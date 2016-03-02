//
//  Antwort.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 28.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "Antwort.h"

@implementation Antwort

@synthesize gesetzteAntwort;

// Insert code here to add functionality to your managed object subclass


#pragma mark - Antworten zurückgeben/erstellen
+ (NSArray<Antwort *> *)antwortenFuerFrage:(Frage *)frage inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Antwort" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"frage == %@", frage];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        return nil;
    }
    else {
        return fetchedObjects;
    }
}

+ (Antwort *)neueAntwortFuerFrage:(Frage *)frage inManagedObjectContext:(NSManagedObjectContext *)context {
    Antwort *neueAntwort = [NSEntityDescription
                                           insertNewObjectForEntityForName:@"Antwort"
                                           inManagedObjectContext:context];
    neueAntwort.frage = frage;
    
    return neueAntwort;
}

@end
