//
//  SWPathUtilities.m
//  FloatingPopover
//
//  Created by Joan Martín Hernàndez on 6/27/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWPathUtilities.h"

CGPathRef CQMPathCreateRoundingRect(CGRect rect, CGFloat blRadius, CGFloat brRadius, CGFloat trRadius, CGFloat tlRadius) {
	CGPoint tlPoint = rect.origin;
	CGPoint brPoint = CGPointMake(rect.origin.x + rect.size.width,
								  rect.origin.y + rect.size.height);
	CGMutablePathRef path = CGPathCreateMutable();
	
	CGPathMoveToPoint(path, NULL, tlPoint.x + tlRadius, tlPoint.y);
	CGPathAddArcToPoint(path, NULL,
						brPoint.x, tlPoint.y,
						brPoint.x, tlPoint.y + trRadius,
						trRadius);
	CGPathAddArcToPoint(path, NULL,
						brPoint.x, brPoint.y,
						brPoint.x - brRadius, brPoint.y,
						brRadius);
	CGPathAddArcToPoint(path, NULL,
						tlPoint.x, brPoint.y,
						tlPoint.x, brPoint.y - blRadius,
						blRadius);
	CGPathAddArcToPoint(path, NULL,
						tlPoint.x, tlPoint.y,
						tlPoint.x + tlRadius, tlPoint.y,
						tlRadius);
	CGPathCloseSubpath(path);
	
	return path;
}


CGPathRef CQMPathCreateInvertedRoundingRect(CGRect rect, CGFloat blRadius, CGFloat brRadius, CGFloat trRadius, CGFloat tlRadius) {
	CGPoint tlPoint = rect.origin;
	CGPoint brPoint = CGPointMake(rect.origin.x + rect.size.width,
								  rect.origin.y + rect.size.height);
	CGMutablePathRef path = CGPathCreateMutable();
	
	// Top left
	CGPathMoveToPoint(path, NULL, tlPoint.x, tlPoint.y);
	CGPathAddLineToPoint(path, NULL,
						 tlPoint.x + tlRadius, tlPoint.y);
	CGPathAddArcToPoint(path, NULL,
						tlPoint.x, tlPoint.y,
						tlPoint.x, tlPoint.y + tlRadius,
						tlRadius);
	CGPathCloseSubpath(path);
	
	// Top right
	CGPathMoveToPoint(path, NULL, brPoint.x, tlPoint.y);
	CGPathAddLineToPoint(path, NULL,
						 brPoint.x, tlPoint.y + trRadius);
	CGPathAddArcToPoint(path, NULL,
						brPoint.x, tlPoint.y,
						brPoint.x - trRadius, tlPoint.y,
						trRadius);
	CGPathCloseSubpath(path);
	
	// Bottom right
	CGPathMoveToPoint(path, NULL, brPoint.x, brPoint.y);
	CGPathAddLineToPoint(path, NULL,
						 brPoint.x - brRadius, brPoint.y);
	CGPathAddArcToPoint(path, NULL,
						brPoint.x, brPoint.y,
						brPoint.x, brPoint.y - brRadius,
						brRadius);
	CGPathCloseSubpath(path);
	
	// Bottom left
	CGPathMoveToPoint(path, NULL, tlPoint.x, brPoint.y);
	CGPathAddLineToPoint(path, NULL, tlPoint.x, brPoint.y - blRadius);
	CGPathAddArcToPoint(path, NULL,
						tlPoint.x, brPoint.y,
						tlPoint.x + blRadius, brPoint.y,
						blRadius);
	CGPathCloseSubpath(path);
	
	return path;
}	
						
