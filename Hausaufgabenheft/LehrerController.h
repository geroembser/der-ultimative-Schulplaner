//
//  LehrerController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 21.11.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

/**
 * diese Klasse soll die Daten von den Lehrerinnen und Lehrern verwalten
 */


#import <Foundation/Foundation.h>
#import "User.h"
#import "ServerRequestController.h"

@class LehrerController;
@protocol LehrerControllerDelegate <NSObject>

@optional
///wird aufgerufen, wenn der Vorgang begonnen hat, Lehrer-Daten herunterzuladen
- (void)didBeginDownloadingTeacherDataInLehrerController:(LehrerController *)lehrerController;

///wird aufgerufen, wenn der Download der Lehrer-Daten abgeschlossen wurde - entweder mit Fehler oder ohne
- (void)didFinishDownloadingTeacherDataInLehrerController:(LehrerController *)lehrerController withError:(NSError *)error;

@end

@interface LehrerController : NSObject <ServerRequestControllerDelegate>


///der Benutzer, für den der LehrerController die Lehrer verwaltet
@property User *associatedUser;

///das Delegate, an das die Nachrichten geschickt werden sollen
@property id <LehrerControllerDelegate> delegate;


/**
 einen LehrerController erstellen, indem man den übergebenen User als Ausgangspunkt nimmt
 @param User: der Benutzer, für den die Klasse die Lehrer verwalten soll
 @returns instancetype
 */
- (instancetype)initWithUser:(User *)user;
/**
 eine Standardinstanz vom LehrerController
 @param nil
 @returns LehrerController eine Standardinstanz
 @exception nil
 */
+ (LehrerController *)defaultController;

/**
 Aktualisiert die Lehrerdaten in der Core-Data-Datenbank
 @param nil
 @returns nil
 @exception nil
 */
- (void)refreshTeacherData;




@end
