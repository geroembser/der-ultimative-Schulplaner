//
//  NSDate+AdvancedDate.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 14.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Schulstunde.h"

///Diese Kategorie bietet weitere Funktionen für NSDate-Objekte
@interface NSDate (AdvancedDate)

///Gibt das Datum-Objekt zurück aber als Datum, dessen Uhrzeit auf Null gesetzt wurde - also um Mitternacht
- (NSDate *)midnightUTC;

///gibt den Wochentag eines Datums so zurück, dass er dem Format des SchulstundeWochentag-Typs entspricht
- (SchulstundeWochentag)wochentag;


@end
