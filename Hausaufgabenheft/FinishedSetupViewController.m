//
//  FinishedSetupViewController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 28.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "FinishedSetupViewController.h"
#import "AppDelegate.h"

@interface FinishedSetupViewController ()

@end

@implementation FinishedSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Instanzen zurückgeben

+ (FinishedSetupViewController *)standardFinishedSetupViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    return (FinishedSetupViewController *)[storyboard instantiateViewControllerWithIdentifier:@"finishedSetupViewController"];
}


#pragma mark - Actions
- (IBAction)startUsingButtonClicked:(UIButton *)sender {
    
    //eine (besser die) AppDelegate Instanz bekommen
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    //das Haupt-Interface anzeigen
    [appDelegate showMainInterface];
}
@end
