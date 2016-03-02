//
//  EinstellungenTableViewController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 19.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "EinstellungenTableViewController.h"
#import "KurseWaehlenViewController.h"
#import "User.h"
#import "ServerUserDataController.h"
#import "AppDelegate.h"
#import "QuizController.h"

@interface EinstellungenTableViewController ()

@end

@implementation EinstellungenTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Konfiguration der Anzeige der einzelnen Einstellungen
    
    //für gesamte Einstellungen benötigte Variablen/Objekte
    User *defaultUser = [User defaultUser];
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"dd.MM.YYYY, HH:mm:ss"];
    
    //Stundenplan-Einstellungen
    self.lastUpdateStundenplanLabel.text = [NSString stringWithFormat:@"letztes Update der Daten: %@", [df stringFromDate:defaultUser.lastDataUpdate]];
    
    //Benutzer-Einstellungen
    self.nameUndStufeLabel.text = [NSString stringWithFormat:@"%@ %@, Stufe: %@", defaultUser.vorname, defaultUser.nachname, defaultUser.stufe];
    self.benutzernameLabel.text = defaultUser.benutzername;
    self.letzteServerVerbindungLabel.text = [NSString stringWithFormat:@"letzte Server-Verbindung am %@", [df stringFromDate:defaultUser.lastServerConnection]];
    
    //Standard-Anweisungen von TableViewController
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - TableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //deselect the row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        //dann öffne den Controller zum Auswählen der Kurse
        KurseWaehlenViewController *kurseWaehlenViewController = [[KurseWaehlenViewController alloc]initWithUser:[User defaultUser]];
        
        //beim Ändern der ausgewählten Kurse in den Einstellungen nicht bei jedem mal den Stundenplan updaten
        kurseWaehlenViewController.shouldStartKurseUpdate = NO;
        
        //den ViewController anzeigen
        [self.navigationController pushViewController:kurseWaehlenViewController animated:YES];
    }
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

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

#pragma mark - Einstellungen bearbeiten/vornehmen etc.
#pragma mark Bereich: Stundenplan

#pragma mark Bereich: Benutzer
- (IBAction)logoutButtonClicked:(id)sender {
    //zeige einen AlertController an, der nachfragt, ob man sich wirklich abmelden möchte

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Wirklich fortfahren?" message:@"Möchtest du dich wirklich von der App abmelden? Deine Daten bleiben auf deinem Handy gespeichert und können durch ein erneutes Anmelden wiederhergestellt werden. Wenn du alle Daten löschen möchtest, lösche diese App von deinem Gerät!" preferredStyle:UIAlertControllerStyleActionSheet];
    
    //abmelden-Action für den alertController
    [alertController addAction:[UIAlertAction actionWithTitle:@"von der App abmelden und Daten behalten" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        //hier der Code für das Abmelden von der App
        
        //den ServeruserDataController erstellen mit dem Standard-Benutzer
        ServerUserDataController *userDataController = [[ServerUserDataController alloc]initWithUser:[User defaultUser]];
        
        [userDataController logout];
        
        //im AppDelegate das Intro anzeigen --> meint: das AppDelegate dazu benutzen, dass Root-Window der Application auf den introPageViewController zu setzen
        AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
        [appDelegate showIntro];
    }]];
    
    //cancel-Action für den Alert-Controller
    [alertController addAction:[UIAlertAction actionWithTitle:@"abbrechen und weiter effizient arbeiten 😉" style:UIAlertActionStyleCancel handler:nil]];
    
    //den alertController anzeigen
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
    
}

#pragma mark Bereich: Quiz
- (IBAction)quizfragenLoeschenButtonClicked:(id)sender {
    //nachfragen, ob wirklich alle Quizfragen gelöscht werden sollen
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Wirklich fortfahren?" message:@"Möchtest du wirklich alle auf diesem Gerät gespeicherten Quiz-Fragen für deine Kurse löschen? Später kannst du sie erneut aus dem Internet herunterladen!" preferredStyle:UIAlertControllerStyleActionSheet];
    
    //abmelden-Action für den alertController
    [alertController addAction:[UIAlertAction actionWithTitle:@"alle Quizfragen löschen" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        //hier der Code für das Löschen aller Quizfragen
        QuizController *quizController = [QuizController defaultQuizController];
        
        [quizController loescheAlleQuizfragenDesBenutzers];
    }]];
    
    //cancel-Action für den Alert-Controller
    [alertController addAction:[UIAlertAction actionWithTitle:@"abbrechen und weiter lernen 👍" style:UIAlertActionStyleCancel handler:nil]];
    
    //den alertController anzeigen
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}
@end
