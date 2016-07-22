//
//  SWStyledSwitchItemController.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/16/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWControlItemController.h"

@class RoundedLabel;
@class ColoredButton;

@interface SWStyledSwitchItemController : SWControlItemController

@property (strong, nonatomic) UISwitch *switchView;
@property (strong, nonatomic) RoundedLabel *labelView;
@property (strong, nonatomic) ColoredButton *buttonView;

//- (IBAction)switchValueChanged:(id)sender;

@end
