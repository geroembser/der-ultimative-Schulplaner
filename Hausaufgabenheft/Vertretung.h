//
//  Vertretung.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 09.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Lehrer, Schulstunde;

NS_ASSUME_NONNULL_BEGIN

@interface Vertretung : NSManagedObject

// Insert code here to declare functionality of your managed object subclass


///erstellt eine neue Vertretung für eine gegebene Schulstunde im ebenfalls gegebenen ManagedObjectContext
+ (Vertretung *)vertretungFuerSchulstunde:(Schulstunde *)schulstunde inManagedObjectContext:(NSManagedObjectContext *)context;

///gibt an, ob die Stunde frei ist
- (BOOL)isFrei;

///gibt an, ob die Vertretung eine Raumvertretung ist
- (BOOL)isRaumVertretung;


@end

NS_ASSUME_NONNULL_END

#import "Vertretung+CoreDataProperties.h"
