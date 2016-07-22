//
//  SWTrendView.m
//  HmiPad
//
//  Created by Joan on 29/04/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "Drawing.h"
#import "SWColor.h"

#import "SWTrendView.h"
#import "SWLayer.h"
#import "SWValue.h"

#import "SWContrastedViewProtocol.h"


//static CFStringRef DateFormatterString0 = CFSTR("HH:mm:ss") ;
//static CFStringRef DateFormatterString1 = CFSTR("yyyy-MM-dd HH:mm:ss ZZ") ;
//static CFStringRef DateFormatterString2 = CFSTR("yy-MM-dd HH:mm:ss") ;
//static CFStringRef DateFormatterString3 = CFSTR("yy-MM-dd HH:mm") ;

@interface SWTrendView()<SWContrastedViewProtocol>

@property (nonatomic, readonly) UIEdgeInsets insets ;
@property (nonatomic, readonly) CFDateFormatterRef dateFormatter ;
//@property (nonatomic, readonly) SWPlotRange xAxisRange ;
@property (nonatomic, readonly) SWBounds yAxisRange ;
@property (nonatomic, readonly) UIFont *font ;
@property (nonatomic, readonly) UIColor *majorTickColor ;
@property (nonatomic, readonly) UIColor *minorTickColor ;
//@property (nonatomic, readonly) UIColor *textColor ;
@property (nonatomic, readonly) UIColor *contrastColor ;
@property (nonatomic, readonly) CFTimeInterval xOffset;
@property (nonatomic, readonly) BOOL xReversed;
@property (nonatomic, readonly) BOOL isTimeChart;
//- (CGSize)getMaxTextSizeWithAttributes:(NSDictionary*)attrs format:(NSString*)format;
- (CFStringRef)dateFormatterString;

@end


@interface SWTrendView()<UIGestureRecognizerDelegate>
{
    UIPinchGestureRecognizer *_pinchGesture;
    UIPanGestureRecognizer *_panGesture;
    UITapGestureRecognizer *_tapGesture;
    SWPlotRange _initialPinchRange;
    SWPlotRange _initialPanRange;
    double _currentPanDisplacement;
    BOOL _pinchBegan;
    BOOL _panBegan;
}
@end


#pragma mark SWBaseRangedTrendLayer

@interface SWBaseRangedTrendLayer : SWLayer

@property (nonatomic, assign) double xRangeLength ;
@property (nonatomic, assign) double xRangeEnd ;
@property (nonatomic, assign) double yRangeBeg ;
@property (nonatomic, assign) double yRangeEnd ;
@property (nonatomic, weak) id animationDelegate;

@end 


@implementation SWBaseRangedTrendLayer

@dynamic xRangeLength ;
@dynamic xRangeEnd ;
@dynamic yRangeBeg ;
@dynamic yRangeEnd ;

+ (BOOL)needsDisplayForKey:(NSString *)key 
{
    if ( [key isEqualToString:@"xRangeLength"] || [key isEqualToString:@"xRangeEnd"] ||
            [key isEqualToString:@"yRangeBeg"] || [key isEqualToString:@"yRangeEnd"] )
    {
        return YES;
    }

    return [super needsDisplayForKey:key];
}




// tornem animacions per la propietat
-(id<CAAction>)actionForKey:(NSString *)key 
{
    // TO DO - Ajustar la duracio de la animacio en funcio de _xLength
    
    BOOL isTimeChart = [(SWTrendView*)_v isTimeChart];
    BOOL isXOffsetZero = [(SWTrendView*)_v xOffset] <= 0;
    if ( [key isEqualToString:@"xRangeEnd"] /*|| [key isEqualToString:@"xRangeLength"]*/)
    {
        if ( !_isAnimated ) return nil ;
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:key] ;
        //animation.delegate = self ;
        animation.delegate = _animationDelegate ;
        animation.fromValue = [[self presentationLayer] valueForKey:key] ;
        NSString *timingFunction = isTimeChart&&isXOffsetZero?kCAMediaTimingFunctionLinear:kCAMediaTimingFunctionEaseOut;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:timingFunction];
        animation.duration = isTimeChart?1.0:0.5 ;
        return animation;
    }
    
    if ( [key isEqualToString:@"xRangeLength"] ||
            [key isEqualToString:@"yRangeBeg"] || [key isEqualToString:@"yRangeEnd"] )
    {
        if ( !_isAnimated ) return nil ;
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:key] ;
        //animation.delegate = self ;
        animation.fromValue = [[self presentationLayer] valueForKey:key] ;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut] ;
        animation.duration = 0.5 ;
        return animation;
    }
    
    return [super actionForKey:key] ;
}

- (id)initWithLayer:(SWBaseRangedTrendLayer *)layer
{
    self = [super initWithLayer:layer] ;
    if ( self )
    {
        self.xRangeLength = layer.xRangeLength ;
        self.xRangeEnd = layer.xRangeEnd ;
        self.yRangeBeg = layer.yRangeBeg ;
        self.yRangeEnd = layer.yRangeEnd ;
        _isAligned = NO ;
    }
    return self ;
}

- (id)init
{
    self = [super init] ;
    if ( self )
    {
    }
    return self ;
}



@end



#pragma mark SWValuesAnimation

@interface SWValuesAnimation : CABasicAnimation
@property (nonatomic) NSData *fromValues;
@end

@implementation SWValuesAnimation

@synthesize fromValues = _fromValues;
//@synthesize toValues = _toValues;

+ (SWValuesAnimation*)animationWithKeyPath:(NSString*)keyPath
{
    SWValuesAnimation *anim = [[SWValuesAnimation alloc] init];
    
    [anim setKeyPath:keyPath];
    return anim;
}

- (id)copyWithZone:(NSZone *)zone
{
    SWValuesAnimation *newAnimation = [super copyWithZone:zone];
    newAnimation->_fromValues = _fromValues;
    return newAnimation;
}


@end


#pragma mark SWPlotLayer

@interface SWPlotLayer : SWBaseRangedTrendLayer

@property (nonatomic, strong) id identifier ;
//@property (nonatomic, weak) id<SWTrendViewDataSource> dataSource;
@property (nonatomic, strong) NSData *plotValues ;
@property (nonatomic, strong) NSMutableData *presentationValues;
@property (nonatomic, strong) UIColor *color ;
@property (nonatomic, strong) UIColor *colorFill ;
@property (nonatomic, assign) BOOL symbol;
@property (nonatomic, assign) BOOL xReversed;
@property (nonatomic, assign) BOOL typeBar;
@property (nonatomic, assign) int barIndex;
@property (nonatomic, assign) int barCount;

@end


@implementation SWPlotLayer

@synthesize identifier = _identifier ;
//@synthesize dataSource = _dataSource ;
@synthesize color = _color ;
@synthesize colorFill = _colorFill;
@synthesize symbol = _symbol;
@synthesize presentationValues = _presentationValues;

@dynamic plotValues;

- (id)initWithIdentifier:(id)identifier 
{
    self = [super init] ;
    if ( self )
    {
        _identifier = identifier ;
    }
    return self ;
}


+ (BOOL)needsDisplayForKey:(NSString *)key 
{
    if ( [key isEqualToString:@"plotValues"] )
    {
        return YES;
    }

    return [super needsDisplayForKey:key];
}



// tornem animacions per la propietat
-(id<CAAction>)actionForKey:(NSString *)key 
{
    if ( [key isEqualToString:@"plotValues"] )
    {
        if ( !_isAnimated || [(SWTrendView*)_v isTimeChart] )
        {
//            SWPlotLayer *modelLayer = [self modelLayer];
//            _presentationValues = [modelLayer.plotValues copy];
            return nil;
        }
        
        SWValuesAnimation *animation = [SWValuesAnimation animationWithKeyPath:key] ;
        //animation.delegate = self ;
        
        SWPlotLayer *modelLayer = [self modelLayer];
        NSData *presentationValues = modelLayer.presentationValues;
        if ( presentationValues == nil )
            presentationValues = modelLayer.plotValues;
        animation.fromValues = [presentationValues copy];  // valors inicials copy!

        animation.fromValue = @(0) ;
        animation.toValue = @(1) ;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut] ;
        animation.duration = 0.5 ;
        return animation;
    }
    
    return [super actionForKey:key] ;
}

//- (void)animationDidStart:(CAAnimation *)anim
//{
//    NSLog(@"animation did start");
//}
//
//- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)finished
//{
//////    CAAnimation *progressAnim = [self animationForKey:@"valuesProgress"];
//////    if ( anim == progressAnim )
//////        _valuesProgress = 0;
//
//    if ( finished )
//        return;
//    
//    CAPropertyAnimation *propertyAnim = (id)anim;
//    if ( [propertyAnim.keyPath isEqualToString:@"valuesProgress"] )
//    {
//        SWPlotLayer *modelLayer = [self modelLayer];
//        NSData *plotValues = [modelLayer plotValues];
//    
//        double progress = 1;
//        NSNumber *progress_n = (id)self.plotValues;
//        if ( [progress_n isKindOfClass:[NSNumber class]] )
//            progress = progress_n.doubleValue;
//        
//        
//        SWPlotPoint fromPlotPoint = SWPlotPointMake(0, 0);
//        if ( plotValues)
//        {
//            fromPlotPoint = *(SWPlotPoint*)[plotValues bytes];
//        }
//    
//        NSLog( @"Hola");
//        NSLog( @"From: %0.2f, Progress:%0.2f", fromPlotPoint.y, progress );
//    }
//}


// inicialitzador utilitzat per el presentationLayer al fer les animacions
- (id)initWithLayer:(SWPlotLayer *)layer
{
    self = [super initWithLayer:layer] ;
    if ( self )
    {
        _identifier = layer.identifier ;
        //_dataSource = layer.dataSource ;
        self.plotValues = layer.plotValues ;
        _presentationValues = layer.presentationValues;
        _color = layer.color ;
        _colorFill = layer.colorFill;
        _symbol = layer.symbol;
        _xReversed = layer.xReversed;
        _typeBar = layer.typeBar;
        _barIndex = layer.barIndex;
        _barCount = layer.barCount;
    }
    return self ;
}


//- (void)setXRangeVV:(SWPlotRange)range reversed:(BOOL)reversed animated:(BOOL)animated
//{
//    [self setAnimated:animated] ;
//    
//    SWPlotRange valuesRange = range ;
//    if ( animated )
//    {
//        SWPlotRange currentRange ;
//        currentRange.max = self.xRangeEnd ;
//        currentRange.min = currentRange.max - self.xRangeLength ;
//        if ( currentRange.min < range.min ) valuesRange.min = currentRange.min ;
//        if ( currentRange.max > range.max ) valuesRange.max = currentRange.max ;
//    }
//    
//    NSData *plotValues = [self _getValuesForRange:valuesRange];
//    
//    _xReversed = reversed;
//    self.xRangeLength = range.max-range.min;
//    self.xRangeEnd = range.max;
//    self.plotValues = plotValues;
//}


- (void)setXRange:(SWPlotRange)range withPlotValues:(NSData*)plotValues reversed:(BOOL)reversed animated:(BOOL)animated
{
    [self setAnimated:animated] ;
    
    _xReversed = reversed;
    self.xRangeLength = range.max-range.min;
    self.xRangeEnd = range.max;
    self.plotValues = plotValues;
    
//    {
//        NSData *plotValuesx = plotValues;
//        int countx = [plotValuesx length]/sizeof(SWPlotPoint);
//        SWPlotPoint *points = (SWPlotPoint*)[plotValuesx bytes];
//        if ( countx > 0)
//        NSLog( @"set x range: %@", [NSDate dateWithTimeIntervalSinceReferenceDate:points[countx-1].x] );
//    }
    [self setNeedsDisplay];
}



- (void)setYRange:(SWBounds)range animated:(BOOL)animated
{
    [self setAnimated:animated] ;
    self.yRangeBeg = range.min ;
    self.yRangeEnd = range.max ;
}


//- (void)reloadData
//{
//    [self reloadDataAnimated:NO];
//}
//
//
//- (void)reloadDataAnimated:(BOOL)animated
//{
//    [self setAnimated:animated];
//    SWPlotRange range ;
//    range.max = self.xRangeEnd ;
//    range.min = range.max - self.xRangeLength ;
//    NSData *plotValues = [self _getValuesForRange:range];
//    self.plotValues = plotValues;
//}



- (void)reloadWithPlotValues:(NSData*)plotValues animated:(BOOL)animated
{
    [self setAnimated:animated];
    self.plotValues = plotValues;
//    {
//        NSData *plotValuesx = plotValues;
//        int countx = [plotValuesx length]/sizeof(SWPlotPoint);
//        SWPlotPoint *points = (SWPlotPoint*)[plotValuesx bytes];
//        if ( countx > 0)
//        NSLog( @"reload with: %@", [NSDate dateWithTimeIntervalSinceReferenceDate:points[countx-1].x] );
//    }
}




// draw
- (void)drawInContext:(CGContextRef)context
{

    CGRect rect = self.bounds ;
    CGSize size = rect.size;
    
    SWTrendView *v = (SWTrendView*)_v ;
    UIEdgeInsets insets0 = v.insets ;
    UIEdgeInsets insets = insets0 ;
    
    SWTranslateAndFlipCTM(context, size.height) ;
    
    double tickInterval = v.xMajorTickInterval ;
    double xLen = self.xRangeLength;
    double xEnd = self.xRangeEnd ;
    double xBeg = xEnd - xLen ;
    
    BOOL isTimeChart = v.isTimeChart;
    //BOOL isOffsetZero = (v.xOffset<=0);
    
    if ( _xReversed )
    {
        xLen = -xLen;
        xBeg = xEnd;
        xEnd = xEnd + xLen;
    }

    CGRect clipRect = CGRectMake(insets0.left, insets0.bottom, size.width-insets0.right-insets0.left, size.height-insets0.top-insets0.bottom);
    CGContextClipToRect(context, clipRect);
    
    if ( !isTimeChart )
    {
        double xPadding = tickInterval/2;
        CGFloat width = size.width-insets0.right-insets0.left;
        CGFloat viewPadd = SWConvertToViewPort(xPadding, 0, xEnd+tickInterval-xBeg, 0, width);
        insets.left += viewPadd;
        insets.right += viewPadd;
    }
    
    double yEnd = self.yRangeEnd ;
    double yBeg = self.yRangeBeg ;
    
    NSData *presentationValues = [self _computePresentationValues];
    
    NSInteger count = presentationValues.length/sizeof(SWPlotPoint);
    const SWPlotPoint *pValues = [presentationValues bytes];
    
    CGPoint p = CGPointZero;
    //NSLog( @"count :%d", count);
    SWPlotPoint e = SWPlotPointMake(0,0);
    
    if ( _typeBar )
    {
        const CGFloat IW = 0.8;
        const CGFloat BW = 0.9;
    
        CGFloat yMed = SWConvertToViewPort(0, yBeg, yEnd, insets.bottom, size.height-insets.top) ;
        CGFloat xIntervalWidth = IW*SWConvertToViewPort(tickInterval, 0, xEnd+tickInterval-xBeg, 0, size.width-insets0.right-insets0.left);
        CGFloat xWidth = xIntervalWidth/_barCount;
        
        if ( count > 0 )
        {
            CGContextSetLineWidth(context, xWidth*BW );
            //CGContextSetLineCap( context, kCGLineCapRound ) ;
            //CGContextSetLineJoin( context, kCGLineJoinRound ) ;
            CGContextSetStrokeColorWithColor( context, _color.CGColor ) ;
        }
        
        for ( int i=0 ; i<count ; i++ )
        {
            e = pValues[i];
        
            p.x = SWConvertToViewPort(e.x, xBeg, xEnd, insets.left, size.width-insets.right ) ;
            p.y = SWConvertToViewPort(e.y, yBeg, yEnd, insets.bottom, size.height-insets.top) ;
            
            CGFloat xOffs = _barIndex*xWidth - xIntervalWidth/2 + xWidth/2;
            
//            NSLog( @"plotIndex: %d", _barIndex);
//            NSLog( @"xoffs: %g", xOffs);
//            NSLog( @"xWidth: %g", xWidth);
//            NSLog( @"xIntervalWidth: %g", xIntervalWidth);
//            NSLog( @"----");
            
            CGContextMoveToPoint( context, p.x+xOffs, yMed );
            CGContextAddLineToPoint( context, p.x+xOffs, p.y );
        }
    
    
        CGContextStrokePath( context );
    
        return;
    }
    
    
    
    CGMutablePathRef path = CGPathCreateMutable();
    if ( _colorFill )
    {
        CGContextSaveGState(context);
    }
    
    for ( int i=0 ; i<count ; i++ )
    {
        //SWPlotPoint
        e = pValues[i];
        
        p.x = SWConvertToViewPort(e.x, xBeg, xEnd, insets.left, size.width-insets.right ) ;
        p.y = SWConvertToViewPort(e.y, yBeg, yEnd, insets.bottom, size.height-insets.top) ;
    
        //if ( _isAligned ) p = SWAlignPointToDeviceSpace( context, p ) ;  // <- torna NaN i peta mes endevant quan p es inf
        if ( i==0 ) CGPathMoveToPoint( path, NULL, p.x, p.y );
        else CGPathAddLineToPoint( path, NULL, p.x, p.y );
    }
    

    // afegim si cal una linea fins el final
    if ( isTimeChart  )
    {
        double xRangeEnd = self.xRangeEnd;  // <-- pot ser _xReversed per tant agafem directament el original
        if ( count>0 && pValues[count-1].x<xRangeEnd)
        {
            e.x = xRangeEnd+v.xOffset;
            p.x = SWConvertToViewPort(e.x, xBeg, xEnd, insets.left, size.width-insets.right ) ;
            CGPathAddLineToPoint( path, NULL, p.x, p.y );
        }
    }
    
    // dibuixem si cal un gradient a sota de la linea
    //if ( _colorFill && count>1 )

    if ( _colorFill && count>0 )
    {
        CGContextAddPath(context, path);

        CGFloat x;
        //SWPlotPoint e;
        //e = pValues[count-1];
        x = SWConvertToViewPort(e.x, xBeg, xEnd, insets.left, size.width-insets.right ) ;
        CGContextAddLineToPoint( context, x, 0 );
    
        x = SWConvertToViewPort(pValues[0].x, xBeg, xEnd, insets.left, size.width-insets.right ) ;
        CGContextAddLineToPoint( context, x, 0 );
    
        CGContextClip(context);
        
        UInt32 rgb = rgbColorForUIcolor(_colorFill);
    
        CGFloat colors[] =
        {
            ColorR(rgb), ColorG(rgb), ColorB(rgb), ColorA(rgb),
            ColorR(rgb), ColorG(rgb), ColorB(rgb), 0.0f,
        };
        
        CGColorSpaceRef rgbSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColorComponents(rgbSpace, colors, NULL, 2);
        
        //CGContextEOFillPath(context);
        CGContextDrawLinearGradient(context, gradient, CGPointMake(0,size.height), CGPointZero, 0);
    
        CGGradientRelease(gradient);
        CGColorSpaceRelease(rgbSpace);
        
        CGContextRestoreGState(context);
    }
    
    // dibuixem la linea
    CGContextSetLineWidth( context, 2 ) ;
    CGContextSetLineCap( context, kCGLineCapRound ) ;
    CGContextSetLineJoin( context, kCGLineJoinRound ) ;
    CGContextSetStrokeColorWithColor( context, _color.CGColor ) ;
    
    CGContextAddPath(context, path);
    CGContextStrokePath( context );
    
    CGPathRelease(path);
    
    // dibuixem una linea de final si cal
    if ( isTimeChart && v.xOffset < 0 )
    {
        CGFloat x = SWConvertToViewPort( e.x, xBeg, xEnd, insets.left, size.width-insets.right ) ;
        SWMoveToPoint( context, x, insets.bottom, _isAligned ) ;
        SWAddLineToPoint( context, x, size.height-insets.top, _isAligned ) ;
        
        double xx = x + (_xReversed?-2:2);
        SWMoveToPoint( context, xx, insets.bottom, _isAligned ) ;
        SWAddLineToPoint( context, xx, size.height-insets.top, _isAligned ) ;
        
        CGContextSetStrokeColorWithColor( context, [v.majorTickColor CGColor] ) ;
        CGContextSetLineWidth( context, 1);
        CGContextStrokePath( context );
    }
    
    // dibuixem si cal rodonetes en els punts
    if ( _symbol )
    {
        CGContextSetFillColorWithColor( context, [UIColor whiteColor].CGColor );
        for ( int i=0 ; i<count ; i++ )
        {
           // CGPoint p ;
           // SWPlotPoint
            SWPlotPoint ee = pValues[i];
            
            p.x = SWConvertToViewPort(ee.x, xBeg, xEnd, insets.left, size.width-insets.right ) ;
            p.y = SWConvertToViewPort(ee.y, yBeg, yEnd, insets.bottom, size.height-insets.top) ;
        
            if ( p.x < 0 || p.x > size.width || p.y < 0 || p.y > size.height )
                continue;   // cercles dibuixats en el infinit congelen la app, evitem dibuixarlos
        
            CGRect circleRect = CGRectMake( p.x-4, p.y-4, 8, 8);
            CGContextFillEllipseInRect(context, circleRect);
            //CGContextAddEllipseInRect(context, circleRect);
            CGContextStrokeEllipseInRect(context, circleRect);
        }
    }
}


- (NSData *)_computePresentationValues
{
    SWPlotLayer *modelLayer = self.modelLayer;
    NSData *toValues = modelLayer.plotValues;
    
    SWTrendView *v = (SWTrendView*)_v ;
    if ( v.isTimeChart )
    {
        return toValues;
    }

    double progress = 1;
    NSNumber *progress_n = (id)self.plotValues;
    if ( [progress_n isKindOfClass:[NSNumber class]] )
        progress = progress_n.doubleValue;
    
    SWValuesAnimation *animation = (id)[self.presentationLayer animationForKey:@"plotValues"];
    NSData *fromValues = animation.fromValues;
    
//    {
//        SWPlotPoint fromPlotPoint = SWPlotPointMake(0, 0);
//        SWPlotPoint toPlotPoint = SWPlotPointMake(0, 0);
//        if ( fromValues)
//            fromPlotPoint = *(SWPlotPoint*)[fromValues bytes];
//    
//        if ( toValues )
//            toPlotPoint = *(SWPlotPoint*)[toValues bytes];
//    
//        NSLog( @"Beg: %0.2f, End:%0.2f, IniProgress:%0.2f, EndProgress:%0.2f",
//            fromPlotPoint.y, toPlotPoint.y, 0.0, progress );
//    }
    
    NSInteger fromCount = fromValues.length/sizeof(SWPlotPoint);
    NSInteger toCount = toValues.length/sizeof(SWPlotPoint) ;
    
    const SWPlotPoint *pFromValues = [fromValues bytes];
    const SWPlotPoint *pToValues = [toValues bytes];
    
    NSInteger count = MAX(fromCount,toCount);
    
    NSMutableData *presentationValues = modelLayer.presentationValues;
    if ( presentationValues == nil ) presentationValues = [NSMutableData data], modelLayer.presentationValues = presentationValues;
    if ( presentationValues.length != count*sizeof(SWPlotPoint) ) [presentationValues setLength:count*sizeof(SWPlotPoint)];
    
    //self.presentationValues = presentationValues;
    
    SWPlotPoint *pPresentationValues = [presentationValues mutableBytes];
    
    for ( NSInteger i=0 ; i<count ; i++ )
    {
        //SWPlotPoint e = ( i<toCount ? pToValues[i] : SWPlotPointMake(i, 0) );
        SWPlotPoint e = ( i<toCount ? pToValues[i] : SWPlotPointMake(pFromValues[i].x, 0) );
        double y0 = ( i<fromCount ? pFromValues[i].y : 0);
        
        e.y = progress*e.y + (1-progress)*y0;
        
        pPresentationValues[i] = e;
    }
    
    return presentationValues;
}



//- (NSData*)_getValuesForRange:(SWPlotRange)range
//{
//    SWPlotRange dataRange = range ;
//    dataRange.min -= 0.5 ;// periode de mostreix
//    
//    NSData *sourceValues = [_dataSource pointsForPlotWithIdentifier:_identifier inRange:dataRange] ;
//    int count = sourceValues.length/sizeof(SWPlotPoint) ;
//    
//    NSMutableData *values = [NSMutableData dataWithLength:(count+1)*sizeof(SWPlotPoint)] ;
//    
//    if ( [(SWTrendView*)_v isTimeChart] )
//    {
//        values = [NSMutableData dataWithLength:(count+1)*sizeof(SWPlotPoint)] ;
//        SWPlotPoint *points = [values mutableBytes] ;
//        memcpy( points, [sourceValues bytes], count*sizeof(SWPlotPoint) ) ;
//        points[count].x = CFAbsoluteTimeGetCurrent() ;
//        points[count].y = points[count-1].y ;
//    }
//    else
//    {
//        values = [NSMutableData dataWithLength:count*sizeof(SWPlotPoint)] ;
//        SWPlotPoint *points = [values mutableBytes] ;
//        memcpy( points, [sourceValues bytes], count*sizeof(SWPlotPoint) ) ;
//    }
//    
//    return values;
//}

@end




#pragma mark SWXAxisLayer

@interface SWXAxisLayer : SWBaseRangedTrendLayer
@end


@implementation SWXAxisLayer


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
- (id)initWithLayer:(SWLayer *)layer
{
    self = [super initWithLayer:layer] ;
    if ( self )
    {
    }
    return self ;
}


- (void)setRange:(SWPlotRange)range animated:(BOOL)animated
{
    [self setAnimated:animated] ;
    self.xRangeLength = range.max-range.min ;
    self.xRangeEnd = range.max ;
}


// draw
- (void)drawInContext:(CGContextRef)context
{
    CGRect rect = self.bounds ;
    CGSize size = rect.size;

    SWTrendView *v = (SWTrendView*)_v ;
    BOOL isTimeChart = v.isTimeChart;
    SWChartType chartType = v.chartType;
    BOOL hasDisplacement = (chartType == SWChartTypeBar || chartType == SWChartTypeMixed);
    
    UIColor *majorTicksColor = v.majorTickColor ;
    UIColor *minorTicksColor = v.minorTickColor ;
    UIColor *textColor = v.contrastColor ;
    double tickInterval = v.xMajorTickInterval ;
    int minorCount = v.xMinorTicksPerInterval ;
    UIEdgeInsets insets0 = v.insets ;
    UIEdgeInsets insets = insets0 ;
    
    double xLen = self.xRangeLength ;
    double xEnd = self.xRangeEnd ;
    double xBeg = xEnd - xLen ;
    
    if ( v.xReversed )
    {
        xLen = -xLen;
        xBeg = xEnd;
        xEnd = xEnd + xLen;
    }
    
    if ( tickInterval <= 0 ) return ;    
    if ( xLen < 0 ) tickInterval = -tickInterval ;
    
    if ( !isTimeChart )
    {
        double xPadding = tickInterval/2;
        CGFloat width = size.width-insets0.right-insets0.left;
        CGFloat viewPadd = SWConvertToViewPort(xPadding, 0, xEnd+tickInterval-xBeg, 0, width);
        insets.left += viewPadd;
        insets.right += viewPadd;
        //NSLog( @"viewPadd %g", viewPadd);
    }
    
    double firstTick = 0;
    int majorCount = 0;
    
//    if ( isTimeChart /*|| normalizedIntervals*/ )
//    {
//        double tickFloor = floor((xBeg-xPadding)/tickInterval) ;
//        firstTick = tickInterval * tickFloor ;
//        majorCount = ceil((xEnd+xPadding)/tickInterval)-tickFloor ;
//    }
//    else
//    {
//        firstTick = xBeg;
//        majorCount = ceil((xEnd-xBeg)/tickInterval);
//    }
    
    if ( isTimeChart /*|| normalizedIntervals*/ )
    {
        double tickFloor = floor(xBeg/tickInterval) ;
        firstTick = tickInterval * tickFloor ;
        majorCount = ceil(xEnd/tickInterval)-tickFloor ;
    }
    else
    {
        firstTick = xBeg;
        majorCount = ceil((xEnd-xBeg)/tickInterval);
    }
    
    double firstTickD = firstTick;
    int majorCountD = majorCount;
    if ( hasDisplacement )
    {
        firstTickD -= tickInterval/2;
        majorCountD += 1;
    }
    
    CGContextSaveGState( context ) ;
    SWTranslateAndFlipCTM(context, size.height) ;
    
// major ticks
    
    UInt8 check = 0;
    CGFloat xx = 0;
    for ( int i=0 ; i<=majorCountD /*e <= lastTick*/ ; i++ )
    {
        double e = firstTickD + (tickInterval*i) ;
        
        CGFloat x;
        x = SWConvertToViewPort(e, xBeg, xEnd, insets.left, size.width-insets.right ) ;
        if ( x < insets0.left || x > size.width-insets0.right ) continue ;
        
        if ( check == 1 )
        {
            check = 2;
            if ( (xx-x)*(xx-x) < 9 ) return ;
        }
        
        if ( check == 0 )
        {
            check = 1 ;
            xx = x;
        }
        
        SWMoveToPoint( context, x, insets.bottom, _isAligned ) ;
        SWAddLineToPoint( context, x, size.height-insets.top, _isAligned ) ;
    }

    CGContextSetLineWidth( context, 0.5 ) ;
    CGContextSetStrokeColorWithColor( context, majorTicksColor.CGColor ) ;
    CGContextStrokePath( context );
    
// minor ticks

    CGFloat width = size.width-insets.left-insets.right ;
    CGFloat minorWidth = width * (tickInterval / xLen) ;
    //e = firstTick ;
    for ( int i=0 ; i<majorCountD /*e <= lastTick-tickInterval*/; i++ )
    {
        double e = firstTickD + (tickInterval*i) ;
        CGFloat x = SWConvertToViewPort(e, xBeg, xEnd, insets.left, size.width-insets.right ) ;
        
        CGFloat mxx = 0;
        for ( int j=1 ; j<minorCount ; j++ )
        {
            CGFloat mx;
            mx = x + j*(minorWidth/minorCount) ;
            if ( mx != mx ) continue;
            if ( mx < insets0.left || mx > size.width-insets0.right ) continue ;
            
            if ( check == 1 )
            {
                check = 2;
                if ( (mxx-mx)*(mxx-mx) < 4 ) goto labels ;
            }
        
            if ( check == 0 )
            {
                check = 1 ;
                mxx = mx;
            }
            
            SWMoveToPoint( context, mx, insets.bottom, _isAligned ) ;
            SWAddLineToPoint( context, mx, size.height-insets.top, _isAligned ) ;
        }
    }
    
    CGContextSetLineWidth( context, 0.5 ) ;
    CGContextSetStrokeColorWithColor( context, minorTicksColor.CGColor ) ;
    CGContextStrokePath( context );
    
    
//    if ( v.xOffset < 0 )
//    {
//        CGContextSetLineWidth( context, 4);
//        CGContextSetStrokeColorWithColor( context, majorTicksColor.CGColor ) ;
//        CGFloat x = SWConvertToViewPort( self.xRangeEnd+v.xOffset, xBeg, xEnd, insets.left, size.width-insets.right ) ;
//        SWMoveToPoint( context, x, insets.bottom, _isAligned ) ;
//        SWAddLineToPoint( context, x, size.height-insets.top, _isAligned ) ;
//        CGContextStrokePath( context );
//    }
    
    // borders
//    [self _drawBordersInContext:context size:size insets:insets] ;
    
labels:
    // labels
    CGContextRestoreGState( context ) ;  // recuperem el estat inicial
    UIGraphicsPushContext( context ) ;
    //CGContextSetFillColorWithColor( context, textColor.CGColor ) ;
    
    UIFont *font = v.font ;
    
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle alloc] init];
        textStyle.lineBreakMode = NSLineBreakByClipping;
        textStyle.alignment = NSTextAlignmentCenter;
        
    NSDictionary *attrs = @{
        NSFontAttributeName:font,
        NSParagraphStyleAttributeName:textStyle,
        NSForegroundColorAttributeName:textColor
    };
    
    //CGFloat textSpace = SWConvertToViewPort( tickInterval, 0, xEnd-xBeg, 0, size.width-insets.right-insets.left) ;
    
    CGFloat textSpace = SWConvertToViewPort(tickInterval, 0, xEnd+tickInterval-xBeg, 0, size.width-insets0.right-insets0.left);
    
    if ( textSpace > 1 )
    {
        if ( isTimeChart )
        {
            CFDateFormatterRef dateFormatter = v.dateFormatter ;

            //CGSize textSize = [(__bridge NSString*)DateFormatterString0 sizeWithFont:font] ;
            CFStringRef formaterString = [v dateFormatterString];
            CGSize textSize = [(__bridge NSString*)formaterString sizeWithAttributes:attrs] ;
            textSize.width = ceil(textSize.width);
            textSize.height = ceil(textSize.height);
        
            int increment = 1 + truncf( textSize.width / textSpace )  ;
            int offset = increment - ((long)trunc(firstTick/tickInterval) % increment) - 1 ;
            //e = firstTick ;
            for ( int i=offset ; i<=majorCount /*e <= lastTick*/ ; i+=increment )
            {
                double e = firstTick + (tickInterval*i) ;

                CGFloat x = SWConvertToViewPort(e, xBeg, xEnd, insets.left, size.width-insets.right ) ;
                // aqui no filtrem x perque volem que el texte sigui visible per el tick previ i posterior al plot frame

                double y = insets.bottom - textSize.height/4 ;  // punt de partida del texte es 1/3 punts mes avall que la alzada de la font
        
                CGRect tRect ;
                tRect.origin = CGPointMake(x-textSize.width/2, size.height - y) ;
                tRect.size = textSize ;
                if ( _isAligned ) tRect.origin = SWAlignPointToDeviceSpace( context, tRect.origin ) ;
        
                NSString *str;
           
//                CFDateRef date = CFDateCreate( NULL, e ) ;
//                str = (__bridge_transfer NSString *)CFDateFormatterCreateStringWithDate( NULL, dateFormatter, date ) ;
//                CFRelease( date ) ;
                
                str = (__bridge_transfer NSString *)CFDateFormatterCreateStringWithAbsoluteTime(NULL, dateFormatter, e);
            
                [str drawInRect:tRect withAttributes:attrs];
            }
        }
    
        else
        {
        
            NSArray *labels = v.labels;
            NSInteger labelsCount = labels.count;
            NSString *format = v.format;
        
            CGFloat lastTexR;
            for ( int i=0 ; i<=majorCount; i++ )
            {
                double e = firstTick + (tickInterval*i) ;

                CGFloat x = SWConvertToViewPort(e, xBeg, xEnd, insets.left, size.width-insets.right ) ;
                if ( x < insets0.left || x > size.width-insets0.right ) continue ;
                
                NSString *str;
                if ( i < labelsCount) str = [labels objectAtIndex:i];
                else str = stringForDouble_withFormat( e, format ) ;
                
                CGSize textSize = [str sizeWithAttributes:attrs];
                textSize.width = ceil(textSize.width);
                textSize.height = ceil(textSize.height);
                
                double y = insets.bottom - textSize.height/4 ;  // punt de partida del texte es 1/3 punts mes avall que la alzada de la font
        
                CGRect tRect ;
                tRect.origin = CGPointMake(x-textSize.width/2, size.height - y) ;
                tRect.size = textSize ;
                
                if ( i > 0 && tRect.origin.x < lastTexR ) continue;
                lastTexR = x+textSize.width/2;
                
                if ( _isAligned ) tRect.origin = SWAlignPointToDeviceSpace( context, tRect.origin ) ;
        
                [str drawInRect:tRect withAttributes:attrs];
            }
        }
    }
    UIGraphicsPopContext();
}

@end


#pragma mark SWYAxisLayer

@interface SWYAxisLayer : SWBaseRangedTrendLayer
@end


@implementation SWYAxisLayer


- (void)setRange:(SWBounds)range animated:(BOOL)animated
{
    [self setAnimated:animated] ;  // atencio sempre no
    self.yRangeBeg = range.min ;
    self.yRangeEnd = range.max ;
}

// draw
- (void)drawInContext:(CGContextRef)context
{
    CGRect rect = self.bounds ;
    CGSize size = rect.size;
    
    SWTrendView *v = (SWTrendView*)_v ;
    UIColor *majorTicksColor = v.majorTickColor ;
    UIColor *minorTicksColor = v.minorTickColor ;
    double tickInterval = v.yMajorTickInterval ;
    int minorCount = v.yMinorTicksPerInterval ;
    UIEdgeInsets insets = v.insets ;
    
    double rBeg = self.yRangeBeg ;
    double rEnd = self.yRangeEnd ;
    double rLen = rEnd - rBeg ;
    
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    if ( tickInterval <= 0 ) return ;
    
    if ( rLen < 0 ) tickInterval = -tickInterval ;
    
    double tickFloor = floor(rBeg/tickInterval) ;
    double firstTick = tickInterval * tickFloor ;
    int majorCount = ceil(rEnd/tickInterval)-tickFloor ;
    
    // major ticks
    UInt8 check = 0;
    CGFloat yy = 0;
    for ( int i=0 ; i<=majorCount ; i++ )
    {
        double e = firstTick + (tickInterval*i) ;
        
        CGFloat y;
        y = SWConvertToViewPort(e, rBeg, rEnd, insets.bottom, size.height-insets.top ) ;
        if ( y < insets.bottom || y > size.height-insets.top ) continue ;
        
        if ( check == 1 )
        {
            check = 2;
            if ( (yy-y)*(yy-y) < 9 ) return ;
        }
        
        if ( check == 0 )
        {
            check = 1 ;
            yy = y;
        }
        
        SWMoveToPoint( context, insets.left, y, _isAligned ) ;
        SWAddLineToPoint( context, size.width-insets.right, y, _isAligned ) ;
    }

    CGContextSetLineWidth( context, 0.5 ) ;
    CGContextSetStrokeColorWithColor( context, majorTicksColor.CGColor ) ;
    CGContextStrokePath( context );
    
    // minor ticks
    CGFloat height = size.height-insets.top-insets.bottom ;
    CGFloat minorHeight = height * (tickInterval / rLen) ;
    
    for ( int i=0 ; i<majorCount ; i++ )
    {
        double e = firstTick + (tickInterval*i) ;
        CGFloat y = SWConvertToViewPort(e, rBeg, rEnd, insets.bottom, size.height-insets.top ) ;
        
        check = 0;
        CGFloat myy = 0;
        for ( int j=1 ; j<minorCount ; j++ )
        {
            CGFloat my;
            my = y + j*(minorHeight/minorCount) ;
            if ( my < insets.bottom || my > size.height-insets.top ) continue ;
            
            if ( check == 1 )
            {
                check = 2;
                if ( (myy-my)*(myy-my) < 4 ) return ;
            }
        
            if ( check == 0 )
            {
                check = 1 ;
                myy = my;
            }
            
            SWMoveToPoint( context, insets.left, my, _isAligned ) ;
            SWAddLineToPoint( context, size.width-insets.right, my, _isAligned ) ;
        }
    }
    
    CGContextSetLineWidth( context, 0.5 ) ;
    CGContextSetStrokeColorWithColor( context, minorTicksColor.CGColor ) ;
    CGContextStrokePath( context );
    
    // borders
//    [self _drawBordersInContext:context size:size insets:insets] ;
}



//- (void)_drawBordersInContext:(CGContextRef)context size:(CGSize)size insets:(UIEdgeInsets)insets
//{
////    // draw horizontal border lines
////    const CGFloat LineWidth = 1.0 ;
////    const CGFloat LOffset = 0.5 ; //LineWidth ;
////    CGContextSetLineWidth( context, LineWidth ) ;
////    CGContextSetStrokeColorWithColor( context, _borderColor.CGColor ) ;
////    SWMoveToPoint( context, insets.left-LOffset, insets.bottom-LOffset, NO ) ;
////    SWAddLineToPoint( context, size.width-insets.right+LOffset, insets.bottom-LOffset, NO ) ;
////    SWMoveToPoint( context, insets.left-LOffset, size.height-insets.top+LOffset, NO ) ;
////    SWAddLineToPoint( context, size.width-insets.right+LOffset, size.height-insets.top+LOffset, NO ) ;
////    CGContextStrokePath( context );
//}

@end

#pragma mark SWTrendBackLayer
@interface SWTrendBackLayer : SWLayer
@end

@implementation SWTrendBackLayer

// draw
- (void)drawInContext:(CGContextRef)context
{
    CGRect rect = self.bounds ;
    CGSize size = rect.size;
    
    SWTrendView *v = (SWTrendView*)_v ;
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
    
    
//    CGContextSetFillColorWithColor( context, tintColor.CGColor ) ;
//    CGContextFillRect( context, backRect ) ;

    CGContextSaveGState( context ) ;
    CGContextClipToRect( context, backRect) ;
    drawSingleGradientRect( context, backRect, tintColor.CGColor, DrawGradientDirectionFlippedDown) ;   //flipped
    CGContextRestoreGState( context ) ;
    
    
    const CGFloat LineWidth = 1.0 ;
    const CGFloat LOffset = 0.5 ; //LineWidth/2 ;
    CGContextSetLineWidth( context, LineWidth ) ;
    CGContextSetStrokeColorWithColor( context, borderColor.CGColor ) ;
    
//    SWMoveToPoint( context, insets.left-LOffset, insets.bottom-LOffset, _isAligned ) ;
//    SWAddLineToPoint( context, insets.left-LOffset, size.height-insets.top+LOffset, _isAligned ) ;
//    SWAddLineToPoint( context, size.width-insets.right+LOffset, size.height-insets.top+LOffset, _isAligned ) ;
//    SWAddLineToPoint( context, size.width-insets.right+LOffset,  insets.bottom-LOffset, _isAligned ) ;
//    SWAddLineToPoint( context, insets.left-LOffset, insets.bottom-LOffset, _isAligned ) ;
    
    CGContextSetLineCap( context, kCGLineCapRound ) ;
    CGContextSetLineJoin( context, kCGLineJoinRound ) ;
    
    CGContextStrokeRect( context, CGRectInset( backRect, -LOffset, -LOffset)) ;
    
    CGContextStrokePath( context );
}


@end



#pragma mark SWTrendLayer

@interface SWTrendLayer : SWLayer

@end


@implementation SWTrendLayer


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
//    Class plotLayerClass = [SWPlotLayer class] ;
//
//    SWTrendView *v = (SWTrendView*)_v ;
//    UIEdgeInsets insets = v.insets ;
    for ( CALayer *layer in self.sublayers )
    {
        CGRect rect = bounds ;
//        if ( [layer isKindOfClass:plotLayerClass] )
//        {
//            rect.origin.x += insets.left ;
//            rect.origin.y += insets.top ;
//            rect.size.width -= insets.left+insets.right ;
//            rect.size.height -= insets.top+insets.bottom ;
//        }
        
        layer.frame = rect ;
        [layer setNeedsLayout] ;
    }
}

@end



#pragma mark SWTrendView

@interface SWTrendView()

@end


@implementation SWTrendView
{
    SWTrendBackLayer *_backLayer ;
    SWXAxisLayer *_xAxisLayer ;
    SWYAxisLayer *_yAxisLayer ;

    NSMutableArray *_plotLayers ;
    NSMutableArray *_plotIdentifiers ;
    
//    CFTimeInterval _xOffset ;
//    CFAbsoluteTime _xLength ;
    double _xOffset ;
    double _xLength ;

    dispatch_source_t _reLoadTimer ;
    CFDateFormatterRef _dateFormatter ;
    
    BOOL _xReversed;
}

+ (Class)layerClass
{
    return [SWTrendLayer class] ;
}

@synthesize dataSource = _dataSource ;

@synthesize style = _style;
@synthesize chartType = _chartType;
@synthesize updatingStyle = _updatingStyle;
@synthesize gesturesEnabled = _gesturesEnabled;

@synthesize font = _font ;
@synthesize dateFormatter = _dateFormatter ;
//@synthesize xAxisRange = _xAxisRange ;
@synthesize xMajorTickInterval = _xMajorTickInterval ;
@synthesize xMinorTicksPerInterval = _xMinorTicksPerInterval ;

@synthesize yAxisRange = _yAxisRange ;
@synthesize yMajorTickInterval = _yMajorTickInterval ;
@synthesize yMinorTicksPerInterval = _yMinorTicksPerInterval ;

@synthesize insets = _insets ;
@synthesize tintsColor = _tintsColor ;

@synthesize majorTickColor = _majorTickColor ;
@synthesize minorTickColor = _minorTickColor ;
//@synthesize textColor = _textColor ;
@synthesize contrastColor = _contrastColor ;
@synthesize borderColor = _borderColor ;


- (void)_doInit
{
    SWTrendLayer *layer = (id)[self layer] ;
    [layer setView:self] ;
    
    _backLayer = [[SWTrendBackLayer alloc] init] ;
    [_backLayer setView:self] ;
    [layer addSublayer:_backLayer] ;
    
    _xAxisLayer = [[SWXAxisLayer alloc] init] ;
    [_xAxisLayer setView:self] ;
    [layer addSublayer:_xAxisLayer] ;
    
    _font = [UIFont boldSystemFontOfSize:13] ;
    
    _yAxisLayer = [[SWYAxisLayer alloc] init] ;
    [_yAxisLayer setView:self] ;
    [layer addSublayer:_yAxisLayer] ;
    
    
    _plotLayers = [NSMutableArray array] ;
    _plotIdentifiers = [NSMutableArray array] ;

    _insets = UIEdgeInsetsMake( 8, 8, 24, 8 ) ;
    _borderColor = [UIColor brownColor] ;
    //[self setTintColor:DarkenedUIColorWithRgb(SystemDarkerBlueColor, 0.6)] ;   // UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1]] ;
    [self setTintsColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1]] ;
    
    _maxZoomInterval = INFINITY;
    
    _chartType = SWChartTypeLine;
}


- (CFDateFormatterRef)dateFormatter
{
    if ( _dateFormatter == NULL )
    {
        _dateFormatter = CFDateFormatterCreate( NULL, NULL, kCFDateFormatterNoStyle, kCFDateFormatterNoStyle ) ;
        //CFDateFormatterSetFormat( dateFormatter, CFSTR("yyyy-MM-dd HH:mm:ss ZZ") ) ;
        //CFDateFormatterSetFormat( _dateFormatter, DateFormatterString0 ) ;
    }
    CFStringRef fString = [self dateFormatterString];
    CFDateFormatterSetFormat( _dateFormatter, fString ) ;
    return _dateFormatter ;
}


- (CFStringRef)dateFormatterString
{
    //static CFStringRef DateFormatterString0 = CFSTR("yyyy-MM-dd HH:mm:ss ZZ") ;
    static CFStringRef DateFormatterString0 = CFSTR("yyyy-MM-dd HH:mm:ss") ;
    static CFStringRef DateFormatterString1 = CFSTR("yyyy-MM-dd HH:mm") ;
    static CFStringRef DateFormatterString2 = CFSTR("yy-MM-dd HH:mm:ss") ;
    static CFStringRef DateFormatterString3 = CFSTR("yy-MM-dd HH:mm") ;
    static CFStringRef DateFormatterString4 = CFSTR("HH:mm:ss") ;
    //static CFStringRef DateFormatterString4 = CFSTR("HH:mm") ;
    
    CFStringRef fString = NULL;
    if ( _xOffset >= 24*3600*365 * 2 || _xLength >= 24*3600*365 * 2)
    {
        if ( _xLength > 3600 ) fString = DateFormatterString1;
        else fString = DateFormatterString0;
    }
    else if ( _xOffset <= 0 )
    {
        if ( _xLength > 3600 ) fString = DateFormatterString3;
        else fString = DateFormatterString4;
    }
    else
    {
        if ( _xLength > 3600 ) fString = DateFormatterString3;
        else fString = DateFormatterString2;
    }
    
    return fString;
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


- (void)dealloc
{
    [self _stopViewUpdating] ;
    if ( _dateFormatter ) CFRelease( _dateFormatter ) ;
}


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if ( newSuperview == nil ) [self _stopViewUpdating] ;
}


- (void)addPlotWithIdentifier:(id)ident
{
    SWTrendLayer *layer = (id)[self layer] ;
    SWPlotLayer *plotLayer = [[SWPlotLayer alloc] initWithIdentifier:ident] ;
    [plotLayer setView:self];
    //plotLayer.dataSource = _dataSource ;
    [_plotLayers addObject:plotLayer] ;
    [_plotIdentifiers addObject:ident] ;

//    [layer addSublayer:plotLayer] ;
    [layer insertSublayer:plotLayer above:_yAxisLayer];

    // ATENCIO, no fem reload en aquest punt
}


- (void)resetViewUpdating
{
    [self _updateViewAnimated:NO] ;
    [self _resetViewUpdating] ;
}


- (void)stopViewUpdating
{
    [self _stopViewUpdating] ;
}


- (void)setStyle:(SWTrendStyle)style
{
    _style = style;
    // TO DO
}


- (void)setChartType:(SWChartType)chartType
{
    _chartType = chartType;
    
//    NSInteger plotLayersCount = [_plotLayers count];
//    
//    for ( NSInteger i=0 ; i<plotLayersCount; i++ )
//    {
//        SWPlotLayer *layer = [_plotLayers objectAtIndex:0];
//        BOOL typeBar = (chartType == SWChartTypeBar || chartType == SWChartTypeMixed );
//        if ( i==0 && (chartType ==SWChartTypeMixed) ) typeBar = NO;
//        [layer setStyleBar:typeBar];
//    }
    
    [_xAxisLayer setNeedsDisplay] ;
    [self reloadPlotsAnimated:YES];
}


- (void)setUpdatingStyle:(SWTrendUpdatingStyle)updatingStyle
{
    _updatingStyle = updatingStyle;
    // tindra efecte despres de la seguent iteracio
}


- (void)setGesturesEnabled:(BOOL)gesturesEnabled
{
    if ( _gesturesEnabled != gesturesEnabled )
    {
        _gesturesEnabled = gesturesEnabled;
        
        if ( gesturesEnabled )
        {
            _pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchRecognized:)];
            _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecognized:)];
            _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
            _tapGesture.numberOfTapsRequired = 2;
            [self addGestureRecognizer:_pinchGesture];
            [self addGestureRecognizer:_panGesture];
            [self addGestureRecognizer:_tapGesture];
            _pinchGesture.delegate = self;
            _panGesture.delegate = self;
            _tapGesture.delegate = self;
        }
        else
        {
            [self removeGestureRecognizer:_pinchGesture];
            [self removeGestureRecognizer:_panGesture];
            [self removeGestureRecognizer:_tapGesture];
            _pinchGesture = nil;
            _panGesture = nil;
            _tapGesture = nil;
        }
    }
}


- (void)setXAxisRange:(SWPlotRange)range animated:(BOOL)animated
{
    //_xAxisRange = range ;
    _xLength = range.max - range.min ;   // es refereix a la longitud entre el ultim i el primer (no sumar 1)
    _xOffset = 0 ;
    _isTimeChart = NO;
    [self _stopViewUpdating] ;
    
//    [_xAxisLayer setRange:SWBoundsMake(range.min, range.max) animated:animated] ;
//    for ( SWPlotLayer *plotLayer in _plotLayers )
//    {
//        NSData *plotValues = [self _getValuesForPlotWithIdentifier:plotLayer.identifier inRange:range animated:animated];
//        [plotLayer setXRange:range withPlotValues:plotValues reversed:_xReversed animated:animated];
//    }
    
    [self _setPlotValuesForRange:range animated:animated];
}


- (void)setYAxisRange:(SWBounds)range animated:(BOOL)animated
{
    _yAxisRange = range ;
    [_yAxisLayer setRange:range animated:animated] ;
}


- (void)setXRangeOffset:(CFTimeInterval)offset
{
    _xOffset = offset ;
    //if ( _xOffset > 0.0 ) 
    [self _updateViewAnimated:NO] ;
    [self _resetViewUpdating] ;
}


- (void)setXPlotInterval:(double)length
{
    _xLength = fabs(length) ;
    _xReversed = (length<0);
    [self _updateViewAnimated:YES] ;
}


- (void)setXMajorTickInterval:(CFTimeInterval)xMajorTickInterval
{
    _xMajorTickInterval = xMajorTickInterval ;
    [_xAxisLayer setNeedsDisplay] ;
}


- (void)setXMinorTicksPerInterval:(int)xMinorTicksPerInterval
{
    _xMinorTicksPerInterval = xMinorTicksPerInterval ;
    [_xAxisLayer setNeedsDisplay] ;
}


- (void)setYMajorTickInterval:(double)yMajorTickInterval
{
    _yMajorTickInterval = yMajorTickInterval ;
    [_yAxisLayer setNeedsDisplay] ;
}


- (void)setYMinorTicksPerInterval:(int)yMinorTicksPerInterval
{
    _yMinorTicksPerInterval = yMinorTicksPerInterval ;
    [_yAxisLayer setNeedsDisplay] ;
}


- (void)setYRange:(SWBounds)range forPlotWithIdentifier:(id)ident animated:(BOOL)animated
{
    NSInteger index = [_plotIdentifiers indexOfObject:ident] ;
    if ( index != NSNotFound )
    {
        SWPlotLayer *plotLayer = [_plotLayers objectAtIndex:index] ;
        [plotLayer setYRange:range animated:animated] ;
    }
}


- (void)removePlotWithIdentifier:(id)ident
{
    NSInteger index = [_plotIdentifiers indexOfObject:ident] ;
    if ( index != NSNotFound )
    {
        SWPlotLayer *plotLayer = [_plotLayers objectAtIndex:index] ;
        [_plotLayers removeObjectAtIndex:index] ;
        [_plotIdentifiers removeObjectAtIndex:index] ;
        
        [plotLayer removeFromSuperlayer] ;
    }
}


- (void)setColor:(UIColor *)color forPlotWithIdentifier:(id)ident
{
    NSInteger index = [_plotIdentifiers indexOfObject:ident] ;
    if ( index != NSNotFound )
    {
        SWPlotLayer *plotLayer = [_plotLayers objectAtIndex:index] ;
        [plotLayer setColor:color] ;
        [plotLayer setNeedsDisplay] ;
    }
}


- (void)setColorFill:(UIColor *)color forPlotWithIdentifier:(id)ident
{
    NSInteger index = [_plotIdentifiers indexOfObject:ident] ;
    if ( index != NSNotFound )
    {
        SWPlotLayer *plotLayer = [_plotLayers objectAtIndex:index] ;
        [plotLayer setColorFill:color] ;
        [plotLayer setNeedsDisplay] ;
    }
}


- (void)setSymbol:(BOOL)symbol forPlotWithIdentifier:(id)ident
{
    NSInteger index = [_plotIdentifiers indexOfObject:ident] ;
    if ( index != NSNotFound )
    {
        SWPlotLayer *plotLayer = [_plotLayers objectAtIndex:index] ;
        [plotLayer setSymbol:symbol] ;
        [plotLayer setNeedsDisplay] ;
    }
}


- (void)removeAllPlots
{    
    for ( SWPlotLayer *plotLayer in _plotLayers )
    {
        [plotLayer removeFromSuperlayer] ;
    }
    [_plotLayers removeAllObjects] ;
    [_plotIdentifiers removeAllObjects] ;
}


- (void)reloadPlotsAnimated:(BOOL)animated
{
    double end = _xAxisLayer.xRangeEnd ;
    double begin = end - _xAxisLayer.xRangeLength ;
    SWPlotRange range = SWPlotRangeMake(begin, end);
    
    [self _setPlotValuesForRange:range animated:animated];
}


- (void)setInsets:(UIEdgeInsets)insets
{
    _insets = insets ;
    SWTrendLayer *layer = (id)[self layer] ;
    [layer setNeedsLayout] ;
    [_xAxisLayer setNeedsDisplay] ;
    [_yAxisLayer setNeedsDisplay] ;
}


- (void)setTintsColor:(UIColor *)color
{
    _tintsColor = color;
    
    UInt32 rgb = rgbColorForUIcolor( color ) ;
    CGFloat brightness = BrightnessForRgb(rgb) ;
    CGFloat majorWhite, minorWhite ;
    if (brightness<0.59f) 
    {
        majorWhite = MIN(brightness+0.5f, 1.0f) ;
        minorWhite = brightness+0.25f ;
    }
    else 
    {
        majorWhite = brightness-0.5f ;
        minorWhite = brightness-0.25f ;
    }
    _majorTickColor = [UIColor colorWithWhite:majorWhite alpha:1] ; 
    _minorTickColor = [UIColor colorWithWhite:minorWhite alpha:1] ; 
    
    [_backLayer setNeedsDisplay] ;
    [_xAxisLayer setNeedsDisplay] ;
    [_yAxisLayer setNeedsDisplay] ;
}


- (void)setBorderColor:(UIColor *)color
{
    _borderColor = color;
    [_backLayer setNeedsDisplay];
}


- (void)setContrastForBackgroundColor:(UIColor *)color
{
    _contrastColor = contrastColorForUIColor( color ) ;
    [_xAxisLayer setNeedsDisplay] ;
}


- (void)setBackgroundColor:(UIColor *)color
{
    [super setBackgroundColor:color] ;
    [self setContrastForBackgroundColor:color];
}


- (void)setLabels:(NSArray *)labels
{
    _labels = labels;
    [_xAxisLayer setNeedsDisplay];
}


- (void)setFormat:(NSString *)format
{
    _format = format;
    [_xAxisLayer setNeedsDisplay];
}


- (void)setMaxZoomInterval:(CFTimeInterval)maxZoomInterval
{
    _maxZoomInterval = maxZoomInterval;
}


#pragma mark - private


- (void)_setPlotValuesForRange:(SWPlotRange)range animated:(BOOL)animated
{
    SWPlotRange valuesRange = range ;
    if ( animated )
    {
        SWPlotRange currentRange ;
        currentRange.max = _xAxisLayer.xRangeEnd ;
        currentRange.min = currentRange.max - _xAxisLayer.xRangeLength ;
        if ( currentRange.min < range.min ) valuesRange.min = currentRange.min ;
        if ( currentRange.max > range.max ) valuesRange.max = currentRange.max ;
    }
    
    //NSLog( @"range      : %1.15g, %1.15g", range.min, range.max );
    //NSLog( @"valuesRange: %1.15g, %1.15g", valuesRange.min, valuesRange.max );
    

    SWPlotRange dataRange = valuesRange ;
    dataRange.min -= 1.0 ; // periode de mostreix
    
    NSArray *sourceDatas = [_dataSource pointsForPlotsWithIdentifiers:_plotIdentifiers inRange:dataRange];
    
    [self _setPlotValues:sourceDatas inPlotRange:range animated:animated];
}


- (void)_setPlotValues:(NSArray*)sourceDatas inPlotRange:(SWPlotRange)range animated:(BOOL)animated
{
    [_xAxisLayer setRange:range animated:animated];
    
    NSInteger datasCount = [sourceDatas count];
    NSInteger plotLayersCount = [_plotLayers count];
    NSInteger barCount = plotLayersCount;
    if ( _chartType == SWChartTypeMixed && barCount > 0) barCount -= 1;
    if ( _chartType == SWChartTypeLine ) barCount = 0;
    
    for ( NSInteger i=0 ; i<datasCount && i<plotLayersCount; i++ )
    {
        NSData *values = [sourceDatas objectAtIndex:i];
        
        SWPlotLayer *plotLayer = [_plotLayers objectAtIndex:i];
        
        int barIndex = i;
        BOOL typeBar = (_chartType == SWChartTypeBar);
        
        if ( _chartType == SWChartTypeMixed )
        {
            typeBar = (i>0);
            barIndex -= 1;
        }
        
        [plotLayer setTypeBar:typeBar];
        [plotLayer setBarIndex:barIndex];
        [plotLayer setBarCount:barCount];
        
        [plotLayer setXRange:range withPlotValues:values reversed:_xReversed animated:animated];
    }
}


- (void)_beginDisabledActions
{
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
}


- (void)_endDisabledActions
{
    [CATransaction commit];
}


- (void)_updateViewAnimated:(BOOL)animated
{
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent() - _xOffset ;
    CFAbsoluteTime begin = end - _xLength ;
    _isTimeChart = YES;
    
    //NSLog( @"SWTrendView updateView begin:%f, end:%f, animated:%d", begin, end, animated) ;
    
    SWPlotRange range = SWPlotRangeMake(begin, end);
    [self _setPlotValuesForRange:range animated:animated];
}


- (void)_resetViewUpdating
{
    if ( _xOffset <= 0.0 ) [self _startUpdatingView] ;
    else [self _stopViewUpdating] ;
}


- (void)_startUpdatingView
{
    // TO DO - Calcular el temps de update i ajustar la animacio en funcio de _xLength
    // TO DO - En el eventhandler filtrar si estem rotant,

    if ( _reLoadTimer == NULL )
    {
        _reLoadTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    
        //dispatch_source_t theReLoadTimer = _reLoadTimer;
        __weak id theSelf = self ;  // evitem el retain cycle entre _reloadTimer i self
        
        dispatch_source_set_event_handler( _reLoadTimer, 
        ^{
            @autoreleasepool
            {
                SWTrendUpdatingStyle updatingStyle = [theSelf updatingStyle];
                BOOL animatedUpdate = (updatingStyle == SWTrendUpdatingStyleContinuous);
                [theSelf _updateViewAnimated:animatedUpdate] ;
            }
        });

        dispatch_source_set_cancel_handler( _reLoadTimer, 
        ^{
            // IOS6 dispatch_release( theReLoadTimer );
        });
    

        dispatch_resume( _reLoadTimer );
        dispatch_source_set_timer( _reLoadTimer, DISPATCH_TIME_NOW, NSEC_PER_SEC/2, 0 );      // repeticio cada 0.5 seg
    }
        
    //dispatch_time_t tt = dispatch_time( DISPATCH_TIME_NOW, REOPEN_TIME_INTERVAL*NSEC_PER_SEC );
    //dispatch_time_t tt = dispatch_time( DISPATCH_TIME_NOW, 1*NSEC_PER_SEC );
}


- (void)_stopViewUpdating
{
    if ( _reLoadTimer ) dispatch_source_cancel( _reLoadTimer ), _reLoadTimer = NULL ;
}


#pragma mark - GestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //NSLog( @"should begin");
    return YES;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


#pragma mark - GestureRecognizer action

- (void)pinchRecognized:(UIPinchGestureRecognizer*)recognizer
{
    CGFloat scale = recognizer.scale;
    
    switch ( recognizer.state )
    {
        case UIGestureRecognizerStateBegan:
            //NSLog( @"Pinch began");
            _pinchBegan = YES;
            _initialPinchRange.max = _xAxisLayer.xRangeEnd + _currentPanDisplacement;
            _initialPinchRange.min = _xAxisLayer.xRangeEnd - _xAxisLayer.xRangeLength + _currentPanDisplacement;
            [self _stopViewUpdating];
            [self _setupRangeForPinchScale:scale];
            break;
            
        case UIGestureRecognizerStateChanged:
             [self _setupRangeForPinchScale:scale];
            break;
            
        case UIGestureRecognizerStateEnded:
            _pinchBegan = NO;
            [self _finishGesture];
            break;
            
        case UIGestureRecognizerStateCancelled:
        //case UIGestureRecognizerStateFailed:
            _pinchBegan = NO;
            break;
            
        default:
            break;
    }
}



- (void)panRecognized:(UIPanGestureRecognizer*)recognizer
{
    CGPoint translation = [recognizer translationInView:self];
    
    switch ( recognizer.state )
    {
        case UIGestureRecognizerStateBegan:
            _panBegan = YES;
            _currentPanDisplacement = 0;
            _initialPanRange.max = _xAxisLayer.xRangeEnd;
            _initialPanRange.min = _xAxisLayer.xRangeEnd - _xAxisLayer.xRangeLength;
            [self _stopViewUpdating];
            [self _setupRangeForPanTranslation:translation.x];
            break;
            
        case UIGestureRecognizerStateChanged:
            [self _setupRangeForPanTranslation:translation.x];
            break;
            
        case UIGestureRecognizerStateEnded:
            
            _panBegan = NO;
            
            CGFloat velocity = [recognizer velocityInView:self].x;
            //NSLog( @"velocity:%g", velocity );
            if ( abs(velocity) < 250 ) [self _finishGesture];
            else [self _performEndingAnimationWithVelocity:velocity];
    
            _currentPanDisplacement = 0;
            
            break;
            
        case UIGestureRecognizerStateCancelled:
        //case UIGestureRecognizerStateFailed:
            _panBegan = NO;
            break;
            
        default:
            break;
    }
}

- (void)tapRecognized:(UITapGestureRecognizer*)recognizer
{

    switch ( recognizer.state )
    {
        case UIGestureRecognizerStateBegan:
            break;
            
        case UIGestureRecognizerStateChanged:
            break;
            
        case UIGestureRecognizerStateEnded:
            _xOffset = 0;
           // [self _updateViewAnimated:YES];
           // [self _resetViewUpdating];
            [self _finishGesture];
            break;
            
        case UIGestureRecognizerStateCancelled:
        //case UIGestureRecognizerStateFailed:
            break;
            
        default:
            break;
    }
}




#pragma mark - gestures private


- (void)_setupRangeForPinchScale:(CGFloat)scale
{
    double initialLength = _initialPinchRange.max - _initialPinchRange.min;
    //_xLength = initialLength * 1/scale;
    double xLength = initialLength * 1/scale;

    SWPlotRange range;
    range.max = (_initialPinchRange.max + _initialPinchRange.min + xLength)/2 - _currentPanDisplacement;
    range.min = (_initialPinchRange.max + _initialPinchRange.min - xLength)/2 - _currentPanDisplacement;
    
    [self _setupRange:range];
}


- (void)_setupRangeForPanTranslation:(CGFloat)translation
{
    if ( _xReversed )
        translation = -translation;

    double displacementScale = _xLength / self.bounds.size.width;
    _currentPanDisplacement = translation * displacementScale;

    SWPlotRange range;
    range.max = (_initialPanRange.max + _initialPanRange.min + _xLength)/2 - _currentPanDisplacement;
    range.min = (_initialPanRange.max + _initialPanRange.min - _xLength)/2 - _currentPanDisplacement;
    
    [self _setupRange:range];
}


- (void)_setupRange:(SWPlotRange)range
{
    double overRange =  (range.max-range.min) - _maxZoomInterval;
    
    //NSLog( @"range:%1.15g overRange:%1.15g", range.max-range.min, overRange );
    if ( overRange  > 0 )
    {
        range.max -= overRange/2;
        range.min += overRange/2;     // revisar
    }
    
    //NSLog( @"range adjusted %1.15g", range.max-range.min );
    
    _xOffset =  CFAbsoluteTimeGetCurrent() - range.max;
    _xLength = range.max-range.min;
    
    [self _setPlotValuesForRange:range animated:NO];
}



- (void)_performEndingAnimationWithVelocity:(CGFloat)velocity
{
    if ( _xReversed )
        velocity = -velocity;
    
    double velocityScale = _xLength / self.bounds.size.width;
    double displacement = _currentPanDisplacement + velocityScale*(velocity*0.7/1.0);

    SWPlotRange range;
    range.max = (_initialPanRange.max + _initialPanRange.min + _xLength)/2 - displacement;
    range.min = (_initialPanRange.max + _initialPanRange.min - _xLength)/2 - displacement;
    
    CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
    double offset = now - range.max;
    if ( offset < 0 )
    {
        range.max += offset;
        range.min += offset;
        _xOffset = 1;
    }
    
    _xAxisLayer.animationDelegate = self;
    [self _setPlotValuesForRange:range animated:YES];
    _xAxisLayer.animationDelegate = nil;
    
    _xOffset =  now - range.max;
}


- (void)_finishGesture
{
    if ( _panBegan || _pinchBegan )
        return;
    
    if ( _xOffset > 0 )
    {
        double rangeEnd = _xAxisLayer.xRangeEnd;
        _xOffset = CFAbsoluteTimeGetCurrent() - rangeEnd;
    }
   
    if ( _xOffset <= 0)
    {
        _xOffset = 0;
        [self _updateViewAnimated:YES];
    }

    [self _resetViewUpdating];
    
    if ( [_delegate respondsToSelector:@selector(trendView:didFinishGestureWithPlotInterval:xOffset:)] )
    {
        double plotInterval = _xLength;
        if ( _xReversed ) plotInterval = -plotInterval;
        [_delegate trendView:self didFinishGestureWithPlotInterval:plotInterval xOffset:_xOffset];
    }
}


#pragma mark - animation delegate

- (void)animationDidStop:(CABasicAnimation *)anim finished:(BOOL)finished
{
    [self _finishGesture];
}
@end

