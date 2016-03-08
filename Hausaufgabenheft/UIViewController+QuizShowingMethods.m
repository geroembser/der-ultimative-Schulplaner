//
//  UIViewController+QuizShowingMethods.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 04.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "UIViewController+QuizShowingMethods.h"
#import "QuizAbfrageNavController.h"

@implementation UIViewController (QuizShowingMethods)


#pragma mark - Fragen abfragen
- (void)frageFragenInArrayAb:(NSArray<Frage *> *)fragenArray zufaellig:(BOOL)randomly {
    //überprüfen, ob Fragen gegeben sind, ansonsten zeige eine Fehlermeldung an
    if (fragenArray && fragenArray.count > 0) {
        //mit allen Fragen ein Quiz erstellen
        Quiz *neuesQuiz = [Quiz quizZusammenstellenMitArrayVonFragen:fragenArray randomly:randomly fuerUser:[User defaultUser]];
        
        //erstellt den ViewController mit dem gegebenen Quiz
        QuizAbfrageNavController *quizNavController = [[QuizAbfrageNavController alloc]initWithQuiz:neuesQuiz];
        
        //zeige diesen QuizNavController an
        [self presentViewController:quizNavController animated:YES completion:nil];
    }
    else {
        [self showErrorMessageThatNoQuestionsAreAvailable];
    }
}


#pragma mark - sonstige Methoden
///zeigt dem user auf dem user interface eine Fehlermeldung an, die angibt, dass keine Fragen verfügbar sind
- (void)showErrorMessageThatNoQuestionsAreAvailable {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Keine Fragen" message:@"Lokal sind keine Fragen für diese Auswahl vorhanden. Wähle deine entsprechenenden Kurse in den Einstellungen aus, und lade in der Quiz-Übersicht neue Fragen herunter, wenn dein Lehrer Fragen bereitgestellt hat." preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
