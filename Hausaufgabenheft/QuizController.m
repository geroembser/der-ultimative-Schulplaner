//
//  QuizController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 27.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "QuizController.h"
#import "ServerRequestController.h"
#import "KurseController.h"
#import "Kurs.h"
#import "Themenbereich.h"
#import "Frage.h"
#import "Antwort.h"

@interface QuizController () <ServerRequestControllerDelegate>
///der Download-Task der dazu benutzt wird, die Fragen herunterzuladen
@property NSURLSessionDataTask *questionDownloadTask;
@end

@implementation QuizController


#pragma mark - Instanzen erstellen/zurückgeben
- (instancetype)initWithUser:(User *)user {
    self = [super init];
    
    if (self) {
        self.user = user;
    }
    
    return self;
}


+ (QuizController *)defaultQuizController {
    static QuizController *defaultQC = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultQC = [[QuizController alloc]initWithUser:[User defaultUser]]; //default QuizController wird mit dem defaultUser initialisiert
    });
    
    return defaultQC;
}

#pragma mark - Methoden für die Verwaltung der Quiz-Fragen etc.
- (void)downloadNeueFragen {
    //eine Server-Anfrage erstellen, aber nur wenn gerade kein Task im Downloadprozess ist
    if (!self.questionDownloadTask) {
        ServerRequestController *serverRequest = [[ServerRequestController alloc]initWithUser:self.user];
        
        //das Delegate der Anfrage auf diesen Controller setzen
        serverRequest.delegate = self;
        
        //einen String von allen aktuellen Kurs-IDs erstellen
        KurseController *kurseController = [[KurseController alloc]initWithUser:self.user];
        NSArray *alleKurse = [kurseController alleAktivenKurseForCurrentUser];
        NSMutableString *kurseStrings = [NSMutableString new];
        
        for (Kurs *kurs in alleKurse) {
            [kurseStrings appendFormat:@"%@;",kurs.id];
        }
        //das letzte Komma entfernen
        [kurseStrings replaceCharactersInRange:NSMakeRange(kurseStrings.length-1, 1) withString:@""];
        
        //den questionDownloadTask erstellen
        self.questionDownloadTask = [serverRequest dataTaskForURL:[NSURL URLWithString:@"http://app.marienschule.de/files/scripts/getQuizData.php"] withParameterDict:@{@"kurse":kurseStrings}];
        
        //diesen DataTask starten
        [self.questionDownloadTask resume];
    }
}

- (void)didFinishDownloadingDataTask:(NSURLSessionDataTask *)dataTask withData:(NSData *)downloadedData andError:(NSError *)error forServerRequest:(ServerRequestController *)serverRequestController {
    //den questionDownloadTask kauf nil setzen, damit ein erneuter Downloadversuch im gleichen QuizController auch funktionieren kann (siehe Methode: "downloadNeueFragen" vom QuizController)
    self.questionDownloadTask = nil;
    
    if (downloadedData && !error) {
        //die heruntergeladenen Daten überprüfen
        NSError *parsingError;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:downloadedData options:0 error:&parsingError];
        
        if (parsingError) {
            //Fehler-Notification posten
            [[NSNotificationCenter defaultCenter]postNotificationName:QuizControllerUpdateFailed object:self userInfo:@{NSLocalizedFailureReasonErrorKey : parsingError.localizedDescription}];
        }
        else {
            //die Daten auslesen
            
            
            //Themenbereiche auslesen und importieren
            NSArray *themen = [jsonDict objectForKey:@"themes"];
            
            for (NSDictionary *einThema in themen) {
                //Daten aus Dictionary lesen und importieren
                NSInteger themaID = [[einThema objectForKey:@"id"]integerValue];
                NSString *themaTitel = [einThema objectForKey:@"titel"];
                NSString *beschreibung = [einThema objectForKey:@"wInfos"];
                NSString *datumString = [einThema objectForKey:@"change"];
                
                //Datum formatieren
                NSDateFormatter *df = [[NSDateFormatter alloc]init];
                [df setDateFormat:@"dd.MM.yyyy HH:mm"];
                [df setTimeZone:[NSTimeZone defaultTimeZone]];
                NSDate *themaLetzteAktualisierung = [df dateFromString:datumString];
                
                //den Themenbereich erstellen
                Themenbereich *themenbereich = [Themenbereich themenbereichMitID:themaID inManagedObjectContext:self.user.managedObjectContext];
                themenbereich.name = themaTitel;
                
                //weitere Attribute für den Themenbereich setzen
                //überprüfen, ob gültige Werte gegeben wurden
                if (beschreibung && ![beschreibung isKindOfClass:[NSNull class]]) {
                    themenbereich.beschreibung = beschreibung;
                }
                if (themaLetzteAktualisierung && ![themaLetzteAktualisierung isKindOfClass:[NSNull class]]) {
                    themenbereich.zuletztAktualisiert = themaLetzteAktualisierung;
                }
            }
            
            //Fragen auslesen und einem Themenbereich zuordnen, danach importieren
            NSArray *fragen = [jsonDict objectForKey:@"frag"];
            
            for (NSDictionary *eineFrage in fragen) {
                //Daten aus Dictionary lesen
                NSString *frageString = [eineFrage objectForKey:@"frage"];
                NSInteger schwierigkeit = [[eineFrage objectForKey:@"schw"]integerValue];
                NSInteger themenbereichID = [[eineFrage objectForKey:@"themenbereich"]integerValue];
                NSString *bildURLString = [eineFrage objectForKey:@"url"];
                NSInteger frageID = [[eineFrage objectForKey:@"id"]integerValue];
                NSString *kursID = [eineFrage objectForKey:@"kursid"];
                
                
                //eine neue Frage mit der ID
                if (frageID && ![frageString isKindOfClass:[NSNull class]]) {
                    Frage *neueFrage = [Frage frageMitID:frageID inManagedObjectContext:self.user.managedObjectContext];
                    neueFrage.schwierigkeit = @(schwierigkeit);
                    neueFrage.themenbereich = [Themenbereich themenbereichMitID:themenbereichID inManagedObjectContext:neueFrage.managedObjectContext];
                    if (frageString && ![frageString isKindOfClass:[NSNull class]]) neueFrage.frage = frageString;
                    if (bildURLString && ![kursID isKindOfClass:[NSNull class]]) neueFrage.imageURL = bildURLString;
                    if (kursID && ![kursID isKindOfClass:[NSNull class]]) neueFrage.kurs = [Kurs kursFuerID:kursID inManagedObjectContext:self.user.managedObjectContext];                 //Frage einem Kurs zuordnen...
                    
                    //aufgrund der übergebenen Daten muss man dem Themenbereich noch einen Kurs zuweisen, was ja logischerweise der Kurs von einer Frage in diesem Themenbereich sein müsste
                    neueFrage.themenbereich.kurs = neueFrage.kurs;
                    
                    
                    //Antworten für diese Frage auslesen und einer Frage zuordnen, danach importieren
                    NSArray *antworten = [eineFrage objectForKey:@"answers"];
                    
                    for (NSDictionary *eineAntwort in antworten) {
                        //Daten aus Dictionary lesen
                        //                NSInteger antwortID = [[eineAntwort objectForKey:@"id"]integerValue]; //derzeit nicht benötigt...
                        BOOL richtigeAntwort = [[eineAntwort objectForKey:@"truth"]boolValue];
                        
                        NSString *loesungString = [eineAntwort objectForKey:@"description"]; //die Beschreibung der Lösung für die Frage, die auf Wunsch des Users angezeigt werden kann (Lange Antwort)
                        
                        NSString *antwortMoeglichkeit = [eineAntwort objectForKey:@"text"]; //die Antwortmöglichkeiten für diese Antwort der Frage (kurze Antwort)
                        
                        //nur wenn die oben erstellt neue Frage auch vorhanden ist
                        if (neueFrage) {
                            //eine neue Antwort erstellen --> diese Antwort der Frage zuweisen
                            Antwort *neueAntwort = [Antwort neueAntwortFuerFrage:neueFrage inManagedObjectContext:neueFrage.managedObjectContext];
                            if (antwortMoeglichkeit && ![antwortMoeglichkeit isKindOfClass:[NSNull class]]) neueAntwort.antwortKurz = antwortMoeglichkeit;
                            if (loesungString && ![loesungString isKindOfClass:[NSNull class]]) neueAntwort.antwortLangfassung = loesungString; //die Langfassung der Antwort
                            
                            //setzten, ob die Antwortmöglichkeit richtig ist oder falsch
                            neueAntwort.richtig = [NSNumber numberWithBool:richtigeAntwort];
                        }
                    }
                }
            }
            
            
            //das Datum der letzten Aktualisierung des Quizzes setzen
            self.user.quizLastUpdate = [NSDate date];
            
            //managedObjectContext speichern
            NSError *savingError;
            [self.user.managedObjectContext save:&savingError];
            
            if (savingError) {
                //poste eine Notification, mit deren Hilfe andere Objekte den Fehler anzeigen lassen -können-
                [[NSNotificationCenter defaultCenter]postNotificationName:QuizControllerUpdateFailed object:self userInfo:@{NSLocalizedFailureReasonErrorKey : savingError.localizedDescription}];
            }
            else {
                //poste eine Notification, die angibt, dass das Update der Daten erfolgreich war
                [[NSNotificationCenter defaultCenter]postNotificationName:QuizControllerDidRefreshQuestions object:self userInfo:nil];
            }
            
        }
    }
    else {
        //Fehler oder keine Daten --> später erneut versuchen
        //Fehler anzeigen --> die Notification posten
        [[NSNotificationCenter defaultCenter]postNotificationName:QuizControllerUpdateFailed object:self userInfo:@{NSLocalizedFailureReasonErrorKey : error.localizedDescription}];
    }
}

///den Download der aktuellen Fragen abbrechen
- (void)cancelCurrentQuestionDownload {
    [self.questionDownloadTask cancel];
    
    self.questionDownloadTask = nil;
}

//alle Quizfragen löschen
- (void)loescheAlleQuizfragenDesBenutzers {
    //alle Antworten löschen
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Antwort" inManagedObjectContext:self.user.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"frage.kurs.user == %@", self.user];
    [fetchRequest setPredicate:predicate];
    
    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
    
    NSError *deleteError = nil;
    [self.user.managedObjectContext executeRequest:delete error:&deleteError];
    
    if (deleteError) {
        //Fehler beim Löschen
        NSLog(@"Fehler beim Löschen aller Antworten");
    }

    
    
    //alle Fragen löschen
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription entityForName:@"Frage" inManagedObjectContext:self.user.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    predicate = [NSPredicate predicateWithFormat:@"kurs.user == %@", self.user];
    [fetchRequest setPredicate:predicate];
    
    delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
    
    [self.user.managedObjectContext executeRequest:delete error:&deleteError];
    
    if (deleteError) {
        //Fehler beim Löschen
        NSLog(@"Fehler beim Löschen aller Fragen");
    }
    
    //alle Themenbereich löschen
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription entityForName:@"Themenbereich" inManagedObjectContext:self.user.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    predicate = [NSPredicate predicateWithFormat:@"kurs.user == %@", self.user];
    [fetchRequest setPredicate:predicate];
    
    delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
    
    [self.user.managedObjectContext executeRequest:delete error:&deleteError];
    
    if (deleteError) {
        //Fehler beim Löschen
        NSLog(@"Fehler beim Löschen aller Themenbereiche");
    }
}


#pragma mark - allgemeine Infos übers Quiz und den Benutzer zurückgeben
- (NSArray<Frage *> *)alleFragen {
    //alle Fragen aus der Datenbank parsen
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Frage" inManagedObjectContext:self.user.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"kurs.user == %@", self.user];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"themenbereich"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.user.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        return nil;
    }
    else {
        return fetchedObjects;
    }
}

- (NSArray<Frage *> *)alleDreißigNeustenFragen {
    //die folgende Methode mit nil als Parameter aufrufen --> sollte alle neusten Fragen zurückgeben, unabhängig vom Kurs
    return [self alleDreißigNeustenFragenVonKurs:nil];
}

- (NSArray<Frage *> *)alleDreißigNeustenFragenVonKurs:(Kurs *)kurs {
    //alle Fragen aus der Datenbank parsen
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Frage" inManagedObjectContext:self.user.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"kurs.user == %@", self.user];
    
    
    //wenn noch ein Kurs gegeben ist, dann muss auch noch der Kurs in das Predicate mitaufgenommen werden
    if (kurs) {
        //das Kurs Predicate
        NSPredicate *kursPredicate = [NSPredicate predicateWithFormat:@"kurs == %@", kurs];
        //das neue Predicate ist dann ein zusammengefügtes Und-Predicate aus dem neu hinzugekommenen kursPredicate und dem alten "predicate", was dazu bestimmt war, nur die Fragen für den aktuellen User des QuizControllers zurückzugeben
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, kursPredicate]];
    }
    
    //das Predicate hier zur FetchRequest "hinzufügen"
    [fetchRequest setPredicate:predicate];
    
    
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"hinzugefuegtAm"
                                                                   ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    //nur die ersten 30 nehmen
    [fetchRequest setFetchLimit:30];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.user.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        return nil;
    }
    else {
        return fetchedObjects;
    }

}

- (NSArray<Frage *> *)alleFalschenFragen {
    //folgende Methode mit nil als Parameter aufrufen, damit alle falschen Fragen unabhängig von einem bestimmten Kurs zurückgegeben werden
    return [self alleFalschenFragenVonKurs:nil];
}

- (NSArray<Frage *> *)alleFalschenFragenVonKurs:(Kurs *)kurs {
    //alle gesuchten Fragen aus der Datenbank parsen
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Frage" inManagedObjectContext:self.user.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"kurs.user == %@ AND anzahlFalschBeantwortet >= anzahlRichtigBeantwortet", self.user]; //falsche Fragen sind dadurch definiert, dass die Anzahl der gegebnen richtigen Antworten unter oder gleich der Anzahl von falsch gegebenen Antworten auf diese Frage (nicht auf die "Unterantworten", sondern ob die Frage als ganzes richtig beantwortet wurde --> das bedeutet, dass der User alle Antworten für diese Frage richtig gegeben haben muss) liegt
    
    
    
    //wenn noch ein Kurs gegeben ist, dann muss auch noch der Kurs in das Predicate mitaufgenommen werden
    if (kurs) {
        //das Kurs Predicate
        NSPredicate *kursPredicate = [NSPredicate predicateWithFormat:@"kurs == %@", kurs];
        //das neue Predicate ist dann ein zusammengefügtes Und-Predicate aus dem neu hinzugekommenen kursPredicate und dem alten "predicate", was dazu bestimmt war, nur die falschen Fragen für den aktuellen User des QuizControllers zurückzugeben
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, kursPredicate]];
    }
    
    //das Predicate hier zur FetchRequest "hinzufügen"
    [fetchRequest setPredicate:predicate];
    
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"anzahlFalschBeantwortet"
                                                                   ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.user.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        return nil;
    }
    else {
        return fetchedObjects;
    }

}

- (NSInteger)punktestand {
    return self.user.quizPunkte.integerValue;
}

- (NSUInteger)numberOfAvailableQuestions {
    //alle Fragen für den user zählen
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Frage" inManagedObjectContext:self.user.managedObjectContext]];
    
    [request setIncludesSubentities:NO]; //Omit subentities. Default is YES (i.e. include subentities)
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"kurs.aktiv == true AND kurs.user == %@", self.user]];
    
    NSError *err;
    NSUInteger count = [self.user.managedObjectContext countForFetchRequest:request error:&err];
    if(count == NSNotFound) {
        //Handle error
        return  0;
    }

    return count;
}

- (NSFetchRequest *)alleKurseMitFragenFetchedRequest {

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Kurs" inManagedObjectContext:self.user.managedObjectContext];
    [fetchRequest setEntity:entity];

    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user == %@ AND aktiv == YES AND ANY fragen.id >= 0", self.user]; //letzter Teil des Predicates sorgt dafür, dass nur die Kurse angezeigt werden, für die auch Fragen verfügbar sind
    [fetchRequest setPredicate:predicate];
    
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    return fetchRequest;
}

- (NSFetchRequest *)alleThemenbereicheFuerKurs:(Kurs *)kurs {
    if (kurs) {
        //alle Fragen aus der Datenbank parsen
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Themenbereich" inManagedObjectContext:self.user.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Specify criteria for filtering which objects to fetch
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"kurs == %@", kurs];
        [fetchRequest setPredicate:predicate];
        // Specify how the fetched objects should be sorted
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"zuletztAktualisiert"
                                                                       ascending:NO];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
        
        
        return fetchRequest;
    }
    
    return nil;
}


@end
