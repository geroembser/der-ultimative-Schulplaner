//
//  KursTableViewCell.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 30.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "KursTableViewCell.h"

@implementation KursTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    //wenn die TableViewCell ausgewählt wird, nicht das Standard-Auswählen als ein solches anzeigen --> sondern einfach nur eine Animation die deutlich macht, dass die TableViewCell ausgewählt wurde; als Indikator für eine ausgewählte TableViewCell, benutze das Checkmark-Symbol
    if (selected) {
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    
    self.backgroundColor = [UIColor whiteColor];
    // Configure the view for the selected state
}

//den Setter für die Eigenschaft associatedKurs überschreiben, sodass beim setzen dieser die Eigenschaften Daten des Kurses entsprechend auf dem Label dargestellt werden
- (void)setAssociatedKurs:(Kurs *)associatedKurs {
    _associatedKurs = associatedKurs;
    
    self.kursNameLabel.text = associatedKurs.name;
    self.lehrerNameLabel.text = associatedKurs.lehrer.name;
    
}

@end
