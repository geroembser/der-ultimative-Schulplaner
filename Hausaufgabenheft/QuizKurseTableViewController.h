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


#pragma mark - Actions
- (IBAction)alleFragenZufaelligAbfragen:(id)sender;

@end
