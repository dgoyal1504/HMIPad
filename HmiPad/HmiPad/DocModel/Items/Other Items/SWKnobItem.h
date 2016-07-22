//
//  SWKnobItem.h
//  HmiPad
//
//  Created by Lluch Joan on 27/06/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWControlItem.h"

@interface SWKnobItem : SWControlItem

@property (nonatomic,readonly) SWValue *style;
@property (nonatomic,readonly) SWValue *thumbStyle;

@property (nonatomic,readonly) SWExpression *value ;
@property (nonatomic,readonly) SWExpression *minValue ;
@property (nonatomic,readonly) SWExpression *maxValue ;

@property (nonatomic,readonly) SWExpression *majorTickInterval ;
@property (nonatomic,readonly) SWExpression *minorTicksPerInterval ;
@property (nonatomic,readonly) SWExpression *format ;
@property (nonatomic,readonly) SWExpression *label ;

@property (nonatomic,readonly) SWExpression *tintColor ;
@property (nonatomic,readonly) SWExpression *thumbColor ;
@property (nonatomic,readonly) SWExpression *borderColor ;


@end
