//
//  Klausur+CoreDataProperties.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 30.11.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Klausur.h"

NS_ASSUME_NONNULL_BEGIN

@interface Klausur (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDecimalNumber *dauer;
@property (nullable, nonatomic, retain) NSDate *nachschreibetermin;
@property (nullable, nonatomic, retain) NSString *notizen;
@property (nullable, nonatomic, retain) NSNumber *restkursFrei;
@property (nullable, nonatomic, retain) NSDate *zeit;
@property (nullable, nonatomic, retain) NSSet<Klausuraufsicht *> *aufsicht;
@property (nullable, nonatomic, retain) Kurs *kurs;
@property (nullable, nonatomic, retain) Note *note;
@property (nullable, nonatomic, retain) Raum *raum;

@end

@interface Klausur (CoreDataGeneratedAccessors)

- (void)addAufsichtObject:(Klausuraufsicht *)value;
- (void)removeAufsichtObject:(Klausuraufsicht *)value;
- (void)addAufsicht:(NSSet<Klausuraufsicht *> *)values;
- (void)removeAufsicht:(NSSet<Klausuraufsicht *> *)values;

@end

NS_ASSUME_NONNULL_END
