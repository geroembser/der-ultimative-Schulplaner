//
//  Newscenter.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 13.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "Newscenter.h"

@interface Newscenter ()
///Alle News-Objekte, die von diesem News-Center verwaltet werden
@property NSMutableArray *newsObjects;
@end

@implementation Newscenter

#pragma mark - Returning instances

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
        //initialisiere den newsObject-array
        self.newsObjects = [NSMutableArray new];
        
        //ein Test-News-Objekt bzw. Willkommens-Newsobjekt (kann als ein solches ausgegeben werden)
        NewscenterObject *newsObject = [NewscenterObject newsCenterObjectWithTitle:@"Herzlich Willkommen" text:@"Herzlich Willkommen im Newscenter deiner BMS-App" andDate:[NSDate date]];
        [self.newsObjects addObject:newsObject];
    }
    
    return self;
}

+ (Newscenter *)defaultNewscenter {
    static Newscenter *defaultNC = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultNC= [[Newscenter alloc]init];
    });
    
    return defaultNC;
}


#pragma mark - News-Infos
- (NewscenterObject *)newscenterObjectAtIndex:(NSUInteger)index {
    if (index < self.newsObjects.count) {
        return [self.newsObjects objectAtIndex:index];
    }
    
    return nil;
}

- (NSUInteger)numberOfNewsEntries {
    return self.newsObjects.count;
}


#pragma mark - Newscenter-Aktionen
- (void)startCreatingNewsFromDefaultSources {

    
    //das Datum der letzten Aktualisierung auf jetzt setzen
    self.lastNewscenterUpdate = [NSDate date];
}

- (void)reloadNewscenter {
    //die Delegate-Methoden aufrufen, die angibt, dass die Aktualisierung begonnen hat
    
    //alle vorhandenen News löschen
    
    //das Datum der letzten Aktualisierung auf jetzt setzen
    self.lastNewscenterUpdate = [NSDate date];
    
    //die Delegate-Methode aufrufen, die angibt, dass die Aktualiserung abgeschlosen wurde
}

@end
