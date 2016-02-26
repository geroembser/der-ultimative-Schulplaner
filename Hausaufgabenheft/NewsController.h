//
//  NewsController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 06.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"


typedef enum {
    ///der Typ für den NewsController, der festlegt, dass die letzten Post nach Datum sortiert zurückgegeben werden sollen
    newsControllerTypeRecentPosts = 0, ///der Typ für den NewsController der festlegt, dass die Posts mit der höchsten Relevanz für die Tags des Users angezeigt werden sollen
    newsControllerTypeUserTags = 1
} NewsControllerType;


@class NewsController;
@class News;

@protocol NewsControllerDelegate <NSObject>

@optional

///wird aufgerufen, wenn damit begonnen wurde, die News im NewsController zu aktualisieren
- (void)didBeginRefreshingNewsInNewsController:(NewsController *)newsController;
///wird aufgerufen, wenn die Aktualisierung aller TableViewCells abgeschlossen ist
- (void)didEndRefreshingNewsInNewsController:(NewsController *)newsController;
///Wird aufgerufen, wenn der Download von News begonnen hat.
- (void)didBeginDownloadingNewsInNewsController:(NewsController *)newsController;
///Wird aufgerufen, wenn der Download von News abgeschlossen ist. Eventuell enthält es einen Fehler.
- (void)newsController:(NewsController *)newsController didFinishDownloadingNewsWithError:(NSError *)error;

///wird aufgerufen, wenn ein News-Objekt am gegebenen Index aktualisiert wurde (zum Beipsiel das Preview-Image heruntergeladen wurde)
- (void)newsController:(NewsController *)newsController didRefreshNewsObject:(News *)newsObj atIndex:(NSUInteger)index;
///wird aufgerufen, wenn ein neues News-Objekt an dem gegebenen Index hinzugefügt wurde
- (void)newsController:(NewsController *)newsController didInsertObject:(News *)newObj atIndex:(NSUInteger)index;
///wird aufgerufen, wenn ein News-Objekt gelöscht wurde
- (void)newsController:(NewsController *)newsController didRemoveObject:(News *)newObj atIndex:(NSUInteger)index;
@end

@interface NewsController : NSObject

#pragma mark - Properties
///das Delegate des NewsControllers
@property id <NewsControllerDelegate> delegate;

///der Typ des NewsControllers
@property NewsControllerType type;

///der Array von News-Objekten, die aktuell für den NewsController verfügbar sind
@property NSMutableArray *news;

////////////Die Einstellungen, die für den NewsController der die News nach Relevanz für den Benutzer sortiert, wichtig sind
@property NewsController *parentNewsController;
@property NewsController *childNewsController;

///der Benutzer, für den die News nach Relevanz sortiert werden sollen
@property User *associatedUser;

////////////Die Seiten, die vom JSON-API für WordPress zurückgegeben werden

///der Index der Seite, die gerade gedownloaded wird
@property NSUInteger page;
///die  Anzahl der verfügbaren Seiten
@property NSUInteger pagesCount;
///die Anzahl der verfügbaren Artikel für die aktuelle News-Anfrage
@property NSUInteger articleCount;
///die Anzahl der Artikel, die pro Seite heruntergeladen werden sollen
@property NSUInteger articlesPerSite;
///gibt an, ob die nächste Seite heruntergeladen werden kann, weil die eine Seite fertig geladen ist
@property BOOL canStartDownloadNextSite;

#pragma mark - Methoden
///startet den Download der News --> über Änderungen, Fehler etc. wird das Delegate informiert
- (void)startNewsDownload;

///lädt die nächste Seite herunter, wenn gerade keine Seite heruntergeladen wird
- (void)loadNextPage;

///gibt an, ob noch weitere Seiten verfügbar sind, die heruntergeladen werden können
- (BOOL)hasMorePagesToLoad;

///aktualisiert alle Daten und startet bei Seite 1 mit dem ersten Eintrag
- (void)reload;

///sortiert die News im parentNewsController user-spezifisch
- (void)userSpecificSortNewsOfParentNewsController;

#pragma mark - Initialisierung
///initialisiert einen neuen NewsController mit dem übergebenen NewsControllerType
- (instancetype)initWithNewsControllerType:(NewsControllerType)type;
///initialisiert den NewsController mit einem parentNewsController, von dem der neu initialisierte NewsController seine Nachrichten bezieht --> ist besonders praktisch, um den NewsController, der die News auf Basis der individuellen Einstellungen des Benutzers sortiert, mit den News von den letzen Tagen etc. zu initialisieren
- (instancetype)initWithParentNewsController:(NewsController *)parentNewsController;

@end
