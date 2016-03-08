//
//  NewscenterObject.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 13.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "NewscenterObject.h"

@implementation NewscenterObject

#pragma mark - neue Newscenter-Objekte erstellen 

+ (NewscenterObject *)newsCenterObjectWithTitle:(NSString *)title text:(NSString *)text andDate:(NSDate *)date {
    NewscenterObject *news = [[NewscenterObject alloc]init];
    
    news.typ = NewscenterObjectTypeSimpleText;
    news.newsObjectTitle = title;
    news.newsObjectText = text;
    news.scheduledDate = date;
    
    return news;
}

+ (NewscenterObject *)newsCenterObjectWithMitteilung:(Mitteilung *)mitteilung {
    if (mitteilung) {
        NewscenterObject *news = [[NewscenterObject alloc]init];
        
        news.typ = NewscenterObjectTypeSchulleitungMessage; //Typ einer Mitteilung, die von der Schulleitung bzw. von Schulseite kommt
        news.newsObjectTitle = mitteilung.titel;
        news.newsObjectText = mitteilung.nachricht;
        news.scheduledDate = mitteilung.datum;
        
        
        return news;
    }
    
    return nil;
}

#pragma mark - Eigenschaften des Newscenter-Objekts zurückgeben
- (NSString *)readableDateString {
    //dafür einen DateFormatter benutzen
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd.MM.YYYY, hh.mm"];
    
    return [dateFormatter stringFromDate:self.scheduledDate];
}

@end
