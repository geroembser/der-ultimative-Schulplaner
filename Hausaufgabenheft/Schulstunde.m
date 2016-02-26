//
//  Schulstunde.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 18.11.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "Schulstunde.h"
#import "Kurs.h"
#import "Lehrer.h"
#import "Raum.h"
#import "Stundenplan.h"

@implementation Schulstunde

@synthesize isFreistunde;
// Insert code here to add functionality to your managed object subclass



#pragma mark - Neue Instanzen erstellen
+ (Schulstunde *)neueSchulstundeFuerWochentag:(NSUInteger)wochentag undStunde:(NSUInteger)stunde mitLehrerKuerzel:(nonnull NSString *)lehrerKuerzel undRaumString:(nonnull NSString *)raum blocknummer:(NSInteger)blocknummer undKursId:(nonnull NSString *)kursId inManagedObjectContext:(nonnull NSManagedObjectContext *)context {
    Schulstunde *newSchulstunde = [NSEntityDescription
                                           insertNewObjectForEntityForName:@"Schulstunde"
                                           inManagedObjectContext:context];
    
    newSchulstunde.wochentag = [NSNumber numberWithInteger:wochentag-1];//Minus 1, weil wir immer bei 0 anfangen zu zählen - Wir Informatiker :-)
    newSchulstunde.beginn = [NSNumber numberWithInteger:stunde];
    newSchulstunde.ende = [NSNumber numberWithInteger:stunde];
    newSchulstunde.lehrer = [Lehrer lehrerForKuerzel:lehrerKuerzel inManagedObjectContext:context];
    newSchulstunde.raumnummer = raum;
    newSchulstunde.kursID = kursId;
    newSchulstunde.blocknummer = [NSNumber numberWithInteger:blocknummer];
    newSchulstunde.geaendertAm = [NSDate date];
    newSchulstunde.hinzugefuegtAm = [NSDate date];
    
    return newSchulstunde;
}

+ (Schulstunde *)schulstundeFuerWochentag:(NSUInteger)wochentag undStunde:(NSUInteger)stunde inManagedObjectContext:(nonnull NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stundenplan" inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"wochentag == %lu AND beginn == %lu", wochentag, stunde];
    [fetchRequest setPredicate:predicate];
    
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects != nil) {
        return fetchedObjects.firstObject;
    }
    
    return nil;
}

//gibt eine Freistunde zurück
+ (Schulstunde *)freistundeFuerWochentag:(SchulstundeWochentag)wochentag undStunde:(NSUInteger)stunde {
    Schulstunde *freistunde = [[Schulstunde alloc]init];
    
    freistunde.isFreistunde = YES;
    
    return freistunde;
}


#pragma mark - Instanzen löschen
+ (void)alleSchulstundenEntfernenInManagedObjectContext:(NSManagedObjectContext *)context {
    //die schnellere iOS9 Variante zum löschen aller Objekte einer CoreData-Datenbank-Tabelle benutzen
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Schulstunde"];
    
    NSBatchDeleteRequest *deleteRequest = [[NSBatchDeleteRequest alloc]initWithFetchRequest:request];
    NSError *deleteError = nil;
    [context executeRequest:deleteRequest error:&deleteError];
    
    if (deleteError) {
        NSLog(@"Fehler beim löschen aller Schulstunden in der Datenbank: %@", deleteError.localizedDescription);
    }
}

#pragma mark - Eigenschaften zurückgeben
//den Wochentag als String zurückgeben, also "Montag" für 1, "Dienstag" für 2 etc.
- (NSString *)wochentagString {
    switch (self.wochentag.intValue) {
        case 0:
            return @"Montag";
            break;
        case 1:
            return @"Dienstag";
            break;
        case 2:
            return @"Mittwoch";
            break;
        case 3:
            return @"Donnerstag";
            break;
        case 4:
            return @"Freitag";
            break;
        case 5:
            return @"Samstag";
            break;
        case 6:
            return @"Sonntag";
            break;
            
            
        default:
            break;
    }
    
    return @"KA";
}

//gibt einen String zurück, der eine Beschreibung einer der Stunden, in der der Kurs stattfindet, zurückgibt
- (NSString *)stundenString {
    return [NSString stringWithFormat:@"%i. Std.", self.beginn.intValue];
}

//gibt die Uhrzeit der Schulstunde als lesbaren String zurück
- (NSString *)uhrzeitDauerString {
    NSArray *stundenBeginn = [Stundenplan zeitenStundenBeginn];
    NSArray *stundenEnde = [Stundenplan zeitenStundenEnde];
    
    return [NSString stringWithFormat:@"%@ Uhr - %@ Uhr", [stundenBeginn objectAtIndex:self.beginn.intValue-1], [stundenEnde objectAtIndex:self.ende.intValue-1]]; //-1 jeweils, weil die Zählung der Untis-Daten, die vom Server heruntergeladen wurden und so in die App übernommen wurden, bei 1 beginnt, und nicht bei 0.
    
}



@end
