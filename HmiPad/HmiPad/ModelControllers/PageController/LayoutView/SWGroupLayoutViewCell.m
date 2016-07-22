//
//  SWGroupView.m
//  HmiPad
//
//  Created by Joan Lluch on 31/12/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWGroupLayoutViewCell.h"

#import "SWLayoutView.h"


@interface SWGroupLayoutViewCell()

@end


@implementation SWGroupLayoutViewCell

- (id)initWithContentView:(UIView*)contentView
{
    self = [super initWithContentView:contentView];
    {
        NSAssert( [contentView isKindOfClass:[SWLayoutView class]], @"Content class must be a SWLayoutView");
    }
    return self;
}


- (SWLayoutView *)contentLayoutView
{
    return (id)_contentView;
}


- (void)reloadLayoutSettings
{
    [super reloadLayoutSettings];
    
    SWLayoutView *parentLayoutView = self.parentLayoutView;
    SWLayoutView *layoutView = self.contentLayoutView;
    
    [layoutView setShowsErrorFramesInEditMode:parentLayoutView.showsErrorFramesInEditMode];
    [layoutView setShowsHiddenItemsInEditMode:parentLayoutView.showsHiddenItemsInEditMode];
    [layoutView setEditMode:parentLayoutView.editMode];
}


static BOOL _pointInside_withEvent_forView(CGPoint point, UIEvent *event, UIView *view)
{
    BOOL isInside = NO;
    for ( UIView *sub in [view.subviews reverseObjectEnumerator] )
    {
        CGPoint pt = [view convertPoint:point toView:sub];
        if ( [sub isKindOfClass:[SWLayoutViewCell class]] )
        {
            isInside = [sub pointInside:pt withEvent:event];
        }
        else
        {
            isInside = _pointInside_withEvent_forView(pt, event, sub);
        }
        if ( isInside ) break;
    }
    return isInside;
}


// considerem que el punt es dins si el punt es estrictament dins de un dels seus subviews
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL isInside = _pointInside_withEvent_forView(point, event, self);
    return isInside;
}




@end
