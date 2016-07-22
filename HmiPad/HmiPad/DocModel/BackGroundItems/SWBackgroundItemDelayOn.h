//
//  SWBackgroundItemDelayOn.h
//  HmiPad
//
//  Created by Joan on 26/05/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWBackgroundItem.h"

@interface SWBackgroundItemDelayOn : SWBackgroundItem

@property (nonatomic,readonly) SWValue *delayedValue;
@property (nonatomic,readonly) SWExpression *value;
@property (nonatomic,readonly) SWExpression *time;


@end
