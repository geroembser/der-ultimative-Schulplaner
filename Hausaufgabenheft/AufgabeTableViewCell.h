//
//  AufgabeTableViewCell.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 30.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Aufgabe.h"

///die TableViewCell für eine Aufgabe
@interface AufgabeTableViewCell : UITableViewCell

#pragma mark - IB-Outlets
@property (weak, nonatomic) IBOutlet UILabel *titelLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *erledigtButton;

#pragma mark - IB-Actions
- (IBAction)erledigtButtonClicked:(UIButton *)sender;

#pragma mark - General properties
///die Aufgabe, die von der TableViewCell dargestellt wird
@property (nonatomic) Aufgabe *aufgabe;


@end
