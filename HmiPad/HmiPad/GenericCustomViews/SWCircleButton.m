//
//  SWCircleButton.m
//  HmiPad
//
//  Created by Joan Lluch on 25/07/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWCircleButton.h"
#import "Drawing.h"


@interface SWCircleButton()
@end


@implementation SWCircleButton
{
    CGRect _initialTouchFrame;
    CGSize _oldSize;
    BOOL _wasInside;
    BOOL _isAnimating;
    UIColor *_storedSetTintColor;
}

const CGFloat PopupDuration = 0.1;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self _swCommonInit];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self _swCommonInit];
    return self;
}


- (void)_swCommonInit
{
    UIImage *backImage = [self _computeBackgroundImage];
//    _circleView = [[UIImageView alloc] initWithImage:backImage];
//    _circleView.frame = self.bounds;
//    _circleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    
//    [self imageView];   // <-- obliguem a crearla ara !! - en cas contrari una imatge afegida posteriorment va al fons
//    [self titleLabel];
//
//    [self insertSubview:_circleView atIndex:0];  // insertem a sota
    
    [self setBackgroundImage:backImage forState:UIControlStateNormal];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
}


- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if ( _isAnimating )
        return;
    
    CGSize currentSize = frame.size;
    if ( !CGSizeEqualToSize( currentSize, _oldSize ) )
    {
        _oldSize = currentSize;
        UIImage *backImage = [self _computeBackgroundImage];
        //[_circleView setImage:backImage];
        [self setBackgroundImage:backImage forState:UIControlStateNormal];

    }
}

- (void)setTintColor:(UIColor *)tintColor
{
    // do not call super yet!
    
    _storedSetTintColor = tintColor;
    [self _updateTintColor];
}


- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    [self _updateTintColor];
}


#pragma mark - Touch


- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    //NSLog( @"begin track");
    [super beginTrackingWithTouch:touch withEvent:event];
    
    _initialTouchFrame = self.frame;
    _wasInside = YES;
    [self _animateToExtendedUsingEaseOut];
    return YES;
}


- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    //NSLog( @"continue track");
    [super continueTrackingWithTouch:touch withEvent:event];

    BOOL touchInside = [self isTouchInside];
    
    if ( touchInside != _wasInside )
    {
        _wasInside = touchInside;
        if ( touchInside ) [self _animateToExtendedUsingEaseOut];
        else [self _animateToNormalUsingEaseOut];
    }
    
    return YES;
}


- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    //NSLog( @"end track");
    [super endTrackingWithTouch:touch withEvent:event];
    
    [self _animateToNormalUsingSpring];
}


- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    //NSLog( @"cancel track");
    [super cancelTrackingWithEvent:event];
    
    [self _animateToNormalUsingEaseOut];
}


#pragma mark - Private


- (void)_updateTintColor
{
    [super setTintColor:(self.enabled?_storedSetTintColor:[UIColor lightGrayColor])];
}

- (void)_setAnimatingFrame:(CGRect)rect
{
    _isAnimating = YES;
    [self setFrame:rect];
    _isAnimating = NO;
}


- (void)_animateToExtendedUsingEaseOut
{
    [UIView animateWithDuration:0.1 delay:0 /*usingSpringWithDamping:1 initialSpringVelocity:0*/ options:UIViewAnimationOptionCurveEaseOut
    animations:^
    {
        CGFloat factor = 4 / _initialTouchFrame.size.height;
        CGRect extFrame = CGRectInset(_initialTouchFrame, -_initialTouchFrame.size.width*factor, -_initialTouchFrame.size.height*factor);
        [self _setAnimatingFrame:extFrame];
    }
    completion:nil];
}


- (void)_animateToNormalUsingEaseOut
{
    [UIView animateWithDuration:PopupDuration delay:0 /*usingSpringWithDamping:1 initialSpringVelocity:0*/ options:UIViewAnimationOptionCurveEaseOut
    animations:^{ [self _setAnimatingFrame:_initialTouchFrame]; } completion:nil];
}


- (void)_animateToNormalUsingSpring
{
    [UIView animateWithDuration:PopupDuration*5 delay:0 usingSpringWithDamping:0.33 initialSpringVelocity:0 options:0
    animations:^{ [self _setAnimatingFrame:_initialTouchFrame]; } completion:nil ];
}


- (UIImage *)_computeBackgroundImage
{
    CGRect bounds = self.bounds;
    CGFloat radius = bounds.size.height/2;
    UIImage *backImage = glossyImageWithSizeAndColor(bounds.size, [UIColor colorWithWhite:0 alpha:0.33].CGColor, YES, NO, radius, 1);
    //backImage = [backImage resizableImageWithCapInsets:UIEdgeInsetsMake(radius, radius, radius, radius)];  // abans de canviar el rendering mode !
    backImage = [backImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return backImage;
}

@end

