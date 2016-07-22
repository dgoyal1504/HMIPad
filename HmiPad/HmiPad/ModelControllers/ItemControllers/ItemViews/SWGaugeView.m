//
//  SWGaugeView.m
//  HmiPad
//
//  Created by Lluch Joan on 01/06/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "Drawing.h"
#import "SWColor.h"

#import "SWGaugeView.h"
#import "SWValue.h"

@interface SWGaugeView()

@property (nonatomic, readonly) UIEdgeInsets insets ;
@property (nonatomic, readonly) UIColor *textColor;
@property (nonatomic, readonly) UIColor *contrastColor;
@property (nonatomic, readonly) UIFont *font ;
@property (nonatomic, readonly) SWRange range ;
@property (nonatomic, readonly) NSData *ranges ;
@property (nonatomic, readonly) NSData *rangeColors ;
@property (nonatomic, readonly) double value;

- (CGFloat)getOuterRadius;
- (CGPoint)getCenterFlipped:(BOOL)isFlipped;
- (CGSize)getMaxTextSizeWithAttributes:(NSDictionary*)attrs;

@end


static double _angleForValue_withRangeBeg_rangeEnd_startAngle_endAngle(double value, double rBeg, double rEnd, double startAngle, double endAngle)
{
    double newAngle = startAngle + (value-rBeg)*((endAngle-startAngle)/(rEnd-rBeg));
    
    if ( endAngle-startAngle > 0 )
    {   
        if ( newAngle > endAngle ) newAngle = endAngle;
        if ( newAngle < startAngle ) newAngle = startAngle;
    }
    else
    {
        if ( newAngle < endAngle ) newAngle = endAngle;
        if ( newAngle > startAngle ) newAngle = startAngle;
    }
    
    if ( value == rBeg) newAngle = startAngle; // filtrem el cas de newAngle es nan
    return newAngle;
}


#pragma mark SWSGaugeLayer

@interface SWGaugeLayer : SWLayer

@property (nonatomic, assign) double rangeBeg ;
@property (nonatomic, assign) double rangeEnd ;

@end


@implementation SWGaugeLayer

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
}

- (id)initWithLayer:(SWGaugeLayer *)layer
{
    self = [super initWithLayer:layer] ;
    if ( self )
    {
        self.rangeEnd = layer.rangeEnd ;
        self.rangeBeg = layer.rangeBeg ;
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
//    CGFloat outerOffset = 2 ;
//    CGFloat majorLength = 8 ;
//    CGFloat minorLength = 5 ;
//
//    SWGaugeView *v = (SWGaugeView*)_v ;
//    double tickInterval = v.majorTickInterval ;
//
//    if ( tickInterval <= 0 ) return ;
//    
//    double rBeg = self.rangeBeg ;
//    double rEnd = self.rangeEnd ;
//    double rLen = rEnd - rBeg ;
//    
//    if ( rLen <= 0 ) tickInterval = -tickInterval ;   
//    
//    int minorCount = v.minorTicksPerInterval ;
//    NSString *labelText = v.labelText ;
//    UIFont *font = v.font ;
//    NSString *format = v.format ;
//    
////    double startAngle = v.startAngle ;
////    double endAngle = v.endAngle ;
//    
//    double deadAnglePosition = v.deadAnglePosition;
//    double angleRange = v.angleRange;
//    double startAngle = deadAnglePosition - (2*M_PI-angleRange)/2;
//    double endAngle = startAngle - angleRange;
//    
//    double aLen = endAngle-startAngle ;
//    
//    UIColor *textColor = v.textColor ;
//    
//    
//    CGContextSaveGState( context ) ;
//    SWTranslateAndFlipCTM( context, size.height ) ;
//    
//    CGFloat outerRadius = [v getOuterRadius];
//    CGPoint center = [v getCenterFlipped:NO];
//    
//    CGFloat outerTickRadius = outerRadius-outerOffset ;
//    
//    double tickFloor = floor(rBeg/tickInterval) ;
//    double firstTick = tickInterval * tickFloor ;
//    int majorCount = ceil(rEnd/tickInterval)-tickFloor ;
//    
//    // major ticks
//    UInt8 check = 0;
//    for ( int i=0 ; i<=majorCount; i++ )
//    {
//        double e = firstTick + (tickInterval*i) ;
//        
//        // el calcul el fem amb double pero la comparacio es fa amb float per considerar iguals valors practicament iguals
//        float angle = startAngle + (e-rBeg)*(aLen/rLen) ;   // float !
//        if ( aLen > 0 && (angle < (float)startAngle || angle > (float)endAngle) ) continue ;
//        if ( aLen < 0 && (angle > (float)startAngle || angle < (float)endAngle) ) continue ;
//        
//        CGPoint pBeg, pEnd, ppBeg ;
//        pBeg.x = center.x + outerTickRadius*cosf(angle) ;
//        pBeg.y = center.y + outerTickRadius*sinf(angle) ;
//        pEnd.x = center.x + (outerTickRadius-majorLength)*cosf(angle) ;
//        pEnd.y = center.y + (outerTickRadius-majorLength)*sinf(angle) ;
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
//        
//        SWMoveToPoint( context, pBeg.x, pBeg.y, NO /*_isAligned*/) ;
//        SWAddLineToPoint( context, pEnd.x, pEnd.y, NO /*_isAligned*/ ) ;
//    }
//
//    CGContextSetLineWidth( context, 2.0 ) ;
//    CGContextSetLineCap( context, kCGLineCapRound ) ;
//    CGContextSetStrokeColorWithColor( context, textColor.CGColor ) ;
//    CGContextStrokePath( context );
//    
//    // minor ticks
//    double minorAngle = aLen * (tickInterval / rLen) ;
//    for ( int i=0 ; i<majorCount /*e <= lastTick-tickInterval*/; i++ )
//    {
//        double e = firstTick + (tickInterval*i) ;
//        double angle = startAngle + (e-rBeg)*(aLen/rLen) ;
//        
//        check = 0;
//        for ( int j=1 ; j<minorCount ; j++ )
//        {
//            float ma = angle + j*(minorAngle/minorCount) ;   // float !
//            if ( aLen > 0 && (ma < (float)startAngle || ma > (float)endAngle) ) continue ;
//            if ( aLen < 0 && (ma > (float)startAngle || ma < (float)endAngle) ) continue ;
//            
//            CGPoint pBeg, pEnd, ppBeg ;
//            pBeg.x = center.x + outerTickRadius*cosf(ma) ;
//            pBeg.y = center.y + outerTickRadius*sinf(ma) ;
//            pEnd.x = center.x + (outerTickRadius-minorLength)*cosf(ma) ;
//            pEnd.y = center.y + (outerTickRadius-minorLength)*sinf(ma) ;
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
//            SWMoveToPoint( context, pBeg.x, pBeg.y, NO /*_isAligned*/) ;
//            SWAddLineToPoint( context, pEnd.x, pEnd.y, NO /*_isAligned*/ ) ;
//        }
//    }
//    
//    CGContextSetLineWidth( context, 1.0 ) ;
//    CGContextSetLineCap( context, kCGLineCapRound ) ;
//    CGContextSetStrokeColorWithColor( context, textColor.CGColor ) ;
//    CGContextStrokePath( context );
//   
//labels:
//    // labels
//    CGContextRestoreGState( context ) ;  // recuperem el estat inicial
//    UIGraphicsPushContext( context ) ;
//    CGContextSetFillColorWithColor( context, textColor.CGColor ) ;
//    
//////    NSString *str = stringForDouble_withFormat( fmax(firstTick,firstTick+(tickInterval*majorCount)), format ) ;
//////    CGSize textSize = [str sizeWithFont:font];
////    
////    NSString *str1 = stringForDouble_withFormat( firstTick, format ) ;
////    CGSize textSize1 = [str1 sizeWithFont:font] ;
////    
////    NSString *str2 = stringForDouble_withFormat( firstTick+(tickInterval*majorCount), format ) ;
////    CGSize textSize2 = [str2 sizeWithFont:font] ;
////    
////    CGSize textSize = textSize1;
////    if ( textSize2.width > textSize1.width ) textSize = textSize2;
//
//    CGSize textSize = v.getMaxTextSize;
//    
//    CGFloat txtBaseRadius = outerTickRadius-majorLength-minorLength ;
//    CGFloat txtRadius = txtBaseRadius-textSize.width/2 ;
//    CGFloat txtSpaceRadius = txtBaseRadius-textSize.height ;
//    CGFloat textSpace = SWConvertToViewPort( tickInterval, 0, rEnd-rBeg, 0, txtSpaceRadius*fabsf(aLen) ) ;
//    
//    if ( textSpace > 1 )
//    {
//        CGRect tRect ;
//        
//        int increment = 1 + truncf( textSize.width / textSpace ) ;
//        for ( int i=0 ; i<=majorCount ; i+=increment )
//        {
//            double e = firstTick + (tickInterval*i) ;
//            float angle = startAngle + (e-rBeg)*(aLen/rLen) ;  // float !
//        
//            if ( aLen > 0 && (angle < (float)startAngle || angle > (float)endAngle) ) continue ;
//            if ( aLen < 0 && (angle > (float)startAngle || angle < (float)endAngle) ) continue ;
//        
//            // coloquem inteligentment els labels perque la seva distancia als majorticks sigui
//            // identica (minorLength), cool!
//            
//            NSString *str = stringForDouble_withFormat( e, format ) ;
//            textSize = [str sizeWithFont:font] ;
//            
//            CGFloat x = textSize.width ;
//            CGFloat y = textSize.height ;
//            CGFloat xx = fminf( x, fabsf(y/tanf(angle)) ) ;
//            CGFloat yy = fminf( y, fabsf(x*tanf(angle)) ) ;
//            CGFloat rr = sqrtf(xx*xx+yy*yy) ;
//    
//            txtRadius = txtBaseRadius-rr/2 ;
//            tRect.origin.x = center.x + txtRadius*cosf(angle) - x/2;
//            tRect.origin.y = size.height - (center.y + txtRadius*sinf(angle) + y/2) ;
//            tRect.size = textSize ;
//            
//            if ( _isAligned ) tRect.origin = SWAlignPointToDeviceSpace( context, tRect.origin ) ;
//            
//            [str drawInRect:tRect withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentLeft] ;
//        }
//        
//        // label
//        textSize = [labelText sizeWithFont:font] ;
//        float middleAngle = (endAngle + startAngle)/2 ;     // centrat en mig del rang d'angles
//        middleAngle = M_PI/2 ;                          // verticalment centrat
//
//        tRect.origin.x = center.x - txtBaseRadius*cosf(middleAngle)/3 - textSize.width/2;
//        tRect.origin.y = size.height - (center.y + txtBaseRadius*sinf(middleAngle)/3 + textSize.height/2) ;
//        tRect.size = textSize ;
//
//        if ( _isAligned ) tRect.origin = SWAlignPointToDeviceSpace( context, tRect.origin ) ;
//        
//        [labelText drawInRect:tRect withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentLeft] ;
//    }
//    UIGraphicsPopContext();
//}
//
//






// draw
- (void)drawInContext:(CGContextRef)context
{
    CGRect rect = self.bounds ;
    CGSize size = rect.size;
    const CGFloat outerOffset = 2 ;
    const CGFloat majorLength = 8 ;
    const CGFloat minorLength = 5 ;
    const CGFloat rangeOuterOffset = outerOffset ;
    const CGFloat rangeInnerOffset = outerOffset + 4*majorLength ;

    SWGaugeView *v = (SWGaugeView*)_v ;
    double tickInterval = v.majorTickInterval ;
    
    if ( tickInterval <= 0 ) return ;
    
    NSData *ranges = v.ranges;
    NSData *rangeColors = v.rangeColors;
    
    int rangeCount = [ranges length]/sizeof(SWValueRange);  // sera 0 si es nil
    const SWValueRange *cRanges = [ranges bytes];
    
    int rangeColorCount = [rangeColors length]/sizeof(UInt32);  // sera 0 si es nil
    const UInt32 *cRGBs = [rangeColors bytes];
    
    double rBeg = self.rangeBeg ;
    double rEnd = self.rangeEnd ;
    double rLen = rEnd - rBeg ;
    
    if ( rLen <= 0 ) tickInterval = -tickInterval ;   
    
    int minorCount = v.minorTicksPerInterval ;
    NSString *labelText = v.labelText ;
    UIFont *font = v.font ;
    NSString *format = v.format ;
    
    double deadAnglePosition = v.deadAnglePosition;
    double angleRange = v.angleRange;
    double startAngle = deadAnglePosition - (2*M_PI-angleRange)/2;
    double endAngle = startAngle - angleRange;
    
    double aLen = endAngle-startAngle ;
    
    UIColor *textColor = v.textColor ;
    
    CGContextSaveGState( context ) ;
    SWTranslateAndFlipCTM( context, size.height ) ;
    
    CGFloat outerRadius = [v getOuterRadius];
    CGPoint center = [v getCenterFlipped:NO];
    
    for ( int i=0 ; i<rangeCount ; i++ )
    {
        SWValueRange r = cRanges[i];
        
        UInt32 rgb = RedColor;
        if ( i<rangeColorCount ) rgb = cRGBs[i];
        
        CGFloat angleMin = _angleForValue_withRangeBeg_rangeEnd_startAngle_endAngle(r.min, rBeg, rEnd, startAngle, endAngle);
        CGFloat angleMax = _angleForValue_withRangeBeg_rangeEnd_startAngle_endAngle(r.max, rBeg, rEnd, startAngle, endAngle);
        
        CGContextSaveGState(context);
        {
            CGContextAddArc(context, center.x, center.y, outerRadius-rangeInnerOffset, angleMin, angleMin, 0);  // <- coloquem el punt inicial
            CGContextAddArc(context, center.x, center.y, outerRadius-rangeOuterOffset, angleMin, angleMax, angleMin>angleMax);
            CGContextAddArc(context, center.x, center.y, outerRadius-rangeInnerOffset, angleMax, angleMin, angleMax>angleMin);
            CGContextClosePath(context);
        
            CGContextClip(context);
        
            CGFloat colors[] =
            {
                ColorR(rgb), ColorG(rgb), ColorB(rgb), ColorA(rgb),
                ColorR(rgb), ColorG(rgb), ColorB(rgb), 0.0f,
            };
        
            CGColorSpaceRef rgbSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColorComponents(rgbSpace, colors, NULL, 2);
        
            CGContextDrawRadialGradient(context, gradient, center, outerRadius-rangeOuterOffset, center, outerRadius-rangeInnerOffset, 0);
    
            CGGradientRelease(gradient);
            CGColorSpaceRelease(rgbSpace);
        }
        CGContextRestoreGState(context);
    
    }
    
    
    CGFloat outerTickRadius = outerRadius-outerOffset ;
    
    double tickFloor = floor(rBeg/tickInterval) ;
    double firstTick = tickInterval * tickFloor ;
    int majorCount = ceil(rEnd/tickInterval)-tickFloor ;
    
    // major ticks
    UInt8 check = 0;
    for ( int i=0 ; i<=majorCount; i++ )
    {
        double e = firstTick + (tickInterval*i) ;
        
        // el calcul el fem amb double pero la comparacio es fa amb float per considerar iguals valors practicament iguals
        double angle = startAngle + (e-rBeg)*(aLen/rLen) ;
        if ( e == rBeg ) angle = startAngle; // filtrem el cas de angle es nan
        
        if ( aLen > 0 && ((float)angle < (float)startAngle || (float)angle > (float)endAngle) ) continue ;  // float !
        if ( aLen < 0 && ((float)angle > (float)startAngle || (float)angle < (float)endAngle) ) continue ;
        
        CGPoint pBeg, pEnd, ppBeg ;
        pBeg.x = center.x + outerTickRadius*cos(angle) ;
        pBeg.y = center.y + outerTickRadius*sin(angle) ;
        pEnd.x = center.x + (outerTickRadius-majorLength)*cos(angle) ;
        pEnd.y = center.y + (outerTickRadius-majorLength)*sin(angle) ;
        
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

        
        SWMoveToPoint( context, pBeg.x, pBeg.y, NO /*_isAligned*/) ;
        SWAddLineToPoint( context, pEnd.x, pEnd.y, NO /*_isAligned*/ ) ;
    }

    CGContextSetLineWidth( context, 2.0 ) ;
    CGContextSetLineCap( context, kCGLineCapRound ) ;
    CGContextSetStrokeColorWithColor( context, textColor.CGColor ) ;
    CGContextStrokePath( context );
    
    // minor ticks
    double minorAngle = aLen * (tickInterval / rLen) ;
    for ( int i=0 ; i<majorCount /*e <= lastTick-tickInterval*/; i++ )
    {
        double e = firstTick + (tickInterval*i) ;
        double angle = startAngle + (e-rBeg)*(aLen/rLen) ;
        if ( e == rBeg ) angle = startAngle; // filtrem el cas de angle es nan
        
        check = 0;
        for ( int j=1 ; j<minorCount ; j++ )
        {
            double ma = angle + j*(minorAngle/minorCount) ;
            if ( ma != ma ) continue;
            if ( aLen > 0 && ((float)ma < (float)startAngle || (float)ma > (float)endAngle) ) continue ;  // float !
            if ( aLen < 0 && ((float)ma > (float)startAngle || (float)ma < (float)endAngle) ) continue ;
            
            CGPoint pBeg, pEnd, ppBeg ;
            pBeg.x = center.x + outerTickRadius*cos(ma) ;
            pBeg.y = center.y + outerTickRadius*sin(ma) ;
            pEnd.x = center.x + (outerTickRadius-minorLength)*cos(ma) ;
            pEnd.y = center.y + (outerTickRadius-minorLength)*sin(ma) ;
            
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
        
            SWMoveToPoint( context, pBeg.x, pBeg.y, NO /*_isAligned*/) ;
            SWAddLineToPoint( context, pEnd.x, pEnd.y, NO /*_isAligned*/ ) ;
        }
    }
    
    CGContextSetLineWidth( context, 1.0 ) ;
    CGContextSetLineCap( context, kCGLineCapRound ) ;
    CGContextSetStrokeColorWithColor( context, textColor.CGColor ) ;
    CGContextStrokePath( context );
   
labels:
    // labels
    CGContextRestoreGState( context ) ;  // recuperem el estat inicial
    UIGraphicsPushContext( context ) ;
    //CGContextSetFillColorWithColor( context, textColor.CGColor ) ;
    
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle alloc] init];
        textStyle.lineBreakMode = NSLineBreakByClipping;
        textStyle.alignment = NSTextAlignmentLeft;
        
    NSDictionary *attrs = @{
        NSFontAttributeName:font,
        NSParagraphStyleAttributeName:textStyle,
        NSForegroundColorAttributeName:textColor
    };

    CGSize textSize = [v getMaxTextSizeWithAttributes:attrs];
    
    CGFloat txtBaseRadius = outerTickRadius-majorLength-minorLength ;
    CGFloat txtRadius = txtBaseRadius-textSize.width/2 ;
    CGFloat txtSpaceRadius = txtBaseRadius-textSize.height ;
    CGFloat textSpace = SWConvertToViewPort( tickInterval, 0, rEnd-rBeg, 0, txtSpaceRadius*fabsf(aLen) ) ;
    
    if ( textSpace > 1 )
    {
        CGRect tRect ;
        
        int increment = 1 + truncf( textSize.width / textSpace ) ;
        for ( int i=0 ; i<=majorCount ; i+=increment )
        {
            double e = firstTick + (tickInterval*i) ;
            double angle = startAngle + (e-rBeg)*(aLen/rLen) ;
            if ( e == rBeg ) angle = startAngle; // filtrem el cas de angle es nan
        
            if ( aLen > 0 && ((float)angle < (float)startAngle || (float)angle > (float)endAngle) ) continue ;// float !
            if ( aLen < 0 && ((float)angle > (float)startAngle || (float)angle < (float)endAngle) ) continue ;
        
            // coloquem inteligentment els labels perque la seva distancia als majorticks sigui
            // identica (minorLength), cool!
            
            NSString *str = stringForDouble_withFormat( e, format ) ;
            //textSize = [str sizeWithFont:font] ;
            textSize = [str sizeWithAttributes:attrs/*@{NSFontAttributeName:font}*/] ;
            textSize.width = ceil(textSize.width);
            textSize.height = ceil(textSize.height);
            
            CGFloat x = textSize.width ;
            CGFloat y = textSize.height ;
            CGFloat xx = fminf( x, fabsf(y/tan(angle)) ) ;
            CGFloat yy = fminf( y, fabsf(x*tan(angle)) ) ;
            CGFloat rr = sqrtf(xx*xx+yy*yy) ;
    
            txtRadius = txtBaseRadius-rr/2 ;
            tRect.origin.x = center.x + txtRadius*cosf(angle) - x/2;
            tRect.origin.y = size.height - (center.y + txtRadius*sinf(angle) + y/2) ;
            tRect.size = textSize ;
            
            if ( _isAligned ) tRect.origin = SWAlignPointToDeviceSpace( context, tRect.origin ) ;
            
            //[str drawInRect:tRect withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentLeft] ;
            
            [str drawInRect:tRect withAttributes:attrs];
        }
        
        // label
        //textSize = [labelText sizeWithFont:font] ;
        textSize = [labelText sizeWithAttributes:attrs/*@{NSFontAttributeName:font}*/] ;
        textSize.width = ceil(textSize.width);
        textSize.height = ceil(textSize.height);
        
        double middleAngle = (endAngle + startAngle)/2 ;     // centrat en mig del rang d'angles
        middleAngle = M_PI/2 ;                          // verticalment centrat

        tRect.origin.x = center.x - txtBaseRadius*cos(middleAngle)/3 - textSize.width/2;
        tRect.origin.y = size.height - (center.y + txtBaseRadius*sin(middleAngle)/3 + textSize.height/2) ;  // cucut
        tRect.size = textSize ;

        if ( _isAligned ) tRect.origin = SWAlignPointToDeviceSpace( context, tRect.origin ) ;
        
        //[labelText drawInRect:tRect withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentLeft] ;
        
        [labelText drawInRect:tRect withAttributes:attrs];
    }
    UIGraphicsPopContext();

    return ;
}


@end




#pragma mark SWNeedleLayer

@interface SWNeedleLayer : SWLayer
{
    double _angle ;
}

@end


@implementation SWNeedleLayer : SWLayer

//+ (BOOL)needsDisplayForKey:(NSString *)key 
//{
//    return [super needsDisplayForKey:key];
//}
//
//
//// tornem animacions per la propietat
//-(id<CAAction>)actionForKey:(NSString *)key 
//{
//    return [super actionForKey:key] ;
//}
//
//- (id)initWithLayer:(SWGaugeLayer *)layer
//{
//    self = [super initWithLayer:layer] ;
//    if ( self )
//    {
//    }
//    return self ;
//}
//
//- (id)init
//{
//    self = [super init] ;
//    if ( self )
//    {
//    }
//    return self ;
//}

//- (double)_angleForValue:(double)value withRange:(SWRange)range startAngle:(double)startAngle endAngle:(double)endAngle




- (void)updateValueAnimated:(BOOL)animated
{    
    // ho fem amb una animacio explicita
    SWGaugeView *v = (SWGaugeView*)_v ;
    SWRange range = v.range ;
    double value = v.value;
    
//    double startAngle = v.startAngle ;
//    double endAngle = v.endAngle ;
    
    double angleRange = v.angleRange;
    double startAngle = M_PI - (2*M_PI-angleRange)/2;
    double endAngle = startAngle - angleRange;
    //_angle = [self _angleForValue:value withRange:range startAngle:startAngle endAngle:endAngle];
    _angle = _angleForValue_withRangeBeg_rangeEnd_startAngle_endAngle(value, range.min, range.max, startAngle, endAngle);
    
    NSNumber *new = [NSNumber numberWithFloat:-_angle] ;
    [self setValue:new forKeyPath:@"transform.rotation"] ;
    
    if ( animated )
    {
        //CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        CABasicAnimation *animation = [[CABasicAnimation alloc] init];
        animation.duration = 0.5;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut] ;
        //animation.fromValue = [NSNumber numberWithFloat:-oldAngle] ;  // utilitzem el vell per forcar la rotacio en el sentit adequat
        animation.fromValue = [[self presentationLayer] valueForKeyPath:@"transform.rotation"];
        animation.toValue = new;
        [self addAnimation:animation forKey:@"transform.rotation"];
    }
}

// draw
- (void)drawInContext:(CGContextRef)context
{
    CGRect rect = self.bounds ;
    CGSize size = rect.size;
    
    SWGaugeView *v = (SWGaugeView*)_v ;
    
    UIColor *needleColor = v.needleColor ;
    CGFloat needleWidth = 3 ;
    CGFloat needleInset = 16 ;
    
    //NSLog( @"position: %g,%g", self.position.x, self.position.y ) ;
    
    SWTranslateAndFlipCTM( context, size.height ) ;
	
    CGContextSetShadowWithColor( context, CGSizeMake(0,0), 2, [UIColor blackColor].CGColor /*textColor.CGColor*/ ) ;
    CGContextSetLineCap( context, kCGLineCapRound ) ;
	CGContextSetFillColorWithColor(context, needleColor.CGColor);
	CGContextSetStrokeColorWithColor(context, needleColor.CGColor);
	CGContextSetLineWidth(context, needleWidth );
	
	CGFloat centerX = size.width / 2.0;
	CGFloat centerY = size.height / 2.0;
   // CGFloat myOuterRadius = size.width / 2.0;
    CGFloat outerRadius = [v getOuterRadius] ;
    CGFloat endX = centerX + outerRadius - needleInset ;
	
	CGContextBeginPath(context);
    SWMoveToPoint( context, centerX, centerY, NO ) ;
    SWAddLineToPoint( context, endX, centerY, NO ) ;
	CGContextStrokePath(context);
    
	CGFloat ellipseRadius = needleWidth * 2.0;
    CGRect centerDotRect = CGRectMake(centerX - ellipseRadius, centerY - ellipseRadius, ellipseRadius * 2.0, ellipseRadius * 2.0) ;
	CGContextFillEllipseInRect(context, centerDotRect);
}

@end

#pragma mark SWNeedleRotatedLayer

// En aquest layer presentem el SWNeedleLayer. Aquest layer esta rotat de manera que en el SWNeedleLayer
// nomes actuem amb angles de -180 a +180 lo qual posibilita el funcionament correcte del presentation layer
@interface SWNeedleRotatedLayer : SWLayer
@end

@implementation SWNeedleRotatedLayer

- (void)layoutSublayers
{
    [super layoutSublayers];
    
    Class needleLayerClass = [SWNeedleLayer class];
        
    for ( SWLayer *layer in self.sublayers )
    {
        if ( [layer isKindOfClass:needleLayerClass] )
        {
            CGSize size = self.bounds.size;
            [layer setBounds:CGRectMake(0,0,size.width,size.height)];
            [layer setPosition:CGPointMake(size.width/2,size.height/2)];
          //  [(id)layer updateValueAnimated:NO];    // atencio tornar a posar
        }
        else
        {
            // no hauria de passar mai
            CGRect bounds = self.bounds;
            layer.frame = bounds;
        }
        [layer setNeedsLayout];
    }
}

@end



#pragma mark SWGaugeBackLayer
@interface SWGaugeBackLayer : SWLayer
@end

@implementation SWGaugeBackLayer

// draw
- (void)drawInContextVV:(CGContextRef)context
{
    //[super drawInContext:context] ;

    CGRect rect = self.bounds ;
    CGSize size = rect.size;
    
    SWGaugeView *v = (SWGaugeView*)_v ;
    
    UIColor *circleColor = v.tintsColor ;
    UIColor *borderColor = v.borderColor ;
    
    CGContextSaveGState( context ) ;
    SWTranslateAndFlipCTM( context, size.height ) ;
    
    CGFloat outerRadius = [v getOuterRadius] ;
    CGPoint center = [v getCenterFlipped:NO] ;
    
    CGRect circleRect ;
    circleRect.origin.x = center.x - outerRadius ;
    circleRect.origin.y = center.y - outerRadius ;
    circleRect.size.width = outerRadius*2 ;
    circleRect.size.height = outerRadius*2 ;
    
    //CGRect borderRect = CGRectInset(circleRect, -2, -2 ) ;
    
    // cercle interior
    CGContextSaveGState( context ) ;
    CGContextAddEllipseInRect( context, circleRect ) ;
    CGContextClip( context ) ;
    
    drawSingleGradientRect( context, rect, circleColor.CGColor, DrawGradientDirectionFlippedDown ) ;
    CGContextRestoreGState( context ) ;
    
    // clipem la sombra que apareixeria a fora
    CGContextAddEllipseInRect( context, CGRectInset(circleRect, -4.5, -4.5 ) ) ;
    CGContextClip( context ) ;
    
    // dibuixem el borde amb sombra
    CGContextSetStrokeColorWithColor( context, borderColor.CGColor ) ;
    CGContextSetLineWidth( context, 5 ) ;
    
    //CGContextSetLineCap( context, kCGLineCapRound ) ;
    CGContextSetLineJoin( context, kCGLineJoinRound ) ;
    CGContextSetShadowWithColor( context, CGSizeMake(0,0), 5, [UIColor blackColor].CGColor ) ;
    CGContextAddEllipseInRect( context, CGRectInset(circleRect, -2, -2 ) ) ;
    CGContextStrokePath( context ) ;
}




// draw
- (void)drawInContext:(CGContextRef)context
{
    //[super drawInContext:context] ;

    CGRect rect = self.bounds ;
    CGSize size = rect.size;
    
    SWGaugeView *v = (SWGaugeView*)_v ;
    
    double deadAnglePosition = v.deadAnglePosition;
    double angleRange = v.angleRange;
//    double startAngle = deadAnglePosition - ((2*M_PI-angleRange)/2 - M_PI/4);
//    double endAngle = deadAnglePosition + ((2*M_PI-angleRange)/2 - M_PI/4);
    
    if ( fabs(angleRange) < M_PI )
        angleRange = M_PI;  // <<-- es indiferent si es positiu o negatiu doncs la direccio de dibuix es irrellevant per el background
    
    double deadAngleOffset = (2*M_PI-angleRange)/3;
    double startAngle = deadAnglePosition - deadAngleOffset;
    double endAngle = deadAnglePosition + deadAngleOffset;
    
    
    UIColor *circleColor = v.tintsColor ;
    UIColor *borderColor = v.borderColor ;
    
    //CGContextSaveGState( context ) ;
    SWTranslateAndFlipCTM( context, size.height ) ;
    
    CGFloat outerRadius = [v getOuterRadius] ;
    CGPoint center = [v getCenterFlipped:NO] ;
    
    // part Interior
    CGContextSaveGState( context ) ;
    {
        CGContextAddArc(context, center.x, center.y, outerRadius, startAngle, endAngle, endAngle>startAngle);
        CGContextClip( context ) ;
    
        drawSingleGradientRect( context, rect, circleColor.CGColor, DrawGradientDirectionFlippedDown ) ;
    }
    CGContextRestoreGState( context ) ;
    
    CGContextSaveGState( context ) ;
    {
        // clipem la sombra que apareixeria a fora
        CGContextAddArc(context, center.x, center.y, outerRadius /*+ 4.5*/, startAngle, endAngle, endAngle>startAngle);
        CGContextClip( context ) ;
    
        // dibuixem la sombra
        CGContextSetStrokeColorWithColor( context, borderColor.CGColor ) ;
        CGContextSetLineWidth( context, 5 ) ;
        CGContextSetShadowWithColor( context, CGSizeMake(0,0), 5, [UIColor blackColor].CGColor ) ;
        CGContextAddArc(context, center.x, center.y, outerRadius + 2, startAngle, endAngle, endAngle>startAngle);
        CGContextClosePath(context);
        CGContextStrokePath( context ) ;
    }
    CGContextRestoreGState( context ) ;
    
    // dibuixem el borde
    CGContextSetStrokeColorWithColor( context, borderColor.CGColor ) ;
    CGContextSetLineWidth( context, 5 ) ;
    CGContextAddArc(context, center.x, center.y, outerRadius + 2, startAngle, endAngle, endAngle>startAngle);
    CGContextClosePath(context);
    CGContextStrokePath( context ) ;
    
    
//    CGRect circleRect ;
//    circleRect.origin.x = center.x - outerRadius ;
//    circleRect.origin.y = center.y - outerRadius ;
//    circleRect.size.width = outerRadius*2 ;
//    circleRect.size.height = outerRadius*2 ;
//    
//    //CGRect borderRect = CGRectInset(circleRect, -2, -2 ) ;
//    
//    // cercle interior
//    CGContextSaveGState( context ) ;
//    {
//        CGContextAddEllipseInRect( context, circleRect ) ;
//        CGContextClip( context ) ;
//    
//        drawSingleGradientRect( context, rect, circleColor.CGColor, DrawGradientDirectionFlippedDown ) ;
//    }
//    CGContextRestoreGState( context ) ;
//    
//    // clipem la sombra que apareixeria a fora
//    CGContextAddEllipseInRect( context, CGRectInset(circleRect, -4.5, -4.5 ) ) ;
//    CGContextClip( context ) ;
//    
//    // dibuixem el borde amb sombra
//    CGContextSetStrokeColorWithColor( context, borderColor.CGColor ) ;
//    CGContextSetLineWidth( context, 5 ) ;
//    CGContextSetShadowWithColor( context, CGSizeMake(0,0), 5, [UIColor blackColor].CGColor ) ;
//    CGContextAddEllipseInRect( context, CGRectInset(circleRect, -2, -2 ) ) ;
//    CGContextStrokePath( context ) ;
}

@end



#pragma mark SWGaugeViewLayer

@interface SWGaugeViewLayer : SWLayer
@end


@implementation SWGaugeViewLayer

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
    Class needleRotatedLayerClass = [SWNeedleRotatedLayer class] ;
    
    for ( SWLayer *layer in self.sublayers )
    {
        if ( [layer isKindOfClass:needleRotatedLayerClass] )
        {
            SWGaugeView *v = (SWGaugeView*)_v ;
            CGFloat outerRadius = [v getOuterRadius] ;
            CGPoint center = [v getCenterFlipped:YES] ;
            layer.bounds = CGRectMake(0, 0, outerRadius*2, outerRadius*2);
            layer.position = center;
        }
        else
        {
            layer.frame = bounds ;
        }
        [layer setNeedsLayout] ;
    }
}

@end




@implementation SWGaugeView
{
    SWGaugeBackLayer *_backLayer ;
    SWGaugeLayer *_gaugeLayer ;
    SWNeedleRotatedLayer *_needleRotatedLayer;
    SWNeedleLayer *_needleLayer ;
}

+ (Class)layerClass
{
    return [SWGaugeViewLayer class] ;
}

@synthesize value = _value ;
@synthesize range = _range ;
//@synthesize startAngle = _startAngle ;
//@synthesize endAngle = _endAngle ;
@synthesize deadAnglePosition = _deadAnglePosition;
@synthesize angleRange = _angleRange;
@synthesize majorTickInterval = _majorTickInterval ;
@synthesize minorTicksPerInterval = _minorTicksPerInterval ;
@synthesize insets = _insets ;
@synthesize font = _font ;
@synthesize format = _format ;

@synthesize needleColor = _needleColor ;
@synthesize tintsColor = _tintsColor ;
@synthesize borderColor = _borderColor ;
@synthesize textColor = _textColor ;
@synthesize contrastColor = _contrastColor ;

@synthesize labelText = _labelText ;
@synthesize gaugeStyle = _gaugeStyle;


- (void)_doInit
{
    SWGaugeViewLayer *layer = (id)[self layer] ;
    [layer setView:self] ;
    
    _backLayer = [[SWGaugeBackLayer alloc] init] ;
    [_backLayer setView:self] ;
    [layer addSublayer:_backLayer] ;
    
    _gaugeLayer = [[SWGaugeLayer alloc] init] ;
    [_gaugeLayer setView:self] ;
    [layer addSublayer:_gaugeLayer] ;
    
    _needleRotatedLayer = [[SWNeedleRotatedLayer alloc] init];
    [_needleRotatedLayer setView:self];
    [layer addSublayer:_needleRotatedLayer];
    
    _needleLayer = [[SWNeedleLayer alloc] init] ;
    [_needleLayer setView:self] ;
    [_needleRotatedLayer addSublayer:_needleLayer] ;
    
    _needleColor = [UIColor redColor] ;
    _font = [UIFont boldSystemFontOfSize:13] ;
    _format = @"" ;
    
    [self setTintsColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0]] ;
    //[self setTintColor:[UIColor blackColor]] ;
    _borderColor = [UIColor brownColor] ;
    _labelText = @"" ;

    _insets = UIEdgeInsetsMake( 8, 8, 8, 8 ) ;
    
    
    _angleRange = 2*M_PI-M_PI/2; 
    _deadAnglePosition = -M_PI/2;
    
//    _angleRange = 2*M_PI-M_PI/8;
//    _deadAnglePosition = M_PI/2;
    
//    _startAngle = M_PI + M_PI/4 ;
//    _endAngle = -M_PI/4 ;
    
    NSNumber *new = [NSNumber numberWithFloat:M_PI-_deadAnglePosition];
    [_needleRotatedLayer setValue:new forKeyPath:@"transform.rotation"];
    
//    _startAngle = M_PI + M_PI/8 ;
//    _endAngle = -M_PI/4 ;
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

- (void)setRange:(SWRange)range animated:(BOOL)animated
{
    _range = range;
    [_needleLayer updateValueAnimated:animated];
    [_gaugeLayer setRange:range animated:animated];
}


- (void)setRanges:(NSData*)ranges
{
    _ranges = ranges;
    [_gaugeLayer setNeedsDisplay];
}

- (void)setRangeRgbColors:(NSData *)rangeColors
{
    _rangeColors = rangeColors;
    [_gaugeLayer setNeedsDisplay];
}

- (void)setMajorTickInterval:(double)majorTickInterval
{
    _majorTickInterval = majorTickInterval;
    [_gaugeLayer setNeedsDisplay];
}

- (void)setMinorTicksPerInterval:(int)minorTicksPerInterval
{
    _minorTicksPerInterval = minorTicksPerInterval;
    [_gaugeLayer setNeedsDisplay];
}

- (void)setFormat:(NSString *)format
{
    _format = format;
    [_gaugeLayer setNeedsDisplay];
}

- (void)setLabelText:(NSString *)text
{
    _labelText = text;
    [_gaugeLayer setNeedsDisplay];
}

- (void)setValue:(double)value animated:(BOOL)animated
{
    if ( _value == value )
        return;
    
    _value = value;
    //NSLog( @"value:%g", value );
    [_needleLayer updateValueAnimated:animated];
}

- (void)setAngleRange:(double)angleRange
{
    if ( angleRange > M_PI*2-0.001 )   // <-- afegim una petita tolerancia per no trencar el funcionament de 
        angleRange = M_PI*2-0.001;
    
    if ( angleRange < -M_PI*2+0.001 )
        angleRange = -M_PI*2+0.001;
    
    _angleRange = angleRange;
    [_needleLayer updateValueAnimated:NO];
    [_gaugeLayer setNeedsDisplay];
    [_backLayer setNeedsDisplay];
}

- (void)setDeadAnglePosition:(double)deadAnglePosition
{
    _deadAnglePosition = deadAnglePosition;
    NSNumber *new = [NSNumber numberWithFloat:M_PI-_deadAnglePosition];
    [_needleRotatedLayer setValue:new forKeyPath:@"transform.rotation"];
    [_gaugeLayer setNeedsDisplay];
    [_backLayer setNeedsDisplay];
}

- (void)setTintsColor:(UIColor*)color
{
    _tintsColor = color;
    _textColor = contrastColorForUIColor(color);
    [_backLayer setNeedsDisplay];
    [_gaugeLayer setNeedsDisplay];
}

- (void)setBorderColor:(UIColor*)color
{
    _borderColor = color;
    [_backLayer setNeedsDisplay];
}

- (void)setBackgroundColor:(UIColor *)color
{
    [super setBackgroundColor:color];
//    _contrastColor = contrastColorForUIColor(color);
//    [_backLayer setNeedsDisplay];
}

- (void)setNeedleColor:(UIColor *)needleColor
{
    _needleColor = needleColor;
    [_needleLayer setNeedsDisplay];
}


@end
