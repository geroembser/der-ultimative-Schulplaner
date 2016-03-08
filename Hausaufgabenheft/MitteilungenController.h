//
//  NachrichtenController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 07.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "User.h"

@class  MitteilungenController;

@protocol MitteilungenControllerDelegate <NSObject>

@optional
///diese Methode gibt an, dass der MitteilungenController damit begonnen hat, seine Mitteilungen zu aktualisieren
- (void)mitteilungenControllerDidBeginRefreshing:(MitteilungenController *)mitteilungenController;

///wird aufgerufen, wenn der MitteilungenController die Aktualisierung abgebrochen hat --> wenn ein Fehler aufgetreten ist, ist der letzte Parameter ungleich nil und ein NSError-Objekt
- (void)mitteilungenController:(MitteilungenController *)mitteilungenController didFinishedRefreshWithError:(NSError *)error;

@end

@interface MitteilungenController : NSObject

#pragma mark - Instanzen zurückgeben
///gibt eine Instanz des Mitteilungs-Controllers zurück, für den gegebenen User
- (instancetype)initWithUser:(User *)user;

///gibt den Standard-Controller zurück, mit dem Standard-user
+ (MitteilungenController *)defaultController;


#pragma mark - Mitteilungen Downloaden
///beginnt den Download von neuen Mitteilungen vom Server und speichert sie lokal
- (void)downloadNew;



#pragma mark - generelle Methoden (auch Hilfsmethoden für andere Objekte)
///gibt die FetchRequest für alle Mitteilungen im MitteilungsController zurück --> mit dieser FetchRequest kann ein FetchedResultsController gefüllt werden, der wiederum einen TableView füllen kann
- (NSFetchRequest *)alleMitteilungenFetchRequest;


#pragma mark - Attribute
///der User, für den dieser MitteilungenController die Mitteilungen verwaltet
@property User *user;

///das Delegate, an das dieser MitteilungenController seine Nachrichten schickt
@property id <MitteilungenControllerDelegate> delegate;

@end
