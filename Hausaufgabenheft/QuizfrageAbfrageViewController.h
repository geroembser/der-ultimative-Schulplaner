//
//  QuizfrageAbfrageViewController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 28.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Quiz.h"
#import "Frage.h"
#import "AntwortButton.h"
@class QuizfrageAbfrageViewController;

@protocol QuizfrageAbfrageViewControllerDelegate <NSObject>

///die Methode teilt dem Delegate mit, dass eine Frage beantwortet wurde und die nächste Frage zur Abfrage vorbereitet werden sollte
- (void)quizfrageAbfrageViewController:(QuizfrageAbfrageViewController *)quizfrageAbfrageViewController frageBeantwortet:(Frage *)beantworteteFrage;

///die Methode teilt dem Delegate mit, dass der User das Quiz abbrechen möchte; die übergebenen Boolean-Variable gibt an, ob die Ergebnis-Seite angezeigt werden soll oder nicht
- (void)quizfrageAbfrageViewController:(QuizfrageAbfrageViewController *)quizfrageAbfrageViewController userRequestedToCancelQuizWithShowingErgebnis:(BOOL)showErgebnis;

///die Methode teilt dem Delegate mit, dass dieser Controller es anfordert, die Ergebnis-Seite des Quiz anzuzeigen
- (void)quizfrageAbfrageViewControllerRequestToShowResultsPage:(QuizfrageAbfrageViewController *)quizfrageAbfrageViewController;

@end

///der ViewController, der eine Quiz-Frage abfragt
@interface QuizfrageAbfrageViewController : UIViewController

#pragma mark - Initialisierung
///initialisiert den ViewController, der die Frage abfragt, mit dem gegebenen Quiz und einer Teilfrage von diesem Quiz
- (instancetype)initWithFrage:(Frage *)frage alsTeilVomQuiz:(Quiz *)quiz;

///initialisiert den ViewController, der die Frage , mit dem gegebenen Quiz und einer Teilfrage von diesem Quiz oder, wenn als isErgebnis=YES übergeben wurde, wird das Ergebnis einer bereits beantworteten Frage angezeigt und der Benutzer kann sich die Lösung noch einmal anschauen
- (instancetype)initWithFrage:(Frage *)frage alsTeilVomQuiz:(Quiz *)quiz isAnzeigeVonErgebnis:(BOOL)isErgebnis;

#pragma mark - Attribute
//das Quiz, dessen Teil-Frage dieser ViewController abfragt; die durch diesen ViewController abzufragende Frage ist in der frage-Property dieses Objekts gespeichert (sollte zumindest eigentlich so sein ...  😂
@property Quiz *quiz;

///die Frage, die durch diesen ViewController beim User abgefragt wird
@property Frage *frage;

///das Delegate, an das dieser ViewController seine Delegate-Nachrichten verschickt
@property id <QuizfrageAbfrageViewControllerDelegate> delegate;



#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *nextQuestionButton;
@property (weak, nonatomic) IBOutlet UILabel *fragenNummerLabel;
@property (weak, nonatomic) IBOutlet UITextView *frageTextView;
@property (weak, nonatomic) IBOutlet UILabel *frageDetailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *frageIDLabel;

@property (weak, nonatomic) IBOutlet AntwortButton *antwortButton1;
@property (weak, nonatomic) IBOutlet AntwortButton *antwortButton2;
@property (weak, nonatomic) IBOutlet AntwortButton *antwortButton3;
@property (weak, nonatomic) IBOutlet AntwortButton *antwortButton4;
@property (weak, nonatomic) IBOutlet UIButton *loesenButton;

#pragma mark - Actions
//der Aufruf dieser Actions teilt dem Delegate mit, dass die nächste Frage aufgerufen werden sollte und dieser ViewController verschwinden sollte
- (IBAction)naechsteFrage:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)frageLoesen:(id)sender;

//die Actions der einzelnen Buttons
- (IBAction)button1Clicked:(AntwortButton *)sender;
- (IBAction)button2Clicked:(AntwortButton *)sender;
- (IBAction)button3Clicked:(AntwortButton *)sender;
- (IBAction)button4Clicked:(AntwortButton *)sender;


@end
