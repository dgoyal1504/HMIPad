//
//  SWScaleView.m
//  HmiPad
//
//  Created by Lluch Joan on 23/05/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "Drawing.h"
#import "SWColor.h"
//#import "SWFormatUtils.h"

#import "SWScaleView.h"
#import "SWValue.h"


#import "SWContrastedViewProtocol.h"


@interface SWScaleView()<SWContrastedViewProtocol>

@property (nonatomic, readonly) UIFont *font ;
@property (nonatomic, readonly) SWRange range ;
@property (nonatomic, readonly) UIEdgeInsets insets ;
@property (nonatomic, readonly) CGFloat extraInset;

//@property (nonatomic, readonly) UIColor *majorTicksColor ;
//@property (nonatomic, readonly) UIColor *minorTicksColor ;
@property (nonatomic, readonly) UIColor *contrastColor ;

- (CGSize)getMaxTextSizeWithAttributes:(NSDictionary*)attrs;
@end


#pragma mark SWScaleLayer

@interface SWScaleLayer : SWLayer

@property (nonatomic, assign) double rangeBeg ;
@property (nonatomic, assign) double rangeEnd ;
//@property (nonatomic, strong) UIColor *majorTicksColor ;
//@property (nonatomic, strong) UIColor *minorTicksColor ;
//@property (nonatomic, strong) UIColor *textColor ;

@end


@implementation SWScaleLayer
//
//@synthesize textColor = _textColor ;
//@synthesize majorTicksColor = _majorTicksColor ;
//@synthesize minorTicksColor = _minorTicksColor ;
@dynamic rangeBeg ;
@dynamic rangeEnd ;

+ (BOOL)needsDisplayForKey:(NSString *)key 
{
    if ( [key isEqualToString:@"rangeBeg"] || [key isEqualToString:@"rangeEnd"] )
    {
        return YES;
    }
    
    return [super needsDisplayForKey:key];
}

// tornem animacions per la propietat
-(id<CAAction>)actionForKey:(NSString *)key 
{
    //NSLog( @"key :%@", key ) ;
    
    if ( [key isEqualToString:@"rangeBeg"] || [key isEqualToString:@"rangeEnd"] )
    {
        if ( !_isAnimated ) return nil ;
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:key] ;
        animation.fromValue = [[self presentationLayer] valueForKey:key] ;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut] ;
        animation.duration = 0.3 ;
        return animation;
    }
    
    return [super actionForKey:key] ;

    
    
//    CALayer *superlayer = [self superlayer] ;
//    CAAnimation *animation = [superlayer animationForKey:key] ;
//    NSLog( @"Superlayer animation: %@", animation ) ;
//    CAAnimation *theAnimation = [animation copy] ;
//    return theAnimation ;
    
//    if ( animation ) return [super actionForKey:key] ;
//    return nil ;
    
    
//    if ( 
//        //[key isEqualToString:@"bounds"] ||
//        [key isEqualToString:@"onLayout"] ||
//        [key isEqualToString:@"contents"] ||
//        [key isEqualToString:@"position"] 
//    )
//    {
//        return [super actionForKey:key] ;
//    }
//    return nil ;

}

- (id)initWithLayer:(SWScaleLayer *)layer
{
    self = [super initWithLayer:layer] ;
    if ( self )
    {
        self.rangeEnd = layer.rangeEnd ;
        self.rangeBeg = layer.rangeBeg ;
//        _textColor = layer.textColor ;
//        _majorTicksColor = layer.majorTicksColor ;
//        _minorTicksColor = layer.minorTicksColor ;
    }
    return self ;
}

- (id)init
{
    self = [super init] ;
    if ( self )
    {
//        _textColor = [UIColor darkGrayColor] ;
//        _majorTicksColor = [UIColor darkGrayColor] ;
//        _minorTicksColor = [UIColor lightGrayColor] ;
    }
    return self ;
}


- (void)setRange:(SWRange)range animated:(BOOL)animated
{
    [self setAnimated:animated] ;
    self.rangeBeg = range.min ;
    self.rangeEnd = range.max ;
}

//// draw
//- (void)drawInContextV:(CGContextRef)context
//{
//    CGRect rect = self.bounds ;
//    CGSize size = rect.size;
//    CGFloat majorLength = 8 ;
//    CGFloat minorLength = 5 ;
//
//    SWScaleView *v = (SWScaleView*)_v ;
//    double tickInterval = v.majorTickInterval ;
//    int minorCount = v.minorTicksPerInterval ;
//    UIEdgeInsets insets = v.insets ;
//    UIFont *font = v.font ;
//    NSString *format = v.format ;
//    UIColor *contrastColor = v.contrastColor;
//    SWOrientation orientation = v.orientation ;
//    
//    if ( tickInterval <= 0 ) return ;
//
//    double rBeg = self.rangeBeg ;
//    double rEnd = self.rangeEnd ;
//    double rLen = rEnd - rBeg ;
//    
//    //if ( rLen <= 0 ) return ;
//    if ( rLen < 0 ) tickInterval = -tickInterval ;
//    
//    CGContextSaveGState( context ) ;
//    SWTranslateAndFlipCTM( context, size.height ) ;
//    
////    double tickFloor = floor(rBeg/tickInterval) ;
////    double firstTick = tickInterval * tickFloor ;
////    double lastTick = tickInterval * ceil(rEnd/tickInterval) ;
//    
//    double tickFloor = floor(rBeg/tickInterval) ;
//    double firstTick = tickInterval * tickFloor ;
//    int majorCount = ceil(rEnd/tickInterval)-tickFloor ;
//    
//    // major ticks
//    UInt8 check = 0;
//    for ( int i=0 ; i<=majorCount ; i++ )
//    {
//        double e = firstTick + (tickInterval*i) ;
//        
//        CGFloat y = SWConvertToViewPort(e, rBeg, rEnd, insets.bottom, size.height-insets.top ) ;
//        if ( y < insets.bottom || y > size.height-insets.top ) continue ;
//        
//        CGPoint pBeg, pEnd, ppBeg ;
//        if ( orientation == SWOrientationLeft )
//        {
//            pBeg = CGPointMake(size.width-insets.right, y) ;
//            pEnd = CGPointMake(size.width-insets.right-majorLength, y) ;
//        }
//        else
//        {
//            pBeg = CGPointMake(insets.left, y) ;
//            pEnd = CGPointMake(insets.left+majorLength, y) ;
//        }
//        
//        if ( check == 1 )
//        {
//            check = 2;
//            if ( (ppBeg.x-pBeg.x)*(ppBeg.x-pBeg.x) + (ppBeg.y-pBeg.y)*(ppBeg.y-pBeg.y) < 9 ) return ;
//        }
//        
//        if ( check == 0 )
//        {
//            check = 1 ;
//            ppBeg = pBeg;
//        }
//        
//        SWMoveToPoint( context, pBeg.x, pBeg.y, _isAligned) ;
//        SWAddLineToPoint( context, pEnd.x, pEnd.y, _isAligned ) ;
//    }
//
//    CGContextSetLineWidth( context, 2.0 ) ;
//    CGContextSetLineCap( context, kCGLineCapRound ) ;
//    CGContextSetStrokeColorWithColor( context, contrastColor.CGColor ) ;
//    CGContextStrokePath( context );
//    
//    // minor ticks
//    CGFloat height = size.height-insets.top-insets.bottom ;
//    CGFloat minorHeight = height * (tickInterval / rLen) ;
//  
//    for ( int i=0 ; i<majorCount ; i++ )
//    {
//        double e = firstTick + (tickInterval*i) ;
//        CGFloat y = SWConvertToViewPort(e, rBeg, rEnd, insets.bottom, size.height-insets.top ) ;
//        
//        check = 0 ;
//        for ( int j=1 ; j<minorCount ; j++ )
//        {
//            CGFloat my = y + j*(minorHeight/minorCount) ;
//            if ( my < insets.bottom || my > size.height-insets.top ) continue ;
//            
//            CGPoint pBeg, pEnd, ppBeg ;
//            if ( orientation == SWOrientationLeft )
//            {
//                pBeg = CGPointMake(size.width-insets.right, my) ;
//                pEnd = CGPointMake(size.width-insets.right-minorLength, my) ;
//            }
//            else
//            {
//                pBeg = CGPointMake(insets.left, my) ;
//                pEnd = CGPointMake(insets.left+minorLength, my) ;
//            }
//            
//            if ( check == 1 )
//            {
//                check = 2;
//                if ( (ppBeg.x-pBeg.x)*(ppBeg.x-pBeg.x) + (ppBeg.y-pBeg.y)*(ppBeg.y-pBeg.y) < 4 ) goto labels;
//            }
//        
//            if ( check == 0 )
//            {
//                check = 1 ;
//                ppBeg = pBeg;
//            }
//
//            SWMoveToPoint( context, pBeg.x, pBeg.y, _isAligned) ;
//            SWAddLineToPoint( context, pEnd.x, pEnd.y, _isAligned ) ;
//        }
//    }
//    
//    CGContextSetLineWidth( context, 1.0 ) ;
//    CGContextSetLineCap( context, kCGLineCapRound ) ;
//    CGContextSetStrokeColorWithColor( context, contrastColor.CGColor ) ;
//    CGContextStrokePath( context );
//    
//labels:
//    // labels
//    CGContextRestoreGState( context ) ;  // recuperem el estat inicial
//    UIGraphicsPushContext( context ) ;
//    
//    CGContextSetFillColorWithColor( context, contrastColor.CGColor ) ;
//    
//    CGFloat lineHeight = font.lineHeight ;
//    
//    CGFloat textSpace = SWConvertToViewPort( tickInterval, 0, rEnd-rBeg, 0, size.height-insets.top-insets.bottom) ;
//    if ( textSpace > 0 )
//    {
//        int increment = 1 + truncf( lineHeight / textSpace ) ;
//        //e = firstTick ;
//        for ( int i=0 ; i<=majorCount /*e <= lastTick*/ ; i+=increment )
//        {
//            double e = firstTick + (tickInterval*i) ;
//        
//            CGFloat y = SWConvertToViewPort(e, rBeg, rEnd, insets.bottom, size.height-insets.top ) ;
//            if ( y < insets.bottom || y > size.height-insets.top ) continue ;
//
//            y += lineHeight/2 ;  // punt de partida del texte es 1/2 punts mes amunt que la alzada de la font
//        
//            //CGPoint p ;
//            CGRect tRect ;
//            NSTextAlignment alignment ;
//            NSString *str = stringForDouble_withFormat( e, format ) ;
//            if ( orientation == SWOrientationLeft )
//            {
//                tRect.size.width = size.width-insets.right-majorLength-minorLength ;
//                tRect.origin = CGPointMake(0, size.height - y) ;
//                alignment = NSTextAlignmentRight ;
//            }
//            else
//            {
//                tRect.origin = CGPointMake(insets.left+majorLength+minorLength, size.height - y) ;
//                tRect.size.width = size.width-insets.right-tRect.origin.x ;
//                alignment = NSTextAlignmentLeft ;
//            }
//        
//            tRect.size.height = lineHeight ;
//            if ( _isAligned ) tRect.origin = SWAlignPointToDeviceSpace( context, tRect.origin ) ;
//        
//            //[str drawAtPoint:p withFont:font] ;
//            //[str drawAtPoint:p forWidth:size.width-insets.right-p.x withFont:font lineBreakMode:UILineBreakModeClip] ;
//        
//            [str drawInRect:tRect withFont:font lineBreakMode:NSLineBreakByClipping alignment:alignment] ;
//        }
//    }
//    UIGraphicsPopContext();
//
//    
//    /*
//    // border lines
//    end :
//    CGContextSetLineWidth( context, 1 ) ;
//    CGContextSetStrokeColorWithColor( context, _borderTickColor.CGColor ) ;
//    CGContextMoveToPoint( context, insets.left, insets.bottom ) ;
//    CGContextAddLineToPoint( context, size.width-insets.right, insets.bottom ) ;
//    CGContextMoveToPoint( context, insets.left, size.height-insets.top ) ;
//    CGContextAddLineToPoint( context, size.width-insets.right, size.height-insets.top ) ;
//    CGContextStrokePath( context );
//    */
//    return ;
//}




// draw
- (void)drawInContext:(CGContextRef)context
{
    CGRect rect = self.bounds ;
    CGSize size = rect.size;
    CGFloat majorLength = 8 ;
    CGFloat minorLength = 5 ;

    SWScaleView *v = (SWScaleView*)_v ;
    double tickInterval = v.majorTickInterval ;
    int minorCount = v.minorTicksPerInterval ;
    UIEdgeInsets insets = v.insets ;
    UIFont *font = v.font ;
    NSString *format = v.format ;
    UIColor *contrastColor = v.contrastColor;
    SWOrientation orientation = v.orientation ;
    
    if ( tickInterval <= 0 ) return ;

    double rBeg = self.rangeBeg ;
    double rEnd = self.rangeEnd ;
    double rLen = rEnd - rBeg ;
    
    //if ( rLen <= 0 ) return ;
    if ( rLen < 0 ) tickInterval = -tickInterval ;
    
    CGContextSaveGState( context ) ;
    SWTranslateAndFlipCTM( context, size.height ) ;
    
//    double tickFloor = floor(rBeg/tickInterval) ;
//    double firstTick = tickInterval * tickFloor ;
//    double lastTick = tickInterval * ceil(rEnd/tickInterval) ;
    
    double tickFloor = floor(rBeg/tickInterval) ;
    double firstTick = tickInterval * tickFloor ;
    int majorCount = ceil(rEnd/tickInterval)-tickFloor ;
    
    // major ticks
    UInt8 check = 0;
    for ( int i=0 ; i<=majorCount ; i++ )
    {
        double e = firstTick + (tickInterval*i) ;
        
        CGFloat x,y;
        if ( orientation == SWOrientationLeft || orientation == SWOrientationRight )
        {
            y = SWConvertToViewPort(e, rBeg, rEnd, insets.bottom, size.height-insets.top ) ;
            if ( y < insets.bottom || y > size.height-insets.top ) continue ;
        }
        
        else if ( orientation == SWOrientationBottom || orientation == SWOrientationTop )
        {
            x = SWConvertToViewPort(e, rBeg, rEnd, insets.left, size.width-insets.right ) ;
            if ( x < insets.left || x > size.width-insets.right ) continue ;
        }
        
        CGPoint pBeg, pEnd, ppBeg ;
        
        switch ( orientation )
        {
            case SWOrientationLeft:
                pBeg = CGPointMake(size.width/*-insets.right*/, y);
                pEnd = CGPointMake(size.width/*-insets.right*/-majorLength, y);
                break;
                
            case SWOrientationBottom:
                pBeg = CGPointMake(x, size.height/*-insets.top*/);
                pEnd = CGPointMake(x, size.height/*-insets.top*/-majorLength);
                break;
                
            case SWOrientationRight:
                pBeg = CGPointMake(0/*+insets.left*/, y);
                pEnd = CGPointMake(0/*insets.left*/+majorLength, y);
                break;
                
            case SWOrientationTop:
                pBeg = CGPointMake(x, 0/*+insets.bottom*/);
                pEnd = CGPointMake(x, /*insets.bottom+*/majorLength);
                break;
        }
        
        if ( check == 1 )
        {
            check = 2;
            if ( (ppBeg.x-pBeg.x)*(ppBeg.x-pBeg.x) + (ppBeg.y-pBeg.y)*(ppBeg.y-pBeg.y) < 9 ) return ;
        }
        
        if ( check == 0 )
        {
            check = 1 ;
            ppBeg = pBeg;
        }
        
        SWMoveToPoint( context, pBeg.x, pBeg.y, _isAligned) ;
        SWAddLineToPoint( context, pEnd.x, pEnd.y, _isAligned ) ;
    }

    CGContextSetLineWidth( context, 2.0 ) ;
    CGContextSetLineCap( context, kCGLineCapRound ) ;
    CGContextSetStrokeColorWithColor( context, contrastColor.CGColor ) ;
    CGContextStrokePath( context );
    
    // minor ticks
    
    CGFloat delta;
    if ( orientation == SWOrientationLeft || orientation == SWOrientationRight )
        delta = size.height-insets.top-insets.bottom ;
    else
        delta = size.width-insets.right-insets.left ;
    
    //CGFloat height = size.height-insets.top-insets.bottom ;
    //CGFloat minorHeight = height * (tickInterval / rLen) ;
    
    CGFloat minorDelta = delta * (tickInterval / rLen) ;
  
    for ( int i=0 ; i<majorCount ; i++ )
    {
        double e = firstTick + (tickInterval*i) ;
        
        CGFloat x,y;
        if ( orientation == SWOrientationLeft || orientation == SWOrientationRight )
        { 
            y = SWConvertToViewPort(e, rBeg, rEnd, insets.bottom, size.height-insets.top ) ;
        }
        
        else if ( orientation == SWOrientationBottom || orientation == SWOrientationTop )
        {
            x = SWConvertToViewPort(e, rBeg, rEnd, insets.left, size.width-insets.right ) ;
        }
        
        check = 0 ;
        for ( int j=1 ; j<minorCount ; j++ )
        {
            CGFloat mx,my;
        
            if ( orientation == SWOrientationLeft || orientation == SWOrientationRight )
            { 
                my = y + j*(minorDelta/minorCount) ;
                if ( my < insets.bottom || my > size.height-insets.top ) continue ;
            }
            
            else if ( orientation == SWOrientationBottom || orientation == SWOrientationTop )
            {
                mx = x + j*(minorDelta/minorCount) ;
                if ( mx < insets.left || mx > size.width-insets.right ) continue ;
            }
            
            CGPoint pBeg, pEnd, ppBeg ;
            
            switch ( orientation )
            {
                case SWOrientationLeft:
                    pBeg = CGPointMake(size.width/*-insets.right*/, my) ;
                    pEnd = CGPointMake(size.width/*-insets.right*/-minorLength, my) ;
                    break;
                    
                case SWOrientationBottom:
                    pBeg = CGPointMake(mx, size.height/*-insets.top*/) ;
                    pEnd = CGPointMake(mx, size.height/*-insets.top*/-minorLength) ;
                    break;
            
                case SWOrientationRight:
                    pBeg = CGPointMake(/*insets.left*/0, my) ;
                    pEnd = CGPointMake(/*insets.left+*/minorLength, my) ;
                    break;
                    
                case SWOrientationTop:
                    pBeg = CGPointMake(mx, 0/*insets.bottom*/) ;
                    pEnd = CGPointMake(mx, /*insets.bottom+*/minorLength) ;
                    break;
            }
            
            if ( check == 1 )
            {
                check = 2;
                if ( (ppBeg.x-pBeg.x)*(ppBeg.x-pBeg.x) + (ppBeg.y-pBeg.y)*(ppBeg.y-pBeg.y) < 4 ) goto labels;
            }
        
            if ( check == 0 )
            {
                check = 1 ;
                ppBeg = pBeg;
            }

            SWMoveToPoint( context, pBeg.x, pBeg.y, _isAligned) ;
            SWAddLineToPoint( context, pEnd.x, pEnd.y, _isAligned ) ;
        }
    }
    
    CGContextSetLineWidth( context, 1.0 ) ;
    CGContextSetLineCap( context, kCGLineCapRound ) ;
    CGContextSetStrokeColorWithColor( context, contrastColor.CGColor ) ;
    CGContextStrokePath( context );
    
labels:
    // labels
    CGContextRestoreGState( context ) ;  // recuperem el estat inicial
    UIGraphicsPushContext( context ) ;
    
    //CGContextSetFillColorWithColor( context, contrastColor.CGColor ) ;
    NSTextAlignment alignment ;
    if ( orientation == SWOrientationLeft ) alignment = NSTextAlignmentRight;
    else if ( orientation == SWOrientationRight ) alignment = NSTextAlignmentLeft;
    else alignment = NSTextAlignmentCenter;
    
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle alloc] init];
        textStyle.lineBreakMode = NSLineBreakByClipping;
        textStyle.alignment = alignment;
        
    NSDictionary *attrs = @{
        NSFontAttributeName:font,
        NSParagraphStyleAttributeName:textStyle,
        NSForegroundColorAttributeName:contrastColor
    };
    
    CGFloat singleSpace=0,textSpace=0;
    CGFloat lineHeight = font.lineHeight;
    
    if ( orientation == SWOrientationLeft || orientation == SWOrientationRight )
    {
        singleSpace = lineHeight;
        textSpace = SWConvertToViewPort( tickInterval, 0, rEnd-rBeg, 0, size.height-insets.top-insets.bottom) ;
    }
    
    else if ( orientation == SWOrientationBottom || orientation == SWOrientationTop )
    {
        CGSize textSize = [v getMaxTextSizeWithAttributes:attrs];
        
        singleSpace = textSize.width;
        textSpace = SWConvertToViewPort( tickInterval, 0, rEnd-rBeg, 0, size.width-insets.right-insets.left) ;
    }

    
    if ( textSpace > 0 )
    {
        int increment = 1 + truncf( singleSpace / textSpace ) ;
        //e = firstTick ;
        for ( int i=0 ; i<=majorCount /*e <= lastTick*/ ; i+=increment )
        {
            double e = firstTick + (tickInterval*i) ;
            
            CGFloat x,y;
            if ( orientation == SWOrientationLeft || orientation == SWOrientationRight )
            {
                y = SWConvertToViewPort(e, rBeg, rEnd, insets.bottom, size.height-insets.top ) ;
                if ( y < insets.bottom || y > size.height-insets.top ) continue ;

                y += singleSpace/2 ;  // punt de partida del texte es 1/2 punts mes amunt que la alzada de la font
            }
            
            else if ( orientation == SWOrientationBottom || orientation == SWOrientationTop )
            {
                x = SWConvertToViewPort(e, rBeg, rEnd, insets.left, size.width-insets.right ) ;
                if ( x < insets.left || x > size.width-insets.right ) continue ;
                
                x -= singleSpace/2 ;
            }

        
            //CGPoint p ;
            CGRect tRect ;
            //NSTextAlignment alignment ;
            NSString *str = stringForDouble_withFormat( e, format ) ;
            
            switch ( orientation )
            {
                case SWOrientationLeft:
                    tRect.size.width = size.width/*-insets.right*/-majorLength-minorLength ;
                    tRect.origin = CGPointMake(0, size.height - y) ;
                    tRect.size.height = singleSpace ;
                    //alignment = NSTextAlignmentRight ;
                    break;
                    
                case SWOrientationBottom:
                    tRect.size.width = singleSpace ;
                    tRect.origin = CGPointMake(x, size.height - (size.height - majorLength-minorLength /*- insets.top*/)) ;
                    tRect.size.height = lineHeight ;
                    //alignment = NSTextAlignmentCenter ;
                    break;
                    
                case SWOrientationRight:
                    tRect.origin = CGPointMake(/*insets.left+*/majorLength+minorLength, size.height - y) ;
                    tRect.size.width = size.width/*-insets.right*/-tRect.origin.x ;
                    tRect.size.height = singleSpace ;
                    //alignment = NSTextAlignmentLeft ;
                    break;
                    
                case SWOrientationTop:
                    tRect.size.width = singleSpace ;
                    tRect.origin = CGPointMake(x, size.height - (lineHeight+majorLength+minorLength/*+insets.bottom*/)) ;
                    tRect.size.height = lineHeight ;
                    //alignment = NSTextAlignmentCenter ;
                    break;
            }
            
            if ( _isAligned ) tRect.origin = SWAlignPointToDeviceSpace( context, tRect.origin ) ;
        
            //[str drawAtPoint:p withFont:font] ;
            //[str drawAtPoint:p forWidth:size.width-insets.right-p.x withFont:font lineBreakMode:UILineBreakModeClip] ;
        
            //[str drawInRect:tRect withFont:font lineBreakMode:NSLineBreakByClipping alignment:alignment] ;
            
            [str drawInRect:tRect withAttributes:attrs];
        }
    }
    UIGraphicsPopContext();

    
    /*
    // border lines
    end :
    CGContextSetLineWidth( context, 1 ) ;
    CGContextSetStrokeColorWithColor( context, _borderTickColor.CGColor ) ;
    CGContextMoveToPoint( context, insets.left, insets.bottom ) ;
    CGContextAddLineToPoint( context, size.width-insets.right, insets.bottom ) ;
    CGContextMoveToPoint( context, insets.left, size.height-insets.top ) ;
    CGContextAddLineToPoint( context, size.width-insets.right, size.height-insets.top ) ;
    CGContextStrokePath( context );
    */
    return ;
}















@end


#pragma mark SWScaleViewLayer

@interface SWScaleViewLayer : SWLayer
@end


@implementation SWScaleViewLayer
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
    
    SWScaleView *v = (SWScaleView*)_v;
    Class scaleLayerClass = [SWScaleLayer class];
    //CGPoint position = self.position ;
    //NSLog( @"layoutSublayers position: %g,%g", position.x, position.y ) ;
    //NSLog( @"layoutSublayers bounds: %g,%g,%g,%g", bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height ) ;
    
    for ( SWLayer *layer in self.sublayers )
    {
        CGRect rect = bounds ;
        if ( [layer isKindOfClass:scaleLayerClass] )
        {
            CGFloat extraInset = v.extraInset;
            rect.origin.x -= extraInset ;
            rect.size.width += extraInset*2 ;
        }

        layer.frame = rect ;
        [layer setNeedsLayout] ;
    }
}

@end


#pragma mark SWScaleView

@interface SWScaleView()
@end

@implementation SWScaleView
{
    SWScaleLayer *_scaleLayer ;
}

+ (Class)layerClass
{
    return [SWScaleViewLayer class] ;
}

@synthesize range = _range ;
@synthesize majorTickInterval = _majorTickInterval ;
@synthesize minorTicksPerInterval = _minorTicksPerInterval ;
@synthesize insets = _insets ;
@synthesize font = _font ;
@synthesize format = _format ;
@synthesize orientation = _orientation ;
@synthesize contrastColor = _contrastColor ;
//@synthesize majorTicksColor = _majorTicksColor ;
//@synthesize minorTicksColor = _minorTicksColor ;

- (void)_doInit
{
    SWScaleViewLayer *layer = (id)[self layer] ;
    [layer setView:self] ;
    
    _scaleLayer = [[SWScaleLayer alloc] init] ;
    [_scaleLayer setView:self] ;
   // [_scaleLayer setContentsGravity:kCAGravityResize] ;
    [layer addSublayer:_scaleLayer] ;
    
    _font = [UIFont boldSystemFontOfSize:13];
    _format = @"";
    _orientation = SWOrientationLeft ;

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


//- (CGSize)getMaxTextSize
//{
//    NSString *str1 = stringForDouble_withFormat( _range.min, _format ) ;
//    CGSize textSize1 = [str1 sizeWithFont:_font] ;
//    
//    NSString *str2 = stringForDouble_withFormat( _range.max, _format ) ;
//    CGSize textSize2 = [str2 sizeWithFont:_font] ;
//        
//    CGSize textSize = textSize1;
//    if ( textSize2.width > textSize1.width ) textSize = textSize2;
//
//    return textSize;
//}

- (CGSize)getMaxTextSizeWithAttributes:(NSDictionary*)attrs
{
    double tickInterval = _majorTickInterval;
    
    double tickFloor = floor(_range.min/tickInterval);
    double firstTick = tickInterval * tickFloor;
    
    double tickCeil = ceil(_range.max/tickInterval);
    double lastTick = tickCeil * tickInterval;

    NSString *str1 = stringForDouble_withFormat( firstTick, _format ) ;
    //CGSize textSize1 = [str1 sizeWithFont:_font] ;
    CGSize textSize1 = [str1 sizeWithAttributes:attrs/*@{NSFontAttributeName:_font}*/] ;
    textSize1.width = ceil(textSize1.width);
    textSize1.height = ceil(textSize1.height);
    
    NSString *str2 = stringForDouble_withFormat( lastTick, _format ) ;
    //CGSize textSize2 = [str2 sizeWithFont:_font] ;
    CGSize textSize2 = [str2 sizeWithAttributes:attrs/*@{NSFontAttributeName:_font}*/] ;
    textSize2.width = ceil(textSize2.width);
    textSize2.height = ceil(textSize2.height);
    
    CGSize textSize = textSize1;
    if ( textSize2.width > textSize1.width ) textSize = textSize2;

    return textSize;
}


- (void)_adjustInsetsIfNeeded
{
    if ( _orientation == SWOrientationLeft || _orientation == SWOrientationRight )
    {
        _extraInset = 0;
        _insets = UIEdgeInsetsMake( 8, 8, 24, 8 ) ;
    }
    else
    {
        CGSize textSize = [self getMaxTextSizeWithAttributes:@{NSFontAttributeName:_font}];
//        textSize.width = ceil(textSize.width);
//        textSize.height = ceil(textSize.height);
        _extraInset = textSize.width;
        _insets = UIEdgeInsetsMake( 8, 8+_extraInset, 24, 8+_extraInset ) ;
    }
}




//- (void)setInsets:(UIEdgeInsets)insets
//{
//    _insets = insets ;
//    SWScaleViewLayer *layer = (id)[self layer] ;
//    [layer setNeedsLayout] ;
//    [_scaleLayer setNeedsDisplay] ;
//}



- (void)setRange:(SWRange)range animated:(BOOL)animated
{
    _range = range ;
    [self _adjustInsetsIfNeeded];
    [self.layer setNeedsLayout];
    [_scaleLayer setRange:range animated:animated] ;
}

- (void)setMajorTickInterval:(double)majorTickInterval
{
    _majorTickInterval = majorTickInterval ;
    [self _adjustInsetsIfNeeded];
    [self.layer setNeedsLayout];
    [_scaleLayer setNeedsDisplay] ;
}

- (void)setMinorTicksPerInterval:(int)minorTicksPerInterval
{
    _minorTicksPerInterval = minorTicksPerInterval ;
    [_scaleLayer setNeedsDisplay] ;
}

- (void)setFormat:(NSString *)format
{
    _format = format ;
    [self _adjustInsetsIfNeeded];
    [self.layer setNeedsLayout];
    [_scaleLayer setNeedsDisplay] ;
}

- (void)setOrientation:(SWOrientation)value
{
    _orientation = value ;
    [self _adjustInsetsIfNeeded];
    [self.layer setNeedsLayout];
    [_scaleLayer setNeedsDisplay] ;
}

- (void)setContrastForBackgroundColor:(UIColor *)color
{
    _contrastColor = contrastColorForUIColor( color ) ;
    [_scaleLayer setNeedsDisplay] ;
}

- (void)setBackgroundColor:(UIColor *)color
{
    [super setBackgroundColor:color] ;
    [self setContrastForBackgroundColor:color];
}

//- (void)setBackgroundColor:(UIColor *)color
//{
//    [super setBackgroundColor:color] ;
//    _contrastColor = contrastColorForUIColor( color ) ;
//    [_scaleLayer setNeedsDisplay] ;
//}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame] ;
    //[self.layer layoutSublayers] ;
}

- (void)layoutSubviews
{
    //CGRect rect = [self frame] ;
    //NSLog( @"layoutSubviews: %g,%g,%g,%g", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height ) ;
    [super layoutSubviews] ;
}

- (void)drawRect:(CGRect)rec
{
    //CGRect rect = [self frame] ;
    //NSLog( @"drawRect: %g,%g,%g,%g", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height ) ;
    [super drawRect:rec] ;
}

@end
