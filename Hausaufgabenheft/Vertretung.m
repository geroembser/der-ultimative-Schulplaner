//
//  Vertretung.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 09.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "Vertretung.h"
#import "Lehrer.h"
#import "Schulstunde.h"

@implementation Vertretung


#pragma mark - Vertretungsstunden erstellen
+ (Vertretung *)vertretungFuerSchulstunde:(Schulstunde *)schulstunde inManagedObjectContext:(NSManagedObjectContext *)context {
    if (context) {
        Vertretung *neueVertretung = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"Vertretung"
                                      inManagedObjectContext:context];
        neueVertretung.schulstunde = schulstunde;
        
        return neueVertretung;
    }
    
    return nil;
}


#pragma mark - Eigenschaften über Vertretungsstunden zurückgeben
- (BOOL)isRaumVertretung {
    if (![self.schulstunde.raumnummer isEqualToString:self.raum]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isFrei {
    
    //unterscheide im folgenden zwischen mehreren Fällen, weil die Vertretungsplan-Dateien aus Untis wohl so exportiert werden, dass wenn eine Stunde ausfällt, dies oft durch jeweils unterschiedliche (was oft wahrscheinlich auch mit dem Grund des Ausfalls zusammenhängt) Eigenschafts-Felder der Vertretungsstunde deutlich gemacht wird
    
    //wenn Vertretungsplan-Vertretungsart ist gleich "C" (für Cancel=Entfall der Stunde) --> dann ist die Stunde schonmal frei
    if ([self.art isEqualToString:@"C"]) {
        return YES;
    }
    //der String "32" im artBitfields-Feld sollte auch angeben, dass die Stunde frei ist...
    else if ([self.artBitfields isEqualToString:@"32"]) {
        return YES;
    }
    
    
    
    return NO;
}

@end
