//
//  UebersichtViewController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 29.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "UebersichtViewController.h"
#import "User.h"
#import "Stundenplan.h"
#import "Kurs.h"
#import "Lehrer.h"
#import "Newscenter.h"
#import "NewscenterTableViewCell.h"

@interface UebersichtViewController () <NewscenterDelegate>
///das Newscenter, dass  in der Übersicht dargestellt wird
@property Newscenter *newscenter;
@end

@implementation UebersichtViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //das Newscenter-Objekt erstellen und die Erstellung der News beginnen
    self.newscenter = [Newscenter defaultNewscenter];
    [self.newscenter startCreatingNewsFromDefaultSources];
    
    //das Delegate vom Newscenter setzen
    self.newscenter.delegate = self;
    
    
    //Newscenter-TableView
    //die TableViewCell "registrieren"
    [self.newscenterTableView registerNib:[UINib nibWithNibName:@"NewscenterTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewscenterTableViewCell"];
    
    self.newscenterTableView.rowHeight = UITableViewAutomaticDimension;
    self.newscenterTableView.estimatedRowHeight = 60.0; //Durchschnittswert der TableViewCells
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //aktualisiere die Anzeige der nächsten Stunde
    [self aktualisiereNaechsteStunde];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


#pragma mark - nächste Stunde

//aktualisiert die Anzeige der nächsten Stunde
- (void)aktualisiereNaechsteStunde {
    //gibt an, ob die Stunde, die zurückgegeben wird, auch gerade aktiv ist
    
    BOOL geradeAktiv = NO;
    Stunde *naechsteStunde = [[[User defaultUser]stundenplan]naechsteSchulstundeGeradeAktiv:&geradeAktiv];
    
    if (geradeAktiv) {
        self.naechsteStundeUeberschriftLabel.text = @"aktuelle Stunde";
    }
    else {
        self.naechsteStundeUeberschriftLabel.text = @"nächste Stunde";
    }
    
    if (naechsteStunde) {
        self.naechsteStundeFachNameLabel.text = naechsteStunde.schulstunde.kurs.name;
        self.naechsteStundeLehrerLabel.text = naechsteStunde.schulstunde.lehrer.printableTeacherString;
        self.naechsteStundeRaumLabel.text = naechsteStunde.schulstunde.raumnummer;
    }
    else {
        self.naechsteStundeFachNameLabel.text = @"alles frei 😉";
        self.naechsteStundeLehrerLabel.text = @"---";
        self.naechsteStundeRaumLabel.text = @"---";
    }
}

#pragma mark IB-Actions
- (IBAction)zumStundenplanGehen:(id)sender {
    [self.tabBarController setSelectedIndex:2]; //zum Stundenplan gehen
}


#pragma mark - Newscenter
#pragma mark Newscenter-TableView Datasource/Delegate + andere Methoden
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.newscenter.numberOfNewsEntries;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewscenterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewscenterTableViewCell"];
    
    if (!cell) {
        cell = [[NewscenterTableViewCell alloc]init];
    }
    
    cell.newsObject = [self.newscenter newscenterObjectAtIndex:indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //deselect the TableViewCell
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Newscenter-Delegate
- (void)newscenterDidBeginReloading:(Newscenter *)newscenter {
    [self.newscenterTableView beginUpdates];
}
- (void)newscenterDidEndReloading:(Newscenter *)newscenter {
    [self.newscenterTableView endUpdates];
}
- (void)newscenter:(Newscenter *)newscenter didInsertNewsObject:(NewscenterObject *)newsObj atIndex:(NSUInteger)index {
    [self.newscenterTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (void)newscenter:(Newscenter *)newscenter didRemoveNewsObject:(NewscenterObject *)newsObj atIndex:(NSUInteger)index {
    [self.newscenterTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
