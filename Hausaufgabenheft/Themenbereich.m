//
//  Themenbereich.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 28.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "Themenbereich.h"
#import "Frage.h"
#import "Kurs.h"

@implementation Themenbereich

// Insert code here to add functionality to your managed object subclass

#pragma mark - Themenbereich-Instanzen zurückgeben
+ (Themenbereich *)vorhandenerThemenbereichMitID:(NSInteger)themenID inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Themenbereich" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %lu", themenID];
    [fetchRequest setPredicate:predicate];
    
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        return nil;
    }
    else {
        return fetchedObjects.firstObject;
    }
    
}

+ (Themenbereich *)themenbereichMitID:(NSInteger)themenID inManagedObjectContext:(NSManagedObjectContext *)context {
    //vorhandenen Themenbereich suchen
    Themenbereich *existingThemenbereich = [Themenbereich vorhandenerThemenbereichMitID:themenID inManagedObjectContext:context];
    
    if (!existingThemenbereich) {
        Themenbereich *neuerThemenbereich = [Themenbereich neuerThemenbereichMitID:themenID inManagedObjectContext:context];
        
        return neuerThemenbereich;
    }
    return existingThemenbereich;
}

+ (Themenbereich *)neuerThemenbereichMitID:(NSInteger)themenID inManagedObjectContext:(nonnull NSManagedObjectContext *)context {
    Themenbereich *newObject = [NSEntityDescription
                                           insertNewObjectForEntityForName:@"Themenbereich"
                                           inManagedObjectContext:context];
    newObject.id = @(themenID);
    
    return newObject;
}


#pragma mark - Attribute/Methoden, die Daten über den Themenbereich zurückgeben
- (NSUInteger)anzahlFragen {
    return self.fragen.count;
}

- (NSUInteger)anzahlRichtigerFragen {
    NSUInteger anzahlRichtigerFragen = 0;
    for (Frage *frage in self.fragen) {
        if ([frage giltAllgemeinAlsRichtigBeantwortet]) { //so ist eine richtig beantwortete Frage in diesem Fall definiert
            anzahlRichtigerFragen++;
        }
    }
    
    return anzahlRichtigerFragen;
}

@end
