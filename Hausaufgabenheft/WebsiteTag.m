//
//  WebsiteTag.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 27.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "WebsiteTag.h"
#import "Kurs.h"
#import "User.h"

@implementation WebsiteTag

// Insert code here to add functionality to your managed object subclass



#pragma mark - Instanzen der Klassen Website Tag zurückgeben
//einen vorhandenen Tag zurückgeben bzw. einen neuen Website-Tag zurückgeben
+ (WebsiteTag *)websiteTagMitTag:(NSString *)tag inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WebsiteTag" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tag like %@", tag];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects == nil || fetchedObjects.count < 1) {
        //ein neues Objekt erstellen und zurückgeben
        return [WebsiteTag neuerWebsiteTagMitTag:tag inManagedObjectContext:context];
    }
    else {
        //das erste Objekt der FetchRequest zurückgeben
        return fetchedObjects.firstObject;
    }
}

+ (WebsiteTag *)neuerWebsiteTagMitTag:(NSString *)tag inManagedObjectContext:(NSManagedObjectContext *)context {
    
    WebsiteTag *newTag = [NSEntityDescription
                                           insertNewObjectForEntityForName:@"WebsiteTag"
                                           inManagedObjectContext:context];
    newTag.tag = tag;
    newTag.hinzugefuegtAm = [NSDate date];
    
    return newTag;
}

#pragma mark - Setter überschreiben
- (void)setTag:(NSString *)tag {
    //Leerzeichen und neue Zeilen am Anfang und Ende des Tags entfernen
    tag = [tag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [self willChangeValueForKey:@"tag"];
    
    [self setPrimitiveValue:tag forKey:@"tag"];
    
    [self didChangeValueForKey:@"tag"];
}


#pragma mark - Tags zurückgeben
+ (NSArray *)alleRelevantenTagsFuerUser:(User *)user {
    if (user) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"WebsiteTag" inManagedObjectContext:user.managedObjectContext];
        [fetchRequest setEntity:entity];
        // Specify criteria for filtering which objects to fetch
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user == %@ AND (vorkommenBeiAktivenKursen > 0 OR relevanz > 0)", user];
        [fetchRequest setPredicate:predicate];
        // Specify how the fetched objects should be sorted
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"vorkommenBeiAktivenKursen"
                                                                       ascending:NO];
        NSSortDescriptor *secondSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"relevanz" ascending:NO];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, secondSortDescriptor, nil]];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [user.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil) {
            return [NSArray new];
        }
        else {
            return fetchedObjects;
        }
    }
    return nil;
}

@end
