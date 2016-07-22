//
//  SWSegmentedControlItem.h
//  HmiPad
//
//  Created by Joan on 05/25/13.
//  Copyright (c) 2013 SweetWilliam SL. All rights reserved.
//

#import "SWControlItem.h"

@interface SWSegmentedControlItem : SWControlItem

//@property (nonatomic, readonly) SWValue *buttonStyle;
@property (nonatomic, readonly) SWExpression *value;
@property (nonatomic, readonly) SWExpression *array;
@property (nonatomic, readonly) SWExpression *format;

@property (nonatomic, readonly) SWExpression *color;
@property (nonatomic, readonly) SWExpression *active;

@property (nonatomic, readonly) SWExpression *linkToPages;

@end
