//
//  SWKnobItemController.h
//  HmiPad
//
//  Created by Lluch Joan on 27/06/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWControlItemController.h"

@class SWKnobControl ;

@interface SWKnobItemController : SWControlItemController


@property (strong, nonatomic) SWKnobControl *knobControl;

//- (IBAction)knobValueChanged:(id)sender;

@end
