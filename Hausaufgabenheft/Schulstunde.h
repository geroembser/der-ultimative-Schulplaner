//
//  Schulstunde.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 18.11.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Kurs, Lehrer, Raum;

NS_ASSUME_NONNULL_BEGIN
///Der Wochentag
typedef NS_ENUM(NSInteger, SchulstundeWochentag) {
    ///Montag
    montagWochentag = 0, ///Dienstag
    dienstagWochentag = 1, ///Mittwoch
    mittwochWochentag = 2, ///Donnerstag
    donnerstagWochentag = 3, ///Freitag
    freitagWochentag = 4, ///Samstag
    samstagWochentag = 5, ///Sonntag
    sonntagWochentag = 6
};

@interface Schulstunde : NSManagedObject

// Insert code here to declare functionality of your managed object subclass


#pragma mark - Eigenschaften von der Schulstunde zurückgeben/setzen
//Dieses Attribut gibt an, ob eine besondere Vertretung in der Stunde vorliegt
//@property Vertretung *vertretung;

///gibt an, dass die Stunde eine Freistunde ist
@property BOOL isFreistunde;

///gibt den Wochentag der Stunde als human readable string zurück
- (NSString *)wochentagString;
///gibt die Stunde, in der der Kurs stattfindet als human readable string zurück
- (NSString *)stundenString;

///gibt einen String zurück, der die Dauer der Stunde angibt (mit der Uhrzeit, Beispiel: "14:15 Uhr - 15:00 Uhr")
- (NSString *)uhrzeitDauerString;

#pragma mark - Instanzen von Schulstunden zurückgeben
+ (Schulstunde *)neueSchulstundeFuerWochentag:(NSUInteger)wochentag undStunde:(NSUInteger)stunde mitLehrerKuerzel:(NSString *)lehrerKuerzel undRaumString:(NSString *)raum blocknummer:(NSInteger)blocknummer undKursId:(NSString *)kursId inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Schulstunde *)schulstundeFuerWochentag:(NSUInteger)wochentag undStunde:(NSUInteger)stunde inManagedObjectContext:(NSManagedObjectContext *)context;

///gibt eine Freistunde zurück, mit den gegebenen Daten zurück
+ (Schulstunde *)freistundeFuerWochentag:(SchulstundeWochentag)wochentag undStunde:(NSUInteger)stunde;


#pragma mark - Instanzen entfernen
+ (void)alleSchulstundenEntfernenInManagedObjectContext:(NSManagedObjectContext *)context;


@end

NS_ASSUME_NONNULL_END

#import "Schulstunde+CoreDataProperties.h"
