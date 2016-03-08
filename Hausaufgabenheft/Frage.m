//
//  Frage.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 28.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "Frage.h"
#import "Antwort.h"
#import "Kurs.h"
#import "NSMutableArray+Shuffling.h"
#import "User.h"

@interface Frage ()

///alle Antworten für eine Frage, sortiert, wie sie das letzte mal von der antwortenFuerFrageSortiertZufaellig-Methode abgefragt wurden
@property NSArray <Antwort *> *antwortenArray;

@end

@implementation Frage
@synthesize antwortenArray;

// Insert code here to add functionality to your managed object subclass

#pragma mark - Fragen Objekte zurückgeben

+ (Frage *)vorhandeneFrageMitID:(NSInteger)frageID inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Frage" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %lu", frageID];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        return nil;
    }
    else return fetchedObjects.firstObject;
}

+ (Frage *)neueFrageMitID:(NSInteger)frageID inManagedObjectContext:(NSManagedObjectContext *)context {
    Frage *newObject = [NSEntityDescription
                                           insertNewObjectForEntityForName:@"Frage"
                                           inManagedObjectContext:context];
    newObject.id = @(frageID);
    newObject.hinzugefuegtAm = [NSDate date]; //das hinzugefügt-am-Datum
    
    return newObject;
}

+ (Frage *)frageMitID:(NSInteger)frageID inManagedObjectContext:(NSManagedObjectContext *)context {
    Frage *frageToReturn = [Frage vorhandeneFrageMitID:frageID inManagedObjectContext:context];
    
    if (!frageToReturn) {
        frageToReturn = [Frage neueFrageMitID:frageID inManagedObjectContext:context];
    }
    
    return frageToReturn;
}


#pragma mark - Infos über Frage bzw. Antworten der Frage zurückgeben oder setzen
- (NSArray<Antwort *> *)antwortenFuerFrageSortiertZufaellig:(BOOL)zufaellig mitRichtigerFrageInnerhalbDerErstenElemente:(NSUInteger)richtigeElemente{
    //wenn das ganze schon einmal gemacht wurde, dann gib den bereits erstellten Antwort-Array zurück
    if (self.antwortenArray && self.antwortenArray.count > 0) {
        return self.antwortenArray;
    }
    
    //alle Antworten erhalten
    NSMutableArray *alleAntworten = [[NSMutableArray alloc]initWithArray:self.antworten.allObjects];
    
    //"durchmischen", aber nur wenn zufaellig übergeben wurde
    if (zufaellig) {
        [alleAntworten shuffle];
    }
    
    //eine der ersten x Antworten, also der Elemente 0-x im Array, muss richtig sein, ansonsten, nehme die richtige Antwort aus de restlichen Teil des Arrays und setze sie pseudo-zufällig innerhalb der ersten x Elemente des Array
    for (int i = 0; i < alleAntworten.count; i++) {
        Antwort *antwort = [alleAntworten objectAtIndex:i];
        
        if (antwort.richtig.boolValue) {
            if (i < richtigeElemente) {
                //dann kein Problem, weil mindestens eine richtige Antwort innerhalb der x-richtigen-Elemente ist, also die Schleife abbrechen
                break;
            }
            else if (i >= richtigeElemente) {
                //dann bedeutet dass, wenn i größer oder gleich der gegebenen Anzahl an Elementen, innerhalb derer eine richtige Lösung vorhanden sein sollte, ist, dann muss diese Element, was jetzt richtig ist, und die erste richtige Antwort ist, weil sonst die darüberliegende if-Bedingung schon längst zum Abbruch des Durchlaufens der Schleife geführt hätte, mit einem pseudo-zufällig gewähltem Element innerhalb des Bereichs 0-x(richtigeElemente) getauscht werden
                //eine pseudo-zufällige Zahl zwischen 0 und x (richtigeElemente) wählen
                int zufallsZahl = arc4random()%richtigeElemente;
                
                //das Objekt, das den Index der Variable "zufallsZahl" hat, mit dem Objekt tauschen, dass am Index der Schleifenvariable, i, ist, tauschen
                [alleAntworten exchangeObjectAtIndex:i withObjectAtIndex:zufallsZahl];
            }
        }
    }
    
    self.antwortenArray = alleAntworten;
    
    return alleAntworten;
}

- (NSString *)allgemeinerAntwortString {
    NSMutableString *antwortString = [NSMutableString new];
    for (Antwort *antwort in self.antwortenArray) {
        //nur eine Langfassung der Antwort and den Antwort-String hängen, wenn auch eine Langfassung für die Antwort verfügbar ist
        if (antwort.antwortLangfassung) {
            [antwortString appendFormat:@"%@ \n----\n", antwort.antwortLangfassung];
        }
    }
    
    return antwortString;
}

- (void)frageBeantwortet:(BOOL)richtig {
    if (richtig) {
        self.anzahlRichtigBeantwortet = @(self.anzahlRichtigBeantwortet.integerValue+1);
        
        //Anzahl der Punkte beim User hochzählen
        self.kurs.user.quizPunkte = @(self.kurs.user.quizPunkte.integerValue+1);
    }
    else {
        self.anzahlFalschBeantwortet = @(self.anzahlFalschBeantwortet.integerValue+1);
    }
    //die Änderungen speichern
    NSError *savingError;
    [self.managedObjectContext save:&savingError];
    
    if (savingError) {
        NSLog(@"Fehler beim Speichern der Daten in die Datenbank");
    }
}

- (BOOL)giltAllgemeinAlsRichtigBeantwortet {
    if (self.anzahlRichtigBeantwortet.integerValue > self.anzahlFalschBeantwortet.integerValue) return YES;
    
    return NO;
}
@end
