//
//  Antwort+CoreDataProperties.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 28.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Antwort.h"

NS_ASSUME_NONNULL_BEGIN

@interface Antwort (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *antwortKurz;
@property (nullable, nonatomic, retain) NSString *antwortLangfassung;
@property (nullable, nonatomic, retain) NSNumber *richtig;
@property (nullable, nonatomic, retain) NSManagedObject *frage;

@end

NS_ASSUME_NONNULL_END
