//
//  SWLampView.m
//  HmiPad
//
//  Created by Lluch Joan on 09/07/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWLampView.h"
#import "SWLayer.h"
#import "SWColor.h"
#import "drawing.h"

@interface SWLampView()

@property (nonatomic, readonly) BOOL value;
@property (nonatomic, readonly) UIEdgeInsets insets;
- (CGFloat)getOuterRadius;
- (CGPoint)getCenterFlipped:(BOOL)isFlipped;

@end



static void drawBackgroundLedInClippedContext( CGContextRef context, CGRect circleRect )
{
    CGPoint center;
    CGFloat outerRadius = circleRect.size.width/2;
    center.x = circleRect.origin.x + outerRadius;
    center.y = circleRect.origin.y + outerRadius;

    CGFloat white = 1.0;
    CGFloat gray = 0.3;
    CGFloat lightGray = 0.7;
    CGFloat lightClear = 0.1;
    UIColor *whiteColor = [UIColor colorWithRed:white green:white blue:white alpha:1.0];
    UIColor *lightGrayColor = [UIColor colorWithRed:lightGray green:lightGray blue:lightGray alpha:1.0];
    UIColor *grayColor = [UIColor colorWithRed:gray green:gray blue:gray alpha:1.0];
    UIColor *clearColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0];
    UIColor *lightClearColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:lightClear];
    
// cercle interior
    //CGContextSaveGState( context );
//    CGContextAddEllipseInRect( context, circleRect );
//    CGContextClip( context );
    drawLinearGradientRect(context, circleRect, grayColor.CGColor, lightGrayColor.CGColor, DrawGradientDirectionFlippedDown);
    //CGContextRestoreGState( context );

    // shine inferior
    CGRect trect;
    CGFloat wGapFactor = 0.6;
    CGFloat hRFactor = 0.4;
    CGFloat hGapFactor = 0.9;
    trect.origin.x = center.x - outerRadius*wGapFactor;
    trect.origin.y = center.y - outerRadius*hGapFactor;
    trect.size.width = outerRadius*wGapFactor*2;
    trect.size.height = outerRadius*hRFactor*2;
    CGContextSetFillColorWithColor( context, lightClearColor.CGColor );
    CGContextAddEllipseInRect( context, trect );
    CGContextFillPath( context );
    
    // shine superior
    wGapFactor = 0.8;
    hRFactor = 0.6;
    hGapFactor = 0.4;
    trect.origin.x = center.x - outerRadius*wGapFactor;
    trect.origin.y = center.y - outerRadius*hGapFactor;
    trect.size.width = outerRadius*wGapFactor*2;
    trect.size.height = outerRadius*hRFactor*2;
    CGContextSaveGState( context );
    CGContextAddEllipseInRect( context, trect );
    CGContextClip( context );
    drawLinearGradientRect(context, trect, whiteColor.CGColor, clearColor.CGColor, DrawGradientDirectionFlippedDown);
    CGContextRestoreGState( context );

}




#pragma mark SWLedLayer

@interface SWLedLayer : SWLayer
{
    BOOL _value;
}
@end


@implementation SWLedLayer

- (void)_performBlinkAnimation
{
    CABasicAnimation *blinkAnimation = [CABasicAnimation animationWithKeyPath:nil];
    blinkAnimation.duration = 0.333f;

    blinkAnimation.fromValue = [NSNumber numberWithFloat:_value?1.0f:0.2f];  
    blinkAnimation.toValue = [NSNumber numberWithFloat:_value?0.2f:1.0f];
    blinkAnimation.autoreverses = YES;
    blinkAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    blinkAnimation.repeatCount = HUGE_VALF;
    [self addAnimation:blinkAnimation forKey:@"opacity"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    SWLampView *v = (SWLampView*)_v;
    BOOL blink = v.blink; 
    if ( blink && _value ) [self _performBlinkAnimation];
    else [self removeAnimationForKey:@"opacity"];
}


- (void)_performValueAnimation
{
    CGFloat oldValue = [[self presentationLayer] opacity];
    
    if ( _value == oldValue )
    {
        [self animationDidStop:nil finished:YES];
        return;
    }
        
    CABasicAnimation *valueAnimation = [CABasicAnimation animationWithKeyPath:nil];
    valueAnimation.delegate = self;
    valueAnimation.duration = 0.166f;
    

    valueAnimation.fromValue = [NSNumber numberWithFloat:oldValue] ; // [NSNumber numberWithFloat:_value?0.2f:1.0f];  
    valueAnimation.toValue = [NSNumber numberWithFloat:_value?1.0f:0.2f];
    valueAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self addAnimation:valueAnimation forKey:@"opacity"];
}


- (void)updateValueAnimated:(BOOL)animated
{
    SWLampView *v = (SWLampView*)_v;
    _value = v.value;
    self.opacity = _value?1.0f:0.2f;
    
    if ( animated )
        [self _performValueAnimation];
}


- (void)updateBlinkState
{
    [self _performValueAnimation];  
}


- (void)drawInContext:(CGContextRef)context
{
    CGRect rect = self.bounds;
    CGSize size = rect.size;
    
    SWLampView *v = (SWLampView*)_v;
    UIColor *color = v.color;
    
    SWTranslateAndFlipCTM( context, size.height );
    
    CGFloat outerRadius = [v getOuterRadius];
    CGPoint center = [v getCenterFlipped:NO];

    CGRect circleRect;
    circleRect.origin.x = center.x - outerRadius;
    circleRect.origin.y = center.y - outerRadius;
    circleRect.size.width = outerRadius*2;
    circleRect.size.height = outerRadius*2;

    // dibuixem una sombra en el borde
    CGContextSetStrokeColorWithColor( context, color.CGColor ) ;
    CGContextSetLineWidth( context, 10 ) ;
    CGContextSetShadowWithColor( context, CGSizeMake(0,0), 10, color.CGColor ) ;
    //CGContextSetShadow( context, CGSizeMake(0,0), 5);
    //CGRect outCircleRect = CGRectInset(circleRect, +5, +5 );
    CGFloat shadowOutSet = fminf(+5, circleRect.size.width/2);
    CGRect shadowCircleRect = CGRectInset(circleRect, shadowOutSet, shadowOutSet );
    CGContextAddEllipseInRect( context, shadowCircleRect ) ;
    CGContextStrokePath( context ) ;
    CGContextSetShadowWithColor( context, CGSizeMake(0,0), 0, NULL ) ;  // desactivem la sombra

    CGContextAddEllipseInRect( context, circleRect );
    CGContextClip( context );
    
    drawBackgroundLedInClippedContext(context, circleRect);
    
    // el color
    CGContextSetBlendMode( context, kCGBlendModeColor );
    CGContextSetFillColorWithColor( context, color.CGColor );
    CGContextFillRect(context, circleRect);
}


@end


#pragma mark SWLampBackLayer
@interface SWLampBackLayer : SWLayer
@end

@implementation SWLampBackLayer


// draw
- (void)drawInContext:(CGContextRef)context
{
    CGRect rect = self.bounds;
    CGSize size = rect.size;
    
    SWLampView *v = (SWLampView*)_v;
    
    CGFloat outerRadius = [v getOuterRadius];
    CGPoint center = [v getCenterFlipped:NO];

    CGRect circleRect;
    circleRect.origin.x = center.x - outerRadius;
    circleRect.origin.y = center.y - outerRadius;
    circleRect.size.width = outerRadius*2;
    circleRect.size.height = outerRadius*2;

    SWTranslateAndFlipCTM( context, size.height );
        
    CGContextAddEllipseInRect( context, circleRect );
    CGContextClip( context );
    
    drawBackgroundLedInClippedContext( context, circleRect );
}


@end



#pragma mark SWLampLayer

@interface SWLampViewLayer : SWLayer
@end


@implementation SWLampViewLayer
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
    
    for ( CALayer *layer in self.sublayers )
    {
        CGRect rect = bounds ;
        layer.frame = rect ;
        [layer setNeedsLayout] ;
    }
}

@end




@implementation SWLampView
{
    SWLedLayer *_ledLayer ;
    SWLampBackLayer *_backLayer ;
}

+ (Class)layerClass
{
    return [SWLampViewLayer class] ;
}


@synthesize value = _value;
@synthesize blink = _blink;
@synthesize color = _color;
@synthesize insets = _insets;


- (void)_doInit
{
    SWLampViewLayer *layer = (id)[self layer] ;
    [layer setView:self] ;
    
    _backLayer = [[SWLampBackLayer alloc] init] ;
    [_backLayer setView:self] ;
    [layer addSublayer:_backLayer] ;
    
    _ledLayer = [[SWLedLayer alloc] init] ;
    [_ledLayer setView:self] ;
    [layer addSublayer:_ledLayer] ;
    
    _insets = UIEdgeInsetsMake( 8, 8, 8, 8 );
    _color = UIColorWithRgb(BarDefaultColor);
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        [self _doInit];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) 
    {
        [self _doInit];
    }
    return self;
}

- (CGFloat)getOuterRadius
{
    CGRect rect = self.bounds ;
    CGSize size = rect.size;
    CGFloat xRadius = (size.width-_insets.left-_insets.right)/2.0f;
    CGFloat yRadius = (size.height-_insets.top-_insets.bottom)/2.0f;
    CGFloat outerRadius = MIN(xRadius,yRadius);
    return outerRadius;
}

- (CGPoint)getCenterFlipped:(BOOL)isFlipped
{
    CGPoint center;
    CGSize size = self.bounds.size;
	center.x = _insets.left + (size.width-_insets.left-_insets.right)/2.0f;;
	center.y = _insets.bottom + (size.height-_insets.bottom-_insets.top)/2.0f;
    if ( isFlipped ) center.y = size.height - center.y;    // compensem per y invertida en cocoa touch
    return center;
}


- (void)setValue:(BOOL)value animated:(BOOL)animated
{
    _value = value;
    [_ledLayer updateValueAnimated:animated];
}


- (void)setBlink:(BOOL)blink
{
    _blink = blink;
    [_ledLayer updateValueAnimated:YES];
}


- (void)setColor:(UIColor *)color
{
    _color = color;
    [_ledLayer setNeedsDisplay];
}

@end
