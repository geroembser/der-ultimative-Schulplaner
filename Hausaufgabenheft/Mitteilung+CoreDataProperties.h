//
//  Mitteilung+CoreDataProperties.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 07.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Mitteilung.h"

NS_ASSUME_NONNULL_BEGIN

@interface Mitteilung (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSString *titel;
@property (nullable, nonatomic, retain) NSString *nachricht;
@property (nullable, nonatomic, retain) NSDate *datum;
@property (nullable, nonatomic, retain) NSDate *letzteLokaleAenderung;
@property (nullable, nonatomic, retain) NSDate *lokalHinzugefuegtAm;
@property (nullable, nonatomic, retain) NSString *stufen;
@property (nullable, nonatomic, retain) User *user;

@end

NS_ASSUME_NONNULL_END
