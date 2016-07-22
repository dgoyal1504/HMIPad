//
//  SWFloatingContentOverlayView.h
//  FloatingPopover
//
//  Created by Joan Martín Hernàndez on 6/27/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kShadowBlur          2.0f

@interface SWFloatingContentOverlayView : UIView

@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, strong) UIColor *edgeColor;

//+ (CGFloat)frameWidth;

@end
