//
//  StundenplanController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 10.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "StundenplanController.h"
#import "Schulstunde.h"
#import "Fach.h"
#import "KurseController.h"

@implementation StundenplanController

#pragma mark - Custom initialization
//Standard-Initialisierungs-Methode
- (instancetype)init {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

//Initialisierung des StundenplanControllers mit einem gegebenen Benutzer
- (instancetype)initWithUser:(User *)user {
    self = [self init];
    
    if (self) {
        self.associatedUser = user;
    }
    
    return self;
    
}

#pragma mark - Stundenplan-Aktualisierung/Download
//aktualisiert den Stundenplan sollte gleich der Methode downloadStundenplanDatenForUser
- (void)aktualisiereStundenplan {
    [self downloadStundenplanDatenForUser];
}

- (void)downloadStundenplanDatenForUser {
    //eine Server-Anfrage erstellen
    ServerRequestController *serverRequest = [[ServerRequestController alloc]initWithUser:self.associatedUser];
    
    //das Delegate der Anfrage auf diesen Controller setzen
    serverRequest.delegate = self;
    
    
    //das Datum der letzen gültigen Aktualisierung abfragen
    NSDate *letzeAktualisierung = self.associatedUser.lastDataUpdate;
    //daraus einen gültigen String für den Server erstellen in dem Format 12.01.2015
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"dd.MM.yyyy"];
    NSString *formattedDate = [df stringFromDate:letzeAktualisierung];
    NSLog(@"richtiges Datum?: %@", formattedDate);
    
    //wenn das zurückgegebene Datum nil ist, dann nimm einen Leerstring
    if (!formattedDate) {
        formattedDate = @"";
    }
    
    //einen DataTask erstellen
    NSURLSessionDataTask *dataTask = [serverRequest dataTaskForURL:[NSURL URLWithString:@"http://app.marienschule.de/files/scripts/NEW/getAllDataN.php"] withParameterDict:@{@"date":formattedDate}];
    
    //diesen DataTask starten
    [dataTask resume];
    
    //rufe die Delegate-Methode auf, die angibt, dass der Download begonnen wurde
    if ([self.delegate respondsToSelector:@selector(didBeginStundenplanAktualsierungForStundenplanController:)]) {
        [self.delegate didBeginStundenplanAktualsierungForStundenplanController:self];
    }
    
}

- (void)loescheStundenFuerBenutzer {
    //die schnellere iOS9 Variante zum löschen aller Objekte einer CoreData-Datenbank-Tabelle benutzen
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Schulstunde"];
    request.predicate = [NSPredicate predicateWithFormat:@"kurs.user == %@", self.associatedUser];
    
    NSBatchDeleteRequest *deleteRequest = [[NSBatchDeleteRequest alloc]initWithFetchRequest:request];
    NSError *deleteError = nil;
    [self.associatedUser.managedObjectContext executeRequest:deleteRequest error:&deleteError];
    
    if (deleteError) {
        NSLog(@"Fehler beim löschen aller Schulstunden in der Datenbank: %@", deleteError.localizedDescription);
    }
}

#pragma mark - Download Delegate
- (void)didFinishDownloadingDataTask:(NSURLSessionDataTask *)dataTask withData:(NSData *)downloadedData andError:(NSError *)error forServerRequest:(ServerRequestController *)serverRequestController {
    
    //der Fehler, der angibt ob beim verarbeiten der Daten ein Fehler passiert ist
    __block NSError *verarbeitungsFehler;
    
    //überprüfen, ob kein Fehler passiert ist
    if (!error) {
        //dann die Daten parsen
        NSError *jsonError;
        
        //die heruntergeladenen Daten in eine JSON-Dictionary parsen
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:downloadedData options:0 error:&error];
        
        
        //wenn kein Parsing-Fehler passiert ist, dann...
        if (!jsonError) {
            //... die heruntergeladenen und geparsten Dinge auf dem Main-Thread verarbeiten, weil CoreData ManagedObjectContext im MainThread ist (CoreData ist nicht Thread safe)
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //generelle Variablen aus der Json-Dictionary
                NSString *schuljahr = [jsonDict objectForKey:@"schuljahr"]; //das Schuljahr, für das die aktuell heruntergeladenen Daten gelten
                
                //die Schuljahr-Property vom User auf den heruntergeladenen Wert setzen
                self.associatedUser.schuljahr = schuljahr;
                
                //eine Instanz vom KurseController erstellen
                KurseController *kurseController = [[KurseController alloc]initWithUser:self.associatedUser];
                
                //0. Schritt: Alte Kurse auf archiviert setzen
                //(#todo) vielleicht alte Kurse löschen bzw. auf archiviert stellen, nachdem das Update durchgeführt wurde und eventuell Daten aktualisiert wurden (also vom Skript nicht false für beispeilsweise pkUndAgs zurückgegeben wurde) --> vielleicht anhand des Zuletzt-Aktualisert-Datums (geaendertAm) --> vielleicht erledigt, das muss die Zukunft zeigen, wenn man Zeit hat, das weiter auszuprobieren, vor allem, wenn ein neues Schuljahr beginnt
//                [kurseController archiviereAlleKurseFuerDenAktuellenBenutzer]; --> nicht alle zentral archivieren, weil sonst, wenn keine Änderungen vom Server zurückgegeben wurden (also false), alle Kurse archiviert werden würden, aber keinen neuen erstellt werden würden
                
                
                
                //1. Schritt: Die Fächerkürzel (bzw. alle Fächer) nehmen und in Core-Data speichern
                //das Fachkuerzel-Objekt bekommen --> erstmal bekommen und überprüfen, ob nicht false zurückgegeben wurde, also sich seit dem letzten Update keine Daten geändert haben
                NSObject *fachkuerzelObj = [jsonDict objectForKey:@"fachkuerzel"];
                
                //wenn das FachkuerzelObjekt eine Dictionary ist, die den Array für den key "fachkuerzel" enthält, dann aktualisiere die Fächerliste, ansonsten ist die Fächerliste in der Zwischenzeit nicht aktualisiert worden
                if (fachkuerzelObj && [fachkuerzelObj isKindOfClass:[NSDictionary class]]) {
                    //dann das Objekt mit für den key facherkuerzel bekommen...
                    NSObject *faecherkuerzelCheckArray = [(NSDictionary *)fachkuerzelObj objectForKey:@"facherkuerzel"];
                    //... und überprüfen ob dieses vorhanden ist und ein Array ist
                    if (faecherkuerzelCheckArray && [faecherkuerzelCheckArray isKindOfClass:[NSArray class]]) {
                        NSArray *jsonFaecherKuerzel = (NSArray *)faecherkuerzelCheckArray;
                
                        //mit einer fast enumeration durch alle Fächer im JSON-Fach Kuerzel Array von Dictionaries gehen
                        for (NSDictionary *jsonFach in jsonFaecherKuerzel) {
                            //das Kürzel für das Fach
                            NSString *fachKuerzel = [jsonFach objectForKey:@"SHORT"];
                            //der Name für das Fach
                            NSString *fachName = [jsonFach objectForKey:@"FULL"];
                            
                            if (fachKuerzel) {
                                //ein neues Fach erstellen bzw. ein altes updaten
                                Fach *fach = [Fach fachFuerKuerzel:fachKuerzel inManagedObjectContext:self.associatedUser.managedObjectContext];
                                fach.name = fachName;
                            }
                            
                        }
                    }
                }
                
                //2. Schritt: Lehrerliste herunterladen und "parsen" -> dann entsprechend in SQLite Database speichern
                NSObject *lehrerlisteObject = [jsonDict objectForKey:@"lehrerliste"];
                
                //hier wieder erst überprüfen, ob der Server neue bzw. gültige Daten zurückgegeben hat
                if (lehrerlisteObject && [lehrerlisteObject isKindOfClass:[NSDictionary class]]) {
                    
                    NSObject *lehrerlisteCheckObject = [(NSDictionary *)lehrerlisteObject objectForKey:@"lehrerliste"];
                    if (lehrerlisteCheckObject && [lehrerlisteCheckObject isKindOfClass:[NSArray class]]){
                        
                        NSArray *jsonLehrerArray = (NSArray *)lehrerlisteCheckObject;
                        
                        //wieder eine fast enumeration durch alle Lehrer in dem jsonLehrerArray
                        for (NSDictionary *jsonLehrer in jsonLehrerArray) {
                            NSString *name = [jsonLehrer objectForKey:@"NAME"];                 //(Nach-)Name des Lehrers
                            NSString *kuerzel = [jsonLehrer objectForKey:@"KUERZEL"];           //Kürzel des Lehrers
                            NSString *vorname = [jsonLehrer objectForKey:@"VORNAME"];           //Vorname des Lehrers
                            NSString *titel = [jsonLehrer objectForKey:@"TITEL"];               //Titel des Lehrers (Herr/Frau/Dr./Schwester...)
                            NSString *email = [jsonLehrer objectForKey:@"MAIL"];               //die E-Mail Adresse des Lehrers (aus Untis)
                            NSArray *faecher = [jsonLehrer objectForKey:@"faecher"];    //die Fächer des Lehrers
                            
                            //#debugging
                            //                    NSLog(@"jsonLehrer: %@", jsonLehrer);
                            //einen neuen Lehrer erstellen oder einen vorhandenen Aktualisieren (die Klasse Lehrer sollte automatisch die Zuweisung des Lehrers zu seinen jeweiligen Fächern übernehmen)
                            Lehrer *lehrer = [Lehrer lehrerForKuerzel:kuerzel inManagedObjectContext:self.associatedUser.managedObjectContext];
                            lehrer.name = name;
                            lehrer.vorname = vorname;
                            lehrer.titel = titel;
                            lehrer.email = email;
                            [lehrer setFaecherArray:faecher];
                        }
                    }
                }
                
                //3. Schritt: AGs und Projektkurse - dafür Kurse erstellen
                NSObject *pkAGObject = [jsonDict objectForKey:@"pkuags"];
                
                //hier erneut überprüfen, ob neue und gültige Daten zurückgegeben wurden
                if (pkAGObject && [pkAGObject isKindOfClass:[NSDictionary class]]) {
                    //ein check-Objekt zur Hilfe nehmen, um zu überprüfen, ob im pkAGObject auch ein Array mit den entscheidenen Daten für das Kürzel "pkuags" enthalten ist
                    NSDictionary *pkAGCheckObject = [(NSDictionary *)pkAGObject objectForKey:@"pkuags"];
                    //dieses Check-Objekt überprüfen, ob es vorhanden ist und ob es ein Array ist
                    if (pkAGCheckObject && [pkAGCheckObject isKindOfClass:[NSArray  class]]) {
                        
                        //alle alten PKs und Ags archivieren
                        [kurseController archiviereAllePKsUndAgsFuerDenAktuellenBenutzer];
                        
                        //die PKs und Ags in einem Array zusammenfassen
                        NSArray *jsonPkUndAGs = (NSArray *)pkAGCheckObject;
                        
                        for (NSDictionary *jsonPkAG in jsonPkUndAGs) {
                            
                            NSString *pkAGName = [jsonPkAG objectForKey:@"BESCHREIBUNG"];
                            NSString *kuerzel = [jsonPkAG objectForKey:@"KUERZEL"]; //bzw. Kurs-ID
                            NSString *lehrerkuerzel = [jsonPkAG objectForKey:@"LEHRERKUERZEL"];
                            NSArray *tags = [jsonPkAG objectForKey:@"TAGS"];
                            NSArray *typen = [jsonPkAG objectForKey:@"TYP"];
                            
                            //für jeden Typ der AG oder des Projektkurs einen neuen Kurs erstellen
                            for (NSString *typ in typen) {
                                //den Typ des Kurses von einem String in einen Integer "umwandeln"...
                                NSInteger typAsInteger;
                                
                                //...das geschieht mithilfe der folgenden If-Abfrage
                                if ([typ isEqualToString:@"PK"]) {
                                    typAsInteger = projektkursKursArt;
                                }
                                else {
                                    typAsInteger = agKursArt;
                                }
                                
                                
                                NSArray *vorhandeneKurse = [Kurs vorhandeneKurseFuerID:kuerzel inManagedObjectContext:self.associatedUser.managedObjectContext];
                                
                                Kurs *kursFuerTyp = nil;
                                //wenn kein Kurs vorhanden ist, dann erstelle einen neuen Kurs
                                if (!vorhandeneKurse) {
                                    kursFuerTyp = [Kurs neuerKursMitKursID:kuerzel inManagedObjectContext:self.associatedUser.managedObjectContext];
                                }
                                else {
                                    //Suche einen vorhandenen Kurs mit den Eigenschaften (dem Typ) des Kurses des aktuellen Schleifendurchlaufs
                                    for (Kurs *vorhandenerKurs in vorhandeneKurse) {
                                        if (vorhandenerKurs.kursart.integerValue == typAsInteger) {
                                            kursFuerTyp = vorhandenerKurs;
                                        }
                                    }
                                    
                                    //wenn kursFuerTyp immer noch nil ist nach der obigen Schleife, dann muss ein neuer Kurs erstellt werden, weil dann kein einziger Kurs mit den gesuchten Eigenschaften existiert
                                    if (!kursFuerTyp) {
                                        //dann ist der Kurs ein anderer, neuer oder ein Projektkurs für die AG
                                        //also muss auch ein neuer Kurs erstellt werden
                                        kursFuerTyp = [Kurs neuerKursMitKursID:kuerzel inManagedObjectContext:self.associatedUser.managedObjectContext];
                                    }
                                }
                                
                                
                                kursFuerTyp.lehrer = [Lehrer lehrerForKuerzel:lehrerkuerzel inManagedObjectContext:self.associatedUser.managedObjectContext];
                                kursFuerTyp.name = pkAGName;
                                kursFuerTyp.schuljahr = schuljahr; //das Schuljahr setzen (ist vielleicht später irgendwann einmal wichtig)
                                kursFuerTyp.user = self.associatedUser; //den Benutzer des Kurses setzen
                                
                                //die Tags für den Kurs setzen
                                [kursFuerTyp setTagsInArrayOfTagsStrings:tags];
                                
                                //den Typ für den Kurs setzen
                                kursFuerTyp.kursart = [NSNumber numberWithInteger:typAsInteger];
                                
                                //den Kurs nicht mehr archivieren
                                kursFuerTyp.archiviert = [NSNumber numberWithBool:NO];
                            }
                            
                        }
                    }}
                
                
                //4. Schritt....
                ///////////....nächster "Ober-Schritt" (Schritt 4.0): Schulstunden///////////////
                //zunächst überprüfen, ob neue Daten von Schulstunden verfügbar sind, erst wenn neue Schulstunden verfügbar sind, die alten löschen und die neuen einspeichern
                //--> dazu das "timetable"-Objekt aus der zurückgegebenen jsonDict bekommen
                NSObject *timeTableDictObject = [jsonDict objectForKey:@"timetable"];
                
                if (timeTableDictObject && [timeTableDictObject isKindOfClass:[NSDictionary class]]) {
                    //dann überprüfen, ob in dieser timetableDict, ein "stundenPlan" enthalten ist
                    NSObject *timeTableCheckArray = [(NSDictionary *)timeTableDictObject objectForKey:@"stundenPlan"];
                    
                    if (timeTableCheckArray && [timeTableCheckArray isKindOfClass:[NSArray class]]) {
                        //jetzt ist also sichergestellt, dass neue Daten für den Stundenplan verfügbar sind, also führe die Änderungen durch
                        //...4.1. Schritt alle alten Schulstunden löschen (aber nur für den aktuellen Benutzer)
                        //                [Schulstunde alleSchulstundenEntfernenInManagedObjectContext:self.associatedUser.managedObjectContext]; //das ist alt und würde alle Schulstunden entfernen
                        [self loescheStundenFuerBenutzer];
                        
                        
                        //5. Schritt: Schulstunden "parsen" und mit CoreData in SQLite Database speichern
                        NSArray *jsonSchulstunden = (NSArray *)timeTableCheckArray;
                        
                        //erstelle Schulstunden-Objekte aus jeder zurückgegebener Stunde
                        NSMutableArray *schulstunden = [NSMutableArray new];
                        
                        for (NSDictionary *jsonStunde in jsonSchulstunden) {
                            NSInteger wochentag = [[jsonStunde objectForKey:@"WOCHENTAG"]integerValue];
                            NSInteger stunde = [[jsonStunde objectForKey:@"STUNDE"]integerValue];
                            NSInteger blocknummer = [[jsonStunde objectForKey:@"BN"]integerValue];
                            NSString *lehrerKuerzel = [jsonStunde objectForKey:@"LKZ"];
                            NSString *kursID = [jsonStunde objectForKey:@"KURSID"];
                            NSString *raumnummer = [jsonStunde objectForKey:@"RAUM"];
                            
                            
                            Schulstunde *newSchulstunde = [Schulstunde neueSchulstundeFuerWochentag:wochentag undStunde:stunde mitLehrerKuerzel:lehrerKuerzel undRaumString:raumnummer blocknummer:blocknummer undKursId:kursID inManagedObjectContext:self.associatedUser.managedObjectContext];
                            
                            [schulstunden addObject:newSchulstunde];
                        }
                        
                        
                        //6. Schritt Kurse aus den CoreData-Schulstunden-Objekten und den heruntergeladenen AGs und Projektkursen erstellen --> Aufruf vom KurseController
                        //vorher aber alle alten, normalen Kurse archivieren
                        [kurseController archiviereAlleNormalenKurseFuerDenAktuellenBenutzer];
                        
                        //dann die Kurse aus den neu heruntergeladenen Schulstunden erstellen
                        [kurseController kurseInDatenbankAusSchulstunden:schulstunden inManagedObjectContext:self.associatedUser.managedObjectContext];
                        
                    }
                }
                
                
                //sagen, dass der User gültige Daten hat
                self.associatedUser.validData = [NSNumber numberWithBool:YES];
                
                //sagen, dass heute das letzte Daten-Update war
                self.associatedUser.lastDataUpdate = [NSDate date];
                
                //sagen, dass heute die letze Server-Verbindung war
                self.associatedUser.lastServerConnection = [NSDate date];
                
                //den Managed Object Context speichern - also die Änderungen wirksam machen - bis zu diesem Punkt könnten die Änderungen theoretisch noch einfach rückggängig gemacht werden können
                NSError *savingError = nil;
                
                [self.associatedUser.managedObjectContext save:&savingError];
                
                if (savingError) {
                    verarbeitungsFehler = savingError;
                }
            });
        }
        else {
            verarbeitungsFehler = [NSError errorWithDomain:@"JSONERROR" code:0 userInfo:@{NSLocalizedDescriptionKey : @"Fehler bei der Datenverarbeitung vom Server. Bitte wenden Sie sich an den Administrator"}];
        }
    }
    
    
    //das Delegate aufrufen
    
    if (!error) {
        //wenn kein Download-Fehler passiert ist, dann überprüfen ob ein Verarbeitungs-Fehler passiert ist bzw. nil oder ein Fehler wird zurückgegeben
        error = verarbeitungsFehler;
    }
    
    [self.delegate didFinishStundenplanAktualisierungInStundenplanController:self withError:error];
}

@end
