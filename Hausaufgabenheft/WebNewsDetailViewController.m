//
//  WebNewsDetailViewController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 07.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "WebNewsDetailViewController.h"

@interface WebNewsDetailViewController ()

@end

@implementation WebNewsDetailViewController

#pragma mark - init
- (instancetype)initWithNews:(News *)news {
    //ViewController vom Storyboard initialisieren
    self = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"webNewsDetailViewController"];
    
    if (self && news) {
        self.associatedNews = news;
    }
    
    return self;
}



#pragma mark - Default methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //das Autor-Label, was bei Scrollen automatisch hinter dem Inhalt verschwinden soll
    [self.webView.scrollView setContentInset:UIEdgeInsetsMake(50, 0, 0, 0)];
    self.webView.backgroundColor = [UIColor clearColor];
    self.autorLabel.text = [NSString stringWithFormat:@"von %@", self.associatedNews.author];
    
    //die Farbe vom NavigationController-View auf weiß setzen, weil es sonst - warum auch immer - zu unschönen Schatten während des Übergangs von einem zu diesem ViewController kommt --> ohne diese folgende Zeile wäre außerdem die NavigationBar wesentlich dunkler
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    
    //den Titel vom ViewController setzen
    self.title = self.associatedNews.title;
    
    //den WebView mit dem HTML-String von der News laden
    //den HTML-String mit einer bestimmten Schriftart erstellen und verhindern, dass der Benutzer Text auswählen kann
    NSString *htmlString = [NSString stringWithFormat:@"<style type=\"text/css\"> * {-webkit-touch-callout: none; -webkit-user-select: none;}</style><font face='Helvetica Light'>%@", self.associatedNews.htmlContent];
    //alle Bilder immer komplett über die ganze Bildschirmbreite
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<img src=\"" withString:@"<img style=\"width:100%; height:auto;\" src=\""];
    
    //den HTML-String im Web-View laden
    [self.webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:self.associatedNews.webURL]];
    
    
    
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

#pragma mark - WebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //wenn ein Link angeklickt wird, dann öffne ihn in Safari
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        //Anfragen in Safari öffnen
        [[UIApplication sharedApplication]openURL:request.URL];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - Actions
- (IBAction)optionButtonClicked:(UIBarButtonItem *)sender {
    //ein AlertController anzeigen, um die Option zum Öffnen in Safari zu geben
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Optionen" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"in Safari öffnen" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //die Seite in Safari öffnen
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:self.associatedNews.webURL]];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"abbrechen" style:UIAlertActionStyleCancel handler:nil]];
    
    //den AlertController anzeigen
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
