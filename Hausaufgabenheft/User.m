//
//  User.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 30.11.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "User.h"
#import "Kurs.h"
#import "AppDelegate.h"
#import "KeychainItemWrapper.h"
#import "Stundenplan.h"

@implementation User

// Insert code here to add functionality to your managed object subclass
@synthesize stundenplan=_stundenplan;

#pragma mark - class methods
/**
 Gibt den Standardbenutzer zurück, der in der Datenbank als aktuell angemeldet gilt.
 @returns User: den aktuell angemeldeten Benutzer oder nil
 */
+ (User *)defaultUser {
    NSManagedObjectContext *context = [AppDelegate defaultManagedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass([User class])inManagedObjectContext: context];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"(loggedIn == 1)"]];
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetch error:&error];
    
    if([fetchedObjects count] >= 1) {
        return [fetchedObjects objectAtIndex:0];
    }
    else {
        return nil;
    }
    
}

/**
 Gibt einen vorhandenen Benutzer mit dem übergebenen Benutzernamen zurück oder nil;
 @param NSString der Benutzername
 @returns User den eventuell vorhandenen Benutzer
 */
+ (User *)userForUsername:(NSString *)username {
    NSManagedObjectContext *context = [AppDelegate defaultManagedObjectContext];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass([User class])inManagedObjectContext: context];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"(benutzername like %@)", username]];
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetch error:&error];
    
    if([fetchedObjects count] >= 1) {
        return [fetchedObjects objectAtIndex:0];
    }
    else {
        return nil;
    }
}

/**
 Erstellt einen neuen Benutzer mit dem gegebenen Daten in der Datenbank und gibt die Instanz zurück
 @param name Der Name des neuen Benutzers.
 @param vorname Der Vorname des neuen Benutzers.
 @param benutzername Der Benutzername des neuen Benutzers.
 */
+ (User *)newUserWithName:(NSString *)name vorname:(NSString *)vorname benutzername:(NSString *)username undPasswort:(nonnull NSString *)password{
    if (username && username.length > 0 && password.length > 0) {
        //neuen Benutzer in der Datenbank erstellen
        User *newUser = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([User class]) inManagedObjectContext:[AppDelegate defaultManagedObjectContext]];
        
        
        //Objekt konfigurieren
        newUser.benutzername = username;
        newUser.nachname = name;
        newUser.vorname = vorname;
        
        //Passwort im Schlüsselbund sichern
        newUser.password = password;
        
        
        //neuen Benutzer speichern
        [newUser save];
        
        
        return newUser;
    }
    return nil;
}

///erstellt einen Identifier (immer nach dem gleichen Muster) für ein Keychain-Item
+ (NSString *)identifierForUsername:(NSString *)username {
    
    return [NSString stringWithFormat:@"bms-app:%@", username];
    
}

/**
 Loggt den Benutzer aus, indem das Passwort gelöscht wird. Sämtliche Benutzerdaten bleiben ansonsten erhalten, nur die isLoggedIn-property des users wird auf NO (0) gesetzt.
 */
- (void)logout {
    //keychainItem erstellen
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:[User identifierForUsername:self.benutzername] accessGroup:nil];
    
    //keychainItem zurücksetzen
    [keychainItem resetKeychainItem];
    
    //in der Datenbank ausloggen
    self.loggedIn = [NSNumber numberWithBool:NO];
    
    //save the user data
    [self save];
}

//password
- (void)setPassword:(NSString *)password {
    //Passwort im Schlüsselbund sichern
    
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:[User identifierForUsername:self.benutzername] accessGroup:nil];
    [keychainItem setObject:self.benutzername forKey:(__bridge id)(kSecAttrAccount)];
    [keychainItem setObject:passwordData forKey:(__bridge id)(kSecValueData)];
}

- (NSString *)password {
    //Passwort im Schlüsselbund sichern
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:[User identifierForUsername:self.benutzername] accessGroup:nil];
    return [[NSString alloc]initWithData:[keychainItem objectForKey:(__bridge id)(kSecValueData)] encoding:NSUTF8StringEncoding];
}



///gibt an, ob genug gültige Daten für den Benutzer der App vorhanden sind, damit die Funktionalität der App gewährleistet ist
- (BOOL)hasValidData {
    return self.validData.boolValue;
}

///speichert den ManagedObjectContext
- (void)save {
    NSError *error;
    [self.managedObjectContext save:&error];
    
    if (error) {
        NSLog(@"Fehler beim Speichern des Benutzers: %@ \n %@", self.benutzername, error.localizedDescription);
    }
}

#pragma mark - Properties Setter and Getter
-(void)setStundenplan:(Stundenplan *)stundenplan {
    _stundenplan = stundenplan;
}
- (Stundenplan *)stundenplan {
    //wenn kein Stundenlan für den Benutzer gesetzt wurde, dann erstelle einen neuen
    if (!_stundenplan) {
        _stundenplan = [Stundenplan stundenPlanFuerUser:self];
    }
    
    return _stundenplan;
}

#pragma mark - andere Methoden
- (NSUInteger)anzahlAusstehendeAufgaben {
    //fetchController initialisieren
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Aufgabe" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user == %@ AND erledigt == NO", self];
    [fetchRequest setPredicate:predicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    NSArray *fetchedObject = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    if (fetchedObject) {
        return fetchedObject.count;
    }
    else {
        return 0;
    }
}

- (NSString *)fullName {
    return [NSString stringWithFormat:@"%@ %@", self.vorname, self.nachname];
}

@end
