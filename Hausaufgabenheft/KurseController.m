//
//  KurseController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 08.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "KurseController.h"
#import "Schulstunde.h"
#import "Kurs.h"
#import "Lehrer.h"

@implementation KurseController

#pragma mark - Kurse Controller erstellen
- (instancetype)init {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

- (instancetype)initWithUser:(User *)user {
    self = [self init];
    
    self.associatedUser = user;
    
    return self;
}

+ (KurseController *)defaultKurseController {
    static KurseController *defaultKC = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultKC = [[KurseController alloc]initWithUser:[User defaultUser]]; //default Kurse Controller wird mit dem defaultUser initialisiert
    });
    
    return defaultKC;
}

//gibt alle Kurse für den aktuellen Benutzer zurück
- (NSArray *)allKurseForCurrentUser {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Kurs" inManagedObjectContext:self.associatedUser.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user==%@", self.associatedUser];
    [fetchRequest setPredicate:predicate];
    
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.associatedUser.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects != nil) {
        return fetchedObjects;
    }
    else {
        return [NSArray new];
    }

}

//gibt alle Kurse für den aktuellen Benutzer zurück, die auch aktiv sind
- (NSArray *)alleAktivenKurseForCurrentUser {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Kurs" inManagedObjectContext:self.associatedUser.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user==%@ AND aktiv == YES", self.associatedUser];
    [fetchRequest setPredicate:predicate];
    
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.associatedUser.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects != nil) {
        return fetchedObjects;
    }
    else {
        return [NSArray new];
    }
}


//archiviert einen Kurs
- (void)archiviereKurs:(Kurs *)kurs {
    kurs.archiviert = [NSNumber numberWithBool:YES];
    //folgende Zeile ist nicht notwendig
//    kurs.aktiv = [NSNumber numberWithBool:kurs.aktiv.boolValue]; //Diese Zeile könnte auch die aktiv-Property auf "YES" setzen (was sinnvoll wäre, wenn man nur den Stundenplan updatet innerhalb des selben Schuljahrs --> Ergänzung: aktuell auf den Wert der jeweiligen Variable des Kurses gesetzt gesetzt (wenn Fehler auftreten sollten, kann es wieder auf NO gesetzt werden)
    
}
//archiviert alle Kurse des aktuellen Benutzer
- (void)archiviereAlleKurseFuerDenAktuellenBenutzer {
    //durch alle Kurse für den aktuellen Benutzer gehen
    for (Kurs *kurs in [self allKurseForCurrentUser]) {
        //Kurs auf archiviert und inaktiv stellen
        [self archiviereKurs:kurs];
    }
}

//archiviert alle AGs und Projektkurs
- (void)archiviereAllePKsUndAgsFuerDenAktuellenBenutzer {
    for (Kurs *kurs in [self allKurseForCurrentUser]) {
        NSInteger kursart = kurs.kursart.integerValue;
        if (kursart == projektkursKursArt || kursart == agKursArt) {
            [self archiviereKurs:kurs];
        }
    }
}

//archiviert alle normalen Kurse
- (void)archiviereAlleNormalenKurseFuerDenAktuellenBenutzer {
    for (Kurs *kurs in [self allKurseForCurrentUser]) {
        NSInteger kursart = kurs.kursart.integerValue;
        NSLog(@"%lu", kursart);
        if (kursart != projektkursKursArt && kursart != agKursArt) {
            [self archiviereKurs:kurs];
        }
    }
}



//aus gegebenen Schulstunden Kurse erstellen oder vorhandene Kurse updaten
- (NSArray *)kurseInDatenbankAusSchulstunden:(NSArray<Schulstunde *> *)schulstunden inManagedObjectContext:(NSManagedObjectContext *)context{
    
    NSMutableArray *kurseArray = [NSMutableArray arrayWithArray:[self allKurseForCurrentUser]];
    
    //Kurse aus Datenbank als Vorlage für die vorhandenen Kurse benutzen
    for (Schulstunde *schulstunde in schulstunden) {
        NSString *kursID = schulstunde.kursID;
        
        Kurs *vorhandenerKurs = nil;
        for (Kurs *aKurs in kurseArray) {
            if ([aKurs.id isEqualToString:kursID]) {
                vorhandenerKurs = aKurs;
            }
        }
        
        if (vorhandenerKurs) {
            [vorhandenerKurs addStundenObject:schulstunde];
            vorhandenerKurs.schuljahr = self.associatedUser.schuljahr; //das Schuljahr des Kurses entsprechend setzen
            vorhandenerKurs.blocknummer = schulstunde.blocknummer;
            vorhandenerKurs.geaendertAm = [NSDate date];
            vorhandenerKurs.id = kursID; //erneut beim vorhandenen Kurs setzen, damit auch eventuell eine neue Beschreibung/ein neuer Fachname gesetzt wird
            vorhandenerKurs.archiviert = [NSNumber numberWithBool:NO]; //sollte ein archivierter Kurs wieder aktiv werden, dann setze die archiviert-Property auf NO
            
            //überprüfe ob der Lehrer vom vorhandenen Kurs der gleiche ist, wie vom neuen (also der schulstunde)
            if (vorhandenerKurs.lehrer.objectID != schulstunde.lehrer.objectID) {
                vorhandenerKurs.lehrer = schulstunde.lehrer;
            }
        }
        else {
            //neuen Kurs erstellen
            Kurs *neuerKurs = [Kurs neuerKursMitKursID:kursID inManagedObjectContext:context];
            
            //das Schuljahr des Kurses setzen
            neuerKurs.schuljahr = self.associatedUser.schuljahr;
            
            //die Blocknummer des Kurses setzen
            neuerKurs.blocknummer = schulstunde.blocknummer;
            
            if (schulstunde.lehrer == nil) {
                NSLog(@"Fehler beim Lehrer der Schulstunde: %@", schulstunde);
            }
            else {
                //den Lehrer des Kurses setzen
                neuerKurs.lehrer = schulstunde.lehrer;
            }
            
            //die Schulstunde zum Kurs hinzufügen - also eine Verbindung schaffen
            [neuerKurs addStundenObject:schulstunde];
            
            //den user des Kurses setzen
            neuerKurs.user = self.associatedUser;
            
            //den neuen Kurs zum Kurse Array hinzufügen
            [kurseArray addObject:neuerKurs];
        }
    }
    
    return kurseArray;
}

@end
