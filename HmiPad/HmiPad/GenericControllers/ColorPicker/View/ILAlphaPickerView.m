//
//  ILAlphaPickerView.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/20/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "ILAlphaPickerView.h"
#import "UIColor+GetHSB.h"
#import "SWColor.h"

@interface ILAlphaPickerView ()

- (void)handleTouches:(NSSet *)touches withEvent:(UIEvent *)event pickingFinished:(BOOL)flag;

@end

@implementation ILAlphaPickerView

@synthesize delegate;
@synthesize alphaValue = _alphaValue;
@synthesize pickerOrientation;


#pragma mark - Setup

- (void)setup
{
    [super setup];
    
    self.clipsToBounds = YES;
    
    _alphaValue = 1.0;
    pickerOrientation = ILAlphaPickerViewOrientationVertical;
}


#define IndLength 8.0f

static CGFloat _scale( CGFloat x, CGFloat x1, CGFloat x2, CGFloat y1, CGFloat y2)
{
    CGFloat y = y1 + (x-x1)*((y2-y1)/(x2-x1));
    if ( y<y1) y=y1;
    if ( y>y2 ) y=y2;
    return y;
}



#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    // draw the hue gradient
    CGContextRef context=UIGraphicsGetCurrentContext();
    
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
        
    CGFloat locs[2]={0.0f, 1.0f};
    
    NSArray *colors=[NSArray arrayWithObjects:
                     (id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] CGColor], 
                     (id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] CGColor], 
                     nil];
    
    CGGradientRef grad = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locs);
    
    if (pickerOrientation == ILAlphaPickerViewOrientationHorizontal)
        CGContextDrawLinearGradient(context, grad, CGPointMake(rect.size.width,0), CGPointMake(0, 0), 0);
    else
        CGContextDrawLinearGradient(context, grad, CGPointMake(0,rect.size.height), CGPointMake(0, 0), 0);
    
    CGGradientRelease(grad);
    CGColorSpaceRelease(colorSpace);
    
    // Draw the indicator
    
//    float pos = (pickerOrientation == ILAlphaPickerViewOrientationHorizontal) ?
//        rect.size.width*(1.0-_alphaValue) :
//        rect.size.height*(1.0-_alphaValue);
    //float indLength = 6;
    
    CGContextSetFillColorWithColor(context, [[UIColor colorWithWhite:0.2f alpha:1.0f] CGColor]);     // 0.2
    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:1.0f alpha:1.0f] CGColor]);   // 0.4
    //CGContextSetStrokeColorWithColor(context, [UIColorWithRgb(TangerineSelectionColor) CGColor]);   // 0.4
    CGContextSetLineWidth(context, 1.0);      // 0.5
    //CGContextSetShadow(context, CGSizeMake(0, 0), 4);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 8, [UIColorWithRgb(0) CGColor] );
    
    CGFloat offset = 1;
    CGFloat pos;
    
    if (pickerOrientation == ILAlphaPickerViewOrientationHorizontal)
    {
        pos = _scale(_alphaValue, 1, 0, IndLength/2, rect.size.width-IndLength/2);
        pos = truncf(pos)+0.5f;
        CGContextMoveToPoint(context, pos-(IndLength/2), -offset);
        CGContextAddLineToPoint(context, pos+(IndLength/2), -offset);
        CGContextAddLineToPoint(context, pos+(IndLength/2), rect.size.height+offset);
        CGContextAddLineToPoint(context, pos-(IndLength/2), rect.size.height+offset);
        CGContextAddLineToPoint(context, pos-(IndLength/2), -offset);
    }
    else
    {
        pos = _scale(_alphaValue, 1, 0, IndLength/2, rect.size.height-IndLength/2-1);
        pos = roundf(pos)+0.5f;
        CGContextMoveToPoint(context, -offset, pos-(IndLength/2));
        CGContextAddLineToPoint(context, -offset, pos+(IndLength/2));
        CGContextAddLineToPoint(context, rect.size.width+offset, pos+(IndLength/2));
        CGContextAddLineToPoint(context, rect.size.width+offset, pos-(IndLength/2));
        CGContextAddLineToPoint(context, -offset, pos-(IndLength/2));
    }
    
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
}

#pragma mark - Touches

- (void)handleTouches:(NSSet *)touches withEvent:(UIEvent *)event pickingFinished:(BOOL)flag
{
    CGPoint pos=[[touches anyObject] locationInView:self];
    
    CGRect frame = self.frame;
    
//    float p=(pickerOrientation == ILAlphaPickerViewOrientationHorizontal) ? pos.x : pos.y;
//    float b=(pickerOrientation == ILAlphaPickerViewOrientationHorizontal) ? frame.size.width : frame.size.height;
//    
//    _alphaValue = _scale(p, b-IndLength/2-1, IndLength/2, 0, 1);
    
    if ( pickerOrientation == ILAlphaPickerViewOrientationHorizontal)
        _alphaValue = _scale(pos.x, frame.size.width-IndLength/2-1, IndLength/2, 0, 1);
    else
        _alphaValue = _scale(pos.y, frame.size.height-IndLength/2-1, IndLength/2, 0, 1);

//    
//    if (p<0)
//        _alphaValue=1.0;
//    else if (p>b)
//        _alphaValue=0.0;
//    else
//        _alphaValue=1.0-p/b;
    
    //NSLog( @"alpha:%g", _alphaValue);
    
    [delegate alphaPicked:_alphaValue picker:self pickingFinished:flag];
    
    [self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"BEGAN");
    [self handleTouches:touches withEvent:event pickingFinished:NO];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"MOVED");
    [self handleTouches:touches withEvent:event pickingFinished:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"ENDED");
    [self handleTouches:touches withEvent:event pickingFinished:YES];
}

#pragma mark - Property Setters


- (void)setAlphaValue:(CGFloat)a
{
    _alphaValue = a;
    [self setNeedsDisplay];
}

- (void)setPickerOrientation:(ILAlphaPickerViewOrientation)po
{
    pickerOrientation = po;
    [self setNeedsDisplay];
}

- (void)setAlphaFromColor:(UIColor *)cc
{
    CGFloat r,g,b,a;
    [cc getHue:&r saturation:&g brightness:&b alpha:&a];
    
    _alphaValue = a;
    [self setNeedsDisplay];
}

@end
