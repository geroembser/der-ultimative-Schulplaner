//
//  Raum+CoreDataProperties.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 30.11.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Raum.h"

NS_ASSUME_NONNULL_BEGIN

@interface Raum (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *beamer;
@property (nullable, nonatomic, retain) NSString *beschreibung;
@property (nullable, nonatomic, retain) NSNumber *computer;
@property (nullable, nonatomic, retain) NSString *funktion;
@property (nullable, nonatomic, retain) NSNumber *kapazitaet;
@property (nullable, nonatomic, retain) NSNumber *lautsprecher;
@property (nullable, nonatomic, retain) NSString *nummer;
@property (nullable, nonatomic, retain) NSSet<Klausur *> *klausuren;
@property (nullable, nonatomic, retain) NSSet<Schulstunde *> *stunden;

@end

@interface Raum (CoreDataGeneratedAccessors)

- (void)addKlausurenObject:(Klausur *)value;
- (void)removeKlausurenObject:(Klausur *)value;
- (void)addKlausuren:(NSSet<Klausur *> *)values;
- (void)removeKlausuren:(NSSet<Klausur *> *)values;

- (void)addStundenObject:(Schulstunde *)value;
- (void)removeStundenObject:(Schulstunde *)value;
- (void)addStunden:(NSSet<Schulstunde *> *)values;
- (void)removeStunden:(NSSet<Schulstunde *> *)values;

@end

NS_ASSUME_NONNULL_END
