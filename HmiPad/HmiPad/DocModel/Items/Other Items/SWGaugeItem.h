//
//  SWGaugeItem.h
//  HmiPad
//
//  Created by Lluch Joan on 01/06/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWItem.h"

@interface SWGaugeItem : SWItem

@property (nonatomic,readonly) SWValue *style;
@property (nonatomic,readonly) SWExpression *options;

@property (nonatomic,readonly) SWExpression *value ;
@property (nonatomic,readonly) SWExpression *minValue ;
@property (nonatomic,readonly) SWExpression *maxValue ;

@property (nonatomic,readonly) SWExpression *majorTickInterval ;
@property (nonatomic,readonly) SWExpression *minorTicksPerInterval ;
@property (nonatomic,readonly) SWExpression *format ;
@property (nonatomic,readonly) SWExpression *label ;

@property (nonatomic,readonly) SWExpression *tintColor ;
@property (nonatomic,readonly) SWExpression *needleColor ;
@property (nonatomic,readonly) SWExpression *borderColor ;

@property (nonatomic,readonly) SWExpression *ranges ;
@property (nonatomic,readonly) SWExpression *rangeColors ;

@end
