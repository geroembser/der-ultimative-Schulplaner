    //
//  IntroPageViewController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 22.10.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "IntroPageViewController.h"
#import "IntroViewController.h"

@interface IntroPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate> {
    
}


@end

@implementation IntroPageViewController

///view did load
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //in den folgenden Zeilen soll ermöglicht werden, dass das Intro automatisch aus allen ViewControllern im Storyboard erstellt wird die nach dem Schema intro%@ aufgebaut sind. %@ ist sozusagen ein Platzhalter für die Reihenfolge des Intros
    //Zugriff aufs Storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    //die Variablen
    UIViewController *vc;
    
    //den NSMutableArray initialisieren
    self.sourceViewControllers = [NSMutableArray new];
    
    
    
    //Schleife durch alle ver
    for (int i = 0; i < 2; i++) {
        vc = [storyboard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"intro%i", i]];
        
        
        
        //überprüfe, ob der viewController von der Klasse IntroViewController ist, dann setze den parentPageViewController auf self
        if ([vc isKindOfClass:[IntroViewController class]]) {
            [(IntroViewController *)vc setParentPageViewController:self];
        }
        
        [self.sourceViewControllers addObject:vc];
    }
    
    
    //die Delegates setzen und festlegen, woher die Daten bezogen werden sollen
    self.delegate = self;
    self.dataSource = self;
    
    //die Hintergrundfarbe ändern, eventuell zum debuggen
    self.view.backgroundColor = [UIColor whiteColor];
    
    //nur konfigurieren, wenn Objekte im sourceViewControllers array enthalten sind
    if (self.sourceViewControllers.count > 0) {
        
        //den ersten der oben erstellten view controller als Start viewController festlegen
        [self setViewControllers:@[[self.sourceViewControllers firstObject]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

///vorherige ViewController bekommen - Delegate Methode
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSInteger index = [self.sourceViewControllers indexOfObject:viewController];
    
    index--;
    
    if (index >= self.sourceViewControllers.count || index < 0) {
        return nil;
    }
    
    
    return [self.sourceViewControllers objectAtIndex:index];
}

///nächsten ViewController bekommen - Delegate Methode
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSInteger index = [self.sourceViewControllers indexOfObject:viewController];
    index++;
    
    if (index >= self.sourceViewControllers.count || index < 0) {
        return nil;
    }
    
    return [self.sourceViewControllers objectAtIndex:index];
}

///step forward
- (void)stepForward {
    [self setViewControllers:@[[self pageViewController:self viewControllerAfterViewController:self.viewControllers.firstObject]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}


///step back
- (void)stepBack {
    [self setViewControllers:@[[self pageViewController:self viewControllerBeforeViewController:self.viewControllers.firstObject]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

#pragma mark Hilfsmethoden
- (NSUInteger)currentPageIndex {
    return [self.sourceViewControllers indexOfObject:self.viewControllers.firstObject];
}

//
//- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
//
//    return 0;
//}
//
//- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
//    return self.sourceViewController.count;
//}

#pragma mark - Intro: dynamsich ViewController einfügen (entfernen)
- (void)addViewController:(UIViewController *)viewControllerToAdd {
    [self.sourceViewControllers addObject:viewControllerToAdd];
}

- (void)removeViewController:(UIViewController *)viewControllerToRemove {
    //nur, wenn noch mehr als 1 ViewController im sourceViewControllers-array ist
    if (self.sourceViewControllers.count > 1) {
        [self.sourceViewControllers removeObject:viewControllerToRemove];
    }
}

- (void)removeViewControllerAtIndex:(NSUInteger)index {
    //nur, wenn noch mehr als 1 ViewController vorhanden sind
    if (self.sourceViewControllers.count > 1) {
        //wenn der Index gleich dem aktuellen Page Index ist, gehe einen Schritt vor, oder zurück
        if (index == self.currentPageIndex) {
            if (index == 0) {
                [self stepForward];
            }
            else {
                [self stepBack];
            }
        }
        
        //dann den ViewController am gegebenen Index aus dem Source-ViewControllers-Array entfernen
        [self.sourceViewControllers removeObjectAtIndex:index];
    }
}

- (void)removeViewControllersFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    //nur, wenn noch mehr als 1 ViewController vorhanden bleiben (wird von removeViewControllerAtIndex übernommen)
    for (int i = (int)fromIndex; i <= toIndex; i++) {
        [self removeViewControllerAtIndex:i];
    }
    
}

@end
