//
//  SWEnableSourceCell.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/20/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWSourceItemCell.h"
#import "SWDocumentModel.h"

@interface SWEnableSourceCell : SWSourceItemCell<DocumentModelObserver>

- (IBAction)switchChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UISwitch *enableSourceSwitch;

@end