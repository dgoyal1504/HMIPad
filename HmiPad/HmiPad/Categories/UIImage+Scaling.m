//
//  UIImage+Scaling.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/30/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "UIImage+Scaling.h"

@implementation UIImage (Scaling)

- (UIImage*)scaleToSize:(CGSize)size 
{
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), self.CGImage);
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

@end
