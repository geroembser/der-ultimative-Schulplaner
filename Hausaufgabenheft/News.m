//
//  News.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 06.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "News.h"
#import "NSString+HTML.h"
#import "User.h"

@implementation News

#pragma mark - Initialisierung
- (instancetype)initWithJSONDictionary:(NSDictionary *)jsonDict {
    self = [super init];
    
    if (self) {
        //die einzelnen Einstellungen aus der gegebenen jsonDict zu den einzelnen News-Properties setzen
        if (jsonDict) {
            //der Titel des Artikels
            self.title = [[jsonDict objectForKey:@"title"]stringByDecodingHTMLEntities]; //HTML-Kodierungen umwandeln, sodass zum Beispiel das &-Zeichen korrekt angezeigt wird und nicht "&#038;"
            
            //der HTML-Content String des Artikels
            self.htmlContent = [jsonDict objectForKey:@"content"];
            
            //der Autor des Artikels
            NSArray *autoren = [[jsonDict objectForKey:@"custom_fields"]objectForKey:@"Autor"];;
            
            self.author = [autoren componentsJoinedByString:@", "];
            
            //das Bild zum Artikel
            NSArray *leadImages = [[jsonDict objectForKey:@"custom_fields"]objectForKey:@"leadimage"];
            self.leadimageURL = leadImages.firstObject;
            
            //die Dates
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            self.date = [dateFormatter dateFromString:[jsonDict objectForKey:@"date"]];
            self.modifiedDate = [dateFormatter dateFromString:[jsonDict objectForKey:@"modified"]];
            
            //die HTML - Vorschau
            self.htmlExcerpt = [jsonDict objectForKey:@"excerpt"];
            
            //die ID
            self.id = [jsonDict objectForKey:@"id"];
            
            //die Tags
            NSArray *tagDicts = [jsonDict objectForKey:@"tags"]; //die Dictionarys von den zurückgegebenen Daten mit den Tags
            NSMutableArray *tagNamesMutable = [NSMutableArray new]; //ein "temporärer" Array, der nur die Namen der Tags enthalten soll
            for (NSDictionary *tagDict in tagDicts) {
                [tagNamesMutable addObject:[tagDict objectForKey:@"slug"]]; //sozusagen die Beschreibung des Tags als Tag-Namen zum temporären tagNamesMutable-array hinzufügen
            }
            //die tagNames sollten jetzt die sein, die im tagNamesMutable-array gespeichert sind
            self.tagNames = tagNamesMutable;
                                 
            //die URL im Web
            self.webURL = [jsonDict objectForKey:@"url"];
            
            //der Status
            self.status = [jsonDict objectForKey:@"status"];
        }
    }
    
    return self;
}

#pragma mark - Methoden

- (NSString *)plainExcerptText {
    return [self.htmlExcerpt stringByConvertingHTMLToPlainText];
}

#pragma mark Relevanz-Bewertung
- (void)einschaetzenMitWebsiteTag:(WebsiteTag *)tag {
    //erstmal überprüfen, ob der Tag überhaupt zu der Nachricht/News passt
    //dazu erst die Tags des News-Objekts mit dem tag vergleichen
    for (NSString *aTagForNews in self.tagNames) {
        if ([aTagForNews isEqualToString:tag.tag]) {
            //dann passt der Tag zu dem Artikel thematisch
            //also die Relevanz erhöhen
            self.relevanz+=tag.vorkommenBeiAktivenKursen.integerValue; //die Relevanz einmal um das Vorkommen des Tags bei den verschiedenen Kursen erhöhen
            self.relevanz+=tag.relevanz.integerValue; //und einmal um die sonstige Relevanz des Tags
        }
    }

    //dann noch überprüfen, wie oft der String/Tag im plain text vom htmlContent enthalten ist
    NSString *plainHTMLContent = [self.htmlContent stringByConvertingHTMLToPlainText];
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:tag.tag options:NSRegularExpressionCaseInsensitive error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:plainHTMLContent options:0 range:NSMakeRange(0, plainHTMLContent.length)];
    if (!error) {
        //wenn kein Fehler passiert ist, die Relevanz erhöhen, je nachdem, wie oft der Tag im plainHTMLContent vorkam
        //aber die Relevanz nicht um die Anzahl des Vorkommens erhöhen, sondern nur um das Viertel davon oder eben 0, wenn das Viertel davon kleiner als 1 ist
        NSInteger addToRelevance = numberOfMatches; //(long)(numberOfMatches/4);
        self.relevanz+=addToRelevance;
    }
    
    //dann noch zählen, wie oft der Name des Benutzers im Text vorkommt --> dann die Relevanz mal das 10-fache hochzählen
    User *user = [User defaultUser];
    
    regex = [NSRegularExpression regularExpressionWithPattern:user.fullName options:NSRegularExpressionCaseInsensitive error:&error];
    numberOfMatches = [regex numberOfMatchesInString:plainHTMLContent options:0 range:NSMakeRange(0, plainHTMLContent.length)];
    if (!error) {
        //wenn kein Fehler passiert ist, die Relevanz erhöhen, je nachdem, wie oft der Name im plainHTMLContent vorkam
        NSInteger addToRelevance = numberOfMatches*10; //mal das Zehnfache
        self.relevanz+=addToRelevance;
    }
    
    //zusätlich gucken, ob der Autor vielleicht gleich dem Benutzer ist --> die Relevanz sollte dann ebenfalls erhöht werden
    if ([self.author isEqualToString:user.fullName]) {
        //den Artikel auch höcher einstufen
        self.relevanz+=5; //die Relevanz um fünf erhöhen
    }
    
    //wenn die Schleife oben nicht beendet worden sein sollte, und numberOfMathes gleich 0 ist und man zu diesem Punkt der Code-Ausführung gelangt, dann ist die Relevanz des Tags für diese News - aber nur für diesen Tag - gleich 0;
}

- (void)einschaetzenMitWebsiteTags:(NSArray<WebsiteTag *> *)tags {
    for (WebsiteTag *tag in tags) {
        [self einschaetzenMitWebsiteTag:tag];
    }
}

@end
