//
//  StundeTableViewCell.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 13.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "StundeTableViewCell.h"

@implementation StundeTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - Setter der Schulstunde
- (void)setSchulstunde:(Schulstunde *)schulstunde {
    self.stundeLabel.text = [NSString stringWithFormat:@"%@, %@", schulstunde.wochentagString, schulstunde.stundenString];
    self.raumLabel.text = schulstunde.raumnummer;
    self.uhrzeitLabel.text = schulstunde.uhrzeitDauerString;
}

@end
