//
//  WebNewsViewController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 06.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>

///Diese Klasse ist der ViewController für die Anzeige der WebNews
@interface WebNewsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UISegmentedControl *newsSourceSegmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *waitIndicatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *tableViewBottomLabel;

#pragma mark - Actions
- (IBAction)newsSourceSegmentedControlValueChanged:(UISegmentedControl *)sender;
- (IBAction)rightSwipeGestureRecognizerSwipe:(UISwipeGestureRecognizer *)sender;
- (IBAction)leftSwipeGestureRecognizer:(UISwipeGestureRecognizer *)sender;


@end
