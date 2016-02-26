//
//  StundenplanTableViewCell.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 29.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Stunde.h"

/**
 Die TableViewCell, die eine Schulstunde im Stundenplan anzeigt
 */

@interface StundenplanTableViewCell : UITableViewCell


#pragma mark - Properties
@property (nonatomic) Stunde *stunde;

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UILabel *stundenNummerLabel;
@property (weak, nonatomic) IBOutlet UILabel *fachNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lehrerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *raumLabel;
@property (weak, nonatomic) IBOutlet UIImageView *kursImageView;

@end
