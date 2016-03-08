//
//  QuizThemenbereichViewController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 03.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "QuizThemenbereichViewController.h"
#import "QuizThemenbereichTableViewCell.h"
#import "QuizController.h"
#import "UIViewController+QuizShowingMethods.h"

@interface QuizThemenbereichViewController () <UITableViewDataSource, UITableViewDelegate>

///der FetchedResultsController für diesen ViewController
@property NSFetchedResultsController *fetchedResultsController;

@end

@implementation QuizThemenbereichViewController

#pragma mark - View configuration
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //den fetchedResultsController initialisieren, nur wenn ein Kurs gegeben ist
    if (self.kurs) {
        QuizController *quizController = [QuizController defaultQuizController];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:[quizController alleThemenbereicheFuerKurs:self.kurs] managedObjectContext:quizController.user.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
        NSError *fetchingError;
        [self.fetchedResultsController performFetch:&fetchingError];
        
        if (fetchingError) {
            NSLog(@"Fehler beim Suchen aller Themenbereiche für den Kurs: %@", self.kurs);
        }
        
        //den Titel des ViewControllers setzen (auf die ID des gegebenen Kurses)
        if (self.kurs.id && self.kurs.id.length > 0) {
            self.title = self.kurs.id;
        }
    }
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
    QuizThemenbereichTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"quizThemenbereichTableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    Themenbereich *bereichForCell = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.themenbereich = bereichForCell;
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //deselect the row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //der ausgewählte Themenbereich
    Themenbereich *ausgewaehlt = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //alle Fragen des Themenbereichs abfragen (mithilfe der UIViewController-Category) und nach "hinzugefuegtAm" sortieren,  um immer die neusten Fragen zuerst abzufragen
    NSArray *fragenSortiert = [ausgewaehlt.fragen.allObjects sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"hinzugefuegtAm" ascending:NO]]];
    [self frageFragenInArrayAb:fragenSortiert zufaellig:NO];
    
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
- (IBAction)alleFragenAbfragen:(id)sender {
    
    //frage den Array von zusammengestellten Fragen ab (durch eine Kategorie "QuizShowingMethods", die UIViewController erweitert und die die Fragen nach einer Erstellung eines Quiz daraus abfragt)
    [self frageFragenInArrayAb:self.kurs.fragen.allObjects zufaellig:YES];
}

- (IBAction)alleNeustenFragenAbfragen:(id)sender {
    //den Standard-Quiz-Controller bekommen, um Zugriff auf die Fragen zu erhalten
    QuizController *defaultQuizController = [QuizController defaultQuizController];
    
    //alle vefügbaren Fragen bekommen
    NSArray *alleFragen = [defaultQuizController alleDreißigNeustenFragenVonKurs:self.kurs];
    
    
    //frage den Array von zusammengestellten Fragen ab (durch eine Kategorie "QuizShowingMethods", die UIViewController erweitert und die die Fragen nach einer Erstellung eines Quiz daraus abfragt)
    [self frageFragenInArrayAb:alleFragen zufaellig:NO];
}

- (IBAction)alleFalschenFragenAbfragen:(id)sender {
    //den Standard-Quiz-Controller bekommen, um Zugriff auf die Fragen zu erhalten
    QuizController *defaultQuizController = [QuizController defaultQuizController];
    
    //alle vefügbaren, als "falsch" markierten, Fragen bekommen
    NSArray *alleFragen = [defaultQuizController alleFalschenFragenVonKurs:self.kurs];
    
    //frage den Array von zusammengestellten Fragen ab (durch eine Kategorie "QuizShowingMethods", die UIViewController erweitert und die die Fragen nach einer Erstellung eines Quiz daraus abfragt)
    [self frageFragenInArrayAb:alleFragen zufaellig:YES];
    
}


@end
