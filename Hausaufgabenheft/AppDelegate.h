//
//  AppDelegate.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 22.10.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class MainTabBarController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

///der Haupt-Tab-Bar-Controller der Application
@property MainTabBarController *mainTabBarController;

/* Core data */
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

///gibt den Standard/Haupt managedObjectContext zurück
+ (NSManagedObjectContext *)defaultManagedObjectContext;


/* other Application Interface Stuff */
///zeigt das Standard-Haupt-user-interface an, das der normale Ausgangspunkt für die meisten Funktionen der App ist
- (void)showMainInterface;

///zeigt das Intro mit dem Login und dr Konfiguration der App an
- (void)showIntro;

///zeigt einen login ViewController an, mit dem man sich bei der App anmelden kann, wenn seine Zugangsdaten abgelaufen sind, oder man sich abgemeldet hat
- (void)showLoginViewController;

@end

