//
//  UIView+Scale.m
//  HmiPad
//
//  Created by Joan on 11/10/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>

#import "UIView+Scale.h"

@implementation UIView (Scale)

- (void)setScaledFrameV:(CGRect)scaledRect originalSize:(CGSize)originalSize
{
    CGFloat scaleX = scaledRect.size.width / originalSize.width;
    CGFloat scaleY = scaledRect.size.height / originalSize.height;
    
    CGPoint position;
    position.x = scaledRect.origin.x + scaledRect.size.width/2;
    position.y = scaledRect.origin.y + scaledRect.size.height/2;
    
    CALayer *layer = self.layer;
    CATransform3D scaleTransform = CATransform3DMakeScale(scaleX, scaleY, 1.0f);
    [layer setTransform:scaleTransform];
    [layer setPosition:position];
    [layer setBounds:CGRectMake(0, 0, originalSize.width, originalSize.height)];
    
//    NSLog( @"View Bounds %@", NSStringFromCGRect(self.bounds));
//    NSLog( @"Layer Bounds %@", NSStringFromCGRect(layer.bounds));
//    NSLog( @"View Frame: %@", NSStringFromCGRect(self.frame));
//    NSLog( @"Layer Frame: %@", NSStringFromCGRect(layer.frame));
}



- (void)setScaledFrame:(CGRect)scaledRect
{

//    NSLog( @"View Bounds %@", NSStringFromCGRect(self.bounds));
    CGSize originalSize = self.bounds.size;
    CGFloat scaleX = scaledRect.size.width / originalSize.width;
    CGFloat scaleY = scaledRect.size.height / originalSize.height;
    
    CGPoint position;
    position.x = scaledRect.origin.x + scaledRect.size.width/2;
    position.y = scaledRect.origin.y + scaledRect.size.height/2;
    
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scaleX, scaleY);
    [self setTransform:scaleTransform];
    [self setCenter:position];
    
    //[self setFrame:scaledRect];   <- aixo tambe va pero posiblement falla si hi ha rotacions
    
    //[self setBounds:CGRectMake(0, 0, originalSize.width, originalSize.height)];
    
//    NSLog( @"View Bounds %@", NSStringFromCGRect(self.bounds));
//    //NSLog( @"Layer Bounds %@", NSStringFromCGRect(layer.bounds));
//    NSLog( @"View Frame: %@", NSStringFromCGRect(self.frame));
    //NSLog( @"Layer Frame: %@", NSStringFromCGRect(layer.frame));
}







- (CGRect)unscaledFrame
{
    CALayer *layer = self.layer;
    CGSize originalSize = layer.bounds.size;
    CGPoint position = layer.position;
    CGRect rect;
    rect.size = originalSize;
    rect.origin.x = position.x - originalSize.width/2;
    rect.origin.y = position.y - originalSize.height/2;
    return rect;
}


@end
