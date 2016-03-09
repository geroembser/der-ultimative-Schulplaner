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
#import "NSDate+AdvancedDate.h"
#import "MitteilungViewController.h"

@interface UebersichtViewController () <NewscenterDelegate>
///das Newscenter, dass  in der Übersicht dargestellt wird
@property Newscenter *newscenter;

///das Refresh-Control-Element des TableViews
@property UIRefreshControl *tableViewRefreshControl;
@end

@implementation UebersichtViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //das Newscenter-Objekt erstellen und die Erstellung der News beginnen
    self.newscenter = [Newscenter defaultNewscenter];
    [self.newscenter startCreatingNewsFromDefaultSources];
    
    //das Delegate vom Newscenter setzen
    self.newscenter.delegate = self;
    
    //beim Start die allgemeinen Informationen über das Newscenter aktualisieren
    [self refreshGeneralNewscenterInfo];
    
    
    //Newscenter-TableView
    //die TableViewCell "registrieren"
    [self.newscenterTableView registerNib:[UINib nibWithNibName:@"NewscenterTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewscenterTableViewCell"];
    
    self.newscenterTableView.rowHeight = UITableViewAutomaticDimension;
    self.newscenterTableView.estimatedRowHeight = 60.0; //Durchschnittswert der TableViewCells
    
    //einn RefreshControl zum TableView mit den News hinzufügen, um über neue Nachrichten zu informieren
    self.tableViewRefreshControl = [[UIRefreshControl alloc] init];
    [self.tableViewRefreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.newscenterTableView addSubview:self.tableViewRefreshControl];
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
    
    //das News-Objekt für die TableViewCell bekommen
    NewscenterObject *newscenterObj = [self.newscenter newscenterObjectAtIndex:indexPath.row];
    
    //den Mitteilungs-ViewController anzeigen, wenn das News-Objekt für diese TableViewCell eine "Mitteilung" enthält
    if (newscenterObj.mitteilung) {
        //den MitteilungViewController initialisieren, der die Mitteilung angzeigen soll
        MitteilungViewController *mvc = [[MitteilungViewController alloc]initWithMitteilung:newscenterObj.mitteilung];
        
        //den ViewController anzeigen/präsentieren
        [self presentViewController:mvc animated:YES completion:nil];
    }
    
    //deselect the TableViewCell€
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Newscenter-TableView Refresh-Control
- (void)refresh:(UIRefreshControl *)refreshControl {
    //im Newscenter die News von den Standard-Quellen laden
    [self.newscenter startCreatingNewsFromDefaultSources];
    
    // Do your job, when done:
    [refreshControl endRefreshing];
}


#pragma mark erweiterte Newscenter-Methoden, für einfachere Programmierung
///der Aufruf dieser Methode soll die generellen Informationen und Details zum Newscenter ausgeben
- (void)refreshGeneralNewscenterInfo {
    ///das Datum der letzten Aktualisierung darstellen
    NSString *lastUpdateString = [[self.newscenter.mitteilungenController.user lastMitteilungenUpdate]datumUndUhrzeitString];
   
    //wenn das Datum gültig ist...
    if (lastUpdateString && lastUpdateString.length > 0) {
        self.newscenterLastUpdateLabel.text = [NSString stringWithFormat:@"letztes Update: %@", lastUpdateString];
    }
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
- (void)newscenterShouldStartReload:(Newscenter *)newscenter {
    //den Table-View refreshen (aber auf dem main-thread)
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.newscenterTableView reloadData];
        
        //die generellen Infos über das Newscenter (damit ist hauptsächlich das Datum der letzten Aktualisierung gemeint) aktualisieren
        [self refreshGeneralNewscenterInfo];
    });
}
- (void)newscenterDidBeginServerUpdate:(Newscenter *)newscenter {
    //Anzeigen, dass eine Verbindung zum Server aufgebaut wird + das Refresh-Control anzeigen (im TableView)
    
    //das Refresh-Control-Element anzeigen und/bzw. animieren
    [self.tableViewRefreshControl beginRefreshing];
    
    //einen Text in das Label setzen, dass den Status bzw. das letzte Update angibt
    self.newscenterLastUpdateLabel.text = @"Verbindung wird hergestellt...";
    
    
}
- (void)newscenter:(Newscenter *)newscenter didFinishServerUpdateWithError:(NSError *)error {
    //Anzeigen, dass das Update abgeschlossen wurde (also genauergesagt die Verbindung mit dem Server) + das Refresh-Control ausblenden (im TableView)
    //auch auf dem main-thread ausführen
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //das Refresh-Control-Element anzeigen und/bzw. animieren
        [self.tableViewRefreshControl endRefreshing];
        
        //einen Text in das Label setzen, dass den Status bzw. das letzte Update angibt --> in diesem Fall unterscheiden, ob ein Fehler passiert ist oder nicht
        if (error) {
            self.newscenterLastUpdateLabel.text = @"Fehler, später erneut versuchen!";
        }
        else {
            [self refreshGeneralNewscenterInfo]; //der Aufruf dieser Methode sollte das Datum der letzten Aktualisierung entsprechend auf dem user interface anzeigen
        }
    });
}



@end
