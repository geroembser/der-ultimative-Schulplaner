//
//  News.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 06.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebsiteTag.h"

///ein neues News-Objekt, dass eine Nachricht von der Webseite repräsentiert
@interface News : NSObject

#pragma mark - Initialisierung
///initialisiert das News-Objekt mit einer JSON-Dictionary die so vom Server zurückgegeben wurde
- (instancetype)initWithJSONDictionary:(NSDictionary *)jsonDict;

#pragma mark - Properties

@property NSString *title;
@property NSString *webURL;
@property NSNumber *id;
@property NSString *author;
@property NSString *htmlContent;
@property NSString *htmlExcerpt; //Vorschau
@property NSString *leadimageURL;
@property NSArray *tagNames;
@property NSDate *date;
@property NSDate *modifiedDate;
@property NSString *status;
@property NSData *imageData;

///Diese Einstellung gibt die Relevanz einer News-Meldung an
@property NSInteger relevanz;

#pragma mark - Methoden
//gibt nur den Text von der Vorschau zurück, indem es die HTML-Elemente entfernt
- (NSString *)plainExcerptText;

#pragma mark Relevanz-Bewertung
///Schätzt die News anhand des gegebenen WebsiteTags ein und bewertet die Relevanz, die in der öffentlichen relevanz-Property des News-Objekts gespeichert wird.
- (void)einschaetzenMitWebsiteTag:(WebsiteTag *)tag;
///Schätzt die News anhand der gegebenen WebsiteTags ein und bewertet die Relevanz, die in der öffentlichen relevanz-Property des News-Objekts gespeichert wird.
- (void)einschaetzenMitWebsiteTags:(NSArray <WebsiteTag *> *)tags;


@end
