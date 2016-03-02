//
//  Themenbereich+CoreDataProperties.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 28.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Themenbereich.h"

NS_ASSUME_NONNULL_BEGIN

@interface Themenbereich (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSDate *zuletztAktualisiert;
@property (nullable, nonatomic, retain) NSString *beschreibung;
@property (nullable, nonatomic, retain) NSSet<Frage *> *fragen;
@property (nullable, nonatomic, retain) Kurs *kurs;

@end

@interface Themenbereich (CoreDataGeneratedAccessors)

- (void)addFragenObject:(Frage *)value;
- (void)removeFragenObject:(Frage *)value;
- (void)addFragen:(NSSet<Frage *> *)values;
- (void)removeFragen:(NSSet<Frage *> *)values;

@end

NS_ASSUME_NONNULL_END
