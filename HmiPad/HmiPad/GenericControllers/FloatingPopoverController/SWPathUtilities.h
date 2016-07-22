//
//  SWPathUtilities.h
//  FloatingPopover
//
//  Created by Joan Martín Hernàndez on 6/27/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <Foundation/Foundation.h>

CGPathRef CQMPathCreateRoundingRect(CGRect rect, CGFloat blRadius, CGFloat brRadius, CGFloat trRadius, CGFloat tlRadius);
CGPathRef CQMPathCreateInvertedRoundingRect(CGRect rect, CGFloat blRadius, CGFloat brRadius, CGFloat trRadius, CGFloat tlRadius);
