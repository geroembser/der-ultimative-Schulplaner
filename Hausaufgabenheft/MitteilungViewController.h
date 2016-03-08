//
//  MitteilungViewController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 08.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mitteilung.h"

///dieser Mitteilungs-Controller soll eine Mitteilung anzeigen
@interface MitteilungViewController : UIViewController


#pragma mark - Initialisierung
///erstellt eine neue Instanz des MitteilungsViewControllers, der eine Mitteilung anzeigen soll; die mit dem Parameter übergebenen Mitteilung soll angezeigt werden
- (instancetype)initWithMitteilung:(Mitteilung *)mitteilung;


#pragma mark Attribute
///die Mitteilung, die von diesem ViewController angezeigt werden soll
@property Mitteilung *mitteilung;

#pragma mark - IB-Outlets
@property (weak, nonatomic) IBOutlet UILabel *titelLabel;
@property (weak, nonatomic) IBOutlet UITextView *nachrichtTextView;
@property (weak, nonatomic) IBOutlet UIButton *okSchliessenButton;

#pragma mark - IB-Actions
//der Aufruf dieser Methode schließt die Mitteilung und sorgt damit also dafür, dass dieser ViewController vom User-Interface "verschwindet"
- (IBAction)schliesseMitteilungsDetails:(id)sender;

@end
