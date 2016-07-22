//
//  SWButtonItemController.h
//  HmiPad
//
//  Created by Lluch Joan on 03/07/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWControlItemController.h"


@class RoundedLabel;
@class ColoredButton;

@interface SWButtonItemController : SWControlItemController

@property (strong, nonatomic) ColoredButton *buttonView;
//@property (strong, nonatomic) RoundedLabel *labelView;

@end
