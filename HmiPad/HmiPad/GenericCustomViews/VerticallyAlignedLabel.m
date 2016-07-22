//
//  VerticallyAlignedLabel.m
//  HmiPad
//
//  Created by Joan on 21/05/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "VerticallyAlignedLabel.h"

@implementation VerticallyAlignedLabel
  
- (id)initWithFrame:(CGRect)frame 
{
    if ( (self = [super initWithFrame:frame]) )
    {
        _verticalAlignment = VerticalAlignmentMiddle;
    }
    return self;
}
 
- (void)setVerticalAlignment:(VerticalAlignment)verticalAlignment 
{
    _verticalAlignment = verticalAlignment;
    [self setNeedsDisplay];
}


 
- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines 
{
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    switch (_verticalAlignment)
    {
        case VerticalAlignmentTop:
            textRect.origin.y = bounds.origin.y;
            break;
        case VerticalAlignmentBottom:
            textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height;
            break;
        case VerticalAlignmentMiddle:
            // Fall through.
        default:
            textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0f;
    }
    return textRect;
}
 
-(void)drawTextInRect:(CGRect)requestedRect
{
    CGRect actualRect = [self textRectForBounds:requestedRect limitedToNumberOfLines:self.numberOfLines];
    [super drawTextInRect:actualRect];
}

@end
