//
//  Newscenter.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 13.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "Newscenter.h"
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@interface Newscenter () <MitteilungenControllerDelegate, NSFetchedResultsControllerDelegate>
///Alle News-Objekte, die von diesem News-Center verwaltet werden
@property NSMutableArray *newsObjects;

///der FetchedResultsConroller, der dazu verwendet werden soll, die Mitteilungs-Objekte aus der Datenbank zu "holen"
@property NSFetchedResultsController *frc;


@end

@implementation Newscenter

#pragma mark - Returning instances

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
        //initialisiere den newsObject-array
        self.newsObjects = [NSMutableArray new];
        
        
        //ein Test-News-Objekt bzw. Willkommens-Newsobjekt (kann als ein solches ausgegeben werden)
        NewscenterObject *newsObject = [NewscenterObject newsCenterObjectWithTitle:@"Herzlich Willkommen" text:@"Herzlich Willkommen im Newscenter deiner BMS-App" andDate:[NSDate date]];
        [self.newsObjects addObject:newsObject];
        
        //einen FetchedResultsController initialisieren, der die Mitteilungen von Lehrerseite verwaltet und aus der Datenbank holt
        self.mitteilungenController = [MitteilungenController defaultController];
        self.mitteilungenController.delegate = self;
        
        
        self.frc = [[NSFetchedResultsController alloc]initWithFetchRequest:[self.mitteilungenController alleMitteilungenFetchRequest] managedObjectContext:self.mitteilungenController.user.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        self.frc.delegate = self; //das Delgate setzen
        
        [self.frc performFetch:nil];
        
        
    }
    
    return self;
}

+ (Newscenter *)defaultNewscenter {
    static Newscenter *defaultNC = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultNC= [[Newscenter alloc]init];
    });
    
    return defaultNC;
}


#pragma mark - News-Infos
- (NewscenterObject *)newscenterObjectAtIndex:(NSUInteger)index {
    //solange der gewünscht Index größer als der Index ist, der vorhandenen, Standard-News-Objekte, nimm die Newscenter-Objekte aus dem newsObjects-Array
    if (index >= (self.numberOfNewsEntries-self.newsObjects.count)) {
        return [self.newsObjects objectAtIndex:index-(self.numberOfNewsEntries-self.newsObjects.count)]; //der NewsObject-Array ist am Ende aller News-Objekte --> daher diese Befehle, die sozusagen die ersten Objekte aus dem FetchedResultsController nehmen und die restlichen aus dem newsObjects-Array hinzufügen, die hinten an alle News-Objekte angefügt wurden
    }
    else if (index < (self.numberOfNewsEntries-self.newsObjects.count)) {
        //ansonten nimm die Daten vom FetchedResultsController --> sind "Mitteilung"s-Objekte
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0]; //der Index Path, für das Item, dass durch den FetchedResultsController gewonnen werden soll
        
        //das Mitteilungs-Objekt vom FetchedResultsController bekommen
        Mitteilung *mitteilung = [self.frc objectAtIndexPath:indexPath];

        
        if (mitteilung) {
            //ein NewscenterObjekt für die Mitteilung erstellen
            NewscenterObject *newscenterObject = [NewscenterObject newsCenterObjectWithMitteilung:mitteilung];
            
            return newscenterObject;
        }
    }
    
    return nil;
}

- (NSUInteger)numberOfNewsEntries {
    return self.newsObjects.count+[self frcObjectsCount];
}

///gibt die Anzahl der Mitteilungs-Objekte zurück, die durch den FetchedResultsController verwaltet werden
- (NSUInteger)frcObjectsCount {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.frc sections] objectAtIndex:0];
    
    NSInteger count = [sectionInfo numberOfObjects];
    
    return count;
}


#pragma mark - Newscenter-Aktionen
- (void)startCreatingNewsFromDefaultSources {
    //die Delegate-Methoden aufrufen, die angibt, dass die Aktualisierung begonnen hat
    if (self.delegate && [self.delegate respondsToSelector:@selector(newscenterDidBeginServerUpdate:)]) {
        [self.delegate newscenterDidBeginServerUpdate:self];
    }
    
    //den Download neuer News-Objekte starten, wenn die News von den "Standard-Quellen" zusammengestellt werden sollen
    [self.mitteilungenController downloadNew];
    
    //das Datum der letzten Aktualisierung auf jetzt setzen
    self.lastNewscenterUpdate = [NSDate date];
}

- (void)reloadNewscenter {
    //die Delegate-Methoden aufrufen, die angibt, dass die Aktualisierung begonnen hat
    
    //alle vorhandenen News löschen
    
    //das Datum der letzten Aktualisierung auf jetzt setzen
    self.lastNewscenterUpdate = [NSDate date];
    
    //die Delegate-Methode aufrufen, die angibt, dass die Aktualiserung abgeschlosen wurde
}

#pragma mark - MitteilungenControllerDelegate
- (void)mitteilungenController:(MitteilungenController *)mitteilungenController didFinishedRefreshWithError:(NSError *)error {
    //eine Delegate-Nachricht "verschicken", damit das Delegate weiß, das der Abgleich der Daten mit dem Server erfolgreich war
    if (self.delegate && [self.delegate respondsToSelector:@selector(newscenter:didFinishServerUpdateWithError:)]) {
        [self.delegate newscenter:self didFinishServerUpdateWithError:error];
    }
    
    //eine Mitteilung posten, dass das Newscenter aktualisiert werden muss --> muss aber logischerweise nur aktualisiert werden, wenn kein Fehler passiert ist
    if (!error && self.delegate && [self.delegate respondsToSelector:@selector(newscenterShouldStartReload:)]) {
        [self.delegate newscenterShouldStartReload:self];
    }
}

#pragma mark - Mitteilungen FRC Delegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    //poste eine Nachricht an das Delegate, die angibt, dass damit begonnen wird, das Newscenter zu aktualisieren
    if (self.delegate && [self.delegate respondsToSelector:@selector(newscenterDidBeginReloading:)]) {
        [self.delegate newscenterDidBeginReloading:self];
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {

    //Sections ändern sich erstmal nicht in diesem Newscenter, weil es keine Sections hat
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {

    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            //teile dem Delegate mit, dass ein neues News-Objekt am gegebenen IndexPath hinzugefügt wurde
            if (self.delegate && [self.delegate respondsToSelector:@selector(newscenter:didInsertNewsObject:atIndex:)]) {
                [self.delegate newscenter:self didInsertNewsObject:[controller objectAtIndexPath:newIndexPath] atIndex:newIndexPath.row];
            }
            break;
            
        case NSFetchedResultsChangeDelete:
            //teile dem Delegate mit, dass ein News-Objekt am gegebenen IndexPath entfernt wurde
            if (self.delegate && [self.delegate respondsToSelector:@selector(newscenter:didRemoveNewsObject:atIndex:)]) {
                [self.delegate newscenter:self didRemoveNewsObject:nil atIndex:indexPath.row];
            }
            break;
            
        case NSFetchedResultsChangeUpdate:
            //teile dem Delegate mit, dass ein News-Objekt am gegebenen IndexPath aktualisiert wurde
            if (self.delegate && [self.delegate respondsToSelector:@selector(newscenter:didReloadNewsObject:atIndex:)]) {
                [self.delegate newscenter:self didReloadNewsObject:[controller objectAtIndexPath:indexPath] atIndex:indexPath.row];
            }
            
            break;
            
        case NSFetchedResultsChangeMove:

            //ein Objekt löschen, ...
            if (self.delegate && [self.delegate respondsToSelector:@selector(newscenter:didRemoveNewsObject:atIndex:)]) {
                [self.delegate newscenter:self didRemoveNewsObject:nil atIndex:indexPath.row];
            }
            
            //... das andere Hinzufügen
            if (self.delegate && [self.delegate respondsToSelector:@selector(newscenter:didInsertNewsObject:atIndex:)]) {
                [self.delegate newscenter:self didInsertNewsObject:[controller objectAtIndexPath:newIndexPath] atIndex:newIndexPath.row];
            }
            
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    //poste eine Nachricht an das Delegate, die angibt, dass die Aktualisierung des Newscenters abgeschlossen wurde
    if (self.delegate && [self.delegate respondsToSelector:@selector(newscenterDidEndReloading:)]) {
        [self.delegate newscenterDidEndReloading:self];
    }
}


@end
