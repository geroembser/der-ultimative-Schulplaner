//
//  QuizErgebnisFrageTableViewCell.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 02.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Frage.h"

///die TableViewCell, die im QuizErgebnisViewController dazu genutzt werden kann, die einzelnen Fragen noch einmal in einer Übersicht anzeigen zu können
@interface QuizErgebnisFrageTableViewCell : UITableViewCell

#pragma mark - IB-Outlets
@property (weak, nonatomic) IBOutlet UILabel *frageIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *frageFrageLabel;
@property (weak, nonatomic) IBOutlet UIButton *frageFavoriteButton;

#pragma mark - Properties
///die Frage, die in der TableViewCell dargestellt werden soll
@property (nonatomic) Frage *dargestellteFrage;

@end
