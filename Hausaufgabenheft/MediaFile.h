//
//  MediaFile.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 01.01.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Aufgabe;

NS_ASSUME_NONNULL_BEGIN

///Der Medientyp eines Aufgaben Medien File Objekts
typedef enum {
    mediaFileTypeImage = 0,
    mediaFileTypeVideo = 1,
    mediaFileTypeAudio = 2
} MediaFileType;

@interface MediaFile : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

#pragma mark - Instanzen erstellen
///erstellt eine neue Medien Datei, die mit der gegebenen Aufgabe verbunden wird
+ (MediaFile *)newMediaFileForAufgabe:(Aufgabe *)aufgabe;

///erstellt ein MediaFile, dass soweit konfiguriert werden kann, nur dass die eigentlichen Media-Daten temporär im Speicher (also in einer Variable) gehalten werden
+ (MediaFile *)tempMediaFileWithData:(NSData *)tempData inManagedObjectContext:(NSManagedObjectContext *)context;


#pragma mark - Instanzen löschen
///löscht das Mediendatei-Objekt aus Core-Data und auch die damit verbundene Mediendatei, der übergebene Boolean gibt an, ob der ManagedObjectContext direkt gespeichert werden soll oder nicht
- (void)loeschenWithContextSave:(BOOL)save;


#pragma mark - Data Handling
///speichert die gegebenen Daten an einem bestimmten Ort im Dateisystem mit der gegebenen Endung und speichert den Ort im Dateisystem, an dem eben diese Datei erstellt wurde, in CoreData
- (void)setMediaData:(NSData *)mediaData withFileExtension:(NSString *)fileExtension;

///gibt die Daten für die Mediendatei zurück
- (NSData *)getMediaData;

///gibt den kompletten Pfad einer Mediendatei zurück (also nicht relativ sondern den wirklich absoluten Pfad zu der Datei);
- (NSString *)completePath;


#pragma mark - Temporäre Mediendateien
///gibt an, dass das Media-File temporär ist
@property BOOL temporary;

///speichert die bisher temporären Daten jetzt
- (void)saveTempData;

//Im folgenden Variablen, die Daten für die temporären Dateien halten

///die temporären Medien Daten
@property (nullable) NSData *tempMediaData;

///die FileExtension für die temporäre Datei
@property (nullable) NSString *tempMediaDataFileExtension;

@end

NS_ASSUME_NONNULL_END

#import "MediaFile+CoreDataProperties.h"
