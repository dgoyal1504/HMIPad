//
//  RoundedLabel.m
//  ScadaMobile_100829
//
//  Created by Joan on 31/08/10.
//  Copyright 2010 SweetWilliam, S.L. All rights reserved.
//

#import "RoundedLabel.h"
#import "SWColor.h"
#import "Drawing.h"


@implementation RoundedLabel
{
    UIColor *_tintColor;
    UIColor *_highColor;
    UInt32 _rgbTintColor;
}


//-----------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
    {
        // Initialization code
    }
    return self;
}

//-----------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect 
{
    if ( _tintColor )
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        addRoundedRectPath(context, rect, 5, 0 ) ;
        CGContextClip(context);

        UIColor *color = _tintColor;
        if ( self.highlighted ) color = _highColor;
        
        CGContextSetFillColorWithColor(context, color.CGColor) ;
        CGContextFillRect(context, rect) ;
    }
    [super drawRect:rect] ;
}


//-----------------------------------------------------------------------------
- (void)dealloc 
{
	//[_tintColor release];
    //[super dealloc];
}


//-----------------------------------------------------------------------------
- (void)setRgbTintColor:(UInt32)rgbColor
{    
    if ( _rgbTintColor != rgbColor || _tintColor == nil )
    {
        _rgbTintColor = rgbColor ;
        _tintColor = UIColorWithRgb(_rgbTintColor) ;
        _highColor = UIColorWithRgb(DarkenedRgbColor(_rgbTintColor, 0.6f));
        
        [self setTextColor:contrastColorForRgbColor(_rgbTintColor)] ;
        [self setShadowColor:shadowColorForForRgbColor(_rgbTintColor)] ;
        [self setNeedsDisplay] ;
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}


@end
