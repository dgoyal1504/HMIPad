//
//  SWPipeView.m
//  HmiPad
//
//  Created by Joan on 23/05/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWPipeView.h"
#import "SWLayer.h"
#import "Drawing.h"

@interface SWPipeView()

//@property (nonatomic) DrawGradientDirection direction;

@end


#pragma mark SWLineLayer

@interface SWLineLayer : SWLayer
@end


@implementation SWLineLayer

// draw
- (void)drawInContext:(CGContextRef)context
{
    CGRect rect = self.bounds ;
    CGSize size = rect.size;
    
    SWPipeView *v = (SWPipeView*)_v ;
    UIColor *color = v.color;
    
    CGContextSaveGState( context ) ;
    SWTranslateAndFlipCTM( context, size.height ) ;

    DrawGradientDirection gradientDirection = v.verticalPipe?DrawGradientDirectionRight:DrawGradientDirectionFlippedDown ;
    drawSingleGradientRect( context, rect, color.CGColor, gradientDirection) ;
}


@end



#pragma mark SWBarLevelLayer

@interface SWPipeLayer : SWLayer
@end


@implementation SWPipeLayer
- (id)init
{
    self = [super init] ;
    if ( self )
    {
    }
    return self ;
}


- (void)layoutSublayers
{
    [super layoutSublayers] ;
        
    CGRect bounds = self.bounds ;
    
    Class LineLayerClass = [SWLineLayer class] ;
    SWPipeView *v = (SWPipeView*)_v ;
    UIEdgeInsets insets = v.insets ;
    
    for ( CALayer *layer in self.sublayers )
    {
        CGRect rect = bounds ;
        if ( [layer isKindOfClass:LineLayerClass] )
        {
            rect.origin.x += insets.left ;
            rect.origin.y += insets.top ;
            rect.size.width -= insets.left+insets.right ;
            rect.size.height -= insets.top+insets.bottom ;
        }
        
        layer.frame = rect ;
        [layer setNeedsLayout] ;
    }
}

@end


@implementation SWPipeView
{
    SWLineLayer *_lineLayer;
}


+ (Class)layerClass
{
    return [SWPipeLayer class] ;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        SWPipeLayer *layer = (id)[self layer] ;
        [layer setView:self] ;
    
        _lineLayer = [[SWLineLayer alloc] init];
        [_lineLayer setView:self];
        [layer addSublayer:_lineLayer];
        
        _color = [UIColor grayColor];
        _verticalPipe = NO;
        _insets = UIEdgeInsetsMake(4, 0, 4, 0);
    }
    return self;
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    [_lineLayer setNeedsDisplay];
}

- (void)setVerticalPipe:(BOOL)verticalPipe
{
    _verticalPipe = verticalPipe;
    if ( _verticalPipe )
        _insets = UIEdgeInsetsMake(0, 4, 0, 4);
    else
        _insets = UIEdgeInsetsMake(4, 0, 4, 0);
    
    [self.layer setNeedsLayout];
    [_lineLayer setNeedsDisplay];
}


@end
