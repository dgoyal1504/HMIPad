//
//  CGGeometry+Additions.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 5/7/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

CG_INLINE CGPoint CGPointTopLeft(CGRect frame)
{
    return frame.origin;
}

CG_INLINE CGPoint CGPointTopRight(CGRect frame)
{
    return CGPointMake(frame.origin.x + frame.size.width, frame.origin.y);
}

CG_INLINE CGPoint CGPointBottomLeft(CGRect frame)
{
    return CGPointMake(frame.origin.x, frame.origin.y + frame.size.height);
}

CG_INLINE CGPoint CGPointBottomRight(CGRect frame)
{
    return CGPointMake(frame.origin.x + frame.size.width, frame.origin.y + frame.size.height);
}

CG_INLINE CGPoint CGPointCenter(CGRect frame)
{
    return CGPointMake(frame.origin.x + frame.size.width/2.0, frame.origin.y + frame.size.height/2.0);
}

CG_INLINE CGRect CGRectMakeFromOriginAndSize(CGPoint origin, CGSize size)
{
    CGRect frame = CGRectZero;
    frame.origin = origin;
    frame.size = size;
    return frame;
}

CG_INLINE CGFloat CGPointDistanceToPoint(CGPoint point1, CGPoint point2)
{
    return sqrtf((point1.x - point2.x)*(point1.x - point2.x) + (point1.y - point2.y)*(point1.y - point2.y));
}

// --- CIRCLE --- //

struct CGCircle
{
    CGPoint center;
    CGFloat radius;
};
typedef struct CGCircle CGCircle;

CG_INLINE CGCircle CGCircleMake(CGPoint center, CGFloat radius)
{
    CGCircle circle = {center,radius};
    return circle;
}

CG_INLINE bool __CGCircleEqualToCircle(CGCircle circle1, CGCircle circle2)
{
    return  CGPointEqualToPoint(circle1.center, circle2.center) && circle1.radius == circle2.radius;
}
#define CGCircleEqualToCGCircle __CGCircleEqualToCircle

extern const CGCircle CGCircleZero;

CG_INLINE bool __CGPointInsideCircle(CGPoint point, CGCircle circle)
{
    return (circle.center.x - point.x)*(circle.center.x - point.x) + (circle.center.y - point.y)*(circle.center.y - point.y) <= circle.radius*circle.radius;
}
#define CGPointInsideCircle __CGPointInsideCircle

