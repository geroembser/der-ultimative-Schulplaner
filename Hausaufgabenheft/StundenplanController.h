//
//  StundenplanController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 10.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Kurs.h"
#import "Lehrer.h"
#import "Raum.h"
#import "ServerRequestController.h"

@class StundenplanController;
@protocol StundenplanControllerDelegate <NSObject>

@optional
///informiert das Delegate darüber, dass die Stundenplan-Aktualisierung für den gegebenen StundenplanController begonnen hat
- (void)didBeginStundenplanAktualsierungForStundenplanController:(StundenplanController *)stundenplanController;

///informiert das Delegate darüber, dass der StundenplanController den Stundenplan erfolgreich bzw. nicht erfolgreich heruntergeladen hat
- (void)didFinishStundenplanAktualisierungInStundenplanController:(StundenplanController *)stundenplanContorller withError:(NSError *)error;

@end

@interface StundenplanController : NSObject <ServerRequestControllerDelegate>

///erstellt einen neuen StundenplanController für den gegebenen Benutzer
- (instancetype)initWithUser:(User *)user;

///aktualisiert den Stundenplan von dem Benutzer, mit dem der StundenplanController initialisiert wurde
- (void)aktualisiereStundenplan;

///lädt den Stundenplan, die Lehrerliste, die Kursliste etc. (also alles, was für das korrektre Funktionieren der Stundenplan-Funktion nötig ist) für den Benutzer herunter und ersetzt alte Daten entsprechend der Implementierung
- (void)downloadStundenplanDatenForUser;


///löscht alle Schulstunden für den Benutzer des StundenplanControllers
- (void)loescheStundenFuerBenutzer;

///der User, für den der StundenplanController den Stundenplan verwaltet
@property User *associatedUser;

///das Delegate für den StundenplanController
@property id <StundenplanControllerDelegate> delegate;

///alle Studen für den Benutzer des StundenplanControllers
- (NSArray *)alleStunden;
- (NSArray *)alleStundenFuerLehrer:(Lehrer *)lehrer;
- (NSArray *)alleStundenFuerKurs:(Kurs *)kurs;
- (NSArray *)alleStundenFuerWochentag:(int)wochentag;
- (NSArray *)alleStundenImRaum:(Raum *)raum;


@end
