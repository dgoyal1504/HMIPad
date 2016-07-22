//
//  SWLayoutOverlayCoordinatorView.m
//  HmiPad
//
//  Created by Joan Lluch on 12/01/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWLayoutOverlayCoordinatorView.h"
#import "SWLayoutView.h"
#import "SWLayoutOverlayView.h"

@interface SWLayoutOverlayCoordinatorView()
{
    NSMutableArray *_overlayViews;
}

@end


@implementation SWLayoutOverlayCoordinatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        _overlayViews = [NSMutableArray array];
        _zoomScaleFactor = 1.0f;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)addLayoutViewLayer:(SWLayoutView*)layoutView
{
    if ( layoutView.layoutOverlayView != nil )
        return;

    SWLayoutOverlayView* layoutOverlayView = [[SWLayoutOverlayView alloc] initWithFrame:self.bounds];
    [layoutOverlayView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    layoutOverlayView.backgroundColor = [UIColor clearColor];
    
    [_overlayViews addObject:layoutOverlayView];
    
    [self addSubview:layoutOverlayView];
    //[layoutOverlayView setContentScaleFactor:self.contentScaleFactor];
    [layoutOverlayView setZoomScaleFactor:_zoomScaleFactor];
    
    layoutView.layoutOverlayView = layoutOverlayView;
    
    layoutOverlayView.autoAlignCells = _autoAlignCells;
    layoutOverlayView.showAlignmentRulers = _showAlignmentRulers;
    
    layoutOverlayView.allowFrameEditing = _allowFrameEditing;
    layoutOverlayView.allowsMultipleSelection = _allowsMultipleSelection;
    
    layoutOverlayView.editMode = _editMode;
    
    layoutOverlayView.dataSource = layoutView;
    layoutOverlayView.delegate = layoutView;
    
    //NSLog( @"OverlayCoordinator Add:%p Views %d", (__bridge void*)layoutOverlayView, _overlayViews.count );
}


- (void)removeLayoutViewLayer:(SWLayoutView*)layoutView
{
    SWLayoutOverlayView *layoutOverlayView = layoutView.layoutOverlayView;
    
    [layoutOverlayView removeFromSuperview];
    [_overlayViews removeObjectIdenticalTo:layoutOverlayView];

    layoutView.layoutOverlayView = nil;
    
    //NSLog( @"OverlayCoordinator Rem:%p Views %d", (__bridge void*)layoutOverlayView, _overlayViews.count );
}


- (void)dealloc
{
    //NSLog(@"OverlayCoordinator Dealloc:%p", (__bridge void*)self);
}


- (void)setEditMode:(BOOL)editing
{
    _editMode = editing;
    self.userInteractionEnabled = editing;
    for ( SWLayoutOverlayView *layoutOverlayView in _overlayViews )
        [layoutOverlayView setEditMode:editing];
}


//- (void)setContentScaleFactor:(CGFloat)contentScaleFactor
//{
//    [super setContentScaleFactor:contentScaleFactor];
//    for ( SWLayoutOverlayView *layoutOverlayView in _overlayViews )
//        [layoutOverlayView setContentScaleFactor:contentScaleFactor];
//}


- (void)setZoomScaleFactor:(CGFloat)zoomScaleFactor
{
    for ( SWLayoutOverlayView *layoutOverlayView in _overlayViews )
        [layoutOverlayView setZoomScaleFactor:zoomScaleFactor];
}


- (void)moveToDirection:(SWLayoutResizerViewDirection)direction
{
    SWLayoutOverlayView *layoutOverlayView = [_overlayViews lastObject];
    [layoutOverlayView moveToDirection:direction];
}


- (void)resizeToDirection:(SWLayoutResizerViewDirection)direction
{
    SWLayoutOverlayView *layoutOverlayView = [_overlayViews lastObject];
    [layoutOverlayView resizeToDirection:direction];
}


- (void)setShowAlignmentRulers:(BOOL)showAlignmentRulers
{
    _showAlignmentRulers = showAlignmentRulers;
    for ( SWLayoutOverlayView *layoutOverlayView in _overlayViews )
        layoutOverlayView.showAlignmentRulers = showAlignmentRulers;
}


- (void)setAutoAlignCells:(BOOL)autoAlignCells
{
    _autoAlignCells = autoAlignCells;
    for ( SWLayoutOverlayView *layoutOverlayView in _overlayViews )
        layoutOverlayView.autoAlignCells = autoAlignCells;
}


- (void)setAllowFrameEditing:(BOOL)allowFrameEditing
{
    _allowFrameEditing = allowFrameEditing;
    for ( SWLayoutOverlayView *layoutOverlayView in _overlayViews )
        [layoutOverlayView setAllowFrameEditing:allowFrameEditing];
}


- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection
{
    _allowsMultipleSelection = allowsMultipleSelection;
    for ( SWLayoutOverlayView *layoutOverlayView in _overlayViews )
        layoutOverlayView.allowsMultipleSelection = allowsMultipleSelection;
}


- (void)setSelectionHidden:(BOOL)selectionHidden
{
    _selectionHidden = selectionHidden;
    [self setAlpha:selectionHidden?0:1];
}

@end
