//
//  WebNewsViewController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 06.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "WebNewsViewController.h"
#import "NewsController.h"
#import "NewsTableViewCell.h"
#import "News.h"
#import "WebNewsDetailViewController.h"

@interface WebNewsViewController () <NewsControllerDelegate>
///der NewsController für die letzten Posts von der Webseite
@property NewsController *recentPostsNewsController;

///der NewsController, der die News in Bezug auf die Relevanz für den User anzeigt
@property NewsController *userTagsNewsController;

///gibt den aktuellen NewsController zurück
@property (nonatomic) NewsController *currentNewsController;
@end

@implementation WebNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //die TableViewCell als Nib für den TableView registrieren
    [self.tableView registerNib:[UINib nibWithNibName:@"NewsTableViewCell" bundle:nil] forCellReuseIdentifier:@"newsTableViewCell"];
    
    //ein "pull to refresh"-feature zum TableView hinzufügen
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(pullToRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    //den Recent Posts NewsController erstellen und den Download beginnen
    NewsController *recentPostsNewsController = [[NewsController alloc]initWithNewsControllerType:newsControllerTypeRecentPosts];
    recentPostsNewsController.delegate = self;
    [recentPostsNewsController startNewsDownload];
    
    self.recentPostsNewsController = recentPostsNewsController;
    
    
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

#pragma mark - TableView
#pragma mark pull to refresh
- (void)pullToRefresh:(UIRefreshControl *)refreshControl {
    // Do your job, when done:
    [refreshControl endRefreshing];
    
    
    //aktualisiere den aktuellen NewsController
    [self.currentNewsController reload];
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count = self.currentNewsController.news.count;
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //die TableViewCell konfigurieren
    NewsTableViewCell *newsTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"newsTableViewCell"];
    
    if (!newsTableViewCell) {
        newsTableViewCell = [[NewsTableViewCell alloc]init];
    }
    
    News *newsForIndexPath = [self.currentNewsController.news objectAtIndex:indexPath.row];
    
    newsTableViewCell.news = newsForIndexPath;
    
    
    //die nächsten News laden, wenn eine der letzten 5 TableRows angezeigt wird
    if (indexPath.row >= [tableView numberOfRowsInSection:indexPath.section]-5) {
        //den Text im tableViewBottom Label so ändern, dass er anzeigt, dass weitere News heruntergeladen werden oder keine weiteren News mehr verfügbar sind
        if ([self.currentNewsController hasMorePagesToLoad] || [self.userTagsNewsController.parentNewsController hasMorePagesToLoad]) { //aber nur wenn noch Seiten verfügbar sind beim currentNewsController oder beim parentNewsController vom userTagsNewsController
            self.tableViewBottomLabel.text = @"weitere News werden geladen...";
        }
        else {
            self.tableViewBottomLabel.text = @"Keine weiteren News verfügbar!";
        }
        
        //die nächsten Nachrichten aus dem NewsController laden
        [self.currentNewsController loadNextPage];
    }
    
    
    return newsTableViewCell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 308.0; // 500.0;// 199.5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //die News mit für die TableViewCell
    News *newsForTableViewCell = [self.currentNewsController.news objectAtIndex:indexPath.row];
    
    //WebNewsDetailViewController erstellen
    WebNewsDetailViewController *webNewsDetailViewController = [[WebNewsDetailViewController alloc]initWithNews:newsForTableViewCell];
    
    //den ViewController im NavigationController anzeigen
    [self.navigationController pushViewController:webNewsDetailViewController animated:YES];
    
    //deselect the row
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - NewsController Delegate
- (void)didBeginRefreshingNewsInNewsController:(NewsController *)newsController {
    //überprüfen, ob der aktuelle NewsController die delegate Nachricht geschickt hat, damit es nicht bei Fehlern vom aktualisieren des TableViews kommt
    if (self.currentNewsController == newsController) {
        //Interface-Aktualisierung im main thread ausführen
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView beginUpdates];
        });
    }
}
- (void)didEndRefreshingNewsInNewsController:(NewsController *)newsController {
    //überprüfen, ob der aktuelle NewsController die delegate Nachricht geschickt hat, damit es nicht bei Fehlern vom aktualisieren des TableViews kommt
    if (self.currentNewsController == newsController) {
        //Interface-Aktualisierung im main thread ausführen
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView endUpdates];
            
            //wenn keine News zum Anzeigen nach einer Aktualisierung des NewsControllers zum Anzeigen verfügbar sind --> dann zeige etwas enstprechendes im TableView-Label an
            if (self.currentNewsController.news.count == 0) {
                self.tableViewBottomLabel.text = @"Keine News verfügbar!";
            }
            else {
                self.tableViewBottomLabel.text = @"weitere News werden geladen...";
            }

        });
    }
}
- (void)newsController:(NewsController *)newsController didInsertObject:(News *)newObj atIndex:(NSUInteger)index {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}- (void)newsController:(NewsController *)newsController didRemoveObject:(News *)newObj atIndex:(NSUInteger)index {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}
- (void)didBeginDownloadingNewsInNewsController:(NewsController *)newsController {
    //einen Text in das tableViewBottomLabel schreiben
    self.tableViewBottomLabel.text = @"aktuelle News werden heruntergeladen...";
}
- (void)newsController:(NewsController *)newsController didFinishDownloadingNewsWithError:(NSError *)error {
    //tableView neuladen
    dispatch_async(dispatch_get_main_queue(), ^{
        //wenn ein Fehler passiert ist, zeige den Fehler an
        if (error) {
            //den Text im tableViewBottomLabel entsprechend setzen
            self.tableViewBottomLabel.text = @"Server-Problem. Bitte neuladen!";
            
            //eine Fehler-Nachricht anzeigen
            [self showErrorMessageWithTitle:@"Server-Problem" andMessage:error.localizedDescription];
        }
        
        //das waitingIndicator Label ausblenden
        self.waitIndicatorLabel.hidden = YES;
    });
    
}

- (void)newsController:(NewsController *)newsController didRefreshNewsObject:(News *)newsObj atIndex:(NSUInteger)index {
    dispatch_async(dispatch_get_main_queue(), ^{
        //die TableViewCell am gegebenen Index neuladen
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}


#pragma mark - Actions
///wird aufgerufen, wenn die News-Quelle von "allen aktuellen" auf "für dich" umgestellt wird
- (IBAction)newsSourceSegmentedControlValueChanged:(UISegmentedControl *)sender {
    
    //den TableView aktualisieren (der TableView wird mit dem currentNewsController aktualisiert, der automatisch beim wechseln des selectedSegmentIndex entsprechend eingestellt wird)
    //den TableView neuladen
    [self.tableView reloadData];
    
    //nach oben im TableView gehen
    [self.tableView setContentOffset:CGPointZero];
    
    //wenn der userTagsNewsController geladen werden soll und der Wert der Variable noch nil ist, dann erstelle ihn neu und starte den Download und die Sortierung der News
    if (sender.selectedSegmentIndex == 1 && self.userTagsNewsController == nil) {
        self.recentPostsNewsController.delegate = nil;
        
        self.userTagsNewsController  = [[NewsController alloc]initWithParentNewsController:self.recentPostsNewsController];
        self.userTagsNewsController.delegate = self;
        self.userTagsNewsController.associatedUser = [User defaultUser];
        [self.userTagsNewsController startNewsDownload];
    }
    else if (sender.selectedSegmentIndex == 1) {
        self.recentPostsNewsController.delegate = nil;
        self.userTagsNewsController.delegate = self;
    }
    else {
        self.userTagsNewsController.delegate = nil;
        self.recentPostsNewsController.delegate = self;
    }
    
    
}

//right swipe
- (IBAction)rightSwipeGestureRecognizerSwipe:(UISwipeGestureRecognizer *)sender {
    self.newsSourceSegmentedControl.selectedSegmentIndex = 0;
    [self newsSourceSegmentedControlValueChanged:self.newsSourceSegmentedControl];
}

- (IBAction)leftSwipeGestureRecognizer:(UISwipeGestureRecognizer *)sender {
    self.newsSourceSegmentedControl.selectedSegmentIndex = 1;
    [self newsSourceSegmentedControlValueChanged:self.newsSourceSegmentedControl];
}

#pragma mark - Setter/Getter
- (NewsController *)currentNewsController {
    if (self.newsSourceSegmentedControl.selectedSegmentIndex == 0) {
        //Modus letzte Posts
        return self.recentPostsNewsController;
    }
    else {
        //Modus Relevanz für Benutzer
        return self.userTagsNewsController;
    }
}

#pragma mark - Error-Handling
- (void)showErrorMessageWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
