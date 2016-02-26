//
//  AufgabeTableViewCell.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 30.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "AufgabeTableViewCell.h"
#import "Kurs.h"

@implementation AufgabeTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)erledigtButtonClicked:(UIButton *)sender {
    //markiere die Aufgabe als erledigt, und speichere oder markiere sie als nicht erledigt und speichere
    [self.aufgabe setzeErledigt:!self.aufgabe.erledigt.boolValue];
    
    //speichere die Aufgabe
    [self.aufgabe sichern];
}


#pragma mark - Aufgabe-Setter
- (void)setAufgabe:(Aufgabe *)aufgabe {
    //den Wert auf die Instanzvariable setzen
    _aufgabe = aufgabe;
    
    //date formatter für das Abgabedatum
    NSDateFormatter *df = [[NSDateFormatter alloc]init];

    [df setDateFormat:@"dd.MM.YYYY"];
    
    //die Werte in den Labels setzen
    //das Titel-Label
    self.titelLabel.text = (aufgabe.titel.length > 0 ? aufgabe.titel : aufgabe.beschreibung); //Wenn kein Titel vorhanden ist, dann zeige die Beschreibung an (bzw. die ersten paar Buchstaben der Beschreibung)
    
    //das Detail-Label
    NSString *abgabeDatumString = [df stringFromDate:aufgabe.abgabeDatum];
    NSString *kursID = aufgabe.kurs.id;
    
    //der Standard-Text für das Detail-Label, der angezeigt werden soll, wenn kein Abgabedatum und keine Kurs-ID verfügbar ist
    NSString *textFuerDetailLabel = @"für Details bitte tippen";
    
    //wenn ein Abgabedatum gegeben ist, dann zeige das an
    if (abgabeDatumString.length > 0) {
        textFuerDetailLabel = [NSString stringWithFormat:@"Abgabedatum: %@", abgabeDatumString];
    }
    if (kursID.length > 0) {
        //wenn jetzt ein Abgabedatum und eine Kurs-ID gegeben ist, dann zeige beide an
        if (abgabeDatumString.length > 0) {
            textFuerDetailLabel = [textFuerDetailLabel stringByAppendingFormat:@", Kurs: %@", kursID];
        }
        //wenn nur eine Kurs-ID gegeben ist, also kein Abgabedatum, dann zeige nur die Kurs-ID an
        else {
            textFuerDetailLabel = [NSString stringWithFormat:@"Kurs: %@", kursID];
        }
    }
    
    self.detailLabel.text = textFuerDetailLabel;
    
    //wenn die Aufgabe erledigt wurde, zeige einen anderen Button an
    self.erledigtButton.imageView.contentMode = UIViewContentModeScaleAspectFit; //den Content-Mode für den ImageView richtig setzen
    if (aufgabe.erledigt.boolValue) {
        [self.erledigtButton setImage:[UIImage imageNamed:@"ic_offline_pin_48pt"] forState:UIControlStateNormal];
    }
    else {
        [self.erledigtButton setImage:[UIImage imageNamed:@"ic_done"] forState:UIControlStateNormal];
    }
    
}
@end
