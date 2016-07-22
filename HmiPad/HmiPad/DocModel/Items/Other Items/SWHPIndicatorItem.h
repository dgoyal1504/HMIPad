//
//  SWHPIndicatorItem.h
//  HmiPad
//
//  Created by Joan Lluch on 6/23/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWItem.h"

@interface SWHPIndicatorItem : SWItem

@property (nonatomic,readonly) SWValue *direction;

@property (nonatomic,readonly) SWExpression *value;
@property (nonatomic,readonly) SWExpression *minValue;
@property (nonatomic,readonly) SWExpression *maxValue;

@property (nonatomic,readonly) SWExpression *format;

@property (nonatomic,readonly) SWExpression *tintColor ;
@property (nonatomic,readonly) SWExpression *needleColor ;
@property (nonatomic,readonly) SWExpression *borderColor ;

@property (nonatomic,readonly) SWExpression *ranges ;
@property (nonatomic,readonly) SWExpression *rangeColors ;

@end
