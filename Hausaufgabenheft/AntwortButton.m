//
//  AntwortButton.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 29.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "AntwortButton.h"
#import "Antwort.h"

@interface AntwortButton ()
///die Farbe, die der Button normal vom Storyboard aus hat
@property UIColor *storyboardStartColor;
@end

@implementation AntwortButton

#pragma mark - Design-Anpassung der App nach dem Laden des Views
- (void)willMoveToSuperview:(UIView *)newSuperview {
    //runde Ecken machen
    self.layer.cornerRadius = 10;
}

#pragma mark - Methoden zur Konfiguration der Buttons
- (void)setzeAntwort:(Antwort *)antwort {
    self.displayingAntwort = antwort;
    
    [self setTitle:antwort.antwortKurz forState:UIControlStateNormal];
}

- (void)setzeButtonAufAusgewaehlt:(BOOL)ausgewaehlt {
    self.ausgewaehlt = ausgewaehlt;
    
    if (ausgewaehlt) {
        self.storyboardStartColor = self.backgroundColor;
        //ein spezielles blau setzen
        self.backgroundColor = [UIColor colorWithRed:0 green:0.72 blue:0.93 alpha:1.0];
        //die Textfarbe auf weiß setzen
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else {
        self.backgroundColor = self.storyboardStartColor;
        //die Textfarbe erneut auf schwarz setzen
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

- (void)markiereAlsRichtig:(BOOL)richtig {
    if (richtig) {
        //ein spezielles grün benutzen
        self.backgroundColor = [UIColor colorWithRed:0.71 green:0.81 blue:0.40 alpha:1.0];
    }
    else {
        //ein spezielles rot benutzen
        self.backgroundColor = [UIColor colorWithRed:0.89 green:0.02 blue:0.07 alpha:1.0];
    }
    
    //in jedem Fall die Textfarbe afu weiß ändern
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}


@end
