//
//  Mitteilung.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 07.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "Mitteilung.h"
#import "User.h"

@implementation Mitteilung

#pragma mark - Erstellen
+ (Mitteilung *)mitteilungErstellenMitID:(NSUInteger)id fuerUser:(User *)user inManagedObjectContext:(NSManagedObjectContext *)context {
    if (id && user && context) {
        Mitteilung *neueMitteilung = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"Mitteilung"
                                      inManagedObjectContext:context];
        neueMitteilung.id = @(id);
        neueMitteilung.user = user;
        
        //das Datum der Mitteilung setzen, das angibt, wann diese Mitteilung lokal zur Datenbank "hinzugefügt" wurde
        neueMitteilung.lokalHinzugefuegtAm = [NSDate date]; //das heutige, aktuelle Datum dafür nehmen
        
        //beim Erstellen einer neuen Mitteilung zusätzlich die letzte lokale Änderung setzen
        neueMitteilung.letzteLokaleAenderung = [NSDate date]; //das Datum ist auch das heutige, aktuelle Datum
        
        return neueMitteilung;
    }
    
    return nil;
}

#pragma mark - vorhandenen Zurückgeben
+ (Mitteilung *)mitteilungFuerID:(NSUInteger)id undUser:(nonnull User *)user inManagedObjectContext:(nonnull NSManagedObjectContext *)context{
    if (id && user && context) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Mitteilung" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        // Specify criteria for filtering which objects to fetch
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %lu AND user == %@", id, user];
        [fetchRequest setPredicate:predicate];
    
        // Specify how the fetched objects should be sorted
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"datum"
                                                                       ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil) {
            return nil;
        }
        return fetchedObjects.firstObject;
    }
    return nil;
}

#pragma mark - Mitteilung löschen
- (void)loescheMitteilung {
    // die Mitteilung löschen
    [self.managedObjectContext deleteObject:self];
    
    //den ManagedObjectContext speichern
    NSError *savingError;
    [self.managedObjectContext save:&savingError];
    
    if (savingError) {
        NSLog(@"Fehler beim Löschen des Objekts: %@", self);
    }
    
}
@end
