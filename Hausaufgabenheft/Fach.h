//
//  Fach.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 26.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Fach : NSManagedObject

// Insert code here to declare functionality of your managed object subclass


///erstellt ein neues Fach in der CoreData-Datenbank mit einem gegebenen Kürzel und dem dafür vollen Namen und gibt es als Fach-Objekt zurück
+ (Fach *)neuesFachMitKuerzel:(NSString *)kuerzel undVollemNamen:(nullable NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;

///gibt ein vorhandenes Fach anhand des Fachkürzels (der Abkürzung für das Fach) zurück
+ (Fach *)vorhandenesFachFuerKuerzel:(NSString *)kuerzel inManagedObjectContext:(NSManagedObjectContext *)context;

///gibt ein vorhandenes oder neues Fach zurück, wenn kein Fach mit dem gegebenen Kürzel vorhanden ist
+ (Fach *)fachFuerKuerzel:(NSString *)kuerzel inManagedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "Fach+CoreDataProperties.h"
