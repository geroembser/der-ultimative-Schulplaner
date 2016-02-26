//
//  Aufgabe.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 18.11.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "Aufgabe.h"
#import "User.h"
#import "Kurs.h"
#import <UIKit/UIKit.h>

@implementation Aufgabe

#pragma mark - eine neue Aufgabe erstellen
+ (Aufgabe *)neueAufgabeFuerBenutzer:(User *)user mitTitel:(NSString *)titel undBeschreibung:(NSString *)beschreibung {
    
    //Eine neue Instanz in CoreData erstellen
     NSManagedObjectContext *context = user.managedObjectContext;
    Aufgabe *newAufgabe = [NSEntityDescription
                                           insertNewObjectForEntityForName:@"Aufgabe"
                                           inManagedObjectContext:context];
    
    
    //das hinzugefügt am Datum ändern
    newAufgabe.erstelltAm = [NSDate date];
    
    //der Benutzer, der die Aufgabe erstellt hat bzw. dem die Aufgabe "gehört" (für den also die Aufgabe ist)
    newAufgabe.user = user;
    
    //der Titel der Aufgabe
    newAufgabe.titel = titel;
    
    //die Beschreibung der Aufgabe
    newAufgabe.beschreibung = beschreibung;
    
    //sagt, dass die Aufgabe keinem Fach zugeordnet ist
    newAufgabe.keinemFachZugeordnet = [NSNumber numberWithBool:YES];
    
    //wichtig ist die normale Aufgaben-Priorität;
    newAufgabe.prioritaet = [NSNumber numberWithInt:aufgabePrioritaetWichtig];
    
    
    return newAufgabe;
}

#pragma mark - Eigenschaften der Aufgabe bearbeiten

- (void)speichereAenderungsdatum {
    //einfach nur das aktuelle Datum in die zuletztAktualisiert Spalte des aktuellen Objekts/Core-Data-Datenbank-Objekt eintragen
    self.zuletztAktualisiert = [NSDate date];
}

- (void)setzeErledigt:(BOOL)erledigt {
    if (erledigt) {
        self.erledigt = [NSNumber numberWithBool:YES];
        
        //wenn die Aufgabe erledigt ist, lösche ebenfalls die Local Notification
        [self loescheLocalNotificationForAufgabe];
    }
    else {
        self.erledigt = [NSNumber numberWithBool:NO];
        
        //wenn die Aufgabe wieder als noch ausstehend markiert wurde, erstelle eine neue Benachrichtigung
        if (self.erinnerungDate) {
            //erstelle eine neue Lokale Benachrichtigung
            UILocalNotification *localNotification = [self localNotificationForCurrentObjectWithFireDate:self.erinnerungDate];
            
            //die Benachrichtigung "registrieren";
            [[UIApplication sharedApplication]scheduleLocalNotification:localNotification];
        }
        
    }
}

#pragma mark - Local Notifications
///gibt eine UILocalNotificaton zurück, mit dem gegebenen fireDate und konfiguriert sie mit den Daten des aktuellen Objekts
- (UILocalNotification *)localNotificationForCurrentObjectWithFireDate:(NSDate *)fireDate {
    if (fireDate) {
        UILocalNotification *localNotification = [[UILocalNotification alloc]init];
        localNotification.fireDate = fireDate;
        localNotification.alertBody = [NSString stringWithFormat:@"Denke an deine Aufgabe: %@", (self.titel ? self.titel : self.beschreibung)];
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.userInfo = @{@"uid":self.objectID.URIRepresentation.absoluteString}; //speichere in der userInfo-Dict die Objekt-ID von Core-Data ab;
        
        return localNotification;
    }
    
    return nil;
}
///löscht die LocalNotification für die Aufgabe (self)
- (void)loescheLocalNotificationForAufgabe {
    UIApplication *app = [UIApplication sharedApplication];
    
    NSArray *events = [app scheduledLocalNotifications];
    
    NSString *uid = self.objectID.URIRepresentation.absoluteString; //die UniqueID von diesem Objekt
    
    for (UILocalNotification *localNotification in events) {
        NSDictionary *userInfo = localNotification.userInfo;
        NSString *localNotificationUID = [userInfo objectForKey:@"uid"];
        
        if ([localNotificationUID isEqualToString:uid]) {
            //dann lösche die Benachrichtigung
            [app cancelLocalNotification:localNotification];
            break;
        }
    }
}


#pragma mark - Sichern
- (void)sichern {
    //hier die LocalNotifications erstellen bzw. vorher alte löschen
    
    //lösche die eventuell vorhandene lokale Benachrichtigung
    [self loescheLocalNotificationForAufgabe];
    
    
    //wenn ein Erinnerungs-Datum gegeben ist und die Aufgabe noch nicht erledigt ist, erstelle eine neue Benachrichtigung
    if (self.erinnerungDate && !self.erledigt.boolValue) {
        //erstelle eine neue Lokale Benachrichtigung
        UILocalNotification *localNotification = [self localNotificationForCurrentObjectWithFireDate:self.erinnerungDate];
        
        //die Benachrichtigung "registrieren";
        [[UIApplication sharedApplication]scheduleLocalNotification:localNotification];
    }
    
    //dann den ManagedObjectContext sichern
    
    NSError *savingError;
    [self.managedObjectContext save:&savingError];
    
    if (savingError) {
        NSLog(@"Fehler: Die Aufgabe (%@) konnte nicht gespeichert werden! Die Beschreibung des aufgetretenen Fehlers: %@", self, savingError.localizedDescription);
    }
}

#pragma mark - Löschen
- (void)loeschen {
    //die eventuell vorhandene lokale Benachrichtigung löschen
    [self loescheLocalNotificationForAufgabe];
    
    //lösche alle Dateien in dem Pfad, der alle Medien-Dateien für die Aufgabe enthält
    if (self.mediaFilesPath.length > 0) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSError *deletingError;
        [fileManager removeItemAtPath:[self completeMediaFilesPath] error:&deletingError];
        
        if (deletingError) {
            NSLog(@"Fehler beim löschen der Mediendateien für die Aufgab: %@", self);
        }
        
    }
    
    [self.managedObjectContext deleteObject:self];
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Fehler beim Löschen einer Aufgabe!");
    }
}

#pragma mark - MediaFiles
//eine Mediendatei hinzufügen
- (MediaFile *)addMediaFileWithData:(NSData *)mediaData andMediaFileType:(MediaFileType)fileType andFileExtension:(nonnull NSString *)fileExtension{
    MediaFile *newMediaFile = [MediaFile newMediaFileForAufgabe:self];
    newMediaFile.typ = [NSNumber numberWithInt:fileType];
    [newMediaFile setMediaData:mediaData withFileExtension:fileExtension];
    
    return newMediaFile;
}


///gibt den Pfad des Verzeichnisses im Dateisystem der App zurück, in dem Ordner liegt, der alle Mediendateien für diese Aufgabe enthält
- (NSString *)mediaContainerPath {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *aufgabeMediaContainerPath = [documentsDirectory stringByAppendingPathComponent:@"aufgabeMedia"];
    
    //überprüfe, ob der Basis-Pfad existiert, wenn nicht erstelle ihn
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:aufgabeMediaContainerPath]) {
        NSError *directoryCreationError;
        [fileManager createDirectoryAtPath:aufgabeMediaContainerPath withIntermediateDirectories:YES attributes:nil error:&directoryCreationError];
        
        if (directoryCreationError) {
            NSLog(@"Fehler beim Erstellen des Verzeichnisses für die Mediendateien der jeweiligen Aufgaben");
        }
    }
    
    return aufgabeMediaContainerPath;
    
}
///gibt den kompletten Pfad zu dem Verzeichnis zurück, welches alle Mediendateien für diese Aufgabe enthält (mit allen vorherigen Standard-Sachen)
- (NSString *)completeMediaFilesPath {
    //wenn eine mediaFilesPath gegeben ist, dann ist der erste Teil des Pfads der Basis-Pfad
    
    if (self.mediaFilesPath) {
        //wenn ein mediaFilesPath gegeben ist, dann gebe den mediaContainerPath mit dem mediaFilesPath aneinandergehängt zurück
        return [[self mediaContainerPath]stringByAppendingPathComponent:self.mediaFilesPath];
    }
    else {
        //erstelle einen neuen Pfad für die Aufgabe, der noch nicht existiert
        //dafür eine Instanz vom FileManager erzeugen
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        //den Basis-Pfad bekommen, an dem die MedienDateien liegen sollen
        NSString *mediaContainerPath = [self mediaContainerPath];
        
        NSString *completePath;
        
        int dateIntervalInt = (int)[self.erstelltAm timeIntervalSince1970];
        
        completePath = [mediaContainerPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%i", dateIntervalInt]];
        
        int i = 1;
        while ([fileManager fileExistsAtPath:completePath]) {
            completePath = [completePath stringByAppendingFormat:@"%i", i];
            i++;
        }
        
        //den neuen Ordner mit den Media Files erstellen
        NSError *dirCreationError;
        [fileManager createDirectoryAtPath:completePath withIntermediateDirectories:YES attributes:nil error:&dirCreationError];
        
        if (dirCreationError) {
            NSLog(@"Fehler beim Erstellen des Verzeichnisses für die Mediendateien für die Aufgabe: %@", self);
        }
        
        //den letzten Teil des kompletten Pfads (also den Ordnernamen) als mediaFilesPath festlegen
        self.mediaFilesPath = completePath.lastPathComponent;
        return completePath;
    }
    
}
@end
