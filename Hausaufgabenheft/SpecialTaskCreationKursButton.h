//
//  SpecialTaskCreationKursButton.h
//  BMS-App
//
//  Created by Gero Embser on 11.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Kurs.h"

///eine Unterklasse von UIButton, die spzeiell die Buttons im SpecialTaskCreationTextfieldAccessoryView repräsentieren soll, die zur Auswahl des jeweiligen Kurses für die Aufgabe genutzt werden sollen
@interface SpecialTaskCreationKursButton : UIButton

#pragma mark - Methoden
///der Aufruf dieser Methode mit dem entsprechenden Parameter zeigt den Button entwender markiert oder nicht markiert an
- (void)markiere:(BOOL)ausgewaehlt;

#pragma mark - Attribute
///der Kurs, der durch diesen Button ausgwählt werden könnte (wenn der Benutzer es macht...)
@property (nonatomic) Kurs *kurs;

///gibt an, ob dieser Button ausgewählt wurde
@property BOOL ausgewaehlt;

@end
