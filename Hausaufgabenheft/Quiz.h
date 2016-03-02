//
//  Quiz.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 28.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Frage.h"
#import "User.h"

@interface Quiz : NSObject


#pragma mark - Quiz erstellen
///initialisiert ein neues Quiz mit einem Array von Fragen für den gegebenen Benutzer
- (instancetype)initWithArrayVonFragen:(NSArray <Frage *> *)fragen andUser:(User *)user;

///erstellt ein neues Quiz mit dem gegebenen Array von Fragen; zusätzlich kann angegeben werden, ob die Fragen zufällig abgefragt werden sollen; der Benutzer, für den das Quiz erstellt werden soll, muss zusätzlich angegeben werden
+ (Quiz *)quizZusammenstellenMitArrayVonFragen:(NSArray <Frage *> *)fragen randomly:(BOOL)randomly fuerUser:(User *)user;


#pragma mark - Methoden
///gibt die nächste Frage, die abgefragt werden soll, zurück - oder nil
- (Frage *)naechsteFrage;

///der Aufruf dieser Methode markiert die gegebenen Frage als richtig oder falsch und entfernt sie aus dem unbearbeiteteFragen-array; diese Methode sollte im Zusammenspiel mit der naechsteFrage-Methode benutzt werden, weil das Ergebnis der naechsteFrage-Methode von dieser Methode abhängig ist
- (void)frage:(Frage *)frage richtigBeantwortet:(BOOL)richtig;

///gibt eine Frage im Quiz zurück, die an der gegebenen Stelle im Fragen-Array steht.
- (Frage *)frageAtIndex:(NSUInteger)index;

///gibt den Index einer Frage in allen Fragen zurück
- (NSUInteger)indexOfFrageInAllenFragen:(Frage *)frage;

///gibt zurück, ob eine Frage bereits beantwortet wurde oder nicht
- (BOOL)frageBeantwortet:(Frage *)frage;

///gibt an, ob eine Frage richtig (gibt true zurück) oder falsch (gibt false zurück) beantwortet wurde
- (BOOL)frageRichtigBeantwortet:(Frage *)frage;

#pragma mark - Attribute
//der Benutzer, der das Quiz ausführt
@property User *user;

///gibt an, ob die Fragen des Quizzes zufällig abgefragt werden sollen
@property BOOL randomly;

///gibt die Anzahl der Fragen im Quiz zurück
@property (nonatomic) NSUInteger numberOfQuestions;

///gibt die Anzahl der Fragen zurück, die bereits bearbeitet wurden.
@property (nonatomic) NSUInteger anzahlBearbeiteterFragen;

///die Anzahl der Fragen, die bisher richtig beantwortet wurden
@property NSUInteger anzahlRichtigBeantworteterFragen;

///gibt die Anzahl der falsch beantworteten Fragen für dieses Quiz zurück
@property (nonatomic) NSUInteger anzahlFalschBeantworteterFragen;

///der Array mit allen Fragen, die im Quiz abgefragt werden sollen
@property NSArray *alleFragen;

///die Fragen im Quiz, die noch nicht beantwortet wurden und noch bearbeitet werden müssen
@property NSMutableArray *unbeantworteteFragen;

///die Fragen, die bereits bearbeitet wurden
@property NSMutableArray *beantworteteFragen;

///die Fragen, die im Quiz richtig beantwortet wurden
@property NSMutableArray *richtigBeantworteteFragen;

///die Fragen, die im Quiz falsch beantwortet wurden
@property NSMutableArray *falschBeantowrteteFragen;



@end
