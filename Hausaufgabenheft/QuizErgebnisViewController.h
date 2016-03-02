//
//  QuizErgebnisViewController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 02.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Quiz.h"
#import "Frage.h"

@class QuizErgebnisViewController;

@protocol QuizErgebnisViewControllerDelegate <NSObject>

@optional
///teilt dem Delegate mit, dass dieser ViewController verschwinden soll, weil das Quiz vom User beendet wurde
- (void)didEndQuizAndShouldHideQuizErgebnisViewController:(QuizErgebnisViewController *)quizErgebnisViewController;
///teilt dem Delegate mit, dass entsprechende ViewController angezeigt werden sollen, die dem User die Möglichkeit geben, sich seine Frage erneut anzuschauen und die detailierte Lösung zu betrachten
- (void)shouldShowErgebnisVonFrage:(Frage *)frage inQuiz:(Quiz *)quiz;

@end

///dieser ViewController soll das Ergebnis von einem Quiz anzeigen
@interface QuizErgebnisViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

#pragma mark - Instanzen zurückgeben
///erstellt einen neuen ViewController, der das Ergebnis anzeigt; das Ergebnis das angezeigt wird, ist das Ergebnis des übergebenen Quiz
- (instancetype)initWithQuiz:(Quiz *)quiz;

#pragma mark - Attribute
///das Quiz, dessen Ergebnis angezeigt wird
@property Quiz *displayedQuiz;

///das Delegate dieses Controllers, an das Nachrichten über Interaktionen vom Benutzer mit dem ViewController etc. gesendet werden
@property id <QuizErgebnisViewControllerDelegate> delegate;


#pragma mark - IB-Outlets
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *stufeLabel;
@property (weak, nonatomic) IBOutlet UILabel *themenbereichLabel;
@property (weak, nonatomic) IBOutlet UILabel *richtigBeantworteteFragenLabel;
@property (weak, nonatomic) IBOutlet UILabel *falschBeantworteteFragenLabel;
@property (weak, nonatomic) IBOutlet UITableView *fragenTableView;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;

#pragma mark - Actions
///beendet das Quiz
- (IBAction)exitQuiz:(id)sender;


@end
