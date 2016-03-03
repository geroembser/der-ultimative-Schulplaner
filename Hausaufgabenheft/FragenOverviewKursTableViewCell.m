//
//  FragenOverviewKursTableViewCell.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 02.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "FragenOverviewKursTableViewCell.h"

@implementation FragenOverviewKursTableViewCell



#pragma mark - Konfiguration der TableViewCell
- (void)setKurs:(Kurs *)kurs {
    self.kursNameLabel.text = kurs.name;
}

@end
