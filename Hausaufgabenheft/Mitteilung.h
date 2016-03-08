//
//  Mitteilung.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 07.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

NS_ASSUME_NONNULL_BEGIN

@interface Mitteilung : NSManagedObject

#pragma mark - Mitteilungen erstellen
///erstellt eine neue Mitteilung mit der gegebenen ID für den gegebenen User im gegebenen ManagedObjectContext
+ (Mitteilung *)mitteilungErstellenMitID:(NSUInteger)id fuerUser:(User *)user inManagedObjectContext:(NSManagedObjectContext *)context;

#pragma mark - Mitteilungen zurückgeben
///gibt eine Mitteilung mit der gegebenen ID und dem gegebnen User im gegebnen MangedObjectContext zurück, oder nil
+ (Mitteilung *)mitteilungFuerID:(NSUInteger)id undUser:(User *)user inManagedObjectContext:(NSManagedObjectContext *)context;

#pragma mark - Mitteilungen löschen
///löscht die Mitteilung entgültig
- (void)loescheMitteilung;

@end

NS_ASSUME_NONNULL_END

#import "Mitteilung+CoreDataProperties.h"
