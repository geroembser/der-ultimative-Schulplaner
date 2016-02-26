//
//  Fach+CoreDataProperties.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 27.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Fach.h"

NS_ASSUME_NONNULL_BEGIN

@interface Fach (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *kuerzel;

@end

NS_ASSUME_NONNULL_END
