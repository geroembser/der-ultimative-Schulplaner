//
//  Stundenplan.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 10.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "Stundenplan.h"
#import "Stunde.h"
#import "Kurs.h"
#import "ServerRequestController.h"
#import "KurseController.h"
#import "Lehrer.h"
#import "NSDate+AdvancedDate.h"

@interface Stundenplan () <ServerRequestControllerDelegate>

@end

@implementation Stundenplan


+ (Stundenplan *)stundenPlanFuerUser:(User *)user {
    
    //fetchController initialisieren
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Schulstunde" inManagedObjectContext:user.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"kurs.aktiv == YES AND kurs.user == %@", user];
    [fetchRequest setPredicate:predicate];
    
    //sortieren nach Blocknummer
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"beginn" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    //perform fetch
    NSError *fetchingError = nil;
    NSArray *schulstunden = [user.managedObjectContext executeFetchRequest:fetchRequest error:&fetchingError];
    
    if (fetchingError) {
        return nil;
    }
    
    //Eine Stundenplan Instanz erstellen
    Stundenplan *stundenplan = [[Stundenplan alloc]init];
    
    //Die Benutzer-Instanzvariable setzen
    stundenplan.user = user;
    
    //die Schuljahr-Instanz-Variable setzen
    stundenplan.schuljahr = user.schuljahr;
    
    //der Array der die einzelnen Arrays für die unterschiedlichen Tage halten soll
    NSMutableArray *alleTage = [NSMutableArray new];
    
    for (int tag = montagWochentag; tag <= freitagWochentag; tag++) {
        //die Stunden für einen Tag
        NSMutableArray *stundenEinTag = [NSMutableArray new];
        
        //durch alle aktiven Stunden für den Benutzer "durchgehen" (liegen im stunden-array)
        for (Schulstunde *schulstunde in schulstunden) {
            if (schulstunde.wochentag.intValue == tag) {
                //dann ein neues "Stunde"n-Objekt erstellen, was eine Stunde in einem Stundenplan repräsentiert
                Stunde *stundenplanStunde = [[Stunde alloc]initWithSchulstunde:schulstunde];
                
                [stundenEinTag addObject:stundenplanStunde];
            }
        }
        
        //aus allen Stunden für den Tag ein Wochentag-Objekt erstellen (übrigens: die Schulstunden sollten schon richtig in der Reihenfolge nach dem Beginn sortiert sein, weil das in der obigen FetchRequest mit dem SortDescriptor so festgelegt ist)
        
        StundenplanWochentag *wochentagObjekt = [StundenplanWochentag wochentagFuerWochentag:tag
                                                                                  mitStunden:stundenEinTag];
        
        [alleTage addObject:wochentagObjekt];
        
    }
    
    //den erstellten Array mit den einzelnen Stunden für die einzelnen Tage in der entsprechende Variable vom stundenplan-Objekt speichern
    stundenplan.wochentage = alleTage;
    
    
    return stundenplan;

}

+ (Stundenplan *)stundenPlanFuerUser:(User *)user mitVertretungenAbDatum:(NSDate *)date {
    //fetchController initialisieren
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Schulstunde" inManagedObjectContext:user.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"kurs.aktiv == YES AND kurs.user == %@", user];
    [fetchRequest setPredicate:predicate];
    
    //sortieren nach Blocknummer
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"beginn" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    //perform fetch
    NSError *fetchingError = nil;
    NSArray *schulstunden = [user.managedObjectContext executeFetchRequest:fetchRequest error:&fetchingError];
    
    if (fetchingError) {
        return nil;
    }
    
    //Eine Stundenplan Instanz erstellen
    Stundenplan *stundenplan = [[Stundenplan alloc]init];
    
    //Die Benutzer-Instanzvariable setzen
    stundenplan.user = user;
    
    //die Schuljahr-Instanz-Variable setzen
    stundenplan.schuljahr = user.schuljahr;
    
    //der Array der die einzelnen Arrays für die unterschiedlichen Tage halten soll
    NSMutableArray *alleTage = [NSMutableArray new];
    
    
    for (int tag = montagWochentag; tag <= freitagWochentag; tag++) {
        //die Stunden für einen Tag
        NSMutableArray *stundenEinTag = [NSMutableArray new];
        
        //wenn ein Datum gegeben wurde, der Variable "datum" einen Wert zuweisen (nämlich den jeweiligen Wert für den Wochentag mit der Bezeichnung des jeweiligen Schleifendurchlaufs (Wert der Variable tag), der nach dem eventuell gegebenen "date" folgt
        
        ///das Datum für diesen Wochentag (in Abhängigkeit vom gegebenen Datum)
        NSDate *datum;
        if (date) {
            datum = [stundenplan datumNaechsterSchultagFuerWochentag:tag nachDatum:date];
        }
        
        ///eine Variable, die angibt, ob Vertretungen für den Wochentag vom aktuellen Schleifendurchlauf verfügbar sind (Vertretungen sind verfügbar, wenn eine der Schulstunden für den Wochentag des aktuellen Schleifendurchlaufs eine Vertretungsstunde hat --> siehe nächste Vorschleife und ihre inneren Anweisungen)
        BOOL hasVertretungen = NO;
        
        //durch alle aktiven Stunden für den Benutzer "durchgehen" (liegen im stunden-array)
        for (Schulstunde *schulstunde in schulstunden) {
            if (schulstunde.wochentag.intValue == tag) {
                //dann ein neues "Stunde"n-Objekt erstellen, was eine Stunde in einem Stundenplan repräsentiert
                Stunde *stundenplanStunde = [[Stunde alloc]initWithSchulstunde:schulstunde];
                
                //wenn eine Vertretung für diese Stunde gegeben ist, die für das jeweilige Datum des Wochentags von diesem Schleifendurchlauf (Wert der Variable "datum") gilt, dann setzte den Wert der Variable hasVertretungen auf "YES"
                if ([stundenplanStunde vertretungFuerDatum:datum]) {
                    hasVertretungen = YES;
                }
                
                [stundenEinTag addObject:stundenplanStunde];
            }
        }
        
        //aus allen Stunden für den Tag ein Wochentag-Objekt erstellen (übrigens: die Schulstunden sollten schon richtig in der Reihenfolge nach dem Beginn sortiert sein, weil das in der obigen FetchRequest mit dem SortDescriptor so festgelegt ist)
        
        StundenplanWochentag *wochentagObjekt = [StundenplanWochentag wochentagFuerWochentag:tag
                                                                                  mitStunden:stundenEinTag];
        
        //das Datum für den jeweilgen Wochentag setzen
        wochentagObjekt.datum = datum;
        
        //den Wert der Variable vom Stundenplan-Wochentag-Objekt, der angibt, ob an einem Wochentag irgendwelche Vertretungsstunden stattfinden, so setzten, wie es in den obigen Schleifen herausgefunden worden sein sollte (siehe das Vorkommen der hasVertretungen-Variable
        wochentagObjekt.vertretungenVerfuegbarOderVorhanden = hasVertretungen;
        
        //das neue Wochentag-Objekt zum Array mit allen Wochentagen ("alleTage"-Variable) hinzufügen.
        [alleTage addObject:wochentagObjekt];
        
    }
    
    //den erstellten Array mit den einzelnen Stunden für die einzelnen Tage in der entsprechende Variable vom stundenplan-Objekt speichern
    stundenplan.wochentage = alleTage;
    
    
    return stundenplan;
    

}

///Diese Methode gibt das Datum zurück, für den gesuchten nächsten Wochentag nach dem gegebenen Datum. Beispiel: Ich suche das Datum vom nächsten Dienstag und übergebe also einmal als gesuchterWochentag=dienstagWochentag und als date=03.02.2016 (Mittwoch). Die Methode sollte dann das Datum vom 09.02.2016 (Dienstag) zurückgeben
- (NSDate *)datumNaechsterSchultagFuerWochentag:(SchulstundeWochentag)gesuchterWochentag nachDatum:(NSDate *)date {
    //eine neue Hilfsvariable einfügen, deren Wert am Ende aller Anweisungen zurückgegeben werden soll (diese Variable enthält also das Datum vom nächsten Schultag)
    NSDate *dateToReturn = date;
    
    //der Wochentag vom jeweiligen Wert der Variable dateToReturn
    SchulstundeWochentag wochentagDateToReturn = [dateToReturn wochentag];
    
    while (gesuchterWochentag != wochentagDateToReturn) {
        dateToReturn = [dateToReturn dateByAddingTimeInterval:60*60*24*1];
        wochentagDateToReturn = [dateToReturn wochentag];
    }
    
    return dateToReturn;
}

- (StundenplanWochentag *)wochentagFuerIndex:(NSUInteger)wochentagIndex {
    if (wochentagIndex < self.wochentage.count) {
        return [self.wochentage objectAtIndex:wochentagIndex];
    }
    return nil;
}

- (Stunde *)stundeFuerWochentag:(SchulstundeWochentag)wochentag undStunde:(NSUInteger)stunde {
    if (wochentag < self.wochentage.count) {
        return [[self wochentagFuerIndex:wochentag] schulstundeFuerStunde:stunde];
    }
    
    //wenn bishierhin nichts zurückgegeben wurde, dann gib eine Freistunde zurück, was meint, nil zurückzugeben
    return nil;
}

- (NSArray *)stundenFuerWochentag:(SchulstundeWochentag)wochentag {
    if (wochentag >= self.wochentage.count) {
        return nil;
    }
    
    return [(StundenplanWochentag *)[self.wochentage objectAtIndex:wochentag]stunden];
}


- (Stunde *)naechsteSchulstundeGeradeAktiv:(BOOL *)geradeAktiv {
    //gerade Aktiv erstmal auf NO setzen (Standard)
    *geradeAktiv = NO;
    
    //Die Zeiten für die Schulstunden
    NSArray *zeitenStundenEnde = [Stundenplan zeitenStundenEnde];
    
    //das aktuelle Datum (mit Uhrzeit etc.)
    NSDate *datum = [NSDate date];
    
    //vom aktuellen Datum entscheiden, welcher Schultag als nächstes ist bzw. welcher gerade ist
    //den aktuellen Wochentag als integer-Wert zurückgeben
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setFirstWeekday:2]; //Montag ist der erste Tag der Woche, nicht Sonntag (=1)
    NSUInteger weekday = [gregorian ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:datum]-1;
    
    //wenn der Wochentag größer als Freitag ist, dann setze ihn auf Montag (das heißt, man ist im Wochenende
    if (weekday > freitagWochentag) {
        weekday = montagWochentag;
        //dann fange an, direkt am Montag in der ersten Stunde zu suchen
        return [self naechsteSchulstundeNachWochentag:(int)weekday undStunde:0];
    }
    
    //zuerst den Index der aktuellen Stunde finden
    for (int i = 0; i < zeitenStundenEnde.count; i++) {
        NSString *aStundenString = [zeitenStundenEnde objectAtIndex:i];
        
        NSArray *stundenStringComponents = [aStundenString componentsSeparatedByString:@":"];
        
        //Date Components vom aktuellen Datum
        NSDateComponents *dateComponentsCurrentDate = [gregorian components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:datum];
        
        //ein Datum erstellen von heute mit der Zeit aus dem Stundenstring
        NSDateComponents *newDateComponents = [[NSDateComponents alloc]init];
        [newDateComponents setYear:dateComponentsCurrentDate.year];
        [newDateComponents setMonth:dateComponentsCurrentDate.month];
        [newDateComponents setDay:dateComponentsCurrentDate.day];
        [newDateComponents setHour:[stundenStringComponents.firstObject integerValue]];
        [newDateComponents setMinute:[stundenStringComponents.lastObject integerValue]];
        [newDateComponents setSecond:0];
        
        //das Datum vom Stundenende erstellen
        NSDate *stundenEnde = [gregorian dateFromComponents:newDateComponents];
        
        //das Datum vom Stundenbeginn erstellen (45 Minuten vor dem Stundenende)
        [newDateComponents setMinute:[stundenStringComponents.lastObject integerValue]-45];
        NSDate *stundenbeginn = [gregorian dateFromComponents:newDateComponents];
        
        //dann überprüfen, ob das aktuelle Datum kleiner als das Ende der jeweiligen Stunde ist (also kleiner als 8.45 Uhr, 9.30 Uhr... --bis irgendwann)
        
        if ([datum compare:stundenEnde] == NSOrderedAscending) {
            if ([datum compare:stundenbeginn] == NSOrderedDescending) {
                
                Stunde *aktiveSchulstunde = [self stundeFuerWochentag:(int)weekday undStunde:i];
                
                if (!aktiveSchulstunde) {
                     //falls es keine aktuell aktive Stunde gibt, gib die nächste Stunde zurück, wenn es eine gibt und gerade keine Freistunde ist (die aufgerufene Methode gibt keine Freistunde zurück)
                    return [self naechsteSchulstundeNachWochentag:(int)weekday undStunde:i];
                }
                else {
                    *geradeAktiv = YES;
                    return aktiveSchulstunde;
                }
//                NSLog(@"in der Stunde: %i", i);
            }
            else {
//                NSLog(@"nächste Stunde: %i", i);
                return [self naechsteSchulstundeNachWochentag:(int)weekday undStunde:i];
            }
        }
    }
//    NSLog(@"nächste Stunde ist die erste am nächsten Tag");
    
    weekday = (weekday + 1 > freitagWochentag) ? montagWochentag : weekday+1;
    return [self naechsteSchulstundeNachWochentag:(int)weekday undStunde:0];
    
    
    return nil;
    
}
///gibt die nächste Stunde im Stundenplan, die nach der Stunde mit den gegebenen Daten folgt; wenn keine Stunde vorhanden ist, wird nil zurückgegeben (aber auch -nur- wenn gar keine Stunde für den Benutzer vorhanden ist); wenn die nächste Stunde eine Freistunde ist, wird die nächste Nicht-Freistunde, falls eine vorhanden ist, nach der Freistunde zurückgegeben
- (Stunde *)naechsteSchulstundeNachWochentag:(SchulstundeWochentag)wochentag undStunde:(NSUInteger)stunde {
    //den Wochentag vor dem gegebenen Wochentag aufrufen, der unten in der Schleife benutzt wird, um zu erkennen, dass die Schleife einmal durchgelaufen ist

    SchulstundeWochentag vorherigerWochentag = (wochentag-1 >= montagWochentag) ? wochentag-1 : freitagWochentag;
    
    //durch alle Wochentage gehen
    for (int i = wochentag; i < self.wochentage.count; i++) {
        //das StundenplanWochentag-Objekt für den Wochentag des aktuellen Schleifendurchlaufs
        StundenplanWochentag *wochentagObjekt = [self wochentagFuerIndex:i];
        
        //durch alle Stunden dieses Wochentags gehen und die Stunde finden, die größer als die gegebenen Stunde ist
        for (Stunde *schulstunde in wochentagObjekt.stunden) {
            if (schulstunde.stunde-1 >= stunde) {
                return schulstunde;
            }
        }
        
        if (i == vorherigerWochentag) {
            //dann wurden alle Stunden durchsucht
            return nil; //keine Schulstunden wurden gefunden
        }
        
        if (i+1 > freitagWochentag) {
            i = montagWochentag-1; //minus 1, weil am Schleifenende +1 gerechnet wird, und damit rechnet sich das raus
            stunde = 0; //Bei Montag bei der ersten Stunde anfangen zu suchen
        }
        else {
            //generell wieder bei der ersten Stunde anfangen zu suchen, wenn beim aktuellen Wochentag, der immer im ersten Schleifendurchlauf behandelt werden sollte, nichts gefunden wurde
            stunde = 0;
        }
    }
    
    return nil;
}

- (NSUInteger)anzahlStundenHeute {
    //das aktuelle Datum (mit Uhrzeit etc.)
    NSDate *datum = [NSDate date];
    
    //vom aktuellen Datum entscheiden, welcher Schultag als nächstes ist bzw. welcher gerade ist
    //den aktuellen Wochentag als integer-Wert zurückgeben
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setFirstWeekday:2]; //Montag ist der erste Tag der Woche, nicht Sonntag (=1)
    NSUInteger weekday = [gregorian ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:datum]-1;
    
    NSArray *stundenFuerWochentag = [self stundenFuerWochentag:(int)weekday];
    
    if (stundenFuerWochentag && stundenFuerWochentag.count > 0) {
        return stundenFuerWochentag.count;
    }
    else {
        return 0;
    }
}


#pragma mark - Vertretungen
- (void)aktualisiereVertretungen {
    
    //erst die alten Vertretungsstunden löschen...
    
    //dann mit dem Vertretungsplan-Objekt die aktuellen Vertretungsstunden herunterladen und mithilfe von Delegates auf Nachrichten des Vertretungsplan-Objekts reagieren --> dieses Vertretungsplan-Objekt lädt dann alle aktuellen Vertretungen herunter und weist sie einer Schulstunde zu (vielleicht auch ohne Vertretungsplan-Objekt, weil der Vertretungsplan viele Eigenschaften vom Stundenplan benötigt)
    
    
    ServerRequestController *request = [[ServerRequestController alloc]initWithUser:self.user];
    request.delegate = self;
    
    //einen String von allen aktuellen Kurs-IDs erstellen
    KurseController *kurseController = [[KurseController alloc]initWithUser:self.user];
    NSArray *alleKurse = [kurseController alleAktivenKurseForCurrentUser];
    NSMutableString *kurseStrings = [NSMutableString new];
    
    for (Kurs *kurs in alleKurse) {
        [kurseStrings appendFormat:@"%@;",kurs.id];
    }
    //das letzte Komma entfernen
    [kurseStrings replaceCharactersInRange:NSMakeRange(kurseStrings.length-1, 1) withString:@""];
    

    [request dataTaskForURL:[NSURL URLWithString:@"http://app.marienschule.de/files/scripts/getChangePlan.php"] withParameterDict:@{@"kurse":kurseStrings}];
    
    //den Download beginnen®
    [request startRequests];
}

#pragma mark ServerRequest-Delegate
- (void)didFinishDownloadingDataTask:(NSURLSessionDataTask *)dataTask withData:(NSData *)downloadedData andError:(NSError *)error forServerRequest:(ServerRequestController *)serverRequestController {
    if (!error && downloadedData) {
        //parse die zurückbekommenen Daten in eine JSON-Dictionary
        NSError *jsonError;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:downloadedData options:0 error:&jsonError];
        
        if (!jsonError) {
            //zuerst überprüfen, ob der Vertretungsplan seit dem letzten Update aktualisiert wurde (also das lokale Vertretungsplan-Update-Datum vom User mit dem heruntergeladenen aus der JSON-Dictionary vergleichen
            NSDateFormatter *df = [[NSDateFormatter alloc]init];
            [df setDateFormat:@"dd.MM.YYYY HH:mm:ss"];
            
            NSString *jsonDate = [jsonDict objectForKey:@"zuletzt Aktualisiert"];
            
            NSDate *newDate;
            if (jsonDate) {
                newDate = [df dateFromString:jsonDate];
            }
            
//            if ((!self.user.lastVertretungsplanUpdate) || [newDate compare:self.user.lastVertretungsplanUpdate] == NSOrderedDescending) {
                self.user.lastVertretungsplanUpdate = newDate;
                
                //wenn dann neue Daten verfügbar sind, dann lösche alle alten Vertretungsstunden
                NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Vertretung"];
                NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
                
                NSError *deleteError = nil;
                [self.user.managedObjectContext executeRequest:delete error:&deleteError];
                
                
                //erstelle Vertretungen-Objekte in der Datenbank aus den heruntergeladenen Daten
                
                //die Vertretungs-Objekte
                NSArray *vertretungen = [jsonDict objectForKey:@"changes"];
                
                //einen DateFormatter, für das parsen des Datums der Vertretung (ohne Zeitangabe)
                NSDateFormatter *vertretungsDF = [[NSDateFormatter alloc]init];
                [vertretungsDF setDateFormat:@"YYYYMMdd"];
                
                //einen DateFormatter, für das Parsen der letzten Änderung der Vertretung (mit Zeitangabe)
                NSDateFormatter *vertretungsAenderungDF = [[NSDateFormatter alloc]init];
                [vertretungsAenderungDF setDateFormat:@"YYYYMMddHHmm"];
                
                //durch alle Vertretungen "gehen"
                for (NSDictionary *eineVertretungJSON in vertretungen) {
                    
                    //das Datum der Vertretung
                    NSDate *vertretungsDate = [vertretungsDF dateFromString:[eineVertretungJSON objectForKey:@"DATUM"]];
                    
                    //die letzte Änderung der Vertretung
                    NSDate *lastChange = [vertretungsAenderungDF dateFromString:[eineVertretungJSON objectForKey:@"AENDERUNG"]];
                    
                    //Kurs-ID
                    NSString *kursID = [eineVertretungJSON objectForKey:@"FACH"];
                    
                    //Notiz zur Vertretung
                    NSString *notiz = [eineVertretungJSON objectForKey:@"TEXT"];
                    
                    //Vertretungslehrer-Kürzel
                    NSString *vertretungsLehrerKuerzel = [eineVertretungJSON objectForKey:@"VERTRETENDERLEHRER"];
                    
                    //Vertretungsraum
                    NSString *vertretungsRaumnummer = [eineVertretungJSON objectForKey:@"VERTRETUNGSRAUM"];
                    
                    //Vertretungsart
                    NSString *vertretungsArt = [eineVertretungJSON objectForKey:@"VERTRETUNGSART"];
                    
                    //Art (Bitfeld mit einem String, der Infos über die Vertretungsstunde angibt)
                    NSString *art = [eineVertretungJSON objectForKey:@"ART"];
                    
                    //Stunde
                    NSUInteger stunde = [[eineVertretungJSON objectForKey:@"STUNDE"]integerValue];
                    
                    //Wochentag der Vertretungsstunde ermitteln, indem der Wochentag vom Datum ermittelt wird
                    SchulstundeWochentag wochentag = [vertretungsDate wochentag];
                    
                    //die Stunde finden, die dieser Vertretung zugewiesen ist, ansonsten keine neue Vertretung erstellen
                    Stunde *stundeFuerVertretung = [self stundeFuerWochentag:wochentag undStunde:stunde-1]; //-1, weil wir Informatiker bei 0 beginnen zu zählen 😂
                    
                    //neues Vertretungs-Objekt erstellen, nur wenn eine Schulstunde gegeben ist
                    if (stundeFuerVertretung && stundeFuerVertretung.schulstunde) {
                        Vertretung *vertretung = [Vertretung vertretungFuerSchulstunde:stundeFuerVertretung.schulstunde inManagedObjectContext:self.user.managedObjectContext];
                        
                        vertretung.notiz = notiz;
                        vertretung.letzteAenderung = lastChange;
                        vertretung.vertretungslehrer = [Lehrer lehrerForKuerzel:vertretungsLehrerKuerzel inManagedObjectContext:self.user.managedObjectContext];
                        vertretung.art = vertretungsArt;
                        vertretung.raum = vertretungsRaumnummer;
                        vertretung.hinzugefuegtAm = [NSDate date];
                        vertretung.kursID = kursID;
                        vertretung.artBitfields = art;
                        
                    }
                    
//                }
                
                //speichern
                NSError *savingError;
                [self.user.managedObjectContext save:&savingError];
                
                if (savingError) {
                    NSLog(@"Fehler beim Speichern der Vertretungen: %@", savingError.localizedDescription);
                }
                
                
                //eine Delegate-Nachricht schicken, die angibt, dass der Stundenplan neugeladen werden muss
                if ([self.delegate respondsToSelector:@selector(didRefreshStundenplan:)]) {
                    [self.delegate didRefreshStundenplan:self];
                }
                
            }
        }
    }
}


#pragma mark - Allgemeine Informationen über Stundenpläne und Schulstunden 
+ (NSArray *)zeitenStundenBeginn {
    //Die Zeiten für die Schulstunden
    return @[@"08:00",@"8:45",@"09:35",@"10:45",@"11:35",@"12:25",@"13:30",@"14:15",@"15:00",@"15:45",@"16:30",@"17:15"];
}
+ (NSArray *)zeitenStundenEnde {
    //Die Zeiten für die Schulstunden
    return @[@"08:45",@"9:30",@"10:20",@"11:30",@"12:20",@"13:10",@"14:15",@"15:00",@"15:45",@"16:30",@"17:15",@"18:00"];
}
@end
