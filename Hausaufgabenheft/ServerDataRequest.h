//
//  ServerDataRequest.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 03.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>

///maybe use this class as a superclass for many controllers which will download access protected files from the server using the lernplattform-login
@interface ServerDataRequest : NSObject
@property NSString *scriptBaseURL; ///Basis-Pfad des Skripts
@property NSDictionary *paramterDict; ///Paramter die übergeben werden key = nameOfParameter , value = value of paramter

//automatisch werden dann die Zugansdaten (Benutzername und Passwort) mitabgefragt und das Delegate entsprechend informiert oder entsprechende Fehlermeldungen über allen hervorgehoben, indem ein neues Window (oder ähnlich) im AppDelegate gesetzt wird, was darauf hinweist, dass die Zugangsdaten nicht mehr aktuell sind und man diese aktualisieren muss. Bis auf weiteres bleibt die App sonst gesperrt.
@end
