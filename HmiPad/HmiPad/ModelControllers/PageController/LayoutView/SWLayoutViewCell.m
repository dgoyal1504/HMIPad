//
//  SWLayoutViewCell.m
//  HmiPad
//
//  Created by Joan Martin on 9/6/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWLayoutViewCell.h"
#import "SWLayoutView.h"
#import "UIView+ColorOfPoint.h"
#import "SWColorCoverView.h"

@implementation SWLayoutViewCell
{
    CGFloat _zoomScaleFactor;
    SWColorCoverView *_coverView;
    unsigned int _hiddenItem:1;
    unsigned int _editMode:1;
    unsigned int _showsHiddenItemsInEditMode:1;
    unsigned int _showsCoverInEditMode:1;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithContentView:nil];
}

- (id)initWithContentView:(UIView*)contentView
{
    self = [super initWithFrame:contentView.bounds];
    if (self)
    {
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];
        
        _useAlphaChanelToComputePointInside = NO;
        _zoomScaleFactor = 1.0f;
        
        _contentView = contentView;
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        [self addSubview:_contentView];
    }
    return self;
}


#pragma mark - Properties and Methods

- (SWLayoutView *)contentLayoutView
{
    return nil;
}


- (void)setSelected:(BOOL)selected
{
    _selected = selected;
}


- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
}


- (void)setShowsCoverInEditMode:(BOOL)showsCoverInEditMode
{
    _showsCoverInEditMode = showsCoverInEditMode;
    if ( _coverView )
        [_coverView setShowsCoverInEditMode:showsCoverInEditMode];
}


- (void)setShowsHiddenItemsInEditMode:(BOOL)showsHiddenItemsInEditMode
{
    _showsHiddenItemsInEditMode = showsHiddenItemsInEditMode;
    if ( _hiddenItem && _editMode )
        [self setHiddenStatus:YES animated:YES];
}


- (void)setEditMode:(BOOL)editMode
{
    _editMode = editMode;
    if ( _coverView )
        [_coverView setEditMode:editMode];
    
    if ( _hiddenItem )
        [self setHiddenStatus:YES animated:YES];
}


- (void)setUseAlphaChanelToComputePointInside:(BOOL)useAlphaChanelToComputePointInside
{
    _useAlphaChanelToComputePointInside = useAlphaChanelToComputePointInside;
}


- (void)setZoomScaleFactor:(CGFloat)zoomScaleFactor
{

//    if ( _coverView )
//    {
//        CGFloat contentScale = [[UIScreen mainScreen]scale]*zoomScaleFactor;
//        [_coverView setContentScaleFactor:contentScale];
//    }

    _zoomScaleFactor = zoomScaleFactor;
    if ( _coverView )
        [_coverView setZoomScaleFactor:zoomScaleFactor];
}

- (CGFloat)zoomScaleFactor
{
//    CGFloat zoomScale = _coverView.contentScaleFactor/[[UIScreen mainScreen]scale];
//    return zoomScale;
    
    return _zoomScaleFactor;
}

- (UIColor*)coverTintColor
{
    return _coverView.coverColor;
}


- (void)setCoverViewColor:(UIColor*)color
{    
    if (color)
    {
        [_coverView removeFromSuperview];
        
        _coverView = [[SWColorCoverView alloc] initForRect:self.bounds andColor:color];
        _coverView.contentMode = UIViewContentModeRedraw;
        _coverView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_coverView setEditMode:_editMode];
        [_coverView setShowsCoverInEditMode:_showsCoverInEditMode];
        
        [self addSubview:_coverView];
        [_coverView setZoomScaleFactor:_zoomScaleFactor];  // Despres de addSubview
    }
    else
    {
        [_coverView removeFromSuperview];
        _coverView = nil;
    }
}


- (void)setViewBackColor:(UIColor*)color
{
    [self setBackgroundColor:color];
}


- (void)setHiddenStatus:(BOOL)hidden animated:(BOOL)animated
{
//    if ( _hidden == hidden )
//        return;

    CGFloat alpha = 1.0f;
    _hiddenItem = hidden;
    if ( hidden )
    {
        alpha = (_editMode&&_showsHiddenItemsInEditMode)?0.5:0.0;
    }
    
    [UIView animateWithDuration:(animated?0.3:0.0) animations:^
    {
        [self setAlpha:alpha];
    }];
}


- (void)reloadLayoutSettings
{
    SWLayoutView *layoutView = _parentLayoutView;
    [self setShowsCoverInEditMode:layoutView.showsErrorFramesInEditMode];
    [self setShowsHiddenItemsInEditMode:layoutView.showsHiddenItemsInEditMode];
    [self setEditMode:layoutView.editMode];
}


- (void)reloadLayoutFrame
{
    SWLayoutView *layoutView = _parentLayoutView;
    [layoutView reloadFrameForCell:self animated:NO];
}


#pragma mark - View Override

- (void)didMoveToSuperview
{
    if ( self.superview != nil )
    {
        [self reloadLayoutSettings];
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
}


//#pragma mark contentScale
//
//- (void)setContentScaleFactor:(CGFloat)contentScaleFactor
//{
//    [super setContentScaleFactor:contentScaleFactor];
//    [_coverView setContentScaleFactor:contentScaleFactor];
//}


#pragma mark - Point Inside Behavoiur

// si _useAlphaChanelToComputePointInside considerem que es dins si el punt on hem tocat no es transparent
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL isInside = [super pointInside:point withEvent:event];
    
    if ( isInside && _useAlphaChanelToComputePointInside )
    {
        CGFloat alpha = [self alphaAtPoint:point];
        
        BOOL isTransparent = alpha < 0.01f;
        isInside = !isTransparent;
    }
    return isInside;
}

@end


@implementation SWLayoutViewCell(subLayout)

- (CGRect)layoutViewConvertedFrame
{
    SWLayoutOverlayView *layoutOverlayView = _parentLayoutView.layoutOverlayView;
    CGRect convertedFrame = [layoutOverlayView convertRect:self.bounds fromView:self];
    return convertedFrame;
}

@end;
