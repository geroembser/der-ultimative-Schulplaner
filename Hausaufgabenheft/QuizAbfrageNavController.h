//
//  QuizAbfrageNavController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 28.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Quiz.h"

///der NavigationController, der die Anzeige der Fragen übernimmt; Durch diesen Controller wird die View-Anzeige der Quiz-Abfrage gesteuert. Dieser Controller bildet die Basis für die gesamten anderen ViewController, die angezeigt werden sollen, die im Zusammenhang mit dem Quiz stehen. Er bildet also den Rahmen für die Navigation innerhalb des Quizzes (bzw. der ViewController, die für das Quiz verwendet werden)
@interface QuizAbfrageNavController : UINavigationController

#pragma mark - Initialisierung
///initialisiert den Quiz-Abfrage-Nav-Controller mit dem gegebenen, zusammengestellten Quiz
- (instancetype)initWithQuiz:(Quiz *)quiz;


#pragma mark - Attribute
///das Quiz, dass in diesem NavigationController angezeigt werden soll
@property Quiz *displayingQuiz;

@end
