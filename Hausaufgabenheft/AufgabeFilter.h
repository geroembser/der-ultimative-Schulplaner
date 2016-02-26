//
//  AufgabeFilter.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 20.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>


///Ein Objekt, was die Filter-Optionen für die Aufgaben verwaltet
@interface AufgabeFilter : NSObject


///gibt an, ob die erledigten Aufgaben angezeigt werden sollen
@property BOOL erledigteAnzeigen;

///enthält alle Kurse, für die die Aufgaben angezeigt werden sollen
@property NSArray *anzuzeigendeKurse;

///das Datum, von dem an alle Aufgaben angezeigt werden sollen
@property NSDate *vonDate;

///das Datum, bis zu dem alle Aufgaben angezeigt werden sollen
@property NSDate *bisDate;

///gibt an, ob die Aufgaben alphabetisch geordnet werden sollen (standardmäßig sollten die Aufgaben nach Fälligkeitsdatum sortiert werden
@property BOOL sortAlphabetically;

///gibt an, ob die erledigten Aufgaben zuerst angezeigt werden sollen, ansonsten werden die ausstehende Aufgaben zuerst angezeigt
@property BOOL erledigteZuerst;

///gibt an, dass die als nächstes zu erledigenden Aufgaben zuerst angezeigt werden sollen
@property BOOL ausstehendeZuerst;

///ein String, der den Suchstring angibt, für den die Aufgaben gefiltert werden sollen
@property NSString *searchString;



@end
