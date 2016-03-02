//
//  QuizErgebnisFrageTableViewCell.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 02.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "QuizErgebnisFrageTableViewCell.h"

@implementation QuizErgebnisFrageTableViewCell



#pragma mark - Setter überschreiben

- (void)setDargestellteFrage:(Frage *)dargestellteFrage {
    _dargestellteFrage = dargestellteFrage;
    
    //Labels etc. der TableViewCell entsprechend konfigurieren
    self.frageIDLabel.text = [NSString stringWithFormat:@"Frage %@", dargestellteFrage.id.stringValue];
    self.frageFrageLabel.text = dargestellteFrage.frage;
    
}

@end
