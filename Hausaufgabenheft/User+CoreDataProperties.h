//
//  User+CoreDataProperties.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 07.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "User.h"

@class Aufgabe, WebsiteTag, Mitteilung, Kurs;

NS_ASSUME_NONNULL_BEGIN

@interface User (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *benutzername;
@property (nullable, nonatomic, retain) NSNumber *blocked;
@property (nullable, nonatomic, retain) NSNumber *eingerichtet;
@property (nullable, nonatomic, retain) NSDate *geburtstag;
@property (nullable, nonatomic, retain) NSDate *lastAppOpen;
@property (nullable, nonatomic, retain) NSDate *lastDataUpdate;
@property (nullable, nonatomic, retain) NSDate *lastServerConnection;
@property (nullable, nonatomic, retain) NSDate *lastVertretungsplanConnection;
@property (nullable, nonatomic, retain) NSDate *lastVertretungsplanUpdate;
@property (nullable, nonatomic, retain) NSNumber *loggedIn;
@property (nullable, nonatomic, retain) NSString *nachname;
@property (nullable, nonatomic, retain) NSDate *quizLastUpdate;
@property (nullable, nonatomic, retain) NSNumber *quizPunkte;
@property (nullable, nonatomic, retain) NSString *schuljahr;
@property (nullable, nonatomic, retain) NSString *stufe;
@property (nullable, nonatomic, retain) NSNumber *validData;
@property (nullable, nonatomic, retain) NSString *vorname;
@property (nullable, nonatomic, retain) NSDate *lastMitteilungenUpdate;
@property (nullable, nonatomic, retain) NSSet<Aufgabe *> *aufgaben;
@property (nullable, nonatomic, retain) NSSet<Kurs *> *kurse;
@property (nullable, nonatomic, retain) NSSet<WebsiteTag *> *tags;
@property (nullable, nonatomic, retain) NSSet<Mitteilung *> *mitteilungen;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addAufgabenObject:(Aufgabe *)value;
- (void)removeAufgabenObject:(Aufgabe *)value;
- (void)addAufgaben:(NSSet<Aufgabe *> *)values;
- (void)removeAufgaben:(NSSet<Aufgabe *> *)values;

- (void)addKurseObject:(Kurs *)value;
- (void)removeKurseObject:(Kurs *)value;
- (void)addKurse:(NSSet<Kurs *> *)values;
- (void)removeKurse:(NSSet<Kurs *> *)values;

- (void)addTagsObject:(WebsiteTag *)value;
- (void)removeTagsObject:(WebsiteTag *)value;
- (void)addTags:(NSSet<WebsiteTag *> *)values;
- (void)removeTags:(NSSet<WebsiteTag *> *)values;

- (void)addMitteilungenObject:(Mitteilung *)value;
- (void)removeMitteilungenObject:(Mitteilung *)value;
- (void)addMitteilungen:(NSSet<Mitteilung *> *)values;
- (void)removeMitteilungen:(NSSet<Mitteilung *> *)values;

@end

NS_ASSUME_NONNULL_END
