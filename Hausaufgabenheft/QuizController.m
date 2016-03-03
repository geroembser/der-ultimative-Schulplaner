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
                NSString *themaTitel = [einThema objectForKey:@"title"];
                NSString *beschreibung = [einThema objectForKey:@"wInfos"];
                NSString *datumString = [einThema objectForKey:@"change"];
                
                //Datum formatieren
                NSDateFormatter *df = [[NSDateFormatter alloc]init];
                [df setDateFormat:@"dd.MM.YYYY HH:mm"];
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
                NSInteger themenbereichID = [[eineFrage objectForKey:@"themen"]integerValue];
                NSString *bildURLString = [eineFrage objectForKey:@"bild"];
                NSInteger antwortID = [[eineFrage objectForKey:@"antw"]integerValue];
                NSString *kursID = [eineFrage objectForKey:@"kursid"];
                
                
                //eine neue Frage mit der ID
                Frage *neueFrage = [Frage frageMitID:antwortID inManagedObjectContext:self.user.managedObjectContext];
                neueFrage.schwierigkeit = @(schwierigkeit);
                neueFrage.themenbereich = [Themenbereich themenbereichMitID:themenbereichID inManagedObjectContext:neueFrage.managedObjectContext];
                neueFrage.frage = frageString;
                neueFrage.imageURL = bildURLString;
                neueFrage.kurs = [Kurs kursFuerID:kursID inManagedObjectContext:self.user.managedObjectContext];                 //Frage einem Kurs zuordnen...
                
                
                //Antworten für diese Frage auslesen und einer Frage zuordnen, danach importieren
                NSArray *antworten = [jsonDict objectForKey:@"antworten"];
                
                for (NSDictionary *eineAntwort in antworten) {
                    //Daten aus Dictionary lesen
                    //                NSInteger antwortID = [[eineAntwort objectForKey:@"id"]integerValue]; //derzeit nicht benötigt...
                    NSInteger frageID = [[eineAntwort objectForKey:@"fragid"]integerValue]; //die ID der Frage, für die diese Antwort ist
                    NSInteger richtigeAntwort = [[eineAntwort objectForKey:@"truth"]integerValue]-1; //die Nummer der Antwort, die richtig ist, (minus 1, weil Florian auf dem Server nicht anfängt, bei 0 zu zählen - zum jetzigen Zeitpunkt zumindest)
                    NSString *loesungString = [eineAntwort objectForKey:@"description"]; //die Beschreibung der Lösung für die Frage, die auf Wunsch des Users angezeigt werden kann (Lange Antwort)
                    NSArray *antwortMoeglichkeiten = [eineAntwort objectForKey:@"antworten"]; //die verschiedenen Antwortmöglichkeiten für diese eine Frage (kurze Antworten)
                    
                    //die Frage aus der Datenbank bekommen, die dieser Antwort zugeordnet ist (wirklich nur die vorhandene Frage --> Sinn: siehe nächste if-Abfrage)
                    Frage *associatedFrage = [Frage vorhandeneFrageMitID:frageID inManagedObjectContext:self.user.managedObjectContext];
                    
                    //nur wenn eine Frage mit der ID in der Datenbank besteht, speichere auch die Antworten, ansonsten hat das keinen Sinn und auf dem Server ist wahrscheinlich irgendein Fehler passiert
                    if (associatedFrage) {
                        
                        //temporär erstmal, bis Florian das Skript überarbeitet hat, eine Antwort für jede Antwortmöglichkeit erstellen, um bei den Antworten später irgendwann einmal differenzierte Möglichkeiten der Erklärung zu bieten
                        for (int i = 0; i < antwortMoeglichkeiten.count; i++) {
                            //die jeweilige Antwortmöglichkeit für den Schleifendurchlauf
                            NSString *antwortMoeglichkeit = [antwortMoeglichkeiten objectAtIndex:i];
                            
                            //eine neue Antwort erstellen --> diese Antwort der Frage zuweisen
                            Antwort *neueAntwort = [Antwort neueAntwortFuerFrage:associatedFrage inManagedObjectContext:associatedFrage.managedObjectContext];
                            neueAntwort.antwortKurz = antwortMoeglichkeit;
                            neueAntwort.antwortLangfassung = loesungString; //die Langfassung der Antwort
                            
                            //überprüfen, ob die Antwortmöglichkeit die richtige Antwortmöglichkeit ist
                            BOOL isRichtigeAntwort = NO;
                            if (i == richtigeAntwort) {
                                isRichtigeAntwort = YES;
                            }
                            
                            neueAntwort.richtig = [NSNumber numberWithBool:isRichtigeAntwort];
                        }
                    }
                }
                
            }
            
            
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
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Frage" inManagedObjectContext:self.user.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"kurs.user == %@", self.user];
    [fetchRequest setPredicate:predicate];
    
    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
    
    NSError *deleteError = nil;
    [self.user.managedObjectContext executeRequest:delete error:&deleteError];
    
    if (deleteError) {
        //Fehler beim Löschen
        NSLog(@"Fehler beim Löschen aller Fragen");
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
- (NSInteger)punktestand {
    return self.user.quizPunkte.integerValue;
}

- (NSUInteger)numberOfAvailableQuestions {
    return 0;
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

@end
