//
//  SWFloatingContentOverlayView.m
//  FloatingPopover
//
//  Created by Joan Martín Hernàndez on 6/27/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWFloatingContentOverlayView.h"
#import "SWPathUtilities.h"

#define kDefaultCornerRadius 5.0f
#define kShadowOffset        CGSizeMake(0, 1.0f)
#define kShadowBlur          2.0f
#define kShadowColor         [UIColor colorWithWhite:0 alpha:0.8f]

@implementation SWFloatingContentOverlayView 

@synthesize edgeColor = _edgeColor;
@synthesize cornerRadius = _cornerRadius;

- (id)init 
{
    self = [super init];
	if (self) 
    {
		[self setBackgroundColor:[UIColor clearColor]];
		[self setCornerRadius:kDefaultCornerRadius];
	}
	return self;
}

#pragma mark Properties

+ (CGFloat)frameWidth 
{
	return kShadowBlur;
}

- (void)setCornerRadius:(CGFloat)cornerRadius 
{
	_cornerRadius = cornerRadius;
	[self setNeedsDisplay];
}

- (void)setEdgeColor:(UIColor*)edgeColor 
{
    _edgeColor = edgeColor;
	[self setNeedsDisplay];
}

#pragma mark Overriden Methods

- (void)drawRect:(CGRect)rect 
{
	[super drawRect:rect];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGSize viewSize = [self frame].size;
	CGFloat radius = _cornerRadius;
	CGPathRef path;
	
	CGContextSaveGState(context);
	CGFloat frameWidth = [SWFloatingContentOverlayView frameWidth];
	path = CQMPathCreateRoundingRect(CGRectMake(frameWidth, frameWidth,
												viewSize.width - frameWidth * 2,
												viewSize.height - frameWidth * 2),
									 radius, radius, radius, radius);
	CGContextAddRect(context, CGRectMake(0, 0,
										 viewSize.width, viewSize.height));
	CGContextAddPath(context, path);
	CGContextSetFillColorWithColor(context, _edgeColor.CGColor);
	CGContextSetShadowWithColor(context, kShadowOffset, kShadowBlur, [kShadowColor CGColor]);
	CGContextEOFillPath(context);
	CGContextDrawPath(context, 0);
	CGPathRelease(path);
	CGContextRestoreGState(context);
}

@end
