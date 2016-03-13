//
//  SpecialTaskCreationTextfieldAccessoryView.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 09.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Kurs.h"
#import "SpecialTaskCreationKursButton.h"

@class SpecialTaskCreationTextfieldAccessoryView;

@protocol SpecialTaskCreationTextfieldAccessoryViewDelegate <NSObject>

@optional
///Durch diese Methode wird angegeben, dass durch den Textfield-Accessory-View ein Kurs ausgewählt wurde
- (void)specialTaskCreationTextfieldAccessoryView:(SpecialTaskCreationTextfieldAccessoryView *)accessoryView didSelectKurs:(Kurs *)ausgewaehlterKurs;

///Durch diese Methode wird angegeben, dass im Accessory-View das Datum, wann diese Aufgabe fertig sein soll (Abgabedatum) und damit auch das Erinnerungsdatum, ausgewählt wurde, das als Parameter mitübergeben wird.
- (void)specialTaskCreationTextfieldAccessoryView:(SpecialTaskCreationTextfieldAccessoryView *)accessoryView didSelectAbgabedatum:(NSDate *)abgabedatum;

@end

///diese Klasse ist die Klasse von dem eigenen Input-Accessory-View vom Textfeld im "speziellen-Aufgaben-Hinzufügen-ViewController"
@interface SpecialTaskCreationTextfieldAccessoryView : UIView

#pragma mark - IB-Outlets
@property (weak, nonatomic) IBOutlet SpecialTaskCreationKursButton *ersterKursVorschlagButton;
@property (weak, nonatomic) IBOutlet SpecialTaskCreationKursButton *zweiterKursVorschlagButton;
@property (weak, nonatomic) IBOutlet UIButton *naechsteStundeAbgabedatumButton;
@property (weak, nonatomic) IBOutlet UIButton *in2TagenAbgabedatumButton;
@property (weak, nonatomic) IBOutlet UIButton *in1WocheAbgabedatumButton;

#pragma mark Constraints-Outlets
///das Höhen-Constraint, das die Höhe der Reihe festlegt, in der die Abgabedatum-Butons enthalten sind
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *abgabedatumReiheHeightConstraint;
///das Höhen-Constraint, das die Höhe der Reihe festlegt, in der die Kurs-Vorschlag-Buttons stehen
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *kursVorschlagReiheHeightConstraint;


#pragma mark - IB-Actions
//Kurs-Vorschläge-Buttons
- (IBAction)ersterKursVorschlagButtonClicked:(id)sender;
- (IBAction)zweiterKursVorschlagButtonClicked:(id)sender;

//Abgabedatum-Vorschläge-Button
- (IBAction)naechsteStundeAbgabedatumButtonClicked:(id)sender;
- (IBAction)in2TagenAbgabedatumButtonClicked:(id)sender;
- (IBAction)in1WocheAbgabedatumButtonClicked:(id)sender;




#pragma mark - Attribute (Setter/Getter)
///Das Attribut, was die Kurse enthalten soll, die durch diesen AccessoryView über der Tastatur als Vorschläge angegeben werden sollen --> Der Aufruf des Setters von diesem Attribut, stellt die ersten zwei Kurse des gegebenen Array in seinem View dar, bzw. schlägt sie also vor...
@property (nonatomic) NSArray <Kurs *> *passendeKurse;

///der Kurs, der durch diesen View ausgewaehlt wurde
@property (nonatomic) Kurs *ausgewaehlterKurs;

///das Objekt, an das dieses Objekt seine Delegate-Nachrichten schicken soll
@property id <SpecialTaskCreationTextfieldAccessoryViewDelegate> delegate;


@end
