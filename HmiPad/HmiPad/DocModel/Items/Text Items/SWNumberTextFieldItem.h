//
//  SWTextFieldItem.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/12/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWControlTextItem.h"

@interface SWNumberTextFieldItem : SWControlTextItem

//@property (nonatomic, readonly) SWValue *inputType;
@property (nonatomic, readonly) SWValue *style;
@property (nonatomic, readonly) SWValue *secureInput;
@property (nonatomic, readonly) SWExpression *value;
@property (nonatomic, readonly) SWExpression *format;
@property (nonatomic, readonly) SWExpression *minValue;
@property (nonatomic, readonly) SWExpression *maxValue;

@property (nonatomic, assign) BOOL controlIsEditing;
@end