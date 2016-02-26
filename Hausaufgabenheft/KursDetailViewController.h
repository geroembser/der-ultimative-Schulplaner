//
//  KursDetailViewController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 19.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Kurs.h"

/**
 * Dieser ViewController zeigt die Details (bzw. später vielleicht einmal) die Einstellungen für einen Kurs
 */
@interface KursDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

#pragma mark - Inititialisierung
///initialisert den KursDetailViewController mit einem Kurs
- (instancetype)initWithKurs:(Kurs *)kurs;


#pragma mark - Einstellungen/Properties
///der Kurs für den dieser Controller die Details bzw. Einstellungen darstellt
@property Kurs *associatedKurs;

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UILabel *kursNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *lehrerNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *writeEmailButton;
@property (weak, nonatomic) IBOutlet UIButton *goToAufgabenButon;
@property (weak, nonatomic) IBOutlet UITableView *stundenTableView;
@property (weak, nonatomic) IBOutlet UISwitch *isActiveSwitch;
@property (weak, nonatomic) IBOutlet UILabel *isActiveLabel;
@property (weak, nonatomic) IBOutlet UILabel *zuletztGeaendertLabel;

#pragma mark - Actions
- (IBAction)closeButtonClicked:(id)sender;
- (IBAction)startWritingEmail:(id)sender;
- (IBAction)goToAufgabenForKurs:(id)sender;

@end
