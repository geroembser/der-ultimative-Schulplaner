//
//  Lehrer+CoreDataProperties.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 09.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Lehrer.h"

NS_ASSUME_NONNULL_BEGIN
@class Vertretung;

@interface Lehrer (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *faecher;
@property (nullable, nonatomic, retain) NSString *kuerzel;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *titel;
@property (nullable, nonatomic, retain) NSString *vorname;
@property (nullable, nonatomic, retain) NSSet<Klausuraufsicht *> *aufsichten;
@property (nullable, nonatomic, retain) NSSet<Kurs *> *kurse;
@property (nullable, nonatomic, retain) NSSet<Schulstunde *> *stunden;
@property (nullable, nonatomic, retain) NSSet<Vertretung *> *vertretungen;

@end

@interface Lehrer (CoreDataGeneratedAccessors)

- (void)addAufsichtenObject:(Klausuraufsicht *)value;
- (void)removeAufsichtenObject:(Klausuraufsicht *)value;
- (void)addAufsichten:(NSSet<Klausuraufsicht *> *)values;
- (void)removeAufsichten:(NSSet<Klausuraufsicht *> *)values;

- (void)addKurseObject:(Kurs *)value;
- (void)removeKurseObject:(Kurs *)value;
- (void)addKurse:(NSSet<Kurs *> *)values;
- (void)removeKurse:(NSSet<Kurs *> *)values;

- (void)addStundenObject:(Schulstunde *)value;
- (void)removeStundenObject:(Schulstunde *)value;
- (void)addStunden:(NSSet<Schulstunde *> *)values;
- (void)removeStunden:(NSSet<Schulstunde *> *)values;

- (void)addVertretungenObject:(Vertretung *)value;
- (void)removeVertretungenObject:(Vertretung *)value;
- (void)addVertretungen:(NSSet<Vertretung *> *)values;
- (void)removeVertretungen:(NSSet<Vertretung *> *)values;

@end

NS_ASSUME_NONNULL_END
