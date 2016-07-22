//
//  SWBarLevelItem.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/16/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWItem.h"

@interface SWBarLevelItem : SWItem

@property (nonatomic, readonly) SWValue *direction;

@property (nonatomic, readonly) SWExpression *value;
@property (nonatomic, readonly) SWExpression *barColor;
@property (nonatomic, readonly) SWExpression *tintColor;
@property (nonatomic, readonly) SWExpression *borderColor;
//@property (nonatomic, readonly) SWExpression *color;
@property (nonatomic, readonly) SWExpression *maxValue;
@property (nonatomic, readonly) SWExpression *minValue;
@property (nonatomic, readonly) SWExpression *format;

//- (CGFloat)currentProgress;

@end
