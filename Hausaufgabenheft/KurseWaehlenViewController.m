//
//  KurseWaehlenViewController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 29.11.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "KurseWaehlenViewController.h"
#import "KurseController.h"
#import "StundenplanController.h"
#import "KursWaehlenTableViewCell.h"
#import "FinishedSetupViewController.h"

@interface KurseWaehlenViewController () <KurseControllerDelegate, NSFetchedResultsControllerDelegate, StundenplanControllerDelegate>
@property NSFetchedResultsController *fetchedResultsController;
@end

@implementation KurseWaehlenViewController

#pragma mark - Default Methods
- (void)viewDidLoad {
    [super viewDidLoad];

    //fetchController initialisieren und Sections anhand von Blocknummer erstellen/sortieren (wenn das erste mal geöffnet oder noch nicht angemeldet: dann sollten keine Kurse in der Datenbank stehen
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Kurs" inManagedObjectContext:self.associatedUser.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"archiviert == NO AND user == %@", self.associatedUser];
    [fetchRequest setPredicate:predicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    //sortieren nach Blocknummer
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fach" ascending:YES];
    NSSortDescriptor *sortDescriptorTwo = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor,sortDescriptorTwo]];
    
    // Use the sectionIdentifier property to group into sections.
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.associatedUser.managedObjectContext sectionNameKeyPath:@"fach" cacheName:nil]; //don't use a cache at this moment
    self.fetchedResultsController.delegate = self;
    
    //perform fetch
    NSError *fetchingError = nil;
    [self.fetchedResultsController performFetch:&fetchingError];
    
    if (fetchingError) {
        NSLog(@"Datenbank Fehler: Fehler beim Abfragen aller Kurse für einen bestimmten Benutzer");
        [self showErrorMessage:@"Schwerer Fehler. Bitte wenden Sie sich an den Administrator"];
    }
    
    
    //table view configuration
    [self.tableView setAllowsMultipleSelection:YES]; ///mehrfaches Auswählen aktivieren, damit man mehrere Kurse auswählen kann
}

//erst in der ViewDidAppear Methode den Download und die Verarbeitung vom heruntergeladenen starten, damit keine unschönen Blockierungen des user Interfaces während der Übergangsanimation zu diesem ViewController entstehen
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //nur den Stundenplan downloaden, wenn die entsprechende Property auch auf YES gesetzt ist
    if (self.shouldStartKurseUpdate) {
        //den Download-Indicator anzeigen
        [self showDownloadIndicator];
        
        //hier starten, die Daten vom Server für den entsprechenden User herunterzuladen
        StundenplanController *stundenplanController = [[StundenplanController alloc]initWithUser:self.associatedUser];
        
        //starte den Download von den Stundenplänen
        [stundenplanController downloadStundenplanDatenForUser];
        stundenplanController.delegate = self;
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

#pragma mark - Initialisierung

- (instancetype)init {
    //Initialisierung vom Storyboard
    self = (KurseWaehlenViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"kurseWaehlenViewController"];
    
    if (self) {
        //weitere eigene (Standard-)Initialisierungen
        
    }
    return self;
}

///initialisiert den ViewController und verbindet ihn mit dem übergebenen User
- (instancetype)initWithUser:(User *)user {
    
    self = [self init];
    
    if (self) {
        self.associatedUser = user;
    }
    
    return self;
}


#pragma mark - TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count;
    
    //wenn für den Benutzer keine gültigen Daten vorliegen, dann zeige keine Kurse an...
    if (![self.associatedUser hasValidData]) {
        count = 0;
    }
    else {
        count = [[self.fetchedResultsController sections] count];
    }
    
    //wenn count == 0 --> dann deaktiviere den Speichern-Button
    if (count == 0) {
        self.speichernButton.enabled = NO;
    }
    else {
        self.speichernButton.enabled = YES;
    }
    
    return count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Die Gesamtanzahl der Kurse im TableView Bottom Label setzen
    [self setTableViewBottomLabelNumberOfKurse:self.fetchedResultsController.fetchedObjects.count withNumberOfSelectedKurse:tableView.indexPathsForSelectedRows.count];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    NSInteger count = [sectionInfo numberOfObjects];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"kursWaehlenTableViewCell";
    
    KursWaehlenTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[KursWaehlenTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //die TableViewCell konfigurieren
    Kurs *kursForTableViewCell = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.associatedKurs = kursForTableViewCell;
    
    //wenn der Kurs für die TableViewCell aktiv ist, dann das entprechend anzeigen
    if (kursForTableViewCell.aktiv.boolValue) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //deselect the other rows in the section
    
    return indexPath;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //den Kurs für den Index-Path auf aktiv setzen
    Kurs *kursForIndexPath = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    kursForIndexPath.aktiv = [NSNumber numberWithBool:YES];
    
    //Die Gesamtanzahl der Kurse im TableView Bottom Label setzen
    [self setTableViewBottomLabelNumberOfKurse:self.fetchedResultsController.fetchedObjects.count withNumberOfSelectedKurse:tableView.indexPathsForSelectedRows.count];
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    //den Kurs für den Index-Path auf inaktiv setzen
    Kurs *kursForIndexPath = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    kursForIndexPath.aktiv = [NSNumber numberWithBool:NO];
    
    //Die Gesamtanzahl der Kurse im TableView Bottom Label setzen
    [self setTableViewBottomLabelNumberOfKurse:self.fetchedResultsController.fetchedObjects.count withNumberOfSelectedKurse:tableView.indexPathsForSelectedRows.count];

}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    //ersten Kurs der Section abrufen...
    Kurs *ersterKursInSection = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];    
    
    //... und dessen Fach als Titel benutzen
    return [NSString stringWithFormat:@"%@", ersterKursInSection.fach];
}


#pragma mark - TableView Helper-Methods
- (void)setTableViewBottomLabelNumberOfKurse:(NSUInteger)numberOfKurse withNumberOfSelectedKurse:(NSUInteger)numberOfSelectedKurse {
    self.tableViewBottomLabel.text = [NSString stringWithFormat:@"%lu Kurse, %lu ausgewählt", numberOfKurse, numberOfSelectedKurse];
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
            //die TableViewCells nicht reloaden, weil nicht damit zu rechnen ist, dass sich die Kurse ändern (wenn man die TableViewCells immer neuladen würde, dann würde es beim Auswählen einer Cell zu unschönen Animationen im user interface kommen, weil die DidSelectRow-Methode die Cell auswählt und diese Methode die Cell nochmal neu auswählt, indem es sie neulädt...)
            //[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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

#pragma mark - Download/Stundenplan Delegate
- (void)didBeginStundenplanAktualsierungForStundenplanController:(StundenplanController *)stundenplanController {
    [self showDownloadIndicator];
}

- (void)didFinishStundenplanAktualisierungInStundenplanController:(StundenplanController *)stundenplanContorller withError:(NSError *)error {
    //im Main Thread ausführen
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self hideDownloadIndicator];
        
        //zeige eine Fehler Meldung an, wenn ein Fehler mit übergeben wurde
        if (error) {
            [self showErrorMessage:error.localizedDescription];
            
            //nichts im TableView anzeigen
            
            //#todo ...
        }
        
    });
}

///Methode, die eine Fehlermeldung während/nach dem Herunterladen ausgibt
- (void)showErrorMessage:(NSString *)errorMessage {
    if (!errorMessage) {
        //dann benutze eine Standardfehlermeldung
        errorMessage = @"Bitte wenden Sie sich an den Administrator!";
    }
    
    //mithilfe eines UIAlertController
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Fehler" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Download Interface-Methods
//hier kommen die meisten Methoden hin, die irgendwie das User interface während des Downloads bzw. vor und danach aktualisieren



- (void)hideDownloadIndicator {
    //die Animation des ActivityIndicators stoppen
    [self.downloadWorkingActivityIndicator stopAnimating];
    //den ActivityIndicator an sich wieder ausblenden
    self.downloadWorkingActivityIndicator.hidden = YES;
    //das Label wieder ausblenden
    self.downloadWorkingIndicatorLabel.hidden = YES;
    
    //den TableView wieder einblenden (also über das downloadWorkingIndicatorLabel legen)
    self.tableView.hidden = NO;
}

- (void)showDownloadIndicator {
    //die Animation des ActivityIndicators stoppen
    [self.downloadWorkingActivityIndicator startAnimating];
    //den ActivityIndicator an sich wieder ausblenden
    self.downloadWorkingActivityIndicator.hidden = NO;
    //das Label wieder ausblenden
    self.downloadWorkingIndicatorLabel.hidden = NO;
    
    //den TableView wieder einblenden (also über das downloadWorkingIndicatorLabel legen)
    self.tableView.hidden = YES;
}


#pragma mark - UI-Actions
- (IBAction)speichernButtonClicked:(UIButton *)sender {
    //vorher überprüfen, ob wirklich keine Kurse parallel stattfinden
    
    if ([self verlaufenStundenParallel]) {
        //mithilfe eines UIAlertController
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Parallele Stunden!" message:@"Die Stunden von mindestens zwei deiner gewählten Kurse verlaufen parallel. Du kannst nicht in zwei Kursen gleichzeitig anwesend sein?! Möchtest du das wirklich speichern?"  preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"nein" style:UIAlertActionStyleCancel handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"ja" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self speichern];
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        return;
    }
    else {
        [self speichern];
    }
}

///speichert die gewählten Daten und stellt das Interface entsprechend ein
- (void)speichern {
    //den Benutzer auf eingerichtet setzen (vor dem Speichern des ManagedObjectContext), damit die Änderungen auch nach dem Speichervorgang erhalten sind --> sollte der Speichervorgang fehlschlagen, ist auch die Einrichtung noch nicht beendet, dann wird aber auch der Speichervorgang von der eingerichtet-Property des Users abgebrochen bzw. scheitert
    self.associatedUser.eingerichtet = [NSNumber numberWithBool:YES];
    
    //den ManagedObjectContext speichern -> das macht die Änderungen an den einzelnen Kurs-Objekten wirksam
    NSError *savingError = nil;
    [self.associatedUser.managedObjectContext save:&savingError];
    
    if (savingError) {
        [self showErrorMessage:@"Fehler beim Speichern der Kurse. Bitte wenden Sie sich an den Administrator"];
    }
    else {
        //den nächsten ViewController anzeigen
        [self presentViewController:[FinishedSetupViewController standardFinishedSetupViewController] animated:YES completion:nil];
    }
}

#pragma mark - Speichern-Methoden
- (BOOL)verlaufenStundenParallel {
    NSArray *selectedRows = self.tableView.indexPathsForSelectedRows;
    for (int i = 0; i < selectedRows.count; i++) {
        NSIndexPath *oneRowIndexPath = [selectedRows objectAtIndex:i];
        
        //Den Kurs für diese Cell abfragen --> gibt also alle ausgewählten Kurse zurück
        Kurs *kursForCell = [self.fetchedResultsController objectAtIndexPath:oneRowIndexPath];
        
        for (Schulstunde *aSchulstundeForKurs in kursForCell.stunden) {
            for (int j = i+1; j < selectedRows.count; j++) {
                NSIndexPath *indexPathToCompare = [selectedRows objectAtIndex:j];
                Kurs *kursToCompare = [self.fetchedResultsController objectAtIndexPath:indexPathToCompare];
                
                for (Schulstunde *schulstundeToCompare in kursToCompare.stunden) {
                    if (schulstundeToCompare.wochentag == aSchulstundeForKurs.wochentag && schulstundeToCompare.beginn == aSchulstundeForKurs.beginn) {
                        //mindestens eine Stunde findet parallel statt
                        NSLog(@"eine parallele Stunde");
                        return YES;
                    }
                }
                
            }
        }
    }
    
    return NO;
}
@end
