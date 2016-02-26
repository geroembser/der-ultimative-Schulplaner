//
//  StundenplanWochentag.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 29.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stunde.h"

///Repräsentiert einen Wochentag im Stundenplan
@interface StundenplanWochentag : NSObject


+ (StundenplanWochentag *)wochentagFuerWochentag:(SchulstundeWochentag)wochentag mitStunden:(NSArray *)stunden;

///gibt den Wochentag, der durch dieses Objekt repräsentiert wird, als Integer-Wert zurück
@property SchulstundeWochentag wochentagInt;

///Die Stunden für den Wochentag
@property NSArray *stunden;

///gibt die Schulstunde für die gegebene Stunde zurück
- (Stunde *)schulstundeFuerStunde:(NSUInteger)stunde;

///gibt als Integer-Wert zurück, was die letzte Stunde des Tages ist
- (NSUInteger)letzteStundeIndex;

///das genaue Datum, also nicht nur die Nummer des Wochentags, für den dieses Objekt die Schulstunden verwaltet (besonders wichtig für das Vertretungsplan-Feature)
@property NSDate *datum;

///Gibt an, ob für diesen Wochentag die Stunden für diesen Wochentag (also für das genaue Datum dieses Wochentags) Vertretungsobjekte enthalten. Anders gesagt, gibt dieses Attribut Aufschluss darüber, ob Vertretungen für eine dieser Stunden dieses Wochentags angezeigt werden sollen.
@property BOOL vertretungenVerfuegbarOderVorhanden;


@end
