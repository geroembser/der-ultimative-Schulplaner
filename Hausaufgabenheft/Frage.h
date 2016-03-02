//
//  Frage.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 28.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Antwort, Kurs;

NS_ASSUME_NONNULL_BEGIN

@interface Frage : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

#pragma mark - Frage zurückgeben oder neu erstellen

///gibt eine vorhandene Frage mit der ID zurück oder nil
+ (Frage *)vorhandeneFrageMitID:(NSInteger)frageID inManagedObjectContext:(NSManagedObjectContext *)context;

///gibt eine vorhandene Frage mit der ID zurück oder erstellt eine neue, wenn die Frage noch nicht vorhanden ist
+ (Frage *)frageMitID:(NSInteger)frageID inManagedObjectContext:(NSManagedObjectContext *)context;

///erstellt eine neue Frage in der Datenbank mit der gegebenen Frage-ID
+ (Frage *)neueFrageMitID:(NSInteger)frageID inManagedObjectContext:(NSManagedObjectContext *)context;


#pragma mark - Infos über die Frage zurückgeben
///gibt alle Antworten für diese Frage in einem Array zurück und sortiert diese auf Wunsch (je nach übergebener Boolean-Variable) zufällig; die zweite übergebene Variable, richtigeElemente, enthält die Anzahl der Elemente, innerhalb derer ab Anfang (Index 0) mindestens eine richtige Antwort dabei sein soll --> das ist wichtig, damit zum Beispiel bei den Antwort-Buttons mindestens eine richtige Antwort dabei ist
- (NSArray <Antwort *> *)antwortenFuerFrageSortiertZufaellig:(BOOL)zufaellig mitRichtigerFrageInnerhalbDerErstenElemente:(NSUInteger)richtigeElemente;

///gibt den allgemeinen String zurück, der als Antwort ausgegeben werden soll
- (NSString *)allgemeinerAntwortString;


@end

NS_ASSUME_NONNULL_END

#import "Frage+CoreDataProperties.h"
