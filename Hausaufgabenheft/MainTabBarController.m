//
//  MainTabBarController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 03.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "MainTabBarController.h"
#import "User.h"
#import "Stundenplan.h"
#import "AppDelegate.h"

@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //im App-Delegate einen Verweis auf hierhin setzten, damit an anderen Stellen des Programms auf diesen Controller zugegegriffen werden kann
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    appDelegate.mainTabBarController = self;
    
    
    //Konfiguriere die Bagdes der einzelnen TabBarIcons
    
    //Stundenplan-TabBarItem
    UITabBarItem *stundenplanTabBarItem = [self.tabBar.items objectAtIndex:2];
    
    User *user = [User defaultUser];
    NSUInteger anzahlStundenHeute = [user.stundenplan anzahlStundenHeute];
    
    if (anzahlStundenHeute < 1) {
        stundenplanTabBarItem.badgeValue = nil;
    }
    else {
        stundenplanTabBarItem.badgeValue = [NSString stringWithFormat:@"%lu", anzahlStundenHeute];
    }
    
    //Aufgaben-TabBarItem
    UITabBarItem *aufgabenTabBarItem = [self.tabBar.items objectAtIndex:1];
    
    NSUInteger anzahlNichtErledigterAufgaben = [user anzahlAusstehendeAufgaben];
    
    if (anzahlNichtErledigterAufgaben < 1) {
        aufgabenTabBarItem.badgeValue = nil;
    }
    else {
        aufgabenTabBarItem.badgeValue = [NSString stringWithFormat:@"%lu", anzahlNichtErledigterAufgaben];
    }
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

@end
