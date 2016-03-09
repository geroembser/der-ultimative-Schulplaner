//
//  MitteilungViewController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 08.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "MitteilungViewController.h"

@interface MitteilungViewController ()

@end

@implementation MitteilungViewController


#pragma mark - Initialisierung
- (instancetype)init {
    //initialisiere den ViewController mit einer Vorgabe aus dem Storyboard
    self = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"mitteilungViewController"];
    
    if (self) {
        //advanced setup
    }
    else {
        self = [super init];
    }
    
    return self;
    
}
- (instancetype)initWithMitteilung:(Mitteilung *)mitteilung {
    //der Aufruf dieser Methode initialisiert den Controller mit dem im Storyboard konfigurierten ViewController
    self = [self init];
    
    if (self) {
        //weiteres Setup des Objekts...
        
        //...der Mitteilungs-Instanzvariable die gegebene Mitteilung zuweisen
        self.mitteilung = mitteilung;
    }
    
    return self;
}


#pragma mark - View-Setup
- (void)viewDidLoad {
    //Aufruf der entsprechenden Methode der Superklasse
    [super viewDidLoad];
    
    //beim View-setup hier in der viewDidLoad-Methode die Anzeige der Mitteilung auf dem user interface konfigurieren
    //...den Titel darstellen, falls einer vorhanden sein sollte
    if (self.mitteilung.titel && self.mitteilung.titel.length > 0) {
        self.titelLabel.text = self.mitteilung.titel;
    }
    else {
        //ansonsten anzeigen, dass kein Titel vorhanden ist
        self.titelLabel.text = @"Kein Titel";
    }
        
    //... die Nachricht darstellen, falls eine vorhanden sein sollte
    if (self.mitteilung.nachricht && self.mitteilung.titel.length > 0) {
        self.nachrichtTextView.selectable = YES; //vorher auf YES setzen...
        self.nachrichtTextView.text = self.mitteilung.nachricht;
        self.nachrichtTextView.selectable = NO; //...nachher auf NO setzen, weil sonst - warum auch immer - bei jedem neuen Setzen von Text in den TextView, das Textformat resettet wird.
    }
    else {
        //Einen Fehler-Text anzeigen
        self.nachrichtTextView.text = @"Keine Details zu dieser Mitteilung verfügbar!";
    }
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

#pragma mark - IB-Action

- (IBAction)schliesseMitteilungsDetails:(id)sender {
    //den ViewController ausblenden
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
