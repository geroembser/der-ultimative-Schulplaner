//
//  KonfigurierteKurseWaehlenViewController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 30.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Kurs.h"

@class KonfigurierteKurseWaehlenViewController;

///Das Protokoll, das das Delegate des KonfigurierteKurseWaehlenViewControllers informiert, dass ein Kurs gewählt wurde oder nicht und wenn ein Kurs gewählt wurde, welcher Kurs gewählt wurde
@protocol KonfigurierteKurseWaehlenViewControllerDelegate <NSObject>

@optional
///informiert das Delegate darüber, dass ein Kurs gewählt wurde oder nicht; Wenn ein Kurs gewählt wurde, wird er mit der Variable gewaehlterKurs übergeben, ansonsten ist der Wert der Variable nil;
- (void)didFinishKursWaehlen:(Kurs *)gewaehlterKurs inKonfigurierteKurseWaehlenViewController:(KonfigurierteKurseWaehlenViewController *)kurseWaehlenViewController;

///informiert das Delegate darüber, dass mehrere Kurse gewählt wurden oder nicht; Wenn Kurse gewählt wurde, werden sie mit der Variable gewaehlteKurse übergeben, ansonsten ist der Wert der Variable nil;
- (void)didFinishKurseWaehlen:(NSArray <Kurs *> *)gewaehlteKurse inKonfigurierteKurseWaehlenViewController:(KonfigurierteKurseWaehlenViewController *)kurseWaehlenViewController;

@end


/**
 * der ViewController, der die konfigurierten Kurse für den Benutzer anzeigt und diese zum Auswählen darstellt
 */

@interface KonfigurierteKurseWaehlenViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

#pragma mark - User Interface
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *abbrechenButton;
- (IBAction)abbrechenButtonClicked:(UIButton *)sender;

#pragma mark - andere Methoden/Eigenschaften der Klasse deklarieren

#pragma mark Eigenschaften
///der Benutzer, für den der ViewController die Kurse anzeigen soll
@property User *associatedUser;

///gibt an, dass mehrfache Auswahl von Kursen zugelassen ist;
@property BOOL allowingMultipleSelection;

@property id <KonfigurierteKurseWaehlenViewControllerDelegate> delegate;

#pragma mark Inititalisierungen
///erstellt eine neue Instanz des ViewControllers, der alle aktiven Kurse für den gegebenen Benutzer darstellt
- (instancetype)initWithUser:(User *)user;

///erstellt eine neue Instanz des ViewControllers, der alle aktiven Kurse für den gegebenen Benutzer darstellt und das Mehrfache Auswählen von Kursen erlaubt. Die Kurse, die als ausgewählt angezeigt werden sollen, wenn der ViewController geladen wird, werden im kursArray übergeben
- (instancetype)initWithUser:(User *)user allowingMultipleKursSelection:(BOOL)multipleSelection andArrayOfSelectedKurse:(NSArray <Kurs *> *)kursArray;


@end
