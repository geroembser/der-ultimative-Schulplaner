//
//  Klausuraufsicht+CoreDataProperties.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 30.11.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Klausuraufsicht.h"

NS_ASSUME_NONNULL_BEGIN

@interface Klausuraufsicht (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *fromDate;
@property (nullable, nonatomic, retain) NSDate *toDate;
@property (nullable, nonatomic, retain) Klausur *klausur;
@property (nullable, nonatomic, retain) Lehrer *lehrer;

@end

NS_ASSUME_NONNULL_END
