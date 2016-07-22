//
//  ColoredButton.m
//  ScadaMobile_100412
//
//  Created by Joan on 13/04/2010.
//  Copyright 2010 SweetWilliam, S.L.. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SWColor.h"
#import "Drawing.h"

#import "ColoredButton.h"
#import "VerticallyAlignedLabel.h"


#define BORDER YES
//#define RADIUS 7
#define RADIUS 4

////////////////////////////////////////////////////////////////////////////////////
#pragma mark ColoredButton
////////////////////////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
@implementation ColoredButton
{
    BOOL _hasCustomImage;
    BOOL _unactived;
    VerticallyAlignedLabel *_overLabel;
}



//-----------------------------------------------------------------------------
- (id)init
{
    if ( (self = [super init] ) )
    {
       // [self setContentMode:UIViewContentModeRedraw] ;
       //_textAlignment = NSTextAlignmentCenter;
    }
    return self ;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self )
    {
        //_textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (void)awakeFromNib
{
    //_textAlignment = NSTextAlignmentCenter;
}

- (VerticallyAlignedLabel*)_overLabel
{
    if ( _overLabel == nil )
    {
        _overLabel = [[VerticallyAlignedLabel alloc] initWithFrame:self.bounds];
        [_overLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [_overLabel setBackgroundColor:[UIColor clearColor]];
        [_overLabel setNumberOfLines:0];
        [_overLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_overLabel setEnabled:self.enabled];
        [self addSubview:_overLabel];
    }
    return _overLabel;
}

- (void)_removeLabel
{
    [_overLabel removeFromSuperview];
    _overLabel = nil;
}

- (void)setVerticalTextAlignment:(VerticalAlignment)alignment
{
    [[self _overLabel] setVerticalAlignment:alignment];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    [[self _overLabel] setTextAlignment:textAlignment];
}

- (void)setOverTitle:(NSString *)text
{
    [[self _overLabel] setText:text];
}

- (void)setOverFont:(UIFont*)font
{
    [[self _overLabel] setFont:font];
}

- (void)setUnactived:(BOOL)unactived
{
    _unactived = unactived;
    [self setUserInteractionEnabled:!_unactived];
    [self computeBackgroundImage];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize size = self.bounds.size;
    CGFloat currentHeight = size.height;
    if (currentHeight != _oldFrameHeight)
    {
        _oldFrameHeight = currentHeight;
        [self computeBackgroundImage];
    }
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return contentRect;
}


- (void)computeBackgroundImage
{
    if ( _hasCustomImage )
        return;
    
    int style = 1;  // solid rect
    if ( self.enabled && !_unactived ) style=0;
    
    CGSize size = self.bounds.size;
    CGFloat scale = self.contentScaleFactor;
    
    const CGFloat radius = self.circular ? size.width / 2 : RADIUS;
    UIColor *color = UIColorWithRgb(rgbTintColor);
    UIImage *image = glossyImageWithSizeAndColorScaled( CGSizeMake(radius*2+2, size.height),
        [color CGColor], BORDER, bottomLine, radius, style, scale ) ;
        
    //NSLog ( @"Image Scale: %g", image.scale);
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, (radius), 0, (radius)) resizingMode:UIImageResizingModeStretch];
    //NSLog ( @"Resizable Image Scale: %g", image.scale);
    [self setBackgroundImage:image forState:UIControlStateNormal];
}


- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [self _removeLabel];
    [super setTitle:title forState:state];
    //[self _updateTextAlignement];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    [self.titleLabel setEnabled:enabled];
    [_overLabel setEnabled:enabled];
    [self computeBackgroundImage];
}


- (void)setImage:(UIImage*)image forState:(UIControlState)controlState
{
    _hasCustomImage = (image != nil );
    
    if ( _hasCustomImage )
    {
        [super setBackgroundImage:nil forState:controlState];
    }
    else
    {
        [self computeBackgroundImage];
    }

    [super setImage:image forState:controlState];
}

//-----------------------------------------------------------------------------
- (void)setRgbTintColor:(UInt32)rgbColor overWhite:(BOOL)overWhite;
{    
    if ( rgbTintColor != rgbColor )
    {
        rgbTintColor = rgbColor ;
        bottomLine = overWhite;
        //UIColor *color = UIColorWithRgb(rgbTintColor) ;
        
        UIColor *textColor = contrastColorForRgbColor(rgbTintColor) ;
        UIColor *shadowColor = shadowColorForForRgbColor(rgbTintColor) ;

        if ( _overLabel )
        {
            [_overLabel setShadowOffset:CGSizeMake(0.0f, -1.0f)] ;
            [_overLabel setTextColor:textColor] ;
            [_overLabel setShadowColor:shadowColor];
        }
        else
        {
            [[self titleLabel] setShadowOffset:CGSizeMake(0.0f, -1.0f)] ;
            [self setTitleColor:textColor forState:UIControlStateNormal] ;
            [self setTitleShadowColor:shadowColor forState:UIControlStateNormal];
        }
        
        [self computeBackgroundImage];
    }
}


- (void)setContentScaleFactor:(CGFloat)contentScaleFactor
{
    [super setContentScaleFactor:contentScaleFactor];
    [_overLabel setContentScaleFactor:contentScaleFactor];
    [self computeBackgroundImage];
}

//- (CGFloat)zoomScaleFactor
//{
//    CGFloat scale = self.contentScaleFactor;
//    return scale / [[UIScreen mainScreen]scale];
//}
//
//
//- (void)setZoomScaleFactor:(CGFloat)zoomScaleFactor
//{
//    CGFloat scale = [[UIScreen mainScreen]scale]*zoomScaleFactor;
//    
//    [self setContentScaleFactor:scale];
//    [_overLabel setContentScaleFactor:scale];
//    [self computeBackgroundImage];
//}


//-----------------------------------------------------------------------------
- (void)dealloc 
{
}

@end
