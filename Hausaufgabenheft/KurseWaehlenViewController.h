//
//  KurseWaehlenViewController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 29.11.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

/**
 Dieser ViewController soll die Anzeige und Interaktion mit dem Benutzer bei der Auswahl/Konfiguration der einzelnen Kurse kontrollieren.
 */

@interface KurseWaehlenViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> //die Protokolle für den TableView implementieren (wir benötigen DataSource und Delegate)

#pragma mark - Methoden
#pragma mark Initialisierungsmethoden
///weist dem Controller den übergebenen Benutzer zu und soll später durch weitere Methodenaufrufe den Studenplan für den bestimmten Lehrer herunterladen
- (instancetype)initWithUser:(User *)user;


#pragma mark - UI-Objects (outlets)
///TableView, der die Anzeige der Kurse kontrolliert
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *downloadWorkingIndicatorLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *downloadWorkingActivityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *speichernButton;
@property (weak, nonatomic) IBOutlet UILabel *tableViewBottomLabel;

#pragma mark - UI-Objects (actions)
- (IBAction)speichernButtonClicked:(UIButton *)sender;


#pragma mark - User Interface Methods
///zeigt einen Download-Indikator an
- (void)showDownloadIndicator;
///blendet einen Download-Indikator aus
- (void)hideDownloadIndicator;


#pragma mark - Properties
///der Benutzer, für den der KurseWaehlenViewController die Kurse kontrolliert
@property User *associatedUser;

///wenn auf YES gesetzt, löst der Controller bei seiner Anzeige auf dem user interface die Aktualisierung der Kurse, also des Stundenplans aus
@property BOOL shouldStartKurseUpdate;

@end
