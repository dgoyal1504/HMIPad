//
//  SWBarLevelView.m
//  HmiPad
//
//  Created by Joan Lluch on 4/16/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "Drawing.h"
#import "SWValue.h"
#import "SWColor.h"

#import "SWLayer.h"
#import "SWBarLevelView.h"

#import "SWContrastedViewProtocol.h"

@interface SWBarLevelView()<SWContrastedViewProtocol>

@property (nonatomic, readonly) UIColor *textColor;
@property (nonatomic, readonly) UIColor *contrastColor;
@property (nonatomic, readonly) UIFont *font ;
@property (nonatomic, readonly) SWRange range;
@property (nonatomic, readonly) UIEdgeInsets insets ;
@property (nonatomic, readonly) double value;

@end



#pragma mark SWLevelLayer

@interface SWLevelLayer : SWLayer

@property (nonatomic, assign) double value;
@property (nonatomic, assign) double rangeOrigin ;
@property (nonatomic, assign) double rangeLength ;
//@property (nonatomic, assign) BOOL animated;

@end

@implementation SWLevelLayer

@dynamic value ;
@dynamic rangeLength ;
@dynamic rangeOrigin ;
//@synthesize animated = _isAnimated ;
//@synthesize rangeOrigin = _rangeOrigin ;

// inidiquem les propietats key-value que necesiten redibuixar el layer
+ (BOOL)needsDisplayForKey:(NSString *)key 
{
    if ( [key isEqualToString:@"value"] || [key isEqualToString:@"rangeLength"] || [key isEqualToString:@"rangeOrigin"] )
    {
        return YES;
    }

    return [super needsDisplayForKey:key];
}

// tornem animacions per la propietat
-(id<CAAction>)actionForKey:(NSString *)key 
{
    if ( [key isEqualToString:@"value"] || [key isEqualToString:@"rangeLength"] || [key isEqualToString:@"rangeOrigin"])
    {
        if ( !_isAnimated ) return nil ;
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:key] ;
        
        animation.fromValue = [[self presentationLayer] valueForKey:key] ;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut] ;
        animation.duration = 0.5 ;
        return animation;
    }
    
    return [super actionForKey:key] ;
}

// inicialitzador per defecte
- (id)init
{
    self = [super init] ;
    if ( self )
    {
    }
    return self ;
}


// inicialitzador utilitzat per el presentationLayer al fer les animacions
- (id)initWithLayer:(SWLevelLayer *)layer
{
    self = [super initWithLayer:layer] ;
    if ( self )
    {
        self.value = layer.value ;
        self.rangeLength = layer.rangeLength ;
        self.rangeOrigin = layer.rangeOrigin ;
    }
    return self ;
}


- (void)setValue:(double)value animated:(BOOL)animated
{
    [self setAnimated:animated] ;
    self.value = value ;
}

- (void)setRange:(SWRange)range animated:(BOOL)animated
{
    [self setAnimated:animated] ;
    self.rangeOrigin = range.min ;
    self.rangeLength = range.max-range.min ;
    [self setNeedsDisplay] ; // per el cas de canvi de origen
}


// draw
- (void)drawInContext:(CGContextRef)context
{
    CGRect rect = self.bounds ;
    //CGPoint origin = rect.origin;
    CGSize size = rect.size;
    
    SWBarLevelView *v = (SWBarLevelView*)_v ;
    
    
    UIEdgeInsets insets = v.insets ;
    UIFont *font = v.font ;
    NSString *format = v.format ;
    SWDirection direction = v.direction ;
    UIColor *barColor = v.barColor ;
    //UIColor *backColor = v.tintColor ;
    UIColor *textColor = v.textColor ;
    double value = self.value ;
    SWRange range;
    range.min = self.rangeOrigin ;
    range.max = range.min + self.rangeLength ;
    
    CGContextSaveGState( context ) ;
    SWTranslateAndFlipCTM( context, size.height ) ;
    
    
    CGRect backRect = CGRectMake
    ( 
        insets.left, 
        insets.bottom, 
        size.width-insets.left-insets.right, 
        size.height-insets.top-insets.bottom 
    ) ;
    
    
    CGContextClipToRect( context, backRect ) ;
//    CGContextSetFillColorWithColor( context, backColor.CGColor ) ;
//    CGContextFillRect( context, backRect ) ;
    
    CGRect barRect = backRect ;
    
    switch ( direction ) 
    {
        case SWDirectionUp:
            barRect.origin = CGPointMake( insets.left, insets.bottom ) ;
            barRect.size.height = SWConvertToViewPort( value, range.min, range.max, 0, backRect.size.height ) ;
            break;        
            
        case SWDirectionRight:
            barRect.origin = CGPointMake( insets.left, insets.bottom ) ;
            barRect.size.width = SWConvertToViewPort( value, range.min, range.max, 0, backRect.size.width ) ;
            break;
            
        case SWDirectionDown:
            barRect.origin.x = insets.left ;
            barRect.origin.y = SWConvertToViewPort( value, range.max, range.min, insets.bottom, size.height-insets.top ) ;
            barRect.size.height = SWConvertToViewPort( value, range.min, range.max, 0, backRect.size.height ) ;
            break;
         
        case SWDirectionLeft:
            barRect.origin.x = SWConvertToViewPort( value, range.max, range.min, insets.left, size.width-insets.right ) ;
            barRect.origin.y = insets.bottom ;
            barRect.size.width = SWConvertToViewPort( value, range.min, range.max, 0, backRect.size.width ) ;
            break;
            
        default:
            break;
    }
    
    CGContextClipToRect( context, barRect ) ;
    BOOL isVertical = (direction==SWDirectionUp || direction==SWDirectionDown);
    DrawGradientDirection gradientDirection = isVertical ? DrawGradientDirectionRight : DrawGradientDirectionFlippedDown ;
        
    drawSingleGradientRect( context, barRect, barColor.CGColor, gradientDirection) ;
    
    // label
    CGContextRestoreGState( context ) ;  // recuperem el estat inicial
    UIGraphicsPushContext( context ) ;
    
    //CGContextSetFillColorWithColor( context, textColor.CGColor ) ;
    
    NSString *str = stringForDouble_withFormat( value, format ) ;
       
    CGFloat lineHeight = font.lineHeight ;
    CGFloat y = insets.bottom - lineHeight/4 ;
       
    CGRect tRect ;
    tRect.origin.x = 0 ;
    tRect.origin.y = size.height - y ;
    tRect.size.width = size.width ;
    tRect.size.height = lineHeight ;
    if ( NO /*_isAligned*/ ) tRect.origin = SWAlignPointToDeviceSpace( context, tRect.origin ) ;
    
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle alloc] init];
        textStyle.lineBreakMode = NSLineBreakByClipping;
        textStyle.alignment = NSTextAlignmentCenter;
        
    NSDictionary *attrs = @{
        NSFontAttributeName:font,
        NSParagraphStyleAttributeName:textStyle,
        NSForegroundColorAttributeName:textColor
    };
    
        
    //[str drawInRect:tRect withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter] ;
    
    [str drawInRect:tRect withAttributes:attrs];

    UIGraphicsPopContext();
}

@end





#pragma mark SWLevelLayer

@interface SWBarBackLayer : SWLayer

@end


@implementation SWBarBackLayer

// tornem animacions per la propietat
-(id<CAAction>)actionForKey:(NSString *)key 
{
    return [super actionForKey:key] ;
}


// draw
- (void)drawInContext:(CGContextRef)context
{
    CGRect rect = self.bounds ;
    CGSize size = rect.size;
    
    SWBarLevelView *v = (SWBarLevelView*)_v ;
    UIEdgeInsets insets = v.insets ;
    UIColor *borderColor = v.borderColor ;
    UIColor *tintColor = v.tintsColor ;
    
    
    SWTranslateAndFlipCTM( context, size.height ) ;
    
    CGRect backRect = CGRectMake
    ( 
        insets.left, 
        insets.bottom, 
        size.width-insets.left-insets.right, 
        size.height-insets.top-insets.bottom 
    ) ;
    
    
    CGContextSetFillColorWithColor( context, tintColor.CGColor ) ;
    CGContextFillRect( context, backRect ) ;
    
    
    const CGFloat LineWidth = 1.0 ;
    const CGFloat LOffset = 0.5 ; //LineWidth/2 ;
    CGContextSetLineWidth( context, LineWidth ) ;
    CGContextSetStrokeColorWithColor( context, borderColor.CGColor ) ;
    
    SWMoveToPoint( context, insets.left-LOffset, insets.bottom-LOffset, NO ) ;
    SWAddLineToPoint( context, insets.left-LOffset, size.height-insets.top+LOffset, NO ) ;
    SWAddLineToPoint( context, size.width-insets.right+LOffset, size.height-insets.top+LOffset, NO ) ;
    SWAddLineToPoint( context, size.width-insets.right+LOffset,  insets.bottom-LOffset, NO ) ;
    SWAddLineToPoint( context, insets.left-LOffset, insets.bottom-LOffset, NO ) ;
    
    CGContextSetLineCap( context, kCGLineCapRound ) ;
    CGContextSetLineJoin( context, kCGLineJoinRound ) ;
    CGContextStrokePath( context );
}

@end



#pragma mark SWBarLevelLayer

@interface SWBarLevelLayer : SWLayer
@end


@implementation SWBarLevelLayer
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
    
    //Class LevelLayerClass = [SWLevelLayer class] ;
    //SWBarLevelView *v = (SWBarLevelView*)_v ;
    //UIEdgeInsets insets = v.insets ;
    
    for ( CALayer *layer in self.sublayers )
    {
        CGRect rect = bounds ;
        /*if ( [layer isKindOfClass:LevelLayerClass] )
        {
            rect.origin.x += insets.left ;
            rect.origin.y += insets.top ;
            rect.size.width -= insets.left+insets.right ;
            rect.size.height -= insets.top+insets.bottom ;
        }
        */
        
        layer.frame = rect ;
        [layer setNeedsLayout] ;
    }
}

@end



@implementation SWBarLevelView
{
    SWLevelLayer *_levelLayer ;
    SWBarBackLayer *_backLayer ;
}

+ (Class)layerClass
{
    return [SWBarLevelLayer class] ;
}

//@synthesize progress = _progress ;
@synthesize range = _range ;
@synthesize value = _value ;
@synthesize insets = _insets ;
@synthesize font = _font ;
@synthesize format = _format ;
@synthesize direction = _direction ;
@synthesize barColor = _barColor ;
@synthesize tintsColor = _tintsColor ;
@synthesize borderColor = _borderColor ;
@synthesize textColor = _textColor ;
@synthesize contrastColor = _contrastColor ;

- (void)_doInit
{
    SWBarLevelLayer *layer = (id)[self layer] ;
    [layer setView:self] ;

    _backLayer = [[SWBarBackLayer alloc] init] ;
    [_backLayer setView:self] ;
    [layer addSublayer:_backLayer] ;
    
    _levelLayer = [[SWLevelLayer alloc] init] ;
    [_levelLayer setView:self] ;
    [layer addSublayer:_levelLayer] ;
    
    _font = [UIFont boldSystemFontOfSize:13] ;
    _format = @"%0.4g" ;
    
    _direction = SWDirectionUp;
    _barColor = [UIColor blueColor];
    _tintsColor = [UIColor whiteColor] ;
    _borderColor = [UIColor lightGrayColor] ;
    _textColor = [UIColor darkGrayColor] ;
    _insets = UIEdgeInsetsMake( 8, 8, 24, 8 ) ;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _doInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _doInit];
    }
    return self;
}

- (void)setBarColor:(UIColor *)color
{    
    _barColor = color;
    [_levelLayer setNeedsDisplay] ;
}

- (void)setTintsColor:(UIColor *)color
{    
    _tintsColor = color;
    [_backLayer setNeedsDisplay] ;
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor ;
    [_backLayer setNeedsDisplay] ;
}

- (void)setDirection:(SWDirection)direction
{
    _direction = direction;
    [_levelLayer setNeedsDisplay] ;
}

- (void)setValue:(double)value animated:(BOOL)animated
{
    _value = value ;
    [_levelLayer setValue:value animated:animated] ;
}

- (void)setRange:(SWRange)range animated:(BOOL)animated
{
    _range = range ;
    [_levelLayer setRange:range animated:animated] ;
}

/*
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    _progress = progress ;
    [_levelLayer setProgress:progress animated:animated] ;
}
*/



- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor ;
    [_levelLayer setNeedsDisplay] ;
}

- (void)setFormat:(NSString *)format
{
    _format = format ;
    [_levelLayer setNeedsDisplay] ;
}

- (void)setContrastForBackgroundColor:(UIColor *)color
{
    _contrastColor = contrastColorForUIColor( color ) ;
    _textColor = _contrastColor;
    [_levelLayer setNeedsDisplay] ;
}

- (void)setBackgroundColor:(UIColor *)color
{
    [super setBackgroundColor:color] ;
    [self setContrastForBackgroundColor:color];
}

/*
- (void)setProgress:(CGFloat)progress
{
    [self setProgress:progress animated:NO] ;
}
*/

/*
- (CGFloat)progress
{
    return _levelLayer.progress ;
}
*/

@end

