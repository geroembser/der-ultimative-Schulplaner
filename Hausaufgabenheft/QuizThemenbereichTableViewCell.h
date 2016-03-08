//
//  QuizThemenbereichTableViewCell.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 03.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Themenbereich.h"


///die TableViewCell für einen Themenbereich, die in der Übersicht der Themenbereiche für einen Kurs angezeigt werden kann
@interface QuizThemenbereichTableViewCell : UITableViewCell

#pragma mark - IB-Outlets
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;


#pragma mark - Attribute
///der Themenbereich, der in der TableViewCell dargestellt werden soll
@property (nonatomic) Themenbereich *themenbereich;

@end
