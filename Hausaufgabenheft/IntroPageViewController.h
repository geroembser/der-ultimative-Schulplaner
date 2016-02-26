//
//  IntroPageViewController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 22.10.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * IntroPageViewController soll hauptsächlich das scrollen durch Intro steuern
 */

@interface IntroPageViewController : UIPageViewController

///the view controllers which should contain the intro
@property NSMutableArray *sourceViewControllers;

///einen neuen ViewController dynamisch zum Intro hinzufügen (zum Beispiel, wenn ein Anmeldeschritt erfolgreich ausgeführt wurd)
- (void)addViewController:(UIViewController *)viewControllerToAdd;

///einen gegebenen ViewController dynamisch aus dem Intro entfernen.
- (void)removeViewController:(UIViewController *)viewControllerToRemove;

///entfernt einen ViewController dynamisch, der am angegebenen Index im sourceViewControllers-Array steht
- (void)removeViewControllerAtIndex:(NSUInteger)index;

///entfernt alle ViewController dynamisch von PageViewController im angegebenen Index-Bereich
- (void)removeViewControllersFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;





///einen Schritt zurück im Intro gehen
- (void)stepBack;

///einen Schritt vorwärts gehen, im Intro
- (void)stepForward;



///der Index, der aktuell angezeigten Seite im PageViewController
@property (nonatomic)  NSUInteger currentPageIndex;

@end
