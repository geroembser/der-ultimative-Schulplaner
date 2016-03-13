//
//  SpecialTaskCreationKursButton.m
//  BMS-App
//
//  Created by Gero Embser on 11.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "SpecialTaskCreationKursButton.h"

@implementation SpecialTaskCreationKursButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - Button-Markieren
- (void)markiere:(BOOL)ausgewaehlt {
    //der Instanzvariable einen Wert zuweisen
    self.ausgewaehlt = ausgewaehlt;
    
    if (ausgewaehlt) {
        //Button als ausgewählt markieren
        
        //die Hintergrundfarbe ändern
        [self setBackgroundColor:self.tintColor];
        
        //die Schriftfarbe ändern
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else {
        //Button als nicht ausgewählt markieren
        
        //die Hintergrundfarbe ändern
        [self setBackgroundColor:[UIColor clearColor]];
        
        //die Schriftfarbe ändern
        [self setTitleColor:self.tintColor forState:UIControlStateNormal];
    }
}


#pragma mark - Titel setzen
- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    //wenn kein Titel gegeben ist, zeige "---" an und zeige den Button als nicht ausgewählt an
    if (!title || title.length < 1) {
        [super setTitle:@"---" forState:state];
    }
    else {
        
        //Aufruf der Superklassen-Methode
        [super setTitle:title forState:state];
        
    }
}

#pragma mark - Kurs-Setter überschreiben
- (void)setKurs:(Kurs *)kurs {
    //wenn ein Kurs gegeben ist, dann den Fachnamen von diesem als Titel für diesen Button benutzen
    if (kurs) {
        [super setTitle:kurs.fach forState:UIControlStateNormal];
    }
    else {
        //einen leeren Titel setzen
        [self setTitle:nil forState:UIControlStateNormal];
    }
}

@end
