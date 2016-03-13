//
//  SpecialTaskCreationViewController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 09.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "SpecialTaskCreationViewController.h"
#import "SpecialTaskCreationTextfieldAccessoryView.h"
#import "KurseController.h"
#import "Kurs.h"
#import "Aufgabe.h"

@interface SpecialTaskCreationViewController () <SpecialTaskCreationTextfieldAccessoryViewDelegate>

///ein Array, der alle Kurse enthält, um den entsprechenden Kurs für die Aufgabe zu wählen
@property NSArray *alleKurse;

///die Range, in der der Fachname im aufgabeTextfeld liegt
@property NSRange fachnameRange;

///der Kurs, für den die Aufgabe erstellt werden soll; wenn die Aufgabe unabhängig von einem Kurs sein soll, dann ist der Wert dieser Variable nil
@property Kurs *kursFuerAufgabe;

@end

@implementation SpecialTaskCreationViewController

#pragma mark - Initialisierungen
- (instancetype)init {
    //vom Storyboard initialisieren
    
    self = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"specialTaskCreationViewController"];
    
    if (self) {
        //weitere anwendungsspezifische Konfiguration des Objekts
        
        //wichtig, damit der ViewController transparent angezeigt wird
        [self setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        
        //der Instanzvariable "alleKurse" einen array von allen Kursen zuordnen (mittels des KurseControllers), um je nach Eingabe des Users dynamisch den Kurs zu finden, der zu dieser Aufgabe gehört
        //dafür erstens einen KursController erstellen
        KurseController *kurseController = [KurseController defaultKurseController];
        
        //davon alle Kurse bekommen
        self.alleKurse = [kurseController alleAktivenKurseForCurrentUser]; //alle aktiven Kurse für den user nehmen
    }
    
    return self;
}

#pragma mark - View-Setup
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    //den input-accessory-view vom aufgaben-textfeld setzen
    SpecialTaskCreationTextfieldAccessoryView *inputAccessoryView = [[SpecialTaskCreationTextfieldAccessoryView alloc]init]; //den SpecialTaskCreationTextfieldAccessoryView laden/initialisieren
    
    //das Delgate von diesem inputAccessoryView auf dieses Objekt setzen
    inputAccessoryView.delegate = self;
    
    
    //dem "aufgabeTextfeld" zuweisen
    self.aufgabeTextfield.inputAccessoryView = inputAccessoryView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
        self.view.layer.backgroundColor = [[UIColor colorWithRed:0.39 green:0.39 blue:0.39 alpha:0.9]CGColor];
    }  completion:nil];
    
    //das Textfeld auswählen, sodass die Eingabe sofort beginnen kann
    [self.aufgabeTextfield becomeFirstResponder];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Textfield Delegate
//wird aufgerufen, wenn die Zeichen geändert werden
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    //die Cursor-Position speichern
    UITextPosition *beginning = textField.beginningOfDocument;
    UITextPosition *start = [textField positionFromPosition:beginning offset:range.location];
    
    
    
    //erstens den eingegebenen, neuen Text in einer Variable zusammenfassen, weil an dieser Stelle die "text"-Property des "textField"s noch den alten Wert enthält, weil diese Methode hier eine ist, die fragt, ob ein neuer Text eingegeben werden darf
    NSString *textfieldsText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    //wenn eine fachnameRange (Instanzvariable) vorhanden ist...
    if (self.fachnameRange.length > 0) {
        //..dann ist eine "gültige" Range vorhanden
        
        //folgende Zeilen verhindern, dass der Benutzer, sollte er einen Kurs ausgewählt haben, diesen aus dem Texteld mittels der Backspace-Taste löschen kann
        
        //die Range die bearbeitet werden soll liegt in dem Fall, dass der Benutzer den Fachnamen löschen oder ändern möchte, innerhalb der fachnameRange -> siehe folgene if-Abfrage
        if (range.location < self.fachnameRange.location+self.fachnameRange.length) {
            //jetzt wird das ganze genauer eingeschränkt und nur auf die Backspace-Taste bezogen --> Backspace-Taste wurde gedrückt, wenn der String leer ist, also eine Länge von 0 hat; zusätzlich ist der weitere Teil der if-Abfrage (hinter dem &&) eine weitere Einschränkung der Bedingung: damit wird nun überprüft, ob die Range, die gelöscht werden soll über die fachnameRange hinausragt)...
            if (string.length == 0 && range.location+range.length > self.fachnameRange.location+self.fachnameRange.length) { //also Backspace (Text in gegebener Range löschen...)
                //... wenn das nämlich der Fall ist, bedeutet das, dass die Range, die gelöscht werden soll, innerhalb der fachnameRange beginnt (siehe if-Abfrage 1: range.location <....) und außerhalb davon aufhört
                //--> die Folge ist also, dass der Text nur ab dem Ende der fachnameRange gelöscht werden darf
                textfieldsText = [textField.text stringByReplacingCharactersInRange:NSMakeRange(self.fachnameRange.location+self.fachnameRange.length, range.length-(self.fachnameRange.location+self.fachnameRange.length-range.location)) withString:@""]; //hier wird aber der aktuell im Textfeld stehende Text genommen, nicht der textfieldsText, weil beim textfieldsText schon der Löschvorgang ausgeführt wurde, dwas hier aber nicht sein sollte
                textField.text = textfieldsText; //den ersetzten Text jetzt erneut in das Textfeld setzen
            }
            
            return NO; // in jedem Fall hier NO zurückgeben (außer das Programm stürzt vielleicht ab, oder was auch immer, aber sonst, NO zurückgeben 😂 ....)
        }
    }
    
    NSUInteger previousTextLength = textfieldsText.length; //die Länge des Texts vor dem Ändern von Zeichen etc. in den folgenden Zeilen (aber schon mit Änderungen des replacementStrings)...
    
    //wenn irgendwo (unabhängig von Groß- und Kleinschreibung) der String " s " oder " a " zu finden ist, ersetze diesen durch " S. " (für Seite) und "Aufg." (für Aufgabe) ersetzen
    textfieldsText = [textfieldsText stringByReplacingOccurrencesOfString:@" s " withString:@" S. " options:NSCaseInsensitiveSearch range:NSMakeRange(0, textfieldsText.length)];
    textfieldsText = [textfieldsText stringByReplacingOccurrencesOfString:@" a " withString:@" Aufg. " options:NSCaseInsensitiveSearch range:NSMakeRange(0, textfieldsText.length)];
    
    // die neue Cursor-Position nach dem Einfügen oder Schreiben von Text
    NSInteger cursorOffset = [textField offsetFromPosition:beginning toPosition:start] +string.length + (textfieldsText.length-previousTextLength); //zusätzlich noch plus die Differenz vom alten Text vom Textfeld plus den neuen
    
    textField.text = textfieldsText; //hier den neuen Text in das Textfeld setzen und dafür am Ende dieser Methode NO zurückgeben, damit nicht jede Eingabe doppelt gesetzt wird
    
    
    //diesen neuen Text im Textfeld jetzt in einen Array aufteilen mit zwei oder mehreren Objekten --> das erste Objekt in einem Array, der durch das Trennen der einzelnen String-Teile nach dem Leerzeichen entstanden ist, sollte das Fach angeben
    NSArray *components = [textfieldsText componentsSeparatedByString:@" "];
    
    //nur den ersten davon als Kurs/Fach festlegen
    if (components.count > 0) {
        NSLog(@"%@", components.firstObject);
        NSString *part = components.firstObject;
        //nun herausfinden, ob für den ersten Teil des angegebenen Strings ein Kurs verfügbar ist, in dessen Name dieser erste Teil des eingegebenen Strings vorkommt
        NSMutableArray *passendeKurse = [NSMutableArray new]; //der Array mit den Kursen, die zu der Suche passen...
        
        //durch alle Kurse gehen
        for (Kurs *kurs in self.alleKurse) {
            NSLog(@"kursname: %@", kurs.name);
            
            //herausfinden, ob im Namen des Faches des Kurses die Eingabe enthalten ist (die Suche ohne Beachtung der Groß- und Kleinschreibung durchführen)
            if (kurs.fach && [kurs.fach rangeOfString:part options:NSCaseInsensitiveSearch].location != NSNotFound) {
                //dann den Kurs zu dem Array hinzufügen, der die Auswahl der passenden Kurs-Vorschläge enthält
                [passendeKurse addObject:kurs];
            }
        }
        NSLog(@"passende Kurse: %@", passendeKurse);
        
        //setze die passenden Kurse entsprechend in den SpecialTaskAccessoryView (wenn jetzt keine passenden Kurse gefunden wurden, also die Anzahl der Elemente, die im passendeKurse-Array enthalten sind, kleiner als 1 ist, dann wird das von der setPassendeKurse-Methode beachtet)
        [(SpecialTaskCreationTextfieldAccessoryView *)self.aufgabeTextfield.inputAccessoryView setPassendeKurse:passendeKurse];
        
    }
    else {
        //das ausgewählte Fach/den ausgewählten Kurs entfernen
        
        //durch Aufruf des Setters der entsprechenden Variable des SpecialTaskCreationTextfieldAccessoryView die darin angezeigten Kurse auf nil setzen --> zeigt keine Vorschläge mehr an
        [(SpecialTaskCreationTextfieldAccessoryView *)self.aufgabeTextfield.inputAccessoryView setPassendeKurse:nil];
        
    }
    
    //die neue Cursor-Positon setzen
    UITextPosition *newCursorPosition = [textField positionFromPosition:textField.beginningOfDocument offset:cursorOffset];
    UITextRange *newSelectedRange = [textField textRangeFromPosition:newCursorPosition toPosition:newCursorPosition];
    [textField setSelectedTextRange:newSelectedRange];
    
    
    return NO; //in jedem Fall NO zurückgeben, weil der Text manuell in das Textfeld gesetzt wird (siehe weiter oben in dieser Methode)
}

//Textfield-Return angeklickt
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    //hier die Aufgabe erstellen, wenn genügend Angaben gegeben sind
    
    //die Beschreibung der Aufgabe finden
    NSString *beschreibung = @"";
    
    //dabei unterscheiden, ob für die Aufgabe ein Kurs gewählt wurde, oder ob kein Kurs gewählt wurde
    if (self.kursFuerAufgabe) {
        //wenn ein Kurs für diese Aufgabe gewählt wurde, dann ist die Beschreibung der Aufgabe der Bereich des Texts des Aufgaben-Textfelds ab der fachnameRange-Instanzvariable (wenn diese gültig ist, also eine Länge von mehr als 0 hat)
        if (self.fachnameRange.length > 0 && self.fachnameRange.location+self.fachnameRange.length < textField.text.length) {
            beschreibung = [textField.text substringFromIndex:self.fachnameRange.location+self.fachnameRange.length];
        }
    }
    else {
        //ansonsten ist die Beschreibung der Aufgabe der gesamte Inhalt des Textfelds
        beschreibung = textField.text;
    }
    
    //eine neue Aufgabe erstellen (Aufgabe-Objekt)
    
    Aufgabe *neueAufgabe = [Aufgabe neueAufgabeFuerBenutzer:[User defaultUser] mitTitel:@"" undBeschreibung:beschreibung];
    neueAufgabe.kurs = self.kursFuerAufgabe;
    
    [textField resignFirstResponder];
    
    //den aktuellen ViewController ausblenden
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //YES zurückgeben, und damit erlauben, dass der Benutzer auf "Fertig" auf der Tastatur klicken kann
    return YES;
}

#pragma mark - SpecialTaskCreationTextfieldAccessoryViewDelegate
- (void)specialTaskCreationTextfieldAccessoryView:(SpecialTaskCreationTextfieldAccessoryView *)accessoryView didSelectKurs:(Kurs *)ausgewaehlterKurs {
    
    //den Kurs der entsprechenden Instanzvariable von diesem Objekt zuweisen
    self.kursFuerAufgabe = ausgewaehlterKurs;
    
    //wenn ein Kurs gesetzt wurde, formatiere den Text im Aufgaben-Eingabe-Textfeld entsprechend, der das Fach angibt, ansonsten, wenn ausgewaehlterKurs gleich nil ist, entferne diese besondere Formatierung
    
    if (ausgewaehlterKurs) {
        //den Fachnamen bekommen
        NSString *fachname = ausgewaehlterKurs.fach;
        
        //wenn ein Fachname gegeben ist, ändere die Formatierung entsprechend weiter ab...
        if (fachname && fachname.length > 0) {
            //den ersten Teil des Textes, in dem der Fachname steht, anders formatieren
            
            //finde den Bereich, in dem im Textfeld der Fachname steht (der Bereich ist so definiert, dass es vom Anfang des Strings bis zum ersten vorkommenden Leerzeichen, vor dem irgendwelche anderen Zeichen außer dem Leerzeichen sind, oder eben bis zum Ende, wenn der String zum Beispiel gar kein Leerzeichen enthält oder auf ein anderes Zeichen, außer dem Leerzeichen, endet)
            
            BOOL anderesZeichenGefunden = NO;
            
            NSString *text = self.aufgabeTextfield.text;
            
            int rangeEndIndex = -1; //-1 gibt an, dass der End-Index noch nicht definiert wurde
            
            for (int i = 0; i < text.length; i++) { //beim zweiten Zeichen anfangen --> wenn der String eh nur ein Zeichen hat, dann setze den Fachnamen einfach komplett in den Text
                NSString *zeichen = [text substringWithRange:NSMakeRange(i, 1)];
                
                if (![zeichen isEqualToString:@" "]) {
                    anderesZeichenGefunden = YES;
                }
                else if (anderesZeichenGefunden) {
                    rangeEndIndex = i;
                    break;
                }
            }
            
            //den String festlegen, der in dem Textfeld als Fachname angezeigt werden soll
            NSString *fachnameTextfieldString = [NSString stringWithFormat:@"%@ : ", fachname]; //der Fachname gefolgt von einem Leerzeichen, einem Doppelpunkt und einem erneuten Leerzeichen
            
            //eine Range erstellen, in der dieser fachnameTextfieldString im späteren Text liegt, diese in einer Instanzvariable speichern, um diese später dazu zu benutzen vom Textfeld den Kursnamen vom restlichen Teil zu unterscheiden
            self.fachnameRange = NSMakeRange(0, fachnameTextfieldString.length); //diese Range definiert sich durch den Beginn am Anfang des Strings und durch eine Länge die logischerweise genauso lang ist, wie der Text, der in diesem Bereich stehen soll
            
            if (!anderesZeichenGefunden || rangeEndIndex == -1) {
                //wenn kein anderes Zeichen gefunden wurde oder dieses am Ende des Strings liegt (wenn rangeEndIndex == -1 ist, sollte das so sein!), dann ist der ganze String der Bereich für den Fachnamen
                self.aufgabeTextfield.text = fachnameTextfieldString;
            }
            else {
                //ansonsten definiere die Range, in der der Fachname liegt
                NSRange fachnameRange = NSMakeRange(0, rangeEndIndex+1); //von 0 bis zum rangeEndIndex+1 (wegen Länge... --> siehe Dokumentation von NSMakeRange(...))
                
                //in diesem Bereich den fachnameTextfieldString setzen
                self.aufgabeTextfield.text = [text stringByReplacingCharactersInRange:fachnameRange withString:fachnameTextfieldString];
            }
        }
    }
    else {
        //folgendes nur machen, wenn die fachnameRange gültig is
        if (self.fachnameRange.length > 0) {
            //entferne den Bereich des fachname-Texts im aufgabe-Textfeld, der angibt, dass ein Kurs ausgewählt wurde, aber nur wenn der String in dem Textfeld länger ist, als der Bereich, der entfernt werden soll
            NSRange rangeToDelete = NSMakeRange(self.fachnameRange.location+self.fachnameRange.length-3, 3); //die Range, die entfernt werden soll
            if (rangeToDelete.location+rangeToDelete.length < self.aufgabeTextfield.text.length) {
                self.aufgabeTextfield.text = [self.aufgabeTextfield.text stringByReplacingCharactersInRange:rangeToDelete withString:@" "]; //den String " : " durch " " (ein einfaches Leerzeichen") ersetzen
                
                //die fachnameRange zurücksetzen
                self.fachnameRange = NSMakeRange(0, 0); //eine leere-Range... ist "ungefähr" gleich entsprechend zu nil
            }
        }
        
    }
}
- (void)specialTaskCreationTextfieldAccessoryView:(SpecialTaskCreationTextfieldAccessoryView *)accessoryView didSelectAbgabedatum:(NSDate *)abgabedatum {
    
}


#pragma mark - Actions
- (IBAction)backgroundTapGestureRecognizerRecognized:(UITapGestureRecognizer *)sender {
    //den ViewController ausblenden
    [self dismissViewControllerAnimated:NO completion:nil];
}
@end
