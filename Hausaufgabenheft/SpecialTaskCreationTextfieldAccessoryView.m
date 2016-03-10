//
//  SpecialTaskCreationTextfieldAccessoryView.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 09.03.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "SpecialTaskCreationTextfieldAccessoryView.h"

@implementation SpecialTaskCreationTextfieldAccessoryView

#pragma mark - Initialisierung
- (instancetype)init {
    
    //aus dem Nib-File den View nehmen
    self = [[[NSBundle mainBundle] loadNibNamed:@"SpecialTaskCreationTextfieldAccessoryView" owner:self options:nil]firstObject];
    
    return self;
}


#pragma mark - View Setup
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
