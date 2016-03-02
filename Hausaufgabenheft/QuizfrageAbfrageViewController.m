//
//  QuizfrageAbfrageViewController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 28.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "QuizfrageAbfrageViewController.h"
#import "Antwort.h"
#import "Kurs.h"
#import "Themenbereich.h"
#import "NSDate+AdvancedDate.h"

@interface QuizfrageAbfrageViewController ()
///der Array, der die Zeiger zu alle Buttons enthält, die für Antworten genutzt werden können --> das Nutzen eines Arrays anstatt der statischen Programmierung kann später vielleicht einmal Vorteile bringen
@property NSArray <AntwortButton *> *alleAntwortenButtons;
///gibt an, ob die Frage gelöst wurde
@property BOOL frageGeloest;
///gibt an, ob die Frage richtig gelöst wurde --> in abhängigkeit zur frageGeloest-Property
@property BOOL frageRichtigGeloest;
///gibt an, ob nur das Ergebnis angezeigt werden soll, oder ob auch die Möglichkeit zur Beantwortung der Frage bestehen soll
@property BOOL nurAnzeigeVonErgebnis;
@end

@implementation QuizfrageAbfrageViewController


#pragma mark - Initialisierung
- (instancetype)init {
    self = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"quizfrageAbfrageViewController"];
    
    if (self) {
        
    }
    
    return self;
}

- (instancetype)initWithFrage:(Frage *)frage alsTeilVomQuiz:(Quiz *)quiz {
    self = [self init];
    
    if (self) {
        if (frage && quiz) {
            self.quiz = quiz;
            self.frage = frage;
        }
    }
    
    return self;
}

- (instancetype)initWithFrage:(Frage *)frage alsTeilVomQuiz:(Quiz *)quiz isAnzeigeVonErgebnis:(BOOL)isErgebnis {
    //erstmal mit bereits vorhandener, anderer Initialisierungsmethode initialisieren
    self = [self initWithFrage:frage alsTeilVomQuiz:quiz];
    
    if (self) {
        //wenn isErgebnis=YES, dann setze die entsprechende Instanzvariable/das entsprechende Attribut des Objekt
        self.nurAnzeigeVonErgebnis = isErgebnis;
    }
    
    return self;
}



#pragma mark - View-Setup
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //den Array mit den Zeigern zu allen Antworten-Buttons erstellen
    self.alleAntwortenButtons = @[self.antwortButton1, self.antwortButton2, self.antwortButton3, self.antwortButton4];
    
    //Die Frage richtig im user interface anzeigen
    
    //die Anzahl der Fragen setzen
    self.fragenNummerLabel.text = [NSString stringWithFormat:@"Frage %lu von %lu", [self.quiz indexOfFrageInAllenFragen:self.frage]+1, self.quiz.numberOfQuestions]; //[self.quiz indexOfFrageInAllenFragen:self.frage]+1, weil der Index immer bei 0 anfängt und außer der Informatiker wahrscheinlich keiner anfängt, bei null zu zählen 😂
    
    //den Fragen-Text anzeigen, in dem Format, wie es im Storyboard festgelegt ist
    self.frageTextView.selectable = YES; //vorher auf YES setzen...
    self.frageTextView.text = self.frage.frage;
    self.frageTextView.selectable = NO; //...nachher auf NO setzen, weil sonst - warum auch immer - bei jedem neuen Setzen von Text in den TextView, das Textformat resettet wird.
    
    //die Antworten setzen
    //dafür alle Antworten der Frage erhalten
    NSArray *antworten = [self.frage antwortenFuerFrageSortiertZufaellig:YES mitRichtigerFrageInnerhalbDerErstenElemente:4]; //letzter Parameter ist gleich 4, weil 4 Antwort-Buttons verfügbar sind
    
    
    for (int i = 0; i < self.alleAntwortenButtons.count; i++) {
        //den jeweiligen Button des Schleifendurchlaufs bekommen
        AntwortButton *antwortButton = [self.alleAntwortenButtons objectAtIndex:i];
        
        //überprüfen, der Antworten-Array auch eine Antwort für den Button-i hat
        if (i < antworten.count) {
            //die jweilige Antwort
            Antwort *antwortFuerButton = [antworten objectAtIndex:i];

            //die Antwort in den Button setzen
            [antwortButton setzeAntwort:antwortFuerButton];
            
            //wenn für den jeweiligen Button die temporäre Property gesetzt ist, die angibt, dass diese Antwort in einem Quiz ausgewählt wurde und sich dieser Controller in dem Modus befindet, dass "nurAnzeigeVonErgebnis" und keine Beantwortung erlaubt ist --> dann markiere den entsprechenden Button als ausgewählt bzw. richtig oder falsch --> eigentlich nur wichtig für die Anzeige der Frage, wenn das Ergebnis der letzten Bearbeitung angezeigt werden soll
            if (self.nurAnzeigeVonErgebnis) {
                if (antwortFuerButton.gesetzteAntwort == AntwortRichtig) {
                    //die Antwort als richtig darstellen
                    [antwortButton markiereAlsRichtig:YES];
                }
                else if (antwortFuerButton.gesetzteAntwort == AntwortFalsch) {
                    //die Antwort als falsch anzeigen
                    [antwortButton markiereAlsRichtig:NO];
                    
                }
                //den jeweiligen Antwort-Button deaktivieren, weil der Benutzer nicht mehr die Möglichkeit bekommen darf, auf die Frage erneut zu antworten
                antwortButton.enabled = NO;
            }
        }
        //wenn keine Antwort mehr verfügbar ist, dann deaktiviere den antwort-Button und setze einen leeren Titel in den Button
        else {
            //setze einen leeren Titel in den Button
            [antwortButton setTitle:@"" forState:UIControlStateNormal];
            
            //deaktiviere diesen
            antwortButton.enabled = NO;
        }
        
    }
    
    //den Text im Label setzen, das die ID für die Frage angeben soll
    self.frageIDLabel.text = [NSString stringWithFormat:@"Frage %@", self.frage.id.stringValue];
    
    //den Text im Detail-Label setzen
    //der String, der im Detail-Label angezeigt werden soll
    NSString *detailLabelString = @"";
    
    //der String für den Namen des Themenbereichs
    if (self.frage.themenbereich) {
        NSString *themaString = self.frage.themenbereich.name;
        //wenn der String leer ist oder keiner ist, dann hänge ihn nicht an den detailLabelString, ansonsten schon
        if (themaString.length > 0 && ![themaString isEqualToString:@""]) {
            detailLabelString = [detailLabelString stringByAppendingFormat:@"%@; ", themaString]; //Semikolon und Leerzeichen am Anfang, damit die Teile voneinander getrennt sind
        }
    }
    
    //den String für den Kurs, aber nur wenn ein Kurs mit der Frage verbunden wurde und dieser auch existiert
    if (self.frage.kurs) {
        NSString *kursString = self.frage.kurs.id; //die ID des Kurses setzen
        //wenn der String leer ist oder keiner ist, dann hänge ihn nicht an den detailLabelString, ansonsten schon
        if (kursString.length > 0 && ![kursString isEqualToString:@""]) {
            detailLabelString = [detailLabelString stringByAppendingFormat:@"%@", kursString];
        }
    }

    //alternativ wäre auch die folgende Anzeige der Daten im Detail-Label möglich
//    //den String für den Kurs, aber nur wenn ein Kurs mit der Frage verbunden wurde und dieser auch existiert
//    if (self.frage.kurs) {
//        NSString *kursString = self.frage.kurs.id; //die ID des Kurses setzen
//        //wenn der String leer ist oder keiner ist, dann hänge ihn nicht an den detailLabelString, ansonsten schon
//        if (kursString.length > 0 && ![kursString isEqualToString:@""]) {
//            detailLabelString = [detailLabelString stringByAppendingFormat:@"Kurs: %@", kursString];
//        }
//    }
//    
//    //der String für den Namen des Themenbereichs
//    if (self.frage.themenbereich) {
//        NSString *themaString = self.frage.themenbereich.name;
//        //wenn der String leer ist oder keiner ist, dann hänge ihn nicht an den detailLabelString, ansonsten schon
//        if (themaString.length > 0 && ![themaString isEqualToString:@""]) {
//            detailLabelString = [detailLabelString stringByAppendingFormat:@"; Themenbereich: %@", themaString]; //Semikolon und Leerzeichen am Anfang, damit die Teile voneinander getrennt sind
//        }
//    }
//    
//    //der String für die Schwierigkeit der Frage
//    if (self.frage.schwierigkeit) {
//        NSString *schwierigkeitString = self.frage.schwierigkeit.stringValue;
//        //wenn der String leer ist oder keiner ist, dann hänge ihn nicht an den detailLabelString, ansonsten schon
//        if (schwierigkeitString.length > 0 && ![schwierigkeitString isEqualToString:@""]) {
//            detailLabelString = [detailLabelString stringByAppendingFormat:@"; Schwierigkeit: %@", schwierigkeitString];
//        }
//    }
//    
//    //der String für das Datum, an dem die Frage zur lokalen Datenbank hinzugefügt wurde
//    if (self.frage.hinzugefuegtAm) {
//        NSString *datumString = [self.frage.hinzugefuegtAm datumUndUhrzeitString];
//        //wenn der String leer ist oder keiner ist, dann hänge ihn nicht an den detailLabelString, ansonsten schon
//        if (datumString.length > 0 && ![datumString isEqualToString:@""]) {
//            detailLabelString = [detailLabelString stringByAppendingFormat:@"; hinzugefügt Am: %@", datumString];
//        }
//    }

    
    //den erstellten Detail-String in das Label setzen
    self.frageDetailsLabel.text = detailLabelString;
    
    
    //wenn dieser ViewController nur das Ergebnis einer schon bereits beantworteten Frage anzeigen soll, dann setze den Titel des Lösen-Buttons auf "Lösung anzeigen" und konfiguriere weitere Dinge
    if (self.nurAnzeigeVonErgebnis) {
        ///sagen, dass die Frage gelöst ist
        self.frageGeloest = YES;
        
        //feststellen, ob die Frage richtig gelöst wurde
        self.frageRichtigGeloest = [self.quiz frageRichtigBeantwortet:self.frage];
        
        //den Lösen-Button entsprechend konfigurieren
        [self setzeLoesungButtonAufRichtig:self.frageRichtigGeloest];
        
        //den weiter-Button aktivieren
        self.nextQuestionButton.enabled = YES;
    }
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

#pragma mark - user interface Methoden
- (void)setzeLoesungButtonAufRichtig:(BOOL)richtig {
    //den Text des Lösen-Buttons auf Lösung anzeigen setzen
    [self.loesenButton setTitle:@"Lösung anzeigen" forState:UIControlStateNormal];
    
    //die Hintergrundfarbe entsprechend ändern, je nach dem, ob die Frage richtig oder falsch beantwortet wurde
    if (richtig) {
        //ein spezielles grün benutzen
        [self.loesenButton setBackgroundColor:[UIColor colorWithRed:0.71 green:0.81 blue:0.40 alpha:1.0]];
    }
    else {
        //ein spezielles rot benutzen
        [self.loesenButton setBackgroundColor:[UIColor colorWithRed:0.89 green:0.02 blue:0.07 alpha:1.0]];
    }
    
    //die Schriftfarbe des Lösen-Buttons auf weiß setzen
    [self.loesenButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

#pragma mark - Methoden 
///überprüft die Frage und gibt einen Boolean zurück, der angibt, ob der User die Frage richtig beantwortet hat
- (BOOL)ueberpruefeFrage {
    //zählt die Anzahl der falschen Antwortenim unten folgenden Überprüfungsprozess der Fragen --> wird später dafür genutzt, ob die ganze Frage wirklich korrekt beantwortet wurde
    int anzahlFalscherAntworten = 0;
    
    //die mit den Antworten-Buttons verbundenen Antworten durchgehen und überprüfen
    for (AntwortButton *antwortButton in self.alleAntwortenButtons) {
        //die Antwort, die vom jeweiligen Antwort-Button angezeigt wird
        Antwort *antwort = antwortButton.displayingAntwort;
        
        //überprüfen, ob die Antwort richtig ist und das mit der ausgewählt-Property des AntwortButtons vergleichen
        if (antwort.richtig.boolValue == antwortButton.ausgewaehlt) {
            //markiere diesen Antwort-Button als richtig oder eben als falsch, je nachdem ob die Frage richtig oder falsch ist --> sollte das zur Verwirrung führen: obige if-Bedingung überprüft, ob der User richtig geantwortet hat, der Button soll aber nur seine bei der richtigen Antwort seine Farbe ändern
            if (antwort.richtig.boolValue) {
                [antwortButton markiereAlsRichtig:YES];
                
                //beim Button angeben, dass die richtige Antwort vom benutzer gegeben wurde --> wichtig für später eventuell erfolgende Anzeige des Ergebnisses einer einzelnen Frage durch den User
                antwort.gesetzteAntwort = AntwortRichtig;
            }
            else {
                //in diesem Fall hat der Benutzer den jeweiligen Button des aktuellen Schleifendurchlaufs nicht ausgewählt --> er hat also keine Antwort gesetzt
                antwort.gesetzteAntwort = AntwortNichtGesetzt; //--> ist wichtig, dieses trotzdem zu setzen, damit nicht bei der Anzeige des Ergebnisses einer Frage ein eventuelles Ergebnis aus einem vorherigem Quiz angezeigt wird
            }
        }
        else {
            //markiere den Antwort-Button als falsch
            [antwortButton markiereAlsRichtig:NO];
            
            antwort.gesetzteAntwort = AntwortFalsch;
            
            //zähle die Variable, die die Anzahl der falschen Antworten zählt, hoch
            anzahlFalscherAntworten++;
        }
    }
    
    //die entsprechende Instanzvariable setzen, die angibt, dass die Frage gelöst wurde
    self.frageGeloest = YES;
    
    
    //wenn falsche Antworten gegeben wurden, dann return NO
    if (anzahlFalscherAntworten > 0) {
        self.frageRichtigGeloest = NO;
        return NO;
    }
    //ansonsten alles richtig --> return YES
    self.frageRichtigGeloest = YES;
    
    return YES;
}

#pragma mark - Actions
- (IBAction)naechsteFrage:(id)sender {
    //beim Quiz die aktuelle Frage als richtig markieren oder eben als falsch
    [self.quiz frage:self.frage richtigBeantwortet:self.frageRichtigGeloest];
    
    //teile dem Delegate mit, dass die Beantwortung der Frage erfolgreich abgeschlossen wurde
    if (self.delegate && [self.delegate respondsToSelector:@selector(quizfrageAbfrageViewController:frageBeantwortet:)]) {
        [self.delegate quizfrageAbfrageViewController:self frageBeantwortet:self.frage];
    }
}

- (IBAction)cancelButtonClicked:(id)sender {
    //einen AlertController anzeigen, der fragt, ob das Quiz wirklich abgebrochen werden soll --> wenn dieser ViewController nur zur Anzeige eines Ergebnisses von einer Frage genutzt wird, dann gib die Möglichkeit an, zur Ergebnis-Seite zu gelangen
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Wirklich abbrechen?" message:@"Möchtest du das Quiz wirklich abbrechen?" preferredStyle:UIAlertControllerStyleActionSheet];
    
    //Quiz fortführen - Action
    [alertController addAction:[UIAlertAction actionWithTitle:@"Nein, weiter lernen 🎒" style:UIAlertActionStyleCancel handler:nil]];
    
    //Quiz abbrechen Actions
    NSString *quizCancelButtonTitle = self.nurAnzeigeVonErgebnis ? @"Quiz komplett beenden!" : @"Abbrechen ☹️";
    [alertController addAction:[UIAlertAction actionWithTitle:quizCancelButtonTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        //dem Delegate, also dem Page-View-Controller sagen, dass sich dieser um die Anzeige der Ergebnis-Seite kümmern soll, die standardmäßig angezeigt werden soll
        if ([self.delegate respondsToSelector:@selector(quizfrageAbfrageViewController:userRequestedToCancelQuizWithShowingErgebnis:)]) {
            [self.delegate quizfrageAbfrageViewController:self userRequestedToCancelQuizWithShowingErgebnis:YES];
        }
    }]];
    
    //wenn nur das Ergebnis angezeigt werden soll, dann gebe noch die Möglichkeit, zur Ergebnisseite zurückzukehren
    if (self.nurAnzeigeVonErgebnis) {
        //eine neue alert-action hinzufügen
        [alertController addAction:[UIAlertAction actionWithTitle:@"🔙 zurück zu den Ergebnissen... " style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //hier die entsprechende Delegate-Methode aufrufen (vom parent-page-view-controller), um zur Ergebnis-Seite zurückzukehren
            if (self.delegate && [self.delegate respondsToSelector:@selector(quizfrageAbfrageViewControllerRequestToShowResultsPage:)]) {
                [self.delegate quizfrageAbfrageViewControllerRequestToShowResultsPage:self];
            }
        }]];
    }
    
    //den Alert-Controller anzeigen
    [self presentViewController:alertController animated:YES completion:nil];
    
}

///löst die Frage, die durch diesen View dargestellt sit
- (IBAction)frageLoesen:(id)sender {
    //wenn Frage bereits gelöst wurde, dann zeige die Lösung an, ansonsten löse die Frage
    if (self.frageGeloest) {
        UIAlertController *loesungView = [UIAlertController alertControllerWithTitle:@"Lösung" message:[self.frage allgemeinerAntwortString] preferredStyle:UIAlertControllerStyleAlert];
        
        [loesungView addAction:[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil]];
        
        [self presentViewController:loesungView animated:YES completion:nil];
        
        return;
    }
    
    //die Frage überprüfen
    BOOL richtig = [self ueberpruefeFrage];

    //den Lösungs-Button entsprechend konfiguriert anzeigen
    [self setzeLoesungButtonAufRichtig:richtig];
    
    //die Antwort-Buttons deaktivieren oder so einstellen, dass sie die Details zu ihrer Antwort anzeigen (letzteres später vielleicht irgendwann einmal)
    for (AntwortButton *antwortButton in self.alleAntwortenButtons) {
        antwortButton.enabled = NO;
    }

    //den weiter-Button aktivieren
    self.nextQuestionButton.enabled = YES;
}

#pragma mark - die einzelnen Buttons der einzelnen Antworten und ihre Actions
//die einzelnen Button-Actions
- (IBAction)button1Clicked:(AntwortButton *)sender {
    //wenn Frage gelöst wurde, dann einen AlertController anzeigen, der die Hilfe zu dieser Antwort anzeigt...
    
    //...ansonsten das "Standard-Verfahren" anwenden.
    [sender setzeButtonAufAusgewaehlt:!sender.ausgewaehlt];
}

- (IBAction)button2Clicked:(AntwortButton *)sender {
    [sender setzeButtonAufAusgewaehlt:!sender.ausgewaehlt];
}

- (IBAction)button3Clicked:(AntwortButton *)sender {
    [sender setzeButtonAufAusgewaehlt:!sender.ausgewaehlt];
}

- (IBAction)button4Clicked:(AntwortButton *)sender {
    [sender setzeButtonAufAusgewaehlt:!sender.ausgewaehlt];
}
@end
