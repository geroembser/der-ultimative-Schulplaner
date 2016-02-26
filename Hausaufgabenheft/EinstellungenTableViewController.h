//
//  EinstellungenTableViewController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 19.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EinstellungenTableViewController : UITableViewController

#pragma mark - Actions/Outlets zu den einzelnen Einstellungen

#pragma mark Stundenplan
///Das Label, in dem angezeigt werden soll, wann zuletzt die Daten über die verfügbaren Kurse (also wann zuletzt der Stundenplan) geupdatet wurde
@property (weak, nonatomic) IBOutlet UILabel *lastUpdateStundenplanLabel;


#pragma mark Benutzer Einstellungen
@property (weak, nonatomic) IBOutlet UILabel *nameUndStufeLabel;
@property (weak, nonatomic) IBOutlet UILabel *benutzernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *letzteServerVerbindungLabel;
@property (weak, nonatomic) IBOutlet UIButton *abmeldenButton;
- (IBAction)logoutButtonClicked:(id)sender;

@end
