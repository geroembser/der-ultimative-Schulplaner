//
//  LoginViewController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 25.10.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "IntroViewController.h"

@interface LoginViewController : IntroViewController <UITextFieldDelegate>

#pragma mark UI - input
/* interface objects - input-textfields */
///email textfield
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
///password textfield
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
///sutfe textfield
@property (weak, nonatomic) IBOutlet UITextField *stufeTextfield;


#pragma mark UI - buttons
/* interface objects - buttons */
///login button
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

///logout button
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

///Weiter-Button, kann angezeigt werden, wenn man bereits angemeldet ist, und weiter gehen möchte
@property (weak, nonatomic) IBOutlet UIButton *weiterButton;

#pragma mark UI-status objects
/* interface objects - status */
///login activity indicator
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loginActivityIndicator;


#pragma mark - UI Methoden und Actions
/* interface objects - button actions */
///action die aufgerufen wird, wenn der Login-Button gedrückt wird
- (IBAction)loginClicked:(UIButton *)sender;

///action die aufgerufen wird, wenn der Logout-Button gedrückt wird
- (IBAction)logoutClicked:(id)sender;

///action, die ausgeführt wird, wenn ein Benutzer auf den Weiter-Button drückt
- (IBAction)weiterButtonClicked:(id)sender;

/* actions */
///logs in with the information from the emailTextfield and the passwordTextfield
- (void)loginWithInformationFromTextfields;

/* constraints */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weiterButtonHeightConstraint;


#pragma mark - UI other Outlets
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


#pragma mark - Fehlerhaftes Passwort später - Neu-Anmelden
//hier Methoden bereitstellen, die ermöglichen, die Zugangsdaten erneut einzugeben und einen entsprechenden Text anzuzeigen, der darauf hinweist, dass das Passwort oder der Benutzername nicht mehr stimmt
- (LoginViewController *)loginViewControllerForFailedUserAccessData;


@end
