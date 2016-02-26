//
//  KursDetailViewController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 19.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "KursDetailViewController.h"
#import "Lehrer.h"
#import "TeacherEmailController.h"
#import "AufgabeFilter.h"
#import "AufgabenFilterPrefViewController.h" //für die Konstanten der geänderten Filter-Notification
#import "AppDelegate.h"
#import "MainTabBarController.h"
#import "StundeTableViewCell.h"

@interface KursDetailViewController () <UINavigationControllerDelegate, MFMailComposeViewControllerDelegate>
///alle Schulstunden für den Kurs (benutze noch eine Hilfsvariable, um die Schulstunden so zu sortieren, wie sie auch angezeigt werden sollen)
@property NSArray *schulstunden;
@end

@implementation KursDetailViewController

#pragma mark - Initialisierung
- (instancetype)initWithKurs:(Kurs *)kurs {
    //self mit einer Instanz vom Storyboard initialisieren
    self = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"kursDetailViewController"];
    
    if (self) {
        self.associatedKurs = kurs;
        
        //wenn ein Kurs gegeben ist, die folgenden Schritte der Initialisierung des Controllers vornehmen
        if (self.associatedKurs) {
            //die Schulstuden so sortieren, wie sie auch angezeigt werden sollen und das ganze in der entsprechenden Hilfsvariable speichern
            self.schulstunden = kurs.stunden.allObjects;
            
            //diese Schulstunden sortieren mit den folgenden SortDescriptors
            //sortieren nach dem Wochentag der Stunde
            NSSortDescriptor *wochentag = [NSSortDescriptor sortDescriptorWithKey:@"wochentag" ascending:YES];
            //sortieren nach dem Beginn der Stunden
            NSSortDescriptor *stunden = [NSSortDescriptor sortDescriptorWithKey:@"beginn" ascending:YES];
            self.schulstunden = [self.schulstunden sortedArrayUsingDescriptors:@[wochentag, stunden]];
        }
        
    }
    
    
    return self;
}

#pragma mark - UIViewController Methoden überschreiben
- (void)viewDidLoad {
    [super viewDidLoad];

    
    
    //hier das Interface mit den Daten konfigurieren, die der gegebenen Kurs hergibt
    if (self.associatedKurs) {
        
        //den Kurs-Namen setzen
        self.kursNameLabel.text = self.associatedKurs.name;
        
        //den Lehrer-Namen setzten
        self.lehrerNameLabel.text = [self.associatedKurs.lehrer printableTeacherString];
        
        //das Datum der letzten Änderung setzten
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"dd.MM.YYYY, HH:mm"];
        self.zuletztGeaendertLabel.text = [NSString stringWithFormat:@"zuletzt geändert am: %@ Uhr", [df stringFromDate:self.associatedKurs.geaendertAm]];
        
    }
    
    //registriere eine entsprechende TableViewCell beim TableView
    [self.stundenTableView registerNib:[UINib nibWithNibName:@"StundeTableViewCell" bundle:nil] forCellReuseIdentifier:@"StundeTableViewCell"];
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


#pragma mark - Stunden-TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.associatedKurs.stunden.allObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StundeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StundeTableViewCell"];
    
    if (!cell) {
        cell = [[StundeTableViewCell alloc]init];
    }
    
    cell.schulstunde = [self.schulstunden objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}




#pragma mark - Actions
- (IBAction)closeButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//zeigt das User-Interface für das Schreiben einer E-Mail an
- (IBAction)startWritingEmail:(id)sender {
    //erst überprüfne, ob überhaupt eine E-Mail-Adresse für den Lehrer des Kurs gegeben ist
    if (self.associatedKurs.lehrer && self.associatedKurs.lehrer.email.length > 0) {
        if ([MFMailComposeViewController canSendMail]) {
            TeacherEmailController *emailController = [[TeacherEmailController alloc]initWithLehrer:self.associatedKurs.lehrer andUser:self.associatedKurs.user];
            
            emailController.mailComposeDelegate = self;
            
            emailController.delegate = self;
            
            [self presentViewController:emailController animated:YES completion:nil];
        }
        else {
            //einen Fehlermeldung anzeigen
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"E-Mail nicht verfügbar" message:[NSString stringWithFormat:@"Dein Gerät unterstützt das Senden von E-Mail leider nicht. Probiere deinen Lehrer anders zu kontaktieren. Hier ist seine E-Mail-Adresse: %@", self.associatedKurs.lehrer.email] preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:nil]];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
    else {
        //Zeige ein AlertController an, der darauf hinweist, dass keine E-Mail-Adresse für den Lehrer vorhanden ist.
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"keine E-Mail verfügbar" message:@"Leider ist für diesen Lehrer keine E-Mail-Adresse in unserem System gespeichert! Wenn du deinem Lehrer etwas mitteilen möchtest, dann frage nach ihm am Lehrerzimmer oder schreibe ihm einen Brief und wirf ihn in den Briefkasten vor dem Lehrerzimmer ein!" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

//geht zu den Aufgaben für diesen Kurs
- (IBAction)goToAufgabenForKurs:(id)sender {
    
    //dismiss diesen ViewController
    [self dismissViewControllerAnimated:YES completion:^{
        //im completion-block beim TabBarController zum Aufgaben-Modul wechseln und alle Aufgaben für diesen Kurs anzeigen
        
        //ApplicationDelegate, um Zugriff auf den MainTabBarController der Application zu erhalten
        AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
        
        //zu den Aufgaben springen (aber vor dem Posten einer Notification, damit der AufgabenOverviewViewController erst in den Speicher geladen werden kann, um auch überhaupt Notifications empfangen zu können)
        [appDelegate.mainTabBarController setSelectedIndex:1];
        
        
        //dazu erst einmal einen Aufgaben-Filter erstellen
        AufgabeFilter *filter = [AufgabeFilter new];
        filter.erledigteAnzeigen = YES;
        filter.ausstehendeZuerst = YES;
        filter.sortAlphabetically = NO;
        filter.erledigteZuerst = NO;
        filter.vonDate = nil;
        filter.bisDate = nil;
        filter.anzuzeigendeKurse = @[self.associatedKurs];
        
        //poste die Notification
        [[NSNotificationCenter defaultCenter]postNotificationName:AufgabenNotificationNeuerFilterGesetzt object:self userInfo:@{AufgabenNotificationInfoDictFilterObjectKey : filter}];
        
        
    }];
    
}


#pragma mark - Email-Delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
