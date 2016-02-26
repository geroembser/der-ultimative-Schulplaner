//
//  PhotoViewController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 30.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaFile.h"

@interface PhotoViewController : UIViewController

#pragma mark - Methoden

///erstellt einen neuen PhotoViewController, der das Foto von dem übergebenen MediaFile darstellen sollte;
- (instancetype)initWithPhotoMediaFile:(MediaFile *)mediaFile;

///das Foto, dass von diesem ViewController angezeigt wird
@property MediaFile *photoMediaFile;


///der Index, also die Position, an der dieser ViewController im PageViewController ist
@property NSUInteger index;

#pragma mark - Outlets
///der imageView, in dem das Bild für das MediaFile angezeigt werden soll
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

///der scrollView, in dem das Bild bewegt werden kann
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@end
