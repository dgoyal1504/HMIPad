//
//  GradientBackgroundView.m
//  iPhoneDomusSwitch_090409
//
//  Created by Joan on 09/04/09.
//  Copyright 2009 SweetWilliam, S.L.. All rights reserved.


#import "GradientBackgroundView.h"

//////////////////////////////////////////////////////////////////////////////
#pragma mark GradientBackground
//////////////////////////////////////////////////////////////////////////////

@implementation GradientBackgroundView

+ (GradientBackgroundData *)gradientBackgroundData
{
    static GradientBackgroundData bgnd =
    {
        1.00f, 1.00f, 1.00f, 1.00f,     // r,g,b,a
        0.50f, 0.80f,                   // i,e
        0.85f, 0.85f, 0.85f, 1.00f,     // lr,lg,lb,la
        NO, NO, NO, NO,                 // left, top, right, bottom
        2.00f,                          // l_width
        11.0f,                          // round_size
        0.0f,                           // px_size
        0.0f                            // py_size
    } ;
    
    return &bgnd ;
}

+ (GradientBackgroundData *)gradientBackgroundData6
{
    static GradientBackgroundData bgnd =
    {
        1.00f, 1.00f, 1.00f, 1.00f,     // r,g,b,a
        0.50f, 0.80f,                   // i,e
        0.85f, 0.85f, 0.85f, 1.00f,     // lr,lg,lb,la
        NO, NO, NO, NO,                 // left, top, right, bottom
        2.00f,                          // l_width
        11.0f,                          // round_size
        0.0f,                           // px_size
        0.0f                            // py_size
    } ;
    
    return &bgnd ;
}


+ (GradientBackgroundData *)theGradientBackgroundData
{
    if ( IS_IOS7 ) return [self gradientBackgroundData];
    else return [self gradientBackgroundData6];
}



//---------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame
{
    if ( (self = [super initWithFrame:frame]) ) 
    {
        GradientBackgroundData *bgnd = [[self class] theGradientBackgroundData] ;
        CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();

        CGFloat i=bgnd->i, e=bgnd->e ;
        CGFloat colors[] =
        {
            bgnd->r*i, bgnd->g*i, bgnd->b*i, bgnd->a,
            bgnd->r*e, bgnd->g*e, bgnd->b*e, bgnd->a,
        };
        
        gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
        CGColorSpaceRelease(rgb);
        
       [self setContentMode:UIViewContentModeRedraw] ;
    }
    return self ;
}


//---------------------------------------------------------------------------------------------------
-(void)drawCornerInContext:(CGContextRef)c cornerX:(CGFloat)x cornerY:(CGFloat)y arcEndX:(CGFloat)endX arcEndY:(CGFloat)endY radius:(CGFloat)radius
{
    CGContextMoveToPoint(c, x, endY);
    CGContextAddArcToPoint(c, x, y, endX, y, radius);
    CGContextAddLineToPoint(c, x, y);
    CGContextAddLineToPoint(c, x, endY);
}


//---------------------------------------------------------------------------------------------------
-(void)drawRoundedCornersInContext:(CGContextRef)c rect:(CGRect)rect withBackgroundData:(GradientBackgroundData*)bgnd
{
    CGFloat radius = bgnd->round_size ;
    CGFloat x_left = rect.origin.x;
    CGFloat x_left_center = rect.origin.x + radius;
    CGFloat x_right_center = rect.origin.x + rect.size.width - radius;
    CGFloat x_right = rect.origin.x + rect.size.width;
    CGFloat y_top = rect.origin.y;
    CGFloat y_top_center = rect.origin.y + radius;
    CGFloat y_bottom_center = rect.origin.y + rect.size.height - radius;
    CGFloat y_bottom = rect.origin.y + rect.size.height;
 
    CGContextBeginPath(c);
    if (YES /*roundUpperLeft*/) 
    {
        [self drawCornerInContext:c cornerX: x_left cornerY: y_top
              arcEndX: x_left_center arcEndY: y_top_center radius: radius];
    }
 
    if (YES /*roundUpperRight*/) 
    {
        [self drawCornerInContext:c cornerX: x_right cornerY: y_top
              arcEndX: x_right_center arcEndY: y_top_center radius: radius];
    }
 
    if (NO /*roundLowerRight*/) 
    {
        [self drawCornerInContext:c cornerX: x_right cornerY: y_bottom
              arcEndX: x_right_center arcEndY: y_bottom_center radius: radius];
    }
 
    if (NO /*roundLowerLeft*/) 
    {
        [self drawCornerInContext:c cornerX: x_left cornerY: y_bottom
              arcEndX: x_left_center arcEndY: y_bottom_center radius: radius];
    }
    CGContextClosePath(c); 
}

//---------------------------------------------------------------------------------------------------
// Crea un cami amb els atributs que se li pasen
//
//---------------------------------------------------------------------------------------------------
- (CGMutablePathRef)createRoundedRectPathForRect:(CGRect)rect withBackgroundData:(GradientBackgroundData*)bgnd
{  
    CGFloat baseTop = 0.0f, baseBottom = 0.0f ;
    if ( onTop ) baseTop =  bgnd->py_size ;
    else baseBottom = bgnd->py_size ;
    CGFloat px_pos = bgnd->px_size + bgnd->round_size ;
    CGFloat corner_radius = bgnd->round_size ;
    
    CGFloat y_top_top = rect.origin.y ;
    CGFloat y_bottom_bottom = rect.origin.y + rect.size.height ; 
    
    CGFloat x_left = rect.origin.x;  
    CGFloat x_right = rect.origin.x + rect.size.width;   
    CGFloat y_top = y_top_top + baseTop;  
    CGFloat y_bottom = y_bottom_bottom - baseBottom ; 
    
    CGFloat x_center_center = fminf(x_right-px_pos, fmaxf(x_left + pointX, px_pos )) ; //PX_POS ; //roundf(rect.size.width/2.0f) ;
    
    CGFloat top_left_radius =  (bgnd->top && bgnd->left) ? corner_radius : 0.0f ;
    CGFloat top_right_radius = (bgnd->top && bgnd->right) ? corner_radius : 0.0f ;
    CGFloat bottom_left_radius =  (bgnd->bottom && bgnd->left) ? corner_radius : 0.0f ;
    CGFloat bottom_right_radius = (bgnd->bottom && bgnd->right) ? corner_radius : 0.0f ;
    
    // Begin 
    CGMutablePathRef path = CGPathCreateMutable() ;
    
    // Linea vertical esquerra
    CGPathMoveToPoint(path, &CGAffineTransformIdentity, x_left, y_bottom - bottom_left_radius);
    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, x_left, y_top + top_left_radius); 
          
    // First corner
    if ( top_left_radius != 0.0f  ) 
    {
        CGPathAddArcToPoint(path, &CGAffineTransformIdentity, x_left, y_top, x_left + top_left_radius, y_top, top_left_radius);
    }
    
    // Punta
    if ( onTop )
    {
        if ( bgnd->px_size != 0.0f ) 
        {
            CGPathAddLineToPoint(path, &CGAffineTransformIdentity, x_center_center - bgnd->px_size, y_top) ;
            CGPathAddLineToPoint(path, &CGAffineTransformIdentity, x_center_center, y_top_top) ;
            CGPathAddLineToPoint(path, &CGAffineTransformIdentity, x_center_center + bgnd->px_size, y_top) ;
        }
    }
    
    // linea superior
    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, x_right - top_right_radius, y_top);  
          
    // Second corner
    if ( top_right_radius != 0.0f ) 
    {
        CGPathAddArcToPoint(path, &CGAffineTransformIdentity, x_right, y_top, x_right, y_top + top_right_radius, top_right_radius);
    }
    
    // Linea vertical dreta
    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, x_right, y_bottom - bottom_right_radius);  
     
      
    // Third corner 
    if ( bottom_right_radius != 0.0f  ) 
    {
        CGPathAddArcToPoint(path, &CGAffineTransformIdentity, x_right, y_bottom, x_right - bottom_right_radius, y_bottom, bottom_right_radius);
    }
    
    // Punta
    if ( !onTop )
    {
        if ( bgnd->px_size != 0.0f )
        {
            CGPathAddLineToPoint(path, &CGAffineTransformIdentity, x_center_center+bgnd->px_size, y_bottom) ; 
            CGPathAddLineToPoint(path, &CGAffineTransformIdentity, x_center_center, y_bottom_bottom) ; 
            CGPathAddLineToPoint(path, &CGAffineTransformIdentity, x_center_center-bgnd->px_size, y_bottom) ;
        }
    }
    
    // Linea inferior
    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, x_left + bottom_left_radius, y_bottom) ;
      
    // Fourth corner 
    if ( bottom_left_radius != 0.0f ) 
    {
        CGPathAddArcToPoint(path, &CGAffineTransformIdentity, x_left, y_bottom, x_left, y_bottom - bottom_left_radius, bottom_left_radius);
    }

    // Done 
    return path ; 
}  


//----------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect 
{
    [super drawRect:rect];
    
    GradientBackgroundData *bgnd = [[self class] theGradientBackgroundData] ;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint start = rect.origin;
    start.y = rect.size.height*(0.0f/6.0f);
    CGPoint end = CGPointMake(rect.origin.x, rect.origin.y+rect.size.height);
    
    // creem un path amb el rectangle arrodinit per dalt
    CGMutablePathRef path = [self createRoundedRectPathForRect:rect withBackgroundData:bgnd] ;
    
    // dibuixem el gradient dins del path
    CGContextAddPath( context, path ) ;
    CGContextClip( context ) ;
    CGContextDrawLinearGradient( context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    
    // dibuixem el contorn del path
    if ( bgnd->l_width != 0.0f )
    {
        CGContextAddPath( context, path ) ;
        CGContextSetRGBStrokeColor(context, bgnd->lr, bgnd->lg, bgnd->lb, bgnd->la ) ; // 0.85f, 0.85f, 0.85f, 1.0f);
        CGContextSetLineWidth(context, bgnd->l_width ) ; // 2.0f);
        CGContextStrokePath(context);
    }

    // alliberem el path
    CGPathRelease( path ) ;
}

//----------------------------------------------------------------------------
- (void)dealloc
{
    CGGradientRelease( gradient ) ;
    // [super dealloc] ;
}

@end


