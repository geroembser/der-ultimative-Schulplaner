//
//  MediaFilesDetailViewController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 30.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "MediaFilesDetailViewController.h"
#import "PhotoViewController.h"
#import "PhotosPageViewController.h"

@interface MediaFilesDetailViewController ()
@property NSUInteger startIndex;
@end

@implementation MediaFilesDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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


#pragma mark - Initialization
//init
- (instancetype)initWithMediaFiles:(NSMutableArray<MediaFile *> *)mediaFiles startingWithFileAtIndex:(NSUInteger)startIndex andPointerToArrayOfMediaFilesToDelete:(NSMutableArray<MediaFile *> *)mediaFilesToDelete{
    self = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"mediaFilesDetailViewController"];
    
    if (self && mediaFiles) {
        
        self.mediaFiles = mediaFiles;
        
        if (mediaFiles.count > 0 && startIndex < mediaFiles.count) {
            self.startIndex = startIndex;
            
            self.currentMediaFileIndex = startIndex;
            self.currentMediaFile = [self.mediaFiles objectAtIndex:self.currentMediaFileIndex];
        }
        
        self.mediaFilesToDelete = mediaFilesToDelete;
        
    }
    
    return self;
}


#pragma mark - PageViewController-Data-Source
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
   
    
    //der ViewController, der der vorherige desjenigen sein soll, der jetzt zurückgegeben werden soll, in eine Variable speichern und als PhotoViewController parsen, um an die index-property von ihm zu gelangen, um zu ermitteln, an welchem Index der ViewController steht
    PhotoViewController *after = (PhotoViewController *)viewController;
    
    
    
    //nur wenn nach dem aktuellen Index im Array noch ein Objekt kommt --> dann einen neuen ViewController zurückgeben
    if (after.index+1 < self.mediaFiles.count) {
        //das MediaFile, dass durch den nächsten ViewController, also den ViewController, der zurückgegeben werden soll, angezeigt werden soll
        MediaFile *mediaFile = [self.mediaFiles objectAtIndex:after.index+1];
        
        //dann den entsprechenden PhotoViewController zurückgeben
        PhotoViewController *photoViewController = [[PhotoViewController alloc]initWithPhotoMediaFile:mediaFile];
        photoViewController.index = after.index+1;
        
        return photoViewController;
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    PhotoViewController *before = (PhotoViewController *)viewController; //den vorherigen ViewController erstmal in einer Variable bekommen, um dann seinen Index ermitteln zu können
    
    //nur wenn vor dem aktuellen Index im Array noch ein Objekt kommt --> dann zeige das vorherige Bild an, das also vor dem Bild war, dass aktuell im PageView angezeigt wird
    if (before.index != 0) {
        MediaFile *mediaFile = [self.mediaFiles objectAtIndex:before.index-1];
        
        //den entsprechenden PhotoViewController zurückgeben
        //dann den entsprechenden PhotoViewController zurückgeben
        PhotoViewController *photoViewController = [[PhotoViewController alloc]initWithPhotoMediaFile:mediaFile];
        photoViewController.index = before.index-1;
        
        return photoViewController;
    }
    
    return nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(nonnull NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    //den aktuell angezeigten PhotoViewController nehmen
    PhotoViewController *photoViewController = pageViewController.viewControllers.firstObject;
    
    //daraus das MediaFile und den aktuellen Index beziehen
    self.currentMediaFile = photoViewController.photoMediaFile;
    self.currentMediaFileIndex = photoViewController.index;
    
}

#pragma mark - Methoden, damit PageViewController, der in einem Storyboard-ContainerView ist, richtig funktioniert
//folgenden zwei Methoden dafür, dass der PageViewController, der ein Kind von diesem ViewController ist und über einen ContainerView im Storyboard eingebunden wurde, weiß, woher er seine Daten bzw. ViewController für sich als PageView beziehen kann

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    //weil bei ContainerViews sozusagen beim Einbetten des ChildViewControllers eine Segue benutzt wird, benutzt man diese Methode, um dem photosPageViewController, also dem Ziel-ViewController der Segue, mitzuteilen, wer der parentViewController ist und damit von wem der Ziel-ViewController seine Daten beziehen soll
    PhotosPageViewController *photoPageViewController = segue.destinationViewController;
    photoPageViewController.parentController = self;
    
    //hier auch die entsprechende, im Prinzip gegensätliche Variable setzten, wie ein Befehl zuvor hier drüber
    self.pageViewController = photoPageViewController;
}

- (PhotoViewController *)startViewController {
    PhotoViewController *pageZero = [[PhotoViewController alloc]initWithPhotoMediaFile:[self.mediaFiles objectAtIndex:self.currentMediaFileIndex]];
    pageZero.index = self.startIndex; //start-Seite --> StartIndex, damit es im weiteren Verlauf auch alles weiter vernünftig funktioniert (mit den anderen Methoden des Page-View-Data-Source-Protokolls)
    return pageZero;
}


#pragma mark - Top-/Bottom-Bar-Methoden (schließen, löschen etc.)
- (IBAction)fertigButtonClicked:(id)sender {
    //den aktuellen ViewController ausblenden
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)trashButtonClicked:(id)sender {
    //nachfragen, ob das Bild wirklich von der Aufgabe entfernt werden soll
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Wirklich?" message:@"Möchten Sie dieses Bild wirklich von der Aufgabe löschen?" preferredStyle:UIAlertControllerStyleActionSheet];
    
                                          
    [alertController addAction:[UIAlertAction actionWithTitle:@"abbrechen" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"löschen" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        //hier die Befehel hereinschreiben, die das MediaFile löschen sollen
        //das aktuelle MediaFile aus dem Array mit den aktuellen MediaFiles löschen
        [self.mediaFiles removeObject:self.currentMediaFile];
        
        //das MediaFile was gelöscht werden soll an den mediaFilesToDelete-Array anhängen
        [self.mediaFilesToDelete addObject:self.currentMediaFile];
    
        
        //die Daten vom CollectionView im parentEditViewController neuladen
        [self.parentEditViewController.collectionView reloadData];
        
        //überprüfen, ob danach noch Objekte in dem MediaFiles-Array vorhanden sind, ansonsten den ViewController ausblenden
        if (self.mediaFiles.count > 0) {
            //dann entferne nur die aktuelle Seite vom ViewController und gehe zur vorherigen (sekundär zur vorherigen) bzw. primär zur nachfolgenden
            
            //die Richtung, in die ein Löschen von einem Bild sozusagen animiert werden soll: Wenn ein neuer ViewController im PageViewController gesetzt wird, dann kann das ganze animiert werden, indem der PageViewController sich zum nächsten ViewController in eine Richtung bewegt. Diese Richtung soll mit dieser Variable angegeben werden
            NSInteger navigationDirection;
            
            
            //Die folgende if-Verzweigung sollte funktionieren, weil der Fall vom aktuellen Index = 0 und mediaFiles.count ==1 dadurch ausgeschlossen sein sollte, dass sich nach dem Löschen noch mindestens ein Objekt im MediaFiles-array befinden sollte, weil die vorherige if-Verzweigung das bereits überprüft hat. Wenn das nicht der Fall gewesen sein sollte, dann würde in diesem Fall das Programm zum else springen und ein negativer Index würde erzeugt werden, der bekanntlichermaßen ungültig ist.
            
            //dazu zuerst noch den Index vom aktuellen MediaFile aktualisieren
            if (self.currentMediaFileIndex+1 < self.mediaFiles.count) {
                //dann zum nächsten gehen
                self.currentMediaFileIndex += 1;
                
                navigationDirection = UIPageViewControllerNavigationDirectionForward;
            }
            else {
                //wenn nur noch ein MediaFile vorhanden ist, ist der Index logischerweise 0
                if (self.mediaFiles.count == 1) {
                    //im Fall von nur zwei Elementen noch einmal unterscheiden, um die richtige Animationsrichtung herauszufinden
                    if (self.currentMediaFileIndex == 1) {
                        //wenn also das zweite von den beiden vorher noch vorhandenen Elementen gelöscht wurde dann...
                        navigationDirection = UIPageViewControllerNavigationDirectionReverse;
                    }
                    else {
                        //ansonsten...
                        navigationDirection = UIPageViewControllerNavigationDirectionForward;
                    }
                    //den neuen Index aber in beiden Fällen auf 0 setzen, weil ja nur noch ein Objekt vorhanden ist.
                    self.currentMediaFileIndex = 0;
                }
                else {
                    //ansonsten zum vorherigen gehen
                    self.currentMediaFileIndex -= 1;
                    navigationDirection = UIPageViewControllerNavigationDirectionReverse;
                }
            }
            
            //danach anhand des neuen Index auch die currentMediaFile-Variable aktualisieren
            self.currentMediaFile = [self.mediaFiles objectAtIndex:self.currentMediaFileIndex];
            
            PhotoViewController *photoPage = [[PhotoViewController alloc]initWithPhotoMediaFile:self.currentMediaFile];
            photoPage.index = self.currentMediaFileIndex;
            
            [self.pageViewController setViewControllers:@[photoPage] direction:navigationDirection animated:YES completion:nil];
        }
        else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (IBAction)actionButtonClicked:(id)sender {
    
    //einen UIActivityViewController anzeigen
    
    //dafür die Daten, die geteilt werden sollen, in einen Array packen
    NSArray *shareDataArray = @[[self.currentMediaFile getMediaData]];
    
    //den ActivityViewController erstellen...
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]initWithActivityItems:shareDataArray applicationActivities:nil];
    
    //...und anzeigen
    [self presentViewController:activityViewController animated:YES completion:nil];
    
}

- (IBAction)hideNavBarAndToolbar:(id)sender {
    
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
    
    [self.navigationController setToolbarHidden:!self.navigationController.toolbarHidden animated:YES];
    
}

@end
