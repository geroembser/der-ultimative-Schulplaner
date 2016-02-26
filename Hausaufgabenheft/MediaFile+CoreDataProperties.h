//
//  MediaFile+CoreDataProperties.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 01.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MediaFile.h"

NS_ASSUME_NONNULL_BEGIN

@interface MediaFile (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *typ;
@property (nullable, nonatomic, retain) NSString *path;
@property (nullable, nonatomic, retain) NSDate *hinzugefuegtAm;
@property (nullable, nonatomic, retain) Aufgabe *aufgabe;

@end

NS_ASSUME_NONNULL_END
