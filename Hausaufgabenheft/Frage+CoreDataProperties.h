//
//  Frage+CoreDataProperties.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 29.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Frage.h"


@class Themenbereich;

NS_ASSUME_NONNULL_BEGIN

@interface Frage (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *anzahlFalschBeantwortet;
@property (nullable, nonatomic, retain) NSNumber *anzahlRichtigBeantwortet;
@property (nullable, nonatomic, retain) NSDate *dateLetzteRichtigeAntwort;
@property (nullable, nonatomic, retain) NSString *frage;
@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSString *imageURL;
@property (nullable, nonatomic, retain) NSNumber *schwierigkeit;
@property (nullable, nonatomic, retain) NSDate *hinzugefuegtAm;
@property (nullable, nonatomic, retain) NSDate *zuletztAktualisiert;
@property (nullable, nonatomic, retain) NSSet<Antwort *> *antworten;
@property (nullable, nonatomic, retain) Kurs *kurs;
@property (nullable, nonatomic, retain) Themenbereich *themenbereich;

@end

@interface Frage (CoreDataGeneratedAccessors)

- (void)addAntwortenObject:(Antwort *)value;
- (void)removeAntwortenObject:(Antwort *)value;
- (void)addAntworten:(NSSet<Antwort *> *)values;
- (void)removeAntworten:(NSSet<Antwort *> *)values;

@end

NS_ASSUME_NONNULL_END
