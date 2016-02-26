//
//  Vertretung+CoreDataProperties.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 19.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Vertretung.h"

NS_ASSUME_NONNULL_BEGIN

@interface Vertretung (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *art;
@property (nullable, nonatomic, retain) NSDate *datum;
@property (nullable, nonatomic, retain) NSNumber *eva;
@property (nullable, nonatomic, retain) NSDate *hinzugefuegtAm;
@property (nullable, nonatomic, retain) NSString *kursID;
@property (nullable, nonatomic, retain) NSDate *letzteAenderung;
@property (nullable, nonatomic, retain) NSString *notiz;
@property (nullable, nonatomic, retain) NSString *raum;
@property (nullable, nonatomic, retain) NSString *artBitfields;
@property (nullable, nonatomic, retain) Schulstunde *schulstunde;
@property (nullable, nonatomic, retain) Lehrer *vertretungslehrer;

@end

NS_ASSUME_NONNULL_END
