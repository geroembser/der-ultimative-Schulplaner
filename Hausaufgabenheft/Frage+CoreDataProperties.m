//
//  Frage+CoreDataProperties.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 29.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Frage+CoreDataProperties.h"

@implementation Frage (CoreDataProperties)

@dynamic anzahlFalschBeantwortet;
@dynamic anzahlRichtigBeantwortet;
@dynamic dateLetzteRichtigeAntwort;
@dynamic frage;
@dynamic id;
@dynamic imageURL;
@dynamic schwierigkeit;
@dynamic hinzugefuegtAm;
@dynamic zuletztAktualisiert;
@dynamic antworten;
@dynamic kurs;
@dynamic themenbereich;

@end
