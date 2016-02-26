//
//  KonfigurierteKurseWaehlenViewController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 30.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "KonfigurierteKurseWaehlenViewController.h"
#import "KursTableViewCell.h"

@interface KonfigurierteKurseWaehlenViewController ()

//der Fetched ResultsController, der benutzt wird, um die Kurse anzuzeigen
@property NSFetchedResultsController *fetchedResultsController;


///die Kurse, die bei der Initialisierung dieses ViewController übergeben wurden und die von Anfang an als ausgewählt angezeigt werden sollen
@property NSArray *kurseStartValues;
@end

@implementation KonfigurierteKurseWaehlenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //registriere die TableViewCell für das Nib-File
    [self.tableView registerNib:[UINib nibWithNibName:@"KursTableViewCell" bundle:nil] forCellReuseIdentifier:@"kursTableViewCell"];
    
    
    //konfiguriere den Fetched ResultsController in der ViewDidLoad-Methode
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Kurs" inManagedObjectContext:self.associatedUser.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"archiviert == NO AND user == %@ AND aktiv == YES", self.associatedUser];
    [fetchRequest setPredicate:predicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    //sortieren nach Blocknummer
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fach" ascending:YES];
    NSSortDescriptor *sortDescriptorTwo = [[NSSortDescriptor alloc] initWithKey:@"kursart" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptorTwo,sortDescriptor]];
    
    // Use the sectionIdentifier property to group into sections.
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.associatedUser.managedObjectContext sectionNameKeyPath:@"kursart" cacheName:nil]; //don't use a cache at this moment
    self.fetchedResultsController.delegate = self;
    
    //perform fetch
    NSError *fetchingError = nil;
    [self.fetchedResultsController performFetch:&fetchingError];
    
    if (fetchingError) {
        NSLog(@"Datenbank Fehler: Fehler beim Abfragen aller aktiven Kurse für einen bestimmten Benutzer");
    }
    
    
    //wenn multiple-Selection erlaubt ist, denn TableView so konfigurieren, dass mehrere Kurse ausgewählt werden können
    if (self.allowingMultipleSelection) {
        self.tableView.allowsMultipleSelection = YES;
        
        //außerdem den Titel vom abbrechen-Button auf fertig setzen
        [self.abbrechenButton setTitle:@"fertig" forState:UIControlStateNormal];
    }
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

#pragma mark Initialisierung der Objekte
- (instancetype)initWithUser:(User *)user {
    //Initialisierung vom Storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    self = [storyboard instantiateViewControllerWithIdentifier:@"konfigurierteKurseWaehlenViewController"];
    
    if (self) {
        //weitere eigene Konfigurationen
        self.associatedUser = user;
    }
    
    return self;
}

- (instancetype)initWithUser:(User *)user allowingMultipleKursSelection:(BOOL)multipleSelection andArrayOfSelectedKurse:(NSArray<Kurs *> *)kursArray {
    self = [self initWithUser:user];
    
    if (self) {
        self.allowingMultipleSelection = multipleSelection;
        self.kurseStartValues = kursArray;
    }
    
    return self;
}

#pragma mark - TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[self.fetchedResultsController sections] count];
    return count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    NSInteger count = [sectionInfo numberOfObjects];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"kursTableViewCell";
    
    KursTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[KursTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    
    //die TableViewCell konfigurieren
    Kurs *kursForTableViewCell = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.associatedKurs = kursForTableViewCell;
    cell.selectionStyle = UITableViewCellSelectionStyleNone; //den Standard-SelectionStyle konfigurieren
    
    //wenn der Kurs für die TableViewCell im kurseStartValues-Array enthalten sind, also von Anfang an als ausgewählt angezeigt werden soll, dann erreicht man das durch die folgenden Befehle (so sollte es zumindest sein 😂)
    if ([self.kurseStartValues containsObject:kursForTableViewCell]) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //deselect the other rows in the section
    
    return indexPath;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //nur wenn nicht multiple-Selection ausgewählt wurde, direkt reagieren wenn der Benutzer einen Kurs anklickt
    if (!self.allowingMultipleSelection) {
        //den Kurs für den Index-Path bekommen
        Kurs *kursForIndexPath = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        
        //das Delegate informieren
        if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishKursWaehlen:inKonfigurierteKurseWaehlenViewController:)]) {
            [self.delegate didFinishKursWaehlen:kursForIndexPath inKonfigurierteKurseWaehlenViewController:self];
        }
        
        //den Controller verbergen
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        //bei mehrfacher Auswahl ein Häkchen bei der TableViewCell anzeigen, wenn noch keins vorhanden ist, wenn ein Häkchen vorhanen ist, dann zeige kein Häkchen mehr an --> wird automatisch von der setSelected-Methode der TableViewCell übernommen
    }
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.allowingMultipleSelection) {
        //bei mehrfacher Auswahl das Häkchen beim "deselecten" wieder ausblenden
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    //ersten Kurs der Section abrufen...
    Kurs *ersterKursInSection = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
    
    //... und Kurs-Art als Section-Titel benutzen
    return [NSString stringWithFormat:@"%@", ersterKursInSection.kursartString];
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





#pragma mark - IB-Actions/user interface
- (IBAction)abbrechenButtonClicked:(UIButton *)sender {
    //beim abbrechen-Button-Click-Event unterscheiden, ob mehrfache Auswahl aktiviert wurde --> dann ist der abbrechen-Button nämlich kein Abbrechen-Button, sondern ein fertig-Button
    if (self.allowingMultipleSelection) {
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(didFinishKurseWaehlen:inKonfigurierteKurseWaehlenViewController:)]) {
                //alle Kurse für die Ausgewählten Index-Paths bekommen
                NSMutableArray *selectedKurse = [NSMutableArray new];
                
                for (NSIndexPath *indexPath in [self.tableView indexPathsForSelectedRows]) {
                    [selectedKurse addObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
                }
                
                //Die Delegate-Methoden "posten"
                [self.delegate didFinishKurseWaehlen:selectedKurse inKonfigurierteKurseWaehlenViewController:self];
            }
        }
        
    }
    else {
        //das Delegate informieren, dass kein Kurs gewählt wurde
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(didFinishKursWaehlen:inKonfigurierteKurseWaehlenViewController:)]) {
                [self.delegate didFinishKursWaehlen:nil inKonfigurierteKurseWaehlenViewController:self];
            }
        }
    }
    
    //den ViewController verbergen
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
@end
