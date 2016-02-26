//
//  NewsTableViewCell.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 06.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "News.h"

@interface NewsTableViewCell : UITableViewCell

#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet UILabel *titelLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *excerptLabel;


#pragma mark - Properties
///die News, die von der TableViewCell angezeigt werden
@property (nonatomic) News *news;

@end
