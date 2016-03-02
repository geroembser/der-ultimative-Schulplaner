//
//  DownloadQuizFragenViewController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 27.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadQuizFragenViewController : UIViewController

#pragma mark - Initialisierung
///Erstellt eine neue Instanz vom DownloadQuizFragenViewController und gibt sie zurück. Sobald der View angezeigt wurde, wird der Download der Quiz-Fragen gestartet
+ (DownloadQuizFragenViewController *)defaultDownloadQuizFragenViewController;

///Erstellt eine neue Instanz vom DownloadQuizFragenViewController und gibt sie zurück. Sobald der View angezeigt wurde, wird der Download der Quiz-Fragen gestartet
- (instancetype)init;

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UILabel *titelLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

#pragma mark - Actions
///bricht das Herunterladen der Quiz-Fragen ab
- (IBAction)cancel:(id)sender;


@end
