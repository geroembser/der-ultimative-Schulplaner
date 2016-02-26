//
//  Aufgabe.h
//  Hausaufgabenheft
//
//  Created by Gero Embser on 18.11.15.
//  Copyright © 2015 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MediaFile.h"

@class Kurs;
@class User;

NS_ASSUME_NONNULL_BEGIN

///Die Priorität einer Aufgabe
typedef enum {
    aufgabePrioritaetUnwichtig = 0,
    aufgabePrioritaetWichtig = 1,
    aufgabePrioritaetExistenziell = 2
} AufgabenPrioritaet;

@interface Aufgabe : NSManagedObject


///erstellt eine neue Aufgabe für den gegebenen Benutzer mit einem gegebenen Titel oder einer gegebenen Beschreibung oder mit beidem
+ (Aufgabe *)neueAufgabeFuerBenutzer:(User *)user mitTitel:(NSString *)titel undBeschreibung:(NSString *)beschreibung;


///setzt das Datum der letzten Änderung der Aufgabe auf das aktuelle Datum
- (void)speichereAenderungsdatum;

///sichert die Aufgabe bzw. die Änderungen an der Aufgabe, indem der ManagedObjectContext gespeichert wird
- (void)sichern;

///löscht die Aufgabe und speichert den Managed Object Context
- (void)loeschen;

///setzt die Erinnerung auf erledigt oder nicht
- (void)setzeErledigt:(BOOL)erledigt;


///Fügt der Aufgabe eine neue Mediendatei mit dem gegebenen Medien Datei Typ und der gegebenen Dateierweiterung hinzu
- (MediaFile *)addMediaFileWithData:(NSData *)mediaData andMediaFileType:(MediaFileType)fileType andFileExtension:(NSString *)fileExtension;

///gibt den Pfad zu dem Ordner zurück, der alle Ordner für Mediendateien für alle Aufgaben enthält (wenn ein solcher noch nicht existiert, dann erstelle ihn neue
- (NSString *)mediaContainerPath;

///Gibt den Ordner zurück, indem die Medien-Dateien für diese Aufgabe liegen bzw. liegen sollen. Wenn noch kein Pfad festgelegt wurde, erstellt diese Methode einen neuen Ordner
- (NSString *)completeMediaFilesPath;


@end

NS_ASSUME_NONNULL_END

#import "Aufgabe+CoreDataProperties.h"
