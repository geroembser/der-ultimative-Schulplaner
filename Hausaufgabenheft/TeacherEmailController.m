//
//  TeacherEmailController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 20.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "TeacherEmailController.h"

@implementation TeacherEmailController


#pragma mark - initialization
- (instancetype)initWithLehrer:(Lehrer *)lehrer andUser:(User *)user {
    self = [super init];
    
    if (self) {
        //den Betreff der E-Mail setzen
        [self setSubject:@"Frage (über BMS-App)"];
        
        
        [self setToRecipients:@[lehrer.email]];

        NSString *anrede = @"Lieber";
        if (![lehrer.titel isEqualToString:@"Herr"]) {
            anrede = @"Liebe";
        }
        NSString *bodyString = [NSString stringWithFormat:@"%@ %@, \n\n\n\nMit freundlichen Grüßen\n%@ %@", anrede, [lehrer printableTeacherString], user.vorname, user.nachname];
        [self setMessageBody:bodyString isHTML:NO];
    }
    
    return self;
}


@end
