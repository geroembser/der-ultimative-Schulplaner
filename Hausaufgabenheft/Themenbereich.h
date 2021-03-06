//
//  Themenbereich.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 28.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Frage, Kurs;

NS_ASSUME_NONNULL_BEGIN

@interface Themenbereich : NSManagedObject


#pragma mark - Themenbereich-Instanzen zurückgeben
///gibt einen vorhandenen Themenbereich im gegebenen ManagedObjectContext zurück, der die gegebenen ID hat --> ansonsten nil
+ (Themenbereich *)vorhandenerThemenbereichMitID:(NSInteger)themenID inManagedObjectContext:(NSManagedObjectContext *)context;

///gibt einen vorhandenen Themenbereich mit der gegebenen ID im gegebenen ManagedObjectContext zurück oder erstellt einen neuen Themenbereich in der Datenbank
+ (Themenbereich *)themenbereichMitID:(NSInteger)themenID inManagedObjectContext:(NSManagedObjectContext *)context;

///erstellt einen neuen Themenbereich im gegebenen ManagedObjectContext mit der gegebenen ID für den neuen Themenbereich
+ (Themenbereich *)neuerThemenbereichMitID:(NSInteger)themenID inManagedObjectContext:(NSManagedObjectContext *)context;


#pragma mark - Attribute bzw. Infos über den Kurs zurückgeben
///gibt die Anzahl aller Fragen in diesem Themenbereich an
- (NSUInteger)anzahlFragen;

///gibt die Anzahl der richtigen Fragen in diesem Themenbereich zurück
- (NSUInteger)anzahlRichtigerFragen;

@end

NS_ASSUME_NONNULL_END

#import "Themenbereich+CoreDataProperties.h"
