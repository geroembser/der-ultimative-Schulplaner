//
//  QuizPageViewController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 28.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "QuizPageViewController.h"
#import "QuizErgebnisViewController.h"


@interface QuizPageViewController () <QuizfrageAbfrageViewControllerDelegate, QuizErgebnisViewControllerDelegate>
///der aktuelle QuizErgebnisViewController vom aktuell durch diesen PageViewController angezeigten Quiz
@property QuizErgebnisViewController *aktuellerErgebnisVC;
@end

@implementation QuizPageViewController

#pragma mark - Initialisierung
- (instancetype)initWithQuiz:(Quiz *)quiz {
    self = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"quizPageViewController"];
    
    if (self) {
        //die Attribute setzen
        self.quiz = quiz;
        
        //die erste Frage abfragen
        [self frageFrageAb:[self.quiz naechsteFrage] undErlaubeBeantwortung:YES];
    }
    
    return self;
}

#pragma mark - Methoden zur View-Hierarchie
///beendet die Anzeige vom Quiz, indem entsprechende Views ausgeblendet werden und vom Bildschirm weggenommen werden
- (void)exitQuizHierarchy {
    //die Anzeige des Quiz beenden, indem der NavigationController (von diesem PageViewController) "verschwindet"
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

///diese Methode zeigt den QuizErgebnisViewController vom Quiz an
- (void)showErgebnisViewController {
    //überprüfe erst, ob bereits ein ergebnis-ViewController für dieses Quiz vorhanden ist (in der Regel, wenn das Quiz abgeschlossen wurde und der User den Ergebnis-Controller von einem Controller anfordert, der das Ergebnis bzw. die Antwort für eine einzelne Frage anzeigt
    if (!self.aktuellerErgebnisVC) {
        self.aktuellerErgebnisVC = [[QuizErgebnisViewController alloc]initWithQuiz:self.quiz];
        self.aktuellerErgebnisVC.delegate = self; //das Delegate setzen, um auch später mitzubekommen, wenn der Page-ViewController ausgeblendet werden soll etc.
    }
    
    //den aktuellen Ergebnis-View-Controller anzeigen
    [self setViewControllers:@[self.aktuellerErgebnisVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}


#pragma mark - Quizabfrage steuern
///fragt die gegebenen Frage ab, indem der entsprechende ViewController erstellt wird und angezeigt wird; zusätzlich muss noch angegeben werden, ob die Frage, die abgefragt werden soll, überhaupt beantwortet werden darf oder ob nur das Ergebnis der Frage, wenn diese eventuell schon einmal beantwortet wurde, angezeigt werden soll
- (void)frageFrageAb:(Frage *)frage undErlaubeBeantwortung:(BOOL)beantwortung {
    //den neuen QuizfrageAbfrageViewController erstellen
    QuizfrageAbfrageViewController *neuerAbfrageController = [[QuizfrageAbfrageViewController alloc]initWithFrage:frage alsTeilVomQuiz:self.quiz isAnzeigeVonErgebnis:!beantwortung];
    
    //setze das Delegate von diesem neu erstellten ViewController auf diesen PageViewController
    neuerAbfrageController.delegate = self;
    
    
    //das entsprechende Attribut setzen, das den aktuellen Abfrage-View-Controller für diesen PageViewController angibt
    self.aktuellerAbfrageViewController = neuerAbfrageController;
    
    //den neuen ViewController anzeigen
    [self setViewControllers:@[neuerAbfrageController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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

#pragma mark - QuizfrageAbfrageViewControllerDelegate
//wird aufgerufen, wenn eine Frage fertig beantwortet wurde, und dieser PageViewController die nächste Frage anzeigen soll
- (void)quizfrageAbfrageViewController:(QuizfrageAbfrageViewController *)quizfrageAbfrageViewController frageBeantwortet:(Frage *)beantworteteFrage {
    //nächste Frage beim Quiz abfragen
    Frage *naechsteFrage = [self.quiz naechsteFrage];
    NSLog(@"naechste Frage: %@", naechsteFrage);
    if (naechsteFrage) {
        
        //wenn die nächste Frage auch schon beantwortet wurde, dann erlaube die Beantwortung nicht --> so kann auch durch die bereits beantworteten Fragen "gezappt" werden
        BOOL erlaubeBeantwortung = ![self.quiz frageBeantwortet:naechsteFrage];
        
        [self frageFrageAb:naechsteFrage undErlaubeBeantwortung:erlaubeBeantwortung];
    }
    else {
        //wenn die nächste Frage gleich nil ist, es also keine nächste Frage mehr gibt, und das Quiz abgeschlossen ist, zeige den Ergebnis-ViewController an
        [self showErgebnisViewController];
        
    }
}

//wird aufgerufen, wenn die Ergebnis-Seite angezeigt werden soll oder das Quiz abgebrochen werden soll
- (void)quizfrageAbfrageViewController:(QuizfrageAbfrageViewController *)quizfrageAbfrageViewController userRequestedToCancelQuizWithShowingErgebnis:(BOOL)showErgebnis {
    
    //das Quiz beenden
    [self exitQuizHierarchy];
    
}

//mit dieser Methode kann ein ViewController, der die Anzeige einer Frage und deren Abfrage steuert, anfordern, dass die Ergebnis-Seite aufgerufen wird
- (void)quizfrageAbfrageViewControllerRequestToShowResultsPage:(QuizfrageAbfrageViewController *)quizfrageAbfrageViewController {
    //den Ergebnis-ViewController aufrufen
    [self showErgebnisViewController];
    
}

#pragma mark - QuizErgebnisViewControllerDelegate
//wird auch aufgerufen, wenn das Quiz beendet werden soll - diesmal aber, nachdem die Ergebnis-Seite angezeigt wurde
- (void)didEndQuizAndShouldHideQuizErgebnisViewController:(QuizErgebnisViewController *)quizErgebnisViewController {
    //das Quiz beenden
    [self exitQuizHierarchy];
}

//wird aufgerufen, wenn dieser PageViewController eine schon beantwortete Frage und ihr Ergebnis anzeigen soll
- (void)shouldShowErgebnisVonFrage:(Frage *)frage inQuiz:(Quiz *)quiz {
    //den entsprechenden View anzeigen, aber nicht erlauben, die Frage noch zu beantworten
    [self frageFrageAb:frage undErlaubeBeantwortung:NO];
}

@end
