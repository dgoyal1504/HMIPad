//
//  UIView+ColorOfPoint.h
//  HmiPad
//
//  Created by Joan Martin on 7/31/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ColorOfPoint)

- (UIColor *)colorOfPoint:(CGPoint)point;
- (CGFloat)alphaAtPoint:(CGPoint)point;

@end
