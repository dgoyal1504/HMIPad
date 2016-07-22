//
//  SWArrayPickerItem.h
//  HmiPad
//
//  Created by Joan on 05/25/13.
//  Copyright (c) 2013 SweetWilliam SL. All rights reserved.
//

#import "SWControlItem.h"

@interface SWArrayPickerItem : SWControlItem

//@property (nonatomic, readonly) SWValue *buttonStyle;
//@property (nonatomic, readonly) SWExpression *value;
@property (nonatomic, readonly) SWValue *element;
@property (nonatomic, readonly) SWExpression *index;
@property (nonatomic, readonly) SWExpression *array;
@property (nonatomic, readonly) SWExpression *format;

@property (nonatomic, readonly) SWExpression *color;
@property (nonatomic, readonly) SWValue *textAlignment;
@property (nonatomic, readonly) SWValue *verticalTextAlignment;
@property (nonatomic, readonly) SWExpression *font;
@property (nonatomic, readonly) SWExpression *fontSize;

@property (nonatomic, readonly) SWExpression *active;
@property (nonatomic, readonly) SWExpression *linkToPages;

@end
