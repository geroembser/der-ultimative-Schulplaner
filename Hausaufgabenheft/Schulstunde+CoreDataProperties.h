//
//  Schulstunde+CoreDataProperties.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 09.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Schulstunde.h"

NS_ASSUME_NONNULL_BEGIN

@class Vertretung;

@interface Schulstunde (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *beginn;
@property (nullable, nonatomic, retain) NSNumber *blocknummer;
@property (nullable, nonatomic, retain) NSDecimalNumber *dauer;
@property (nullable, nonatomic, retain) NSNumber *ende;
@property (nullable, nonatomic, retain) NSDate *geaendertAm;
@property (nullable, nonatomic, retain) NSDate *hinzugefuegtAm;
@property (nullable, nonatomic, retain) NSString *kursID;
@property (nullable, nonatomic, retain) NSString *raumnummer;
@property (nullable, nonatomic, retain) NSString *sonstiges;
@property (nullable, nonatomic, retain) NSNumber *wochentag;
@property (nullable, nonatomic, retain) Kurs *kurs;
@property (nullable, nonatomic, retain) Lehrer *lehrer;
@property (nullable, nonatomic, retain) Raum *raum;
@property (nullable, nonatomic, retain) NSSet<Vertretung *> *vertretungen;

@end

@interface Schulstunde (CoreDataGeneratedAccessors)

- (void)addVertretungenObject:(Vertretung *)value;
- (void)removeVertretungenObject:(Vertretung *)value;
- (void)addVertretungen:(NSSet<Vertretung *> *)values;
- (void)removeVertretungen:(NSSet<Vertretung *> *)values;

@end

NS_ASSUME_NONNULL_END
