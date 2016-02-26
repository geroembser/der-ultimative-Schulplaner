//
//  FinishedSetupViewController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 28.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Der View Controller, der angezeigt wird, wenn das Setup im Intro abgeschlossen ist und der den Standard-Start-Bildschirm aufrufen soll.
 */
@interface FinishedSetupViewController : UIViewController

#pragma mark - Instanzen zurückgeben
///gibt den Standard FinishedSetupViewController zurück
+ (FinishedSetupViewController *)standardFinishedSetupViewController;

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UIButton *startUsingButton;

#pragma mark - Actions
- (IBAction)startUsingButtonClicked:(UIButton *)sender;

@end
