//
//  Aufgabe+CoreDataProperties.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 01.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Aufgabe.h"

NS_ASSUME_NONNULL_BEGIN

@interface Aufgabe (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *abgabeDatum;
@property (nullable, nonatomic, retain) NSString *beschreibung;
@property (nullable, nonatomic, retain) NSDate *erinnerungDate;
@property (nullable, nonatomic, retain) NSNumber *erledigt;
@property (nullable, nonatomic, retain) NSDate *erstelltAm;
@property (nullable, nonatomic, retain) NSNumber *keinemFachZugeordnet;
@property (nullable, nonatomic, retain) NSString *mediaFilesPath;
@property (nullable, nonatomic, retain) NSString *notizen;
@property (nullable, nonatomic, retain) NSNumber *prioritaet;
@property (nullable, nonatomic, retain) NSNumber *typ;
@property (nullable, nonatomic, retain) NSDate *zuletztAktualisiert;
@property (nullable, nonatomic, retain) NSString *titel;
@property (nullable, nonatomic, retain) Kurs *kurs;
@property (nullable, nonatomic, retain) User *user;
@property (nullable, nonatomic, retain) NSSet<MediaFile *> *mediaFiles;

@end

@interface Aufgabe (CoreDataGeneratedAccessors)

- (void)addMediaFilesObject:(MediaFile *)value;
- (void)removeMediaFilesObject:(MediaFile *)value;
- (void)addMediaFiles:(NSSet<MediaFile *> *)values;
- (void)removeMediaFiles:(NSSet<MediaFile *> *)values;

@end

NS_ASSUME_NONNULL_END
