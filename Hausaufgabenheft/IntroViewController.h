//
//  IntroViewController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 22.10.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

/**
 * Basis ViewController Klasse für jeden ViewController im Intro.
 * Diese Klasse wird dazu benutzt, zum Beispiel einen Verweis zum aufrufenden PageViewController zu bekommen, um dann beispielsweise bei einer Methode, die durch einen Button ausgelöst wird, im PageViewController zu "scrollen".
 */


#import <UIKit/UIKit.h>
#import "IntroPageViewController.h"

@interface IntroViewController : UIViewController


///IntroPageViewController, der die IntroViewController enthält
@property IntroPageViewController *parentPageViewController;

@end
