//
//  SWKeyboardKey.m
//  HmiPad
//
//  Created by Hermes Pique on 5/10/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWKeyboardKey.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Resize.h"




//#pragma mark - Helper functions
//
//static CGFloat Scale(void)
//{
//    static CGFloat scale = 0;
//    static dispatch_once_t onceToken;
//    dispatch_once( &onceToken, ^
//    {
//        scale = [[UIScreen mainScreen] scale];
//    });
//    
//    return scale;
//}
//
//
//static UIImage* _imageWithColor_size(UIColor* color, CGSize size)
//{
//    CGFloat scale = Scale();
//    CGRect rect = CGRectMake(0.0f, 0.0f, scale*size.width, scale*size.height);
//    
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(NULL, rect.size.width, rect.size.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
//    CGColorSpaceRelease(colorSpace);
//    
//    if (context == NULL)
//        return nil;
//    
//    CGContextSetFillColorWithColor(context, [color CGColor]); // <-- Color to fill
//    CGContextFillRect(context, rect);
//    
//    CGImageRef bitmapContext = CGBitmapContextCreateImage(context);
//    CGContextRelease(context);
//    
//    UIImage *theImage = [UIImage imageWithCGImage:bitmapContext scale:scale orientation:UIImageOrientationUp];
//    CGImageRelease(bitmapContext);
//    
//    return theImage;
//}






@implementation SWKeyboardKey

#define ShadowInset 3

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initHelper];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initHelper];
    }
    return self;
}

- (void)initHelper
{
// hpique: Uncomment these lines if you want the layer to handle the shadow. Perfomance was bad so I opted to draw the shadow manually.
//    self.layer.shadowOffset = CGSizeMake(0, 1);
//    self.layer.shadowRadius = 1;
//    self.layer.shadowOpacity = 0.7;
//    self.layer.shadowColor = [UIColor blackColor].CGColor;

    [self adjustFrameForShadow];

    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    if ( IS_IOS7 )
    {
        self.titleLabel.shadowOffset = CGSizeMake(0, 0);
    }
    else
    {
        self.titleLabel.shadowOffset = CGSizeMake(0, 1);
        self.titleLabel.font = [UIFont systemFontOfSize:21];
        [self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    }
    [self setBackgroundColor:[UIColor clearColor]];
    [self setContentMode:UIViewContentModeRedraw];
    
    
//    // set a white transparent higlited state if no image is given
//    UIImage *normalImage = _imageWithColor_size([UIColor colorWithWhite:1 alpha:1], CGSizeMake(1,1));
//    normalImage = [normalImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    [self setImage:normalImage forState:UIControlStateNormal];
//    
//    
//    UIImage *highImage = _imageWithColor_size([UIColor colorWithWhite:1 alpha:0.2], CGSizeMake(1,1));
//    highImage = [highImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    [self setImage:highImage forState:UIControlStateHighlighted];
//    
//    [self.imageView setContentMode:UIViewContentModeScaleToFill];
//    //[self setContentMode:UIViewContentModeScaleToFill];
//    [self setContentVerticalAlignment:UIControlContentVerticalAlignmentFill];
//    [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
}

- (void)adjustFrameForShadow
{
    CGRect frame = self.frame;
    self.frame = CGRectInset(frame, -ShadowInset, -ShadowInset);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // hpique: Uncomment this lines if you want the layer to handle the shadow. See initHelper for more info.
    //    self.layer.shadowPath = [SWKeyboardKey newPathForRoundedRect:self.bounds radius:7];

    const UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
//    const CGFloat fontSize = UIInterfaceOrientationIsLandscape(orientation) ? 26 : 21;
//    const CGFloat altFontSize = UIInterfaceOrientationIsLandscape(orientation) ? 21 : 18;
    
    CGFloat fontSize;
    
    if ( IS_IPHONE )
    {
        if ( self.tag != 0 ) fontSize = UIInterfaceOrientationIsLandscape(orientation) ? 20 : 14;
        else fontSize = UIInterfaceOrientationIsLandscape(orientation) ? 22 : 21;
    }
    else
    {
        if ( self.tag != 0 ) fontSize = UIInterfaceOrientationIsLandscape(orientation) ? 22 : 18;
        else fontSize = UIInterfaceOrientationIsLandscape(orientation) ? 26 : 21;
    }
    // UNHACK - we can not use device orientation because it is based on accelerometer values and is not always consistent with the
    // actual orientation of the interface
    //const UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    //const CGFloat fontSize = UIDeviceOrientationIsLandscape(orientation) ? 26 : 21;
    
    UIFont *currentFont = self.titleLabel.font;
    self.titleLabel.font = [UIFont fontWithName:currentFont.fontName size:fontSize];

 //   [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{

    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    CGFloat radius = IS_IPHONE ? 4 : 7;
    
    if ( IS_IOS7 )
    {
    
        const CGRect innerRect = CGRectInset(rect, ShadowInset, ShadowInset); // jlz: Leave some space for Xib compatibility
        
        CGRect bebelRect = innerRect;
        bebelRect.origin.y++;
        
        CGPathRef borderPath = [SWKeyboardKey newPathForRoundedRect:innerRect radius:radius];
        CGPathRef bebelPath = [SWKeyboardKey newPathForRoundedRect:bebelRect radius:radius];
        
        UIColor *keyColor;
        BOOL tag = (self.tag != 0 );
        BOOL hig = self.highlighted;
        
//        if ( tag && !hig) keyColor = [UIColor colorWithRed:0.73 green:0.745 blue:0.76 alpha:0.5];
//        else if ( !tag && hig ) keyColor = [UIColor colorWithRed:0.83 green:0.84 blue:0.85 alpha:0.5];
//        else keyColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0];
        
        if ( tag && !hig) keyColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.16666];
        else if ( !tag && hig ) keyColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.08333];
        else keyColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0];

        [self drawInnerFillInContext:context borderPath:bebelPath color:[UIColor colorWithWhite:0.5 alpha:1]];
        CGContextSetBlendMode(context, kCGBlendModeCopy);
        [self drawInnerFillInContext:context borderPath:borderPath color:[UIColor clearColor]];
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        [self drawInnerFillInContext:context borderPath:borderPath color:keyColor];
        
//        if ( tag && !hig) keyColor = [UIColor colorWithRed:0.73 green:0.745 blue:0.76 alpha:0.3333];
//        else if ( !tag && hig ) keyColor = [UIColor colorWithRed:0.83 green:0.84 blue:0.85 alpha:1.0];
//        else keyColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0];
//        
//        [self drawInnerFillInContext:context borderPath:bebelPath color:[UIColor colorWithWhite:0.0 alpha:0.3333]];
//        [self drawInnerFillInContext:context borderPath:borderPath color:keyColor];
        
        CGPathRelease(borderPath);
        CGPathRelease(bebelPath);
    }
    else
    {
        const CGRect innerRect = CGRectInset(rect, ShadowInset, ShadowInset); // hpique: Leave some space for the shadow
        CGPathRef borderPath = [SWKeyboardKey newPathForRoundedRect:CGRectInset(innerRect, 0.5, 0.5) radius:radius];
    
        [self drawShadowInContext:context borderPath:borderPath];
        [self drawGradientInContext:context borderPath:borderPath];
        [self drawOverallGradientInContext:context borderPath:borderPath];
        [self drawBottomInnerShadowInContext:context borderPath:borderPath rect:innerRect];
        [self drawTopInnerShadowInContext:context borderPath:borderPath rect:innerRect];
        [self drawBorderInContext:context borderPath:borderPath];
    
        CGPathRelease(borderPath);
    }
}

#pragma mark - UIControl

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setNeedsDisplay];
}

#pragma mark - Private

- (void)drawGradientInContext:(CGContextRef)context borderPath:(CGPathRef)borderPath
{
    CGContextSaveGState(context);
    UIColor *topColor, *bottomColor;
    if (self.state & (UIControlStateHighlighted | UIControlStateSelected))
    {
        topColor = [UIColor colorWithRed:179.0/255.0 green:179.0/255.0 blue:187.0/255 alpha:1];
        bottomColor = [UIColor colorWithRed:130.0/255.0 green:130.0/255.0 blue:140.0/255 alpha:1];
    }
    else
    {
        topColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:243.0/255 alpha:1];
        bottomColor = [UIColor colorWithRed:223.0/255.0 green:223.0/255.0 blue:231.0/255 alpha:1];
    }
    
    CGFloat locations[2] = { 0.0, 1.0 };
    NSArray *colors = @[(__bridge id)topColor.CGColor, (__bridge id)bottomColor.CGColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);
    
    CGPoint topCenter = CGPointMake(CGRectGetMidX(self.bounds), 0.0f);
    CGPoint midCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds));
    
    CGContextAddPath(context, borderPath);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, topCenter, midCenter, 0);
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
}

- (void)drawOverallGradientInContext:(CGContextRef)context borderPath:(CGPathRef)borderPath
{
    CGContextSaveGState(context);
    UIColor *topColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.11 alpha:0];
    UIColor *bottomColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.11 alpha:0.4];
    
    CGFloat locations[2] = { 0.0, 1.0 };
    NSArray *colors = @[(__bridge id)topColor.CGColor, (__bridge id)bottomColor.CGColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);
    
    CGPoint topCenter = CGPointMake(CGRectGetMidX(self.bounds), -(self.frame.origin.y));
    CGPoint midCenter = CGPointMake(CGRectGetMidX(self.bounds), self.superview.bounds.size.height-(self.frame.origin.y));
    
    CGContextAddPath(context, borderPath);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, topCenter, midCenter, 0);
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
}

- (void)drawBottomInnerShadowInContext:(CGContextRef)context borderPath:(CGPathRef)borderPath rect:(CGRect)rect
{
    CGContextSaveGState(context);
    CGContextAddPath(context, borderPath);
    CGContextEOClip(context);
    CGContextSetShadowWithColor(context, CGSizeMake(0, -1), 1, [UIColor colorWithWhite:0 alpha:0.5].CGColor);
    CGContextAddRect(context, CGRectInset(rect, -5, -5));
    CGContextAddPath(context, borderPath);
    CGContextEOFillPath(context);
    CGContextRestoreGState(context);
}

- (void)drawTopInnerShadowInContext:(CGContextRef)context borderPath:(CGPathRef)borderPath rect:(CGRect)rect
{
    CGContextSaveGState(context);
    CGContextAddPath(context, borderPath);
    CGContextEOClip(context);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 1), 0, [UIColor whiteColor].CGColor);
    CGContextAddRect(context, CGRectInset(rect, -5, -5));
    CGContextAddPath(context, borderPath);
    CGContextEOFillPath(context);
    CGContextRestoreGState(context);
}

- (void)drawBorderInContext:(CGContextRef)context borderPath:(CGPathRef)borderPath
{
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, 1);
    [[UIColor colorWithWhite:0.0 alpha:0.4] setStroke];
    CGContextAddPath(context, borderPath);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

- (void)drawShadowInContext:(CGContextRef)context borderPath:(CGPathRef)borderPath
{
    UIColor *shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 1), 3, shadowColor.CGColor);
    CGContextAddPath(context, borderPath);
    CGContextEOFillPath(context);
    CGContextRestoreGState(context);
}

- (void)drawInnerFillInContext:(CGContextRef)context borderPath:(CGPathRef)borderPath color:(UIColor*)color
{
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextAddPath(context, borderPath);
    CGContextEOFillPath(context);
    CGContextRestoreGState(context);
}

#pragma mark - Class

+ (CGPathRef)newPathForRoundedRect:(CGRect)rect radius:(CGFloat)radius
{
    CGMutablePathRef retPath = CGPathCreateMutable();
    
    const CGRect innerRect = CGRectInset(rect, radius, radius);
    
    const CGFloat insideRight = innerRect.origin.x + innerRect.size.width;
    const CGFloat outsideRight = rect.origin.x + rect.size.width;
    const CGFloat insideBottom = innerRect.origin.y + innerRect.size.height;
    const CGFloat outsideBottom = rect.origin.y + rect.size.height;
    
    const CGFloat insideTop = innerRect.origin.y;
    const CGFloat outsideTop = rect.origin.y;
    const CGFloat outsideLeft = rect.origin.x;
    
    CGPathMoveToPoint(retPath, NULL, innerRect.origin.x, outsideTop);
    
    CGPathAddLineToPoint(retPath, NULL, insideRight, outsideTop);
    CGPathAddArcToPoint(retPath, NULL, outsideRight, outsideTop, outsideRight, insideTop, radius);
    CGPathAddLineToPoint(retPath, NULL, outsideRight, insideBottom);
    CGPathAddArcToPoint(retPath, NULL,  outsideRight, outsideBottom, insideRight, outsideBottom, radius);
    
    CGPathAddLineToPoint(retPath, NULL, innerRect.origin.x, outsideBottom);
    CGPathAddArcToPoint(retPath, NULL,  outsideLeft, outsideBottom, outsideLeft, insideBottom, radius);
    CGPathAddLineToPoint(retPath, NULL, outsideLeft, insideTop);
    CGPathAddArcToPoint(retPath, NULL,  outsideLeft, outsideTop, innerRect.origin.x, outsideTop, radius);
    
    CGPathCloseSubpath(retPath);
    
    return retPath;
}

@end
