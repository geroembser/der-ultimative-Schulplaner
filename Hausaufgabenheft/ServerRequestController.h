//
//  ServerRequestController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 07.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@class ServerRequestController;
@protocol ServerRequestControllerDelegate <NSObject>

@optional
//gibt dem Delegate an, dass ein Download-Task erfolgreich/unerfolgreich heruntergeladen wurde und enthält eventuell ein Fehler-Objekt
- (void)didFinishDownloadingDataTask:(NSURLSessionDataTask *)dataTask withData:(NSData *)downloadedData andError:(NSError *)error forServerRequest:(ServerRequestController *)serverRequestController;

@end

/**
 Diese Klasse bietet eine Vereinfachung der Server-Daten-Abfragen.
 Sie ist optimal geeignet, wenn einfache Daten (wie JSON) abgefragt werden müssen.
 Dadurch, dass sie mit einem User-verknüpft ist, kann sie jedes Mal die gleichen Prozeduren zur Anmeldung verwenden. Fehlermeldungen können einheitlich ausgegeben werden etc. 
 
 Das ist zumindest die Idee hiervon...
 ...ob das so praktisch ist und wirklich funtioniert, wird sich noch heraussstellen
 */

@interface ServerRequestController : NSObject


///erstellt einen ServerRequestController für den übergebenen Benutzer, der automatisch bei Server-Abfragen Passwort und Username des Benutzers als Parameter mit übergibt
- (instancetype)initWithUser:(User *)user;

///startet die konfigurierten Anfragen in der Standard-Session
- (void)startRequests;

///der Benutzer, für den diese Server-Abfrage durchgeführt wird
@property User *associatedUser;

//das Delegate an das die Nachrichten von dieser Session geschickt werden
//@property id delegate; //erst später vielleicht implementieren, wenn auffällt, dass es für irgendwas doch gebraucht wird


///die URL-Session die von dieser Klasse benutzt wird, um die benötigten/angeforderten Daten herunterzuladen
@property NSURLSession *urlSession;

///der Array von DataTasks die gerade mit der Session verbunden sind
@property NSMutableArray *dataTasks;

///das Delegate für eine Server-Anfrage
@property id <ServerRequestControllerDelegate> delegate;


///erstellt einen neuen Data-Task für die Anfrage und fügt sie der Standard-URL-Session für diese Klasse hinzu.
- (NSURLSessionDataTask *)dataTaskForURL:(NSURL *)requestURL withParameterDict:(NSDictionary *)parameters;

@end
