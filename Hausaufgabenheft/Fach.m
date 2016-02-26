//
//  Fach.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 26.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "Fach.h"

@implementation Fach


#pragma mark - Neues Fach erstellen
+ (Fach *)neuesFachMitKuerzel:(NSString *)kuerzel undVollemNamen:(nullable NSString *)name inManagedObjectContext:(nonnull NSManagedObjectContext *)context{
    Fach *neuesFach = [NSEntityDescription
                                           insertNewObjectForEntityForName:@"Fach"
                                           inManagedObjectContext:context];
    neuesFach.kuerzel = kuerzel;
    
    //nur wenn auch ein Name gegeben ist, setzte ihn entsprechend bei dem Eintrag in der Datenbank für das neue Fach
    if (name) {
        neuesFach.name = name;
    }
    
    return neuesFach;
}


#pragma mark - Vorhandene Fächer zurückgeben /bzw. neu erstellen
+ (Fach *)vorhandenesFachFuerKuerzel:(NSString *)kuerzel inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Fach" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"kuerzel like %@", kuerzel];
    [fetchRequest setPredicate:predicate];
    
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        return nil;
    }
    else if (fetchedObjects.count > 0) {
        return fetchedObjects.firstObject;
    }
    
    return nil;
    
}

+ (Fach *)fachFuerKuerzel:(NSString *)kuerzel inManagedObjectContext:(NSManagedObjectContext *)context {
    //auf ein vorhandenes Fach prüfen
    Fach *vorhandenesFach = [Fach vorhandenesFachFuerKuerzel:kuerzel inManagedObjectContext:context];
    
    if (vorhandenesFach) {
        return vorhandenesFach;
    }
    
    return [Fach neuesFachMitKuerzel:kuerzel undVollemNamen:nil inManagedObjectContext:context];
}




@end
