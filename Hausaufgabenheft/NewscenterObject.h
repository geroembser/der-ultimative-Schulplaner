//
//  NewscenterObject.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 13.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>

//Typedef vom Newscenter-Objekt-Typ
typedef NS_ENUM(NSUInteger, NewscenterObjectType) {
    ///Newscenter-Objekt-Typ-WebNews
    NewscenterObjectTypeWebNews = 0, ///Newscenter-Objekt-Typ-SimpleText
    NewscenterObjectTypeSimpleText = 1, ///Newscenter-Objekt-Typ-Vertretungsplan-Notiz
    NewscenterObjectTypeVertretungsplanNotiz = 2, ///Newscenter-Objekt-Typ-Admin-Message
    NewscenterObjectTypeAdminMessage = 3, ///Newscenter-Objekt-Typ-Schulleitung-Message
    NewscenterObjectTypeSchulleitungMessage = 4
};

///Ein Newscenter-Objekt, dass eine News repräsentiert
@interface NewscenterObject : NSObject


#pragma mark - neue Newscenter-Objekte erzeugen
///Diese Methode gibt ein einfaches Newscenter-Objekt mit einem Titel, einem Text und einem Datum zurück
+ (NewscenterObject *)newsCenterObjectWithTitle:(NSString *)title text:(NSString *)text andDate:(NSDate *)date;

#pragma mark - Eigenschaften des Newscenter-Objekts

///der Typ des Newscenter-Objekts
@property NewscenterObjectType typ;

///der Titel des Newscenter-Objekts
@property NSString *newsObjectTitle;

///der Text, der Infos über das Newscenter-Objekt gibt.
@property NSString *newsObjectText;

///NSData für ein image, dass als zusätzliche Information in der Übersicht der Newscenter-Objekte angezeigt werden kann
@property NSData *imageData;

///HTML-String, der Informationen über das Newscenter-Objekt enthalten kann, die später in einem Webview angezeigt werden können
@property NSString *html;

///spezielle Informationen zur jeweiligen Nachricht für das Newscenter, auf die über die jeweiligen Keys in der Dictionary zugegriffen werden kann
@property NSDictionary *userInfo;

///das Datum, an dem diese News "herausgeschickt" wurde bzw. wann etwas fällig ist (bei Aufgaben zum Beispiel)
@property NSDate *scheduledDate;

#pragma mark - Methoden, um Eigenschaften des Objekts zurückzugeben
///gibt einen lesbaren String vom Datum des News-Objekts zurück
- (NSString *)readableDateString;


@end
