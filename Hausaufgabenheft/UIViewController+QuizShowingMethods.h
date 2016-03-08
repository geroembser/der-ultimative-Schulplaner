//
//  UIViewController+QuizShowingMethods.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 04.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Frage.h"
#import "Quiz.h"

///Nutze diese Kategorie um einfach in ViewControllern, die diese Kategorie importieren, neue Quizze anzeigen zu lassen
@interface UIViewController (QuizShowingMethods)


///fragt den gegebenen Array von Fragen ab, indem diese Methoden ein Quiz erstellt und damit einen QuizAbfrageNavController initialisiert; die gegebenen Boolean-Variable (randomly) gibt an, ob diese Fragen in diesem Array zufällig abgefragt werden soll
- (void)frageFragenInArrayAb:(NSArray <Frage *> *)fragenArray zufaellig:(BOOL)randomly;

@end
