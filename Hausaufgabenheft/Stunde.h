//
//  Stunde.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 08.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Schulstunde.h"
#import "Vertretung.h"

@class Schulstunde, StundenplanWochentag;

@interface Stunde : NSObject

///initialisert eine neue Stunde mit einer vorhandenen Schulstunde
- (instancetype)initWithSchulstunde:(Schulstunde *)schulstunde;

///initialisiert eine neue Instanz von einer Stunde in einem Stundenplan mit einem Wochentag und einer Stunde (integer) in der diese Stunde im Stundenplan eingetragen werden soll
- (instancetype)initWithWochentag:(SchulstundeWochentag)wochentag undStunde:(NSUInteger)stunde;

///gibt eine Freistunde zurück, die am gegebenen Wochentag und in der gegebenen Stunde stattfindet
+ (Stunde *)freistundeAmWochentag:(SchulstundeWochentag)wochentag undStunde:(NSUInteger)stunde;

/// die Schulstunde, für die diese Stunde im Stundenplan steht (kann auch nil sein, zum Beispiel bei einer Freistunde)
@property Schulstunde *schulstunde;


///der Accessor von dieser Property gibt zurück, ob es sich um eine Freistunde handelt oder nicht
@property (nonatomic) BOOL freistunde;

///der Wochentag, an dem diese Stunde stattfindet
@property SchulstundeWochentag wochentag;

///das Stundenplan-Wochentag-Objekt, für den Wochentag, der dieser Stunde zugeordnet ist.
@property StundenplanWochentag *wochentagStundenplan;

//die Stunde, in der diese Stunde an diesem Wochentag stattfindet
@property NSUInteger stunde;


///gibt an, ob die Stunde eine Stunde ist, für die eine Vertretung gilt bzw. ob diese Stunde eine Vertretungsstunde ist
- (BOOL)isVertretungsstunde;

///Gibt ein eventuell vorhandenes Vertretungs-Objekt für diese Stunde zurück, dessen dadurch repräsentierte Vertretungsstunde am gegebenen Datum stattfindet. (wenn also diese Stunde vertreten wird oder frei ist, dann ist diese Eigenschaft nicht nil)
- (Vertretung *)vertretungFuerDatum:(NSDate *)date;


@end
