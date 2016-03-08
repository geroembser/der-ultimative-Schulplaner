//
//  QuizThemenbereichTableViewCell.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 03.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "QuizThemenbereichTableViewCell.h"
#import "NSDate+AdvancedDate.h" //für erweiterte Date-Funktionen
#import "Frage.h"

@implementation QuizThemenbereichTableViewCell



#pragma mark - Setter überschreiben
- (void)setThemenbereich:(Themenbereich *)themenbereich {
    _themenbereich = themenbereich;
    
    
    //die Werte in die Labels schreiben
    if (themenbereich.name && themenbereich.name.length > 0) {
        self.nameLabel.text = themenbereich.name;
    }
    
    
    //berechnen, wie viele Fragen in dem Themenbereich verfügbar sind und wie viele davon richtig sind
    NSUInteger anzahlFragen = [themenbereich anzahlFragen]; //Anzahl aller Fragen in dem Themenbereich
    
    //noch berechnen, ob man schreibt, 1 Frage oder 2,3... Fragen
    NSString *anzahlString = @"Fragen";
    if (anzahlFragen == 1) {
        anzahlString = @"Frage";
    }
    
    NSUInteger anzahlRichtigerFragen = [themenbereich anzahlRichtigerFragen]; //Anzahl aller richtigen Fragen in dem Themenbereich
    
    float prozent = (anzahlRichtigerFragen/anzahlFragen)*100; //Prozent ist gleich mal hundert
    
    
    //außerdem noch einen String erstellen, der angibt, wann der Themenbereich das letzte Mal aktualisiert wurde
    NSString *dateString = @"--";
    if (themenbereich.zuletztAktualisiert) {
        dateString = [themenbereich.zuletztAktualisiert datumStringAlleine];
    }
    
    
    //die berechneten Werte in dem entsprechenden Label entsprechend formatiert ausgeben
    self.detailLabel.text = [NSString stringWithFormat:@"%lu %@ verfügbar; richtig: %.1f%%; zuletzt aktualisiert: %@", anzahlFragen, anzahlString, prozent, dateString];
    
}

@end
