//
//  SWViewSelectionLayer.m
//  HmiPad
//
//  Created by Joan on 09/10/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

//#import <QuartzCore/QuartzCore.h>
#import "SWViewSelectionLayer.h"

#import "SWColor.h"
#import "Drawing.h"

@implementation SWViewSelectionLayer
{
    CALayer *_tmp;
}

- (id)init
{
    self = [super init] ;
    if ( self )
    {
        CGFloat scale = [UIScreen mainScreen].scale ;
        self.contentsScale = scale;
    }
    return self ;
}


- (void)addToView:(UIView*)view
{
    if ( view == nil )
        return;
    
    [[view layer] addSublayer:self];
    [self layoutInSuperview];
}

//- (void)removeFromSuperview
//{
//    [self removeFromSuperlayer];
//}

- (void)remove
{
    _tmp = self;
    _tmp.opacity = 0.0f;
    NSString *key = @"opacity";
    CABasicAnimation *valueAnimation = [CABasicAnimation animationWithKeyPath:key];
    valueAnimation.delegate = self;
    valueAnimation.duration = 0.25f;

    //valueAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
    //valueAnimation.fromValue = [_tmp.presentationLayer valueForKeyPath:key];
    valueAnimation.toValue = [NSNumber numberWithFloat:0.0f];
    valueAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    valueAnimation.removedOnCompletion = YES;
    [_tmp addAnimation:valueAnimation forKey:nil];
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [_tmp removeFromSuperlayer];
    _tmp = nil;
}

#define OverlayerWidth 6.0f
#define InterLayerWidth 1.0f
#define OverlayRGB TangerineSelectionColor

- (void)layoutInSuperview
{
   // [CATransaction begin];
   // [CATransaction setDisableActions:YES];
    
    CALayer *superlayer = self.superlayer;
    CGRect bounds = superlayer.bounds;
    [self setFrame:CGRectInset(bounds,-OverlayerWidth,-OverlayerWidth)];
    [self setNeedsDisplay];

   // [CATransaction commit];
}

- (void)drawInContext:(CGContextRef)theContext
{
    [self drawInContext_3:theContext];
}


// BO, seleccio de color pla ( funciona be amb un OverlayerWidh de 3 o 4 )
- (void)drawInContext_1:(CGContextRef)theContext
{
    CGRect bounds = self.bounds;
    CGFloat radius = OverlayerWidth*2;
    
    addRoundedRectPath(theContext, bounds, radius, 0);
    CGContextClip(theContext);
    
    CGRect theRect = CGRectInset( bounds, OverlayerWidth/2, OverlayerWidth/2 );
    
    UIColor *scolor = [UIColor colorWithWhite:0.0f alpha:0.8];
    CGContextSetShadowWithColor( theContext, CGSizeMake(0,0), OverlayerWidth, scolor.CGColor );
    
    UIColor *color = UIColorWithRgb(OverlayRGB);
    CGContextSetLineWidth(theContext, OverlayerWidth );
    CGContextSetStrokeColorWithColor( theContext, color.CGColor );
    addRoundedRectPath(theContext, theRect, radius, 0);
    CGContextStrokePath(theContext);
}


// BO similar a la seleccio de celdes de l'aplicacio numbers i sombra negre interior (funciona be amb un OverLayerWidth de 3) 
- (void)drawInContext_2:(CGContextRef)theContext
{
    CGRect bounds = self.bounds;
    CGFloat radius = OverlayerWidth*2;
    
    addRoundedRectPath(theContext, bounds, radius, 0);
    CGContextClip(theContext);
    
    CGRect theRect = CGRectInset( bounds, OverlayerWidth/2, OverlayerWidth/2 );
    
    UIColor *scolor = [UIColor colorWithWhite:0.0f alpha:0.8];
    CGContextSetShadowWithColor( theContext, CGSizeMake(0,0), OverlayerWidth+2, scolor.CGColor );

    UIColor *color = [UIColor blueColor];
    CGContextSetLineWidth(theContext, OverlayerWidth );
    CGContextSetStrokeColorWithColor( theContext, color.CGColor );
    addRoundedRectPath(theContext, theRect, radius, 0);
    CGContextStrokePath(theContext);
    
    CGContextSetShadowWithColor( theContext, CGSizeMake(0,0), 0, NULL );
    
    CGRect theRect2 = CGRectInset( bounds, OverlayerWidth/2, OverlayerWidth/2 );
    UIColor *color2 = UIColorWithRgb(BlueSelectionColor);
    CGContextSetLineWidth(theContext, InterLayerWidth );
    CGContextSetStrokeColorWithColor( theContext, color2.CGColor );
    addRoundedRectPath(theContext, theRect2, radius, 0);
    CGContextStrokePath(theContext);  
}


// BO, amb sombra exterior i un gap de color blanc (funciona be amb OverlayerWidth de 6)
- (void)drawInContext_3:(CGContextRef)theContext
{
    CGRect bounds = self.bounds;
    const CGFloat gap = 1;
    const CGFloat overlay = OverlayerWidth-gap;
    const CGFloat radius = 6;  // referit al borde interior
    
    //UIColor *scolor = [UIColor colorWithWhite:0.0f alpha:1.0];
    //UIColor *color = [UIColor blueColor];
//    UIColor *color = UIColorWithRgb(BlueSelectionColor);
//    UIColor *color2 = UIColorWithRgb(BlueSelectionColor);
    UIColor *color = UIColorWithRgb(OverlayRGB);
    UIColor *color2 = UIColorWithRgb(OverlayRGB);
    UIColor *colorw = [UIColor whiteColor];
    //UIColor *color3 = [UIColor cyanColor];
    
    // guardem el contexte
    CGContextSaveGState(theContext);
    
//    // clip per fora
    CGRect theRect = CGRectInset( bounds, overlay, overlay );
    CGRect boundingBox = CGContextGetClipBoundingBox(theContext);
    CGContextAddRect( theContext, boundingBox);
    addRoundedRectPath(theContext, theRect, radius, 0);
    CGContextEOClip(theContext);
    
    // rectangle amb sombra, la sombra quedara fora
    const CGFloat shadowBlur = 6;   //6
    theRect = CGRectInset( bounds, overlay-gap, overlay-gap );
    CGContextSetShadowWithColor( theContext, CGSizeMake(0,0), shadowBlur, color.CGColor );
    CGContextSetFillColorWithColor( theContext, color2.CGColor );
    addRoundedRectPath(theContext, theRect, radius+gap, 0);
    CGContextFillPath(theContext);
    
    // recuperem el contexte original
    CGContextRestoreGState(theContext);
    
    // rectangle blanc, just per fora del view
    CGRect theRectw = CGRectInset( bounds, overlay+gap-gap/2, overlay+gap-gap/2 );
    CGContextSetLineWidth(theContext, gap );
    CGContextSetStrokeColorWithColor( theContext, colorw.CGColor );
    addRoundedRectPath(theContext, theRectw, radius-(gap-gap/2), 0);
    CGContextStrokePath(theContext);

//  // rectangle exterior al rectangle blanc (en teoria no seria necessari pero aparentment queda tot plegat una mica mes definit
    CGRect theRect2 = CGRectInset( bounds, overlay-gap/2, overlay-gap/2 );
    CGContextSetLineWidth(theContext, gap );
    CGContextSetStrokeColorWithColor( theContext, color2.CGColor );
    addRoundedRectPath(theContext, theRect2, radius+gap/2, 0);
    CGContextStrokePath(theContext);  
}


// BO, amb un gap de color blanc sense sombra (funciona be amb OverlayerWidth de 6)
- (void)drawInContext_4:(CGContextRef)theContext
{
    CGRect bounds = self.bounds;
    CGFloat gap = 1;
    const CGFloat overlay = OverlayerWidth-gap;
    const CGFloat radius = 6;  // referit al borde interior
    
//    UIColor *color = UIColorWithRgb(OverlayRGB);
    UIColor *color2 = UIColorWithRgb(OverlayRGB);
    UIColor *colorw = [UIColor whiteColor];
    //UIColor *color3 = [UIColor cyanColor];
    
//    // guardem el contexte
//    CGContextSaveGState(theContext);
//    
////    // clip per fora
//    CGRect theRect = CGRectInset( bounds, overlay, overlay );
//    CGRect boundingBox = CGContextGetClipBoundingBox(theContext);
//    CGContextAddRect( theContext, boundingBox);
//    addRoundedRectPath(theContext, theRect, radius, 0);
//    CGContextEOClip(theContext);
//    
//    // rectangle amb sombra, la sombra quedara fora
//    const CGFloat shadowBlur = 6;
//    theRect = CGRectInset( bounds, overlay-gap, overlay-gap );
//    CGContextSetShadowWithColor( theContext, CGSizeMake(0,0), shadowBlur, color.CGColor );
//    CGContextSetFillColorWithColor( theContext, color2.CGColor );
//    addRoundedRectPath(theContext, theRect, radius+gap, 0);
//    CGContextFillPath(theContext);
//    
//    // recuperem el contexte original
//    CGContextRestoreGState(theContext);
    
    // rectangle blanc, just per fora del view
    CGRect theRectw = CGRectInset( bounds, overlay+gap-gap/2, overlay+gap-gap/2 );
    CGContextSetLineWidth(theContext, gap );
    CGContextSetStrokeColorWithColor( theContext, colorw.CGColor );
    addRoundedRectPath(theContext, theRectw, radius-(gap-gap/2), 0);
    CGContextStrokePath(theContext);

//  // rectangle exterior al rectangle blanc (en teoria no seria necessari pero aparentment queda tot plegat una mica mes definit)
    gap = 2;
    CGRect theRect2 = CGRectInset( bounds, overlay-gap/2, overlay-gap/2 );
    CGContextSetLineWidth(theContext, gap );
    CGContextSetStrokeColorWithColor( theContext, color2.CGColor );
    addRoundedRectPath(theContext, theRect2, radius+gap/2, 0);
    CGContextStrokePath(theContext);  
}







@end
