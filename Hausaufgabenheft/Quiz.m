//
//  Quiz.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 28.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "Quiz.h"

@implementation Quiz


#pragma mark - Quiz erstellen
- (instancetype)initWithArrayVonFragen:(NSArray<Frage *> *)fragen andUser:(User *)user{
    //wenn kein Array von Fragen gegeben wurde, gebe auch kein Quiz zurück
    if (!fragen || fragen.count == 0 || user == nil) {
        return nil;
    }
    
    self = [super init];
    
    if (self) {
        //den User für das Quiz setzen
        self.user = user;
        
        //die Arrays mit den Fragen initialisieren
        self.alleFragen = fragen;
        
        //die MutableArrays mit den unbeantworteten und beantworteten Fragen initialisieren
        self.unbeantworteteFragen = [[NSMutableArray alloc]initWithArray:self.alleFragen];
        self.beantworteteFragen = [[NSMutableArray alloc]init];
        
        //die MutableArrays mit den richtig und falsch beantworteten Fragen initialisieren
        self.richtigBeantworteteFragen = [NSMutableArray new];
        self.falschBeantowrteteFragen = [NSMutableArray new];
    }
    return self;
}

+ (Quiz *)quizZusammenstellenMitArrayVonFragen:(NSArray<Frage *> *)fragen randomly:(BOOL)randomly fuerUser:(User *)user{
    Quiz *neuesQuiz = [[Quiz alloc]initWithArrayVonFragen:fragen andUser:user];
    
    if (neuesQuiz) {
        neuesQuiz.randomly = randomly;
    }
    
    return neuesQuiz;
}

#pragma mark - Infos über das Quiz zurückgeben
- (NSUInteger)anzahlBearbeiteterFragen {
    return self.beantworteteFragen.count;
}
- (NSUInteger)anzahlFalschBeantworteterFragen {
    return self.numberOfQuestions-self.anzahlRichtigBeantworteterFragen;
}

- (NSUInteger)numberOfQuestions {
    return self.alleFragen.count;
}

- (Frage *)frageAtIndex:(NSUInteger)index {
    return [self.alleFragen objectAtIndex:index];
}

- (NSUInteger)indexOfFrageInAllenFragen:(Frage *)frage {
    return [self.alleFragen indexOfObject:frage];
}

- (Frage *)naechsteFrage {
    ///gibt die jeweils erste Frage des unbeantworteteFragen-arrays zurück, wenn nicht zufällig beim Quiz gewählt wurde
    Frage *frageToReturn;
    if (self.randomly && self.unbeantworteteFragen.count > 0) { //eine unbeantwortete Frage muss mindestens vorhanden sein
        frageToReturn = [self.unbeantworteteFragen objectAtIndex:arc4random()%self.unbeantworteteFragen.count];
    }
    else frageToReturn = self.unbeantworteteFragen.firstObject;
    
    return frageToReturn;
}

- (void)frage:(Frage *)frage richtigBeantwortet:(BOOL)richtig {
    if (frage) {
        //zähle die Anzahl bei der Frage hoch, wie oft diese schon richtig/falsch beantwortet wurde
        frage.anzahlRichtigBeantwortet = @(frage.anzahlRichtigBeantwortet.integerValue+(int)richtig); //kleiner Trick... 😉
        
        frage.anzahlFalschBeantwortet = @(frage.anzahlFalschBeantwortet.integerValue+(int)!richtig);
        
        //mache das gleiche bei der Einstellung, wie viele Fragen während des gesamten Quizzes schon richtig beantwortet wurden
        self.anzahlRichtigBeantworteterFragen+=richtig;
        
        //die Frage aus dem unbeantworteteFragen-array entfernen und dem bearbeitete Fragen-Array hinzufügen
        [self.unbeantworteteFragen removeObject:frage];
        [self.beantworteteFragen addObject:frage];
        
        //wenn eine Frage richtig beantwortet wurde, füge sie zu dem Array mit den richtig beantworteten Fragen hinzu, ansonsten zu dem Array mit den falsch beantworteten Fragen
        if (richtig) {
            [self.richtigBeantworteteFragen addObject:frage];
        }
        else {
            [self.falschBeantowrteteFragen addObject:frage];
        }
    }
}

- (BOOL)frageBeantwortet:(Frage *)frage {
    //die Position im Array mit den beantworteten Fragen
    NSUInteger pos = [self.beantworteteFragen indexOfObject:frage];
    
    if (pos != NSNotFound) {
        //wenn die Position also in dem Array ist, dann gib YES/true zurück
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)frageRichtigBeantwortet:(Frage *)frage {
    //gibt zurück, ob die Frage in dem Array mit den richtig beantworteten Fragen enthalten ist --> wenn sie enthalten ist, dann sollte sie auch richtig beantwortet worden sein
    return [self.richtigBeantworteteFragen containsObject:frage];
}
@end
