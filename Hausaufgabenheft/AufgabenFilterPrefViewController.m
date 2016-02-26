//
//  AufgabenFilterPrefViewController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 20.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "AufgabenFilterPrefViewController.h"
#import "AufgabeFilter.h"
#import "KonfigurierteKurseWaehlenViewController.h"

@interface AufgabenFilterPrefViewController () <KonfigurierteKurseWaehlenViewControllerDelegate>
///das aktuell akive Textfeld
@property UITextField *activeField;

///der Date-Picker für das von-Textfeld
@property UIDatePicker *vonDatePicker;

///der Date-Picker für das bis-Textfeld
@property UIDatePicker *bisDatePicker;

///das ausgewählte von-Datum - oder eben keins (= nil)
@property (nonatomic) NSDate *vonDate;

///das ausgewählte bis-Datum - oder eben keins (= nil)
@property (nonatomic) NSDate *bisDate;

///der Array von Kursen, nach denen gefiltert werden soll
@property (nonatomic) NSArray *kurseToFilter;

@end

@implementation AufgabenFilterPrefViewController

#pragma mark - initialization
- (instancetype)initWithFilter:(AufgabeFilter *)filter {
    self = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"aufgabenFilterPrefViewController"];
    
    if (self) {
        //wichtig, damit der ViewController transparent angezeigt wird
        [self setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        
        //der Filter, für den ViewController (für den der View sozusagen vorkonfiguriert werden soll)
        self.currentFilter = filter;
    }
    
    return self;
}


#pragma mark - Default
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //die Datepicker für das von-/bis-Textfeld konfigurieren
    //von-Date-Picker
    self.vonDatePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150.0)];
    [self.vonDatePicker setDate:[NSDate date]];
    self.vonDatePicker.datePickerMode = UIDatePickerModeDate;
    [self.vonDatePicker addTarget:self action:@selector(vonDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.vonDateTextfeld setInputView:self.vonDatePicker];
    
    //bis-Date-Picker
    self.bisDatePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150.0)];
    [self.bisDatePicker setDate:[NSDate date]];
    self.bisDatePicker.datePickerMode = UIDatePickerModeDate;
    [self.bisDatePicker addTarget:self action:@selector(bisDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.bisDateTextfeld setInputView:self.bisDatePicker];
    
    
    //die InputAccessory-Views für die Date-Picker-Textfelder
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"fertig" style:UIBarButtonItemStyleDone target:self action:@selector(hideKeyboard:)];
    UIBarButtonItem *keinDatum = [[UIBarButtonItem alloc]initWithTitle:@"kein Datum" style:UIBarButtonItemStylePlain target:self action:@selector(resetDateInCurrentDateTextfield)];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [toolbar setItems:@[keinDatum, flexibleSpace, cancelButton]];
    
    self.vonDateTextfeld.inputAccessoryView = toolbar;
    self.bisDateTextfeld.inputAccessoryView = toolbar;
    
    
    
    
    //den View so konfigurieren, dass er die Daten des aktuellen Filters anzeigt
    if (self.currentFilter) {
        self.erledigteAnzeigenSwitch.on = self.currentFilter.erledigteAnzeigen;
        
        NSUInteger newIndex = 0;
        if (self.currentFilter.ausstehendeZuerst) {
            newIndex = 0;
        }
        else if (self.currentFilter.sortAlphabetically) {
            newIndex = 1;
        }
        else if (self.currentFilter.erledigteZuerst) {
            newIndex = 2;
        }
        self.sortSegmentedControl.selectedSegmentIndex = newIndex;
        
        //die von-/bis-Datums
        self.vonDate = self.currentFilter.vonDate;
        self.bisDate = self.currentFilter.bisDate;
        
        // hier noch weitere Konfigurationen vornehmen, wie die Kurse, die gefiltert werden müssen (der Setter der kurseToFilter-Property sollte automatisch das user interface konfigurieren
        self.kurseToFilter = self.currentFilter.anzuzeigendeKurse;
    }
    
    
    
    //Die Benachrichtigunen für das Anzeigen und Verschwinden des Keyboards registrien, um die ContentInsets des ScrollViews entsprechend zu ändern
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardDidHideNotification object:nil];
}

//Animiere den Hintergrund des Views beim Ein- und Ausblenden des Views (damit es für den Benutzer akzeptabel aussieht)
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    

}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
        self.view.layer.backgroundColor = [[UIColor colorWithRed:0.39 green:0.39 blue:0.39 alpha:0.9]CGColor];
    }  completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //nur den Hintergrund wieder transparent machen, bevor der ViewController ausgeblendet wird, nicht aber wenn der ViewController zum Kurse-Auswählen angezeigt wird
    if ([self isBeingDismissed]) {
        [UIView animateWithDuration:0.05 animations:^{
            self.view.layer.backgroundColor = [[UIColor colorWithRed:0.39 green:0.39 blue:0.39 alpha:0]CGColor];
        }];
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




#pragma mark - IB-Actions
- (IBAction)anwenden:(id)sender {
    //Poste die Notification, die angibt, dass etwas geändert wurde
    
    //dafür ein Aufgaben-Filter-Objekt erstellen
    AufgabeFilter *filter = [AufgabeFilter new];
    filter.erledigteAnzeigen = self.erledigteAnzeigenSwitch.on;
    filter.ausstehendeZuerst = self.sortSegmentedControl.selectedSegmentIndex == 0;
    filter.sortAlphabetically = self.sortSegmentedControl.selectedSegmentIndex == 1;
    filter.erledigteZuerst = self.sortSegmentedControl.selectedSegmentIndex == 2;
    filter.vonDate = self.vonDate;
    filter.bisDate = self.bisDate;
    filter.anzuzeigendeKurse = self.kurseToFilter;
    
    //poste die Notification
    [[NSNotificationCenter defaultCenter]postNotificationName:AufgabenNotificationNeuerFilterGesetzt object:self userInfo:@{AufgabenNotificationInfoDictFilterObjectKey : filter}];
                                                                                                                            
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)zuruecksetzen:(id)sender {
    
    //poste die Notification
    [[NSNotificationCenter defaultCenter]postNotificationName:AufgabenNotificationNeuerFilterGesetzt object:self userInfo:nil]; //ohne UserInfo, weil kein neuer Filter gesetzt wurde
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)showKursSelection:(id)sender {

    //den KonfigurierteKurseWaehlenViewController erstellen
    KonfigurierteKurseWaehlenViewController *konfKurseWaehlen = [[KonfigurierteKurseWaehlenViewController alloc]initWithUser:[User defaultUser] allowingMultipleKursSelection:YES andArrayOfSelectedKurse:self.kurseToFilter];
    
    //das Delegate setzen
    konfKurseWaehlen.delegate = self;
    
    //dann den ViewController anzeigen
    [self presentViewController:konfKurseWaehlen animated:YES completion:nil];
}

- (IBAction)backgroundTapGestureRecognizerTapped:(id)sender {
    //aber nur den ViewController ausblenden, wenn auf den Hintergrund getippt wurde, also nicht auf den eigentlichenFilterView
    UITapGestureRecognizer *gestureRecognizer = (UITapGestureRecognizer *)sender;
    if ([gestureRecognizer locationInView:self.eigentlicherFilterView].y < 0) { //damit wird der ViewController nur ausgeblendet, wenn der Touch vom User überhalb vom eigentlichenFilterView auf dem Bildschirm war
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}


#pragma mark - Textfield InputViews-Methoden
#pragma mark DatePicker
///die Methode, wenn das Datum vom von-Date-Picker geändert wurde
- (IBAction)vonDatePickerValueChanged:(id)sender {
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    
    //überprüfen, ob das Datum vom von-Date-Picker kleiner oder gleich dem ist, was beim bis-Date-Picker ausgewählt ist
    if ([datePicker.date compare:self.bisDate] == NSOrderedDescending) {
        //dann setze das Date beim Date-Picker auf das des bis-Date-Pickers
        datePicker.date = self.bisDatePicker.date;
    }

    //aktualisiert auch das Textfeld entsprechend
    self.vonDate = datePicker.date;
    
    
    
}
///die Methode, wenn das Datum vom bis-Date-Picker geändert wurde
- (IBAction)bisDatePickerValueChanged:(id)sender {
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    
    //überprüfen, ob das Datum vom bis-Date-Picker größer oder gleich dem ist, was beim vom-Date-Picker ausgewählt ist
    if ([datePicker.date compare:self.vonDate] == NSOrderedAscending) {
        //dann setze das Date beim Date-Picker auf das des von-Date-Pickers
        datePicker.date = self.vonDatePicker.date;
    }
    
    //aktualisiert auch das Textfeld entsprechend
    self.bisDate = datePicker.date;

    
}

- (void)setVonDate:(NSDate *)vonDate {
    _vonDate = vonDate;
    if (vonDate) {
        self.vonDatePicker.date = vonDate;
        self.vonDateTextfeld.text = [self dateStringFromDate:vonDate];
    }
    else {
        self.vonDateTextfeld.text = @"";
    }
    
}
- (void)setBisDate:(NSDate *)bisDate {
    _bisDate = bisDate;
    if (bisDate) {
        self.bisDatePicker.date = bisDate;
        self.bisDateTextfeld.text = [self dateStringFromDate:bisDate];
    }
    else {
        self.bisDateTextfeld.text = @"";
    }
    
}

#pragma mark InputAccessoryView Textfields
///blendet die Tastatur vom aktuellen Textfeld aus und beendet damit die Bearbeitung des Textfeld
- (IBAction)hideKeyboard:(id)sender {
    [self.activeField resignFirstResponder];
}

///setzt das Datum für eines der von-/bis-Date-Picker-Textfelder auf leer
- (void)resetDateInCurrentDateTextfield {
    if (self.activeField == self.vonDateTextfeld) {
        self.vonDate = nil;
    }
    else if (self.activeField == self.bisDateTextfeld) {
        self.bisDate = nil;
    }
}


#pragma mark Helper-Methods
- (NSString *)dateStringFromDate:(NSDate *)date {
    
    if (!date) {
        return nil;
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"dd.MM.YYYY"];
    
    return [df stringFromDate:date];
}

#pragma mark - Textfield delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    //wenn angefangen wird, ein Textfeld zu bearbeiten, dann "markiere" es entsprechend als aktives Textfeld
    self.activeField = textField;
    
    //in das jeweilige Textfeld direkt nach Beginn des Editings, den aktuellen Wert des jeweiligen DatePickers setzen
    if (self.activeField == self.vonDateTextfeld) {
        self.vonDate = self.vonDatePicker.date;
    }
    else if (self.activeField == self.bisDateTextfeld) {
        self.bisDate = self.bisDatePicker.date;
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil; // wenn kein Textfeld mehr bearbeitet wird, dann ist auch kein Textfeld mehr aktiv
}
//die folgenden zwei Methoden sind wichtig, damit das Textfeld, welches gerade ausgewählt ist, auch entsprechend gekennzeichnet wird (hier mit einem roten Rand)
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    textField.layer.cornerRadius=8.0f;
    textField.layer.masksToBounds=YES;
    textField.layer.borderColor=[[UIColor redColor]CGColor];
    textField.layer.borderWidth= 1.0f;
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    //danach die in der Methode hierüber gemachten Änderungen "rückgängig machen"
    textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    textField.layer.borderWidth = 0.0;
    textField.layer.cornerRadius = 0.0;
    
    
    return YES;
}

#pragma mark - Keyboard Notification
///wird aufgerufen, wenn die Tastatur angezeigt wird und ändert die contentInsets des ScrollViews entsprechend ab
- (void)keyboardWasShown:(NSNotification *)aNotification {
    //Die Informationen zur Tastatur aus der userInfo-Dictionary von der gegebenen Notification entnehmen
    NSDictionary *info = [aNotification userInfo];
    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey]CGRectValue].size;
    
    //die neuen ContentInsets kalkulieren und dem ScrollView zuweisen
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height-self.anwendenButton.frame.size.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets; //auch den scrollIndicators die insets zuweisen, damit die scroll-indicators nicht hinter der Tastatur verschwinden, sobald man nach unten scrollt
    
    //wenn das aktive Textfeld oder der aktive TextView vom Keyboard verdeckt wird, scrolle es nach oben
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    
    //definiere den Punkt, für den geprüft werden soll, ob er vom Textfeld verdeckt wird
    CGPoint punkToCheck = self.activeField.frame.origin;
    
    //überprüfe, ob das aktive Textfeld vom Keyboard verdeckt wird
    if (!CGRectContainsPoint(aRect, punkToCheck)) {
        //erstelle den Punkt, zu dem gescrollt werden soll
        
        //dafür erst wieder zwischen Textfeld und Textview unterscheiden
        CGFloat scrollPointY = self.activeField.frame.origin.y;
        
        CGPoint scrollPoint = CGPointMake(0.0, scrollPointY-kbSize.height);
        
        //dann scrolle zu dem gerade erstellten Punkt
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}
///diese Methode setzt die contentInsets wieder an allen Rändern auf 0, wenn die Tastatur ausgeblendet wird
- (void)keyboardWillBeHidden:(NSNotification *)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}


#pragma mark - Konfigurierte-Kurse-Waehlen-ViewController-Delegate
- (void)didFinishKurseWaehlen:(NSArray<Kurs *> *)gewaehlteKurse inKonfigurierteKurseWaehlenViewController:(KonfigurierteKurseWaehlenViewController *)kurseWaehlenViewController {
    self.kurseToFilter = gewaehlteKurse; //Aufruf des Setters sollte das user interface entsprechend konfigurieren
}

- (void)setKurseToFilter:(NSArray *)kurseToFilter {
    _kurseToFilter = kurseToFilter;
    
    //einen String aus allen Kurs-IDs der gewählten Kurse erstellen, der entsprechend angezeigt werden soll
    NSMutableString *kurseString = [NSMutableString new];
    for (Kurs *kurs in kurseToFilter) {
        [kurseString appendString:kurs.id];
        if (kurs != kurseToFilter.lastObject) {
            [kurseString appendString:@", "];
        }
    }
    //wenn die Länge des kurseStrings gleich 0 ist, dann setzte den Standard-Title
    if (kurseString.length == 0) {
        kurseString = (NSMutableString *)@"Fächer auswählen";
    }
    [self.fachFilterButton setTitle:kurseString forState:UIControlStateNormal];
    
}
@end
