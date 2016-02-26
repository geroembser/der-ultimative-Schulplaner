//
//  Lehrer.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 18.11.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "Lehrer.h"
#import "Klausuraufsicht.h"
#import "Kurs.h"
#import "Schulstunde.h"
#import "Fach.h"

@implementation Lehrer

// Insert code here to add functionality to your managed object subclass

#pragma mark - Instanzen zurückgeben/erstellen
//lehrer erstellen
+ (Lehrer *)lehrerWithName:(NSString *)name andFaecher:(NSArray<NSString *> *)faecher andKuerzel:(NSString *)kuerzel andEmail:(NSString *)email inManagedObjectContext:(NSManagedObjectContext *)context {
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    [request setEntity:entity];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like %@", name];
    [request setPredicate:predicate];
    
    
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"yourSortKey" ascending:YES];
//    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
//    [request setSortDescriptors:sortDescriptors];
    
    
    
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:request error:&error];
    
    if ((result != nil) && ([result count]) && (error == nil)){
        return result.firstObject;
    }
    else{
        Lehrer *object = (Lehrer *) [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
        
        //neues Objekt konfigurieren
        object.name = name;
        object.email = email;
        object.kuerzel = kuerzel;
        [object setFaecherArray:faecher];
        
        //neues Objekt speichern
        NSError *error;
        if (![context save:&error]) {
            //Handle error
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            
        }
        
        return object;
        
    }
    
    
}

//Lehrer zurückgeben
+ (Lehrer *)lehrerForKuerzel:(NSString *)kuerzel inManagedObjectContext:(NSManagedObjectContext *)context {
    if (kuerzel && context) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Lehrer" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        // Specify criteria for filtering which objects to fetch
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"kuerzel like %@", kuerzel];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil || fetchedObjects.count < 1) {
            //create a new Lehrer
            return [Lehrer neuerLehrerMitKuerzel:kuerzel inManagedObjectContext:context];
        }
        else {
            return [fetchedObjects firstObject];
        }
    }
    return nil;
}

//neuer Lehrer
+ (Lehrer *)neuerLehrerMitKuerzel:(NSString *)kuerzel inManagedObjectContext:(NSManagedObjectContext *)context {
    if (kuerzel && context) {
        
        Lehrer *newTeacher = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
        
        newTeacher.kuerzel = kuerzel;
        
        
        
        return newTeacher;
    }
    
    return nil;
}

#pragma mark - Lehrer-Objekte bearbeiten
//Fächer String setzen
- (void)setFaecherArray:(NSArray *)faecherArray {
    self.faecher = [faecherArray componentsJoinedByString:@","]; //die Fächer im Array alle aneinander, mit einem Komma getrennt, hängen 
}

#pragma mark - Eigenschaften zurückgeben
//gibt die übliche Anrede mit Namen für den Lehrer als einen String zurück
- (NSString *)printableTeacherString {
    return [NSString stringWithFormat:@"%@ %@", self.titel, self.name];
}




#pragma mark - old/future methods
//- (void)setFaecherMitFachKuerzelString:(NSString *)kuerzelString {
//    NSArray *faecherKuerzel = [kuerzelString componentsSeparatedByString:@","];
//    
//    for (NSString *kuerzel in faecherKuerzel) {
//        [self addFaecherObject:[Fach fachFuerKuerzel:kuerzel inManagedObjectContext:self.managedObjectContext]];
//    }
//}

@end
