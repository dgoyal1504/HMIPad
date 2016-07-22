//
//  SWShapeView.m
//  HmiPad
//
//  Created by Lluch Joan on 09/07/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWShapeView.h"
#import "SWLayer.h"
#import "SWColor.h"
#import "drawing.h"

#import "UIImage+Resize.h"

@interface SWShapeView()

@property (nonatomic, readonly) UIEdgeInsets insets;
@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) UIViewContentMode contentMode;
@property (nonatomic, readonly) BOOL original;


//- (CGFloat)getOuterRadius;
//- (CGPoint)getCenterFlipped:(BOOL)isFlipped;

@end


//
//static void drawBackgroundLedInClippedContext( CGContextRef context, CGRect circleRect )
//{
//    CGPoint center;
//    CGFloat outerRadius = circleRect.size.width/2;
//    center.x = circleRect.origin.x + outerRadius;
//    center.y = circleRect.origin.y + outerRadius;
//
//    CGFloat white = 1.0;
//    CGFloat gray = 0.3;
//    CGFloat lightGray = 0.7;
//    CGFloat lightClear = 0.1;
//    UIColor *whiteColor = [UIColor colorWithRed:white green:white blue:white alpha:1.0];
//    UIColor *lightGrayColor = [UIColor colorWithRed:lightGray green:lightGray blue:lightGray alpha:1.0];
//    UIColor *grayColor = [UIColor colorWithRed:gray green:gray blue:gray alpha:1.0];
//    UIColor *clearColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0];
//    UIColor *lightClearColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:lightClear];
//    
//// cercle interior
//    //CGContextSaveGState( context );
////    CGContextAddEllipseInRect( context, circleRect );
////    CGContextClip( context );
//    drawLinearGradientRect(context, circleRect, grayColor.CGColor, lightGrayColor.CGColor, DrawGradientDirectionFlippedDown);
//    //CGContextRestoreGState( context );
//
//    // shine inferior
//    CGRect trect;
//    CGFloat wGapFactor = 0.6;
//    CGFloat hRFactor = 0.4;
//    CGFloat hGapFactor = 0.9;
//    trect.origin.x = center.x - outerRadius*wGapFactor;
//    trect.origin.y = center.y - outerRadius*hGapFactor;
//    trect.size.width = outerRadius*wGapFactor*2;
//    trect.size.height = outerRadius*hRFactor*2;
//    CGContextSetFillColorWithColor( context, lightClearColor.CGColor );
//    CGContextAddEllipseInRect( context, trect );
//    CGContextFillPath( context );
//    
//    // shine superior
//    wGapFactor = 0.8;
//    hRFactor = 0.6;
//    hGapFactor = 0.4;
//    trect.origin.x = center.x - outerRadius*wGapFactor;
//    trect.origin.y = center.y - outerRadius*hGapFactor;
//    trect.size.width = outerRadius*wGapFactor*2;
//    trect.size.height = outerRadius*hRFactor*2;
//    CGContextSaveGState( context );
//    CGContextAddEllipseInRect( context, trect );
//    CGContextClip( context );
//    drawLinearGradientRect(context, trect, whiteColor.CGColor, clearColor.CGColor, DrawGradientDirectionFlippedDown);
//    CGContextRestoreGState( context );
//
//}


//
//
//#pragma mark SWShapeLayer
//
//@interface SWShapeLayer : SWLayer
//{
//    BOOL _value;
//}
//@end
//
//
//@implementation SWShapeLayer
//
//- (void)_performBlinkAnimation
//{
//    CABasicAnimation *blinkAnimation = [CABasicAnimation animationWithKeyPath:nil];
//    blinkAnimation.duration = 0.333f;
//
//    blinkAnimation.fromValue = [NSNumber numberWithFloat:_value?1.0f:0.2f];  
//    blinkAnimation.toValue = [NSNumber numberWithFloat:_value?0.2f:1.0f];
//    blinkAnimation.autoreverses = YES;
//    blinkAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    blinkAnimation.repeatCount = HUGE_VALF;
//    [self addAnimation:blinkAnimation forKey:@"opacity"];
//}
//
//- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
//{
//    SWShapeView *v = (SWShapeView*)_v;
//    BOOL blink = v.blink; 
//    if ( blink && _value ) [self _performBlinkAnimation];
//    else [self removeAnimationForKey:@"opacity"];
//}
//
//
//- (void)_performValueAnimation
//{
//    CGFloat oldValue = [[self presentationLayer] opacity];
//    
//    if ( _value == oldValue )
//    {
//        [self animationDidStop:nil finished:YES];
//        return;
//    }
//        
//    CABasicAnimation *valueAnimation = [CABasicAnimation animationWithKeyPath:nil];
//    valueAnimation.delegate = self;
//    valueAnimation.duration = 0.166f;
//    
//
//    valueAnimation.fromValue = [NSNumber numberWithFloat:oldValue] ; // [NSNumber numberWithFloat:_value?0.2f:1.0f];  
//    valueAnimation.toValue = [NSNumber numberWithFloat:_value?1.0f:0.2f];
//    valueAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
//    [self addAnimation:valueAnimation forKey:@"opacity"];
//}
//
//
//- (void)updateValueAnimated:(BOOL)animated
//{
////    SWShapeView *v = (SWShapeView*)_v;
////    _value = v.value;
////    self.opacity = _value?1.0f:0.2f;
////    
////    if ( animated )
////        [self _performValueAnimation];
//}
//
//
//- (void)updateBlinkState
//{
//    [self _performValueAnimation];  
//}
//
//
//- (void)drawInContext:(CGContextRef)context
//{
////    CGRect rect = self.bounds;
////    CGSize size = rect.size;
////    
////    SWShapeView *v = (SWShapeView*)_v;
////    UIColor *color = v.color;
////    
////    SWTranslateAndFlipCTM( context, size.height );
////    
////    CGFloat outerRadius = [v getOuterRadius];
////    CGPoint center = [v getCenterFlipped:NO];
////
////    CGRect circleRect;
////    circleRect.origin.x = center.x - outerRadius;
////    circleRect.origin.y = center.y - outerRadius;
////    circleRect.size.width = outerRadius*2;
////    circleRect.size.height = outerRadius*2;
////
////    // dibuixem una sombra en el borde
////    CGContextSetStrokeColorWithColor( context, color.CGColor ) ;
////    CGContextSetLineWidth( context, 10 ) ;
////    CGContextSetShadowWithColor( context, CGSizeMake(0,0), 10, color.CGColor ) ;
////    //CGContextSetShadow( context, CGSizeMake(0,0), 5);
////    CGContextAddEllipseInRect( context, CGRectInset(circleRect, +5, +5 ) ) ;
////    CGContextStrokePath( context ) ;
////    CGContextSetShadowWithColor( context, CGSizeMake(0,0), 0, NULL ) ;  // desactivem la sombra
////
////    CGContextAddEllipseInRect( context, circleRect );
////    CGContextClip( context );
////    
////    drawBackgroundLedInClippedContext(context, circleRect);
////    
////    // el color
////    CGContextSetBlendMode( context, kCGBlendModeColor );
////    CGContextSetFillColorWithColor( context, color.CGColor );
////    CGContextFillRect(context, circleRect);
//}
//
//
//@end
//

#pragma mark SWShapeBackLayer
@interface SWShapeBackLayer : SWLayer
{
    CGFloat _opacity;
}

@end

@implementation SWShapeBackLayer


- (void)_performBlinkAnimation
{
    CABasicAnimation *blinkAnimation = [CABasicAnimation animationWithKeyPath:nil];
    blinkAnimation.duration = 0.333f;

    blinkAnimation.fromValue = [NSNumber numberWithFloat:_opacity?_opacity:0.0f];
    blinkAnimation.toValue = [NSNumber numberWithFloat:_opacity?0.0f:_opacity];
    blinkAnimation.autoreverses = YES;
    blinkAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    blinkAnimation.repeatCount = HUGE_VALF;
    [self addAnimation:blinkAnimation forKey:@"opacity"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    SWShapeView *v = (SWShapeView*)_v;
    BOOL blink = v.blink; 
    if ( blink && _opacity>0.0f ) [self _performBlinkAnimation];
    else [self removeAnimationForKey:@"opacity"];
}


- (void)_performValueAnimation
{
    CGFloat oldValue = [[self presentationLayer] opacity];
    
    if ( _opacity == oldValue )
    {
        [self animationDidStop:nil finished:YES];
        return;
    }
        
    CABasicAnimation *valueAnimation = [CABasicAnimation animationWithKeyPath:nil];
    valueAnimation.delegate = self;
    valueAnimation.duration = 0.166f;
    

    valueAnimation.fromValue = [NSNumber numberWithFloat:oldValue] ; // [NSNumber numberWithFloat:_value?0.2f:1.0f];  
    valueAnimation.toValue = [NSNumber numberWithFloat:_opacity?_opacity:0.0f];
    valueAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self addAnimation:valueAnimation forKey:@"opacity"];
}


- (void)updateValueAnimated:(BOOL)animated
{
    SWShapeView *v = (SWShapeView*)_v;
    _opacity = v.layerOpacity;
    self.opacity = _opacity?_opacity:0.0f;
    
    if ( animated )
        [self _performValueAnimation];
}

- (void)updateBlinkState
{
    [self _performValueAnimation];  
}



// draw
- (void)drawInContext:(CGContextRef)context
{
    CGRect bounds = self.bounds;
    CGSize size = bounds.size;
        
    SWTranslateAndFlipCTM( context, size.height );
    
    SWShapeView *v = (SWShapeView*)_v;
    
    UIEdgeInsets insets = v.insets;
    
    CGRect inerRect = bounds;
    inerRect.origin.x -= insets.left;  // insets son negatius
    inerRect.origin.y -= insets.bottom;  // flipped
    inerRect.size.width += insets.left+insets.right;
    inerRect.size.height += insets.top+insets.bottom;
    
    
    CGFloat sOffset = v.shadowOffset;
    CGFloat sBlur = v.shadowBlur;
    UIColor *sColor = v.shadowColor;
    UIColor *tColor = v.strokeColor;
    CGFloat cornerRadius = v.cornerRadius;
    CGFloat lineWidth = v.lineWidth;
    SWShadowStyle shadowStyle = v.shadowStyle;
    
    //CGContextStrokeRect(context, rect);   // per visualitzar la mida del layer
    
    // en cas de shadow amb alpha chanel utilitzem un transparency layer
    if ( shadowStyle == SWShadowStyleAlphaChannel )
    {
        CGContextSetShadowWithColor( context, CGSizeMake(sOffset,sOffset), fabsf(sBlur), sColor.CGColor ) ;
        CGContextBeginTransparencyLayer(context, NULL);
    }
    
    // guardem el estat original per despres de les operacions clipades
    CGContextSaveGState(context);
    
    // si volem una sombra solida al exterior fem un clip per dibuixar a la part exterior
    if ( shadowStyle == SWShadowStyleOuterFill )
    {
        CGRect boundingBox = CGContextGetClipBoundingBox(context);
        CGContextAddRect( context, boundingBox);
    }
    
    // clipem la part interior (si es SWShadowStyleOuterFill l'efecte sera un clipat exterior)
    addRoundedRectPath( context, inerRect, cornerRadius, 0 );
    CGContextEOClip(context);
    
    // dibuixem la sombra en el exterior utilitzant el fill interior
    if ( shadowStyle == SWShadowStyleOuterFill )
    {
        CGContextSetShadowWithColor( context, CGSizeMake(sOffset,sOffset), sBlur, sColor.CGColor ) ;
        CGContextSetFillColorWithColor( context, sColor.CGColor ) ;
        addRoundedRectPath( context, inerRect, cornerRadius, 0 ) ;
        CGContextFillPath( context );
        
        // clipem en el interior per preparar les operacions seguents
        CGContextRestoreGState(context);  // recuperem el contexte original
        CGContextSaveGState( context );   // el tornem a guardar
        addRoundedRectPath( context, inerRect, cornerRadius, 0 );
        CGContextClip(context);
    }
    
    // dibuixem en el interior
    SWFillStyle fillStyle = v.fillStyle;
    UIColor *fillColor1 = v.fillColor1;
    switch ( fillStyle )
    {
        case SWFillStyleFlat:
            drawRectWithStyle(context, inerRect, fillColor1.CGColor, 1);
            break;
                
        case SWFillStyleSolid:
            drawSingleGradientRect( context, inerRect, fillColor1.CGColor, DrawGradientDirectionFlippedDown ) ;
            break;
                
        case SWFillStyleGradient:
        {
            SWDirection direction = v.gradientDirection;
            DrawGradientDirection gDirection;
            switch (direction)
            {
                case SWDirectionUp: gDirection = DrawGradientDirectionFlippedUp; break;
                case SWDirectionLeft: gDirection = DrawGradientDirectionLeft; break;
                case SWDirectionDown: gDirection = DrawGradientDirectionFlippedDown; break;
                case SWDirectionRight: gDirection = DrawGradientDirectionRight; break;
            }

            UIColor *fillColor2 = v.fillColor2;
            drawLinearGradientRect( context, inerRect, fillColor1.CGColor, fillColor2.CGColor, gDirection);
            break;         
        }

        case SWFillStyleImage:
            // todo
            break;
    }
    
    UIImage *image = v.image;
    
    if ( image )
    {
        UIViewContentMode contentMode = v.contentMode;
        CGSize imageSize = [image sizeWithContentMode:contentMode bounds:inerRect.size contentScale:0/*self.contentsScale*/];
    
        //NSLog( @"imageSize:%@ %@", NSStringFromCGSize(image.size), NSStringFromCGSize(imageSize) );
    
        // centrem la imatge a dins del contexte
        CGRect drawRect;
        drawRect.origin.x =  inerRect.origin.x + (inerRect.size.width - imageSize.width)/2;
        drawRect.origin.y =  inerRect.origin.y + (inerRect.size.height - imageSize.height)/2;
        drawRect.size = imageSize;
    
        CGContextDrawImage( context, drawRect, image.CGImage);
    }
    
    // dibuixem la sombra en el interior utilitzant un stroke de gruix suficient
    if ( shadowStyle == SWShadowStyleInnerFill )
    {
        CGContextSetShadowWithColor( context, CGSizeMake(sOffset,sOffset), sBlur, sColor.CGColor ) ;
        CGFloat strokeWidth = fmaxf(sBlur,sOffset*2);
        CGContextSetLineWidth(context, strokeWidth );
        CGContextSetStrokeColorWithColor( context, sColor.CGColor ) ;
        CGFloat sPathInset = -(strokeWidth/2);
        addRoundedRectPath( context, inerRect, cornerRadius, sPathInset ) ;
        CGContextStrokePath(context);
    }
    
    // dibuixem el grid
    NSInteger columns = v.gridColumns;
    if ( columns > 1 )
    {
        CGContextSetLineWidth(context, lineWidth );
        CGContextSetStrokeColorWithColor( context, tColor.CGColor ) ;
        
        CGFloat cWidth = (inerRect.size.width - inerRect.origin.x)/columns;
        for ( NSInteger i=1 ; i<columns ; i++ )
        {
            CGFloat x = inerRect.origin.x+(i*cWidth);
            CGContextMoveToPoint( context, x, inerRect.origin.y );
            CGContextAddLineToPoint( context, x, inerRect.origin.y+inerRect.size.height );
        }
        CGContextStrokePath( context );
    }
    
    NSInteger rows = v.gridRows;
    if ( rows > 1 )
    {
        CGContextSetLineWidth(context, lineWidth );
        CGContextSetStrokeColorWithColor( context, tColor.CGColor ) ;
        
        CGFloat cHeight = (inerRect.size.height - inerRect.origin.y)/rows;
        for ( NSInteger i=1 ; i<rows ; i++ )
        {
            CGFloat y = inerRect.origin.y+(i*cHeight);
            CGContextMoveToPoint( context, inerRect.origin.x, y );
            CGContextAddLineToPoint( context, inerRect.origin.x+inerRect.size.width, y );
        }
        CGContextStrokePath( context );
    }
    
    // recuperem el estat del contexte original (no clipat)
    CGContextRestoreGState( context );
    
    // dibuixem el borde
    CGContextSetLineWidth(context, lineWidth );
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    SWStrokeStyle strokeStyle = v.strokeStyle;
    if ( strokeStyle == SWStrokeStyleDash )
    {
        CGFloat phase = 0;
        const CGFloat lengths[] = { lineWidth*2, lineWidth*3 };
        CGContextSetLineDash( context, phase, lengths, sizeof(lengths)/sizeof(CGFloat));
    }
    
    CGContextSetStrokeColorWithColor( context, tColor.CGColor ) ;
    
    CGFloat sLineInset = 0;
    if ( lroundf(lineWidth)%2 != 0)
    {
        sLineInset = 0.5f;
    }
    
    addRoundedRectPath( context, inerRect, cornerRadius, sLineInset );
    CGContextStrokePath( context );
    
    // tanquem el transparency layer si n'hi havia un
    if ( shadowStyle == SWShadowStyleAlphaChannel )
    {
        CGContextEndTransparencyLayer(context);
    }
}


@end



#pragma mark SWShapeViewLayer

@interface SWShapeViewLayer : SWLayer
@end


@implementation SWShapeViewLayer
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
    SWShapeView *v = (SWShapeView*)_v;
    Class shapeBackLayerClass = [SWShapeBackLayer class];
    
    for ( CALayer *layer in self.sublayers )
    {
        CGRect rect = bounds ;
        if ( [layer isKindOfClass:shapeBackLayerClass] )
        {
            UIEdgeInsets insets = v.insets;
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




@implementation SWShapeView
{
  //  SWShapeLayer *_ledLayer ;
    SWShapeBackLayer *_backLayer ;
}

+ (Class)layerClass
{
    return [SWShapeViewLayer class] ;
}


@synthesize insets = _insets;

// general propertyes
@synthesize animated = _animated;             // yes, no

// fill properties
@synthesize fillStyle = _fillStyle;             // solid, gradient, image
@synthesize gradientDirection = _gradientDirection;     // up, down, right, left,
@synthesize fillColor1 = _fillColor1;
@synthesize fillColor2 = _fillColor2;
@synthesize fillImage = _fillImage;
@synthesize aspectRatio = _aspectRatio;

// stroke properties
@synthesize strokeStyle = _strokeStyle;           // line, dash, 
@synthesize cornerRadius = _cornerRadius;
@synthesize strokeColor = _strokeColor;
@synthesize lineWidth = _lineWidth;

// shadow properties
@synthesize shadowStyle = _shadowStyle;
@synthesize shadowOffset = _shadowOffset;
@synthesize shadowBlur = _shadowBlur;
//@synthesize shadowOpacity = _shadowOpacity;
@synthesize shadowColor = _shadowColor;

// layer properties
@synthesize layerOpacity = _layerOpacity;
@synthesize blink = _blink;


//- (void)_doInit
//{
//    SWShapeViewLayer *layer = (id)[self layer] ;
//    [layer setView:self] ;
//    
//    _backLayer = [[SWShapeBackLayer alloc] init] ;
//    [_backLayer setView:self] ;
//    [layer addSublayer:_backLayer] ;
//    
////    _ledLayer = [[SWLedLayer alloc] init] ;
////    [_ledLayer setView:self] ;
////    [layer addSublayer:_ledLayer] ;
//    
//    //_insets = UIEdgeInsetsMake( -20, -20, -20, -20 );
//    
//    
////    [_backLayer setShadowRadius:10]; 
////    [_backLayer setShadowColor:[UIColor blackColor].CGColor];
////    [_backLayer setShadowOpacity:1];
//    
//}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        SWShapeViewLayer *layer = (id)[self layer] ;
        [layer setView:self] ;
    
        _backLayer = [[SWShapeBackLayer alloc] init] ;
        [_backLayer setView:self] ;
        [layer addSublayer:_backLayer] ; 
    }
    return self;
}


//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//    if (self) 
//    {
//        [self _doInit];
//    }
//    return self;
//}

//- (CGFloat)getOuterRadius
//{
//    CGRect rect = self.bounds ;
//    CGSize size = rect.size;
//    CGFloat xRadius = (size.width-_insets.left-_insets.right)/2.0f;
//    CGFloat yRadius = (size.height-_insets.top-_insets.bottom)/2.0f;
//    CGFloat outerRadius = MIN(xRadius,yRadius);
//    return outerRadius;
//}
//
//- (CGPoint)getCenterFlipped:(BOOL)isFlipped
//{
//    CGPoint center;
//    CGSize size = self.bounds.size;
//	center.x = _insets.left + (size.width-_insets.left-_insets.right)/2.0f;;
//	center.y = _insets.bottom + (size.height-_insets.bottom-_insets.top)/2.0f;
//    if ( isFlipped ) center.y = size.height - center.y;    // compensem per y invertida en cocoa touch
//    return center;
//}


// ajustem la mida del layer a traves dels insets per donar cabuda a les sombres i el borde
- (void)_adjustInsetsIfNeeded
{
    CGFloat gap = 0;
    CGFloat offset = 0;
    switch ( _shadowStyle )
    {
        case SWShadowStyleAlphaChannel:
        case SWShadowStyleOuterFill:
            gap = _shadowBlur;
            offset = _shadowOffset;
            break;
            
        case SWShadowStyleInnerFill:
        case SWShadowStyleNone:
            gap = 0;
            offset = 0;
            break;
    }
    
    CGFloat lineGap = + ceilf(_lineWidth/2);
    CGFloat topLeftGap = gap + lineGap - offset;
    CGFloat bottomRightGap = gap + lineGap + offset;
    if ( topLeftGap < lineGap ) topLeftGap = lineGap;
    _insets.top = - topLeftGap;
    _insets.left = - topLeftGap;
    _insets.bottom = - bottomRightGap;
    _insets.right = - bottomRightGap;
}


- (void)setFillStyle:(SWFillStyle)value
{
    _fillStyle = value;
    [_backLayer setNeedsDisplay];
}

- (void)setGradientDirection:(SWDirection)value
{
    _gradientDirection = value;
    [_backLayer setNeedsDisplay];
}

- (void)setFillColor1:(UIColor*)value
{
    _fillColor1 = value;
    [_backLayer setNeedsDisplay];
}

- (void)setFillColor2:(UIColor*)value
{
    _fillColor2 = value;
    [_backLayer setNeedsDisplay];
}

- (void)setFillImage:(UIImage*)value
{
    _fillImage = value;
    [_backLayer setNeedsDisplay];
}




- (void)setAspectRatio:(SWImageAspectRatio)value
{
    _aspectRatio = value;
    [_backLayer setNeedsDisplay];
}

- (void)setStrokeStyle:(SWStrokeStyle)value
{
    _strokeStyle = value;
    [_backLayer setNeedsDisplay];
}

- (void)setCornerRadius:(double)value
{
    _cornerRadius = value;
    [_backLayer setNeedsDisplay];
}

- (void)setStrokeColor:(UIColor*)value
{
    _strokeColor = value;
    [_backLayer setNeedsDisplay];
}

- (void)setLineWidth:(double)value
{
    _lineWidth = value;
    [self _adjustInsetsIfNeeded];
    [self.layer setNeedsLayout];
    [_backLayer setNeedsDisplay];
}


- (void)setGridColumns:(NSInteger)value
{
    _gridColumns = value;
    [_backLayer setNeedsDisplay];
}

- (void)setGridRows:(NSInteger)value
{
    _gridRows = value;
    [_backLayer setNeedsDisplay];
}



- (void)setShadowStyle:(SWShadowStyle)value
{
    _shadowStyle = value;
    [self _adjustInsetsIfNeeded];
    [self.layer setNeedsLayout];
    [_backLayer setNeedsDisplay];
}

- (void)setShadowOffset:(double)value
{
    _shadowOffset = value;
    [self _adjustInsetsIfNeeded];
    [self.layer setNeedsLayout];
    [_backLayer setNeedsDisplay];
}

- (void)setShadowBlur:(double)value
{
    _shadowBlur = value;
    [self _adjustInsetsIfNeeded];
    [self.layer setNeedsLayout];
    [_backLayer setNeedsDisplay];
}

//- (void)setShadowOpacity:(double)value
//{
//    _shadowOpacity = value;
//    [_backLayer setNeedsDisplay];
//}

- (void)setShadowColor:(UIColor*)value
{
    _shadowColor = value;
    [_backLayer setNeedsDisplay];
}


#pragma mark image


- (void)setOriginalImage:(UIImage*)image
{
    _image = image;
    _original = YES;
    [_backLayer setNeedsDisplay];
}

- (void)setResizedImage:(UIImage*)image
{
    _image = image;
    _original = NO;
    [_backLayer setNeedsDisplay];
}


- (void)setContentMode:(UIViewContentMode)contentMode
{
    _contentMode = contentMode;
    [_backLayer setNeedsDisplay];
}



- (void)setLayerOpacity:(double)value animated:(BOOL)animated
{
    _layerOpacity = value;
    [_backLayer updateValueAnimated:animated];
}

- (void)setBlink:(BOOL)value
{
    _blink = value;
    [_backLayer updateValueAnimated:YES];
}


@end















