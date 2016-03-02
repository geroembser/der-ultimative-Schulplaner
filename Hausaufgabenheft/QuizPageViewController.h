//
//  QuizPageViewController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 28.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Quiz.h"
#import "Frage.h"
#import "QuizfrageAbfrageViewController.h"

@interface QuizPageViewController : UIPageViewController

#pragma mark - Initialisierung
///initialisiert den PageViewController, der die Fragen vom gegebenen Quiz abfragt
- (instancetype)initWithQuiz:(Quiz *)quiz;


#pragma mark - Attribute
///das Quiz, das durch diesen PageViewController abgefragt wird
@property Quiz *quiz;

///der ViewController, der gerade angezeigt wird und der dazu genutzt wird, die aktuelle Frage beim User abzufragen
@property QuizfrageAbfrageViewController *aktuellerAbfrageViewController;

@end
