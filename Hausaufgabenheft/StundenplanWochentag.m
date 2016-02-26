//
//  StundenplanWochentag.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 29.12.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "StundenplanWochentag.h"

@implementation StundenplanWochentag

+ (StundenplanWochentag *)wochentagFuerWochentag:(SchulstundeWochentag)wochentag mitStunden:(NSArray *)stunden {
    StundenplanWochentag *sw = [[StundenplanWochentag alloc]init];
    
    sw.wochentagInt = wochentag;
    sw.stunden = stunden;
    
    //jeder Stunde für diesen Wochentag jeweils einen Verweis zu diesem Wochentag-Objekt setzen
    for (Stunde *stunde in stunden) {
        stunde.wochentagStundenplan = sw;
    }
    
    return sw;
}

- (Stunde *)schulstundeFuerStunde:(NSUInteger)stunde {
    //suche im stunden-Array die Stunde, die die gegebenen Bedingungen erfüllt
    for (Stunde *schulstunde in self.stunden) {
        if (schulstunde.stunde == stunde+1) { //+1, weil der übergebene Wert der Stunde bei 0 beginnt, in der Datenbank die Werte aber bei 1 beginnen
            //dann wurde eine Stunde mit den gegebenen Eigenschaften gefunden
            return schulstunde;
        }
    }
    
    
    //wenn bishierhin nichts zurückgegeben wurde, dann gib eine Freistunde zurück
    return [Stunde freistundeAmWochentag:self.wochentagInt undStunde:stunde];
}

- (NSUInteger)letzteStundeIndex {
    if (self.stunden && self.stunden.count > 0) {
        //ist der Beginn-Index der letzten Stunde im Stundenarray
        return [(Stunde *)self.stunden.lastObject stunde];
    }
    
    return 0;
}

@end
