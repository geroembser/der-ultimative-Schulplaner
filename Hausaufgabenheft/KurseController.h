//
//  KurseController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 08.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Schulstunde.h"

@class KurseController;
@protocol KurseControllerDelegate <NSObject>

@optional
- (void)kurseController:(KurseController *)kurseController didFinishUpdateKurseSuccessful:(BOOL)successful;
- (void)kurseControllerDidStartUpdateKurse:(KurseController *)kurseController;

@end

///Diese Klasse soll die Kurse und Stunden der Kurse für einen Benutzer verwalten, der mit diesem Controller verbunden ist. Gleichzeitig soll dieser Controller die einzelnen Schulstunden der einzelnen Kurse des Benutzers verwalten.
@interface KurseController : NSObject

///Custom Initialization with User
- (instancetype)initWithUser:(User *)user;

///Standard-KurseController - mit dem Standardbenutzer
+ (KurseController *)defaultKurseController;

///Delegate


//neue Kurse herunterladen bzw. Datenbank/Daten nach Abfrage (durch das Delegate) ändern


///Delegate Methoden:

///should update data etc. - asks delegate for updating data or not

///gibt an, ob das neue Daten für Kurse (bzw. Studenpläne/Schulstunden) verfügbar sind
//- (BOOL)stundenplanAenderungenVerfuegbar;

///gibt alle Kurse für den aktuellen Benutzer zurück
- (NSArray *)allKurseForCurrentUser;

///gibt einen Array von allen aktiven Kursen des aktuellen Benutzers zurück
- (NSArray *)alleAktivenKurseForCurrentUser;

///gibt alle Schulstunden für den jeweiligen Benutzer zurück
- (NSArray *)allStundenForCurrentUser;

///archiviert alle Kurse des aktuellen Benutzers
- (void)archiviereAlleKurseFuerDenAktuellenBenutzer;
///archiviert alle Projektkurse und alle AGs für den aktuellen Benutzer
- (void)archiviereAllePKsUndAgsFuerDenAktuellenBenutzer;
///archiviert alle normalen Kurse für den aktuellen Benutzer
- (void)archiviereAlleNormalenKurseFuerDenAktuellenBenutzer;

///der Benutzer, für den der KurseController die Kurse verwaltet
@property User *associatedUser;

///das Delegate des KurseControllers
@property id <KurseControllerDelegate> delegate;


///erstellt aus einem Array von gegebenen Schulstunden Kurse, indem die Blocknummer bzw, die Kurs-ID und die Lehrer verglichen werden. Alle Schulstunden werden so einem gegebenen Kurs übergeben
- (NSArray *)kurseInDatenbankAusSchulstunden:(NSArray <Schulstunde *> *)schulstunden inManagedObjectContext:(NSManagedObjectContext *)context;



#pragma mark - alt oder zukünftig
/////lädt alle Projektkurse und AGs herunter (für die Stufe des übergebenen Benutzers) und speichert die Daten entsprechend in einer Datenbank
//- (void)projektKurseUndAGsHerunterladen;
//
/////erstellt aus den Stunden in der Datenbank Kurse
//- (void)erstelleKurseAusStundenplanVonStufe;



//#alt
///erstellt einen Array von Kursen aus einem gegebenen Array von Schulstunden
//- (NSArray *)kurseAusSchulstunden:(NSArray *)schulstunden;


@end
