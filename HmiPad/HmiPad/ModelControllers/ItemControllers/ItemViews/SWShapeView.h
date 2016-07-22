//
//  SWShapeView.h
//  HmiPad
//
//  Created by Lluch Joan on 09/07/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWEnumTypes.h"

@interface SWShapeView : UIView


// general propertyes
@property (nonatomic, assign) SWBooleanChoice animated;             // yes, no

// fill properties
@property (nonatomic, assign) SWFillStyle fillStyle;             // solid, gradient, image
@property (nonatomic, assign) SWDirection gradientDirection;     // up, down, right, left,
@property (nonatomic, strong) UIColor *fillColor1;
@property (nonatomic, strong) UIColor *fillColor2;
@property (nonatomic, strong) UIImage *fillImage;
@property (nonatomic, assign) SWImageAspectRatio aspectRatio;

// stroke properties
@property (nonatomic, assign) SWStrokeStyle strokeStyle;           // line, dash, 
@property (nonatomic, assign) double cornerRadius;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, assign) double lineWidth;

// grid properties
@property (nonatomic, assign) NSInteger gridColumns;
@property (nonatomic, assign) NSInteger gridRows;

// shadow properties
@property (nonatomic, assign) SWShadowStyle shadowStyle;
@property (nonatomic, assign) double shadowOffset;
@property (nonatomic, assign) double shadowBlur;
//@property (nonatomic, assign) double shadowOpacity;  
@property (nonatomic, strong) UIColor *shadowColor;

// layer properties
@property (nonatomic, readonly) double layerOpacity;
@property (nonatomic, assign) BOOL blink;

- (void)setLayerOpacity:(double)value animated:(BOOL)animated;


- (void)setContentMode:(UIViewContentMode)contentMode;

- (void)setOriginalImage:(UIImage*)image;
- (void)setResizedImage:(UIImage*)image;

@end
