//
//  Kurs.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 18.11.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Aufgabe, Klausur, Lehrer, Note, Schulstunde, User;

//#note die Blocknummer beim CoreData Kurs-Objekt ist die erste Blocknummer aller Schulstunden des Kurses (manchmal ist die Blocknummer von den unterschiedlichen Stunden des Kurses unterschiedlich) --> so, also wenn man eine gleiche Blocknummer für den Kurs hat, kann die Blocknummer zum Sortieren der Kurse im user interface benutzt werden


//ein neuer Typ von Kursart, um die Kursart zu bestimmen, bzw. ihr einen Namen zuzuweisen
typedef enum {
    keineKursArt = 0,
    leistungskursKursArt = 1,
    grundkursKursArt = 2,
    projektkursKursArt = 3,
    vertiefungsKursArt = 4,
    ergänzungsKursArt = 5,
    agKursArt = 6,
    zusatzkursKursArt = 7
    
} KursArt;

NS_ASSUME_NONNULL_BEGIN

@interface Kurs : NSManagedObject
// Insert code here to declare functionality of your managed object subclass

#pragma mark - Infos über den Kurs
///gibt an, ob der Kurs eine AG ist
- (BOOL)isAG;
///gibt an, ob der Kurs ein Projektkurs ist
- (BOOL)isProjektkurs;
///gibt die Kursart als Abkürzungs-String zurück
- (NSString *)kursartString;

///gibt das Kürzel des Fachs anhand der Kurs-ID an //#todo
- (NSString *)fachKuerzel;

///setzt alle als String-Objekte im übergebenen Array mitgegebenen NSStrings als Tags für diesen Kurs fest
- (void)setTagsInArrayOfTagsStrings:(NSArray *)tags;

#pragma mark - Kurs-Instanzen erstellen bzw. vorhandene Kursinstanzen zurückgeben
///gibt alle vorhandenen Kurse mit der ID zurück
+ (NSArray <Kurs *> *)vorhandeneKurseFuerID:(NSString *)kursID inManagedObjectContext:(NSManagedObjectContext *)context;

///gibt einenn vorhandenen Kurs für eine bestimmte ID zurück oder nil;
+ (Kurs *)vorhandenerKursFuerID:(NSString *)kursID inManagedObjectContext:(NSManagedObjectContext *)context;

///gibt einen vorhandenen Kurs mit der gegebenen Kurs-ID zurück oder erstellt einen neuen
+ (Kurs *)kursFuerID:(NSString *)kursID inManagedObjectContext:(NSManagedObjectContext *)context;


///erstellt einen neuen Kurs mit der gegebenen KursID in der Datenbank  von CoreData
+ (Kurs *)neuerKursMitKursID:(NSString *)kursId inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;



@end

NS_ASSUME_NONNULL_END

#import "Kurs+CoreDataProperties.h"
