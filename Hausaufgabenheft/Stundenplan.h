//
//  Stundenplan.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 10.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Schulstunde.h"
#import "StundenplanWochentag.h"

@protocol StundenplanDelegate <NSObject>

@optional
///Gibt an, dass der Stundenplan aktualisiert wurde, sodass die Anzeige im user interface neu geladen werden muss. Das kann vorkommen, wenn neue Vertretungen gefunden wurden, sich also der Vertretungsplan geändert hat, oder wenn ein Kurs deaktiviert wurde. Vielleicht in Zukunft auch einmal, wenn ein neuer Stundenplan zu einem neuen Schuljahr veröffentlicht wurde.
- (void)didRefreshStundenplan:(Stundenplan *)stundenplan;

@end

@interface Stundenplan : NSObject


#pragma mark - Stundenpläne erstellen
///erstellt den Stundenplan für den gegebenen Benutzer
+ (Stundenplan *)stundenPlanFuerUser:(User *)user;

///erstellt den Stundenplan für den gegebenen Benutzer in Abhängigkeit der aktuellen Vertretungsstunden. Der Stundenplan wird für die nächsten 7 Tage ab dem gegebenen Datum (inklusive diesem) erstellt. 
+ (Stundenplan *)stundenPlanFuerUser:(User *)user mitVertretungenAbDatum:(NSDate *)date;


///ein Array von StundenplanWochentagen mit den einzelnen Stunden für den Wochentag
@property NSArray *wochentage;

///das Schuljahr für das der Stundenplan gilt
@property NSString *schuljahr;

///der Benutzer, für den der Stundenplan ist
@property User *user;


///das Delegate, an das der Stundenplan seine Nachrichten schicken soll
@property id <StundenplanDelegate> delegate;

///gibt ein StundenplanWochentag-Objekt für den gegebenen Index zurück
- (StundenplanWochentag *)wochentagFuerIndex:(NSUInteger)wochentagIndex;

///gibt eine Stunde für den gegebenen Wochentag und die gegebene Stunde zurück; wenn die gegebene Stunde nicht existiert, dann wird eine Freistunde zurückgegeben, die eben einfach nil ist
- (Stunde *)stundeFuerWochentag:(SchulstundeWochentag)wochentag undStunde:(NSUInteger)stunde;

///gibt einen Array von allen Schulstunden (ohne Freistunden) für den übergebenen Wochentag zurück
- (NSArray *)stundenFuerWochentag:(SchulstundeWochentag)wochentag;

///gibt die nächste Schulstunde, die stattfindet, zurück und auch, ob diese aktuell gerade stattfindet (bzw. stattfinden sollte)
- (Stunde *)naechsteSchulstundeGeradeAktiv:(BOOL *)geradeAktiv;

///gibt die Anzahl der Stunden zurück, die heute stattfinden
- (NSUInteger)anzahlStundenHeute;

#pragma mark - Allgemeine Informationen zu Stundenplänen zurückgeben
///gibt einen Array von Strings mit den Zeiten zurück, wann die einzelnen Schulstunden anfangen (die erste Stunde am Index 0, etc....)
+ (NSArray *)zeitenStundenBeginn;
///gibt einen Array von Strings mit den Zeiten zurück, wann die einzelnen Schulstunden enden (die erste Stunde am Index 0, etc....)
+ (NSArray *)zeitenStundenEnde;



///#alt

@property NSArray *vertretungen;

///aktualisiert die Vertretungen für die Stunden des Stundenplans und aktualisiert den Stundenplan entsprechen
- (void)aktualisiereVertretungen;

@end
