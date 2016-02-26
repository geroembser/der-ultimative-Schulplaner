//
//  NSDate+AdvancedDate.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 14.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "NSDate+AdvancedDate.h"

@implementation NSDate (AdvancedDate)

///gibt ein Datum zurück, dessen Uhrzeit auf 00.00.00 Uhr gesetzt wurde
- (NSDate *)midnightUTC {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                   fromDate:self];
    [dateComponents setHour:0];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    
    NSDate *midnightUTC = [calendar dateFromComponents:dateComponents];
    
    return midnightUTC;
}

//gibt den Wochentag zurück
- (SchulstundeWochentag)wochentag {
    //vom aktuellen Datum entscheiden, welcher Schultag als nächstes ist bzw. welcher gerade ist
    //den aktuellen Wochentag als integer-Wert zurückgeben
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setFirstWeekday:2]; //Montag ist der erste Tag der Woche, nicht Sonntag (=1)
    NSUInteger weekday = [gregorian ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:self]-1;
    
    return weekday;
}

@end
