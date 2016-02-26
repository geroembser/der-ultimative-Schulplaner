//
//  AufgabenOverviewViewController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 30.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AufgabenOverviewViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

#pragma mark - IB-Outlets
/* neue Aufgabe erstellen - Buttons */
///der Button, der den Text "neue Aufgabe" anzeigt
@property (weak, nonatomic) IBOutlet UIButton *neueAufgabeTextButton;
///der Button der im Stil des "Add-Contact"-Buttons ein "Hinzufügen"-Icon anzeigt
@property (weak, nonatomic) IBOutlet UIButton *neueAufgabeIconButton;
///die SearchBar
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
///der Sortieren-/Filtern-Button
@property (weak, nonatomic) IBOutlet UIButton *filterSortButton;

/* TableView */
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *tableViewBottomLabel;


#pragma mark - IB-Actions
/* neue Aufgaben - Action */
- (IBAction)neueAufgabeButtonClicked:(UIButton *)sender;

///zeigt einen ViewController zum Filtern/zum Sortieren der Aufgaben an
- (IBAction)filterSortDetail:(id)sender;


@end
