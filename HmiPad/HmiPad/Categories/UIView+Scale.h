//
//  UIView+Scale.h
//  HmiPad
//
//  Created by Joan on 11/10/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Scale)

- (void)setScaledFrame:(CGRect)scaledRect;
- (CGRect)unscaledFrame;

@end
