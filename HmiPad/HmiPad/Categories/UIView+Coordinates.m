//
//  UIView+Coordinates.m
//  layoutController
//
//  Created by Joan Martín Hernàndez on 2/6/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import "UIView+Coordinates.h"

@implementation UIView (Coordinates)

- (CGPoint)topRight
{
    CGRect frame = self.frame ;
    return CGPointMake(frame.origin.x + frame.size.width, frame.origin.y);
}

- (CGPoint)topLeft
{
    return self.frame.origin;
}

- (CGPoint)bottomRight
{
    CGRect frame = self.frame ;
    return CGPointMake(frame.origin.x + frame.size.width, frame.origin.y + frame.size.height);
}

- (CGPoint)bottomLeft
{
    CGRect frame = self.frame ;
    return CGPointMake(frame.origin.x, frame.origin.y + frame.size.height);    
}

@end
