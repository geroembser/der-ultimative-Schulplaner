//
//  User+CoreDataProperties.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 27.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "User+CoreDataProperties.h"

@implementation User (CoreDataProperties)

@dynamic benutzername;
@dynamic blocked;
@dynamic eingerichtet;
@dynamic geburtstag;
@dynamic lastAppOpen;
@dynamic lastDataUpdate;
@dynamic lastServerConnection;
@dynamic lastVertretungsplanConnection;
@dynamic lastVertretungsplanUpdate;
@dynamic loggedIn;
@dynamic nachname;
@dynamic schuljahr;
@dynamic stufe;
@dynamic validData;
@dynamic vorname;
@dynamic quizPunkte;
@dynamic quizLastUpdate;
@dynamic aufgaben;
@dynamic kurse;
@dynamic tags;

@end
