//
//  ServerUserDataController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 30.11.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "User.h"


/**
 Das Protokoll, was benutzt wird, um das Delegate des ServerUserDataControllers über eventuelle Änderungen oder Fehler etc. in der Kommunikation mit dem Server zu informieren
 */
@class ServerUserDataController;
@protocol ServerUserDataControllerDelegate <NSObject>

@optional
/**
 Diese Methode wird aufgerufen, wenn der Login-Vorgang gestartet wurde
 @returns void
 */

-(void)loginDidStart;
/**
 Wenn der Login erfolgreich abgeschlossen wurde wird die Methode mit dem Parameter successful=YES und error=nil aufgerufen. Im anderen Fall umgekehrt
 @returns void
 */

-(void)loginEndSuccessfully:(BOOL)successful withError:(NSError *)error;
/**
 Wird aufgerufen, wenn der Logout erfolgreich oder unerfolgreich abgeschlossen wurde.
 @returns void
 */
-(void)logoutEndSuccessfully:(BOOL)successful withError:(NSError *)error;

/**
 Diese Methode wird aufgerufen, wenn ein neuer Benutzer erfolgreich angemeldet wurde und entsprechend in der Datenbank erstellt wurde.
 @param newCreatedUser: die Instanz vom neuerstellten Benutzer
 @param serverUserDataController: die Instanz des ServerUserDataControllers, die die Anmeldung ausgeführt hat.
 @returns void
 */
- (void)successfullyLoggedInAndCreatedDatabaseInstanceForUser:(User *)newCreatedUser withServerUserDataController:(ServerUserDataController *)serverUserDataController;

@end

/**
 Eine Klasse, die sämtliche Interaktionen bezüglich der Benutzerdaten für einen bestimmten Benutzer mit der Lernplattform ausführt
 */
@interface ServerUserDataController : NSObject

#pragma mark - Properties/Attribute

///der mit dem ServerUserDataController verbundene User
@property User *associatedUser;

///das Delegate, an das sämtliche Fehlermeldungen in der Kommunikation mit dem Server geschickt werden
@property id <ServerUserDataControllerDelegate> delegate;

#pragma mark - Initialisierungsmethoden
/// einen neuen ServerUserDataController mit einem gegebenen Benutzer erstellen, oder einen Standard-Controller zurückgeben
- (instancetype)initWithUser:(User *)user;


#pragma mark - Klassenmethoden



#pragma mark - Instanzmethoden
////////////folgende Methoden funktionieren nur, wenn ein User in der Variable associatedUser gegeben ist /////////

///loggt den Benutzer aus
- (BOOL)logout;

////////////////////////////////////////////////////////////////

///loggt den Benutzer mit den gegebenen Daten ein - über das Delegate werden entsprechende Nachrichten verschickt
- (void)loginUserWithUsername:(NSString *)username andPassword:(NSString *)password andStufe:(NSString *)stufe;

/////////////



// hier können Methoden folgen, die Beispielsweise den Benutzernamen oder das Passwort vom Server ändern


@end
