//
//  SWCustomSwitchItem.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/5/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWSwitchItem.h"

@interface SWCustomSwitchItem : SWSwitchItem

@property (nonatomic, readonly, strong) SWValue *aspectRatioForStateOn;
@property (nonatomic, readonly, strong) SWValue *aspectRatioForStateOff;
@property (nonatomic, readonly, strong) SWExpression *imagePathForStateOn;
@property (nonatomic, readonly, strong) SWExpression *imagePathForStateOff;
@property (nonatomic, readonly, strong) SWExpression *tintColorForStateOn;
@property (nonatomic, readonly, strong) SWExpression *tintColorForStateOff;

@end
