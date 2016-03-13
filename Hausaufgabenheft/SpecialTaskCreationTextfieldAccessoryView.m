//
//  SpecialTaskCreationTextfieldAccessoryView.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 09.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "SpecialTaskCreationTextfieldAccessoryView.h"

@implementation SpecialTaskCreationTextfieldAccessoryView

#pragma mark - Initialisierung
- (instancetype)init {
    
    //aus dem Nib-File den View nehmen
    self = [[[NSBundle mainBundle] loadNibNamed:@"SpecialTaskCreationTextfieldAccessoryView" owner:self options:nil]firstObject];
    
    [self showAbgabedatumButtons:NO animated:NO];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    
    return self;
}


#pragma mark - View Setup
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

#pragma mark - Attribute (Setter überschreiben)
- (void)setPassendeKurse:(NSArray<Kurs *> *)passendeKurse {
    //die neuen Kurse speichern
    _passendeKurse = passendeKurse;
    
    //wenn ein Kurs ausgewählt wurde, also die ausgewaehlterKurs-Property nicht nil ist, dann muss überprüft werden, ob der Kurs immer noch im passende Kurse-Array enthalten ist --> das kann aber nur in einem Array überprüft werden, wenn dieser nicht nil ist und logischerweise auch mehr als ein Element enthält
    if (self.ausgewaehlterKurs && passendeKurse && passendeKurse.count > 0) {
        //dann überprüfen, ob dieser Kurs auch im passendeKurse-array, welcher als Parameter übergeben wurde, enthalten ist
        if (![passendeKurse containsObject:self.ausgewaehlterKurs]) {
            //dann die beiden Buttons entsprechend nicht mehr als markiert anzeigen
            [self.ersterKursVorschlagButton markiere:NO];
            [self.zweiterKursVorschlagButton markiere:NO];
            
            //den ausgewählten Kurs auf nil setzen
            self.ausgewaehlterKurs = nil;
        }
    }
    if (passendeKurse && passendeKurse.count > 0) { //nur wenn überhaupt passende Kurse übergeben wurden
        //die neuen, passenden Kurse auf dem Bildschrim darstellen
        //die ersten beide Vorschläge aus dem "passendeKurse"-Array nehmen
        Kurs *ersterVorschlag = passendeKurse.firstObject; //dieser Aufruf kann hier ohne weiteres erfolgen, weil firstObject im Fall von keinem ersten Element (also 0 Elementen im Array) auch nil zurückgeben sollte - im Gegensatz zur "objectAtIndex"-Methode der Klasse NSArray
        Kurs *zweiterVorschlag = nil; //erstmal mit nil initialisieren --> bedeutet theoretisch einen String für den Button von "---"
        
        //nur wenn mehr als ein Kurs im passendeKurse-Array ist, den zweiten Vorschlag setzen
        if (passendeKurse.count > 1) {
            zweiterVorschlag = [passendeKurse objectAtIndex:1];
        }
        
        
        //die beiden Vorschläge den beiden Buttons zuweisen
        self.ersterKursVorschlagButton.kurs = ersterVorschlag;
        self.zweiterKursVorschlagButton.kurs = zweiterVorschlag;
    }
    else {
        //beiden Vorschlag-Buttons nil zuweisen, also "---" als Titel der Buttons setzen (macht der Setter der kurs-Property)
        self.ersterKursVorschlagButton.kurs = nil;
        self.zweiterKursVorschlagButton.kurs = nil;
        
        //beide Buttons nicht mehr markieren
        [self.ersterKursVorschlagButton markiere:NO];
        [self.zweiterKursVorschlagButton markiere:NO];
        
        //dann ist auch kein Kurs mehr ausgewählt
        self.ausgewaehlterKurs = nil;
    }
}

- (void)setAusgewaehlterKurs:(Kurs *)ausgewaehlterKurs {
    _ausgewaehlterKurs = ausgewaehlterKurs; //der Instanzvariable zuweisen
    
    //den Setter vom ausgewählten Kurs überschreiben, damit bei jedem setzen auch die entsprechende Delegate-Methode aufgerufen wird
    //Delegate-Nachricht "posten"
    if (self.delegate && [self.delegate respondsToSelector:@selector(specialTaskCreationTextfieldAccessoryView:didSelectKurs:)]) {
        [self.delegate specialTaskCreationTextfieldAccessoryView:self didSelectKurs:ausgewaehlterKurs]; //die Delegate-Methode mit dem ausgewählten Kurs aufrufen
    }
}

#pragma mark - Actions - Vorschlag-Buttons
- (IBAction)ersterKursVorschlagButtonClicked:(id)sender {
    //der Button, der angeklickt wurde
    SpecialTaskCreationKursButton *clickedButton = (SpecialTaskCreationKursButton *)sender;
    
    if (clickedButton.ausgewaehlt) {
        //wenn der Button bereits ausgwählt ist, dann wähle diesen nicht mehr aus und zeige an, dass kein Kurs mehr ausgewählt wurde
        [clickedButton markiere:NO];
        self.ausgewaehlterKurs = nil;
        
        //die Abgabedatum-Buttons ausblenden
        [self showAbgabedatumButtons:NO animated:YES];
    }
    else {
        //den Kurs, der angeklickt wurde, in einer Variable speichern
        Kurs *selectedKurs = self.passendeKurse.firstObject;
        
        //folgendes nur machen, wenn auch ein Kurs verfügbar ist
        if (selectedKurs) {
            //die Instanz-Varibale setzen
            self.ausgewaehlterKurs = selectedKurs; //teilt dem Delegate von diesem Objekt auch mit, dass ein Kurs ausgewählt wurde --> wird im Setter der Property ausgewaehlterKurs gemacht
            
            //den ersten Button als markiert darstellen
            [clickedButton markiere:YES];
            
            
            //den anderen Vorschlag-Button nicht mehr markieren
            [self.zweiterKursVorschlagButton markiere:NO];
            
            //die Abgabedatum-Buttons anzeigen
            [self showAbgabedatumButtons:YES animated:YES];
        }
    }
}

- (IBAction)zweiterKursVorschlagButtonClicked:(id)sender {
    //der Button, der angeklickt wurde
    SpecialTaskCreationKursButton *clickedButton = (SpecialTaskCreationKursButton *)sender;
    
    if (clickedButton.ausgewaehlt) {
        //wenn der Button bereits ausgwählt ist, dann wähle diesen nicht mehr aus und zeige an, dass kein Kurs mehr ausgewählt wurde
        [clickedButton markiere:NO];
        self.ausgewaehlterKurs = nil;
        
        //die Abgabedatum-Buttons ausblenden
        [self showAbgabedatumButtons:NO animated:YES];
    }
    else {
        //den Kurs, der angeklickt wurde, in einer Variable speichern
        Kurs *selectedKurs = nil;
        if (self.passendeKurse.count > 1) {
            selectedKurs = [self.passendeKurse objectAtIndex:1];
        }
        
        //folgendes nur machen, wenn auch ein Kurs verfügbar ist
        if (selectedKurs) {
            //die Instanz-Varibale setzen
            self.ausgewaehlterKurs = selectedKurs; //teilt dem Delegate von diesem Objekt auch mit, dass ein Kurs ausgewählt wurde --> wird im Setter der Property ausgewaehlterKurs gemacht

            
            //den zweiten Button als markiert darstellen
            [clickedButton markiere:YES];
            
            //den anderen Vorschlag-Button nicht mehr markieren
            [self.ersterKursVorschlagButton markiere:NO];
            
            //die Abgabedatum-Buttons anzeigen
            [self showAbgabedatumButtons:YES animated:YES];
        }
        
        
    }
    
}

- (IBAction)naechsteStundeAbgabedatumButtonClicked:(id)sender {
    
}

#pragma mark - Actions - Abgabedatum-Buttons
- (IBAction)in2TagenAbgabedatumButtonClicked:(id)sender {
    
}
- (IBAction)in1WocheAbgabedatumButtonClicked:(id)sender {
    
}

#pragma mark - Abgabedatum-Buttons-Animationen
///der Aufruf dieser Methoden zeigt die Abgabedatum-Buttons an oder blendet sie aus (optional auch animiert)
- (void)showAbgabedatumButtons:(BOOL)show animated:(BOOL)animated {
    CGFloat heightConstant = show ? 40.0 : 0;
    
    if (!animated) {
        self.abgabedatumReiheHeightConstraint.constant = heightConstant;
        
        [self layoutIfNeeded];
        return;
    }
    
    [self layoutIfNeeded];
    [UIView animateWithDuration:0.5 animations:^{
        self.abgabedatumReiheHeightConstraint.constant = heightConstant;
        [self layoutIfNeeded];
    }];
}

@end
