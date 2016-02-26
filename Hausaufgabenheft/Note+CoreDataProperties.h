//
//  Note+CoreDataProperties.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 30.11.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Note.h"

NS_ASSUME_NONNULL_BEGIN

@interface Note (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDecimalNumber *klassendurchschnitt;
@property (nullable, nonatomic, retain) NSNumber *punkte;
@property (nullable, nonatomic, retain) NSNumber *schriftlich;
///Art der Note, also zum Beispiel "mündlich, 1. Halbjahr Q2"
@property (nullable, nonatomic, retain) NSString *beschreibung;
///Datum, an dem die Note hinzugefügt wurde
@property (nullable, nonatomic, retain) NSDate *hinzugefuegtAm;
@property (nullable, nonatomic, retain) Klausur *klausur;
@property (nullable, nonatomic, retain) Kurs *kurs;

@end

NS_ASSUME_NONNULL_END
