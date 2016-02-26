//
//  PhotoViewController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 30.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController () <UIScrollViewDelegate>

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //setzte das Foto, was vom MediaFile verwaltet wird, als Bild in den ImageView des PhotoViewControllers
    UIImage *photoImage = [UIImage imageWithData:[self.photoMediaFile getMediaData]];
    
    self.imageView.image = photoImage;
    
    self.scrollView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //wenn der View wieder angezeigt wird, dann setzte den Zoom auf Standard (1.0)
    [self.scrollView setZoomScale:1.0 animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - Init
- (instancetype)initWithPhotoMediaFile:(MediaFile *)mediaFile {
    self = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"photoViewController"];
    
    if (self && mediaFile) {
        self.photoMediaFile = mediaFile;
        
        
        
    }
    
    return self;
}

#pragma mark - ScrollView Delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

@end
