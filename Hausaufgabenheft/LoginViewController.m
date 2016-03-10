//
//  LoginViewController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 25.10.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "LoginViewController.h"
#import "ServerUserDataController.h"
#import "KurseWaehlenViewController.h"

@interface LoginViewController () <ServerUserDataControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIScrollViewDelegate> {
    UITextField *activeField; //das aktuell aktive Textfeld, was immer wieder durch die Delegate-Methoden von den Textfeldern gesetzt wird
    UIPickerView *stufePickerView; //der Picker-View für die Auswahl der Stufe
    NSArray *pickerViewStufen; //array von Strings mit Stufenbezeichnungen für den stufePickerView
    ServerUserDataController *currentServerUserDataController; ///die Instanz des ServerUserDataControllers für dieses Objekt
}

@end

@implementation LoginViewController

#pragma mark Standard-Methoden

/**
 Die Standard ViewDidLoad-Methode
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Die Benachrichtigunen für das Anzeigen und Verschwinden des Keyboards registrien, um die ContentInsets des ScrollViews entsprechend zu ändern
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardDidHideNotification object:nil];
    
    //einen Input-Accessory-View zum Stufen-Textfeld setzen
    UIToolbar *toolbar = [[UIToolbar alloc]init];
    [toolbar setBarStyle:UIBarStyleDefault];
    toolbar.userInteractionEnabled = YES;
    [toolbar sizeToFit];
    
    //die einzelnen BarButtonItems setzen
    UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *fertigButton = [[UIBarButtonItem alloc]initWithTitle:@"fertig" style:UIBarButtonItemStylePlain target:self action:@selector(resignFirstResponderOfActiveField)];
    
    //die Items der Toolbar zuweisen
    [toolbar setItems:@[spaceButton, fertigButton]];
    
    self.stufeTextfield.inputAccessoryView = toolbar;
    
    
    //konfiguriere den Input-View für das Stufe textfield
    stufePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    
    stufePickerView.delegate = self;
    
    pickerViewStufen = @[@"EF", @"Q1", @"Q2"];
    
    //den Cursor vom Stufen-Textfeld ausblenden
    self.stufeTextfield.tintColor = [UIColor clearColor];
    
    
    
    //den ServeruserDataController erstellen mit dem Standard-Benutzer (oder eben nil)
    currentServerUserDataController = [[ServerUserDataController alloc]initWithUser:[User defaultUser]];
    currentServerUserDataController.delegate = self;
    
    //isAlreadyLoggedI = in neuer Version [User defaultUser] != nil;
    if (currentServerUserDataController.associatedUser) {
        //User-Interface so konfigurieren, dass es entsprechend aussieht, dass der Benutzer bereits angemeldet gewesen ist
        self.emailTextfield.text = currentServerUserDataController.associatedUser.benutzername;
        
        //einfach ein Test-Passwort setzen
        self.passwordTextfield.text = @"einTestPasswort....";
        
        //die drei Textfelder deaktivieren
        self.emailTextfield.enabled = NO;
        self.passwordTextfield.enabled = NO;
        self.stufeTextfield.enabled = NO;
        
        
        //Anmelde-Button deaktivieren
        self.loginButton.enabled = NO;
        
        //Abmelde-Button anzeigen
        self.logoutButton.hidden = NO;
        
        //weiter-Button anzeigen (nicht animiert), um zum Kurse-Auswählen-ViewController zu gelangen
        [self showWeiterButtonAnimated:NO];
        
        
    }
    else {
        NSLog(@"noch nicht angemeldet");
        //das Vorwärtsgehen im Anmelde-Prozess deaktivieren
    }
    
}

/**
 Methode, die aufgerufen wird, wenn der Speicher knapp wird.
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 Methode die aufgerufen wird, wenn der View erscheint
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark Login-User-Interface-Methoden
///Methode, die ausgeführt wird, wenn der User den Login-Button gedrückt hat.
- (IBAction)loginClicked:(UIButton *)sender {
    
    //die Tastatur ausblenden, vom aktuell aktiven Textfeld, weil der Anmelde-Knopf gedrückt werden kann, wenn sowohl das Username/Email-Textfeld als auch das Passwort-Textfeld ausgewählt sind
    [activeField resignFirstResponder];
    
    //mit den Informationen aus den Textfelder einloggen
    [self loginWithInformationFromTextfields];
}


#pragma mark Logut-User-Interface-Methoden
///Methode die ausgeführt wird, wenn der User den Logout-Button gedrückt hat.
- (IBAction)logoutClicked:(id)sender {
    //Tastatur ausblenden
    [activeField resignFirstResponder];
    
    //abmelden
    [currentServerUserDataController logout];
}

#pragma mark Login-Methoden
///Die Methdoe führt die entsprechenden Schritt zur Anmeldung aus, indem es die gegebenen Daten aus den Textfeldern nimmt und gegebenenfalls überprüft und Fehlermeldungen ausgibt.
- (void)loginWithInformationFromTextfields {
    //als erstes die Eingaben überprüfen
    if (self.emailTextfield.text.length < 1 && self.passwordTextfield.text.length < 1) {
        [self showErrorMessage:@"Bitte gib den Benutzernamen/E-Mail und dein Passwort ein!"];
        return;
    }
    else if (self.emailTextfield.text.length < 1) {
        [self showErrorMessage:@"Bitte gib deinen Benutzernamen oder deine E-Mail Adresse an!"];
        return;
    }
    else if (self.passwordTextfield.text.length < 1) {
        [self showErrorMessage:@"Bitte gib dein Passwort ein, um dich anzumelden!"];
        return;
    }
    else if (self.stufeTextfield.text.length < 1) {
        [self showErrorMessage:@"Bitte wähle eine Stufe aus!"];
        return;
    }
    
    //username bekommen
    NSString *username = self.emailTextfield.text;
    
    //Passwort bekommen
    NSString *password = self.passwordTextfield.text;
    
    
    //überprüfen, ob man bereits angemeldet ist
    if (currentServerUserDataController.associatedUser) {
        //wenn man bereits angemeldet ist, dann fragen, ob man sich erneut anmelden möchte oder den Schritt überspringen möchte
        
    }
    else {
        //neu anmelden, indem die entsprechende Methode des ServerUserDataControllers aufgerufen wird.
        [currentServerUserDataController loginUserWithUsername:username andPassword:password andStufe:self.stufeTextfield.text];
        
        //ab jetzt in den Delegates reagieren und vorerst warten, bzw. in einer der Delegate-Methoden den Activity Indicator anzeigen
    }
    
}

#pragma mark ServerUserDataController Delegate
///Die Methode wird vom ServerUserDataController aufgerufen, wenn der Login-Vorgang beginnt und aktualisiert das Interface entsprechend.
- (void)loginDidStart {
//    User-Interface --> Main-Thread
    dispatch_async(dispatch_get_main_queue(), ^{
        //den Activity Indicator anzeigen und animieren
        self.loginActivityIndicator.hidden = NO;
        [self.loginActivityIndicator startAnimating];
        
        //die Eingabefelder deaktivieren
        self.emailTextfield.enabled = NO;
        self.passwordTextfield.enabled = NO;
        
        //den Anmelde-Button deaktivieren
        self.loginButton.enabled = NO;
    
    });
}

///Die Methode wird vom ServerUserDataController aufgerufen, wenn der Login Vorgang erfolgreich oder unverfolgreich beendet wurde und aktualisiert das Interface entsprechend.
- (void)loginEndSuccessfully:(BOOL)successful withError:(NSError *)error {
    
    //    User-Interface --> Main-Thread
    dispatch_async(dispatch_get_main_queue(), ^{
        //den Activity Indicator verbergen und die Animation beenden
        self.loginActivityIndicator.hidden = YES;
        [self.loginActivityIndicator stopAnimating];
        
        if (!successful) {
            //die Eingabefelder aktivieren, wenn der Login fehlgeschlagen ist
            self.emailTextfield.enabled = YES;
            self.passwordTextfield.enabled = YES;
            
            //den Anmelde-Button aktivieren
            self.loginButton.enabled = YES;
         
            //Fehler ausgeben
            [self showErrorMessage:[error localizedDescription]];
        }
        else {
            //den Abmelde-Button anzeigen
            self.logoutButton.hidden = NO;
            
//            //das Vorwärtsgehen im Anmelde-Prozess aktivieren
//            self.parentPageViewController.canGoForward = YES;
            //statt des hier direkt drüber auskommentiertem
            
            //den Weiter-Button animiert anzeigen
            [self showWeiterButtonAnimated:YES];
            
            
            //weiter gehen im Anmelde-Prozess oder wo auch immer - kann durch den Benutzer jetzt manuell durch einen Klick auf den Weiter-Button geschehen
        }
    });
    
}

///Die Methode wird aufgerufen, wenn der ServerUserDataController den Logout-Vorgang erfolgreich oder unerfolgreich beendet hat und aktualisert das UI entsprechend bzw. gibt die Fehlermeldung aus.
- (void)logoutEndSuccessfully:(BOOL)successful withError:(NSError *)error {
    if (successful) {
        dispatch_async(dispatch_get_main_queue(), ^{
        
            //abmelde-Button ausblenden
            self.logoutButton.hidden = YES;
            
            //anmelde-Button aktivieren
            self.loginButton.enabled = YES;
            
            //die Eingabefelder aktivieren und deren Text zurücksetzen
            self.emailTextfield.enabled = YES;
            self.passwordTextfield.enabled = YES;
            self.stufeTextfield.enabled = YES;
            self.emailTextfield.text = @"";
            self.passwordTextfield.text = @"";
            self.stufeTextfield.text = @"";
            
            
            //den Weiter-Button animiert ausblenden
            [self hideWeiterButtonAnimated:YES];
            
            //alle nachfolgenden ViewController im parentPageViewController löschen
            [self.parentPageViewController removeViewControllersFromIndex:self.parentPageViewController.currentPageIndex+1 toIndex:self.parentPageViewController.sourceViewControllers.count-1];
            
        });
    }
}


- (void)successfullyLoggedInAndCreatedDatabaseInstanceForUser:(User *)newCreatedUser withServerUserDataController:(ServerUserDataController *)serverUserDataController {
    NSLog(@"%@", newCreatedUser);
}

#pragma mark Textfield Delegate
//die Standard Methoden für die Textfelder

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeField = textField;
    
    //überprüfen, ob das gewählte Textfeld das Stufen-Textfeld ist, dann nämlich als Input View den StufenPickerView nehmen
    if (textField == self.stufeTextfield) {
        textField.inputView = stufePickerView;
        
        //und den aktuell ausgewählten Wert im ersten Komponenten des stufePickerViews direkt in das Textfeld schreiben, wenn der Text davon noch leer ist
        if (textField.text.length < 1) {
            //den aktuell ausgewählten Wert der aktuell ausgewählten Zelle des Komponenten des stufePickerViews nehmen
            textField.text = [pickerViewStufen objectAtIndex:[stufePickerView selectedRowInComponent:0]];
        }
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    activeField = nil;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextfield) {
        //Email/username textfield
        [textField resignFirstResponder];
        [self.passwordTextfield becomeFirstResponder];
        
        return YES;
    }
    else  if (textField == self.passwordTextfield) {
        //then try logging in
        
        [self loginWithInformationFromTextfields];
     
        [textField resignFirstResponder];
        
        return YES;
    }
    
    return NO;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.stufeTextfield) {
        //Im Stufentextfeld keine Eingaben erlauben (auch keine Eingaben hereinkopieren, sondern nur die Werte vom UIPickerView
        return NO;
    }
    return YES;
}

#pragma mark - andere Textfield Methoden
///die Bearbeitung vom aktuellen Textfeld wird dadurch abgebrochen
- (void)resignFirstResponderOfActiveField {
    [activeField resignFirstResponder];
}

#pragma mark - PickerView Delegate
//Die üblichen Delegate Methdoen für den UIPickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return pickerViewStufen.count;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.stufeTextfield.text = [NSString stringWithFormat:@"%@", [pickerViewStufen objectAtIndex:row]];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [pickerViewStufen objectAtIndex:row];
}



#pragma mark - Weiter-Button
///führt Schritte aus, wenn auf den Weiter-Button geklickt wurde.
- (void)weiterButtonClicked:(id)sender {
    //überprüfen, ob der aktuelle Benutzer des ServerUserDataControllers eingeloggt ist
    if (currentServerUserDataController.associatedUser.loggedIn.boolValue) {
        //den nächsten Stundenplan/KursAuswählen-Controller anzeigen
        //erstellt einen neuen KurseViewController mit dem Benutzer, der aktuell vom ServerUserDataController verwaltet wird
        KurseWaehlenViewController *kWController = [[KurseWaehlenViewController alloc]initWithUser:currentServerUserDataController.associatedUser];
        
        //das Update der Kurse im KurseWaehlenViewController starten (wenn dieser also direkt nach der Anmeldung geöffnet wird)
        kWController.shouldStartKurseUpdate = YES;
        
        //nur einen neuen KursWaehlenViewController zum parentPageViewController hinzufügen, wenn in seinem SourceViewControllers-array kein Objekt der Klasse KursWaehlenViewController enthalten ist.
        __block BOOL shouldAddViewController = YES;
        [self.parentPageViewController.sourceViewControllers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[KurseWaehlenViewController class]]) {
                shouldAddViewController = NO;
            }
        }];
        
        if (shouldAddViewController) {
            [self.parentPageViewController addViewController:kWController];
        }
        
        //step forward im IntroPageViewController
        [self.parentPageViewController stepForward];
    }
}

///weiter-Button ausblenden (animiert/nicht animiert)
- (void)showWeiterButtonAnimated:(BOOL)animated {
    self.weiterButton.hidden = NO;
    if (animated) {
        [self.weiterButton layoutIfNeeded];
        [UIView animateWithDuration:0.5 animations:^{
            self.weiterButtonHeightConstraint.constant = 58;
            [self.weiterButton layoutIfNeeded];
        } completion:nil];
    }
    else {
        self.weiterButtonHeightConstraint.constant = 58;
    }
}

///weiter-Button ausblenden (animiert/nicht animiert)
- (void)hideWeiterButtonAnimated:(BOOL)animated {
    if (animated) {
        [self.weiterButton layoutIfNeeded];
        [UIView animateWithDuration:0.5 animations:^{
            self.weiterButtonHeightConstraint.constant = 0;
            [self.weiterButton layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (finished) {
                self.weiterButton.hidden = YES;
            }
        }];
    }
    else {
        self.weiterButton.hidden = YES;
    }
    
}

#pragma mark - Allgemeine Methoden
///Methode, die eine Fehlermeldung während des Logins ausgibt
- (void)showErrorMessage:(NSString *)errorMessage {
    //mithilfe eines UIAlertController
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Fehler" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
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
    
    //definiere den Punkt, für den geprüft werden soll, ob er vom Textfeld verdeckt wird
    CGPoint punkToCheck = activeField.frame.origin;
    
    //überprüfe, ob das aktive Textfeld vom Keyboard verdeckt wird
    if (!CGRectContainsPoint(aRect, punkToCheck)) {
        //erstelle den Punkt, zu dem gescrollt werden soll
        
        //dafür erst wieder zwischen Textfeld und Textview unterscheiden
        CGFloat scrollPointY = activeField.frame.origin.y;
        
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


#pragma mark - ScrollView-Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //wenn der ScrollView fertig gescrollt wurde, die Tastatur ausblenden
    [activeField resignFirstResponder];
}

@end
