//
//  QuizErgebnisViewController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 02.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "QuizErgebnisViewController.h"
#import "QuizErgebnisFrageTableViewCell.h"

@implementation QuizErgebnisViewController


#pragma mark - Instanzen zurückgeben
- (instancetype)init {
    self = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"quizErgebnisViewController"];
 
    if (self) {
        //weitere eigene Initialisierungen möglich
        
        
    }
    
    return self;
}

- (instancetype)initWithQuiz:(Quiz *)quiz {
    self = [self init];
    
    if (self) {
        self.displayedQuiz = quiz;
    }
 
    return self;
}

#pragma mark - View-Setup
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //die Ergebnisse vom Quiz in einem Label anzeigen
    //der Name des Benutzers
    self.userNameLabel.text = [NSString stringWithFormat:@"Name: %@", self.displayedQuiz.user.fullName];
    self.stufeLabel.text = [NSString stringWithFormat:@"Stufe: %@", self.displayedQuiz.user.stufe];
    self.richtigBeantworteteFragenLabel.text = [NSString stringWithFormat:@"richtig beantwortete Fragen: %lu (%.1f%%)", self.displayedQuiz.anzahlRichtigBeantworteterFragen, ((float)self.displayedQuiz.anzahlRichtigBeantworteterFragen/(float)self.displayedQuiz.numberOfQuestions)*100];
    self.falschBeantworteteFragenLabel.text = [NSString stringWithFormat:@"falsch beantwortete Fragen: %lu (%.1f%%)", self.displayedQuiz.anzahlFalschBeantworteterFragen, ((float)self.displayedQuiz.anzahlFalschBeantworteterFragen/(float)self.displayedQuiz.numberOfQuestions)*100];
    
}

#pragma mark - Actions
- (IBAction)exitQuiz:(id)sender {
    //das Quiz beenden, indem an den ParentViewController eine Delegate-Nachricht geschickt wird, dass Quiz zu beenden
    if (self.delegate && [self.delegate respondsToSelector:@selector(didEndQuizAndShouldHideQuizErgebnisViewController:)]) {
        [self.delegate didEndQuizAndShouldHideQuizErgebnisViewController:self];
    }
}

#pragma mark - sonstige Methoden


#pragma mark - Fragen-TableView-Methoden (Datasource, Delegate etc.)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.displayedQuiz.numberOfQuestions;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QuizErgebnisFrageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"quizErgebnisFrageTableViewCell"];
    
    if (!cell) {
        return [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"quizErgebnisFrageTableViewCell"];
    }
    
    
    //in der TableViewCell die jeweilige Frage anzeigen
    cell.dargestellteFrage = [self.displayedQuiz frageAtIndex:indexPath.row];
    
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //die entsprechende Delegate-Methode aufrufen, die das Ergebnis der jeweiligen Frage erneut anzeigen lassen soll
    if (self.delegate && [self.delegate respondsToSelector:@selector(shouldShowErgebnisVonFrage:inQuiz:)]) {
        [self.delegate shouldShowErgebnisVonFrage:[self.displayedQuiz frageAtIndex:indexPath.row] inQuiz:self.displayedQuiz];
    }
}


@end
