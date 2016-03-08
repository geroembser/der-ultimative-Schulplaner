//
//  QuizKurseTableViewController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 28.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuizKurseTableViewController : UITableViewController

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UIButton *alleFragenButton;
@property (weak, nonatomic) IBOutlet UIButton *neusteFragenButton;
@property (weak, nonatomic) IBOutlet UIButton *alleFalschenFragenButton;


#pragma mark - Actions
///sollte alle verfügbaren Fragen zufällig abfragen...
- (IBAction)alleFragenZufaelligAbfragen:(id)sender;
///sollte alle neusten Fragen abfragen
- (IBAction)alleNeustenFragenAbfragen:(id)sender;
///soll gezielt die Abfrage von allen als falsch beantwortet eingestuften Fragen starten
- (IBAction)alleFalschenFragenAbfragen:(id)sender;


@end
