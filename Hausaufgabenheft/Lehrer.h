//
//  Lehrer.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 18.11.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Fach, Klausuraufsicht, Kurs, Schulstunde;

NS_ASSUME_NONNULL_BEGIN

@interface Lehrer : NSManagedObject


#pragma mark Lehrer Instanzen zurückgeben
///einen neuen Lehrer zurückgeben und in der Datenbank erstellen oder einen bekannten, schon vorhandenen zurückgeben
+ (Lehrer *)lehrerWithName:(NSString *)name andFaecher:(NSArray <NSString *> *)faecher andKuerzel:(NSString *)kuerzel andEmail:(NSString *)email inManagedObjectContext:(NSManagedObjectContext *)context;

///gibt einen Lehrer zurück, der das angegebenen Kürzel hat, oder erstellt einen neuen, wenn kein Lehrer mit dem gegeben Kürzeln gefunden werden konnte
+ (Lehrer *)lehrerForKuerzel:(NSString *)kuerzel inManagedObjectContext:(NSManagedObjectContext *)context;

///erstellt einen neuen Eintrag in der Lehrer-Tabelle in CoreData für einen Lehrer mit dem gegebenen Kürzel
+ (Lehrer *)neuerLehrerMitKuerzel:(NSString *)kuerzel inManagedObjectContext:(NSManagedObjectContext *)context;


#pragma mark - Lehrer bearbeiten
///setzt die Fächernamen, die als einzelne String-Objekte im übergebenen Array enthalten sind für den Lehrer
- (void)setFaecherArray:(NSArray *)faecherArray;

#pragma mark - Eigenschaften zurückgeben
///gibt einen String zurück, wie es üblich ist, die Lehrer anzusprechen; ein Beispiel: Herr Dr. Gerards
- (NSString *)printableTeacherString;


#pragma mark - alte oder zukünftige (gedachte) Methoden
//#old oder in Zukunft
/////sollte die Fächer für den Lehrer anhand des übergebenen mit Kommata seperierten Kürzel-String setzen
//- (void)setFaecherMitFachKuerzelString:(NSString *)kuerzelString;

@end

NS_ASSUME_NONNULL_END

#import "Lehrer+CoreDataProperties.h"
