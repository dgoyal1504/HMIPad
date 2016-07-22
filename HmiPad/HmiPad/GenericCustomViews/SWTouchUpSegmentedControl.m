//
//  SWTouchUpSegmentedControl.m
//  HmiPad
//
//  Created by Joan on 25/06/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWTouchUpSegmentedControl.h"


@interface SWTouchUpSegmentedControl()
{
    NSInteger _initialSelectedIndex;
    NSInteger _selectedIndexStore;
    BOOL _isInside;
}

@end


@implementation SWTouchUpSegmentedControl


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _isInside = YES;
    _initialSelectedIndex = self.selectedSegmentIndex;
    
    [super touchesBegan:touches withEvent:event];
    
    _selectedIndexStore = self.selectedSegmentIndex;
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGRect onePointRect = CGRectMake(point.x, point.y, 1, 1);
    
    CGRect boundedRect = CGRectInset(self.bounds, -40, -40);
    BOOL isAlmostInside = ( CGRectIntersectsRect(onePointRect, boundedRect));
    if ( _isInside != isAlmostInside )
    {
        [self setSelectedSegmentIndex:isAlmostInside?_selectedIndexStore:-1];
        _isInside = isAlmostInside;
    }
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if ( _isInside )
    {
        [super sendActionsForControlEvents:UIControlEventValueChanged];  // call super now!
        if ( !_toggleControl ) [self setSelectedSegmentIndex:-1];
    }
    else
    {
        [self setSelectedSegmentIndex:_toggleControl?_initialSelectedIndex:-1];
    }
}


- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents
{
    //   do NOT call super
    _selectedIndexStore = self.selectedSegmentIndex;
}


//- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
//{
//    [super sendAction:action to:target forEvent:event];
//    if ( !_toggleControl ) [self setSelectedSegmentIndex:-1];  // reset segmented control
//}


@end


