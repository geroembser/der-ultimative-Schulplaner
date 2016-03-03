//
//  QuizController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 27.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Frage.h"

@class QuizController;

//die statischen Konstanten für das NSNotificationCenter
///der Key für die Notification, die angibt, dass der QuizController neue Fragen hinzugefügt hat oder alte aktualisiert hat
static NSString* const QuizControllerDidRefreshQuestions = @"QuizControllerDidRefreshQuestions";
///der Key für die Notification, die angibt, dass das Update der Quiz-Fragen fehlgeschlagen ist; die Fehlermeldung kann aus der User-Info-Dictionary gelesen werden (key: NSLocalizedFailureReasonErrorKey);
static NSString* const QuizControllerUpdateFailed = @"QuizControllerUpdateFailed";

///das Delegate-Protokoll des QuizControllers, um über spezielle Vorgänge zu informieren
@protocol QuizControllerDelegate <NSObject>

- (void)quizController:(QuizController *)quizController didCreateNumberOfNewQuestions:(NSInteger)newQuestionsInt;
- (void)quizController:(QuizController *)quizController didFinishAddingQuestionsWithError:(NSError *)error;

@end

///Dieser Controller verwaltet das Quiz und stellt Methoden zum Download und zur Abfrage von Inhalten in Zusammenhang mit dem Quiz dar
@interface QuizController : NSObject

#pragma mark - Quiz-Controller Instanzen erstellen
///gibt den QuizController für den Standard-Benutzer zurück
+ (QuizController *)defaultQuizController;

///erstellt einen neuen QuizContorller mit dem gegebenen User, für den der QuizController die Fragen und das ganze Quiz verwaltet
- (instancetype)initWithUser:(User *)user;

#pragma mark - Methoden für die Verwaltung der Quiz-Fragen etc.
///startet den Download von neuen Fragen für den User
- (void)downloadNeueFragen;

///bricht den aktuellen Download ab
- (void)cancelCurrentQuestionDownload;

///löscht alle Quizfragen des Benutzers
- (void)loescheAlleQuizfragenDesBenutzers;

///gibt die Anzahl der Fragen zurück, die verfügbar sind.
- (NSUInteger)numberOfAvailableQuestions;

///gibt den aktuellen Punktestand für den User dieses QuizControllers zurück
- (NSInteger)punktestand;

///gibt alle für den User verfügbaren Fragen zurück, sortiert nach Themenbereichen
- (NSArray <Frage *> *)alleFragen;

///sollte einen Array von den dreißig neusten für den User verfügbaren Fragen zurückgeben
- (NSArray <Frage *> *)alleDreißigNeustenFragen;

///gibt eine Fetched Request zurück, mit allen aktiven Kursen des Users des QuizControllers, für die Fragen verfügbar sind
- (NSFetchRequest *)alleKurseMitFragenFetchedRequest;

#pragma mark - Attribute
///der User, für den der QuizController die Quiz-Fragen etc. verwaltet
@property User *user;

@end
