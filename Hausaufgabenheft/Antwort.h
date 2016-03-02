//
//  Antwort.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 28.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Frage.h"

NS_ASSUME_NONNULL_BEGIN

///der Typ, der angibt, wie eine Antwort, wenn sie vom Benutzer gegeben wurde, angezeigt werden soll, wenn sich der Benutzer noch einmal das Ergebnis der Frage angucken möchte
typedef enum : NSUInteger {
    ///gibt an, dass der User diese Antwort nicht ausgewählt hat
    AntwortNichtGesetzt, ///gibt an, dass der Benutzer diese Antwort ausgewählt hat, sie aber falsch war
    AntwortFalsch, ///gibt an, dass der Benutzer diese Antwort richtig gegeben hat
    AntwortRichtig,
} GesetzteAntwortTyp;

@interface Antwort : NSManagedObject

#pragma mark - Antworten zurückgeben oder erstellen
///gibt einen Array von Antwort-Objekten zurück, die für eine spezielle Frage festgelegt sind oder nil, wenn für die Frage noch keine Antworten festgelegt sind
+ (NSArray <Antwort *> *)antwortenFuerFrage:(Frage *)frage inManagedObjectContext:(NSManagedObjectContext *)context;

///gibt eine neue Antwort zurück, die direkt automatisch mit der gegebenen Frage verbunden wird
+ (Antwort *)neueAntwortFuerFrage:(Frage *)frage inManagedObjectContext:(NSManagedObjectContext *)context;


#pragma mark - Attribute
///eine temporäre Property, die angibt, wie der User eine Antwort gegeben hat --> wichtig für die Anzeige des Ergebnis einer Frage, auf die bereits geantwortet wurde
@property GesetzteAntwortTyp gesetzteAntwort;

@end

NS_ASSUME_NONNULL_END

#import "Antwort+CoreDataProperties.h"
