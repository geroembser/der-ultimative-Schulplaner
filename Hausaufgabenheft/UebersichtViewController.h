//
//  UebersichtViewController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 29.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * der Haupt-ViewController, der beim App Start angezeigt werden soll
 */
@interface UebersichtViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

#pragma mark - Outlets
#pragma mark nächste Stunde
@property (weak, nonatomic) IBOutlet UIView *naechsteStundeContainer;
@property (weak, nonatomic) IBOutlet UILabel *naechsteStundeFachNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *naechsteStundeLehrerLabel;
@property (weak, nonatomic) IBOutlet UILabel *naechsteStundeRaumLabel;
@property (weak, nonatomic) IBOutlet UIButton *zumStundenplanButton;
@property (weak, nonatomic) IBOutlet UILabel *naechsteStundeUeberschriftLabel;

#pragma mark - Newscenter
@property (weak, nonatomic) IBOutlet UITableView *newscenterTableView;
@property (weak, nonatomic) IBOutlet UILabel *newscenterLastUpdateLabel;


#pragma mark - Actions
#pragma mark - nächste Stunde
- (IBAction)zumStundenplanGehen:(id)sender;




#pragma mark - Properties

#pragma mark - Methoden


@end
