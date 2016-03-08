//
//  NachrichtenController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 07.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "MitteilungenController.h"
#import "ServerRequestController.h"
#import "NSDate+AdvancedDate.h"
#import "Mitteilung.h"

@interface MitteilungenController () <ServerRequestControllerDelegate>

///der DataTask, der zum Hernterladen von Mitteilungen genutzt werden sollte
@property NSURLSessionDataTask *mitteilungenDataTask;

@end


@implementation MitteilungenController


#pragma mark - Instanzen zurückgeben

- (instancetype)initWithUser:(User *)user {
    self = [super init];
    
    if (self) {
        self.user = user;
    }
    
    return self;
}

+ (MitteilungenController *)defaultController {
    static MitteilungenController *defaultMC = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultMC = [[MitteilungenController alloc]initWithUser:[User defaultUser]]; //default MitteilungsController wird mit dem defaultUser initialisiert
    });
    
    return defaultMC;
    
}


#pragma mark - Mitteilungen Downloaden
///beginnt den Download von neuen Mitteilungen vom Server und speichert sie lokal
- (void)downloadNew {
    if (!self.mitteilungenDataTask) {
        ServerRequestController *serverRequest = [[ServerRequestController alloc]initWithUser:self.user];
        
        //das Delegate der Anfrage auf diesen Controller setzen
        serverRequest.delegate = self;
        
        //das Datum der letzten Aktualisierung der Mitteilungen anfordern
        NSDate *letzteAktualisierung = self.user.lastMitteilungenUpdate;
        
        //wenn das nil ist, dann keine Parameter mitschicken
        NSDictionary *parameters = nil; //die Download Parameter
        if (letzteAktualisierung) {
            //einen Date-Formatter benutzen, um das Format festzulegen, in dem das Datum an den Server übermittelt werden soll
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"dd.MM.yyyy hh:mm:ss"];
            
            parameters = @{@"date":[dateFormatter stringFromDate:letzteAktualisierung]};
        }
        
        
        //den mitteilungenDataTask erstellen --> einer Instanz-Variable zuweisen, damit nicht mehrmals der Download angefordert wird
        self.mitteilungenDataTask = [serverRequest dataTaskForURL:[NSURL URLWithString:@"http://app.marienschule.de/files/scripts/nachrichten.php"] withParameterDict:parameters];
        
        //diesen DataTask starten
        [self.mitteilungenDataTask resume];
        
    }
}

#pragma mark - Server-RequestController-Delegate
- (void)didFinishDownloadingDataTask:(NSURLSessionDataTask *)dataTask withData:(NSData *)downloadedData andError:(NSError *)error forServerRequest:(ServerRequestController *)serverRequestController {
    //diese Methode auf dem Main-Thread ausführen, weil CoreData nicht thread-safe ist, und im folgenden diverse CoreData-Operationen durchgeführt werden sollen
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error || downloadedData == nil) {
            //dann informiere das Delegate, über einen Fehler, den das Delegate dann entsprechend anzeigen soll
            if (self.delegate && [self.delegate respondsToSelector:@selector(mitteilungenController:didFinishedRefreshWithError:)]) {
                //erstelle ein Fehler-Objekt
                NSError *customError = [NSError errorWithDomain:@"bms-app-server" code:error.code userInfo:@{NSLocalizedDescriptionKey : @"Fehler bei der Server-Verbindung! Sollte das Problem länger auftreten, wende dich bitte an den Administrator der App!"}];
                
                //rufe die Delegate-Methode auf
                [self.delegate mitteilungenController:self didFinishedRefreshWithError:customError];
            }
        }
        else {
            //kreiere JSON-Objekte aus den heruntergeladenen Daten
            NSError *jsonError;
            
            //Mitteilungen sollte ein Array von allen Mitteilungen sein, die in sich wieder durch Dictionaries dargestellt sein sollten
            NSArray *mitteilungen = [NSJSONSerialization JSONObjectWithData:downloadedData options:0 error:&jsonError];
            
            if (jsonError) {
                //auch einen Fehler melden --> mit dem Admin sprechen
                if (self.delegate && [self.delegate respondsToSelector:@selector(mitteilungenController:didFinishedRefreshWithError:)]) {
                    //erstelle ein Fehler-Objekt
                    NSError *customError = [NSError errorWithDomain:@"bms-app-server" code:error.code userInfo:@{NSLocalizedDescriptionKey : @"Auf dem Server der App ist ein Fehler aufgetreten! Sollte das Problem länger bestehen, wende dich bitte an den Admin der App! Danke!"}];
                    
                    //rufe die Delegate-Methode auf
                    [self.delegate mitteilungenController:self didFinishedRefreshWithError:customError];
                }
            }
            else {
                //durch jedes einzelne Mitteilungs-Objekt gehen und es in der Datenbank speichern
                for (NSDictionary *mitteilungDict in mitteilungen) {
                    
                    //dann bekomme die einzelnen Eigenschaften einer Mitteilung, überprüfe sie und, nach erfolgreicher Überprüfung, speichere sie in der Datenbank ab
                    NSString *idString = [mitteilungDict objectForKey:@"id"];
                    
                    //nur wenn eine ID vorhanden ist, weitergehen
                    if (![idString isKindOfClass:[NSNull class]] && idString && idString.length > 0) {
                        //dann wandle die ID in eine Zahl um, die wieder größer oder gleich 0 sein soll
                        NSInteger id = [idString integerValue];
                        
                        if (id >= 0) {
                            
                            //zuerst eine Variable "geloescht" initialisieren, die später dazu genutzt werden kann, eine Mitteilung nicht noch zur Datenbank hinzuzufügen, wenn sie eigentlich gelöscht werden sollte
                            BOOL geloescht = NO;
                            
                            //zunächst überprüfen, ob diese Nachricht gelöscht werden soll, der Wert des Booleans "geloescht" also auf YES (gleich 1) steht
                            NSString *geloeschtString = [mitteilungDict objectForKey:@"geloescht"];
                            
                            //das überprüfen
                            if (![geloeschtString isKindOfClass:[NSNull class]] && geloeschtString && geloeschtString.length == 1) { //Länge gleich 1 wegen Boolean
                                //dann den geloeschtString in einen Boolean umwandeln
                                geloescht = [geloeschtString boolValue];
                                
                                if (geloescht == YES) {
                                    //dann die Mitteilung mit dieser ID löschen
                                    Mitteilung *mitteilungToDelete = [Mitteilung mitteilungFuerID:id undUser:self.user inManagedObjectContext:self.user.managedObjectContext]; //die eventuell vorhandene Mitteilung mit dieser ID bekommen
                                    
                                    if (mitteilungToDelete) {
                                        //lösche diese Mitteilung, wenn eine vorhandene aus der Datenbank zurückgegeben wurde
                                        [mitteilungToDelete loescheMitteilung];
                                    }
                                    
                                }
                            }
                            
                            //nur weitergehen, wenn die Nachricht nicht geloescht werden soll
                            if (!geloescht) {
                                //jetzt überprüfen, ob eine Nachricht gegeben ist (denn ohne Nachricht macht das Speichern keinen Sinn
                                NSString *nachricht = [mitteilungDict objectForKey:@"nachricht"];
                                
                                if (![nachricht isKindOfClass:[NSNull class]] && nachricht && nachricht.length > 0) {
                                    //dann ist die Nachricht erstmal "gültig", sodass ein Mitteilungs-Objekt erstellt werden kann, wenn die Nachricht nicht geänder wurde, und die Mitteilung nur bearbeitet werden muss
                                    Mitteilung *neueMitteilung = [Mitteilung mitteilungFuerID:id undUser:self.user inManagedObjectContext:self.user.managedObjectContext];
                                    
                                    //wenn also keine Mitteilung vorhanden ist, erstelle eine neue Mitteilung, der dann die entsprechenden Werte zugewiesen werden
                                    if (!neueMitteilung) {
                                        neueMitteilung = [Mitteilung mitteilungErstellenMitID:id fuerUser:self.user inManagedObjectContext:self.user.managedObjectContext];
                                    }
                                    else {
                                        //setze das Datum der letzen lokalen Änderung, was beim Erstellen einer neuen Mitteilung automatisch in der Erstellungs-Methode passiert
                                        neueMitteilung.letzteLokaleAenderung = [NSDate date];
                                    }
                                    
                                    //als nächstes den Titel der Nachricht abfragen und diesen, wenn dieser gültig ist, zur "neuenMitteilung" hinzufügen
                                    NSString *titel = [mitteilungDict objectForKey:@"titel"];
                                    
                                    //den Titel überprüfen, bevor er zur Nachricht hinzugefügt wirdd
                                    if (![titel isKindOfClass:[NSNull class]] && titel && titel.length > 0) {
                                        neueMitteilung.titel = titel;
                                    }
                                    
                                    //als nächstes die Stufen aus der Mitteilung bekommen, falls vorhanden, und auch, wenn diese gültig sind, in der Datenbank speichern
                                    NSString *stufenString = [mitteilungDict objectForKey:@"stufen"];
                                    
                                    if (![stufenString isKindOfClass:[NSNull class]] && stufenString && stufenString.length > 0) {
                                        neueMitteilung.stufen = stufenString;
                                    }
                                    
                                    //im nächsten Schritt die Datumsangaben aus der heruntergeladenen Dictionary parsen
                                    
                                    //dafür zunächst einen geeigneten DateFormatter erstellen
                                    NSDateFormatter *df = [[NSDateFormatter alloc]init];
                                    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                    
                                    
                                    NSString *geaendertAmString = [mitteilungDict objectForKey:@"geaendertAm"];
                                    
                                    //das Datum der letzten Änderung auf dem Server, das eventuell durch die mitteilungDict zurückgegeben wurde, "überprüfen", ob es gültig war
                                    if (![geaendertAmString isKindOfClass:[NSNull class]] && geaendertAmString && geaendertAmString.length > 0) {
                                        //dann wandle diesen String in ein Datum um
                                        NSDate *geaendertAmDate = [df dateFromString:geaendertAmString];
                                        
                                        if (geaendertAmDate) {
                                            //der Mitteilung hinzufügen und zwar als "datum", weil das "datum" angeben soll, wann sozusagen der Stand einer einzelnen Mitteilung war
                                            neueMitteilung.datum = geaendertAmDate;
                                        }
                                    }
                                }
                                else {
                                    //wenn in diesem Fall keine Nachricht gegeben ist, dann überprüfe, ob bereits eine Mitteilung mit dieser ID existiert --> dann lösche sie, weil keine Nachricht vorhanden ist
                                    Mitteilung *mitteilung = [Mitteilung mitteilungFuerID:id undUser:self.user inManagedObjectContext:self.user.managedObjectContext];
                                    
                                    //wenn also eine Mitteilung gegeben ist --> lösche diese; wenn also eine Mitteilung gegeben ist, dann ist wohl auf dem Server irgendwie ein Fehler passiert, weil eine Mitteilung zurückgegeben wurde, obwohl eigentlich gar keine Nachricht für diese Mitteilung definiert wurde
                                    if (mitteilung) {
                                        //dann lösche die Mitteilung
                                        [mitteilung loescheMitteilung];
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            //das Datum der letzten erfolgreichen Aktualisierung der Mitteilungen speichern
            self.user.lastMitteilungenUpdate = [NSDate date];
            
            //den managedObjectContext speichern
            NSError *savingError;
            [self.user.managedObjectContext save:&savingError];
            
            if (savingError) {
                NSLog(@"Fehler beim Speichern neuer Mitteilungen in der Datenbank");
            }
            else {
                //ansonsten eine Delegate-Methode aufrufen, die angibt, dass die Aktualisierung der Mitteilungen abgeschlossen wurde
                if (self.delegate && [self.delegate respondsToSelector:@selector(mitteilungenController:didFinishedRefreshWithError:)]) {
                    //rufe die Delegate-Methode auf
                    [self.delegate mitteilungenController:self didFinishedRefreshWithError:nil]; //kein Fehler, also nil als Error-Parameter
                }
                
            }
        }
    });
}


#pragma mark - generelle Methoden (auch Hilfsmethoden für andere Objekte)
///gibt die FetchRequest für alle Mitteilungen im MitteilungsController zurück --> mit dieser FetchRequest kann ein FetchedResultsController gefüllt werden, der wiederum einen TableView füllen kann
- (NSFetchRequest *)alleMitteilungenFetchRequest {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Mitteilung" inManagedObjectContext:self.user.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user == %@", self.user];
    [fetchRequest setPredicate:predicate];
    
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"datum" ascending:NO]; //die Objekte nach dem Datum sortieren, was angibt, wann die Mitteilungen von den Lehrern erstellt wurden bzw. das letzte Mal geändert wurden
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    
    return fetchRequest;
}


@end
