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
#import "QuizThemenbereichViewController.h"
#import "UIViewController+QuizShowingMethods.h"

@interface QuizKurseTableViewController ()

///der Fetched Results Controller, der die Kurse aus der Datenbank nimmt
@property NSFetchedResultsController *fetchedResultsController;

///der aktuell durch den Benutzer im TableView ausgewählte Kurs
@property Kurs *aktuellGewaehlterKurs;

///ein Array mit einer Auswahl von Farben für die einzelnen TableViewCells des TableViews (alle aufeinanderfolgenden TableViewCells sollten unterschiedliche Farben haben, damit das besser aussieht
@property NSArray *farbenArray;

@end

@implementation QuizKurseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //die Farben definieren, die im TableView als Hintergrundfarbe für die einzelnen TableViewCells verwendet werden sollen
    self.farbenArray = @[[UIColor colorWithRed:0.8 green:0.8 blue:0.2 alpha:1.0], [UIColor colorWithRed:0.0 green:0.47 blue:1.0 alpha:1.0], [UIColor colorWithRed:0.61 green:0.09 blue:0.27 alpha:1.0], [UIColor colorWithRed:0.6 green:0.6 blue:0.2 alpha:1.0], [UIColor colorWithRed:1.0 green:0.4 blue:0.0 alpha:1.0]];
    
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
    
    //die Hintergrundfarbe setzen auf eine Farbe aus dem farbenArray
    UIColor *farbe = [self.farbenArray objectAtIndex:indexPath.row%self.farbenArray.count];
    
    cell.contentView.backgroundColor = farbe;
    
    
    
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //setzte den aktuell ausgewählten Kurs, um ihn in der prepareForSegue-Methode an den QuizThemenbereichViewController übergeben zu können --> das ganze aber schon hier machen, weil es vor dem Aufruf der prepareForSegue-Methode geschehen muss, die durch die Storyboard-Segue von der TableView-Cell zu dem neuen ViewController aufgerufen wird;
    self.aktuellGewaehlterKurs = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //aber nur die weiter gehen, wenn auch wirklich Fragen für den Kurs verfügbar sind
    if (self.aktuellGewaehlterKurs.fragen.allObjects.count <= 0) {
        return nil;
    }
    
    ///Index-Path zurückgeben, damit die TableViewCell auch wirklich ausgewählt wird --> wenn man nil zurückgeben würde, würde die TableViewCell nicht ausgewählt werden
    return indexPath;
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.destinationViewController isKindOfClass:[QuizThemenbereichViewController class]]) {
        QuizThemenbereichViewController *themenbereichVC = [segue destinationViewController];
        
        themenbereichVC.kurs = self.aktuellGewaehlterKurs;
    }
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

#pragma mark - Actions
///startet das Quiz von allen Fragen zufällig
- (IBAction)alleFragenZufaelligAbfragen:(id)sender {
    //den Standard-Quiz-Controller bekommen, um Zugriff auf die Fragen zu erhalten
    QuizController *defaultQuizController = [QuizController defaultQuizController];
    
    //alle vefügbaren Fragen bekommen
    NSArray *alleFragen = [defaultQuizController alleFragen];
    
    //frage den Array von zusammengestellten Fragen ab (durch eine Kategorie "QuizShowingMethods", die UIViewController erweitert und die die Fragen nach einer Erstellung eines Quiz daraus abfragt)
    [self frageFragenInArrayAb:alleFragen zufaellig:YES];
}

- (IBAction)alleNeustenFragenAbfragen:(id)sender {
    //den Standard-Quiz-Controller bekommen, um Zugriff auf die Fragen zu erhalten
    QuizController *defaultQuizController = [QuizController defaultQuizController];
    
    //alle vefügbaren Fragen bekommen
    NSArray *alleFragen = [defaultQuizController alleDreißigNeustenFragen];
    
    
    //frage den Array von zusammengestellten Fragen ab (durch eine Kategorie "QuizShowingMethods", die UIViewController erweitert und die die Fragen nach einer Erstellung eines Quiz daraus abfragt)
    [self frageFragenInArrayAb:alleFragen zufaellig:NO];
}

- (IBAction)alleFalschenFragenAbfragen:(id)sender {
    //den Standard-Quiz-Controller bekommen, um Zugriff auf die Fragen zu erhalten
    QuizController *defaultQuizController = [QuizController defaultQuizController];
    
    //alle vefügbaren, als "falsch" markierten, Fragen bekommen
    NSArray *alleFragen = [defaultQuizController alleFalschenFragen];
    
    //frage den Array von zusammengestellten Fragen ab (durch eine Kategorie "QuizShowingMethods", die UIViewController erweitert und die die Fragen nach einer Erstellung eines Quiz daraus abfragt)
    [self frageFragenInArrayAb:alleFragen zufaellig:YES];

}

@end
