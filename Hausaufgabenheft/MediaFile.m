//
//  MediaFile.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 01.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "MediaFile.h"
#import "Aufgabe.h"

@implementation MediaFile

@synthesize temporary, tempMediaDataFileExtension, tempMediaData;

// Insert code here to add functionality to your managed object subclass

#pragma mark - Neue MediaFiles erzeugen
+ (MediaFile *)newMediaFileForAufgabe:(Aufgabe *)aufgabe {
    if (!aufgabe) {
        return nil;
    }
    
    NSManagedObjectContext *context = aufgabe.managedObjectContext;
    MediaFile *newMediaFile = [NSEntityDescription
                                           insertNewObjectForEntityForName:@"MediaFile"
                                           inManagedObjectContext:context];
    
    newMediaFile.aufgabe = aufgabe;
    
    return newMediaFile;
}

+ (MediaFile *)tempMediaFileWithData:(NSData *)tempData inManagedObjectContext:(nonnull NSManagedObjectContext *)context{
    if (context) {
        MediaFile *newMediaFile = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"MediaFile"
                                   inManagedObjectContext:context];
        newMediaFile.temporary = YES;
        newMediaFile.tempMediaData = tempData;
     
        return newMediaFile;
    }
    
    return nil;
}

#pragma mark - Löschen
- (void)loeschenWithContextSave:(BOOL)save {
    
    //lösche die damit verbundene Mediendatei
    if (self.path.length > 0) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSError *deletingError;
        [fileManager removeItemAtPath:self.completePath error:&deletingError];
        
        if (deletingError) {
            NSLog(@"Fehler beim Löschen der Mediendatei die im Pfad %@ liegt!", self.completePath);
        }
    }
    
    NSManagedObject *aManagedObject = self;
    NSManagedObjectContext *context = [aManagedObject managedObjectContext];
    [context deleteObject:aManagedObject];
    NSError *error;
    if (save) {
        if (![context save:&error]) {
            // Handle the error.
            NSLog(@"Das MediaFile (%@) konnte nicht aus CoreData gelöcht werden", self);
        }
    }

}


#pragma mark - Data Handling

- (void)setMediaData:(NSData *)mediaData withFileExtension:(NSString *)fileExtension {
    if (mediaData) {
        //wenn keine FileExtension gegeben ist, nehme die File-Extension ".aufgabeMedia"
        if (!fileExtension) {
            fileExtension = @"aufgabeMedia";
        }
        
        //eine Instanz vom NSFileManager erzeugen
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        //der Pfad zu dem Ordner, an dem die Daten gespeichert werden sollen
        NSString *folderWhereToSave = [self.aufgabe completeMediaFilesPath];
        
        //jetzt den genauen Pfad zu der Datei erstellen (inklusive Namen)
        NSString *completePath = [folderWhereToSave stringByAppendingPathComponent:[NSString stringWithFormat:@"am1.%@", fileExtension]];
        
        //solange eine Datei am completePath existiert, inkrementiere die Zählvariable i und hänge sie an den Pfad dran
        int i = 2;
        while ([fileManager fileExistsAtPath:completePath]) {
            completePath = [folderWhereToSave stringByAppendingPathComponent:[NSString stringWithFormat:@"am%i.%@",i, fileExtension]];
            i++;
        }
        
        
        //speichere die Dateien
        [mediaData writeToFile:completePath atomically:YES];
        
        //nur den Teil des kompletten Pfads speichern, der in Abhängigkeit zum Homeverzeichnis der App steht
        NSArray *pathComponents = completePath.pathComponents;
        NSArray *pathComponentsToSave = @[[pathComponents objectAtIndex:pathComponents.count-3], [pathComponents objectAtIndex:pathComponents.count-2], [pathComponents objectAtIndex:pathComponents.count-1]];
        self.path = [pathComponentsToSave componentsJoinedByString:@"/"];
        

    }
}

- (NSData *)getMediaData {
    if (self.path.length > 0) {
        //bekomme die Daten als NSData Objekt
        NSData *data = [NSData dataWithContentsOfFile:[self completePath]];
        
        return data;
    }
    else if (self.tempMediaData) {
        //wenn also temporäre Medien Daten verfügbar sind, dann gebe diese zurück
        return self.tempMediaData;
    }
    return nil;
}

#pragma mark - Path Handling
- (NSString *)completePath {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:self.path];
}


#pragma mark - temporary MediaFiles
- (void)saveTempData {
    //ruft einfach setMediaData: - Methode mit den temporären MediaDatas auf
    if (self.tempMediaData) {
        //setze das "hinzugefügt am"-Datum
        self.hinzugefuegtAm = [NSDate date];
        
        //sichere die Daten
        [self setMediaData:self.tempMediaData withFileExtension:self.tempMediaDataFileExtension];
        
        //danach die Variablen, die die temporären Daten enthalten "löschen" und den Status des Objekts auf nicht temporär setzen
        self.temporary = NO;
        self.tempMediaDataFileExtension = nil;
        self.tempMediaData = nil;
    }
}
@end
