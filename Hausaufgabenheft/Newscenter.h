//
//  Newscenter.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 13.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewscenterObject.h"
#import "MitteilungenController.h"


///Das Newscenter-Protokoll, mit dem das Delegate eines Newscenter Objekts über Änderungen im Newscenter informiert werden kann
@class Newscenter, NewscenterObject;
@protocol NewscenterDelegate <NSObject>

@optional
///gibt an, dass ein Newscenter-Objekt aus dem Newscenter entfernt wurde
- (void)newscenter:(Newscenter *)newscenter didRemoveNewsObject:(NewscenterObject *)newsObj atIndex:(NSUInteger)index;
///gibt an, dass ein neues Newscenter-Objekt zum Newscenter hinzugefügt wurde
- (void)newscenter:(Newscenter *)newscenter didInsertNewsObject:(NewscenterObject *)newsObj atIndex:(NSUInteger)index;
///gibt an, dass damit begonnen wurde, dass Newscenter und damit seine Newscenter-Objekte zu aktualisieren
- (void)newscenterDidBeginReloading:(Newscenter *)newscenter;
///gibt an, dass die Aktualisierung des Newscenters abgeschlossen wurde
- (void)newscenterDidEndReloading:(Newscenter *)newscenter;
///gibt an, dass ein Newscenter-Objekt am gegebenen IndexPath aktualisiert wurde
- (void)newscenter:(Newscenter *)newscenter didReloadNewsObject:(NewscenterObject *)newsObj atIndex:(NSUInteger)index;
///gibt an, dass das Newscenter neugeladen werden soll
- (void)newscenterShouldStartReload:(Newscenter *)newscenter;

///gibt an, dass das Newscenter eine Verbindung zum Server hergestellt hat und dieser das Update vorbereitet
- (void)newscenterDidBeginServerUpdate:(Newscenter *)newscenter;
///gibt an, dass das Newscenter alle Daten vom Server erfolgreich erhalten und gespeichert hat oder eben, dass ein Fehler passiert ist
- (void)newscenter:(Newscenter *)newscenter didFinishServerUpdateWithError:(NSError *)error;
@end

///Die Newscenter-Klasse, die ein Newscenter bietet und gleichzeitig Methoden und Eigenschaften für seine Verwaltung implementiert.
@interface Newscenter : NSObject

#pragma mark - Returning instances
///gibt das Standard-Newscenter für die App zurück
+ (Newscenter *)defaultNewscenter;


#pragma mark - Newscenter-Aktionen
///startet die Erstellung von Newscenter-Objekten mit den Standard-Quellen (siehe Implementierung der Funktion
- (void)startCreatingNewsFromDefaultSources;

///der Aufruf dieser Methode aktualisiert das ganze Newscenter --> es lädt sich also komplett neu
- (void)reloadNewscenter;

#pragma mark - News-Infos
///gibt das Newscenter-Objekt vom Newscenter zurück, dass am gegebenen Index ist
- (NewscenterObject *)newscenterObjectAtIndex:(NSUInteger)index;
///gibt an, wieviele News im Newscenter gerade angezeigt werden
- (NSUInteger)numberOfNewsEntries;


#pragma mark - Newscenter-Infos
///gibt das Datum an, an dem das Newscenter zuletzt geupdatet wurde
@property NSDate *lastNewscenterUpdate;

///das Delegate von diesem Newscenter
@property id <NewscenterDelegate> delegate;

#pragma mark - andere Attribute des Newscenter-Objekts

///der MitteilungenController, von denen dieses Newscenter seine Mitteilungen bezieht
@property MitteilungenController *mitteilungenController;




@end
