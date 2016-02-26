//
//  Kurs+CoreDataProperties.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 27.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Kurs.h"

NS_ASSUME_NONNULL_BEGIN

@interface Kurs (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *aktiv;
@property (nullable, nonatomic, retain) NSNumber *archiviert;
@property (nullable, nonatomic, retain) NSNumber *blocknummer;
@property (nullable, nonatomic, retain) NSString *fach;
@property (nullable, nonatomic, retain) NSDate *geaendertAm;
@property (nullable, nonatomic, retain) NSDate *hinzugefuegtAm;
@property (nullable, nonatomic, retain) NSString *icon;
@property (nullable, nonatomic, retain) NSString *id;
@property (nullable, nonatomic, retain) NSNumber *kursart;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *schriftlich;
@property (nullable, nonatomic, retain) NSString *schuljahr;
@property (nullable, nonatomic, retain) NSSet<Aufgabe *> *aufgaben;
@property (nullable, nonatomic, retain) NSSet<Klausur *> *klausuren;
@property (nullable, nonatomic, retain) Lehrer *lehrer;
@property (nullable, nonatomic, retain) NSSet<Note *> *noten;
@property (nullable, nonatomic, retain) NSSet<Schulstunde *> *stunden;
@property (nullable, nonatomic, retain) User *user;
@property (nullable, nonatomic, retain) NSSet<NSManagedObject *> *tags;

@end

@interface Kurs (CoreDataGeneratedAccessors)

- (void)addAufgabenObject:(Aufgabe *)value;
- (void)removeAufgabenObject:(Aufgabe *)value;
- (void)addAufgaben:(NSSet<Aufgabe *> *)values;
- (void)removeAufgaben:(NSSet<Aufgabe *> *)values;

- (void)addKlausurenObject:(Klausur *)value;
- (void)removeKlausurenObject:(Klausur *)value;
- (void)addKlausuren:(NSSet<Klausur *> *)values;
- (void)removeKlausuren:(NSSet<Klausur *> *)values;

- (void)addNotenObject:(Note *)value;
- (void)removeNotenObject:(Note *)value;
- (void)addNoten:(NSSet<Note *> *)values;
- (void)removeNoten:(NSSet<Note *> *)values;

- (void)addStundenObject:(Schulstunde *)value;
- (void)removeStundenObject:(Schulstunde *)value;
- (void)addStunden:(NSSet<Schulstunde *> *)values;
- (void)removeStunden:(NSSet<Schulstunde *> *)values;

- (void)addTagsObject:(NSManagedObject *)value;
- (void)removeTagsObject:(NSManagedObject *)value;
- (void)addTags:(NSSet<NSManagedObject *> *)values;
- (void)removeTags:(NSSet<NSManagedObject *> *)values;

@end

NS_ASSUME_NONNULL_END
