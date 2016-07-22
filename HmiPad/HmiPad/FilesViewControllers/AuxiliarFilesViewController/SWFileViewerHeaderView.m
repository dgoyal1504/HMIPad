//
//  SWFileViewerHeaderView.m
//  HmiPad
//
//  Created by Joan on 10/12/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWFileViewerHeaderView.h"

@implementation SWFileViewerHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext() ;
    
//    UIColor *color1 = [UIColor colorWithWhite:1.0f alpha:1.0f];
    UIColor *color2 = [UIColor colorWithWhite:0.8f alpha:1.0f];
    
    
//    CGContextMoveToPoint( context, rect.origin.x, rect.origin.y+0.5 ) ;
//    CGContextAddLineToPoint( context, rect.origin.x + rect.size.width, rect.origin.y+0.5 ) ;
//    CGContextSetLineWidth( context, 1 ) ;
//    CGContextSetStrokeColorWithColor( context, [color1 CGColor]) ;
//    CGContextStrokePath( context ) ;
    
    CGContextMoveToPoint( context, rect.origin.x, rect.origin.y+rect.size.height-0.5 ) ;
    CGContextAddLineToPoint( context, rect.origin.x + rect.size.width, +rect.size.height-0.5 ) ;
    CGContextSetLineWidth( context, 1 ) ;
    CGContextSetStrokeColorWithColor( context, [color2 CGColor]) ;
    CGContextStrokePath( context ) ;
    
    [super drawRect:rect] ;
}


- (IBAction)segmentedValueChanged:(id)sender
{
    if ( [_delegate respondsToSelector:@selector(fileViewerHeaderView:didSelectSegmentAtIndex:)])
    {
        NSInteger indx = [_segmented selectedSegmentIndex];
        [_delegate fileViewerHeaderView:self didSelectSegmentAtIndex:indx];
    }
}

- (void)setSegmentedValue:(NSInteger)value
{
    [_segmented setSelectedSegmentIndex:value];
}

@end
