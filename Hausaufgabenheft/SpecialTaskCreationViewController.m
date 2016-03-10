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

@interface SpecialTaskCreationViewController ()

///ein Array, der alle Kurse enthält, um den entsprechenden Kurs für die Aufgabe zu wählen
@property NSArray *alleKurse;

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
    
    //erstens den eingegebenen, neuen Text in einer Variable zusammenfassen, weil an dieser Stelle die "text"-Property des "textField"s noch den alten Wert enthält, weil diese Methode hier eine ist, die fragt, ob ein neuer Text eingegeben werden darf
    NSString *textfieldsText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
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
            //herausfinden, ob im Namen des Kurses die Eingabe enthalten ist (die Suche ohne Beachtung der Groß- und Kleinschreibung durchführen)
            if (kurs.name && [kurs.name rangeOfString:part options:NSCaseInsensitiveSearch].location != NSNotFound) {
                //dann den Kurs zu dem Array hinzufügen, der die Auswahl der passenden Kurs-Vorschläge enthält
                [passendeKurse addObject:kurs];
            }
        }
        
        //wenn jetzt passende Kurse gefunden wurden, also die Anzahl der Elemente, die im passendeKurse-Array enthalten sind, größer als 0 sind, dann setze diese entsprechend in den SpecialTaskAccessoryView
        if (passendeKurse.count > 0) {
            [(SpecialTaskCreationTextfieldAccessoryView *)self.aufgabeTextfield.inputAccessoryView setPassendeKurse:passendeKurse];
        }
        
    }
    else {
        //das ausgewählte Fach/den ausgewählten Kurs entfernen
        
        //durch Aufruf des Setters der entsprechenden Variable des SpecialTaskCreationTextfieldAccessoryView die darin angezeigten Kurse auf nil setzen --> zeigt keine Vorschläge mehr an
        [(SpecialTaskCreationTextfieldAccessoryView *)self.aufgabeTextfield.inputAccessoryView setPassendeKurse:nil];
        
    }
    
    
    
    return YES;
}

//Textfield-Return angeklickt
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    //hier die Aufgabe erstellen, wenn genügend Angaben gegeben sind
    
    
    //YES zurückgeben, und damit erlauben, dass der Benutzer auf "Fertig" auf der Tastatur klicken kann
    return YES;
}


#pragma mark - Actions
- (IBAction)backgroundTapGestureRecognizerRecognized:(UITapGestureRecognizer *)sender {
    //den ViewController ausblenden
    [self dismissViewControllerAnimated:NO completion:nil];
}
@end
