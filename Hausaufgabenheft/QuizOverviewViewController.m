//
//  QuizOverviewViewController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 27.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "QuizOverviewViewController.h"
#import "QuizController.h"
#import "NSDate+AdvancedDate.h"
#import "DownloadQuizFragenViewController.h"

@interface QuizOverviewViewController ()
///der QuizController, dessen Daten angezeigt werden bzw. der benutzt wird, um die Übersicht des Quizes für des User darzustellen und Infos über das Quiz zu gewinnen
@property QuizController *quizController;
@end

@implementation QuizOverviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //den QuizController für diesen ViewController setzen
    self.quizController = [QuizController defaultQuizController];
    
    //die Farbe vom NavigationController-View auf weiß setzen, weil es sonst - warum auch immer - zu unschönen Schatten während des Übergangs von einem zu diesem ViewController kommt --> ohne diese folgende Zeile wäre außerdem die NavigationBar wesentlich dunkler
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    
    //die Werte für die entsprechenden View-Objekte nach dem Laden des Views setzen
    //User-Name
    self.userNameLabel.text = self.quizController.user.fullName;
    
    //Punkte-Stand
    self.punkteLabel.text = [NSString stringWithFormat:@"%lu Punkte", self.quizController.punktestand];
    
    //letztes Daten-Update
    NSString *lastUpdate = [self.quizController.user.quizLastUpdate datumUndUhrzeitString];
    self.letztesUpdateDatumLabel.text = [NSString stringWithFormat:@"letztes Update der Daten: %@", (lastUpdate && lastUpdate.length > 0 ? lastUpdate : @"noch nie")];
    
    //verfügbare Fragen
    self.verfuegbareFragenLabel.text = [NSString stringWithFormat:@"verfügbare Fragen: %lu", self.quizController.numberOfAvailableQuestions];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//ruft den ViewController auf, der die neuen Fragen herunterladen soll
- (IBAction)neueFragenHerunterladen:(id)sender {
    //den ViewController anzeigen, der das Herunterladen der neuen Fragen übernimmt
    DownloadQuizFragenViewController *downloadViewController = [DownloadQuizFragenViewController defaultDownloadQuizFragenViewController];
    
    //den ViewController anzeigen (aber im parentViewController vom navigationController vom QuizOverviewController, damit die Transparenz erhalten bleibt, aber gleichzeitig auch die Tab-Bar überblendet wird
    [self.navigationController.parentViewController presentViewController:downloadViewController animated:YES completion:nil];
}
@end
