//
//  QuizKurseTableViewController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 28.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "QuizKurseTableViewController.h"
#import "Quiz.h"
#import "QuizController.h"
#import "QuizAbfrageNavController.h"
#import "FragenOverviewKursTableViewCell.h"
#import "KurseController.h"

@interface QuizKurseTableViewController ()

///der Fetched Results Controller, der die Kurse aus der Datenbank nimmt
@property NSFetchedResultsController *fetchedResultsController;

@end

@implementation QuizKurseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //ausgewählte Zellen des TableViews beim Erscheinen des Views abwählen
     self.clearsSelectionOnViewWillAppear = YES;
    
    //den FetchedResultsController konfigurieren
    QuizController *quizController = [QuizController defaultQuizController];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:quizController.alleKurseMitFragenFetchedRequest managedObjectContext:quizController.user.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    NSError *fetchingError;
    [self.fetchedResultsController performFetch:&fetchingError];
    
    if (fetchingError) {
        NSLog(@"Fehler beim Suchen aller Kurse für den User, die Fragen beinhalten");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FragenOverviewKursTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"quizErgebnisFrageTableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    Kurs *kursForCell = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.kurs = kursForCell;
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //deselect the row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


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

#pragma mark - Actions
///startet das Quiz von allen Fragen zufällig
- (IBAction)alleFragenZufaelligAbfragen:(id)sender {
    //den Standard-Quiz-Controller bekommen, um Zugriff auf die Fragen zu erhalten
    QuizController *defaultQuizController = [QuizController defaultQuizController];
    
    //alle vefügbaren Fragen bekommen
    NSArray *alleFragen = [defaultQuizController alleFragen];
    
    //überprüfen, ob Fragen gegeben sind, ansonsten zeige eine Fehlermeldung an
    if (alleFragen && alleFragen.count > 0) {
        //mit allen Fragen ein Quiz erstellen
        Quiz *neuesQuiz = [Quiz quizZusammenstellenMitArrayVonFragen:alleFragen randomly:YES fuerUser:[User defaultUser]];
        
        //erstellt den ViewController mit dem gegebenen Quiz
        QuizAbfrageNavController *quizNavController = [[QuizAbfrageNavController alloc]initWithQuiz:neuesQuiz];
        
        //zeige diesen QuizNavController an
        [self presentViewController:quizNavController animated:YES completion:nil];
    }
    else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Keine Fragen" message:@"Lokal sind keine Fragen vorhanden. Wähle deine entsprechenenden Kurse in den Einstellungen aus, und lade in der Quiz-Übersicht neue Fragen herunter, wenn dein Lehrer Fragen bereitgestellt hat." preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
@end
