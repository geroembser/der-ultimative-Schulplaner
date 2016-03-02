//
//  User.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 30.11.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Kurs;
@class Stundenplan;

NS_ASSUME_NONNULL_BEGIN

@interface User : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

#pragma mark Klassenmethoden

///gibt den aktuell, eigeloggten Benutzer zurück, oder nil
+ (User *)defaultUser;

///gibt einen eventuell vorhandenen Benutzer mit dem übergebenen Benutzernamen zurück
+ (User *)userForUsername:(NSString *)username;

///gibt an, ob die Daten, die für den Benutzer vorhanden sind, gültig sind (also die Daten für die kompletten/wichtigen Funktionen der App vorhanden sind); wenn zum Beispiel ein paar der Daten, die heruntergeladen worden fehlerhaft sind oder der Download fehlgeschlagen ist, sollte diese Methode auch NO zurückgeben, damit entsprechend im user interface Dinge bereitgestellt werden können, die anzeigen, dass die Funktionalität der App eingeschränkt ist oder neue Daten heruntergeladen werden können. Außerdem kann diese Einstellung auf NO gesetzt werden, wenn zum Beispiel ein neues Schuljahr ansteht oder nach einem App-Update ein Update der Benutzerdaten (oder App-Daten) erforderlich ist.
- (BOOL)hasValidData; //#todo

/**
 Erstellt einen neuen Benutzer in der Datenbank mit den übergebenen Parametern und speichert auch das Passwort im Schlüsselbund des Systems.
 @param optional: name
 @param optional: vorname
 @param required: username
 @param requierd: password
 @returns User den neuen Benutzer
 */
+ (User *)newUserWithName:(NSString *)name vorname:(NSString *)vorname benutzername:(NSString *)username undPasswort:(NSString *)password;


#pragma mark Instanzmethoden
///logged den aktuellen Benutzer aus (setzt nur einen entsprechenden Boolean)
- (void)logout;
///logged den aktuellen Benutzer ein (setzt im Prinzip nur einen entsprechenden Boolean)
- (void)login;
///gibt das Passwort des Benutzers als Klartext zurück
@property (nonatomic) NSString *password;

/**
 Das speichert die Daten in der Datenbank
 */
- (void)save;

///gibt die Anzahl der ausstehenden Aufgaben zurück
- (NSUInteger)anzahlAusstehendeAufgaben;

///gibt den kompletten Namen des Users zurück - Format: "Vorname Nachname"
- (NSString *)fullName;

#pragma mark - Properties
///hält den Stundenplan für den Benutzer
@property (nonatomic) Stundenplan *stundenplan;




@end

NS_ASSUME_NONNULL_END

#import "User+CoreDataProperties.h"
