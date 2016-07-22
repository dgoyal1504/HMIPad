//
//  SWScaleItem.h
//  HmiPad
//
//  Created by Lluch Joan on 23/05/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWItem.h"

@interface SWScaleItem : SWItem
{
}

@property (nonatomic,readonly) SWExpression *minValue ;
@property (nonatomic,readonly) SWExpression *maxValue ;

@property (nonatomic,readonly) SWExpression *majorTickInterval ;
@property (nonatomic,readonly) SWExpression *minorTicksPerInterval ;
@property (nonatomic,readonly) SWExpression *format ;

@property (nonatomic,readonly) SWValue *orientation;

@end
