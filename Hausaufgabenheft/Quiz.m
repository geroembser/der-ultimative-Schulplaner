//
//  Quiz.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 28.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "Quiz.h"
#import "NSMutableArray+Shuffling.h"

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
    //wenn randomly gewählt wurde, dann mische den Array mit den Fragen vorher einmal durch
    if (randomly) {
        NSMutableArray *fragenMutable = [NSMutableArray arrayWithArray:fragen];
        [fragenMutable shuffle];
        
        fragen = fragenMutable;
    }
    
    //dann erstelle das Quiz
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
    ///gibt die jeweils erste Frage des unbeantworteteFragen-arrays zurück (auch wenn zufällig beim Quiz gewählt wurde, weil der Array dann vorher durchgemischt wurde, damit der Zugriff mit Indizes etc. später funktioniert und man beispielsweise weiß, die wie vielte Frage abgefragt wird
    return self.unbeantworteteFragen.firstObject;
}

- (void)frage:(Frage *)frage richtigBeantwortet:(BOOL)richtig {
    if (frage) {
        //kleiner Trick... 😉: bei der Einstellung, wie viele Fragen während des gesamten Quizzes schon richtig beantwortet wurden
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
        
        
        //die Frage in der Datenbank markieren und hochzählen, wie oft die Frage schon beantwortet wurde
        [frage frageBeantwortet:richtig];
        
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
