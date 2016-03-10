//
//  SpecialTaskCreationViewController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 09.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>

///ist eine Klasse, die die Möglichkeit bietet, schnell und einfach eine neue Aufgabe zu erstellen
@interface SpecialTaskCreationViewController : UIViewController <UITextFieldDelegate>


#pragma mark - Initialisierung

#pragma mark - Attribute


#pragma mark - IB-Outlets
@property (weak, nonatomic) IBOutlet UITextField *aufgabeTextfield;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *backgroundTapGestureRecognizer;

#pragma mark - IB-Actions
///der Aufruf dieser Methode sorgt dafür, dass der komplette ViewController ausgeblendet wird und ist so eine Art Cancel-Button für die Erstellung neuer Aufgaben, da der User auf den Hintergrund geklickt haben soll, wenn diese Methode aufgerufen wird
- (IBAction)backgroundTapGestureRecognizerRecognized:(UITapGestureRecognizer *)sender;


@end
