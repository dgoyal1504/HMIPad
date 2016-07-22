//
//  drawing.m
//  PDColoredProgressViewDemo
//
//  Created by Pascal Widdershoven on 03-01-09.
//  Copyright 2009 P-development. All rights reserved.
//

/* 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Computer, Inc. ("Apple") in consideration of your agreement to the
 following terms, and your use, installation, modification or
 redistribution of this Apple software constitutes acceptance of these
 terms.  If you do not agree with these terms, please do not use,
 install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Computer,
 Inc. may be used to endorse or promote products derived from the Apple
 Software without specific prior written permission from Apple.  Except
 as expressly stated in this notice, no other rights or licenses, express
 or implied, are granted by Apple herein, including but not limited to
 any patent rights that may be infringed by your derivative works or by
 other works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2005 Apple Computer, Inc., All Rights Reserved
 
 @source http://developer.apple.com/mac/library/samplecode/QuartzShapes/listing10.html
 See license above
 */
 
 
 #import "Drawing.h"
 
//----------------------------------------------------------------------------------------

/*
void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth,
								 float ovalHeight)
{
	float fw, fh;
	// If the width or height of the corner oval is zero, then it reduces to a right angle,
	// so instead of a rounded rectangle we have an ordinary one.
	if (ovalWidth == 0 || ovalHeight == 0) 
    {
		CGContextAddRect(context, rect);
		return;
	}
	
	//  Save the context's state so that the translate and scale can be undone with a call
	//  to CGContextRestoreGState.
	CGContextSaveGState(context);
	
	//  Translate the origin of the contex to the lower left corner of the rectangle.
	CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
	
	//Normalize the scale of the context so that the width and height of the arcs are 1.0
	CGContextScaleCTM(context, ovalWidth, ovalHeight);
	
	// Calculate the width and height of the rectangle in the new coordinate system.
	fw = CGRectGetWidth(rect) / ovalWidth;
	fh = CGRectGetHeight(rect) / ovalHeight;
	
	// CGContextAddArcToPoint adds an arc of a circle to the context's path (creating the rounded
	// corners).  It also adds a line from the path's last point to the begining of the arc, making
	// the sides of the rectangle.
	CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
	CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
	CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
	CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
	CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
	
	// Close the path
	CGContextClosePath(context);
	
	// Restore the context's state. This removes the translation and scaling
	// but leaves the path, since the path is not part of the graphics state.
	CGContextRestoreGState(context);
}
*/

/*
void fillRectWithLinearGradient(CGContextRef context, CGRect rect, CGFloat colors[], int numberOfColors, CGFloat locations[])
{
	CGContextSaveGState(context);
	
	if(!CGContextIsPathEmpty(context))
		CGContextClip(context);
	
	CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
	CGPoint start = CGPointMake(0, 0);
	CGPoint end = CGPointMake(0, rect.size.height);
	
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(space, colors, locations, numberOfColors);
	CGContextDrawLinearGradient(context, gradient, end, start, 0);
	CGContextRestoreGState(context);
	
	CGColorSpaceRelease(space);
	CGGradientRelease(gradient);
}
*/

//----------------------------------------------------------------------------------------
/*
typedef struct
{
	float color[4];
	float caustic[4];
	float expCoefficient;
	float expOffset;
	float expScale;
	float initialWhite;
	float finalWhite;
} GlossyParams;
*/
/*
static void rgb_to_hsv(const float* inputComponents, float* outputComponents)
{
	// Unpack r,g,b for conciseness
	float r = inputComponents[0];
	float g = inputComponents[1];
	float b = inputComponents[2];
	
	// Rather tediously, find the min and max values, and the max component
	char max_elt = 'r';
	float max_val=r, min_val=r;
	if (g > max_val)
	{
		max_val = g;
		max_elt = 'g';
	}
	if (b > max_val)
	{
		max_val = b;
		max_elt = 'b';
	}
	if (g < min_val) min_val = g;
	if (b < min_val) min_val = b;

	// Cached
	float max_minus_min = max_val - min_val;
	
	// Calculate h as a degree (0 - 360) measurement
	float h = 0;
	switch (max_elt)
	{
		case 'r':
			h = !max_minus_min?0:60*(g-b)/max_minus_min + 360;
			if (h >= 360) h -= 360;
			break;
		case 'g':
			h = !max_minus_min?0:60*(b-r)/max_minus_min + 120;
			break;
		case 'b':
		default:
			h = !max_minus_min?0:60*(r-g)/max_minus_min + 240;
			break;
	}
	
	// Normalize h
	h /= 360;
	
	// Calculate s
	float s = 0;
	if (max_val) s = max_minus_min/max_val;
	
	// Store HSV triple; v is just the max
	outputComponents[0] = h;
	outputComponents[1] = s;
	outputComponents[2] = max_val;
}
*/
/*
static float perceptualGlossFractionForColor(float* inputComponents)
{
    static const float REFLECTION_SCALE_NUMBER	= 0.2f;
    static const float NTSC_RED_FRACTION		= 0.299f;
    static const float NTSC_GREEN_FRACTION		= 0.587f;
    static const float NTSC_BLUE_FRACTION		= 0.114f;
	
    float glossScale =	NTSC_RED_FRACTION * inputComponents[0] +
						NTSC_GREEN_FRACTION * inputComponents[1] +
						NTSC_BLUE_FRACTION * inputComponents[2];

    return powf(glossScale, REFLECTION_SCALE_NUMBER);
}
*/
/*
static void perceptualCausticColorForColor(float* inputComponents, float* outputComponents)
{
    static const float CAUSTIC_FRACTION				= 0.35f;
    static const float COSINE_ANGLE_SCALE			= 1.4f;
    static const float MIN_RED_THRESHOLD			= 0.95f;
    static const float MAX_BLUE_THRESHOLD			= 0.7f;
    static const float GRAYSCALE_CAUSTIC_SATURATION	= 0.2f;

	float temp[3];
	
	rgb_to_hsv(inputComponents, temp);
    float hue=temp[0], saturation=temp[1], brightness=temp[2];

	rgb_to_hsv(CGColorGetComponents([[UIColor yellowColor] CGColor]), temp);
    float targetHue=temp[0], targetSaturation=temp[1], targetBrightness=temp[2];
    
    if (saturation < 1e-3)
    {
        hue = targetHue;
        saturation = GRAYSCALE_CAUSTIC_SATURATION;
    }
	
    if (hue > MIN_RED_THRESHOLD)
    {
        hue -= 1.0f;
    }
    else if (hue > MAX_BLUE_THRESHOLD)
    {
		rgb_to_hsv(CGColorGetComponents([[UIColor magentaColor] CGColor]), temp);
		targetHue=temp[0], targetSaturation=temp[1], targetBrightness=temp[2];
    }
	
    float scaledCaustic = CAUSTIC_FRACTION * 0.5f * (1.0f + cosf(COSINE_ANGLE_SCALE * (float)M_PI * (hue - targetHue)));
	UIColor* caustic = [UIColor colorWithHue:hue * (1.0f - scaledCaustic) + targetHue * scaledCaustic
								  saturation:saturation
								  brightness:brightness * (1.0f - scaledCaustic) + targetBrightness * scaledCaustic
									   alpha:inputComponents[3]];
	
	const CGFloat* causticComponents = CGColorGetComponents([caustic CGColor]);
	for (int j = 3; j >= 0; j--) outputComponents[j] = causticComponents[j];
}
*/
/*
static void calc_glossy_color(void* info, const float* in, float* out)
{
	GlossyParams*	params		= (GlossyParams*) info;
	float			progress	= *in;
	
    if (progress < 0.5f)
    {
        progress = progress * 2.0f;
		
        progress = 1.0f - params->expScale * (expf(progress * -params->expCoefficient) - params->expOffset);
		
        float currentWhite = progress * (params->finalWhite - params->initialWhite) + params->initialWhite;
        
        out[0] = params->color[0] * (1.0f - currentWhite) + currentWhite;
        out[1] = params->color[1] * (1.0f - currentWhite) + currentWhite;
        out[2] = params->color[2] * (1.0f - currentWhite) + currentWhite;
        out[3] = params->color[3] * (1.0f - currentWhite) + currentWhite;
    }
    else
    {
        progress = (progress - 0.5f) * 2.0f;
		
        progress = params->expScale * (expf((1.0f - progress) * -params->expCoefficient) - params->expOffset);
		
        out[0] = params->color[0] * (1.0f - progress) + params->caustic[0] * progress;
        out[1] = params->color[1] * (1.0f - progress) + params->caustic[1] * progress;
        out[2] = params->color[2] * (1.0f - progress) + params->caustic[2] * progress;
        out[3] = params->color[3] * (1.0f - progress) + params->caustic[3] * progress;
    }
}
*/



/*
static void drawGlossyRect( CGRect rect, CGColorRef color, CGContextRef context )    // Deprecated
{
	static const float EXP_COEFFICIENT	= 4.0f;
	static const float REFLECTION_MAX	= 0.80f;
	static const float REFLECTION_MIN	= 0.20f;

	static const CGFloat normalizedRanges[8] = {0, 1, 0, 1, 0, 1, 0, 1};
	static const CGFunctionCallbacks callbacks = {0, calc_glossy_color, NULL};

	// Prepare gradient configuration struct
	GlossyParams params;
	// Set the base color
	const CGFloat* colorComponents = CGColorGetComponents( color );
	int j = (int) CGColorGetNumberOfComponents( color );
	if (j == 4)
	{
		for (j--; j >= 0; j--) params.color[j] = colorComponents[j];
	}
	else if (j == 2)
	{
		for (; j >= 0; j--) params.color[j] = colorComponents[0];
		params.color[3] = colorComponents[1];
	}
	else
	{
		// I dunno
		return;
	}
	// Set the caustic color
	perceptualCausticColorForColor(params.color, params.caustic);
	// Set the exponent curve parameters
	params.expCoefficient	= EXP_COEFFICIENT;
	params.expOffset		= expf(-params.expCoefficient);
	params.expScale			= 1.0f/(1.0f - params.expOffset);
	// Set the highlight intensities
	float glossScale		= perceptualGlossFractionForColor(params.color);
	params.initialWhite		= glossScale * REFLECTION_MAX;
	params.finalWhite		= glossScale * REFLECTION_MIN;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGFunctionRef function = CGFunctionCreate(&params, 1, normalizedRanges, 4, normalizedRanges, &callbacks);
	
	CGPoint sp = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    CGPoint ep = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
	CGShadingRef shader = CGShadingCreateAxial(colorSpace, sp, ep, function, NO, NO);

	CGFunctionRelease(function);
	CGColorSpaceRelease(colorSpace);

	CGContextDrawShading(context, shader);
	CGShadingRelease(shader);
}
*/


void addRoundedRectPath(CGContextRef context, CGRect rect, CGFloat radius, CGFloat inset )
{
    CGFloat cornerRadius = radius;

	// Unpack size for compactness, find minimum dimension
	CGFloat w = rect.size.width-2*inset;
	CGFloat h = rect.size.height-2*inset;
	CGFloat m = w<h?w:h;
	
	// Special case: Degenerate rectangles abort this method
	if (m <= 0) return;
	
	// Bounds
	CGFloat b = rect.origin.y+inset;
	CGFloat t = b + h;
	CGFloat l = rect.origin.x+inset;
	CGFloat r = l + w;

	// Adjust radius for inset, and limit it to 1/2 of the rectangle's shortest axis
	CGFloat d = (inset<cornerRadius)?(cornerRadius-inset):0;
	d = (d>0.5f*m)?(0.5f*m):d;
	
	// Define a CW path in the CG co-ordinate system (origin at LL)
	//CGContextBeginPath(context);
	CGContextMoveToPoint(context, (l+r)/2, t);		// Begin at TDC
	CGContextAddArcToPoint(context, r, t, r, b, d);	// UR corner
	CGContextAddArcToPoint(context, r, b, l, b, d);	// LR corner
	CGContextAddArcToPoint(context, l, b, l, t, d);	// LL corner
	CGContextAddArcToPoint(context, l, t, r, t, d);	// UL corner
	CGContextClosePath(context);					// End at TDC
}

static void drawSolidRect( CGContextRef context, CGRect rect, CGColorRef color )
{    
    CGContextSetFillColorWithColor(context, color) ;
    CGContextFillRect(context, rect) ;
}



static void getLimitPoints( CGPoint *start, CGPoint *end, CGRect rect, CGFloat startOffset, DrawGradientDirection direction )
{
    CGFloat x = rect.origin.x + rect.size.width/2 ;
    CGFloat y = rect.origin.y + rect.size.height/2 ;
    
    switch ( (int)direction )
    {
        case DrawGradientDirectionUp :
            *start = CGPointMake(x, rect.origin.y+rect.size.height);
            *end = CGPointMake(x, rect.origin.y);
            break;
            
        case DrawGradientDirectionRight :
            *start = CGPointMake(rect.origin.x, y);
            *end = CGPointMake(rect.origin.x+rect.size.width, y);
            break ;
            
        case DrawGradientDirectionDown :
            *start = CGPointMake(x, rect.origin.y);
            *end = CGPointMake(x, rect.origin.y+rect.size.height);
            break ;
            
        case DrawGradientDirectionLeft :
            *start = CGPointMake(rect.origin.x+rect.size.width, y);
            *end = CGPointMake(rect.origin.x, y);
            break;
            
        default:
        {
            CGFloat a = 0 ;
            switch ( (int)direction )
            {
                case DrawGradientDirectionUpLeft :  
                    a = -M_PI/4;
                    break;
            
            case DrawGradientDirectionDownRight :
                    a =  M_PI-M_PI/4;
                    break;
            }
        
            CGPoint sstart = CGPointMake(rect.origin.x+startOffset, rect.origin.y+rect.size.height/2);
            CGPoint eend = CGPointMake(rect.origin.x+rect.size.width, rect.origin.y+rect.size.height/2);
            CGAffineTransform transform = CGAffineTransformMakeTranslation(x, y);
            transform = CGAffineTransformRotate(transform, a);
            transform = CGAffineTransformTranslate(transform,-x,-y);
            *start = CGPointApplyAffineTransform(sstart, transform);
            *end = CGPointApplyAffineTransform(eend, transform);
            break ;
        }
    }
}










static void getLimitPointsV( CGPoint *start, CGPoint *end, CGRect rect, CGFloat startOffset, DrawGradientDirection direction )
{
    CGFloat x = rect.origin.x + rect.size.width/2 ;
    CGFloat y = rect.origin.y + rect.size.height/2 ;
    CGFloat a = 0 ;
    CGPoint sstart = CGPointMake(rect.origin.x+startOffset, rect.origin.y+rect.size.height/2);
    CGPoint eend = CGPointMake(rect.origin.x+rect.size.width, rect.origin.y+rect.size.height/2);
    
    switch ( (int)direction )
    {
        case DrawGradientDirectionUp :
            a = -M_PI/2;
            break;
            
        case DrawGradientDirectionRight :
            a = 0;
            break ;
            
        case DrawGradientDirectionDown :
            a = +M_PI/2;
            break ;
            
        case DrawGradientDirectionLeft :
            a = M_PI;
            break;
            
        case DrawGradientDirectionUpLeft :  
            a = -M_PI/4;
            break;
            
        case DrawGradientDirectionDownRight :
            a =  M_PI-M_PI/4;
            break;
    }
            
    CGAffineTransform transform ;
    transform = CGAffineTransformMakeTranslation(x, y);
    transform = CGAffineTransformRotate(transform, a);
    transform = CGAffineTransformTranslate(transform,-x,-y);
    *start = CGPointApplyAffineTransform(sstart, transform);
    *end = CGPointApplyAffineTransform(eend, transform);
}




static void drawLinearGradient( CGContextRef context, CGGradientRef gradient, CGRect rect, DrawGradientDirection direction)
{
    CGPoint start;
    CGPoint end;
    
//    switch ( (int)direction )
//    {
//        case DrawGradientDirectionUp :
//            start = CGPointMake(rect.origin.x, rect.origin.y+rect.size.height);
//            end = rect.origin ;
//            break ;
//        case DrawGradientDirectionRight :
//            start = CGPointMake(rect.origin.x+rect.size.width, rect.origin.y);
//            end = rect.origin;
//            break ;
//        case DrawGradientDirectionDown :
//            start = rect.origin;
//            end = CGPointMake(rect.origin.x, rect.origin.y+rect.size.height);
//            break ;
//        case DrawGradientDirectionLeft :
//            start = rect.origin;
//            end = CGPointMake(rect.origin.x+rect.size.width, rect.origin.y);
//            break ;
//            
//        default :
//        {
//            CGFloat x = rect.origin.x + rect.size.width/2 ;
//            CGFloat y = rect.origin.y + rect.size.height/2 ;
//            CGFloat a = 0 ;
//    
//            start = rect.origin;
//            end = CGPointMake(rect.origin.x+rect.size.width, rect.origin.y);
//            
//            switch ( (int) direction)
//            {
//                case DrawGradientDirectionUpLeft :  
//                    a = -M_PI/4;
//                    break;
//                case DrawGradientDirectionDownRight :
//                    a =  M_PI-M_PI/4;
//                    break;
//            }
//            
//            CGAffineTransform transform ;
//            transform = CGAffineTransformMakeTranslation(x, y);
//            transform = CGAffineTransformRotate(transform, a);
//            transform = CGAffineTransformTranslate(transform,-x,-y);
//            start = CGPointApplyAffineTransform(start, transform);
//            end = CGPointApplyAffineTransform(end, transform);
//            break ;
//        }
//    }    
    
    getLimitPoints( &start, &end, rect, 0, direction);
    
    if ( !CGPointEqualToPoint( start, end ) )
        CGContextDrawLinearGradient( context, gradient, start, end, 0 /*kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation*/);

}



static void drawRadialGradient( CGContextRef context, CGGradientRef gradient, CGRect rect, CGFloat centerOffset, DrawGradientDirection direction)
{
    CGPoint start;
    CGPoint end;
    
    getLimitPoints( &start, &end, rect, centerOffset, direction) ;    
    
    if ( !CGPointEqualToPoint( start, end ) )
    {
        CGPoint middle = CGPointMake( rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2) ;
        CGContextDrawRadialGradient(context, gradient, start, 0.0, middle, rect.size.width/2, 0 /*(kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation)*/);
    }
}



static void drawGlossAndGradient(CGContextRef context, CGRect rect, CGColorRef color ) 
{
    const CGFloat i=1.1f ;
    const CGFloat m=0.8f ;
    
    //CGFloat a = 0.5f ;
       
    CGFloat locations[2] = { 0.0f, 1.0f };
    CGFloat colors[8] ;

    const CGFloat *components = CGColorGetComponents(color) ;
    for ( int k=0 ; k<3 ; k++ ) colors[k] = i*components[k] ;
    colors[3] = components[3] ;
    for ( int k=0 ; k<3 ; k++ ) colors[k+4] = m*components[k] ;
    colors[3+4] = components[3] ;


    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents( rgb, colors, locations, 2 );
    drawLinearGradient( context, gradient, rect, DrawGradientDirectionDown ) ;
    CGGradientRelease(gradient);
    
    CGFloat colorsb[8] = 
    { 
       /* 1.0, 1.0, 1.0, 0.1,
        1.0, 1.0, 1.0, 0.35, */
        
        1.0, 1.0, 1.0, 0.35, 
        1.0, 1.0, 1.0, 0.1,
    } ;
    
    CGRect topHalf = CGRectMake(rect.origin.x, rect.origin.y/*+rect.size.height/2*/, rect.size.width, rect.size.height/2);
    
    gradient = CGGradientCreateWithColorComponents( rgb, colorsb, locations, 2 );
    drawLinearGradient( context, gradient, topHalf, DrawGradientDirectionDown ) ;
    CGGradientRelease(gradient);
    CGColorSpaceRelease(rgb);
}

static void drawDoubleGradientRect(  CGContextRef context, CGRect rect, CGColorRef color )
{
    const CGFloat i=1.0f ;
    const CGFloat m=0.55f ;
    const CGFloat n=0.45f ;
    const CGFloat e=0.0f ;
    
    CGFloat a = 0.5f ;
    
    CGFloat colors[] =
    {
        e, e, e, a,
        n, n, n, a,
        m, m, m, a,
        i, i, i, a
    };
    
    CGFloat locations[4] = { 0.0f, 0.5f, 0.5f, 1.0f };

    // primer pinta un rectangle del color que ens pasen
    CGContextSetFillColorWithColor(context, color) ;
    CGContextFillRect(context, rect) ;

    // despres superposa un gradient
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, colors, locations, 4 /*sizeof(colors)/(sizeof(colors[0])*4)*/ ) ;
    
    CGPoint start = rect.origin;
    CGPoint end = CGPointMake(rect.origin.x, rect.origin.y+rect.size.height);
    CGContextDrawLinearGradient( context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(rgb);
}


void drawSingleGradientRect( CGContextRef context, CGRect rect, CGColorRef color, DrawGradientDirection direction )
{
    const CGFloat i=1.1f ;    // + clar
    const CGFloat m=0.8f ;    // + fosc
    
    //CGFloat a = 0.5f ;
       
    CGFloat locations[2] = { 0.0f, 1.0f };
    CGFloat colors[8] ; ;

    const CGFloat *components = CGColorGetComponents(color) ;
    for ( int k=0 ; k<3 ; k++ ) colors[k] = i*components[k] ;
    colors[3] = components[3] ;
    for ( int k=0 ; k<3 ; k++ ) colors[k+4] = m*components[k] ;
    colors[3+4] = components[3] ;
    
    
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents( rgb, colors, locations, 2 );
    drawLinearGradient( context, gradient, rect, direction ) ;
    CGGradientRelease(gradient);
    CGColorSpaceRelease(rgb);
    
}

void drawLinearGradientRect( CGContextRef context, CGRect rect, CGColorRef begcolor, CGColorRef endcolor, DrawGradientDirection direction )
{
    const void * ccolors[] = { begcolor, endcolor } ;
    CFArrayRef colors = CFArrayCreate( NULL, ccolors, 2, NULL) ;
    
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(rgb, colors, NULL) ;

    drawLinearGradient( context, gradient, rect, direction ) ;
    
    CGGradientRelease(gradient) ;
    CGColorSpaceRelease(rgb) ;
    CFRelease(colors) ;
}


void drawRadialGradientRect( CGContextRef context, CGRect rect, CGColorRef begcolor, CGColorRef endcolor, CGFloat centerOffset, DrawGradientDirection direction )
{
    const void * ccolors[] = { begcolor, endcolor };
    CFArrayRef colors = CFArrayCreate( NULL, ccolors, 2, NULL);
    
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(rgb, colors, NULL);

    drawRadialGradient( context, gradient, rect, centerOffset, direction );
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(rgb);
    CFRelease(colors);

}


void drawRectWithStyle( CGContextRef context, CGRect rect, CGColorRef color, int style )
{
    if ( style == 0 ) drawGlossAndGradient( context, rect, color );
    else if ( style == 1 ) drawSolidRect( context, rect, color ) ;
    else if ( style == 2 ) drawSingleGradientRect( context, rect, color, DrawGradientDirectionDown ) ;
    else if ( style == 3 ) drawSingleGradientRect( context, rect, color, DrawGradientDirectionUp ) ;
    //else drawGlossyRect( rect, color, context );
}


UIImage *glossyImageWithSizeAndColor( CGSize size, CGColorRef color, BOOL border, BOOL bottomLine, CGFloat radius, int style )
{
    return glossyImageWithSizeAndColorScaled(size,color,border,bottomLine,radius,style,0);
}


UIImage *glossyImageWithSizeAndColorScaled( CGSize size, CGColorRef color, BOOL border, BOOL bottomLine, CGFloat radius, int style, CGFloat scale )
{
	static const CGFloat MIN_SIZE = 1;
	
	// Get and check size
    //CGSize size = rect.size;
    if ((size.width < MIN_SIZE) || (size.height < MIN_SIZE)) return nil;
	
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    // Convert co-ordinate system to Cocoa's (origin in UL, not LL)
//    CGContextTranslateCTM(context, 0, size.height);
//    CGContextConcatCTM(context, CGAffineTransformMakeScale(1, -1));
    
    // Prepare clipping rect
    CGRect rect = CGRectMake( 0,0,size.width,size.height);
    CGRect clipRect = rect ;
    if ( border )
    {
        clipRect = CGRectInset(rect, 0.5f, 0.5f);
        CGContextSaveGState( context );
    }

    // Prepare clipping region
    addRoundedRectPath( context, clipRect, radius, 0 );
    CGContextClip(context);
		
    // Draw glossy image
    drawRectWithStyle( context, clipRect, color, style ) ;
    
    if (border)
	{
        // Restore context before drawing border
        CGContextRestoreGState( context );
        
        // Set line with
        CGContextSetLineWidth(context, 1.0f);
        
        // Set stroke color
        //CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:0.0f alpha:0.5f] CGColor]);
        CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:0.33f alpha:1.0f] CGColor]);
        
        // Draw border
        
        CGRect borderRect = CGRectInset(rect, 0.5f, 0.5f);
        if ( bottomLine )
        {
            borderRect.size.height -= 1.0f;
        }
        
		addRoundedRectPath( context, borderRect, radius, 0 );
		CGContextStrokePath(context);
        
        if ( bottomLine )
        {
            CGFloat borderBottom = borderRect.origin.y + borderRect.size.height + 1.0f;
            CGFloat borderRight = borderRect.origin.x + borderRect.size.width;
            CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:1.0f alpha:1.0f] CGColor]);
            CGContextMoveToPoint( context, 0, borderBottom );
            CGContextAddLineToPoint( context, borderRight, borderBottom );
            CGContextStrokePath( context );
        }
    }
    
/*
    //
    // aquest esta basat en el diseny original (no esborrar, guardar per referencia)
    //
    if (border)
	{
		// Draw border
        CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:0.3f alpha:1.0f] CGColor]);
		setPathToRoundedRect(CGRectMake(0.5f, 0.5f, size.width-1, size.height-1), 0, context);
		CGContextStrokePath(context);
		
		// Prepare clipping region
		setPathToRoundedRect(CGRectMake(1, 1, size.width-2, size.height-2), 1, context);
		CGContextClip(context);

		// Draw glossy image
		drawDoubleGradientRect( context, CGRectMake(1, 1, size.width-2, size.height-2), color );
	}
    else
    {
        // Prepare clipping region
		setPathToRoundedRect( CGRectMake(0, 0, size.width, size.height), 0, context ) ;
		CGContextClip(context);
		
		// Draw glossy image
		drawDoubleGradientRect( context, CGRectMake(0, 0, size.width, size.height), color ) ;
    }
*/


	// Create and assign image
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext() ;
	
	// Release image context
	UIGraphicsEndImageContext();
    
    // return
    return image ;
}





