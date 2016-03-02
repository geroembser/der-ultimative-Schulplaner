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

@interface QuizKurseTableViewController ()

@end

@implementation QuizKurseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
