//
//  Kurs.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 18.11.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "Kurs.h"
#import "Aufgabe.h"
#import "Klausur.h"
#import "Lehrer.h"
#import "Note.h"
#import "Schulstunde.h"
#import "Fach.h"
#import "WebsiteTag.h"

@implementation Kurs

// Insert code here to add functionality to your managed object subclass

+ (NSArray<Kurs *> *)vorhandeneKurseFuerID:(NSString *)kursID inManagedObjectContext:(NSManagedObjectContext *)context {
    //nur, wenn eine Kurs-ID und ein managedObjectContext gegeben ist
    if (kursID && context) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Kurs" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        // Specify criteria for filtering which objects to fetch
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id like %@", kursID];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil || fetchedObjects.count < 1) {
            return nil;
        }
        return fetchedObjects;
    }
    return nil;
}

+ (Kurs *)vorhandenerKursFuerID:(NSString *)kursID inManagedObjectContext:(NSManagedObjectContext *)context {
    NSArray *vorhandeneKurse = [Kurs vorhandeneKurseFuerID:kursID inManagedObjectContext:context];
    
    if (vorhandeneKurse == nil) {
        return nil;
    }
    else {
        return vorhandeneKurse.firstObject;
    }
}

+ (Kurs *)kursFuerID:(NSString *)kursID inManagedObjectContext:(NSManagedObjectContext *)context {
    //nur wenn ein Kurs und ein ManagedObjectContext gegeben ist
    if (kursID && context) {
        //erst überprüfen, ob bereits in der Datenbank ein Kurs mit der übergebenen ID vorhanden ist
        Kurs *vorhandenerKurs = [Kurs vorhandenerKursFuerID:kursID inManagedObjectContext:context];
        
        if (vorhandenerKurs == nil) {
            //neues Kurse Objekt erstellen und zurückgeben
            return [Kurs neuerKursMitKursID:kursID inManagedObjectContext:context];
        }
        
        //ansonsten das vorhandene Kurs-Objekt zurückgeben
        return vorhandenerKurs;
    }
    return nil;
}

#pragma mark - neue Kurs-Objekte erstellen
+ (Kurs *)neuerKursMitKursID:(NSString *)kursId inManagedObjectContext:(nonnull NSManagedObjectContext *)managedObjectContext{
    
    Kurs *newKurs = [NSEntityDescription
                                           insertNewObjectForEntityForName:@"Kurs"
                                           inManagedObjectContext:managedObjectContext];
    
    
    //die Kurs-Id zuweisen
    newKurs.id = kursId;
    
    //"hinzugefügt am"-Datum setzen
    newKurs.hinzugefuegtAm = [NSDate date];
    
    
    return newKurs;
}

// die setID-Methode überschreiben, damit anhand der ID die Kursart bestimmt werden kann und entsprechend gesetzt wird und außerdem das Fach bestimmt wird (also die genaue Beschreibung für das Fach
- (void)setId:(NSString *)id {
    [self willChangeValueForKey:@"id"];
    [self setPrimitiveValue:id forKey:@"id"];
    [self didChangeValueForKey:@"id"];
    
    
    //aus der Kurs-Id die Art des Kurses erkennen
    //dafür erstmal eventuell zweimal vorkommende Leerzeichen durch eins ersetzen
    NSString *workingKursID = [id stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    //diese nach dem Leerzeichen in einem Array aufteilen
    NSArray *kursIDParts = [workingKursID componentsSeparatedByString:@" "];
    
    NSString *fachKuerzel;
    NSString *kursArt;
    NSString *fachName;
    
    //wenn zwei Teile der Kurs-ID vorhanden sind, dann ist der erste Teil das Fach und der zweite Teil die Kursart mit der LK/GK-Nummer
    if (kursIDParts.count == 2) {
        fachKuerzel = [kursIDParts firstObject];
        
        kursArt = [kursIDParts lastObject];
        
        if ([kursArt rangeOfString:@"G"].location != NSNotFound) {
            self.kursart = [NSNumber numberWithInt:grundkursKursArt];
        }
        else if ([kursArt rangeOfString:@"L"].location != NSNotFound) {
            self.kursart = [NSNumber numberWithInt:leistungskursKursArt];
            self.schriftlich = [NSNumber numberWithBool:YES]; //Leistungskurs muss schriftlich gewählt werden
        }
        else if ([kursArt rangeOfString:@"P"].location != NSNotFound) {
            self.kursart = [NSNumber numberWithInt:projektkursKursArt];
        }
        
        //in der Fächer-CoreData Datenbank-Tabelle sollte zu jeder Kurs-ID der entsprechende Name bzw. die Beschreibung für das Fach zu finden sein (bei einer zweiteiligen Kurs-ID, zum Beisiel "M  LK1", findet sich in der CoreData-Fächer–Datenbank-Tabelle immer eine genauere Beschreibung als das pure Fach, was ja im Fall des Beispiels "Mathe" wäre und nur im ersten Teil der zweiteiligen Kurs-ID abgebildet ist) --> hier sollte also zum Beispiel "Mathe Leistungskurs 1" als Fachname/Kursname zurückgegeben werden
        Fach *fachObject= [Fach fachFuerKuerzel:id inManagedObjectContext:self.managedObjectContext];
        fachName = fachObject.name;
    }
    else if (kursIDParts.count == 1) {
        //bedeutet, dass eine einteilige Kurs-ID vorliegt, zum Beispiel nur "M" oder "D", was dann gleich das Fach und die genaue Beschreibung des Fachs ist
        fachKuerzel = kursIDParts.firstObject;
    }

    Fach *fachObject = [Fach fachFuerKuerzel:fachKuerzel inManagedObjectContext:self.managedObjectContext];
    self.fach = fachObject.name;
    if (!fachName) {
        //wenn kein Fachname gegeben ist, also eine einteilige Kurs-ID vorliegt (weil bei einer zweiteiligen Kurs-ID der Fachname bereits aus der Fächer-Datenbank gelesen wurde - siehe if-Abfrage oben), ist der Fachname gleich der genauen Beschreibung des Fachs
        self.name = self.fach;
    }
    else {
        self.name = fachName;
    }
    
    //wenn der Name des Fachs jetzt doch nicht gegeben sein sollte, was passiert, wenn fachFuerKuerzel:.... keinen Namen zurückgibt, dann nimm den ersten Teil des Namens. Das ist oft bei Fächern der Fall, die nur in der Oberstufe unterrichtet werden. Also zum Beispiel Informatik hat die Kurs-ID "IF G1" --> Die Klasse CoreData-Datenbank hat keinen Namen für das Fachkürzel IF, weil es so nicht in der Untis-Datei steht (siehe Untis Fächer-Datei) --> die CoreData-Datenbank liefert aber "Informatik Grundkurs 1" für das Kürzel "IF G1" zurück, sodass das Fach der erste Teil des nach Leerzeichen separierten Strings ist. Das gleiche gilt Beispielsweise für Französisch oder die Zusatzkurse
    if (fachObject.name.length < 1 || !fachObject.name) {
        self.fach = [self.name componentsSeparatedByString:@" "].firstObject;
    }
    
    //wenn der Name des Fachs das Wort Zusatzkurs enthält, dann markiere es als Zusatzkurs
    if ([self.name rangeOfString:@"Zusatzkurs"].location != NSNotFound) {
        self.kursart = [NSNumber numberWithInteger:zusatzkursKursArt];
    }
}

//Gibt den Namen des Fachs zurück; wenn kein Name für das Fach vorhanden ist, gibt es einen Standardwert zurück, der in diesem Fall ein Leerzeichen ist. Das ist sehr wichtig, damit beim KurseWaehlenViewConroller auch die AGs angezeigt werden. Würde hier nil zurückgegeben werden, würde der FetchedResultsController vom KurseWaehlenViewController die AGs (bzw. genauer die Kurse) die keinen Wert für ihre Eigenschaft "fach" besitzen, nicht anzeigen. Der FetchedResultsController erzeugt nämlich die Sections, indem es die Eigenschaft des Objekts abfragt und erstellt die Sections nicht direkt aus der Datenbank heraus (was übrigens auch schwierig wäre, wenn Änderungen angezeigt werden sollen, solange der ManagedObjectContext noch nicht gespeichert wurde). 
- (NSString *)fach {
    [self willAccessValueForKey:@"fach"];
    NSString *fachname = [self primitiveValueForKey:@"fach"];
    [self didAccessValueForKey:@"fach"];
    
    if (!fachname || fachname.length < 1) {
        return @" ";
    }
    return fachname;
}


#pragma mark - Infos über den Kurs
//gibt das Fachkürzel zurück
- (NSString *)fachKuerzel {
    NSString *kuerzel = [self.id componentsSeparatedByString:@" "].firstObject; //das Kürzel des Fachs, sollte bei einem Kurs-ID der Form M LK1 vorne stehen, wenn man den String nach einem Leerzeichen separiert
    
    //wenn das Kürzel nil ist oder ein Leerstring oder nicht länger als 0 Zeichen, dann einfach die Kurs-ID zurückgeben
    if (kuerzel == nil || kuerzel.length < 1 || [kuerzel isEqualToString:@" "]) {
        return self.id;
    }
    else {
        return kuerzel;
    }
}

//gibt an, ob der Kurs ein Projektkurs
- (BOOL)isProjektkurs {
    if (self.kursart.intValue == projektkursKursArt) {
        return YES;
    }
    
    return NO;
}

//gibt an, ob der Kurs eine AG ist
- (BOOL)isAG {
    if (self.kursart.intValue == agKursArt) {
        return YES;
    }
    
    return NO;
}

//gibt die Kursart als Abkürzung zurück, also GK, LK, PK, AG, ZK etc.
- (NSString *)kursartString {
    switch (self.kursart.intValue) {
        case grundkursKursArt:
            return @"GK";
            break;
        case leistungskursKursArt:
            return @"LK";
            break;
        case projektkursKursArt:
            return @"PK";
            break;
        case agKursArt:
            return @"AG";
            break;
        case zusatzkursKursArt:
            return @"ZK";
            break;
            
        default:
            return @"KA"; //keine Angabe
            break;
    }
}

//Tags in Array setzen
- (void)setTagsInArrayOfTagsStrings:(NSArray *)tags {
    
    //durch den gegebenen Array gehen
    for (NSString *tag in tags) {
        WebsiteTag *websiteTag = [WebsiteTag websiteTagMitTag:tag inManagedObjectContext:self.managedObjectContext];
        
        //den Benutzer für den Tag setzen
        websiteTag.user = self.user;
        
        [self addTagsObject:websiteTag];
    }
    
}

#pragma mark - Setter überschreiben
//Die setAktiv-Methode überschreiben, sodass immer wenn ein Kurs auf aktiv gesetzt wird, die entsprechenden Variablen bei den WebsiteTags für diesen Kurs geändert werden, damit eine vernünftige Bewertung der News auf der Grundlage der Tags möglich ist
- (void)setAktiv:(NSNumber *)aktiv {
    [self willChangeValueForKey:@"aktiv"];
    
    [self setPrimitiveValue:aktiv forKey:@"aktiv"];
    
    [self didChangeValueForKey:@"aktiv"];
    
    //wenn der Kurs auf aktiv gesetzt wird, dann zähle die vorkommenBeiAktivenKurse-Variable aller Website-Tags für diesen Kurs hoch oder runter
    for (WebsiteTag *websiteTag in self.tags.allObjects) {
        NSInteger neuesVorkommen = websiteTag.vorkommenBeiAktivenKursen.integerValue;
        if (aktiv.boolValue) {
            neuesVorkommen++;
        }
        else {
            neuesVorkommen--;
        }
        websiteTag.vorkommenBeiAktivenKursen = @(neuesVorkommen);
    }
    
    
}

#pragma mark - Quiz-Info zurückgeben
- (NSUInteger)anzahlUnbearbeiteteFragen {
    //alle Fragen für diesen Kurs, die unbearbeitet sind
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Frage" inManagedObjectContext:self.managedObjectContext]];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"kurs == %@ AND anzahlFalschBeantwortet == 0 AND anzahlRichtigBeantwortet == 0", self]];
    
    [request setIncludesSubentities:NO]; //keine Untereinheiten mit "zurückgeben"
    
    NSError *err;
    NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:&err];
    if(count == NSNotFound) {
        return 0;
    }
    
    return count;
}

- (NSUInteger)anzahlVerfuegbareFragen {
    //alle Fragen für diesen Kurs, die verfügbar sind, zählen
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Frage" inManagedObjectContext:self.managedObjectContext]];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"kurs == %@", self]];
    
    [request setIncludesSubentities:NO]; //keine Untereinheiten mit "zurückgeben"
    
    NSError *err;
    NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:&err];
    if(count == NSNotFound) {
        return 0;
    }
    
    return count;
}
- (float)prozentRichtigerFragen {
    //alle Fragen für diesen Kurs, die unbearbeitet sind
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Frage" inManagedObjectContext:self.managedObjectContext]];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"kurs == %@ AND anzahlRichtigBeantwortet > anzahlFalschBeantwortet" , self]]; //eine Frage wird als richtig beantwortet angesehen, wenn die Anzahl der richtigen Bearbeitungen den falschen Bearbeitungen überwiegt (siehe "giltAllgemeinAlsRichtigBeantwortet"-Methode der Klasse "Frage"
    
    [request setIncludesSubentities:NO]; //keine Untereinheiten mit "zurückgeben"
    
    NSError *err;
    NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:&err];
    if(count == NSNotFound) {
        return 0;
    }
    
    return (count/(float)self.anzahlVerfuegbareFragen)*100; //eine Prozentzahl daraus machen
}


#pragma mark - Generell
//vielleicht, um später das Datum der letzten Änderung in der Datenbank zu speichern (immer dann, wenn eine Eigenschaft des Objekts gesetzt wird
//- (void)didChangeValueForKey:(NSString *)key {
//    [super didChangeValueForKey:key];
//
//    self.geaendertAm = [NSDate date];
//}


@end
