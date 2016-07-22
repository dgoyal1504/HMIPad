//
//  SWCrossView.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/29/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import "SWCrossView.h"

#import <QuartzCore/QuartzCore.h>

@implementation SWCrossView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        
        self.layer.masksToBounds = NO;
        self.layer.shadowOffset = CGSizeMake(3, 3);
        self.layer.shadowRadius = 2;
        self.layer.shadowOpacity = 0.8;
        self.layer.shadowPath = [[UIBezierPath bezierPathWithOvalInRect:self.bounds] CGPath];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGFloat lineWidth = 3;
    CGRect circleRect = CGRectMake(lineWidth/2.0, lineWidth/2.0, rect.size.width-lineWidth, rect.size.height-lineWidth);
    
    UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:circleRect];
    circle.lineWidth = lineWidth;
    
    [[UIColor whiteColor] setStroke];
    [[UIColor colorWithRed:0.4 green:0.0 blue:0.0 alpha:1.0] setFill];
   
    [circle fill];
    [circle stroke];
    
    CGFloat offset = rect.size.width * 0.7;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(offset, offset)];
    [path addLineToPoint:CGPointMake(rect.size.width - offset, rect.size.height - offset)];
    [path moveToPoint:CGPointMake(offset, rect.size.height - offset)];
    [path addLineToPoint:CGPointMake(rect.size.width - offset, offset)];
    
    path.lineWidth = lineWidth;
    
    [[UIColor whiteColor] setStroke];
    [path stroke];
}


@end
