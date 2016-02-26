//
//  StundenplanTableViewCell.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 29.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "StundenplanTableViewCell.h"
#import "Kurs.h"
#import "Lehrer.h"
#import "StundenplanWochentag.h"

@implementation StundenplanTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


//Die setSchulstunde-Methode überschreiben, weil diese jeweils immer die Einstellungen für eine Schulstunde setzt
- (void)setStunde:(Stunde *)stunde {
    _stunde = stunde;
    
    //wenn es eine Freistunde ist oder die gegebene Stunde == nil,...
    if (stunde == nil || stunde.freistunde) {
        ///... setzte die Werte der Labels entsprechend
        self.stundenNummerLabel.text = @"";
        self.fachNameLabel.text = @"FREISTUNDE";
        self.lehrerNameLabel.text = @"";
        self.raumLabel.text = @"";
    }
    else {
        self.stundenNummerLabel.text = [NSString stringWithFormat:@"%lu", stunde.stunde];
        self.fachNameLabel.text = stunde.schulstunde.kurs.name;
        self.lehrerNameLabel.text = [stunde.schulstunde.lehrer printableTeacherString];
        self.raumLabel.text = stunde.schulstunde.raumnummer;
        
        
        //die Anzeige für Vertretungsstunden hier konfigurieren
        //die Vertretungsstunde für den Wochentag mit dem Datum
        Vertretung *vertretung = [stunde vertretungFuerDatum:stunde.wochentagStundenplan.datum];
        if (vertretung) {
            //überprüfen, ob die Stunde frei ist
            if (vertretung.isFrei) {
                //dann "streiche die Stunde im Titel-Label durch"
                NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]initWithString:stunde.schulstunde.kurs.name];
                [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                        value:@2
                                        range:NSMakeRange(0, [attributeString length])];
                
                //diesen "durchgestrichenen Text" dann in der TableViewCell anzeigen
                [self.fachNameLabel setAttributedText:attributeString];
            }
            //überprüfe, ob eine Raumverlegung vorliegt.
            if (vertretung.isRaumVertretung) {
                //Raum-Vertretung anzeigen, indem die Hintergrundfarbe vom Label vom Raum geändert wird und der neue Raum angezeigt wird
                
            }
        }
        
    }
}

@end
