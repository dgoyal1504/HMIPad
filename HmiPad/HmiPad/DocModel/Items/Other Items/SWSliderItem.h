//
//  SWSliderItem.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/16/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWControlItem.h"

@interface SWSliderItem : SWControlItem

@property (nonatomic, readonly) SWValue *orientation;
@property (nonatomic, readonly) SWExpression *value;
@property (nonatomic, readonly) SWExpression *color;
@property (nonatomic, readonly) SWExpression *maxValue;
@property (nonatomic, readonly) SWExpression *minValue;
@property (nonatomic, readonly) SWExpression *format;

@end
