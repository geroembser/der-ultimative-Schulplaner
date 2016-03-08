//
//  NewscenterTableViewCell.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 13.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewscenterObject.h"
#import "Mitteilung.h"

///Die TableViewCell, die einen Newscenter-Einträg anzeigen soll
@interface NewscenterTableViewCell : UITableViewCell

#pragma mark - IBOutlets
@property (weak, nonatomic) IBOutlet UIImageView *additionalMediaImageView;
@property (weak, nonatomic) IBOutlet UILabel *titelLabel;
@property (weak, nonatomic) IBOutlet UILabel *previewTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateAndAdditionalInfoLabel;


#pragma mark - Eigenschaften der TableViewCell
///das News-Objekt, was durch die TableViewCell angezeigt werden soll
@property (nonatomic) NewscenterObject *newsObject;

@end
