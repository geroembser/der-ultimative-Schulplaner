//
//  WebNewsDetailViewController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 07.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "News.h"

@interface WebNewsDetailViewController : UIViewController <UIWebViewDelegate>

#pragma mark - WebNewsDetailViewController erstellen

///erstellt einen neuen ViewController mit einer News
- (instancetype)initWithNews:(News *)news;

#pragma mark - Properties
///Die News, die von den ViewController angezeigt werden
@property News *associatedNews;

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UILabel *autorLabel;

#pragma mark - Actions
- (IBAction)optionButtonClicked:(UIBarButtonItem *)sender;


@end
