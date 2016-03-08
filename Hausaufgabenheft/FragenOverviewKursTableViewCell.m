//
//  FragenOverviewKursTableViewCell.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 02.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "FragenOverviewKursTableViewCell.h"

@implementation FragenOverviewKursTableViewCell



#pragma mark - Konfiguration der TableViewCell
- (void)setKurs:(Kurs *)kurs {
    self.kursNameLabel.text = kurs.name;
    
    //die Infos über die Fragen vom Kurs setzen
    //erst einen String bilden, um zwischen "1 Frage" und "2 Fragen" unterscheiden zu können
    NSUInteger anzahlFragen = kurs.anzahlVerfuegbareFragen;
    NSString *anzahlFragenString = anzahlFragen == 1 ? @"Frage" : @"Fragen";
    
    //den zusammengesetzten Text dann in das Label schreiben
    self.kurseFragenInfoLabel.text = [NSString stringWithFormat:@"%lu %@ verfügbar; %lu unbearbeitet; richtig: %.f%%", anzahlFragen, anzahlFragenString, kurs.anzahlUnbearbeiteteFragen, kurs.prozentRichtigerFragen];
}

@end
