//
//  SWColorCoverView.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/13/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWColorCoverView.h"

#import "SWColor.h"
#import "Drawing.h"

#warning ha de ser un layer
@implementation SWColorCoverView
{
    CGFloat _zoomScaleFactor;
}

@synthesize coverColor = _coverColor;
@synthesize lineWidth = _lineWidth;
@synthesize cornerRadius = _cornerRadius;

//- (id)initWithFrame:(CGRect)frame
//{
//    return [self initWithFrame:frame andColor:[UIColor redColor]];
//}
//
//- (id)initWithFrame:(CGRect)frame andColor:(UIColor*)color
//{
//    self = [super initWithFrame:frame];
//    if (self)
//    {
//        _coverColor = color;
//        self.backgroundColor = [UIColor clearColor];
//        self.userInteractionEnabled = NO;
//        self.clipsToBounds = NO;
//        _lineWidth = 4;
//        _cornerRadius = 4;
//    }
//    return self;
//}
//
//- (void)drawRect:(CGRect)rect
//{
//    CGFloat offset = _lineWidth/2.0;
//    CGContextRef theContext = UIGraphicsGetCurrentContext() ;
//    CGRect theRect = CGRectInset( [self bounds], offset, offset ) ;
//    CGContextSetShadowWithColor( theContext, CGSizeMake(0,1), offset*3, [UIColor blackColor].CGColor ) ;
//    CGContextSetLineWidth(theContext, offset*2 );
//    CGContextSetStrokeColorWithColor( theContext, _coverColor.CGColor ) ;
//    addRoundedRectPath(theContext, theRect, _cornerRadius, 0 ) ;
//    CGContextStrokePath(theContext);
//}

//#define oversize 20
//#define overoffset 6

#define oversize 4
#define overoffset 0

- (id)initWithFrame:(CGRect)frame
{
    frame = CGRectInset(frame, +oversize, +oversize);
    return [self initForRect:frame andColor:[UIColor redColor]];
}

- (id)initForRect:(CGRect)rect andColor:(UIColor*)color
{
    CGRect frame = CGRectInset(rect, -oversize, -oversize);
    self = [super initWithFrame:frame];
    if (self)
    {
        _coverColor = color;
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        _lineWidth = 1;
        _cornerRadius = 2;
    }
    return self;
}


- (void)setShowsCoverInEditMode:(BOOL)showsCoverInEditMode
{
    if ( _showsCoverInEditMode != showsCoverInEditMode )
    {
        _showsCoverInEditMode = showsCoverInEditMode;
        [self setNeedsDisplay];
    }
}

- (void)setEditMode:(BOOL)editMode
{
    if ( _editMode != editMode )
    {
        _editMode = editMode;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    if ( _editMode && !_showsCoverInEditMode )
        return;
    
    CGFloat multiplyFactor = 1/_zoomScaleFactor;
    if ( multiplyFactor > 1 ) multiplyFactor = 1;

    CGFloat efLineWidth = _lineWidth*multiplyFactor;

    CGFloat offset = efLineWidth/2.0;
    CGContextRef theContext = UIGraphicsGetCurrentContext() ;
    
    CGRect bounds = self.bounds;
    CGRect theRect = CGRectInset( bounds, oversize-overoffset-offset, oversize-overoffset-offset ) ;
    
    if ( NO && !_editMode )
    {
        CGContextSetFillColorWithColor( theContext, [UIColor colorWithWhite:0.5 alpha:0.5].CGColor);
        CGRect fillRect = CGRectInset(theRect, overoffset+offset, overoffset+offset );
        addRoundedRectPath(theContext, fillRect, 0, 0 ) ;
        CGContextFillPath(theContext);
    }
    
    CGContextSetLineWidth(theContext, efLineWidth );
    
//    CGContextSetShadowWithColor( theContext, CGSizeMake(0,0), 2, [UIColor blackColor].CGColor ) ;
    CGContextSetStrokeColorWithColor( theContext, [UIColor blackColor].CGColor );
    addRoundedRectPath(theContext, theRect, _cornerRadius, 0 ) ;
    CGContextStrokePath(theContext);
    
//    CGContextSetShadowWithColor( theContext, CGSizeMake(0,0), 0, NULL  ) ;
    CGContextSetStrokeColorWithColor( theContext, _coverColor.CGColor );
    static const CGFloat lengths[2] = {4,4};
    CGContextSetLineDash(theContext, 0, lengths, 2);
    addRoundedRectPath(theContext, theRect, _cornerRadius, 0 ) ;
    CGContextStrokePath(theContext);
}


- (void)setZoomScaleFactor:(CGFloat)zoomScaleFactor
{
    _zoomScaleFactor = zoomScaleFactor;
    CGFloat contentScale = [[UIScreen mainScreen]scale]*zoomScaleFactor;
    [self setContentScaleFactor:contentScale];
}

- (CGFloat)zoomScaleFactor
{
    return _zoomScaleFactor;
}


@end
