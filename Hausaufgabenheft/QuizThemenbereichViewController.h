//
//  QuizThemenbereichViewController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 03.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Themenbereich.h"
#import "Kurs.h"


///der ViewController, der die Anzeige von allen Themenbereich für einen Kurs managed
@interface QuizThemenbereichViewController : UITableViewController

#pragma mark - Attribute
///der Kurs dessen Themenbereichen, durch diesen ViewController sozusagen dargestellt werden sollen (ohne diese gesetzte Eigenschaft wird es schwierig, eine vernünftige Anzeige zu produzieren... :-))
@property Kurs *kurs;


#pragma mark - Actions
///soll alle Fragen des ausgewaehlten Kurses abfragen (also Themenbereichs übergreifend)
- (IBAction)alleFragenAbfragen:(id)sender;
///soll alle neusten Fragen des Kurses, die verfügbar sind, abfragen
- (IBAction)alleNeustenFragenAbfragen:(id)sender;
///soll gezielt die Abfrage von allen als falsch beantwortet eingestuften Fragen des Kursen starten
- (IBAction)alleFalschenFragenAbfragen:(id)sender;


@end
