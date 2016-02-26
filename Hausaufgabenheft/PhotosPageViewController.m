//
//  PhotosPageViewController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 30.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "PhotosPageViewController.h"
#import "MediaFilesDetailViewController.h"

@interface PhotosPageViewController ()

@end

@implementation PhotosPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //den parentViewController bekommen und ihn als DataSource für sich selbst festlegen (das sollte der Haupt-Zweck dieser Klasse sein
    self.dataSource = (UIViewController <UIPageViewControllerDataSource>*)self.parentController;
    
    //die Delegate-Nachrichten auch an den parentController schicken
    self.delegate = self.parentController;
    
    
    //setzte den ersten ViewController (das ist der startViewController)
    PhotoViewController *pageZero = [self.parentController startViewController];

    [self setViewControllers:@[pageZero] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    
    //setze die Hintergrundfarbe
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
