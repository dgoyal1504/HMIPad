//
//  SWHPIndicatorView.m
//  HmiPad
//
//  Created by Joan Lluch on 6/23/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "Drawing.h"
#import "SWValue.h"
#import "SWColor.h"

#import "SWLayer.h"
#import "SWHPIndicatorView.h"

#import "SWContrastedViewProtocol.h"

@interface SWHPIndicatorView()<SWContrastedViewProtocol>

@property (nonatomic, readonly) UIColor *textColor;
@property (nonatomic, readonly) UIFont *font ;
@property (nonatomic, readonly) SWRange range;
@property (nonatomic, readonly) NSData *ranges ;
@property (nonatomic, readonly) NSData *rangeColors ;
@property (nonatomic, readonly) UIEdgeInsets insets ;
@property (nonatomic, readonly) double value;

@property (nonatomic, readonly) UIColor *contrastColor ;

@end



#pragma mark SWHPRangesLayer

@interface SWHPRangesLayer : SWLayer

//@property (nonatomic, assign) double value;
@property (nonatomic, assign) double rangeOrigin ;
@property (nonatomic, assign) double rangeLength ;

@end

@implementation SWHPRangesLayer

@dynamic rangeLength;
@dynamic rangeOrigin;

// inidiquem les propietats key-value que necesiten redibuixar el layer
+ (BOOL)needsDisplayForKey:(NSString *)key 
{
    if ( /*[key isEqualToString:@"value"] ||*/ [key isEqualToString:@"rangeLength"] || [key isEqualToString:@"rangeOrigin"] )
    {
        return YES;
    }

    return [super needsDisplayForKey:key];
}

// tornem animacions per la propietat
-(id<CAAction>)actionForKey:(NSString *)key 
{
    if ( /*[key isEqualToString:@"value"] ||*/ [key isEqualToString:@"rangeLength"] || [key isEqualToString:@"rangeOrigin"])
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
- (id)initWithLayer:(SWHPRangesLayer *)layer
{
    self = [super initWithLayer:layer] ;
    if ( self )
    {
        //self.value = layer.value ;
        self.rangeLength = layer.rangeLength ;
        self.rangeOrigin = layer.rangeOrigin ;
    }
    return self ;
}


//- (void)setValue:(double)value animated:(BOOL)animated
//{
//    [self setAnimated:animated] ;
//    self.value = value ;
//}

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
    
    SWHPIndicatorView *v = (SWHPIndicatorView*)_v ;
    
    
    UIEdgeInsets insets = v.insets ;
    SWDirection direction = v.direction ;
    //UIColor *barColor = v.needleColor ;
    SWRange range;
    double rangeLen = self.rangeLength;
    range.min = self.rangeOrigin ;
    range.max = range.min + rangeLen ;
    
    
    NSData *ranges = v.ranges;
    NSData *rangeColors = v.rangeColors;
    
    int rangeCount = [ranges length]/sizeof(SWValueRange);  // sera 0 si es nil
    const SWValueRange *cRanges = [ranges bytes];
    
    int rangeColorCount = [rangeColors length]/sizeof(UInt32);  // sera 0 si es nil
    const UInt32 *cRGBs = [rangeColors bytes];
    
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
    
    for ( int i=0 ; i<rangeCount ; i++ )
    {
        SWValueRange r = cRanges[i];
        double rLen = r.max-r.min;
        
        UInt32 rgb = RedColor;
        rgb = Theme_RGB(0, 192, 192, 192);
        if ( i<rangeColorCount ) rgb = cRGBs[i];
        
        UIColor *barColor = UIColorWithRgb(rgb);
    
        CGContextSaveGState(context);
        {
    
            CGRect barRect = backRect ;
    
            switch ( direction ) 
            {
                case SWDirectionUp:
                
                    barRect.origin.x = insets.left,
                    barRect.origin.y = /*floorf*/(SWConvertToViewPort( r.min, range.min, range.max, insets.bottom, size.height-insets.top )) ;
                    barRect.size.height = /*ceilf*/(SWConvertToViewPort( rLen, 0, rangeLen, 0, backRect.size.height )) ;
                    //barRect.size.height = SWConvertToViewPort( r.max, range.min, range.max, insets.bottom, size.height-insets.top ) - barRect.origin.y;
                    break;
            
                case SWDirectionRight:
                    barRect.origin.x = /*floorf*/(SWConvertToViewPort( r.min, range.min, range.max, insets.left, size.width-insets.right )) ;
                    barRect.origin.y = insets.bottom ;
                    barRect.size.width = /*ceilf*/(SWConvertToViewPort( rLen, 0, rangeLen, 0, backRect.size.width )) ;
                    break;
            
                case SWDirectionDown:
                    barRect.origin.x = insets.left ;
                    barRect.origin.y = /*floorf*/(SWConvertToViewPort( r.max, range.max, range.min, insets.bottom, size.height-insets.top )) ;
                    barRect.size.height = /*ceilf*/(SWConvertToViewPort( rLen, 0, rangeLen, 0, backRect.size.height )) ;
                    break;
         
                case SWDirectionLeft:
                    barRect.origin.x = /*floorf*/(SWConvertToViewPort( r.max, range.max, range.min, insets.left, size.width-insets.right )) ;
                    barRect.origin.y = insets.bottom ;
                    barRect.size.width = /*ceilf*/(SWConvertToViewPort( rLen, 0, rangeLen, 0, backRect.size.width )) ;
                    break;
            
                default:
                    break;
            }
    
            CGContextClipToRect( context, barRect ) ;
            
            BOOL isVertical = (direction==SWDirectionUp || direction==SWDirectionDown);
            DrawGradientDirection gradientDirection = isVertical ? DrawGradientDirectionRight : DrawGradientDirectionFlippedDown ;
        
            drawSingleGradientRect( context, barRect, barColor.CGColor, gradientDirection) ;
        }
        
        CGContextRestoreGState(context);
    }
}

@end


#pragma mark SWHPValueLayer

@interface SWHPValueLayer : SWLayer

@property (nonatomic, assign) double value;
//@property (nonatomic, assign) double rangeOrigin ;
//@property (nonatomic, assign) double rangeLength ;

@end

@implementation SWHPValueLayer

@dynamic value ;

// inidiquem les propietats key-value que necesiten redibuixar el layer
+ (BOOL)needsDisplayForKey:(NSString *)key 
{
    if ( [key isEqualToString:@"value"] )
    {
        return YES;
    }

    return [super needsDisplayForKey:key];
}

// tornem animacions per la propietat
-(id<CAAction>)actionForKey:(NSString *)key 
{
    if ( [key isEqualToString:@"value"] )
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
- (id)initWithLayer:(SWHPValueLayer *)layer
{
    self = [super initWithLayer:layer] ;
    if ( self )
    {
        self.value = layer.value ;
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
    [self setNeedsDisplay] ; // per el cas de canvi de origen
}


// draw
- (void)drawInContext:(CGContextRef)context
{
    CGRect rect = self.bounds ;
    //CGPoint origin = rect.origin;
    CGSize size = rect.size;
    
    SWHPIndicatorView *v = (SWHPIndicatorView*)_v ;
    
    
    UIEdgeInsets insets = v.insets ;
    UIFont *font = v.font ;
    NSString *format = v.format ;
    UIColor *textColor = v.textColor ;
    double value = self.value ;
    
    // label
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





#pragma mark SWHPNeedleLayer

@interface SWHPNeedleLayer : SWLayer

@property (nonatomic, assign) double value;
//@property (nonatomic, assign) double rangeOrigin ;
//@property (nonatomic, assign) double rangeLength ;

@end

@implementation SWHPNeedleLayer

//// inidiquem les propietats key-value que necesiten redibuixar el layer
//+ (BOOL)needsDisplayForKey:(NSString *)key 
//{
//    if ( [key isEqualToString:@"value"] )
//    {
//        return YES;
//    }
//
//    return [super needsDisplayForKey:key];
//}
//
//// tornem animacions per la propietat
//-(id<CAAction>)actionForKey:(NSString *)key 
//{
//    if ( [key isEqualToString:@"value"] )
//    {
//        if ( !_isAnimated ) return nil ;
//        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:key] ;
//        animation.fromValue = [[self presentationLayer] valueForKey:key] ;
//        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut] ;
//        animation.duration = 0.5 ;
//        return animation;
//    }
//    
//    return [super actionForKey:key] ;
//}
//
//// inicialitzador per defecte
//- (id)init
//{
//    self = [super init] ;
//    if ( self )
//    {
//    }
//    return self ;
//}
//
//
//// inicialitzador utilitzat per el presentationLayer al fer les animacions
//- (id)initWithLayer:(SWHPValueLayer *)layer
//{
//    self = [super initWithLayer:layer] ;
//    if ( self )
//    {
//        self.value = layer.value ;
//    }
//    return self ;
//}


//- (void)setValue:(double)value animated:(BOOL)animated
//{
//    [self setAnimated:animated] ;
//    self.value = value ;
//}
//
//- (void)setRange:(SWRange)range animated:(BOOL)animated
//{
//    [self setAnimated:animated] ;
//    [self setNeedsDisplay] ; // per el cas de canvi de origen
//}



- (void)updateValueAnimated:(BOOL)animated
{
    SWHPIndicatorView *v = (SWHPIndicatorView*)_v ;

    CGRect rect = v.bounds ;
    CGSize size = rect.size;

    UIEdgeInsets insets = v.insets ;
    double value = v.value ;
    SWDirection direction = v.direction ;
    SWRange range = v.range;

    CGPoint position;
    
    switch ( direction )
    {
        case SWDirectionUp:
            position.x = size.width-insets.right;
            position.y = SWConvertToViewPort(value, range.min, range.max, insets.bottom, size.height-insets.top);
            break;
            
        case SWDirectionRight:
            position.x = SWConvertToViewPort(value, range.min, range.max, insets.left, size.width-insets.right);
            position.y = size.height-insets.top;
            break;
            
        case SWDirectionDown:
            position.x = size.width-insets.right;
            position.y = SWConvertToViewPort(value, range.max, range.min, insets.bottom, size.height-insets.top);
            break;
        
        case SWDirectionLeft:
            position.x = SWConvertToViewPort(value, range.max, range.min, insets.left, size.width-insets.right);
            position.y = size.height-insets.top;
            break;
    
    }
    
    if ( position.x < insets.left ) position.x = insets.left;
    if ( position.x > size.width-insets.right ) position.x = size.width-insets.right;
    if ( position.y < insets.bottom ) position.y = insets.bottom;
    if ( position.y > size.height-insets.top ) position.y = size.height-insets.top;
    
    position.y = size.height-position.y;   // <-- revertim les coordenades de iOS
    
    self.bounds = CGRectMake(0, 0, 40, 40);
    
    self.position = position;
    if ( animated )
    {
        //CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        CABasicAnimation *animation = [[CABasicAnimation alloc] init];
        animation.duration = 0.5;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut] ;
        animation.fromValue = [[self presentationLayer] valueForKeyPath:@"position"];
        animation.toValue = [NSValue valueWithCGPoint:position];
        [self addAnimation:animation forKey:@"position"];
    }
}



//// draw
//- (void)drawInContextX:(CGContextRef)context
//{
//    CGRect rect = self.bounds ;
//    //CGPoint origin = rect.origin;
//    CGSize size = rect.size;
//    
//    SWHPIndicatorView *v = (SWHPIndicatorView*)_v ;
//    
//    UIColor *needleColor = v.needleColor ;
//    UIColor *textColor = v.textColor;
//    UIColor *contrastColor = contrastColorForUIColor(textColor);
//    SWDirection direction = v.direction ;
//    
//    CGPoint center = CGPointMake( size.width/2, size.height/2);
//    CGFloat outerRadius = size.width/2;
//    
//    SWTranslateAndFlipCTM( context, size.height ) ;
//    
//        CGFloat needleWidth = 5 ;
//        CGContextSetLineCap( context, kCGLineCapRound ) ;
//        CGContextSetStrokeColorWithColor(context, needleColor.CGColor);
//        CGContextSetLineWidth(context, needleWidth );
//        //CGFloat outerRadius = [v getOuterRadius] ;
//        
//        CGMutablePathRef path = CGPathCreateMutable();
//    
//        CGPoint endPoint = center;
//    
//        switch ( direction )
//        {
//            case SWDirectionDown:
//            case SWDirectionUp:
//                endPoint.x = center.x+outerRadius;
//                endPoint.y = center.y;
//                break;
//        
//            case SWDirectionRight:
//            case SWDirectionLeft:
//                endPoint.x = center.x;
//                endPoint.y = center.y+outerRadius;
//                break;
//        }
//    
//        CGPathMoveToPoint(path, NULL, center.x, center.y);
//        CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y);
//        
//        CGContextSetLineWidth(context, needleWidth+1 );
//        //CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:1 alpha:1.0f].CGColor);
//        //CGContextSetShadowWithColor( context, CGSizeMake(0,0), 5, [UIColor colorWithWhite:0 alpha:0.5f].CGColor /*textColor.CGColor*/ ) ;
//        CGContextSetStrokeColorWithColor(context, contrastColor.CGColor);
//        CGContextSetShadowWithColor( context, CGSizeMake(0,0), 5, textColor.CGColor ) ;
//    
//        CGContextAddPath(context, path);
//        CGContextStrokePath(context);
//        
//        CGContextSetLineWidth(context, needleWidth );
//        CGContextSetStrokeColorWithColor(context, needleColor.CGColor);
//        CGContextAddPath(context, path);
//        CGContextStrokePath(context);
//        
//        CGPathRelease(path);
//}


// draw
- (void)drawInContext:(CGContextRef)context
{
    CGRect rect = self.bounds ;
    //CGPoint origin = rect.origin;
    CGSize size = rect.size;
    
    SWHPIndicatorView *v = (SWHPIndicatorView*)_v ;
    
    UIColor *needleColor = v.needleColor ;  
    //UIColor *contrastColor1 = [contrastColorForUIColor(v.backgroundColor) colorWithAlphaComponent:1.0];
    UIColor *contrastColor1 = [contrastColorForUIColor(v.contrastColor) colorWithAlphaComponent:1.0];
    UIColor *contrastColor2 = [contrastColorForUIColor(contrastColor1) colorWithAlphaComponent:1.0];
    
    
    SWDirection direction = v.direction ;
    
    CGPoint center = CGPointMake( size.width/2, size.height/2);
    CGFloat outerRadius = 16;
    
    SWTranslateAndFlipCTM( context, size.height ) ;
    
        CGFloat needleWidth = 3 ;
        CGContextSetLineCap( context, kCGLineCapRound ) ;
        CGContextSetLineJoin(context, kCGLineJoinRound) ;
        CGContextSetStrokeColorWithColor(context, needleColor.CGColor);
        CGContextSetLineWidth(context, needleWidth );
        //CGFloat outerRadius = [v getOuterRadius] ;
        
        CGMutablePathRef path = CGPathCreateMutable();
    
        CGPoint endPoint1 = center;
        CGPoint endPoint2 = center;
        CGFloat tg30 = tanf(M_PI/6);
    
        switch ( direction )
        {
            case SWDirectionDown:
            case SWDirectionUp:
                endPoint1.x = center.x+outerRadius;
                endPoint1.y = center.y+outerRadius*tg30;
                endPoint2.x = center.x+outerRadius;
                endPoint2.y = center.y-outerRadius*tg30;
                break;
        
            case SWDirectionRight:
            case SWDirectionLeft:
                endPoint1.x = center.x-outerRadius*tg30;
                endPoint1.y = center.y+outerRadius;
                endPoint2.x = center.x+outerRadius*tg30;
                endPoint2.y = center.y+outerRadius;
                break;
        }
    
        CGPathMoveToPoint(path, NULL, center.x, center.y);
        CGPathAddLineToPoint(path, NULL, endPoint1.x, endPoint1.y);
        CGPathAddLineToPoint(path, NULL, endPoint2.x, endPoint2.y);
        CGPathCloseSubpath(path);
        
        CGContextSetLineWidth(context, needleWidth+1 );
        //CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:1 alpha:1.0f].CGColor);
        //CGContextSetShadowWithColor( context, CGSizeMake(0,0), 5, [UIColor colorWithWhite:0 alpha:0.5f].CGColor /*textColor.CGColor*/ ) ;
        CGContextSetStrokeColorWithColor(context, contrastColor1.CGColor);
        CGContextSetShadowWithColor( context, CGSizeMake(0,0), 3, contrastColor2.CGColor ) ;
    
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
        
        CGContextSetLineWidth(context, needleWidth );
        CGContextSetStrokeColorWithColor(context, needleColor.CGColor);
        CGContextSetShadowWithColor( context, CGSizeMake(0,0), 0, NULL ) ;
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
        
        CGPathRelease(path);
}

@end












#pragma mark SWHPBarBackLayer

@interface SWHPBarBackLayer : SWLayer

@end


@implementation SWHPBarBackLayer

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
    
    SWHPIndicatorView *v = (SWHPIndicatorView*)_v ;
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



#pragma mark SWHPBarLevelLayer

@interface SWHPBarLevelLayer : SWLayer
@end


@implementation SWHPBarLevelLayer
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
    
    Class needleLayer = [SWHPNeedleLayer class] ;
    //SWBarLevelView *v = (SWBarLevelView*)_v ;
    //UIEdgeInsets insets = v.insets ;
    
    for ( CALayer *layer in self.sublayers )
    {
        CGRect rect = bounds ;
        if ( [layer isKindOfClass:needleLayer] )
        {
            [(SWHPNeedleLayer*)layer updateValueAnimated:NO];
            continue;
        }
        
        layer.frame = rect ;
        [layer setNeedsLayout] ;
    }
}

@end



@implementation SWHPIndicatorView
{
    SWHPNeedleLayer *_needleLayer;
    SWHPValueLayer *_valueLayer ;
    SWHPRangesLayer *_rangesLayer ;
    SWHPBarBackLayer *_backLayer ;
}

+ (Class)layerClass
{
    return [SWHPBarLevelLayer class] ;
}

//@synthesize progress = _progress ;
@synthesize range = _range ;
@synthesize value = _value ;
@synthesize insets = _insets ;
@synthesize font = _font ;
@synthesize format = _format ;
@synthesize direction = _direction ;
@synthesize needleColor = _needleColor ;
@synthesize tintsColor = _tintsColor ;
@synthesize borderColor = _borderColor ;
@synthesize textColor = _textColor ;
@synthesize contrastColor = _contrastColor ;

- (void)_doInit
{
    SWHPBarLevelLayer *layer = (id)[self layer] ;
    [layer setView:self] ;

    _backLayer = [[SWHPBarBackLayer alloc] init] ;
    [_backLayer setView:self] ;
    [layer addSublayer:_backLayer] ;
    
    _rangesLayer = [[SWHPRangesLayer alloc] init] ;
    [_rangesLayer setView:self] ;
    [layer addSublayer:_rangesLayer] ;
    
    _valueLayer = [[SWHPValueLayer alloc] init];
    [_valueLayer setView:self];
    [layer addSublayer:_valueLayer];
    
    _needleLayer = [[SWHPNeedleLayer alloc] init];
    [_needleLayer setView:self];
    [layer addSublayer:_needleLayer];
    
    _font = [UIFont boldSystemFontOfSize:13] ;
    _format = @"%0.4g" ;
    
    _direction = SWDirectionUp;
    _needleColor = [UIColor blueColor];
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

- (void)setNeedleColor:(UIColor *)color
{    
    _needleColor = color;
    [_needleLayer setNeedsDisplay] ;
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
    [_rangesLayer setNeedsDisplay] ;
    [_needleLayer setNeedsDisplay];
    [_needleLayer updateValueAnimated:NO];
}

- (void)setValue:(double)value animated:(BOOL)animated
{
    _value = value ;
    [_valueLayer setValue:value animated:animated];
    [_needleLayer updateValueAnimated:animated];
}

- (void)setRange:(SWRange)range animated:(BOOL)animated
{
    _range = range ;
    [_rangesLayer setRange:range animated:animated] ;
    [_needleLayer updateValueAnimated:animated];
}

- (void)setRanges:(NSData*)ranges
{
    _ranges = ranges;
    [_rangesLayer setNeedsDisplay];
}

- (void)setRangeRgbColors:(NSData *)rangeColors
{
    _rangeColors = rangeColors;
    [_rangesLayer setNeedsDisplay];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor ;
    [_valueLayer setNeedsDisplay] ;
}

- (void)setFormat:(NSString *)format
{
    _format = format ;
    [_valueLayer setNeedsDisplay] ;
}

- (void)setContrastForBackgroundColor:(UIColor *)color
{
    _contrastColor = contrastColorForUIColor( color ) ;
    _textColor = _contrastColor;
    [_valueLayer setNeedsDisplay];
    [_needleLayer setNeedsDisplay];
}

- (void)setBackgroundColor:(UIColor *)color
{
    [super setBackgroundColor:color] ;
    [self setContrastForBackgroundColor:color];
}


@end

