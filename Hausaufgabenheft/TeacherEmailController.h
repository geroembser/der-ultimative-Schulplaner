//
//  TeacherEmailController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 20.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Lehrer.h"
#import "User.h"

///Diese Unterklasse vom MFMailComposeViewController kann dazu benutzt werden, einen  standardisierten View zu geben, der es ermöglicht, eine E-Mail an einen Lerer zu schreiben
@interface TeacherEmailController : MFMailComposeViewController

#pragma mark - Initialization
///Erstellt einen TeacherEmailViewController, mit dem der Benutzer dem Lehrer einen E-Mail schreiben kann. Der übergebene Lehrer-Parameter enthält die Einstellungen des Lehrers, die notwendig sind, um eine vorgefertigte E-Mail zu erstellen. Der andere übergebenen Parameter, der User-Parameter, wird benötigt, um den Namen des Benutzer an die E-Mail anzufügen.
- (instancetype)initWithLehrer:(Lehrer *)lehrer andUser:(User *)user;

//weiter Eigenschafte, Methoden etc. werden von Superklasse genommen

@end
