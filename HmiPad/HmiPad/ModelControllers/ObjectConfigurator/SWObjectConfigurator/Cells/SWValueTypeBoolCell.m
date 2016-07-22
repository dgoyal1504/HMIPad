//
//  SWValueTypeBoolCell.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/8/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWValueTypeBoolCell.h"

NSString * const SWValueTypeBoolCellIdentifier = @"ValueTypeBoolCellIdentifier";
NSString * const SWValueTypeBoolCellNibName = @"SWValueTypeBoolCell";

@implementation SWValueTypeBoolCell
@synthesize switchView = _switchView;

- (void)refreshValue
{
    [super refreshValue];
    
    _switchView.on = self.value.valueAsBool;
    
    //NSLog(@"Number Value: %f",self.value.valueAsDouble);
    
    //NSLog(@"Refresh Value 2: %@", STRBOOL(self.value.valueAsBool));
}

- (IBAction)switchValueAction
{
    // Commiting changes to the value
    [self.value setValueAsDouble:(double)_switchView.on];
}

@end
