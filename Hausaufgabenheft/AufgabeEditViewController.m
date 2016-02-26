//
//  AufgabeEditViewController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 30.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "AufgabeEditViewController.h"
#import "Aufgabe.h"
#import <AVFoundation/AVFoundation.h>
#import "AufgabeMediaCollectionViewCell.h"
#import <Photos/Photos.h>
#import "Lehrer.h"
#import "Schulstunde.h"
#import "MediaFilesDetailViewController.h"

@interface AufgabeEditViewController () <UIScrollViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

//die folgenden zwei Variablen dazu benutzen, sie dynamisch mithilfe der Textfield-/TextView-Delegate-Methoden zu setzen, um beispielsweise den first responder zu entziehen und damit die Tastatur auszublenden
///das aktuell akive Textfeld
@property UITextField *activeField;
///der aktuell aktive TextView
@property UITextView *activeTextView;

//die zwei DatePicker für das erinnerungs-Textfeld und das abgabeDatum-Textfeld
////der DatePicker für das Erinnerungs-Datum-Textfeld
@property UIDatePicker *erinnerungsDatumDatePicker;
///der DatePicker für das Abgabe Datum Textfeld
@property UIDatePicker *abgabeDatumDatePicker;
@end

@implementation AufgabeEditViewController


//überschreibe die init-Methode
- (instancetype)init {
    //Initialisiere den ViewController aus dem Storyboard heraus
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    self = [storyboard instantiateViewControllerWithIdentifier:@"aufgabeEditViewController"];
    
    if (self) {
        //weitere Konfigurationen von der Instanz, die vom Storyboard zurückgegebn wurde
        
        //die mutable Arrays im Zusammenhang mit den mediaFiles initialisieren
        self.mediaFiles = [NSMutableArray new];
        self.mediaFilesToAdd = [NSMutableArray new];
        self.mediaFileToDelete = [NSMutableArray new];
    }
    else {
        //wenn keine Instanz vom Storyboard zurückgegeben wurde, dann erstelle einfach eine neue Instanz durch den Aufruf der Superklasse (UIViewController) --> die dann eventuell zurückgegebene Instanz ist dann nicht so, wie die im Storyboard konfigurierte Instanz
        return [super init];
    }
    
    return self;
}

//initWithAufgabe
- (instancetype)initWithAufgabe:(Aufgabe *)aufgabe {
    self = [self init];
    
    if (self && aufgabe) {
        self.representedAufgabe = aufgabe;
        self.associatedUser = aufgabe.user;
        self.mediaFiles = [NSMutableArray arrayWithArray:aufgabe.mediaFiles.allObjects];
        
        //die MediaFiles noch sortieren (das zuletzt hinzugefügte MediaFile an den Schluss stellen
        [self.mediaFiles sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"hinzugefuegtAm" ascending:YES]]];
        
    }
    
    return self;
}

//initWithSchulstunde
- (instancetype)initWithSchulstunde:(Schulstunde *)schulstunde {
    self = [self init];
    
    if (self && schulstunde) {
        self.associatedUser = schulstunde.kurs.user;
        self.kursFuerAufgabe = schulstunde.kurs;
        
        //hier können noch weiter Konfigurationen vorgenommen werden, sodass die Aufgabe so konfiguriert ist, dass sie zum Beispiel die Erinnerung auf den Tag vor der nächsten Stunde dieses Fachs setzt bzw. logischerweise das Abgabedatum auf das Datum der nächsten Schulstunde von diesem Kurs setzt... #todo
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Beim Laden prüfen, ob ein Benutzer vorhanden ist, ansonsten den Standard-Benutzer nehmen
    if (!self.associatedUser) {
        self.associatedUser = [User defaultUser];
    }
    
    
    //Die Benachrichtigunen für das Anzeigen und Verschwinden des Keyboards registrien, um die ContentInsets des ScrollViews entsprechend zu ändern
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardDidHideNotification object:nil];
    
    //Die Textfelder mit der Datums-/Uhrzeitwahl entsprechend konfigurieren
    
    //Abgabedatum
    self.abgabeDatumTextfield.tintColor = [UIColor clearColor];
    
        //den DatePicker konfigurieren für das Abgabedatum
    self.abgabeDatumDatePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150.0)];
    [self.abgabeDatumDatePicker setDate:[NSDate date]];
    self.abgabeDatumDatePicker.datePickerMode = UIDatePickerModeDate; //beim Abgabedatum nur das Datum wählen
    [self.abgabeDatumDatePicker addTarget:self action:@selector(abgabeDatumDateChanged:) forControlEvents:UIControlEventValueChanged];
    [self.abgabeDatumTextfield setInputView:self.abgabeDatumDatePicker];
    
    //Erinnerungsdatum + Uhrzeit
    self.erinnerungTextfield.tintColor = [UIColor clearColor];
    
        //den DatePicker für das Erinnerungsdatum konfigurieren
    self.erinnerungsDatumDatePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150.0)];
    [self.erinnerungsDatumDatePicker setDate:[NSDate date]];
    self.erinnerungsDatumDatePicker.datePickerMode = UIDatePickerModeDateAndTime; //beim Erinnerungsdatum auch die Uhrzeit neben dem Datum wählen
    [self.erinnerungsDatumDatePicker addTarget:self action:@selector(erinnerungsDateChanged:) forControlEvents:UIControlEventValueChanged];
    [self.erinnerungTextfield setInputView:self.erinnerungsDatumDatePicker];
    
    
    //jetzt überprüfen, ob eine Aufgabe bereits vorhanden ist, der Controller also mit einer Aufgabe initialisiert wurde --> dann nämlich die Daten schon entsprechend setzen
    if (self.representedAufgabe) {
        self.titelTextfield.text = self.representedAufgabe.titel;
        self.lehrerLabel.text = [self.representedAufgabe.kurs.lehrer printableTeacherString];
        self.beschreibungTextView.text = self.representedAufgabe.beschreibung;
        self.prioritaetSegmentedControl.selectedSegmentIndex = self.representedAufgabe.prioritaet.intValue;
        self.notizenTextView.text = self.representedAufgabe.notizen;
        
        //sonstige Eigenschaften setzen (der Aufruf von allen Settern der folgenden Eigenschaften sollte auch das User-Interface konfigurieren)
        self.abgabeDatum = self.representedAufgabe.abgabeDatum;
        self.erinnerungsDatum = self.representedAufgabe.erinnerungDate;
        self.kursFuerAufgabe = self.representedAufgabe.kurs;
        
        //den Titel des Titel-Labels auf "Aufgabe" setzen
        self.titelLabel.text = @"Aufgabe";
    }
    else if (self.kursFuerAufgabe) {
        //wenn stattdessen beim Start schon ein Kurs vorhanden ist, dann richte das Interface so entsprechend ein
        self.kursFuerAufgabe = self.kursFuerAufgabe; //durch einen Aufruf von dem Setter mit dem bereits vorhandenen Wert der Variable wird das Interface entsprechend konfiguriert
    }
    else {
        //wenn noch keine Aufgabe vorhanden ist, dann noch weitere Konfigurationen vornehmen
        
    }
    
    
    //Image-Picker-Controller: eventuell die Buttons zum Auswählen von Fotos ausblenden
    //prüft, ob die Kamera verfügbar ist
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        //wenn keine Kamera verfügbar ist, dann deaktiviere den neues Foto-Button aus
        self.neuesFotoAufnehmenButton.enabled = NO;
    }
    //Fotoalbum
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        //wenn kein Fotoalbum verfügbar ist, dann deaktiviere den fotosAusAlbumWaehlenButton
        self.fotoAusAlbumWaehlenButton.enabled = NO;
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

#pragma mark - Methoden zur Konfiguration der Aufgabenerstellung/Aufgabenbearbeitung
#pragma mark - Setter überschreiben
- (void)setKursFuerAufgabe:(Kurs *)kursFuerAufgabe {
    _kursFuerAufgabe = kursFuerAufgabe;
    
    //Das Interface entsprechend konfigurieren
    if (!kursFuerAufgabe) {
        //dann setze den Standard-Text in den Kurs-Button
        [self.kursButton setTitle:@"Kurs (hier tippen)" forState:UIControlStateNormal];
        
        //den Text im Lehrer Label ändern
        self.lehrerLabel.text = @"Bitte einen Kurs wählen!";
    }
    else {
        //den Titel vom Kurs Button setzen, wenn ein Kurs zurückgegeben wurde
        [self.kursButton setTitle:kursFuerAufgabe.name forState:UIControlStateNormal];
        
        //den Lehrer für den Kurs auch setzen
        self.lehrerLabel.text = [kursFuerAufgabe.lehrer printableTeacherString];
    }
}

- (void)setAbgabeDatum:(NSDate *)abgabeDatum {
    _abgabeDatum = abgabeDatum;
    
    //das user interface entsprechend konfigurieren
    
    //wenn kein Abgabedatum gegeben ist, dann entsprechend einen Leerstring anzeigen und die Ausführung der Methode unterbrechen
    if (!abgabeDatum) {
        self.abgabeDatumTextfield.text = @"";
        return;
    }
    
    //den DateFormatter, um das Datum entsprechend als String zu bekommen
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd.MM.YYYY"];
    
    //das Datum mit Hilfe des DateFormatters in einen String umwandeln
    NSString *abgabeDatumString = [dateFormatter stringFromDate:abgabeDatum];
    
    //den String mit dem Abgabedatum im abgabeDatumTextfield ausgeben
    self.abgabeDatumTextfield.text = abgabeDatumString;
    
    //dem Date-Picker ebenfalls nochmal das abgabeDatum zuweisen, falls diese Methode aufgerufen wird, wenn eine Aufgabe bearbeitet wird, sodass später, wenn das abgabeDatumTextfield angeklickt wird, dort das abgabeDatum der aktuellen Aufgabe angezeigt wird und nicht das Standard-Datum vom DatePicker
    self.abgabeDatumDatePicker.date = abgabeDatum;
    
    //wenn kein Erinnerungs-Datum gesetzt wurde, und der Erinnerungs-Switch on ist, dann setze das Erinnerungsdatum auf einen Tag vor dem Abgabedatum
    if (self.erinnerungsDatum == nil && self.erinnerungSwitch.on) {
        self.erinnerungsDatum = [abgabeDatum dateByAddingTimeInterval:-24*60*60];
    }
}

- (void)setErinnerungsDatum:(NSDate *)erinnerungsDatum {
    _erinnerungsDatum = erinnerungsDatum;
    
    //das user interface entsprechend konfigurieren
    
    //wenn kein Abgabedatum gegeben ist, dann entsprechend einen Leerstring anzeigen und die Ausführung der Methode unterbrechen
    if (!erinnerungsDatum) {
        self.erinnerungTextfield.text = @"";
        self.erinnerungSwitch.on = NO; //den Switch so konfigurieren, dass die Erinnerung ausgestellt ist
        self.erinnerungTextfield.enabled = NO; //das Erinnerungs-Textfeld deaktivieren, sodass keine Erinnerung gewählt werden kann
        return;
    }
    
    //den DateFormatter, um das Datum entsprechend als String zu bekommen
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd.MM.YYYY"];
    
    //das Datum mit Hilfe des DateFormatters in einen String umwandeln
    NSString *erinnerungsDatumString = [dateFormatter stringFromDate:erinnerungsDatum];
    
    //die Zeit vom erinnerungsDatum bekommen, indem das Format des DateFormatters geändert wird und erneut die Methode stringFromDate: vom DateFormatter aufgerufen wierd
    [dateFormatter setDateFormat:@"HH.mm"];
    NSString *erinnerungsDatumZeitString = [dateFormatter stringFromDate:erinnerungsDatum];
    
    //einen neuen String aus Erinnerungsdatum und der Zeit im erinnerungsTextfield ausgeben
    self.erinnerungTextfield.text = [NSString stringWithFormat:@"%@, %@ Uhr", erinnerungsDatumString, erinnerungsDatumZeitString];
    
    //dem Date-Picker ebenfalls nochmal das erinnerungsDatum zuweisen, falls diese Methode aufgerufen wird, wenn eine Aufgabe bearbeitet wird, sodass später, wenn das erinnerungTextfield angeklickt wird, dort das erinnerungsDatum der aktuellen Aufgabe angezeigt wird und nicht das Standard-Datum vom DatePicker
    self.erinnerungsDatumDatePicker.date = erinnerungsDatum;
}

#pragma mark Kurs-Waehlen
- (IBAction)kursButtonClicked:(id)sender {
    //den KonfigurierteKurseWaehlenViewController mit dem mit diesem Objekt verbundenem Benutzer initialisieren
    KonfigurierteKurseWaehlenViewController *konfKurseWaehlen = [[KonfigurierteKurseWaehlenViewController alloc]initWithUser:self.associatedUser];
    
    //setze das Delegate auf diesen Controller
    konfKurseWaehlen.delegate = self;
    
    //zeige den neuen ViewController an
    [self presentViewController:konfKurseWaehlen animated:YES completion:nil];
    
}

#pragma mark KonfigurierteKurseWaehlenViewControllerDelegate
- (void)didFinishKursWaehlen:(Kurs *)gewaehlterKurs inKonfigurierteKurseWaehlenViewController:(KonfigurierteKurseWaehlenViewController *)kurseWaehlenViewController {
    //setze den zurückgegebenen Wert in die entsprechende Instanzvariable --> der Setter der Instanzvariable stellt das user interface entsprechend ein
    self.kursFuerAufgabe = gewaehlterKurs;
}

#pragma mark Speichern
//speichert die vorhandene Aufgabe oder erstellt eine neue
- (void)speichern {
    
    //zuerst überprüfen, ob genug Daten zu Aufgaben-Erstellung vorhanden sind
    if (self.titelTextfield.text.length > 0 || self.beschreibungTextView.text.length > 0) {
        //eine Aufgaben-Variable deklarieren, die die Aufgabe enthält, die bearbeitet wurde, oder die neu erstellte Aufgabe
        Aufgabe *aufgabeToEdit = self.representedAufgabe;
        
        if (!aufgabeToEdit) {
            //bedeutet, dass eine neue Aufgabe erstellt werden muss
            aufgabeToEdit = [Aufgabe neueAufgabeFuerBenutzer:self.associatedUser mitTitel:self.titelTextfield.text undBeschreibung:self.beschreibungTextView.text];
            
        }
        
        //die Eigenschaften der Aufgabe speichern
        aufgabeToEdit.beschreibung = self.beschreibungTextView.text;
        aufgabeToEdit.titel = self.titelTextfield.text;
        aufgabeToEdit.abgabeDatum = self.abgabeDatum;
        aufgabeToEdit.erinnerungDate = self.erinnerungsDatum;
        aufgabeToEdit.prioritaet = [NSNumber numberWithInteger:self.prioritaetSegmentedControl.selectedSegmentIndex];
        aufgabeToEdit.notizen = self.notizenTextView.text;
        aufgabeToEdit.kurs = self.kursFuerAufgabe;
        
        //die Mediendateien sichern, die hinzugefügt wurden und die, die gelöscht werden sollen, müssen gelöscht werden
        for (MediaFile *tmpMediaFile in self.mediaFilesToAdd) {
            //und die temporären MediaFiles einer Aufgabe zuordnet werden --> bevor man die Dateien speichert, damit das MediaFile weiß, in welchem Ordner es die Daten speichern soll, weil alle MediaFiles für eine Aufgabe in dem gleichen Ordner gespeichert werden sollen
            tmpMediaFile.aufgabe = aufgabeToEdit;
            
            //die temporären MediaFiles "sichern"
            [tmpMediaFile saveTempData];
        }
        //die Mediendateien löschen, die gelöscht werden sollen
        for (MediaFile *mediaFileToDelete in self.mediaFileToDelete) {
            [mediaFileToDelete loeschenWithContextSave:NO];
        }
        
        
        
        //auf jeden Fall angeben, dass die Aufgaben heute zuletzt bearbeitet wurde
        [aufgabeToEdit speichereAenderungsdatum];
        
        
        //Aufgabe speichern
        [aufgabeToEdit sichern];
        
        //den ViewController ausblenden
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        //zeige eine Fehlermeldung an
        [self showErrorMessageWithTitle:@"Fehlende Angaben" andMessage:@"Um eine Aufgabe zu speichern, muss mindestens ein Titel oder eine Beschreibung angegeben werden!"];
    }
    
}


#pragma mark Erinnerung an/aus
//Erinnerungen aktivieren bzw. deaktivieren
- (IBAction)erinnerungSwitchValueChanged:(UISwitch *)sender {
    if (sender.on) {
        //dann ErinnerungTextfield aktivieren
        self.erinnerungTextfield.enabled = YES;
        
        //das Erinnerungsdatum setzen
        if (self.abgabeDatum) {
            self.erinnerungsDatum = [self.abgabeDatum dateByAddingTimeInterval:-24*60*60]; //Beim Anstellen das Standard-Erinnerungsdatum auf einen Tag vorher setzen (vom Abgabedatum)
        }
    }
    else {
        self.erinnerungTextfield.enabled = NO;
        self.erinnerungsDatum = nil;
    }
}

#pragma mark - Fotos für Notizen wählen
//Foto aus Album
- (IBAction)fotoAusAlbumClicked:(UIButton *)sender {
    //überprüfe, ob der Zugang zur Photolibrary erlaubt ist
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    if (authStatus == PHAuthorizationStatusDenied) {
        [self showErrorMessageWithTitle:@"Kein Fotozugriff" andMessage:@"Bitte erlaube in den Einstellungen den Zugriff auf die Fotobibliothek!"];
        return;
    }
    else {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status != PHAuthorizationStatusAuthorized) {
                [self showErrorMessageWithTitle:@"Kein Fotozugriff" andMessage:@"Bitte erlaube in den Einstellungen den Zugriff auf die Fotobibliothek!"];
                return;
            }
        }];
    }
        
    //einen neuen Image-Picker-Controller erstellen
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

//neues Foto aufnehmen
- (IBAction)neuesFotoClicked:(UIButton *)sender {
    //überprüfe, ob der Zugang zur Kamera erlaubt ist
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusDenied) {
        [self showErrorMessageWithTitle:@"Kein Kamerazugriff" andMessage:@"Bitte erlaube in den Einstellungen den Zugriff auf die Kamera!"];
        return;
    }
    else {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (!granted) {
                [self showErrorMessageWithTitle:@"Kein Kamerazugriff" andMessage:@"Bitte erlaube in den Einstellungen den Zugriff auf die Kamera!"];
                return;
            }
        }];
    }
    
    //einen neuen Image-Picker-Controller erstellen
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}




#pragma mark - allgemeine ViewController-Steuerelemente

- (IBAction)cancelButtonClicked:(UIButton *)sender {
    //den aktuellen ViewController wieder ausblende
    
    [self dismissViewControllerAnimated:YES completion:nil]; 
}

- (IBAction)speichernButtonClicked:(UIButton *)sender {
    //die Aufgabe speichern
    [self speichern];
}




#pragma mark - Textfield delegate
//Die genaue Beschreibung und Funktion der folgenden zwei Delegate Methoden: siehe oben Beschreibung der Properties activeField und activeTextView
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    //wenn angefangen wird, ein Textfeld zu bearbeiten, dann "markiere" es entsprechend als aktives Textfeld
    self.activeField = textField;
    
    //wenn es das Erinnerungs-Textfeld oder das Abgabedatum-Textfeld ist, dann setze das Datum, das in dem Textfeld steht für den DatePicker fest
    if (self.erinnerungTextfield == textField) {
        
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil; // wenn kein Textfeld mehr bearbeitet wird, dann ist auch kein Textfeld mehr aktiv
}



#pragma mark - TextView delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.activeTextView = textView;
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    self.activeTextView = textView;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //wenn es ein Textfeld ist, das einen Datums-Picker bzw. einen Datums- und Uhrzeitenpicker enthält, dann darf der User keinen Text einfügen (das ist beim erinnerungsTextfield und beim abgabeDatumTextfield der Fall)
    if (self.erinnerungTextfield == textField || self.abgabeDatumTextfield == textField) {
        return NO;
    }
    else {
        return YES;
    }
}




#pragma mark - ScrollView delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate) {
        //hide keyboard
        
        ///das Keyboard ausblenden, wenn der scrollView sich, nachdem der Finger vom Display angehoben wurde, weiter bewegt (also verzögert) --> in der Regel ist dann schnell gescrollt worden, sodass die Tastatur ausgeblendet werden soll
        [self.activeField resignFirstResponder];
        [self.activeTextView resignFirstResponder];
    }
}




#pragma mark - Keyboard Notification
///wird aufgerufen, wenn die Tastatur angezeigt wird und ändert die contentInsets des ScrollViews entsprechend ab
- (void)keyboardWasShown:(NSNotification *)aNotification {
    //Die Informationen zur Tastatur aus der userInfo-Dictionary von der gegebenen Notification entnehmen
    NSDictionary *info = [aNotification userInfo];
    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey]CGRectValue].size;
    
    //die neuen ContentInsets kalkulieren und dem ScrollView zuweisen
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets; //auch den scrollIndicators die insets zuweisen, damit die scroll-indicators nicht hinter der Tastatur verschwinden, sobald man nach unten scrollt
    
    //wenn das aktive Textfeld oder der aktive TextView vom Keyboard verdeckt wird, scrolle es nach oben
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    
    //definiere den Punkt, für den geprüft werden soll, ob er vom Textfeld verdeckt wird (weil es entweder ein Textfeld oder ein TextView sein könnte
    CGPoint punkToCheck = (self.activeField) ? self.activeField.frame.origin: self.activeTextView.frame.origin;
    
    //überprüfe, ob das aktive Textfeld/der aktive Textview vom Keyboard verdeckt wird
    if (!CGRectContainsPoint(aRect, punkToCheck)) {
        //erstelle den Punkt, zu dem gescrollt werden soll
        
        //dafür erst wieder zwischen Textfeld und Textview unterscheiden
        CGFloat scrollPointY = self.activeField ? self.activeField.frame.origin.y : self.activeTextView.frame.origin.y;
        
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




#pragma mark - Date Picker Methoden für zwei Datepicker (Abgabedatum + Erinnerungsdatum)
///wenn diese Methode aufgerufen wird, wird das Datum im abgabeDatumTextfield entsprechend auf das des abgabeDatumDatePickers geändert
- (void)abgabeDatumDateChanged:(id)sender {
    
    //den Setter aufrufen, welcher auch das Interface-Konfiguriert
    self.abgabeDatum = [self.abgabeDatumDatePicker date];
    
}
///wenn diese Methode aufgerufen wird, wird das Datum im erinnerungsTextfield entsprechend auf das des erinnerungsDatumDatePickers gesetzt
- (void)erinnerungsDateChanged:(id)sender {
    //den Setter aufrufen, welcher auch das user-interface konfiguriert
    self.erinnerungsDatum = [self.erinnerungsDatumDatePicker date];
}


#pragma mark - ImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    //bekomme das Image, das gesichert werden soll
    UIImage *imageToSave;
    
    UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (editedImage) {
        imageToSave = editedImage;
    }
    else {
        imageToSave = originalImage;
    }
    
    //die Daten als JPEG bekommen
    NSData *jpegImageData = UIImageJPEGRepresentation(imageToSave, 1.0);
    
    //ein temporäres MediaFile erstellen, weil die Medien-Dateien noch nicht ins Dateisystem geschrieben werden sollen und auch noch keiner Aufgabe zugewiesen sind
    MediaFile *tempMediaFile = [MediaFile tempMediaFileWithData:jpegImageData inManagedObjectContext:self.associatedUser.managedObjectContext];
    tempMediaFile.typ = [NSNumber numberWithInteger:mediaFileTypeImage];
    tempMediaFile.tempMediaDataFileExtension = @"jpeg";
    
    [self.mediaFilesToAdd addObject:tempMediaFile];
    
    //gleichzeitig die Daten auch zum mediaFiles-array hinzufügen, sodass sie auch im CollectionView angezeigt werden
    [self.mediaFiles addObject:tempMediaFile];
    
    //den CollectionView neuladen
    [self.collectionView reloadData];
    
    //den ImagePickerController verschwinden lassen
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CollectionView delegate
//die Delegate-Methoden für den CollectionView, der die MediaFiles anzeigt
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.mediaFiles.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //Die CollectionViewCell bekommen
    AufgabeMediaCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"aufgabeMediaCollectionViewCell" forIndexPath:indexPath];
    
    //das AufgabeMediaFile für den Index Path bekommen
    MediaFile *mediaFileForIndexPath = [self.mediaFiles objectAtIndex:indexPath.row];
    
    //ein UIImage vom MediaFile erzeugen
    UIImage *mediaImage = [UIImage imageWithData:[mediaFileForIndexPath getMediaData] scale:0.5]; //herunterskalieren, damit die Anzeige flüssiger läuft (eventuell bei hochqualitativen Fotos ein Problem)
    
    cell.imageView.image = mediaImage;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //den MediaFilesDetailViewController anzeigen
    MediaFilesDetailViewController *detailController = [[MediaFilesDetailViewController alloc]initWithMediaFiles:self.mediaFiles startingWithFileAtIndex:indexPath.row andPointerToArrayOfMediaFilesToDelete:self.mediaFileToDelete];
    detailController.parentEditViewController = self;
    
    
    //diesen MediaFilesDetailViewController dann noch in einen NavigationController einbetten, damit die Navigation- und Toolbars von diesem vernünftig angezeigt werden
    
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:detailController];
    navController.toolbarHidden = NO; //die Toolbar anzeigen, damit auch der Trash-Button angezeigt wird
    
    //durchsichtige, schwarzgefärbte Navigationbar und Toolbar
    navController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    navController.toolbar.barStyle = UIBarStyleBlackTranslucent;
    
    //dann diesen NavigationController anzeigen
    [self presentViewController:navController animated:YES completion:nil];
    
}

#pragma mark - andere Methoden
///zeigt eine Fehlermeldung auf dem Bildschrim an
- (void)showErrorMessageWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
