//
//  StundeTableViewCell.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 13.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Schulstunde.h"

@interface StundeTableViewCell : UITableViewCell

#pragma mark - Outlets
///das Label, dass anzeigt, an welchem Wochentag und in welcher Stunde die Schulstunde stattfindet
@property (weak, nonatomic) IBOutlet UILabel *stundeLabel;

///das Label, was die Uhrzeit angibt, wann die Schulstunde stattfindet
@property (weak, nonatomic) IBOutlet UILabel *uhrzeitLabel;

///dass Label, was anzeigt, in welchem Raum die Stunde stattfindet
@property (weak, nonatomic) IBOutlet UILabel *raumLabel;


#pragma mark - Die Infos über die von der TableViewCell angezeigte Schulstunde
@property (nonatomic) Schulstunde *schulstunde;
@end
