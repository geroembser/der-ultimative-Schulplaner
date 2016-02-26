//
//  Stunde.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 08.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "Stunde.h"
#import "Schulstunde.h"
#import "StundenplanWochentag.h"

///Eine Stunde im Stundenplan
@implementation Stunde



#pragma mark - Initialization

- (instancetype)initWithSchulstunde:(Schulstunde *)schulstunde {
    self = [super init];
    
    if (self) {
        self.schulstunde = schulstunde;
        
        //die entsprechenden Attribute zuweisen
        self.wochentag = schulstunde.wochentag.unsignedIntegerValue;
        self.stunde = schulstunde.beginn.unsignedIntegerValue;
        
    }
    
    return self;
}

- (instancetype)initWithWochentag:(SchulstundeWochentag)wochentag undStunde:(NSUInteger)stunde {
    self = [super init];
    
    if (self) {
        self.wochentag = wochentag;
        self.stunde = stunde;
    }
    
    return self;
}



+ (Stunde *)freistundeAmWochentag:(SchulstundeWochentag)wochentag undStunde:(NSUInteger)stunde {
    Stunde *freistunde = [[Stunde alloc]initWithWochentag:wochentag undStunde:stunde];
    
    freistunde.freistunde = YES;
    
    return freistunde;
}



#pragma mark - Methoden bezüglich Vertretungsstunden und Vertretungsplan (aber nur für diese jeweilige Stunde im Stundenplan)
- (BOOL)isVertretungsstunde {
    //überprüfen, ob eine Vertretung für den Wochentag, dem diese Stunde zugeordnet ist, verfügbar ist
    if ([self vertretungFuerDatum:self.wochentagStundenplan.datum]) {
        return YES;
    }
    else return NO;
}

- (Vertretung *)vertretungFuerDatum:(NSDate *)date {
    //durch alle Vertretungsstunden einer Schulstunde (bzw. der Schulstunde für diese Stunde im Stundenplan) enumerieren
    for (Vertretung *vertretung in self.schulstunde.vertretungen) {
        //vergleichen, ob das Datum einer Vertretungsstunde für diese Schulstunde gleich dem Datum ist, dass gegeben wurde, für das also die Vertretungsstunde gesucht wird
        if ([vertretung.datum compare:date] == NSOrderedSame) {
            //wenn das zutrifft, gib diese Vertretungsstunde bzw. dieses Vertretungsobjekt zurück.
            return vertretung;
        }
    }
    //ansonsten wird nil zurückgegeben
    return nil;
}

#pragma mark - Getter/Accessors
- (BOOL)freistunde {
    
    //wenn eine Vertretungsstunde gegeben ist, dann überprüfe, ob diese Stunde frei ist, also EVA.
    if ([self isVertretungsstunde]) {
        //die Vertretung für das Datum der Stunde (gleich Datum des Wochentags
        Vertretung *vertretungFuerDatum = [self vertretungFuerDatum:self.wochentagStundenplan.datum];
        
        //zurückgeben, ob die Stunde frei ist, oder nicht
        return vertretungFuerDatum.eva.boolValue;
    }
    
    //gibt den Wert der _freistunde-Instanz-Variable zurück
    return _freistunde;
}


@end
