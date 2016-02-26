//
//  MediaFilesDetailViewController.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 30.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaFile.h"
#import "AufgabeEditViewController.h"

@class PhotoViewController;

@interface MediaFilesDetailViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIPageViewControllerDelegate>

#pragma mark - Initialisierung
///gibt einen neuen ViewController zur Anzeige der MediaFiles zurück und startet die Anzeige bei dem MediaFile am gegebenen Index; zusätzlich kann ein mediaFilesToDelete-array übergeben werden, an den die MediaFiles angehängt werden, die gelöscht werden sollen, sodass der AufgabenEditViewController die Files löscht und entsprechend anzeigt.
- (instancetype)initWithMediaFiles:(NSMutableArray <MediaFile *> *)mediaFiles startingWithFileAtIndex:(NSUInteger)startIndex andPointerToArrayOfMediaFilesToDelete:(NSMutableArray <MediaFile *> *)mediaFilesToDelete;


#pragma mark - Methoden



#pragma mark - Properties;

///der parentEditViewController, der dazu benutzt werden kann, Einstellungen etc. zu setzten oder zu beziehen, die sich auf den MediaFilesDetailView beziehen
@property AufgabeEditViewController *parentEditViewController;

///der Array von MediaFiles, die durch diesen ViewController verwaltet werden
@property NSMutableArray *mediaFiles;

//der Pointer zu dem Array, der die MediaFiles enthalten soll, die gelöscht werden sollen
@property NSMutableArray *mediaFilesToDelete;

///das aktuell angezeigte MediaFile
@property MediaFile *currentMediaFile;

///der Index vom aktuell angezeigten MediaFile
@property NSUInteger currentMediaFileIndex;

///der PageViewController, der die MediaFiles anzeigen soll und in einem ContainerView liegt
@property UIPageViewController *pageViewController;


///gibt den Start-View-Controller für den PageViewController zurück, der nicht direkt durch diese Klasse verwaltet wird
- (PhotoViewController *)startViewController;


#pragma mark - Outlets/Actions

#pragma mark - Outlets/Actions (Top-/Bottom-Bar)

@property (weak, nonatomic) IBOutlet UIBarButtonItem *fertigButton;
- (IBAction)fertigButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashButton;
- (IBAction)trashButtonClicked:(id)sender;
///soll ein entsprechendes Interface anzeigen, welches dem Benutzer die Möglichkeit gibt, beispielsweise ein Bild zu speichern oder per WhatsApp zu verschicken
- (IBAction)actionButtonClicked:(id)sender;

///blendet navigationBar und toolbar animiert us
- (IBAction)hideNavBarAndToolbar:(id)sender;


@end
