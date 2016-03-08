//
//  AufgabenOverviewViewController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 30.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "AufgabenOverviewViewController.h"
#import "AufgabeEditViewController.h"
#import "AufgabeTableViewCell.h"
#import "AufgabenFilterPrefViewController.h"
#import "AufgabeFilter.h"

@interface AufgabenOverviewViewController () <NSFetchedResultsControllerDelegate>
///der FetchedResultsController, der die Anzeige der Aufgaben koordiniert
@property NSFetchedResultsController *fetchedResultsController;

///der aktuelle Filter, der für den TableView benutzt wird
@property AufgabeFilter *currentFilter;
@end

@implementation AufgabenOverviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //register the tableViewCell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"AufgabeTableViewCell" bundle:nil] forCellReuseIdentifier:@"aufgabeTableViewCell"];
    
    
    
    
    
    
    //den Filter für die Standard-Fetch-Request erstellen, bzw. irgendwann einmal den letzen Filter nehmen
    AufgabeFilter *filter = [self standardFilter];
    
    //mit diesem Filter den TableView neuladen
    [self reloadTableViewDataWithFilter:filter];
    
    
    //registriere die Notification, die angibt, dass sich Filter geändert haben
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(filterDidChange:) name:AufgabenNotificationNeuerFilterGesetzt object:nil];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IB-Actions

///Die Action, die ausgeführt wird, wenn ein Button angetippt wurde, mit dem ein neue Aufgabe erstellt werden soll bzw. der ViewController, der das übernehmen soll, angezeigt wird.
- (IBAction)neueAufgabeButtonClicked:(UIButton *)sender {
    
    //eine neue Instanz davon erstellen
    AufgabeEditViewController *neueAufgabeViewController = [[AufgabeEditViewController alloc]init];
    
    //den ViewController anzeigen
    [self presentViewController:neueAufgabeViewController animated:YES completion:nil];
    
}

//zeigt einen ViewController an, der zum Einstellen der Filter und des Sortieren benutzt werden kann
- (IBAction)filterSortDetail:(id)sender {
    AufgabenFilterPrefViewController *filterSortVC = [[AufgabenFilterPrefViewController alloc]initWithFilter:self.currentFilter];
    
    [self presentViewController:filterSortVC animated:YES completion:nil];
}


#pragma mark - TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    NSInteger count = [[self.fetchedResultsController sections] count];
    
    //wenn keine Sections vorhanden sind, aktualisiere das TableViewBottomLabel auch entsprechend
    if (count == 0) {
        [self setTableViewBottomLabelAufgabenAnzahl:0 withAnzahlErledigterAufgaben:0];
    }
    
    return count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    NSInteger count = [sectionInfo numberOfObjects];
    
    //Die Anzahl der Aufgaben und der davon erledigten im tableViewCellBottomLabel darstellen. (die erledigten Aufgaben sind die in der zweiten Section)
    NSUInteger erledigteAufgaben = 0;
    
 
    
    //finde die Section, die die erledigten Aufgaben darstellt und nehme den Count der Objekte in der Sektion
    for (id <NSFetchedResultsSectionInfo> sectionInfo in self.fetchedResultsController.sections) {
        //die Section, deren indexTitle gleich "1" (für erledigt == YES --> Siehe Konfiguration des FetchedResultsControllers mit sectionNameKeyPath) ist
        if ([[sectionInfo indexTitle] isEqualToString:@"1"]) {
            erledigteAufgaben = [sectionInfo numberOfObjects];
        }
    }
    
    [self setTableViewBottomLabelAufgabenAnzahl:self.fetchedResultsController.fetchedObjects.count withAnzahlErledigterAufgaben:erledigteAufgaben];
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"aufgabeTableViewCell";
    
    AufgabeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[AufgabeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //die TableViewCell konfigurieren
    Aufgabe *aufgabeForCell = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.aufgabe = aufgabeForCell;
    
    NSLog(@"%@", aufgabeForCell.abgabeDatum);
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //deselect the other rows in the section
    
    return indexPath;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //die Aufgabe für den Index-Path bekommen
    Aufgabe *aufgabeForIndexPath = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //eine neue Instanz davon erstellen
    AufgabeEditViewController *neueAufgabeViewController = [[AufgabeEditViewController alloc]initWithAufgabe:aufgabeForIndexPath];
    
    //den ViewController anzeigen
    [self presentViewController:neueAufgabeViewController animated:YES completion:nil];
    
    //deselect the row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {

    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 61;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    //erste Aufgabe der Section bekommen
    Aufgabe *ersteAufgabeAusSection = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];

    //... und anhand dessen "erledigt"-Property entscheiden, ob die Aufgaben erledigt wurden
    BOOL erledigt = ersteAufgabeAusSection.erledigt.boolValue;
    
    
    return [NSString stringWithFormat:@"%@", erledigt ? @"erledigt" : @"ausstehend"];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
//folgende Methode wird benötigt, damit man Aufgaben mit einem Swipe nach links löschen kann
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //einen AlertConroller anzeigen, der danach fragt, ob wirklich die Aufgabe gelöscht werden soll
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Fortfahren?" message:@"Möchtest du diese Aufgabe wirklich löschen? Das ist unwiederbringlich..." preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Nein, abbrechen" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"löschen" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        Aufgabe *aufgabeForCell = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [aufgabeForCell loeschen];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - TableView Helper-Methods
- (void)setTableViewBottomLabelAufgabenAnzahl:(NSUInteger)aufgaben withAnzahlErledigterAufgaben:(NSUInteger)erledigt {
    
    self.tableViewBottomLabel.text = [NSString stringWithFormat:@"Aufgaben: %lu, erledigt: %lu", aufgaben, erledigt];
    
    //gleichzeitig auch das Badge im TabbarController setzten
    NSUInteger ausstehendeAufgaben = aufgaben-erledigt;
    if (ausstehendeAufgaben <= 0) {
        self.tabBarItem.badgeValue = nil;
    }
    else {
        self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu", aufgaben-erledigt];
    }
}

#pragma mark - TableView-ScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //beim Scrollen, die Tastatur ausblenden --> dafür also den FirstResponder von der SearchBar entziehen
    [self.searchBar resignFirstResponder];
}

#pragma mark - FRC Delegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                     withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                     withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default: return;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


#pragma mark - Filtering Content
///gibt den Standard-Filter zurück
- (AufgabeFilter *)standardFilter {
    AufgabeFilter *filter = [AufgabeFilter new];
    
    filter.ausstehendeZuerst = YES;
    filter.erledigteZuerst = NO;
    filter.erledigteAnzeigen = YES;
    
    return filter;
}

///sollte vom NotificationCenter aufgerufen werden, wenn die Filter-Notfication gepostet wurde (die also angibt, dass sich der Filter für die Aufgaben geändert hat)
- (void)filterDidChange:(NSNotification *)notification {
    
    //das Filter-Objekt, nach dem gefiltert werden soll, aus der user-info-dictionary heraussuchen
    NSDictionary *userInfo = [notification userInfo];
    AufgabeFilter *filter = [userInfo objectForKey:AufgabenNotificationInfoDictFilterObjectKey];
    
    if (!filter) {
        filter = [self standardFilter]; // wenn kein Filter gegeben ist, nehme den Standard-Filter (was einem zurücksetzen des Filters gleichkommen sollte)
    }
    
    if (filter) {
        [self reloadTableViewDataWithFilter:filter];
    }
    
}

///lädt die Daten im TableView und damit im FetchedResultsController mit dem gegebenen Filter neu
- (void)reloadTableViewDataWithFilter:(AufgabeFilter *)filter {
    if (filter) {
        //dann eine Fetch-Request für den Filter erstellen
        NSFetchRequest *fetchRequest = [self fetchRequestForFilter:filter];
        
        //setze den Wert der currentFilter-Variable auf den gegebenen Filter
        self.currentFilter = filter;
        
        //den TableView mit einer Request und einem Section Key-Path neuladen
        [self reloadTableViewDataWithFetchRequest:fetchRequest andSectionKeyPath:@"erledigt"];
        
        
    }
}

///lädt die Daten im TableView mit der gegebenen FetchRequest und dem gegebenen sectionKeyPath neu, indem der FetchedResultsController neugeladen wird
- (void)reloadTableViewDataWithFetchRequest:(NSFetchRequest *)fetchRequest andSectionKeyPath:(NSString *)sectionKeyPath {
    //User ist der DefaultUser
    User *user = [User defaultUser];
    
    // Use the sectionIdentifier property to group into sections.
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:user.managedObjectContext sectionNameKeyPath:@"erledigt" cacheName:nil]; //don't use a cache at this moment
    self.fetchedResultsController.delegate = self;
    
    //perform fetch
    NSError *fetchingError = nil;
    [self.fetchedResultsController performFetch:&fetchingError];
    
    if (fetchingError) {
        NSLog(@"Datenbank Fehler: Fehler beim Abfragen aller Aufgaben für einen bestimmten Benutzer");
    }
    
    [self.tableView reloadData];
}

///gibt eine FetchRequest für den gegebenen Filter zurück
- (NSFetchRequest *)fetchRequestForFilter:(AufgabeFilter *)filter {
    if (filter) {
        //User ist der DefaultUser
        User *user = [User defaultUser];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Aufgabe" inManagedObjectContext:user.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        ///das NSPredicate konfigurieren
        NSMutableArray *predicates = [NSMutableArray new];
        
        NSPredicate *basePredicate = [NSPredicate predicateWithFormat:@"user == %@", user];
        [predicates addObject:basePredicate];
        
        if (filter.erledigteAnzeigen == NO) {
            [predicates addObject:[NSPredicate predicateWithFormat:@"erledigt == NO"]];
        }
        
        if (filter.bisDate) {
            [predicates addObject:[NSPredicate predicateWithFormat:@"abgabeDatum <= %@", filter.bisDate]];
        }
        if (filter.vonDate) {
            [predicates addObject:[NSPredicate predicateWithFormat:@"abgabeDatum >= %@", filter.vonDate]];
        }
        
        if (filter.anzuzeigendeKurse && filter.anzuzeigendeKurse.count >= 1) {
            [predicates addObject:[NSPredicate predicateWithFormat:@"kurs IN %@", filter.anzuzeigendeKurse]];
        }
        
        //für die Suche wichtig (Filter-searchString)
        if (filter.searchString && filter.searchString.length > 0) {
            NSPredicate *titelPredicate = [NSPredicate predicateWithFormat:@"titel CONTAINS[cd] %@", filter.searchString];
            
            NSPredicate *beschreibungPredicate = [NSPredicate predicateWithFormat:@"beschreibung LIKE %@", filter.searchString];
            
            [predicates addObject:[NSCompoundPredicate orPredicateWithSubpredicates:@[titelPredicate, beschreibungPredicate]]];
            
            
        }
        
        
        NSPredicate *combinedPredicates = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        
        [fetchRequest setPredicate:combinedPredicates];
        
        // Set the batch size to a suitable number.
        [fetchRequest setFetchBatchSize:20];
        
        NSMutableArray *sortDescriptors = [NSMutableArray new];
        
        //erledigte zuerst oder später
        [sortDescriptors addObject:[[NSSortDescriptor alloc] initWithKey:@"erledigt" ascending:!filter.erledigteZuerst]];
        
        //alphabetische Sortierung
        if (filter.sortAlphabetically) {
            [sortDescriptors addObject:[[NSSortDescriptor alloc]initWithKey:@"titel" ascending:YES]];
        }
        
        [sortDescriptors addObject:[[NSSortDescriptor alloc] initWithKey:@"abgabeDatum" ascending:filter.ausstehendeZuerst]];
        
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        return fetchRequest;
    }
    return nil;
}

#pragma mark - Searching the Content
#pragma mark UISearchBarDelegate


//Das Durchsuchen der Aufgaben wird implementiert, indem der Filter so modifiziert wird, dass er Suchtexte berücksichtigt (weil eine Suche ja eigentlich nichts anderes als ein Filter ist, war das der Gedanke bei dieser Implementierung - ist wesentlich einfacher und schneller und wahrscheinlich auch einfacher zu warten....)
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    //starte die Such mit dem gegebenen Suchtext (bzw. wenn kein Suchtext vorhanden wird, wird der Suchtext vom Filter auf den Suchtext der SearchBar gesetzt, was einem Reset der Suche gleichkommen sollte.
    
    //ändere den Suchtext vom aktuellen Filter
    self.currentFilter.searchString = searchText;
    
    //lade den TableView mit dem geänderten Filter neu
    [self reloadTableViewDataWithFilter:self.currentFilter];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}



@end
