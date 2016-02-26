//
//  WebsiteTag.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 27.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Kurs, User;

NS_ASSUME_NONNULL_BEGIN

@interface WebsiteTag : NSManagedObject

// Insert code here to declare functionality of your managed object subclass


#pragma mark - Tag-Instanzen zurückbekommen
///gibt einen vorhandenen WebsiteTag in der Datenbank zurück oder erstellt einen neuen
+ (WebsiteTag *)websiteTagMitTag:(NSString *)tag inManagedObjectContext:(NSManagedObjectContext *)context;

///erstellt einen neuen Website Tag in der Datenbank
+ (WebsiteTag *)neuerWebsiteTagMitTag:(NSString *)tag inManagedObjectContext:(NSManagedObjectContext *)context;

///gibt einen nach Vorkommen und Relevanz sortierten Array von allen Tags für den gegebenen User zurück, die aktiv bzw. relevant sind
+ (NSArray *)alleRelevantenTagsFuerUser:(User *)user;

@end

NS_ASSUME_NONNULL_END

#import "WebsiteTag+CoreDataProperties.h"
