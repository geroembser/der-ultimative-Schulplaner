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
#import <QuartzCore/QuartzCore.h>

@interface QuizOverviewViewController ()
///der QuizController, dessen Daten angezeigt werden bzw. der benutzt wird, um die Übersicht des Quizes für des User darzustellen und Infos über das Quiz zu gewinnen
@property QuizController *quizController;
@end

@implementation QuizOverviewViewController


#pragma mark - View Setup
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //den QuizController für diesen ViewController setzen
    self.quizController = [QuizController defaultQuizController];
    
    //die Farbe vom NavigationController-View auf weiß setzen, weil es sonst - warum auch immer - zu unschönen Schatten während des Übergangs von einem zu diesem ViewController kommt --> ohne diese folgende Zeile wäre außerdem die NavigationBar wesentlich dunkler
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    
    //die Werte für die entsprechenden View-Objekte nach dem Laden des Views setzen
    //befüllt die Quiz-Infos, die in der Übersicht erscheinen sollen (Name des Benutzers, letztes Update, verfügbare Fragen und Punktestand)
    [self befuelleQuizInfos];
    
    //für Notifications registrieren
    //neue Fragen (also Herunterladen fertig)-Notification --> um die Anzahl der verfügbaren Fragen und das Datum des letzten Updates zu aktualisieren
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quizControllerDidRefreshQuestions:) name:QuizControllerDidRefreshQuestions object:self.quizController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated {
    // Set up the shape of the circle
    int radius = self.punkteContainerView.frame.size.width/2;
    CAShapeLayer *circle = [CAShapeLayer layer];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint point = CGPointMake(self.punkteContainerView.frame.size.width/2, self.punkteContainerView.frame.size.height/2);
    
    [path addArcWithCenter:point radius:radius startAngle:0 endAngle:M_PI*2*0  clockwise:YES];
    
    
    
    // Make a circular shape
    circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)
                                             cornerRadius:radius/2].CGPath;
    circle.path = path.CGPath;
    // Center the shape in self.view
    circle.position = CGPointMake(0,0);
    NSLog(@"%@", NSStringFromCGPoint(circle.position));
    // Configure the apperence of the circle
    circle.fillColor = [UIColor clearColor].CGColor;
    circle.strokeColor = [UIColor whiteColor].CGColor;
    circle.lineWidth = 10;
    
    // Add to parent layer
    [self.punkteContainerView.layer addSublayer:circle];
    
    // Configure animation
    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    drawAnimation.duration            = 1.0; // "animate over 10 seconds or so.."
    drawAnimation.repeatCount         = 1.0;  // Animate only once..
    
    // Animate from no part of the stroke being drawn to the entire stroke being drawn
    drawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    drawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    
    // Experiment with timing to get the appearence to look the way you want
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    // Add the animation to the circle
    [circle addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Methoden
///diese Methode befüllt die entsprechenden Label mit den wichtigen, grundsätzlichen Infos über das Quiz (wie das letzte Update, die verfügbaren Fragen, der Punktestand und der Name des Benutzers
- (void)befuelleQuizInfos {
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

///folgende Methode sollte aufgerufen werden, wenn der Quiz-Controller ein Update der Fragen abgeschlossen hat
- (IBAction)quizControllerDidRefreshQuestions:(id)sender {
    //hier die neuen Werte für das Datum der letzen Aktualisierung und der Anzahl an Quiz-Fragen setzen, wenn der QuizController die Fragen aktualisiert hat --> auf dem Main-Thread ausführen --> user interface-Aktion
    dispatch_async(dispatch_get_main_queue(), ^{
        [self befuelleQuizInfos];
    });
}

#pragma mark - IB-Actions

//ruft den ViewController auf, der die neuen Fragen herunterladen soll
- (IBAction)neueFragenHerunterladen:(id)sender {
    //den ViewController anzeigen, der das Herunterladen der neuen Fragen übernimmt
    DownloadQuizFragenViewController *downloadViewController = [DownloadQuizFragenViewController defaultDownloadQuizFragenViewController];
    
    //den ViewController anzeigen (aber im parentViewController vom navigationController vom QuizOverviewController, damit die Transparenz erhalten bleibt, aber gleichzeitig auch die Tab-Bar überblendet wird
    [self.navigationController.parentViewController presentViewController:downloadViewController animated:YES completion:nil];
}
@end
