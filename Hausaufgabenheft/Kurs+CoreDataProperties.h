//
//  Kurs+CoreDataProperties.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 04.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Kurs.h"

NS_ASSUME_NONNULL_BEGIN

@class Frage, Themenbereich,WebsiteTag;

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
@property (nullable, nonatomic, retain) NSSet<Frage *> *fragen;
@property (nullable, nonatomic, retain) NSSet<Klausur *> *klausuren;
@property (nullable, nonatomic, retain) Lehrer *lehrer;
@property (nullable, nonatomic, retain) NSSet<Note *> *noten;
@property (nullable, nonatomic, retain) NSSet<Schulstunde *> *stunden;
@property (nullable, nonatomic, retain) NSSet<WebsiteTag *> *tags;
@property (nullable, nonatomic, retain) NSSet<Themenbereich *> *themenbereiche;
@property (nullable, nonatomic, retain) User *user;

@end

@interface Kurs (CoreDataGeneratedAccessors)

- (void)addAufgabenObject:(Aufgabe *)value;
- (void)removeAufgabenObject:(Aufgabe *)value;
- (void)addAufgaben:(NSSet<Aufgabe *> *)values;
- (void)removeAufgaben:(NSSet<Aufgabe *> *)values;

- (void)addFragenObject:(Frage *)value;
- (void)removeFragenObject:(Frage *)value;
- (void)addFragen:(NSSet<Frage *> *)values;
- (void)removeFragen:(NSSet<Frage *> *)values;

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

- (void)addTagsObject:(WebsiteTag *)value;
- (void)removeTagsObject:(WebsiteTag *)value;
- (void)addTags:(NSSet<WebsiteTag *> *)values;
- (void)removeTags:(NSSet<WebsiteTag *> *)values;

- (void)addThemenbereicheObject:(Themenbereich *)value;
- (void)removeThemenbereicheObject:(Themenbereich *)value;
- (void)addThemenbereiche:(NSSet<Themenbereich *> *)values;
- (void)removeThemenbereiche:(NSSet<Themenbereich *> *)values;

@end

NS_ASSUME_NONNULL_END
