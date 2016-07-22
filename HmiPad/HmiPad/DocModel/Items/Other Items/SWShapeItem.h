//
//  SWShapeItem.h
//  HmiPad
//
//  Created by Lluch Joan on 09/07/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWItem.h"

@interface SWShapeItem : SWItem


// general propertyes
@property (nonatomic, readonly) SWValue *animated;             // yes, no

// fill properties
@property (nonatomic, readonly) SWValue *fillStyle;             // solid, gradient, image
@property (nonatomic, readonly) SWValue *gradientDirection;     // up, down, right, left,
@property (nonatomic, readonly) SWExpression *fillColor1;
@property (nonatomic, readonly) SWExpression *fillColor2;
@property (nonatomic, readonly) SWExpression *fillImage;
@property (nonatomic, readonly) SWValue *aspectRatioValue;

// stroke properties
@property (nonatomic, readonly) SWValue *strokeStyle;           // line, dash, 
@property (nonatomic, readonly) SWExpression *cornerRadius;
@property (nonatomic, readonly) SWExpression *strokeColor;
@property (nonatomic, readonly) SWExpression *lineWidth;

// grid properties
@property (nonatomic, readonly) SWExpression *gridColumns;
@property (nonatomic, readonly) SWExpression *gridRows;

// shadow properties
@property (nonatomic, readonly) SWValue *shadowStyle;
@property (nonatomic, readonly) SWValue *shadowOffset;
@property (nonatomic, readonly) SWValue *shadowBlur;
@property (nonatomic, readonly) SWExpression *shadowColor;

// layer properties
@property (nonatomic, readonly) SWExpression *opacity;
@property (nonatomic, readonly) SWExpression *blink;

@end
