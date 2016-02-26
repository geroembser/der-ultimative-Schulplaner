//
//  AufgabenFilterPrefViewController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 20.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AufgabeFilter.h"

//Konstanten deklarieren für das Filtern und Sortieren,
///Die Konstante für die Notification, die angibt, dass ein neuer Filter gesetzt wurde
static NSString *const AufgabenNotificationNeuerFilterGesetzt = @"neuerFilterGesetztNotification";
///für diesen Key sollte aus der User-Info-Dictionary der AufgabenNotificationNeuerFilterGesetzt-Notification das Filter-Objekt zurückgegeben werden
static NSString *const AufgabenNotificationInfoDictFilterObjectKey = @"aufgabenFilterFilterObject";


///Ein ViewController, der ein user interface für die Filterung und Sortierung von Aufgaben bietet. Ziel ist es, dass dieser ViewController entsprechend der User-Eingaben Nachrichten verschickt, die an anderen Stellen des Programms empfangen werden und auf die dann dort reagiert wird --> zum Beispiel mit einer Filterung der Daten
@interface AufgabenFilterPrefViewController : UIViewController <UITextFieldDelegate>


#pragma mark - Initialization
///erstellt einen neuen AufgabenFilterPrefViewController, der entsprechende Nachrichten verschickt, die an anderen Stellen des Programms dazu verwendet werden können, Aufgaben entsprechend zu filtern. Wenn ein Filter vorhanden ist, wird dieser AufgabenFilterPrefViewController so angezeigt, dass er die Einstellungen dem Filter entsprechend anzeigt
- (instancetype)initWithFilter:(AufgabeFilter *)filter;

#pragma mark - Properties
/// der Filter, der gerade angezeigt wird bzw. mit dem der AufgabenFilterPrefViewController initialisiert wurde
@property AufgabeFilter *currentFilter;

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *eigentlicherFilterView;
@property (weak, nonatomic) IBOutlet UISwitch *erledigteAnzeigenSwitch;
@property (weak, nonatomic) IBOutlet UIButton *fachFilterButton;
@property (weak, nonatomic) IBOutlet UITextField *vonDateTextfeld;
@property (weak, nonatomic) IBOutlet UITextField *bisDateTextfeld;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sortSegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *anwendenButton;


#pragma mark - Actions
///wendet die Filter an bzw. verschickt entsprechende Nachrichten
- (IBAction)anwenden:(id)sender;
///setzt den Filter zurück, postet also nil als Filter
- (IBAction)zuruecksetzen:(id)sender;
///wird aufgerufen, wenn auf den Button, welcher die Auswahl der Kurse anzeigen soll, angeklickt wurde
- (IBAction)showKursSelection:(id)sender;

///soll den filter-view-controller wieder ausblenden, wenn auf den Hintergrund gedrückt bzw. getippt wurde
- (IBAction)backgroundTapGestureRecognizerTapped:(id)sender;

@end
