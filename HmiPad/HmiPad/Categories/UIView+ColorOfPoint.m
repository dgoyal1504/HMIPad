//
//  UIView+ColorOfPoint.m
//  HmiPad
//
//  Created by Joan Martin on 7/31/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "UIView+ColorOfPoint.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (ColorOfPoint)

- (UIColor *)colorOfPoint:(CGPoint)point
{
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    
    [self.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    //NSLog(@"pixel: %d %d %d %d", pixel[0], pixel[1], pixel[2], pixel[3]);
    
    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0f green:pixel[1]/255.0f blue:pixel[2]/255.0f alpha:pixel[3]/255.0f];
    
    return color;
}


- (CGFloat)alphaAtPointV:(CGPoint)point
{
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    
    [self.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    CGFloat alpha = pixel[3]/255.0f;
    return alpha;
}



- (CGFloat)alphaAtPoint:(CGPoint)point
{
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    
    UIGraphicsPushContext(context);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];   // faster?
    UIGraphicsPopContext();
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    CGFloat alpha = pixel[3]/255.0f;
    return alpha;
}

@end
