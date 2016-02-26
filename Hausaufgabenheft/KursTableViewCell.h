//
//  KursTableViewCell.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 30.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Kurs.h"
#import "Lehrer.h" //Lehrer importieren, um auf das Lehrer-Objekt des Kurses Zugriff zu haben

/**
 * Die TableViewCell, die einen Kurs anzeigt
 */

@interface KursTableViewCell : UITableViewCell

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UILabel *kursNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lehrerNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *kursIconImageView;




#pragma mark - General properties
//der Kurs, der durch die TableViewCell dargestellt wird
@property (nonatomic) Kurs *associatedKurs;

@end
