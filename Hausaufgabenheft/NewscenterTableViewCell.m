//
//  NewscenterTableViewCell.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 13.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "NewscenterTableViewCell.h"

@implementation NewscenterTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Setter der Eigenschaften der TableViewCell
- (void)setNewsObject:(NewscenterObject *)newsObject {
    self.titelLabel.text = newsObject.newsObjectTitle;
    self.previewTextLabel.text = newsObject.newsObjectText;
    self.dateAndAdditionalInfoLabel.text = [NSString stringWithFormat:@"%@ Uhr – für mehr Infos hier klicken", newsObject.readableDateString];
}

@end
