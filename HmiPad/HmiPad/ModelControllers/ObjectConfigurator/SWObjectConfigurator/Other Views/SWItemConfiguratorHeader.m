//
//  SWItemConfiguratorHeader.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 5/21/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWItemConfiguratorHeader.h"


@interface SWItemConfiguratorHeader ()
{
    BOOL _isTouchInside;
}
//- (void)doInit;

@end

@implementation SWItemConfiguratorHeader

@synthesize imageButton;
@synthesize target = _target;
@synthesize action = _action;

- (void)_doItemCongigurationHeaderInit
{
    //UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognized:)];
    //[self addGestureRecognizer:tapGesture];
}

- (void)gestureRecognized:(UITapGestureRecognizer*)recognizer
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_target performSelector:_action withObject:self];
#pragma clang diagnostic pop
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _doItemCongigurationHeaderInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _doItemCongigurationHeaderInit];
    }
    return self;
}

#pragma mark Overriden Methods


#pragma mark Public Methods

- (void)expand:(BOOL)flag animated:(BOOL)animated
{
    CGAffineTransform transform;
    
//    if (!flag)
//        transform = CGAffineTransformMakeRotation(-M_PI_2);
//    else 
//        transform = CGAffineTransformIdentity;
        
    if (flag)
        transform = CGAffineTransformMakeRotation(M_PI_2);
    else 
        transform = CGAffineTransformIdentity;
    
    void (^animation)(void) = ^{
        imageButton.transform = transform;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.25 animations:animation];
    } else {
        animation();
    }
}

- (void)setTarget:(id)target andAction:(SEL)action
{
    _target = target;
    _action = action;
}


#pragma mark Touch


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
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
        _isTouchInside = touchInside;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if ( _isTouchInside )
    {
        _isTouchInside = NO;
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [_target performSelector:_action withObject:self];
        #pragma clang diagnostic pop
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    if ( _isTouchInside )
    {
        _isTouchInside = NO;
    }
}

@end
