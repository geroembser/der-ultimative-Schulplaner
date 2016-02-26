//
//  AufgabeEditViewController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 30.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KonfigurierteKurseWaehlenViewController.h"

@class Schulstunde;

@interface AufgabeEditViewController : UIViewController <KonfigurierteKurseWaehlenViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate> //Delegate wird benötigt, dafür dass das Wählen des Kurses vernünftig funktioniert

#pragma mark - Initialisierung
///erstellt eine neue Instanz vom AufgabeEditViewController, der eine gegebenen Aufgabe bearbeitet
- (instancetype)initWithAufgabe:(Aufgabe *)aufgabe;

///erstellt eine neue Instanz vom AufgabenEditViewController, der die Voreinstellungen der Aufgabe so setzt, dass sie mit einer gegebenen Schulstunde übereinstimmen
- (instancetype)initWithSchulstunde:(Schulstunde *)schulstunde;

#pragma mark - Eigenschaften des Controllers
///der Benutzer, für den die Aufgabe, die bearbeitet werden soll ist oder für den eine neue Aufgabe erstellt werden soll
@property User *associatedUser;

///Die Aufgabe, die vom Controller repräsentiert wird, bearbeitet wird(, oder erstellt wird)
@property Aufgabe *representedAufgabe;

#pragma mark - Eigenschaften der Aufgabe (neue Aufgabe oder bestehende Aufgabe)
///der Kurs, der für die Aufgabe gewählt ist
@property (nonatomic) Kurs *kursFuerAufgabe;
///das Abgabedatum, dass für die Aufgabe gewählt ist
@property (nonatomic) NSDate *abgabeDatum;
///das Erinnerungsdatum, dass für die Aufgabe gewählt ist
@property (nonatomic) NSDate *erinnerungsDatum;
///die Medienobjekte für die Aufgabe
@property NSMutableArray *mediaFiles;
///enthält die Mediendateien, die auch wirklich gelöscht werden sollen, wenn der Benutzer auf Speichern drückt
@property NSMutableArray *mediaFileToDelete;
///enthält die Mediendateien, die auch wirklich zu der Aufgabe hinzugefügt werden sollen, wenn auf Speichern gedrückt wird (in der Regel temporäre MediaFiles)
@property NSMutableArray *mediaFilesToAdd;

#pragma mark - Allgemeine Steuerelemente des ViewControllers

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

- (IBAction)cancelButtonClicked:(UIButton *)sender;
- (IBAction)speichernButtonClicked:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *titelLabel;



#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UIButton *kursButton;
@property (weak, nonatomic) IBOutlet UITextField *titelTextfield;
@property (weak, nonatomic) IBOutlet UITextView *beschreibungTextView;
@property (weak, nonatomic) IBOutlet UITextField *abgabeDatumTextfield;
@property (weak, nonatomic) IBOutlet UISwitch *erinnerungSwitch;
@property (weak, nonatomic) IBOutlet UITextField *erinnerungTextfield;
@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritaetSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextView *notizenTextView;
@property (weak, nonatomic) IBOutlet UIButton *neuesFotoAufnehmenButton;
@property (weak, nonatomic) IBOutlet UIButton *fotoAusAlbumWaehlenButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView; //der CollectionView, der die MediaFiles anzeigen soll
@property (weak, nonatomic) IBOutlet UILabel *lehrerLabel;

#pragma mark - IB-Actions
- (IBAction)kursButtonClicked:(id)sender;
- (IBAction)erinnerungSwitchValueChanged:(UISwitch *)sender;
- (IBAction)fotoAusAlbumClicked:(UIButton *)sender;
- (IBAction)neuesFotoClicked:(UIButton *)sender;


@end
