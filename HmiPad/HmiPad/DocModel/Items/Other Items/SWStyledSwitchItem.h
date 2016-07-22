//
//  SWStyledSwitchItem.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/16/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWSwitchItem.h"

@interface SWStyledSwitchItem : SWSwitchItem

@property (nonatomic, readonly, strong) SWValue *switchStyle;
@property (nonatomic, readonly, strong) SWExpression *color;

@property (nonatomic, readonly) SWExpression *active;

@end
