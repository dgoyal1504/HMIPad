//
//  SWImagePickerViewCell.m
//  ImagePicker
//
//  Created by Joan Martín Hernàndez on 7/3/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWImagePickerViewCell.h"
#import <QuartzCore/QuartzCore.h>

#import "SWImageManager.h"
#import "SWViewSelectionLayer.h"

@implementation SWImagePickerViewCell
{
    UIImageView *_imageView;
    UIView *_overlayView;
    UIImageView *_checkMarkView;
    SWViewSelectionLayer *_highlightedLayer;
    
    //UITapGestureRecognizer *_tapGesture;
    BOOL _isTouchInside;
}

@synthesize showBorder = _showBorder;
@synthesize selected = _selected;
@synthesize delegate = _delegate;
@dynamic image;
//@synthesize imageDescriptor = _imageDescriptor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        
        _selected = NO;
        _showBorder = NO;
        _highlighted = NO;
        
//        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapGestureRecognized:)];
//        [self addGestureRecognizer:_tapGesture];
    }
    return self;
}

#pragma mark Properties

- (UIImage*)image
{
    return _imageView.image;
}

- (void)setImage:(UIImage *)image
{
    _imageView.image = image;
}

- (void)setImageWithDescriptor:(SWImageDescriptor *)imageDescriptor
{
    //_imageDescriptor = imageDescriptor;
    
    [[SWImageManager defaultManager] getImageWithDescriptor:imageDescriptor completionBlock:^(UIImage *image)
    {
        self.image = image;
    }];
}

//- (void)setShowBorderV:(BOOL)showBorder
//{
//    if (_showBorder == showBorder)
//        return;
//    
//    _showBorder = showBorder;
//    CALayer *layer = self.layer;
//    if (showBorder)
//    {
//        layer.borderWidth = 1;
//        //layer.borderColor = [UIColor blackColor].CGColor;
//        UIColor *borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
//        layer.borderColor = borderColor.CGColor;
//    }
//    else
//    {
//        layer.borderWidth = 0;
//    }
//}

- (void)setShowBorder:(BOOL)showBorder
{
    if (_showBorder == showBorder)
        return;
    
    _showBorder = showBorder;

    [self _updatePresentationState];
}



- (void)setHighlighted:(BOOL)highlighted
{
    if (_highlighted == highlighted)
        return;
 
    _highlighted = highlighted;
    
    [self _updatePresentationState];
}


- (void)setSelected:(BOOL)selected
{
    if (_selected == selected)
        return;
 
    _selected = selected;
    
    [self _updatePresentationState];
}

#pragma mark Overriden Methods


#pragma mark Public Methods

- (void)prepareForReuse
{
    _imageView.image = nil;
    self.selected = NO;
    self.highlighted = NO;
}

#pragma mark Private Methods

- (void)_tapGestureRecognized:(UITapGestureRecognizer*)recognizer
{    
    if ([_delegate respondsToSelector:@selector(tapReceivedInImagePickerViewCell:)])
        [_delegate tapReceivedInImagePickerViewCell:self];
}


- (void)_updatePresentationStateV
{
    CGRect bounds = self.bounds;
    if ( _selected || _highlighted )
    {
        if ( _overlayView == nil )
        {
            _overlayView = [[UIView alloc] initWithFrame:CGRectMake(0,0,bounds.size.width,bounds.size.height)];
            [self addSubview:_overlayView];
        }
        
    }

    if ( _selected )
    {
        [_overlayView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
        [_highlightedLayer remove];
        _highlightedLayer = nil;
        
        if ( _checkMarkView == nil )
        {
            _checkMarkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkWhiteShadow.png"]];
            [_checkMarkView setContentMode:UIViewContentModeCenter];
            _checkMarkView.frame = CGRectMake(bounds.size.width-28-4,bounds.size.height-28-4,28,28);
            [_overlayView addSubview:_checkMarkView];
        }
    }
    else if ( _highlighted )
    {
        [_overlayView setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.0f]];
        [_checkMarkView removeFromSuperview];
        _checkMarkView = nil;
        if ( _highlightedLayer == nil )
        {
            _highlightedLayer = [[SWViewSelectionLayer alloc] init];
            [_highlightedLayer addToView:_overlayView];
        }
    }
    else
    {
        [_checkMarkView removeFromSuperview];
        _checkMarkView = nil;
        [_overlayView removeFromSuperview];
        _overlayView = nil;
        [_highlightedLayer remove];
        _highlightedLayer = nil;
    }
    
    CALayer *layer = self.layer;
    if ( _showBorder && !_highlighted )
    {
        //layer.borderColor = [UIColor blackColor].CGColor;
        UIColor *borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
        layer.borderColor = borderColor.CGColor;
        layer.borderWidth = 1;
    }
    else
    {
        layer.borderWidth = 0;
    }
}


- (void)_updatePresentationState
{
    CGRect bounds = self.bounds;
    if ( _selected || _highlighted )
    {
        if ( _overlayView == nil )
        {
            _overlayView = [[UIView alloc] initWithFrame:CGRectMake(0,0,bounds.size.width,bounds.size.height)];
            [self addSubview:_overlayView];
        }
    }
    
    if ( _highlighted )
    {
        if ( _highlightedLayer == nil )
        {
            _highlightedLayer = [[SWViewSelectionLayer alloc] init];
            [_highlightedLayer addToView:_overlayView];
        }
        [_overlayView setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.0f]];
    }
    else
    {
        [_highlightedLayer remove];
        _highlightedLayer = nil;
    }
    
    if ( _selected )
    {
        if ( _checkMarkView == nil )
        {
            _checkMarkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkWhiteShadow.png"]];
            [_checkMarkView setContentMode:UIViewContentModeCenter];
            _checkMarkView.frame = CGRectMake(bounds.size.width-28-4,bounds.size.height-28-4,28,28);
            [_overlayView addSubview:_checkMarkView];
        }
        [_overlayView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
    }
    else
    {
        [_checkMarkView removeFromSuperview];
        _checkMarkView = nil;
    }
    
    if ( !_selected && !_highlighted )
    {
        [_checkMarkView removeFromSuperview];
        _checkMarkView = nil;
        [_overlayView removeFromSuperview];
        _overlayView = nil;
        [_highlightedLayer remove];
        _highlightedLayer = nil;
    }
    
    CALayer *layer = self.layer;
    if ( _showBorder && !_highlighted )
    {
        //layer.borderColor = [UIColor blackColor].CGColor;
        UIColor *borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
        layer.borderColor = borderColor.CGColor;
        layer.borderWidth = 1;
    }
    else
    {
        layer.borderWidth = 0;
    }
}



#pragma mark Private

- (void)_setTouchInside:(BOOL)touchInside
{
    _isTouchInside = touchInside;
    //self.backgroundColor = (touchInside?[UIColor colorWithWhite:0 alpha:0.2]:[UIColor clearColor]);
    //[self setSelected:touchInside];
    [self setHighlighted:touchInside];
}


#pragma mark Touch


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    //self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    //[self setSelected:YES];
    [self setHighlighted:YES];
    _isTouchInside = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGRect bounds = self.bounds;
    BOOL touchInside = CGRectContainsPoint( CGRectInset(bounds, -40, -40), point );
    if ( touchInside != _isTouchInside )
    {
        [self _setTouchInside:touchInside];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if ( _isTouchInside )
    {
        [self _setTouchInside:NO];
        if ([_delegate respondsToSelector:@selector(tapReceivedInImagePickerViewCell:)])
            [_delegate tapReceivedInImagePickerViewCell:self];

    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    if ( _isTouchInside )
    {
        [self _setTouchInside:NO];
    }
}



@end
