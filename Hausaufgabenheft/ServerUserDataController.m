//
//  ServerUserDataController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 30.11.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "ServerUserDataController.h"
#import "KeychainItemWrapper.h"
#import "AppDelegate.h"

@interface ServerUserDataController () <NSURLSessionDelegate>

@property NSURLSession *loginSession;
@property KeychainItemWrapper *keychainItem;

@end


@implementation ServerUserDataController
#pragma mark initialization
/**
 Erstellt eine neue Instanz des ServerUserDataControllers, mit den gegebenen Parametern.
 @param user: der User, für den der ServerUserDataController eingerichtet sein soll;
 @returns instancetype
 @exceptions nil
 */
- (instancetype)initWithUser:(User *)user {
    self = [super init];
    
    if (self) {
        self.associatedUser = user;
    }
    
    return self;
}


#pragma mark Public Login Method
///login with username and password
- (void)loginUserWithUsername:(NSString *)username andPassword:(NSString *)password andStufe:(NSString *)stufe {
    
    if (username.length > 0 && password.length > 0 && stufe.length > 0) {
        //überprüfen, ob Benutzer bereits in der Datenbank vorhanden ist.....
        
        
        ///...dann wieder nach Passwort Überprüfung auf isLoggedIn = true setzen

        
        
        //Delegate-Methode aufrufen, dass Login gestartet wurde, aber nur, wenn das Delegate auch eine Methode hat, die darauf reagiert
        if ([self.delegate respondsToSelector:@selector(loginDidStart)]) {
            [self.delegate loginDidStart];
        }
        
        NSString *sendData = [NSString stringWithFormat:@"username=%@&pw=%@&stufe=%@", username, password, stufe.uppercaseString];//Stufe als lowercase String (wird vom Server so verlangt)
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://app.marienschule.de/files/scripts/login.php"]];
        
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
        
        //Here you send your data
        [request setHTTPBody:[sendData dataUsingEncoding:NSUTF8StringEncoding]];
        
        [request setHTTPMethod:@"POST"];
        
        //die Login-Session erstellen
        self.loginSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]delegate:self delegateQueue:nil];
        
        NSURLSessionDataTask *postDataTask = [self.loginSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            
            //returned json-data
            NSError *jsonError;
            NSDictionary *returnedDict = data!= nil ? [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError]: nil;
            
            //variables for error handling
            BOOL successful;
            NSError *errorToReturn;
            
            //nur erfolgreich, wenn kein Fehler passiert ist und auch die returnedDict kein error-Element enthält und der HTTP-Status-Code gleich 200 ist
            if ((!error) && httpResponse.statusCode == 200 && [returnedDict valueForKey:@"error"] == nil && !jsonError) {
                successful = YES;
                //ein neues User-Objekt erstellen
                dispatch_async(dispatch_get_main_queue(), ^{
                    User *userToChange; //der User, dessen Daten geändert werden sollen (entweder ein neuer Benutzer oder ein alter, in der Datenbank bereits vorhandener Benutzer)
                    
                    //prüft zuerst, ob bereits ein Benutzer mit den gegebenen Benutzerdaten existiert
                    User *existingUser = [User userForUsername:username];
                    
                    if (existingUser) {
                        userToChange = existingUser;
                        //Passwort, Vornamen, Nachnamen aktualisieren
                        userToChange.vorname = [returnedDict valueForKey:@"firstname"];
                        userToChange.nachname = [returnedDict valueForKey:@"lastname"];
                        userToChange.password = password;
                    }
                    else {
                        //einen neuen Benutzer in der Datenbank speichern - speichert alle Daten inklusive Benutzernamen und Passwort
                        User *newUser = [User newUserWithName:[returnedDict valueForKey:@"lastname"] vorname:[returnedDict valueForKey:@"firstname"] benutzername:username undPasswort:password];
                        
                        userToChange = newUser;
                    }
                    
                    //die Stufe beim Benutzer speichern
                    userToChange.stufe = stufe;
                    
                    //Benutzer auf eingeloggt setzen
                    userToChange.loggedIn = [NSNumber numberWithBool:YES];
                    [userToChange save];
                    
                    //den eingeloggten Benutzer mit deisem ServerUserDataController verbinden
                    self.associatedUser = userToChange;
                
                    //Delegate-Methode aufrufen und informieren, dass ein neuer Benutzer erstellt wurde
                    if ([self.delegate respondsToSelector:@selector(successfullyLoggedInAndCreatedDatabaseInstanceForUser:withServerUserDataController:)]) {
                        [self.delegate successfullyLoggedInAndCreatedDatabaseInstanceForUser:userToChange withServerUserDataController:self];
                    }
                    
                    //die Delegate Methode aufrufen, die zurückgibt, ob die Anfrage erfolgreich war
                    if ([self.delegate respondsToSelector:@selector(loginEndSuccessfully:withError:)]) {
                        [self.delegate loginEndSuccessfully:successful withError:errorToReturn];
                    }
                });
                
            }
            else {
                successful = NO;
                errorToReturn = error;
                
                if (error) {
                    //Höchstwahrscheinlich ein Verbindungsfehler, der als ein solcher ausgegeben werden muss
                    errorToReturn = error;
                }
                //Fehler 400 meint, dass nicht genügend Parameter übergeben wurden, 401 sagt, dass entweder Passwort oder Benutzername oder beides falsch ist
                else if (httpResponse.statusCode == 400) {
                    //Fehler melden an Systemadministrator
                    ///dürfte nicht vorkommen...
                    NSLog(@"Fehler beim Download! Nicht genügend Parameter übergeben! %@", response);
                    //hier sollte eine Nachricht an den Administrator geschickt werden
                    errorToReturn = [NSError errorWithDomain:@"notEnoughParameters" code:401 userInfo:@{NSLocalizedDescriptionKey: @"Schwerwiegender Fehler! Bitte wenden Sie sich an den Administrator!"}];
                }
                else if (httpResponse.statusCode == 401) {
                    //falsches Passwort oder falscher Benutzername
                    errorToReturn = [NSError errorWithDomain:@"wrongPassword" code:401 userInfo:@{NSLocalizedDescriptionKey: @"Falscher Benutzername oder falsches Passwort"}];
                }
                else if (returnedDict) {
                    //als Fehlermeldung den Fehler der vom Skript zurückgegeben wurde nehmen
                    if ([returnedDict valueForKey:@"error"]) {
                        errorToReturn = [NSError errorWithDomain:@"scriptError" code:111 userInfo:@{NSLocalizedDescriptionKey:[returnedDict valueForKey:@"error"]}];
                    }
                }
                
                //die Delegate Methode aufrufen, die zurückgibt, ob die Anfrage erfolgreich war
                if ([self.delegate respondsToSelector:@selector(loginEndSuccessfully:withError:)]) {
                    [self.delegate loginEndSuccessfully:successful withError:errorToReturn];
                }
                
            }
            
            
        }];
        
        [postDataTask resume];
    }
}

#pragma mark Public Logout Method
- (BOOL)logout {
    if (self.associatedUser) {
        [self.associatedUser logout];
        
        if ([self.delegate respondsToSelector:@selector(logoutEndSuccessfully:withError:)]) {
            [self.delegate logoutEndSuccessfully:YES withError:nil];
        }
        
        //keinen aktuellen Benutzer, mit dem dieser Controller verbunden ist, mehr vorhanden.
        self.associatedUser = nil;
        
        return YES;
    }
    return NO;
}

#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    //wichtig für selbst-signierte SSL-Zertifikate
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        if([challenge.protectionSpace.host isEqualToString:@"app.marienschule.de"]){
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        }
    }
}

@end
