//
//  NewsTableViewCell.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 06.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "NewsTableViewCell.h"

@implementation NewsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
}

//die setHighlighted-Methode überschreiben, damit die Hintergrundfarbe vom excerptLabel beim hervorheben nicht transparent wird;
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
    UIColor *originalExcerptLabelBackgroundColor = self.excerptLabel.backgroundColor;
    
    [super setHighlighted:highlighted animated:animated];
    
    self.excerptLabel.backgroundColor = originalExcerptLabelBackgroundColor;
}



#pragma mark - Cell konfigurieren
///konfiguriert die TableViewCell
- (void)setNews:(News *)news {
    //das Titel-Label
    self.titelLabel.text = news.title;
    
    //das Bild für den ImageView
    if (news.imageData) {
        self.previewImageView.image = [UIImage imageWithData:news.imageData];
    }
    else {
        self.previewImageView.image = nil;
    }
    
    //das Datums-Label
    NSString *textForDateLabel = @"";
    //Time-Interval von jetzt bis zum Datum erstellen
    NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT]; //erst die Sekunden herausfinden, die noch in der Zeitzone, in der man gerade ist, draufgerechnet werden müssen, weil das Datum von [NSDate date] immer in UTC-Zeit ist
    NSDate *currentDate = [[NSDate date]dateByAddingTimeInterval:timeZoneSeconds]; //dort eben die Zeitzonen-Unterschiede draufrechnen, damit die nächste Zeile die unterschiedlichen Zeitzonen beachtet
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:news.date]; //Intervall vom aktuellen Datum nehmen, wegen Unterschiede in Zeitzonen
    if (timeInterval < 60) {
        //Sekunden
        NSString *oneOrMore = timeInterval < 1 ? @"Sekunde" : @"Sekunden"; //ist nötig, damit 1 Tag und 2 Tage etc. angezeigt wird
        textForDateLabel = [NSString stringWithFormat:@"vor %.f %@", timeInterval, oneOrMore];
    }
    else if (timeInterval < 3600) { //3600 Sekunden hat eine Stunde
        //Minuten
        NSString *oneOrMore = timeInterval/60 < 2 ? @"Minute" : @"Minuten";
        textForDateLabel = [NSString stringWithFormat:@"vor %.f %@", timeInterval/60, oneOrMore];
    }
    else if (timeInterval < 86400) { //84600 Sekunden hat ein Tag
        //Stunden
        NSString *oneOrMore = timeInterval/3600 < 2 ? @"Stunde" : @"Stunden";
        textForDateLabel = [NSString stringWithFormat:@"vor %.f %@", timeInterval/3600, oneOrMore];
    }
    else if (timeInterval < 2259200) { //nach dreißig Tagen (2259200 Sekunden haben 30 Tage) --> ansonsten das genaue Datum anzeigen
        //Tage
        NSString *oneOrMore = timeInterval/86400 < 2 ? @"Tag" : @"Tagen";
        textForDateLabel = [NSString stringWithFormat:@"vor %.f %@", timeInterval/86400, oneOrMore];
    }
    else {
        //genaues Datum anzeigen
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"dd.MM.yyyy, HH.mm"];
        
        textForDateLabel = [NSString stringWithFormat:@"vom %@ Uhr", [df stringFromDate:news.modifiedDate]];
    }
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"dd.MM.yyyy, HH.mm"];
    self.dateLabel.text = textForDateLabel;
    
    
    //die Vorschau der News im entsprechenden Label anzeigen
    self.excerptLabel.text = [news plainExcerptText];
    
}

@end
