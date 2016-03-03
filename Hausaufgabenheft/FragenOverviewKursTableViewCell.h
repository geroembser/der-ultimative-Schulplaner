//
//  FragenOverviewKursTableViewCell.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 02.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Kurs.h"

@interface FragenOverviewKursTableViewCell : UITableViewCell

#pragma mark - Attribute
///der Kurs, der von dieser TableViewCell angezeigt wird
@property (nonatomic) Kurs *kurs;

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UILabel *kursNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *kurseFragenInfoLabel;


@end
