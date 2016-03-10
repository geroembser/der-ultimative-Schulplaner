//
//  NewsController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 06.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "NewsController.h"
#import "News.h"
#import "KurseController.h"
#import "WebsiteTag.h"

@interface NewsController () <NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate> {
///die NSURL-Session, mit der die Webseiten-Artikel gedownloaded werden
NSURLSession *articlesSession;
//die NSURL-Session, mit der die LeadImages für die einzelnen Artikel heruntergeladen werden
NSURLSession *imagesDownloadSession;
}

@end


@implementation NewsController


#pragma mark - Initialisierung
- (instancetype)initWithNewsControllerType:(NewsControllerType)type {
    self = [super init];
    
    if (self) {
        self.type = type;
        self.news = [NSMutableArray new];
        
        //die Session für den Download der News erstellen
        articlesSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
        
        //die Session für den Download der Bilder erstellen
        imagesDownloadSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        
        //die Anzahl der Artikel festlegen, die pro Seite heruntergeladen werden sollen
        self.articlesPerSite = 30;
        
        //die Seite, bei der angefangen wird, die Artikel herunterzuladen
        self.page = 1;
        
        //von Anfang an erlauben, eine Seite herunterzuladen
        self.canStartDownloadNextSite = YES;
    }
    
    return self;
}

- (instancetype)initWithParentNewsController:(NewsController *)parentNewsController {
    self = [super init];
    
    if (self) {
        self.type = newsControllerTypeUserTags;
        
        self.news = [NSMutableArray new];
        
        self.page = 1; //starte bei Seite 1 (der Informatiker hätte 0 geschrieben :-))
        self.pagesCount = parentNewsController.pagesCount; //ist gleich die Anzahl der Seiten vom parentNewsController
        
        self.parentNewsController = parentNewsController;
        parentNewsController.childNewsController = self;
    }
    
    return self;
}

#pragma mark - Download
- (void)startNewsDownload {
    //wenn News-Controller-Type-User-Tags, dann erstelle Download-Tasks für alle Tags in der articlesSession
    if (self.type == newsControllerTypeUserTags) {
        
        [self userSpecificSortNewsOfParentNewsController];
        
        //Vorgehen:
        //1. den häufigsten Tag bestimmen bzw. den mit der höchsten Relevanz (dazu am besten neue Eigenschaften zur WebsiteTag-Klasse in Datenbank hinzufügen: relevanz, vorkommenBeiAktivenKursen --> relevanz kann immer hochgezählt werden, wenn ein Artikel angeklickt wurde) --> keine zusätzlichen Daten für den häufigsten Tag herunterladen, weil bereits alle wichtigen Artikel aus der letzten Zeit in den 50 letzen Artikeln enthalten sein sollten
        //2. Die ersten 50 aktuellsten Artikel herunterladen
        //3. Die Artikel, deren Tags und Titel zu den Suchbegriffen/Tags passen, die am häufigsten vorkommen, in der Liste nach Datum sortiert nach oben im Array stellen.
        
        
        
        ///vielleicht eine Klassenmethode mit einer Singleton-Variable die einen Array mit den letzen neuen Artikeln enthält, damit, falls bereits die ersten Artikel im normalen Modus heruntergeladen wurden, diese nicht doppelt heruntergeladen werden und damit auch doppelt Speicher benötigen und doppeltes Datenvolumen benötigen
        

        //für die Namen jedes aktiven Kurses und seiner Tags die entsprechenden Download-Tasks erstellen (mit der marienschule.de-Suchfunktion nach dem Schema: http://marienschule.de/?s=Natur&x=0&y=0&json=1&orderby=date)
        
        //den am häufigsten vorkommenden Tag ermitteln und für ihn eine Suchanfrage starten, aber nur die Artikel der letzten 30 Tage mit einbeziehen
        
        //Relevanz-Property bei den Tags, die angibt, wie beliebt der Tag ist --> also wie oft er vorkommt???? --> bzw. wahrscheinlich nicht nötig, weil alle Tags für jeden aktiven Kurs durchgehen und daraus den am häufigsten vorkommenden Tag ermitteln --> Häufigkeit zurückgeben --> wenn zurückgegebene Häufigkeit gleich 1 ist, dann die Suchanfrage nicht bei Server stellen, weil die Relevanz als zu gering eingeschätzt wird
        
        //bei jedem Anklicken einer News wird ein Zähler bei der Relevanz beim entsprechenden Tag hochgezählt und der Tag wird höher eingestuft....
        
        //Man müsste also circa die ersten 50 aktuellen Artikel von der Webseite herunterladen und diese nach den Tags und Suchbegriffen filtern und sortieren, sodass ihre Relevanz bestimmt werden kann.
    
        //wenn die nächste Seite der aktuellen Artikel heruntergeladen wird (also Artikel 51-100), dann müssten diese nochmal nach dem selben Algorithmus wie die ersten 50 Artikel sortiert werden und in der Reihenfolge, wie sie der Algorithmus sortiert hat, an die ersten 50 drangehängt werden-->?!
        
        //dann erstelle download-Tasks für alle URLs, die in dem Array festgelegt sind ---> am besten jeweils nur die ersten 5 herunterladen
        
    
    }
    
    
    //ansonten lade nur die letzen Artikel herunter
    if (articlesSession) {
        //Am Anfang anfangen, die Post herunterzuladen
        
        [self startDownloadPostsAtPageWithIndex:1];
    }
}

- (void)loadNextPage {
    //wenn ein parentNewsController vorhanden ist, dann rufe seine Methode zum Aktualisieren der News auf
    if (self.parentNewsController) {
        if (self.canStartDownloadNextSite) {
            self.canStartDownloadNextSite = NO;
            if (self.page+1 <= self.parentNewsController.pagesCount) {
                self.page++;
                [self.parentNewsController loadNextPage];
            }
        }
    }
    else {
        //überprüfen, ob der Download der nächsten Seite starten kann, oder ob schon einer gestartet wurde
        if (self.canStartDownloadNextSite) {
            //die gerade abgefragte Eigenschaft auf NO setzen, um anzugeben, dass gerade ein Downloadversuch gestartet wurde
            self.canStartDownloadNextSite = NO;
            
            //den page-Index um einen hoch zählen, solange der Page-Index kleiner als der page count ist (Überprüfung, ob überhaupt noch Seiten verfügbar sind, die heruntergeladen werden können)
            if (self.page+1 <= self.pagesCount) {
                
                //den Download der aktuellen Seite starten
                [self startDownloadPostsAtPageWithIndex:self.page+1];
            }
        }
    }
    
}

- (BOOL)hasMorePagesToLoad {
    if (self.page < self.pagesCount) {
        return YES;
    }
    
    return NO;
}

- (void)startDownloadPostsAtPageWithIndex:(NSUInteger)pageIndex {
    
    //die News-URL erstellen (mit den Seiten-Parametern, um die entsprechenden Seiten zurückzubekommen)
    NSString *newsURL = [NSString stringWithFormat:@"http://marienschule.de/?json=get_recent_posts&page=%lu&count=%lu", pageIndex, self.articlesPerSite];
    NSURLSessionDataTask *dataTask = [articlesSession dataTaskWithURL:[NSURL URLWithString:newsURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //das Delegate definieren, an das in diesem Block Nachrichten geschickt werden sollen (auf dem Delegate des childNewsControllers oder auf dem eigenen, wenn es gesetzt sein sollte)
        id <NewsControllerDelegate> theDelegate = self.childNewsController.delegate ? self.childNewsController.delegate : self.delegate;
        
        //wenn ein Fehler beim Download passiert ist, abbrechen und den Fehler dem Delegate mitteilen
        if (error) {
            //nur die Delegate-Methode aufrufen, wenn der Task nicht vom User abgebrochen wurde, zum Beispiel dadurch, dass er den Reload-Button betätigt hat
            if (error.code != NSURLErrorCancelled) {
                //die Delegate-Methode aufrufen
                if (theDelegate && [theDelegate respondsToSelector:@selector(newsController:didFinishDownloadingNewsWithError:)]) {
                    [theDelegate newsController:self didFinishDownloadingNewsWithError:error];
                }
            }
        }
        else {
            NSError *jsonError;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            //wenn ein JSON-Fehler passiert ist, abbrechen und dem Delegate den Fehler mitteilen
            if (jsonError) {
                if (theDelegate && [theDelegate respondsToSelector:@selector(newsController:didFinishDownloadingNewsWithError:)]) {
                    [theDelegate newsController:self didFinishDownloadingNewsWithError:jsonError];
                }
            }
            else {
                
                //die zurückgegebenen Informationen über die Seiten in den entsprechenden Variablen speichern
                self.pagesCount = [[jsonDict objectForKey:@"pages"]unsignedIntegerValue];
                self.articleCount = [[jsonDict objectForKey:@"count_total"]unsignedIntegerValue];
                
                //vor dem Hinzufügen der Posts/News zum news-array, die Anzahl von Objekten im News-Array vor dem Hinzufügen in einer Variable speichern, damit nachher bei dem Index angefangen werden kann, die Bilder herunterzuladen, weil bis zu dem Index sollte es schon angefangen worden sein bzw. abgeschlossen sein, die Bilder herunterzuladen
                NSUInteger prevNewsCount = self.news.count;
                
                
                //vor dem Hinzufügen von neuen News das Delegate informieren, dass damit begonnen wird, neue News hinzuzufügen
                if ([self.delegate respondsToSelector:@selector(didBeginRefreshingNewsInNewsController:)]) {
                    [self.delegate didBeginRefreshingNewsInNewsController:self];
                }
                
                //einen Boolean-Variable, die angibt, ob ein Delegate vorhanden ist, das auf den angegebenen-Selektor reagiert
                BOOL hasValidDelegate = [self.delegate respondsToSelector:@selector(newsController:didInsertObject:atIndex:)];
                
                //alle posts vom zurückgegebenen Inhalt nehmen und mit einer For-Schleife durchlaufen
                NSArray *posts = [jsonDict objectForKey:@"posts"];
                for (NSDictionary *aPost in posts) {
                    News *news = [[News alloc]initWithJSONDictionary:aPost];
                    [self.news addObject:news];
                    
                    if (hasValidDelegate) {
                        //dann rufe die Delegate-Methode auf, die darüber informiert, dass ein neues News-Objekt hinzugefügt wurde - diese Delegate-Methode aber nur auf dem Delegate von self, also dem recentPostNewsController, aufrufen, weil die News so nicht zu einem eventuellen childNewsController hinzugefügt werden, wie es hier passiert
                        [self.delegate newsController:self didInsertObject:news atIndex:self.news.count-1];
                    }
                    
                }
                
                //wenn der Download erfolgreich abgeschlossen wurde dann zähle die Variable für die Seite erst hoch, ansonsten wird die Variable bei mehreren aufeinanderfolgen, fehlgeschlagenen Download-Versuchen immer weiter hochgezählt --> aber: wichtig!!! vor dem Sortieren des childNewsControllers, weil dieser sich in seiner userSpecificSortNewsOfParentNewsController-Methode auf die neue Einstellung bezieht
                self.page = pageIndex;
                
                //wenn ein childNewsController vorhanden ist, dann rufe seine sortieren-Methode auf - am besten (bzw. vorsichtshalber) vor der gleich folgende Schleife, die die Downloads für die Bilder startet (ich habe es noch nicht mit ausprobiert, wenn dies danach stehen würde, aber ich denke, es könnte zu zusätzlichen Problemen und zusätzlichen Abfragen kommen, wenn die News beispielsweise noch sortiert werden, während der Download für die Bilder schon abgeschlossen ist)
                if (self.childNewsController) {
                    [self.childNewsController userSpecificSortNewsOfParentNewsController];
                }
                
                //die Delegate-Methode aufrufen
                if (theDelegate) {
                    if ([theDelegate respondsToSelector:@selector(newsController:didFinishDownloadingNewsWithError:)]) {
                        //teilt dem Delegate mit, dass der Download von den neuen News abgeschlossen ist
                        [theDelegate newsController:self didFinishDownloadingNewsWithError:error];
                    }
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(didEndRefreshingNewsInNewsController:)]) {
                    //teilt dem Delegate mit, dass jetzt die Aktualisierung der News im news-array abgeschlossen ist und die Möglichkeit besteht, einen TableView zu updaten. - Dies wieder nur ausführen, wenn es wirklich ein delegate bei self gibt, nicht bei dem childNewsController, weil es sagen würden, dass News im diesen Controller aktualisiert wurden, was ja faktisch der Fall war, aber was keinem Delegate mitgeteilt werden kann, wenn self == nil ist
                    [self.delegate didEndRefreshingNewsInNewsController:self];
                }
                
                
                
                //nachdem die Delegate-Methode aufgerufen wurde und alle News-Objekte erstellt wurden und der TableView auf dem MainThread, der die News von diesem Controller darstellt, alle News dargestellt hat, starte erst den Download der Bilder, damit es zu keinen Problemen kommt --> aber ab dem Index prevNewsCount
                for (NSUInteger i = prevNewsCount; i < self.news.count; i++) {
                    News *news = [self.news objectAtIndex:i];
                    
                    //das Lead-Image für jedes News-Objekt herunterladen, wenn eins vorhanden ist
                    if (news.leadimageURL && news.leadimageURL.length > 0) {
                        
                        //die Variable enthält die News für den Image-Download
                        __block News *newsForDownloadTask = news;
                        
                        //einen neuen Data-Task für die Image-Download-Session erstellen
                        NSURLSessionDataTask *imageDownloadTask = [imagesDownloadSession dataTaskWithURL:[NSURL URLWithString:news.leadimageURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                            if (!error) {
                                //die heruntergeladenen ImageData der newsForDownloadTask zuweisen
                                newsForDownloadTask.imageData = data;
                                
                                //wenn kein Fehler passiert ist, die Methode refreshNews aufrufen, welche eine Nachricht an das Delegate schickt:
                                [self refreshNews:newsForDownloadTask];
                            }
                        }];
                        
                        //den imageDownloadTask starten
                        [imageDownloadTask resume];
                    }
                }
                
                
            }
            
        }
        
        //nachdem eine weitere Seite heruntergeladen wurde oder ein Download-Fehler passiert ist, wieder erlauben, weitere eventuell noch vorhandenen Seiten herunterzuladen
        self.canStartDownloadNextSite = YES;
    }];
    
    //das Delegate definieren, an das in diesem Block Nachrichten geschickt werden sollen (auf dem Delegate des childNewsControllers oder auf dem eigenen, wenn es gesetzt sein sollte)
    id <NewsControllerDelegate> theDelegate = self.childNewsController.delegate ? self.childNewsController.delegate : self.delegate;
    
    //das Delegate darüber informieren, dass der Download begonnen hat
    if (theDelegate && [theDelegate respondsToSelector:@selector(didBeginDownloadingNewsInNewsController:)]) {
        [theDelegate didBeginDownloadingNewsInNewsController:self];
    }
    [dataTask resume];
}

- (void)reload {
    //Die Reload-Methode von einem eventuell vorhandenen parentNewsController aufrufen
    if (self.parentNewsController) {
        //vorher die Seite dieses Controllers auf 1 setzen
        self.page = 1;
        [self.parentNewsController reload];
    }
    
    //alle Download-Task in der articlesSession abbrechen - aber nur, wenn kein parentNewsController vorhanden ist, der die News für den childNewsController verwaltet
    if (!self.parentNewsController) {
        [articlesSession getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
            for (NSURLSessionDataTask *dataTask in dataTasks) {
                [dataTask cancel];
            }
        }];
    }
    
    //die nächsten Zeilen Code -auch- ausführen, wenn ein parentViewController gegeben ist
    
    //das Delegte informieren, dass begonnen wird, Dinge zu aktualisieren
    if (self.delegate && [self.delegate respondsToSelector:@selector(didBeginRefreshingNewsInNewsController:)]) {
        [self.delegate didBeginRefreshingNewsInNewsController:self];
    }
    
    //entsprechende Delegate-Methoden aufrufen
    if ([self.delegate respondsToSelector:@selector(newsController:didRemoveObject:atIndex:)]) {
        for (int i = 0; i < self.news.count; i++) {
            [self.delegate newsController:self didRemoveObject:[self.news objectAtIndex:i] atIndex:i];
        }
    }
    
    //alle vorhandenen Objekte löschen
    self.news = [NSMutableArray new];
    
    //das Delegate informieren, dass die Aktualisierung der Daten zu Ende ist
    if (self.delegate && [self.delegate respondsToSelector:@selector(didEndRefreshingNewsInNewsController:)]) {
        [self.delegate didEndRefreshingNewsInNewsController:self];
    }
    
    //den Download erneut bei Seite 1 starten - aber nur, wenn kein parentNewsController vorhanden ist, der die News für den childNewsController verwaltet
    if (!self.parentNewsController) {
        [self startDownloadPostsAtPageWithIndex:1];
    }
}

#pragma mark - User spezifische Sortierung
///sortiert die News im parentNewsController userspezifisch
- (void)userSpecificSortNewsOfParentNewsController {
    //Am Anfang die Delegate-Methode aufrufen, die sagt, dass begonnen wird, die News zu updaten
    if (self.delegate && [self.delegate respondsToSelector:@selector(didBeginRefreshingNewsInNewsController:)]) {
        [self.delegate didBeginRefreshingNewsInNewsController:self];
    }
    
    //den Array, der temporär die News hält, die nachher zum self.news-array hinzugefügt werden sollen (temporärer Array wird benötigt, damit man nach der Einschätzung der Relevanz der einzelnen News den array sortieren kann, sodass ich die News-Objekte nicht einfach direkt an den news-array "dranhängen" kann)
    NSMutableArray *tempNews = [NSMutableArray new];
    
    //den Array (nach Vorkommen und Relevanz sortiert) mit den entsprechenden Website-Tags für den Benutzer bekommen
    NSArray *tags = [WebsiteTag alleRelevantenTagsFuerUser:self.associatedUser];
    
    //jede News vom Parent-NewsController durchgehen (den Startpunkt anhand der aktuellen Seite und der articlesPerSite property von parentNewsController bestimmen) und anhand bestimmter Parameter im self.news-array einordnen
    for (int i = (int)(self.page*self.parentNewsController.articlesPerSite-self.parentNewsController.articlesPerSite); i < self.parentNewsController.news.count; i++) {
        //Die neuen News, die noch bewertet werden müssen
        News *news = [self.parentNewsController.news objectAtIndex:i];
        
        //Die Relevanz des News-Objekts einschätzen anhand aller Tags aus dem tags-array
        [news einschaetzenMitWebsiteTags:tags];
        
        //wenn die Relevanz null ist, dann das Objekt nicht zum temporären Array hinzufügen, ansonsten schon
        if (news.relevanz != 0) {
            [tempNews addObject:news];
        }
    }
    
    
    //Am Ende den Array nach der Relevanz der einzelnen News-Objekte sortieren
    //dafür die SortDescriptors erstellen
    NSSortDescriptor *relevanzSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"relevanz" ascending:NO]; //erst nach Relevanz, ...
    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]; //... dannn nach Datum sortieren
    [tempNews sortUsingDescriptors:@[relevanzSortDescriptor, dateSortDescriptor]];
    
    //dann den neuen temporären News-Array an den self.news-array anhängen und die Delegate Methode aufrufen, dass neue Objekte an den bestimmten Indizes hinzugefügt wurden
    BOOL hasValidDelegate = [self.delegate respondsToSelector:@selector(newsController:didInsertObject:atIndex:)];
    for (int i = 0; i < tempNews.count; i++) {
        News *newsToAdd = [tempNews objectAtIndex:i];
        
        [self.news addObject:newsToAdd];
//        NSLog(@"INDEX: %lu", (unsigned long)self.news.count-1);
        if (hasValidDelegate) {
            [self.delegate newsController:self didInsertObject:newsToAdd atIndex:self.news.count-1]; //-1, weil das Objekt in der Zeile darüber zum Array hinzugefügt wird
        }
        
    }
    
    //Am Ende die Delegate-Methode aufrufen, die sagt, dass die Aktualisierung der News abgeschlossen ist
    if (self.delegate && [self.delegate respondsToSelector:@selector(didEndRefreshingNewsInNewsController:)]) {
        [self.delegate didEndRefreshingNewsInNewsController:self];
    }
    
    //nächste Seite kann geladen werden
    self.canStartDownloadNextSite = YES;
}


#pragma mark - NSURLSessionDelegate

#pragma mark - NewsControllerDelegate
///sendet an das Delegate die Nachricht, dass ein News-Objekt an einem bestimmten Index aktualisiert werden muss
- (void)refreshNews:(News *)newsToRefresh {
    if (self.delegate && [self.delegate respondsToSelector:@selector(newsController:didRefreshNewsObject:atIndex:)]) {
        //den Index für die News aus dem news-Array herausfinden
        NSUInteger index = [self.news indexOfObject:newsToRefresh];
        
        //die Delegate-Methode aufrufen, wenn ein Index gefunden wurde
        if (index != NSNotFound) {
            [self.delegate newsController:self didRefreshNewsObject:newsToRefresh atIndex:index];
        }
    }
    //Außerdem dem childNewsController Bescheid sagen, dass ein News-Objekt akutalisiert werden muss
    if (self.childNewsController) {
        [self.childNewsController refreshNews:newsToRefresh];
    }
}



@end
