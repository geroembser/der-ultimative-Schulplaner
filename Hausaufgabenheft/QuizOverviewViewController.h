//
//  QuizOverviewViewController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 27.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuizOverviewViewController : UIViewController


#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UIButton *neueFragenHerunterladenButton;
@property (weak, nonatomic) IBOutlet UILabel *verfuegbareFragenLabel;
@property (weak, nonatomic) IBOutlet UIButton *quizStartenButton;
@property (weak, nonatomic) IBOutlet UILabel *letztesUpdateDatumLabel;
@property (weak, nonatomic) IBOutlet UILabel *punkteLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImageImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIView *punkteContainerView;


#pragma mark - Actions
- (IBAction)neueFragenHerunterladen:(id)sender;


@end
