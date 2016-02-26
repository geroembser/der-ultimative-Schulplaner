//
//  StundenplanViewController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 29.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Schulstunde.h"
#import "Stundenplan.h"


/**
 * Der ViewController, der den Stundenplan anzeigt.
 */
@interface StundenplanViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

#pragma mark - General properties
///der Benutzer, für den der StundenplanViewController die Stunden anzeigt
@property User *associatedUser;

///der Stundenplan, den der StundenplanViewController anzeigt
@property Stundenplan *stundenplan;

#pragma mark - General actions
///gibt den Wochentag zurück, den der ViewController gerade anzeigt bzw. setzt ihn neu
@property (nonatomic) SchulstundeWochentag aktuellAngezeigterWochentag;

///der aktuell angezeigte Wochentag als Objekt, von dem die einzelnen Stunden bezogen werden können
@property StundenplanWochentag *aktuellAngezeigterWochentagObjekt;

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UISegmentedControl *wochentagSegmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *bottomTableViewLabel;
///Das Label, in dem angezeigt werden soll, für welches Datum die Vertretungs-Stunden angezeigt werden
@property (weak, nonatomic) IBOutlet UILabel *vertretungenDateLabel;
///das Label in dem angezeigt werden soll, wann der Vertretungsplan das letzte mal aktualisiert wurde
@property (weak, nonatomic) IBOutlet UILabel *vertretungsplanLetzeAktualisierungLabel;

//gesture recognizers
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *rightSwipeGestureRecognizer;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *leftSwipeGestureRecognizer;



#pragma mark - Actions
- (IBAction)wochentagSegmentedControlValueChanged:(UISegmentedControl *)sender;

//gesture recognizers
///wird aufgerufen, wenn der Swipe-Gesture-Recognizer auf dem TableView einen Swipe nach rechts erkannt hat
- (IBAction)rightSwipeGestureRecognizer:(UISwipeGestureRecognizer *)sender;
///wird aufgerufen, wenn der Swipe-Gesture-Recognizer auf dem TableView einen Swipe nach links erkannt hat
- (IBAction)leftSwipeGestureRecognizer:(UISwipeGestureRecognizer *)sender;


@end
