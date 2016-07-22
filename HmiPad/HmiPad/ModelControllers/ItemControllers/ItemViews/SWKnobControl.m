//
//  SWKnobControl.m
//  HmiPad
//
//  Created by Lluch Joan on 26/06/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "Drawing.h"
#import "SWColor.h"

#import "SWKnobControl.h"
#import "SWValue.h"

#import "SWContrastedViewProtocol.h"

@interface SWKnobControl()<SWContrastedViewProtocol>

@property (nonatomic, readonly) UIEdgeInsets insets;
@property (nonatomic, readonly) UIColor *contrastColor;
@property (nonatomic, readonly) UIColor *labelColor;
@property (nonatomic, readonly) UIColor *highTintColor;
@property (nonatomic, readonly) UIFont *font;
@property (nonatomic, readonly) SWRange range;
@property (nonatomic, readonly) double angleRange;
@property (nonatomic, readonly) double deadAnglePosition;
//@property (nonatomic, readonly) double startAngle;  // depen dels anteriors (es pot fer un macro)
//@property (nonatomic, readonly) double endAngle;    // depen dels anteriors (es pot fer un macro)

- (CGFloat)getOuterRadius;
//- (CGFloat)getOuterRadiusForSize:(CGSize)size;
- (CGPoint)getCenterFlipped:(BOOL)isFlipped;
//- (CGRect)getAspectFitFrameFlipped:(BOOL)isflipped;
- (CGSize)getMaxTextSizeWithAttributes:(NSDictionary*)attrs;

@end


#pragma mark SWKnobLayer

@interface SWKnobLayer : SWLayer

@property (nonatomic, assign) double rangeBeg;
@property (nonatomic, assign) double rangeEnd;

@end


@implementation SWKnobLayer

@dynamic rangeBeg;
@dynamic rangeEnd;

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
        if ( !_isAnimated ) return nil;
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:key];
        animation.fromValue = [[self presentationLayer] valueForKey:key];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        animation.duration = 0.3;
        return animation;
    }
    return [super actionForKey:key];
}

- (id)initWithLayer:(SWKnobLayer *)layer
{
    self = [super initWithLayer:layer];
    if ( self )
    {
        self.rangeEnd = layer.rangeEnd;
        self.rangeBeg = layer.rangeBeg;
    }
    return self;
}

- (id)init
{
    self = [super init];
    if ( self )
    {
    }
    return self;
}


- (void)setRange:(SWRange)range animated:(BOOL)animated
{
    [self setAnimated:animated];
    self.rangeBeg = range.min;
    self.rangeEnd = range.max;
}

// draw
- (void)drawInContext:(CGContextRef)context
{

    CGRect rect = self.bounds;
    CGSize size = rect.size;
    CGFloat outerOffset = -7;
    CGFloat majorLength = -8;
    CGFloat minorLength = -5;

    SWKnobControl *v = (SWKnobControl*)_v;
    double tickInterval = v.majorTickInterval;

    if ( tickInterval <= 0 ) return;
    
    double rBeg = self.rangeBeg;
    double rEnd = self.rangeEnd;
    double rLen = rEnd - rBeg;
    
    if ( rLen <= 0 ) tickInterval = -tickInterval ;   
    
    int minorCount = v.minorTicksPerInterval;
    NSString *labelText = v.labelText;
    UIFont *font = v.font;
    NSString *format = v.format;
    
//    double startAngle = v.startAngle;
//    double endAngle = v.endAngle;
    
    double deadAnglePosition = v.deadAnglePosition;
    double angleRange = v.angleRange;
    double startAngle = deadAnglePosition - (2*M_PI-angleRange)/2;
    double endAngle = startAngle - angleRange;
    
    
    double aLen = endAngle-startAngle;
    
    UIColor *textColor = v.contrastColor;
    UIColor *labelColor = v.labelColor;
    
    
    CGContextSaveGState( context );
    SWTranslateAndFlipCTM( context, size.height );
    
    CGFloat outerRadius = [v getOuterRadius];
    CGPoint center = [v getCenterFlipped:NO];
//    CGPoint center;
//    center.x = size.width/2;
//    center.y = size.height/2;
    CGFloat outerTickRadius = outerRadius-outerOffset;
    
    double tickFloor = floor(rBeg/tickInterval);
    double firstTick = tickInterval * tickFloor;
    int majorCount = ceil(rEnd/tickInterval)-tickFloor;
    
    UInt8 check = 0;
    for ( int i=0 ; i<=majorCount ; i++ )
    {
        double e = firstTick + (tickInterval*i);
        
        // el calcul el fem amb double pero la comparacio es fa amb float per considerar iguals valors practicament iguals
        double angle = startAngle + (e-rBeg)*(aLen/rLen) ;
        if ( angle != angle ) continue;
        
        if ( aLen > 0 && ((float)angle < (float)startAngle || (float)angle > (float)endAngle) ) continue;// float !
        if ( aLen < 0 && ((float)angle > (float)startAngle || (float)angle < (float)endAngle) ) continue;
        
        CGPoint pBeg, pEnd, ppBeg;
        pBeg.x = center.x + outerTickRadius*cos(angle);
        pBeg.y = center.y + outerTickRadius*sin(angle);
        pEnd.x = center.x + (outerTickRadius-majorLength)*cos(angle);
        pEnd.y = center.y + (outerTickRadius-majorLength)*sin(angle);
        
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
        
        SWMoveToPoint( context, pBeg.x, pBeg.y, NO /*_isAligned*/);
        SWAddLineToPoint( context, pEnd.x, pEnd.y, NO /*_isAligned*/ );
    }

    CGContextSetLineWidth( context, 2.0 );
    CGContextSetLineCap( context, kCGLineCapRound );
    CGContextSetStrokeColorWithColor( context, textColor.CGColor );
    CGContextStrokePath( context );
    
    // minor ticks
    double minorAngle = aLen * (tickInterval / rLen);
    
    // minor ticks
    for ( int i=0 ; i<majorCount ; i++ )
    {
        double e = firstTick + (tickInterval*i);
        double angle = startAngle + (e-rBeg)*(aLen/rLen);
        
        check = 0 ;
        for ( int j=1 ; j<minorCount ; j++ )
        {
            double ma = angle + j*(minorAngle/minorCount) ;
            if ( ma != ma ) continue;
            if ( aLen > 0 && ((float)ma < (float)startAngle || (float)ma > (float)endAngle) ) continue;// float !
            if ( aLen < 0 && ((float)ma > (float)startAngle || (float)ma < (float)endAngle) ) continue;
            
            CGPoint pBeg, pEnd, ppBeg;
            pBeg.x = center.x + outerTickRadius*cos(ma);
            pBeg.y = center.y + outerTickRadius*sin(ma);
            pEnd.x = center.x + (outerTickRadius-minorLength)*cos(ma);
            pEnd.y = center.y + (outerTickRadius-minorLength)*sin(ma);
            
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
        
            SWMoveToPoint( context, pBeg.x, pBeg.y, NO /*_isAligned*/);
            SWAddLineToPoint( context, pEnd.x, pEnd.y, NO /*_isAligned*/ );
        
        }
    }
    
    CGContextSetLineWidth( context, 1.0 );
    CGContextSetLineCap( context, kCGLineCapRound );
    CGContextSetStrokeColorWithColor( context, textColor.CGColor );
    CGContextStrokePath( context );
 
labels:   
    // labels
    CGContextRestoreGState( context ) ;  // recuperem el estat inicial
    UIGraphicsPushContext( context );
    //CGContextSetFillColorWithColor( context, textColor.CGColor );
    
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle alloc] init];
        textStyle.lineBreakMode = NSLineBreakByClipping;
        textStyle.alignment = NSTextAlignmentLeft;
        
    NSDictionary *attrs = @{
        NSFontAttributeName:font,
        NSParagraphStyleAttributeName:textStyle,
        NSForegroundColorAttributeName:textColor
    };
    
    CGSize textSize = [v getMaxTextSizeWithAttributes:attrs];
    textSize.width = ceil(textSize.width);
    textSize.height = ceil(textSize.height);
    
    CGFloat txtBaseRadius = outerTickRadius-majorLength-minorLength;
    CGFloat txtRadius = txtBaseRadius+textSize.width/2 ;
    CGFloat txtSpaceRadius = txtBaseRadius+textSize.height ;
    CGFloat textSpace = SWConvertToViewPort( tickInterval, 0, rEnd-rBeg, 0, txtSpaceRadius*fabsf(aLen) );
    
    if ( textSpace > 1 )
    {
        CGRect tRect;
        
        int increment = 1 + truncf( textSize.width / textSpace );
        for ( int i=0 ; i<=majorCount && check<3 ; i+=increment )
        {
            double e = firstTick + (tickInterval*i);
            double angle = startAngle + (e-rBeg)*(aLen/rLen) ;
            if ( angle != angle ) continue;
        
            if ( aLen > 0 && ((float)angle < (float)startAngle || (float)angle > (float)endAngle) ) continue;// float !
            if ( aLen < 0 && ((float)angle > (float)startAngle || (float)angle < (float)endAngle) ) continue;
        
            // coloquem inteligentment els labels perque la seva distancia als majorticks sigui
            // identica (minorLength), cool!
            
            NSString *str = stringForDouble_withFormat( e, format );
            //textSize = [str sizeWithFont:font];
            textSize = [str sizeWithAttributes:attrs/*@{NSFontAttributeName:font}*/];
            textSize.width = ceil(textSize.width);
            textSize.height = ceil(textSize.height);
            
            CGFloat x = textSize.width;
            CGFloat y = textSize.height;
            CGFloat xx = fminf( x, fabs(y/tan(angle)) );
            CGFloat yy = fminf( y, fabs(x*tan(angle)) );
            CGFloat rr = sqrtf(xx*xx+yy*yy);
    
            txtRadius = txtBaseRadius+rr/2 ;
            tRect.origin.x = center.x + txtRadius*cos(angle) - x/2;
            tRect.origin.y = size.height - (center.y + txtRadius*sin(angle) + y/2);
            tRect.size = textSize;
            
            if ( _isAligned ) tRect.origin = SWAlignPointToDeviceSpace( context, tRect.origin );
            
            //[str drawInRect:tRect withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentLeft];
            
            [str drawInRect:tRect withAttributes:attrs];
        }
        
        CGContextSetFillColorWithColor( context, labelColor.CGColor );
        //textSize = [labelText sizeWithFont:font];
        textSize = [labelText sizeWithAttributes:attrs/*@{NSFontAttributeName:font}*/];
        textSize.width = ceil(textSize.width);
        textSize.height = ceil(textSize.height);

        tRect.origin.x = center.x - textSize.width/2;
        tRect.origin.y = size.height - (center.y + textSize.height/2);
        tRect.size = textSize;

        if ( _isAligned ) tRect.origin = SWAlignPointToDeviceSpace( context, tRect.origin );
        
        //[labelText drawInRect:tRect withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentLeft];
        
        [labelText drawInRect:tRect withAttributes:attrs];
    }
    UIGraphicsPopContext();

    return;
}


@end





#pragma mark SWThumbLayer

@interface SWThumbLayer : SWLayer
{
    double _angle;
}

@end


@implementation SWThumbLayer : SWLayer

- (double)_angleForValue:(double)value withRange:(SWRange)range startAngle:(double)startAngle endAngle:(double)endAngle
{
    double newAngle = startAngle + (value-range.min)*((endAngle-startAngle)/(range.max-range.min));
    
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
    
    if ( value == range.min) newAngle = startAngle; // filtrem el cas de newAngle es nan
    return newAngle;
}


- (void)updateValueAnimated:(BOOL)animated
{
    SWKnobControl *v = (SWKnobControl*)_v;
    
    
    SWRange range = v.range;
    double value = v.value;
    SWKnobThumbStyle style = v.thumbStyle;
    
    if ( style == SWKnobThumbStyleSegment )
    {
    
        double angleRange = v.angleRange;
        double startAngle = M_PI - (2*M_PI-angleRange)/2;
        double endAngle = startAngle - angleRange;
        _angle = [self _angleForValue:value withRange:range startAngle:startAngle endAngle:endAngle];
        
        NSNumber *new = [NSNumber numberWithFloat:-_angle];
        [self setValue:new forKeyPath:@"transform.rotation"];
        
//        NSLog( @"old: %g", -oldAngle/M_PI*180);
//        //NSLog( @"lay: %g", [[[self presentationLayer] valueForKeyPath:@"transform.rotation"]floatValue]/M_PI*180);
//        CGFloat layerAngle = [[[self presentationLayer] valueForKeyPath:@"transform.rotation"] floatValue];
//        NSLog( @"lay: %g", layerAngle/M_PI*180 ) ;
        
//        NSLog( @"cos:%g,sin:%g", cosf(-oldAngle), sinf(-oldAngle));
//        NSLog( @"%g,%g,%g,%g", td.m11, td.m12, td.m13, td.m14 );
//        NSLog( @"%g,%g,%g,%g", td.m21, td.m22, td.m23, td.m24 );
//        NSLog( @"%g,%g,%g,%g", td.m31, td.m32, td.m33, td.m34 );
//        NSLog( @"%g,%g,%g,%g", td.m41, td.m42, td.m43, td.m44 );
        
    
//        CGAffineTransform at = CATransform3DGetAffineTransform(td);
//        NSLog( @"value: %@", transformValue);
//        NSLog( @"%g,%g", at.a, at.b );
//        NSLog( @"%g,%g", at.c, at.d );
//        NSLog( @"%g,%g", at.tx, at.ty );
//        NSLog( @"lay: %g", atan2f(at.b, at.a)/M_PI*180 );
//        NSLog( @"new: %g", -_angle/M_PI*180);
        if ( animated )
        {
        
            // El seguent codi evita rebots deguts a actualitzacions mes rapides que la animacio. Lo ideal seria partir del [[self presentationLayer] valueForKeyPath:@"transform.rotation"] pero desafortunadament el angle que torna no te en compte el quadrant. Com a workaround el que fem es determinar si el presentation layer esta en un angle igual al anterior (independentment del quadrant) i nomes en aquest cas animem el moviment. El resultat es que per actualitzacions rapides el posicionament sera instantani. Sense aquesta comprovacio el moviment partiria del angle anterior amb un rebot enrera abans d'iniciar l'animacio
//            CATransform3D td;
//            NSValue *transformValue = [[self presentationLayer] valueForKey:@"transform"];
//            [transformValue getValue:&td];
        
           // if ( fabsf(cosf(-oldAngle) - td.m11)<0.0001 && fabsf(sinf(-oldAngle) - td.m12)<0.0001 )
            {
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
                animation.duration = 0.8;
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                //animation.fromValue = [NSNumber numberWithFloat:-oldAngle] ;  // utilitzem el vell per forcar la rotacio en el sentit adequat
                animation.fromValue = [[self presentationLayer] valueForKeyPath:@"transform.rotation"];
                animation.toValue = new;
                [self addAnimation:animation forKey:nil];
            }
        }
        
    }
    else if ( style == SWKnobThumbStyleThumb )
    {
//        double startAngle = v.startAngle;
//        double endAngle = v.endAngle;

        double deadAnglePosition = v.deadAnglePosition;
        double angleRange = v.angleRange;
        double startAngle = deadAnglePosition - (2*M_PI-angleRange)/2;
        double endAngle = startAngle - angleRange;
        
        _angle = [self _angleForValue:value withRange:range startAngle:startAngle endAngle:endAngle];
    
        CGFloat outerRadius = [v getOuterRadius];
        CGSize size = self.bounds.size;
        CGSize supersize = self.superlayer.bounds.size;
        //CGPoint center = [v getCenterFlipped:YES];
        CGPoint center;
        center.x = supersize.width/2;
        center.y = supersize.height/2;
        CGFloat thumbRadius = outerRadius-(0.667f*size.width);
    
        CGPoint pos;
        pos.x = center.x + thumbRadius*cosf(_angle);
        pos.y = center.y - thumbRadius*sinf(_angle); // y invertida cocoa touch

        [self setPosition:pos] ;   // TODO: animate position along a path (arch with oldAngle, newAngle, centerX, centerY)
    }
}



// draw
- (void)drawInContext:(CGContextRef)context
{
    CGRect rect = self.bounds;
    CGSize size = rect.size;
    
    SWKnobControl *v = (SWKnobControl*)_v;
    
    UIColor *needleColor = v.needleColor;
    SWKnobThumbStyle style = v.thumbStyle;
    
    //NSLog( @"position: %g,%g", self.position.x, self.position.y );
    //NSLog( @"size: %g,%g", size.width, size.height ) ;
    
    SWTranslateAndFlipCTM( context, size.height );
	
	CGFloat centerX = size.width / 2.0;
	CGFloat centerY = size.height / 2.0;
    

    if ( style == SWKnobThumbStyleSegment )
    {

        CGFloat needleWidth = 5 ;
        CGFloat needleInset = 10 ;
        CGContextSetLineCap( context, kCGLineCapRound ) ;
        CGContextSetStrokeColorWithColor(context, needleColor.CGColor);
        CGContextSetLineWidth(context, needleWidth );
        CGFloat outerRadius = [v getOuterRadius] ;
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, &CGAffineTransformIdentity, centerX+outerRadius/3, centerY);
        CGPathAddLineToPoint(path, &CGAffineTransformIdentity, centerX+outerRadius-needleInset, centerY);
        
        CGContextSetLineWidth(context, needleWidth+1 );
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextSetShadowWithColor( context, CGSizeMake(0,0), 5, [UIColor colorWithWhite:0 alpha:0.5].CGColor /*textColor.CGColor*/ ) ;
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
        
        CGContextSetLineWidth(context, needleWidth );
        CGContextSetStrokeColorWithColor(context, needleColor.CGColor);
        //CGContextSetShadowWithColor( context, CGSizeMake(0,0), 0, NULL ) ;
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
        
        CGPathRelease(path);
    }
    
    else if ( style == SWKnobThumbStyleThumb )
    {
        CGFloat thumbInset = 2;
        CGFloat thumbRadius = size.width / 2.0 - thumbInset;
        CGRect thumbRect = CGRectMake(centerX - thumbRadius, centerY - thumbRadius, thumbRadius*2.0, thumbRadius*2.0);
        CGContextAddEllipseInRect(context, thumbRect);
        CGContextClip(context);
    
        UIColor *color1 = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0] ;  //+fosc
        //UIColor *color2 = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] ;  //+clar 
        drawLinearGradientRect(context, thumbRect, color1.CGColor, needleColor.CGColor, DrawGradientDirectionFlippedDownRight);
    }
}

@end




#pragma mark SWThumbRotatedLayer

// En aquest layer presentem el SWThumbLayer. Aquest layer esta rotat de manera que
@interface SWThumbRotatedLayer : SWLayer
@end

@implementation SWThumbRotatedLayer

- (void)layoutSublayers
{
    [super layoutSublayers];
    
    Class thumbLayerClass = [SWThumbLayer class];
        
    for ( SWLayer *layer in self.sublayers )
    {
        if ( [layer isKindOfClass:thumbLayerClass] )
        {
            SWKnobControl *v = (SWKnobControl*)_v;
            SWKnobThumbStyle style = v.thumbStyle;
            if ( style == SWKnobThumbStyleSegment )
            {
                CGSize size = self.bounds.size;
                //layer.frame = bounds;
                [layer setBounds:CGRectMake(0,0,size.width,size.height)];
                [layer setPosition:CGPointMake(size.width/2,size.height/2)];
                // la rotacio la posa updateValue
            }
            else if ( style == SWKnobThumbStyleThumb )
            {
                CGFloat outerRadius = [v getOuterRadius] ;
                CGFloat d = 44;
                if ( outerRadius*0.9f < 44 ) d = outerRadius*0.9f;
                [layer setBounds:CGRectMake(0, 0, d, d)];
                [layer setTransform:CATransform3DIdentity];
                // la posicio la posa updateValue
            }
            
            [(id)layer updateValueAnimated:NO];    // atencio tornar a posar
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




#pragma mark SWKnobBackLayer
@interface SWKnobBackLayer : SWLayer
@end

@implementation SWKnobBackLayer

// draw
- (void)drawInContext:(CGContextRef)context
{
    //[super drawInContext:context];

    CGRect rect = self.bounds;
    CGSize size = rect.size;
    
    SWKnobControl *v = (SWKnobControl*)_v;
    UIColor *circleColor = v.tintsColor;
    UIColor *highColor = v.highTintColor;
    UIColor *borderColor = v.borderColor;
    UIColor *contrastColor = v.contrastColor;
    
    SWTranslateAndFlipCTM( context, size.height );
    
    CGFloat outerRadius = [v getOuterRadius];
    CGPoint center = [v getCenterFlipped:NO];
//    CGPoint center;
//    center.x = size.width/2;
//    center.y = size.height/2;

    CGRect circleRect;
    circleRect.origin.x = center.x - outerRadius;
    circleRect.origin.y = center.y - outerRadius;
    circleRect.size.width = outerRadius*2;
    circleRect.size.height = outerRadius*2;
    
    // cercle interior
    drawRadialGradientRect(context, circleRect, highColor.CGColor, 
        circleColor.CGColor, circleRect.size.width/6, DrawGradientDirectionFlippedDownRight);

    // contorn del cercle interior (si no aparaiex pixelated)
    CGContextSetLineWidth( context, 1 );
    CGContextSetStrokeColorWithColor( context, circleColor.CGColor );
    CGContextAddEllipseInRect( context, circleRect );
    CGContextStrokePath( context );
    
    // clipem la sombra que apareixeria a fora
//    CGContextAddEllipseInRect( context, CGRectInset(circleRect, -4.5, -4.5 ) );
//    CGContextClip( context );
    
    // dibuixem el borde amb una sombra
    CGContextSetStrokeColorWithColor( context, borderColor.CGColor );
    CGContextSetLineWidth( context, 2 );
    CGContextSetShadowWithColor( context, CGSizeMake(0,0), 3, contrastColor.CGColor /*textColor.CGColor*/ );
    CGContextAddEllipseInRect( context, CGRectInset(circleRect, -3, -3 ) );
    CGContextStrokePath( context );
//    
    
    
}

@end



#pragma mark SWKnobControlLayer

@interface SWKnobControlLayer : SWLayer
@end


@implementation SWKnobControlLayer

- (id)init
{
    self = [super init];
    if ( self )
    {
    }
    return self;
}


//- (void)layoutSublayersV
//{
//    [super layoutSublayers];
//        
//   
//    Class thumbLayerClass = [SWThumbLayer class];
//        
//    for ( SWLayer *layer in self.sublayers )
//    {
//        if ( [layer isKindOfClass:thumbLayerClass] )
//        {
//            [(SWThumbLayer*)layer layoutInSuperlayer];
//        }
//        else
//        {
////            SWKnobControl *v = (SWKnobControl*)_v;
////            CGRect rect = [v getAspectFitFrameFlipped:YES];
////            layer.frame = rect;
//            
//            CGRect bounds = self.bounds;
//            layer.frame = bounds;
//        }
//        [layer setNeedsLayout];
//    }
//}


- (void)layoutSublayers
{
    [super layoutSublayers];
        
   
    Class thumbRotatedLayerClass = [SWThumbRotatedLayer class];
    
    for ( SWLayer *layer in self.sublayers )
    {
        if ( [layer isKindOfClass:thumbRotatedLayerClass] )
        {
            SWKnobControl *v = (SWKnobControl*)_v;
            CGPoint center = [v getCenterFlipped:YES];
            CGFloat outerRadius = [v getOuterRadius];
            [layer setBounds:CGRectMake(0, 0, outerRadius*2, outerRadius*2)];
            [layer setPosition:center];
        }
        else
        {
//            SWKnobControl *v = (SWKnobControl*)_v;
//            CGRect rect = [v getAspectFitFrameFlipped:YES];
//            layer.frame = rect;
            
            CGRect bounds = self.bounds;
            layer.frame = bounds;
        }
        [layer setNeedsLayout];
    }
}

@end




@implementation SWKnobControl
{
    SWKnobBackLayer *_backLayer;
    SWKnobLayer *_knobLayer;
    SWThumbRotatedLayer *_thumbRotatedLayer;
    SWThumbLayer *_thumbLayer;
    double _startTrackValue;
    double _startTrackAngle;
    double _referenceTrackAngle;
}

+ (Class)layerClass
{
    return [SWKnobControlLayer class];
}

@synthesize value = _value;
@synthesize range = _range;
//@synthesize startAngle = _startAngle;
//@synthesize endAngle = _endAngle;
@synthesize majorTickInterval = _majorTickInterval;
@synthesize minorTicksPerInterval = _minorTicksPerInterval;
@synthesize insets = _insets;
@synthesize font = _font;
@synthesize format = _format;

@synthesize needleColor = _needleColor;
@synthesize tintsColor = _tintsColor;
@synthesize highTintColor = _highTintColor;
@synthesize borderColor = _borderColor;
//@synthesize textColor = _textColor;
@synthesize contrastColor = _contrastColor;
@synthesize labelColor = _labelColor;

@synthesize labelText = _labelText;
@synthesize thumbStyle = _thumbStyle;
@synthesize knobStyle = _knobStyle;


- (void)_doInit
{
    SWKnobControlLayer *layer = (id)[self layer];
    [layer setView:self];
//
    
    _backLayer = [[SWKnobBackLayer alloc] init];
    [_backLayer setView:self];
    [layer addSublayer:_backLayer];
    
    _knobLayer = [[SWKnobLayer alloc] init];
    [_knobLayer setView:self];
    [layer addSublayer:_knobLayer];
    
    _thumbRotatedLayer = [[SWThumbRotatedLayer alloc] init];
    [_thumbRotatedLayer setView:self];
    [layer addSublayer:_thumbRotatedLayer];
    
    _thumbLayer = [[SWThumbLayer alloc] init];
    [_thumbLayer setView:self];
    //[layer addSublayer:_thumbLayer];
    [_thumbRotatedLayer addSublayer:_thumbLayer];
    
//    NSNumber *new = [NSNumber numberWithFloat:M_PI/3];
//    [_thumbRotationLayer setValue:new forKeyPath:@"transform.rotation"];
    
    _thumbStyle = SWKnobThumbStyleSegment;
    _needleColor = [UIColor blackColor];
    _font = [UIFont boldSystemFontOfSize:13];
    _format = @"";
    
    [self setTintsColor:[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0]];

    _borderColor = [UIColor greenColor];
    _labelText = @"";

    _insets = UIEdgeInsetsMake( 40, 40, 40, 40 );
//    _startAngle = M_PI + M_PI/4;
//    _endAngle = -M_PI/4;
    
    
    _angleRange = 2*M_PI-M_PI/2; 
    _deadAnglePosition = -M_PI/2; //-M_PI/4;
    
//    _startAngle = _deadAnglePosition - (2*M_PI-_angleRange)/2;
//    _endAngle = _startAngle - _angleRange;
    
    NSNumber *new = [NSNumber numberWithFloat:M_PI-_deadAnglePosition];
    [_thumbRotatedLayer setValue:new forKeyPath:@"transform.rotation"];
    
    
//    _startAngle = -(M_PI-M_PI_4);
//    _endAngle = M_PI-M_PI_4;

//    _startAngle = -M_PI/4 ;;
//    _endAngle = M_PI + M_PI/4;
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


- (CGSize)getMaxTextSizeWithAttributes:(NSDictionary *)attrs
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
    CGRect rect = self.bounds;
    CGSize size = rect.size;
    CGFloat xRadius = (size.width-_insets.left-_insets.right)/2.0f;
    CGFloat yRadius = (size.height-_insets.top-_insets.bottom)/2.0f;
    CGFloat outerRadius = MIN(xRadius,yRadius);
    return outerRadius;
}

//- (CGFloat)getOuterRadiusForSize:(CGSize)size
//{
//    CGFloat xRadius = (size.width-_insets.left-_insets.right)/2.0f;
//    CGFloat yRadius = (size.height-_insets.top-_insets.bottom)/2.0f;
//    CGFloat outerRadius = MIN(xRadius,yRadius);
//    return outerRadius;
//}

- (CGPoint)getCenterFlipped:(BOOL)isFlipped
{
    CGPoint center;
    CGSize size = self.bounds.size;
	center.x = _insets.left + (size.width-_insets.left-_insets.right)/2.0f;;
	center.y = _insets.bottom + (size.height-_insets.bottom-_insets.top)/2.0f;
    if ( isFlipped ) center.y = size.height - center.y ;    // compensem per y invertida en cocoa touch
    return center;
}

- (CGRect)getAspectFitFrameFlipped:(BOOL)isflipped
{
    CGSize size = self.bounds.size;
    size.width = size.width-_insets.left-_insets.right;
    size.height = size.height-_insets.bottom-_insets.top;
    CGPoint center;
    center.x = _insets.left + (size.width)/2.0f;;
	center.y = _insets.bottom + (size.height)/2.0f;
    
    if ( size.width>size.height ) size.width = size.height;
    else size.height = size.width;
    
    size.width += 80;
    size.height += 80;
    
    CGRect rect;
    rect.origin.x = center.x - size.width/2;
    rect.origin.y = center.y - size.height/2;
    rect.size = size;
    return rect;
}

- (void)setRange:(SWRange)range animated:(BOOL)animated
{
    _range = range;
    [_thumbLayer updateValueAnimated:animated];
    [_knobLayer setRange:range animated:animated];
}

- (void)setMajorTickInterval:(double)majorTickInterval
{
    _majorTickInterval = majorTickInterval;
    [_knobLayer setNeedsDisplay];
}

- (void)setMinorTicksPerInterval:(int)minorTicksPerInterval
{
    _minorTicksPerInterval = minorTicksPerInterval;
    [_knobLayer setNeedsDisplay];
}

- (void)setFormat:(NSString *)format
{
    _format = format;
    [_knobLayer setNeedsDisplay];
}

- (void)setValue:(double)value animated:(BOOL)animated
{
    if ( _value == value )
        return;
    
    _value = value;
    [_thumbLayer updateValueAnimated:animated];
}

- (void)setThumbStyle:(SWKnobThumbStyle)thumbStyle
{
    _thumbStyle = thumbStyle;
    
    if ( thumbStyle == SWKnobThumbStyleSegment )
    {
        NSNumber *new = [NSNumber numberWithFloat:M_PI-_deadAnglePosition];
        [_thumbRotatedLayer setValue:new forKeyPath:@"transform.rotation"];
    }
    else
    {
        [_thumbRotatedLayer setTransform:CATransform3DIdentity];
    }
    
    [_thumbRotatedLayer setNeedsLayout];
    [_thumbLayer setNeedsDisplay];
}

- (void)setLabelText:(NSString *)text
{
    _labelText = text;
    [_knobLayer setNeedsDisplay] ;
}

- (void)setTintsColor:(UIColor*)color
{
    
    UInt32 rgb = rgbColorForUIcolor( color );
    CGFloat brightness = BrightnessForRgb(rgb);
    CGFloat majorWhite = MIN(brightness+0.8f, 1.0f);
    _highTintColor = [UIColor colorWithRed:majorWhite green:majorWhite blue:majorWhite alpha:1];
    _tintsColor = color;
    _labelColor = contrastColorForUIColor( _highTintColor );
    
    [_knobLayer setNeedsDisplay];
    [_backLayer setNeedsDisplay];
}

- (void)setBorderColor:(UIColor*)color
{
    _borderColor = color;
    [_backLayer setNeedsDisplay];
}

- (void)setNeedleColor:(UIColor*)color
{
    _needleColor = color;
    [_thumbLayer setNeedsDisplay];
}

- (void)setContrastForBackgroundColor:(UIColor *)color
{
    _contrastColor = contrastColorForUIColor( color );
    [_knobLayer setNeedsDisplay];
    [_backLayer setNeedsDisplay];
}

- (void)setBackgroundColor:(UIColor *)color
{
    [super setBackgroundColor:color];
    [self setContrastForBackgroundColor:color];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    [self setAlpha:enabled?1.0:0.5];

}

#pragma mark tracking


- (CGFloat)thumbDistanceFromPoint:(CGPoint)point
{
    // to do
    return 0;
    
    CGPoint center = [self getCenterFlipped:YES];
    CGFloat dx = point.x - center.x;
	CGFloat dy = point.y - center.y;
    CGFloat distance = dx*dx + dy*dy;
    return distance;
}


// Torna el angle que correspon al punt que se li passa. 
// El angle conte les rotacions acumulades del punt que se li passa
- (double)angleForPoint:(CGPoint)point
{
    CGPoint rotated;
    
    // Volem obtenir el angle que correspon al punt que ens pasen. La funcio atan2 ens permet 
    // determinar el angle a partir de les coordenades. Pero amb els punts que estan a la interseccio 
    // entre el segon i el tercer quadrant tenim un problema perque la funcio atan2 fa un salt brusc 
    // de 180 a -180 graus. Per solucionar aixo el que fem es mantenir un angle de referencia en el que acumulem les
    // desviacions excesives del origen. El angle de referencia l'utilitzem per fer una rotacio d'eixos de manera que
    // els punts (respecte els eixos rotats) sempre caiguin a prop del origen.
    // Despres apliquem atan2 al punt expressat en els eixos rotats i el resultat el compensem de nou 
    // amb el angle de referencia per obtenir el angle en les coordenades no rotades.
    // El resultat final conte les rotacions acumulades dels punts que se li passen. 
        
    // Primer referim el nou punt a uns eixos rotats segons el angle de referencia
	CGPoint center = [self getCenterFlipped:YES];
    rotated.x = cos(_referenceTrackAngle) * (point.x-center.x) - sin(_referenceTrackAngle) * (point.y-center.y) + center.x;
    rotated.y = sin(_referenceTrackAngle) * (point.x-center.x) + cos(_referenceTrackAngle) * (point.y-center.y) + center.y;
    
    // Obtenim el angle actual referit als eixos rotats 
	double angle = - atan2(rotated.y-center.y, rotated.x-center.x);
    
    //NSLog( @"Rotated (x,y):(%g,%g) AngleForPoint : %g", rotated.x, rotated.y, angle*180.0/M_PI );
    //NSLog( @"AbsoluteTrackAngle : %g", _referenceTrackAngle*180.0/M_PI );
    
    // Si l'angle actual s'allunya un cert valor del origen compensem el angle de referencia
    // per a la seguent iteracio
    if ( fabs(angle) > 0.05 )    // aixo es aproximadament 2,8 graus (suficient per descartar perdues de precisio en l'acumulacio del angle de referencia)
    {
        _referenceTrackAngle += angle;
        angle = 0;
    }
    
    return _referenceTrackAngle + angle;
}


- (BOOL)beginTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
	CGPoint point = [touch locationInView:self];
//    NSLog( @"--------------------" ) ;
//    NSLog( @"begin point:(%g, %g)", point.x, point.y );
    
    if ( [self thumbDistanceFromPoint:point] > 30 ) 
        return NO;
    
    CGPoint center = [self getCenterFlipped:YES];
    _referenceTrackAngle = atan2(point.y-center.y, point.x-center.x);
    _startTrackAngle = [self angleForPoint:point];
    _startTrackValue = _value;

	self.highlighted = YES;
	return YES;
}


- (BOOL)handleTouch:(UITouch*)touch
{
    CGPoint point = [touch locationInView:self];
    
    double startAngle = _deadAnglePosition - (2*M_PI-_angleRange)/2;
    double endAngle = startAngle - _angleRange;
    
    
    CGFloat trackAngle = [self angleForPoint:point];
    double deltaAngle = trackAngle - _startTrackAngle;
//    double deltaValue = deltaAngle*((_range.max-_range.min)/(_endAngle-_startAngle));
    double deltaValue = deltaAngle*((_range.max-_range.min)/(endAngle-startAngle));
    double newValue = _startTrackValue + deltaValue;
    
    double rLen = _range.max - _range.min;
    if ( rLen > 0 ) 
    {
        if ( newValue > _range.max ) newValue = _range.max;
        if ( newValue < _range.min ) newValue = _range.min;
    }
    else
    {
        if ( newValue < _range.max ) newValue = _range.max;
        if ( newValue > _range.min ) newValue = _range.min;
    }
    
    //NSLog( @"actualValue: %g", newValue );
    
    [self setValue:newValue animated:NO];
	return YES;
}


- (BOOL)continueTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
	//CGPoint point = [touch locationInView:self];
    //NSLog( @"continue track point:(%g, %g)", point.x, point.y );

    BOOL continuous = YES;
	if ([self handleTouch:touch] && continuous)
		[self sendActionsForControlEvents:UIControlEventValueChanged];

	return YES;
}


- (void)endTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{

	//CGPoint point = [touch locationInView:self];
    //NSLog( @"end track point:(%g, %g) with result: %g", point.x, point.y, _value );

	self.highlighted = NO;
	[self handleTouch:touch];
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}


- (void)cancelTrackingWithEvent:(UIEvent*)event
{
    //NSLog( @"cancel track" );
	self.highlighted = NO;
	//[self sendActionsForControlEvents:UIControlEventTouchCancel];
}


@end
