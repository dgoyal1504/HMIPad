//
//  SWLayer.h
//  HmiPad
//
//  Created by Lluch Joan on 23/05/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>


//--------------------------------------------------------------------
#pragma mark SWRange

struct SWRange
{
	double min ;
	double max ;
};
typedef struct SWRange SWRange;

static inline SWRange SWRangeMake(double min, double max)
{
  SWRange p = { min, max } ; 
  return p;
}



/**
 *	@brief Aligns a point in user space to integral coordinates in device space.
 *
 *	Ensures that the x and y coordinates are at a pixel corner in device space.
 *	Drawn from <i>Programming with Quartz</i> by D. Gelphman, B. Laden.
 *
 *	@param context The graphics context.
 *	@param p The point in user space.
 *	@return The device aligned point in user space.
 **/
static CGPoint SWAlignPointToDeviceSpace(CGContextRef context, CGPoint p)
{
    // Compute the coordinates of the point in device space.
    p = CGContextConvertPointToDeviceSpace(context, p);
    
    // Ensure that coordinates are at exactly the corner
    // of a device pixel.
    p.x = roundf(p.x) + 0.5f;
    p.y = roundf(p.y) - 0.5f;
    
    // Convert the device aligned coordinate back to user space.
    return CGContextConvertPointToUserSpace(context, p);
}

/**
 *	@brief Adjusts a size in user space to integral dimensions in device space.
 *
 *	Ensures that the width and height are an integer number of device pixels.
 *	Drawn from <i>Programming with Quartz</i> by D. Gelphman, B. Laden.
 *
 *	@param context The graphics context.
 *	@param s The size in user space.
 *	@return The device aligned size in user space.
 **/
static CGSize SWAlignSizeToDeviceSpace(CGContextRef context, CGSize s)
{
    // Compute the size in device space.
    s = CGContextConvertSizeToDeviceSpace(context, s);
    
    // Ensure that size is an integer multiple of device pixels.
    s.width = roundf(s.width);
    s.height = roundf(s.height);
    
    // Convert back to user space.
    return CGContextConvertSizeToUserSpace(context, s);
}


//inline static CGFloat SWInterpolate( double emin, double emax, double progress  )
//{
//    CGFloat result = emin + progress*(emax-emin) ;
//    return result;
//}


inline static CGFloat SWConvertToViewPort( double e, double emin, double emax, CGFloat vpmin, CGFloat vpmax )
{
    CGFloat result = vpmin + (e-emin)*((vpmax-vpmin)/(emax-emin)) ;
    if ( result != result ) return vpmin /*+ (vpmax-vpmin)/2*/;    // filtrem el cas de nan !
    //if ( emin == emax ) return (vpmax+vpmin)/2; // filtrem el cas de inf
    return result;
}

inline static void SWMoveToPoint( CGContextRef context, CGFloat x, CGFloat y, BOOL aligned )
{
    CGPoint p = CGPointMake( x, y ) ;
    if ( aligned ) p = SWAlignPointToDeviceSpace( context, p ) ;
    CGContextMoveToPoint( context, p.x, p.y ) ;
}

inline static void SWAddLineToPoint( CGContextRef context, CGFloat x, CGFloat y, BOOL aligned )
{
    CGPoint p = CGPointMake( x, y ) ;
    if ( aligned ) p = SWAlignPointToDeviceSpace( context, p ) ;
    CGContextAddLineToPoint( context, p.x, p.y ) ;
}

inline static void SWTranslateAndFlipCTM( CGContextRef context, CGFloat height )
{
    CGContextTranslateCTM( context, 0.0, height ) ;
    CGContextScaleCTM( context, 1.0, -1.0 ) ;
}

@interface SWLayer : CALayer
{
    __weak UIView *_v ;
    BOOL _isAnimated ;
    BOOL _isAligned ;
}

@property (nonatomic, weak) UIView *view ;
@property (nonatomic, assign) BOOL animated ;

@end 
