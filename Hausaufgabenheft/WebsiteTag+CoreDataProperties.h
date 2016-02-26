//
//  WebsiteTag+CoreDataProperties.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 09.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "WebsiteTag.h"

NS_ASSUME_NONNULL_BEGIN

@interface WebsiteTag (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *hinzugefuegtAm;
@property (nullable, nonatomic, retain) NSString *tag;
@property (nullable, nonatomic, retain) NSNumber *relevanz;
@property (nullable, nonatomic, retain) NSNumber *vorkommenBeiAktivenKursen;
@property (nullable, nonatomic, retain) NSSet<Kurs *> *kurse;
@property (nullable, nonatomic, retain) User *user;

@end

@interface WebsiteTag (CoreDataGeneratedAccessors)

- (void)addKurseObject:(Kurs *)value;
- (void)removeKurseObject:(Kurs *)value;
- (void)addKurse:(NSSet<Kurs *> *)values;
- (void)removeKurse:(NSSet<Kurs *> *)values;

@end

NS_ASSUME_NONNULL_END
