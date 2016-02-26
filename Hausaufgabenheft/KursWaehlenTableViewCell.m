//
//  KursWaehlenTableViewCell.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 07.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "KursWaehlenTableViewCell.h"
#import "Lehrer.h"
#import "Schulstunde.h"

@implementation KursWaehlenTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
    
    //das Kurs-Kürzel-Label anzeigen bzw. ausblenden, je nachdem, ob die Cell ausgewählt wurde oder nicht
    self.kursKuerzelLabel.hidden = !selected;
}


#pragma mark - UserInterface Konfiguration 
- (void)setAssociatedKurs:(Kurs *)associatedKurs {
    //hier die entsprechenden Einstellungen, vor allem im User interface setzen
    
    //wenn Stunden von dem Kurs da sind, anzeigen, wann die Stunden sind bzw. das in einem String speichern und hinter dem Lehrernamen anzeigen
    NSString *stundenString = @"";
    if (associatedKurs.stunden.allObjects.count > 0) {
        Schulstunde *ersteSchulstunde = associatedKurs.stunden.allObjects.firstObject;
        stundenString = [NSString stringWithFormat:@"(%@, %@)", ersteSchulstunde.wochentagString, ersteSchulstunde.stundenString];
    }
    
    self.kursNameLabel.text = associatedKurs.name;
    self.kursArtLabel.text = [associatedKurs kursartString];
    self.lehrerNameLabel.text = [associatedKurs.lehrer.name stringByAppendingFormat:@" %@", stundenString];
    
    _associatedKurs = associatedKurs;
    
    
    //wenn der Kurs eine AG oder ein Projektkurs ist, dann das klausurSegmentedControl ausblenden
    if (associatedKurs.isProjektkurs || associatedKurs.isAG) {
        self.klausurSegmentedControl.hidden = YES;
    }
    else {
        self.klausurSegmentedControl.hidden = NO;
    }
    //wenn der Kurs ein Leistungskurs ist, dann wähle schriftlich standardmäßig aus
    if (associatedKurs.kursart.intValue == leistungskursKursArt) {
        //Leistungskurs
        self.klausurSegmentedControl.selectedSegmentIndex = 1; //schriftlich ausgewählt
        associatedKurs.schriftlich = [NSNumber numberWithBool:YES]; //den Kurs automatisch auf schriftlich setzen
    }
    else {
        self.klausurSegmentedControl.selectedSegmentIndex = associatedKurs.schriftlich.boolValue; //mündlich bei anderen Kursen standardmäßig bzw. den Wert aus CoreData benutzen
    }
    
    //Die Abkürzung für den Kurs setzen (sollten die ersten zwei Buchstaben der Kurs-ID sein
    if (associatedKurs.id.length > 1) {
        self.kursKuerzelLabel.text = [associatedKurs.id substringToIndex:2];
    }
    else {
        self.kursKuerzelLabel.text = @"";
    }

    
}


#pragma mark - IB-Action
- (IBAction)klausurSegmentedControlValueChanged:(UISegmentedControl *)sender {
    //schriftlich oder mündlich wählen
    self.associatedKurs.schriftlich = [NSNumber numberWithInteger:sender.selectedSegmentIndex];
}
@end
