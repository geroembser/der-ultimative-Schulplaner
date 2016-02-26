//
//  PhotosPageViewController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 30.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaFilesDetailViewController.h"

@interface PhotosPageViewController : UIPageViewController


///der parentController von diesen ViewController, der über einen ContainerView im Storyboard eingebunden worden sein sollte und von dem dieser PageViewController seine Daten beziehn soll
@property MediaFilesDetailViewController *parentController;


@end
