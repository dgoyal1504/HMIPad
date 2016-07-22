//
//  SWFloatingFrameView.m
//  FloatingPopover
//
//  Created by Joan Martín Hernàndez on 6/27/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SWFloatingFrameView.h"
#import "SWPathUtilities.h"

#import "Drawing.h"


#define kLightBorderWidth    1.0f
#define kHighlightHeight     22.0f
#define kHighlightMargin     1.0f
//#define kLightBorderColor    [UIColor colorWithWhite:1.00f alpha:0.10f]
#define kLightBorderColor    [UIColor colorWithWhite:1.00f alpha:0.30f]
#define kStartHighlightColor [UIColor colorWithWhite:1.00f alpha:0.40f]
#define kEndHighlightColor   [UIColor colorWithWhite:1.00f alpha:0.05f]
#define kDefaultOuterCornerRadius 8.0f

#define kOuterShadowColor       [UIColor blackColor]
#define kOuterShadowOffset      CGSizeMake(0, 2.0f)

#define kShadowOpacity     0.70f
#define kShadowRadius      20.0f


@implementation SWFloatingFrameView

@synthesize cornerRadius = cornerRadius_;
@synthesize baseColor = baseColor_;

- (id)init 
{
    self = [super init];
	if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.cornerRadius = kDefaultOuterCornerRadius;
        CALayer *layer = self.layer;
        [layer setShadowColor:[kOuterShadowColor CGColor]];
        [layer setShadowOffset:kOuterShadowOffset];
        [layer setShadowOpacity:kShadowOpacity];
        [layer setShadowRadius:kShadowRadius];
        [layer setMasksToBounds:NO];
	}
	return self;
}

#pragma mark Properties

- (void)setBaseColor:(UIColor*)baseColor 
{
    baseColor_ = baseColor;
	[self setNeedsDisplay];
}

- (void)setCornerRadius:(CGFloat)cornerRadius 
{
	cornerRadius_ = cornerRadius;
	[self setNeedsDisplay];
}

#pragma mark Overriden Methods

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.bounds;
    //UIBezierPath *path = [UIBezierPath bezierPathWithRect:frame];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:cornerRadius_];
    [self.layer setShadowPath:path.CGPath];
}


- (void)drawRectV:(CGRect)rect
{
	[super drawRect:rect];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGFloat radius = [self cornerRadius];
	CGSize viewSize = [self frame].size;
	CGPathRef path;
	
	// Light border
	CGContextSaveGState(context);
	CGFloat borderRadius = radius + kLightBorderWidth;
	path = CQMPathCreateRoundingRect(CGRectMake(0, 0,
												viewSize.width, viewSize.height),
									 borderRadius, borderRadius, borderRadius, borderRadius);
	CGContextAddPath(context, path);
	CGContextSetFillColorWithColor(context, [kLightBorderColor CGColor]);
	CGContextFillPath(context);
	CGPathRelease(path);
	CGContextRestoreGState(context);
	
	// Base ( tota la superficie )
	CGContextSaveGState(context);
	path = CQMPathCreateRoundingRect(CGRectMake(kLightBorderWidth, kLightBorderWidth,
												viewSize.width - kLightBorderWidth * 2,
												viewSize.height - kLightBorderWidth * 2),
									 radius, radius, radius, radius);
	CGContextAddPath(context, path);
	CGContextSetFillColorWithColor(context, [self.baseColor CGColor]);
	CGContextFillPath(context);
	CGPathRelease(path);
	CGContextRestoreGState(context);
	
    if ( IS_IOS7 )
    {
    
    }
    else
    {
	// Highlight (el gradient que es dibuixa a la capsalera, una mica insetat)
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	NSArray *colors = [[NSArray alloc] initWithObjects:
					   (id)[kStartHighlightColor CGColor],
					   (id)[kEndHighlightColor CGColor],
					   nil];
	CGFloat locations[] = {0, 1.0f};
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
	CGFloat highlightMargin = kLightBorderWidth + kHighlightMargin;
	CGRect highlightRect = CGRectMake(highlightMargin, highlightMargin,
									  viewSize.width - highlightMargin * 2,
									  kHighlightHeight);
	CGFloat highlightRadius = radius - kHighlightMargin;
	CGContextSaveGState(context);
	path = CQMPathCreateRoundingRect(highlightRect,
									 0, 0, highlightRadius, highlightRadius);
	CGContextAddPath(context, path);
	CGContextClip(context);
	CGContextDrawLinearGradient(context, gradient,
								CGPointMake(0, 0),
								CGPointMake(0, kHighlightHeight),
								0);
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);
	CGPathRelease(path);
	CGContextRestoreGState(context);
    }
}




- (void)drawRect:(CGRect)rect
{
	//[super drawRect:rect];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGFloat radius = [self cornerRadius];
	CGSize viewSize = [self bounds].size;
	CGPathRef path;
	
	// Light border
	CGContextSetFillColorWithColor(context, [kLightBorderColor CGColor]);
    addRoundedRectPath( context, rect, radius+kLightBorderWidth, 0);
    CGContextFillPath(context);
	
	// Base ( tota la superficie )
	CGContextSetFillColorWithColor(context, [self.baseColor CGColor]);
    //CGRect rectInset = CGRectInset(rect, kLightBorderWidth, kLightBorderWidth);
    addRoundedRectPath( context, rect, radius+kLightBorderWidth, kLightBorderWidth);
    CGContextFillPath(context);
	
    if ( IS_IOS7 )
    {
    
    }
    else
    {
	// Highlight (el gradient que es dibuixa a la capsalera, una mica insetat)
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	NSArray *colors = [[NSArray alloc] initWithObjects:
					   (id)[kStartHighlightColor CGColor],
					   (id)[kEndHighlightColor CGColor],
					   nil];
	CGFloat locations[] = {0, 1.0f};
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
	CGFloat highlightMargin = kLightBorderWidth + kHighlightMargin;
	CGRect highlightRect = CGRectMake(highlightMargin, highlightMargin,
									  viewSize.width - highlightMargin * 2,
									  kHighlightHeight);
	CGFloat highlightRadius = radius - kHighlightMargin;
	CGContextSaveGState(context);
	path = CQMPathCreateRoundingRect(highlightRect,
									 0, 0, highlightRadius, highlightRadius);
	CGContextAddPath(context, path);
	CGContextClip(context);
	CGContextDrawLinearGradient(context, gradient,
								CGPointMake(0, 0),
								CGPointMake(0, kHighlightHeight),
								0);
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);
	CGPathRelease(path);
	CGContextRestoreGState(context);
    }
}





@end
