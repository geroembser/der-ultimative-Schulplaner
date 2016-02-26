//
//  KursWaehlenTableViewCell.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 07.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Kurs.h"

/**
 Die Klasse soll die TableViewCell für einen Kurs enthalten, wenn man die Kurse auswählt bzw. konfiguriert.
 */
@interface KursWaehlenTableViewCell : UITableViewCell

#pragma mark - User Interface
///der ImageView, der das Symbol für den jeweiligen Kurs/die AG etc. enthalten soll
@property (weak, nonatomic) IBOutlet UIImageView *kursSymbolImageView;

///das Label, das den Namen für den Kurs enthalten soll
@property (weak, nonatomic) IBOutlet UILabel *kursNameLabel;

///das Label, das den Namen des jeweiligen Kurs-Lehrers enthalten soll
@property (weak, nonatomic) IBOutlet UILabel *lehrerNameLabel;

///das Label, was die Kursart enthalten soll (also GK/LK)
@property (weak, nonatomic) IBOutlet UILabel *kursArtLabel;

///das SegmentedControl, mit dem man wählen kann, ob der Kurs mündlich oder schriftlich gewählt wurde
@property (weak, nonatomic) IBOutlet UISegmentedControl *klausurSegmentedControl;

///wird aufgerufen, wenn der Wert des klausurSegmentedControl geändert wird
- (IBAction)klausurSegmentedControlValueChanged:(UISegmentedControl *)sender;

///das Label für das Kürzel des Kurses, was angezeigt werden kann, wenn der Kurs ausgewählt wurde
@property (weak, nonatomic) IBOutlet UILabel *kursKuerzelLabel;


#pragma mark - Sachen für die Arbeit der Klasse/des Objekts im Hintergrund
///der Kurs, den die KursWaehlenTableViewCell darstellt
@property (nonatomic) Kurs *associatedKurs;

@end
