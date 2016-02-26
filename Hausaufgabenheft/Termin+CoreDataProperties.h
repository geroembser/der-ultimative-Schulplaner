//
//  Termin+CoreDataProperties.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 30.11.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Termin.h"

NS_ASSUME_NONNULL_BEGIN

@interface Termin (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *beschaeftigt;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSDate *erinnerung;
@property (nullable, nonatomic, retain) NSDate *hinzugefuegtAm;
@property (nullable, nonatomic, retain) NSString *quelle;
@property (nullable, nonatomic, retain) NSNumber *schulfrei;
@property (nullable, nonatomic, retain) NSNumber *terminID;
@property (nullable, nonatomic, retain) NSDate *zuletztAktualisiert;

@end

NS_ASSUME_NONNULL_END
