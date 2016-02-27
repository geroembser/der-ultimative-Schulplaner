//
//  StundenplanViewController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 29.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "StundenplanViewController.h"
#import "StundenplanTableViewCell.h"
#import "Kurs.h"
#import "AufgabeEditViewController.h"
#import "KursDetailViewController.h"
#import "NSDate+AdvancedDate.h"

@interface StundenplanViewController () <StundenplanDelegate>
///das Refresh-Control-Element vom TableView, um den Vertretungsplan zu aktualisieren (eine Variable in dieser Instanz wird benötigt, damit man in der didRefreshStundenplan-Delegate-Methode auf dieses Kontrollelement zugreifen kann, um es auszublenden, also anzuzeigen, dass der Aktualisierungsprozess abgeschlossen wurde)
@property UIRefreshControl *refreshControl;
@end

@implementation StundenplanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Die TableViewCell für den TableView als Nib-File "registrieren"
    [self.tableView registerNib:[UINib nibWithNibName:@"StundenplanTableViewCell" bundle:nil] forCellReuseIdentifier:@"stundenplanTableViewCell"];
    
    //dem TableView ein Refresh-Control hinzufügen
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshVertretungsplan:) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:self.refreshControl];
    
    //den Benutzer standardmäßig auf den Default-User setzen
    self.associatedUser = [User defaultUser];
    
    //einen Stundenplan bekommen, für den Standard-User (siehe vorherige Zeile) mit Vertretungen ab dem jetzigen Datum (von diesem Datum aber die Uhrzeit nicht beachten, die Uhrzeit also mit der Methode einer NSDate-Kategorie - midnightUTC - auf Mitternacht setzen)
    self.stundenplan = [Stundenplan stundenPlanFuerUser:self.associatedUser mitVertretungenAbDatum:[NSDate date].midnightUTC];
    
    //das Delegate setzen
    self.stundenplan.delegate = self;
    
    //Vertretungsplan laden
    [self.stundenplan aktualisiereVertretungen];
    
    //den aktuellen Wochentag als integer-Wert zurückgeben
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setFirstWeekday:2]; //Montag ist der erste Tag der Woche, nicht Sonntag (=1)
    NSUInteger weekday = [gregorian ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:[NSDate date]];
    
    //den aktuell angezeigten Wochentag auf den des aktuellen Tags setzen, oder den nächsten Schultag (bei Samstag oder Sonntag als Wochentag)
    self.aktuellAngezeigterWochentag = (int)(weekday-1); //das konfiguriert schon den FetchedResultsController; weekday-1, weil Montag = 1 ist --> wir beginnen in der App mit Montag = 0
    
    
    //das Datum der letzten Aktualisierung des Vertretungsplans aktualisieren
    [self aktualisiereLabelMitDatumLetzteVertretungsplanVerbindung];
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

#pragma mark - TableView
#pragma mark TableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    //Die Gesamtanzahl der Kurse im TableView Bottom Label setzen
    [self setTableViewBottomLabelAufAktuelleStundenanzahl:self.aktuellAngezeigterWochentagObjekt.stunden.count];
    
    //Das Vertretuns-Label entsprechend aktualisieren
    [self refreshTableViewHeaderVertretungenDateLabelTextWithCurrentStundenplanWochentag];
    
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    
    //die letzte Stunde und deren Beginn ist der höchste Index einer Section im TableView
    return self.aktuellAngezeigterWochentagObjekt.letzteStundeIndex;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Standard-Teil für TableViewCells
    static NSString *CellIdentifier = @"stundenplanTableViewCell";
    
    StundenplanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[StundenplanTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //die TableViewCell konfigurieren
    Stunde *stundeForTableViewCell = [self.aktuellAngezeigterWochentagObjekt schulstundeFuerStunde:indexPath.row];
    cell.stunde = stundeForTableViewCell;
    
    //überprüfe, ob die nächste Stunde vom gleichen Kurs ist, dann lösche den Separator zwischen den einzelnen TableViewCells
    Stunde *naechsteStunde = [self.aktuellAngezeigterWochentagObjekt schulstundeFuerStunde:indexPath.row+1];
    
    
    //wenn die nächste Stunde != nil ist
    if (naechsteStunde != nil) {
        //vergleiche die beiden Kurs IDs, aber erst wenn beide Stunden jeweils ein "Schulstunde"-Objekt haben (also keine Vertretungen etc.)
        if (stundeForTableViewCell.schulstunde && naechsteStunde.schulstunde && [stundeForTableViewCell.schulstunde.kursID isEqualToString:naechsteStunde.schulstunde.kursID]) {
            //dann verstecke den Indicator
            cell.separatorInset = UIEdgeInsetsMake(0.f, 600.f, 0.f, 0.f);
        }
        else {
            //zeige den separator-indicator an
            cell.separatorInset = UIEdgeInsetsMake(0.f, 20.f, 0, 0);
        }
    }
    else {
        //zeige den Indicator an
        cell.separatorInset = UIEdgeInsetsMake(0.f, 20.f, 0, 0);
    }
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //deselect the other rows in the section
    
    return indexPath;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //deselect the row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //die Schulstunde für den ausgewählten Kurs in einer Variable halten
    __block Stunde *selectedStunde = [self.aktuellAngezeigterWochentagObjekt schulstundeFuerStunde:indexPath.row];
    
    
    //aber nur ein Menü anzeigen, wenn die Stunde keine Freistunde ist
    if (!selectedStunde.freistunde) {
        //zeige einen AlertController an, der die Möglichkeit gibt, eine neue Aufgabe für dieses Fach zu erstellen oder die Eigenschaften des Fachs/Kurs anzuzeigen
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ – Details\n%@", selectedStunde.schulstunde.kurs.name, [selectedStunde.schulstunde uhrzeitDauerString]] message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        //Details-Actions
        [alertController addAction:[UIAlertAction actionWithTitle:@"Details" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            //den Kurs-Detail-ViewController anzeigen
            KursDetailViewController *kursDetailViewController = [[KursDetailViewController alloc]initWithKurs:selectedStunde.schulstunde.kurs];
            [self presentViewController:kursDetailViewController animated:YES completion:nil];
        }]];
        //neue-Aufgabe-Action
        [alertController addAction:[UIAlertAction actionWithTitle:@"neue Aufgabe" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //einen AufgabeEditViewController anzeigen
            AufgabeEditViewController *aufgabeEditViewController = [[AufgabeEditViewController alloc]initWithSchulstunde:selectedStunde.schulstunde];
            
            [self presentViewController:aufgabeEditViewController animated:YES completion:nil];
        }]];
        //cancel-Action
        [alertController addAction:[UIAlertAction actionWithTitle:@"abbrechen" style:UIAlertActionStyleCancel handler:nil]];
        
        //alertController anzeigen
        [self presentViewController:alertController animated:YES completion:nil];
        
    }

}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {

    
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

#pragma mark TableView Helper-Methods
///setzt den Text im TableViewBottomLabel auf die Anzahl der Stunden des aktuell ausgewählten Tags
- (void)setTableViewBottomLabelAufAktuelleStundenanzahl:(NSUInteger)stundenanzahl {
    self.bottomTableViewLabel.text = [NSString stringWithFormat:@"%lu Stunden", stundenanzahl];
}

///aktualisiert den Text im "vertretungenDateLabel" so, dass dieser die entsprechende Information über den aktuell angezeigten Stundenplan-Wochentag und seine Vertretungsstunden ausgibt
- (void)refreshTableViewHeaderVertretungenDateLabelTextWithCurrentStundenplanWochentag {
    //die Variable, die den Text für das Label enthalten soll
    NSString *textForLabel = @"";
    
    //einen Date-Formatter zum Ausgeben des Datums für den jeweiligen StundenplanWochentag als String
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"EEEE, dd.MM.YYYY"];
    df.locale = [NSLocale currentLocale];
    
    //der String mit dem Datum für den jeweiligen Wochentag
    NSString *dateString = [df stringFromDate:self.aktuellAngezeigterWochentagObjekt.datum];
    
    //unterscheide, ob für den jeweiligen Wochentag Vertretungsstunden verfügbar sind, oder nicht
    if (self.aktuellAngezeigterWochentagObjekt.vertretungenVerfuegbarOderVorhanden) {
        //Vertretungen sind verfügbar
        textForLabel = [NSString stringWithFormat:@"Vertretungen für %@", dateString];
    }
    else {
        //keine Vertretungen verfügbar
        textForLabel = [NSString stringWithFormat:@"keine Vertretungen für %@", dateString];
    }
    
    self.vertretungenDateLabel.text = textForLabel;
}

///diese Methode sollte durch ein UIRefreshControl aufgerufen werden, wenn der User möchte, dass der TableView neugeladen werden soll --> eigentlich sollt damit nur der Vertretungsplan aktualisiert werden
- (void)refreshVertretungsplan:(UIRefreshControl *)refreshControl {
    //den Vertretungsplan aktualisieren
    [self.stundenplan aktualisiereVertretungen];
}


#pragma mark - Methoden-Einstellungen-Stundenplan
//setzt den aktuell angezeigten Wochentag neu
- (void)setAktuellAngezeigterWochentag:(SchulstundeWochentag)aktuellAngezeigterWochentag {
    //wenn der Wochentag Freitag oder Samstag ist, dann zeige Montag an
    if (aktuellAngezeigterWochentag > freitagWochentag) {
        //dann setze den Wochentag auf Montag
        aktuellAngezeigterWochentag = montagWochentag;
    }
    
    _aktuellAngezeigterWochentag = aktuellAngezeigterWochentag;
    
    
    //wenn der Index vom Segmented Control anders ist, als der des aktuell angezeigtem Wochentag, dann setze ihn auch entsprechend
    if (self.wochentagSegmentedControl.selectedSegmentIndex != aktuellAngezeigterWochentag) {
        self.wochentagSegmentedControl.selectedSegmentIndex = aktuellAngezeigterWochentag;
    }
    
    //das Wochentag-Objekt für den aktuell ausgewählten Wochentag vom Stundenplan bekommen und es entsprechend der Instanzvariable bzw. Property zuweisen
    self.aktuellAngezeigterWochentagObjekt = [self.stundenplan wochentagFuerIndex:self.aktuellAngezeigterWochentag];
}

///aktualisiert den Text in dem Label, was anzeigt, wann der Vertretungsplan zuletzt aktualisiert wurde
- (void)aktualisiereLabelMitDatumLetzteVertretungsplanVerbindung {
    //der String vom Datum der letzten Verbindung zum Vertretungsplan
    NSString *timeString = [self.stundenplan.user.lastVertretungsplanConnection datumUndUhrzeitString];
    
    //wenn der String leer ist oder "ungültig", dann zeige an, "letzte Aktualisierung: noch nie"
    if (timeString.length > 0 && ![timeString isEqualToString:@""]) {
        self.vertretungsplanLetzeAktualisierungLabel.text = [NSString stringWithFormat:@"letzte Aktualisierung: %@", timeString];
    }
    else {
        self.vertretungsplanLetzeAktualisierungLabel.text = @"letzte Aktualisierung: noch nie";
    }
    
}

#pragma mark - user interface actions
//Wochentag Segmented Control
- (IBAction)wochentagSegmentedControlValueChanged:(UISegmentedControl *)sender {
    self.aktuellAngezeigterWochentag = (int)sender.selectedSegmentIndex;
    
    //den Tableview neuladen
    [self.tableView reloadData];
}
#pragma mark Gesture Recognizers
//right swipe gesture recognizer
- (IBAction)rightSwipeGestureRecognizer:(UISwipeGestureRecognizer *)sender {
    NSInteger newIndex = (((int)self.wochentagSegmentedControl.selectedSegmentIndex)-1)%(int)self.wochentagSegmentedControl.numberOfSegments;
    
    if (newIndex < 0) {
        newIndex = self.wochentagSegmentedControl.numberOfSegments-1;
    }
    
    self.wochentagSegmentedControl.selectedSegmentIndex = newIndex;
    //die Interface-Methode von hier oben drüber aufrufen
    [self wochentagSegmentedControlValueChanged:self.wochentagSegmentedControl];
}
//left swipe gesture recognizer
- (IBAction)leftSwipeGestureRecognizer:(UISwipeGestureRecognizer *)sender {
    NSInteger newIndex = (self.wochentagSegmentedControl.selectedSegmentIndex+1)%self.wochentagSegmentedControl.numberOfSegments;
    self.wochentagSegmentedControl.selectedSegmentIndex = newIndex;
    [self wochentagSegmentedControlValueChanged:self.wochentagSegmentedControl];
    
}



#pragma mark - StundenplanDelegate
- (void)didRefreshStundenplan:(Stundenplan *)stundenplan {
    
    //lade den TableView neu, aber auf dem MainThread
    dispatch_async(dispatch_get_main_queue(), ^{
        //den TabelView neuladen
        [self.tableView reloadData];
        
        //das Datum der letzten Aktualisierung des Vertretungsplans aktualisieren
        [self aktualisiereLabelMitDatumLetzteVertretungsplanVerbindung];
        
        //beim Refresh-Control-Element den Aktualisieren-Effekt beenden
        [self.refreshControl endRefreshing];
    });
    
    
}
@end
