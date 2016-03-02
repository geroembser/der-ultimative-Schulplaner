//
//  DownloadQuizFragenViewController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 27.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "DownloadQuizFragenViewController.h"
#import "QuizController.h"

@interface DownloadQuizFragenViewController ()

///der QuizController, der von diesem DownloadQuizFragenViewController benutzt wird, um die Fragen herunterzuladen
@property QuizController *quizController;

@end

@implementation DownloadQuizFragenViewController

#pragma mark - Initialisierung
+ (DownloadQuizFragenViewController *)defaultDownloadQuizFragenViewController {
    return [[DownloadQuizFragenViewController alloc]init];
}

- (instancetype)init {
    self = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"downloadQuizFragenViewController"];
    
    if (self) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //den QuizController initialisieren bzw. den Standard-QuizController bekommen
    self.quizController = [QuizController defaultQuizController];
    
    //für Notifications vom QuizController registrieren
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    //neue Fragen (also Herunterladen fertig)-Notification
    [notificationCenter addObserver:self selector:@selector(quizControllerDidRefreshQuestions:) name:QuizControllerDidRefreshQuestions object:self.quizController];
    //Fehler Notification
    [notificationCenter addObserver:self selector:@selector(quizControllerUpdateFailed:) name:QuizControllerUpdateFailed object:self.quizController];
    
    //hier den Download starten
    [self.quizController downloadNeueFragen];
    
    
    
    
    
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

#pragma mark - user interface Steuerung des Download-Prozesses
- (IBAction)cancel:(id)sender {
    //den Download abbrechen
    [self.quizController cancelCurrentQuestionDownload];
    
    //den ViewController ausblenden
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - QuizController-Notifications
//führt entsprechende Aktionen aus, wenn erfolgreich neue Fragen hinzugefügt wurden
- (IBAction)quizControllerDidRefreshQuestions:(id)sender {
    
    //wenn die Fragen aktualisiert wurden, lasse diesen ViewController verschwinden
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
//führt entsprechende Aktionen aus, wenn ein Update der Fragen fehlgeschlagen ist
- (IBAction)quizControllerUpdateFailed:(id)sender {
    NSNotification *notification = (NSNotification *)sender;
    
    NSDictionary *userInfo = notification.userInfo;
    
    //zeige eine Fehlermeldung im entsprechenden Label an
    self.statusLabel.text = [userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    

    //den ViewController ausblenden
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
