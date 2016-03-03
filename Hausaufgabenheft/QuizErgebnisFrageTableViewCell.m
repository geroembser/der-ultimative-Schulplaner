//
//  QuizErgebnisFrageTableViewCell.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 02.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "QuizErgebnisFrageTableViewCell.h"

@implementation QuizErgebnisFrageTableViewCell


#pragma mark - Methoden
- (void)zeigeAnAlsRichtig:(BOOL)richtig {
    if (richtig) {
        self.contentView.backgroundColor = [UIColor colorWithRed:0.71 green:0.81 blue:0.40 alpha:1.0];
    }
    else {
        self.contentView.backgroundColor = [UIColor colorWithRed:0.89 green:0.02 blue:0.07 alpha:1.0];
    }
}


#pragma mark - Setter überschreiben

- (void)setDargestellteFrage:(Frage *)dargestellteFrage {
    _dargestellteFrage = dargestellteFrage;
    
    //Labels etc. der TableViewCell entsprechend konfigurieren
    self.frageIDLabel.text = [NSString stringWithFormat:@"Frage %@", dargestellteFrage.id.stringValue];
    self.frageFrageLabel.text = dargestellteFrage.frage;
    
}

@end
