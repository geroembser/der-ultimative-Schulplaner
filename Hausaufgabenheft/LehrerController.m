//
//  LehrerController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 21.11.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "LehrerController.h"
#import "Lehrer.h"
#import "ServerRequestController.h" //für Server-Anfragen

@interface LehrerController ()

@property NSURLSession *getTeacherSession;

@end

@implementation LehrerController

#pragma mark - LehrerController init
- (instancetype)initWithUser:(User *)user {
    self = [super init];
    
    if (self) {
        self.associatedUser = user;
    }
    
    return self;
}

#pragma mark - defaultLehrerController
+ (LehrerController *)defaultController {
    
    LehrerController *lehrerController = [[LehrerController alloc]initWithUser:[User defaultUser]];
    
    return lehrerController;
}


#pragma mark - refreshTeacherData
- (void)refreshTeacherData {
    
    //eine Server-Anfrage mithilfe der von uns erstellten spezifischen Klasse "ServerRequestController"
    ServerRequestController *serverRequest = [[ServerRequestController alloc]initWithUser:self.associatedUser];
    
    //setzte das Delegate
    serverRequest.delegate = self;
    
    //von der Server-Request erstelle einen DataTask
    NSURLSessionDataTask *dataTask = [serverRequest dataTaskForURL:[NSURL URLWithString:@"http://projektkurs.marienschule.de/bms-app/getTeachersNew.php"] withParameterDict:nil];
    
    //das Delegate informieren, dass der Download starten
    if ([self.delegate respondsToSelector:@selector(didBeginDownloadingTeacherDataInLehrerController:)]) {
        [self.delegate didBeginDownloadingTeacherDataInLehrerController:self];
    }
    
    //den Download von diesem DataTask starten
    [dataTask resume];
    
    
    
    
    
    
    
    
//    NSString *getTeacherScriptPath = @"";
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:getTeacherScriptPath]];
    
//    //die Session erstellen
//    self.getTeacherSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//    
//    NSURLSessionDataTask *dataTask = [self.getTeacherSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        
//        //returned json-data
//        NSError *jsonError;
//        NSDictionary *returnedDict = data!= nil ? [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError]: nil;
//        
//        NSLog(@"%@", returnedDict);
//        //variables for error handling
//        BOOL successful;
//        NSError *errorToReturn;
//        
//        //nur erfolgreich, wenn kein Fehler passiert ist und auch die returnedDict kein error-Element enthält
//        if ((!error) && [returnedDict valueForKey:@"error"] == nil) {
//            successful = YES;
//            
//        }
//        else {
//            successful = NO;
//            errorToReturn = error;
//            if (returnedDict) {
//                //als Fehlermeldung den Fehler der vom Skript zurückgegeben wurde nehmen
//                if ([returnedDict valueForKey:@"error"]) {
//                    errorToReturn = [NSError errorWithDomain:@"scriptError" code:111 userInfo:@{NSLocalizedDescriptionKey:[returnedDict valueForKey:@"error"]}];
//                }
//            }
//        }
//        
////        //die Delegate Methode aufrufen, die zurückgibt, ob die Anfrage erfolgreich war
////        if ([self.delegate respondsToSelector:@selector(loginEndSuccessfully:withError:)]) {
////            [self.delegate loginEndSuccessfully:successful withError:errorToReturn];
////        }
//    }];
//    
//    [dataTask resume];
    
}

#pragma mark - ServerRequestControllerDelegate methods
- (void)didFinishDownloadingDataTask:(NSURLSessionDataTask *)dataTask withData:(NSData *)downloadedData andError:(NSError *)error {
    //der Fehler, der ans Delegate übergeben werden solö
    NSError *errorToReturn = error;
    if (downloadedData && !error) {
        
        //die heruntergeladenen Daten als JSON interpretieren
        NSError *jsonError;
//        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:downloadedData options:0 error:&jsonError];

        
        ///Die eventuell schon vorhandenen Lehrer mit den aktuellen Einstellungen bearbeiten
        //--> Also erst schauen, ob schon ein Lehrer mit dem gegebenen Kürzel existiert, wenn noch nicht, dann eine neue Instanz erstellen. Sollte bereits eine Instanz von Lehrer erstellt worden sein, dann deren Einstellungen auf die neuen heruntergeladenen ändern
        
        ///wichtig...
        
        
        
        if (!jsonError) {
            //wenn JSON-Parsing-Error, dann den JSON Fehler an die entsprechende Delegate-Methode übergeben
            errorToReturn = jsonError;
        }
        else {
            //die geparsten JSON-Daten einlesen und daraus Lehrer-Objekte erstellen
            
        }
        
    }
    
    //Delegate Methoden aufrufen
    if ([self.delegate respondsToSelector:@selector(didFinishDownloadingTeacherDataInLehrerController:withError:)]) {
        [self.delegate didFinishDownloadingTeacherDataInLehrerController:self withError:errorToReturn];
    }
}


@end
