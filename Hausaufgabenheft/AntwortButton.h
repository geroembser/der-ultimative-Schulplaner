//
//  AntwortButton.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 29.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Antwort.h"


///der Button, der die Antwort anzeigen soll
@interface AntwortButton : UIButton

#pragma mark - Methoden

///weist dem Button die gegebene Antwort zu
- (void)setzeAntwort:(Antwort *)antwort;

///konfiguriert die Anzeige vom Button so, dass er aussieht, also ob er ausgewählt wurde oder eben nicht - je nach gegebener ausgewaehlt-Property
- (void)setzeButtonAufAusgewaehlt:(BOOL)ausgewaehlt;

///konfiguriert die Anzeige des Buttons entsprechend, dass der User versteht, ob er auf die Antwort, die mit diesem Button verbunden ist, richtig geantwortet hat (zum Beispiel bei einer richtigen Antwort--> die Hintergrundfarbe auf grün setzen; bei einer falschen Antwort auf rot)
- (void)markiereAlsRichtig:(BOOL)richtig;

#pragma mark - Attribute
///die Antwort, die vom Button angezeigt wird
@property Antwort *displayingAntwort;

///gibt an, ob der Button ausgewaehlt wurde
@property BOOL ausgewaehlt;



@end
