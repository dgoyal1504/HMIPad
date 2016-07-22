//
//  SWScrollView.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/2/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWScrollView.h"

@interface SWScrollView ()

- (void)_performAnimation;

@end

@implementation SWScrollView

@synthesize animatingScrolling = _animatingScrolling;
@synthesize scrollAnimationDirection = _scrollAnimationDirection;
@synthesize scrollAnimationVelocityFactor = _scrollAnimationVelocityFactor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _animatingScrolling = NO;
        _scrollAnimationDirection = CGPointZero;
        _scrollAnimationVelocityFactor = 1.0;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _animatingScrolling = NO;
    _scrollAnimationDirection = CGPointZero;
    _scrollAnimationVelocityFactor = 1.0;
}

#pragma mark - Properties

- (void)setScrollAnimationDirection:(CGPoint)scrollAnimationDirection
{
    _scrollAnimationDirection = scrollAnimationDirection;
    
    CGFloat norm = sqrtf(_scrollAnimationDirection.x*_scrollAnimationDirection.x + _scrollAnimationDirection.y*_scrollAnimationDirection.y);
    
    if (norm > TOL) {
        _normalizedScrollAnimationDirection = CGPointMake(_scrollAnimationDirection.x/norm, _scrollAnimationDirection.y/norm);
    }
}

#pragma mark - Main Methods

- (void)startScrollingAnimation
{
    NSLog(@"STARTING ANIMATION");
    
//    @synchronized(self) {
        if (_animatingScrolling == YES) {
            return;
        }
        _animatingScrolling = YES;
//    }
    
    [self _performAnimation];
}

- (void)stopScrollingAnimation
{
    if (_animatingScrolling == NO)
        return;
    
    NSLog(@"STOPING ANIMATION");
    _shouldStopAnimation = YES;
}

#pragma mark - Private Methods

- (void)_performAnimation
{
    CGFloat animationDuration = 0.1;
    UIViewAnimationOptions options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear;
    
    CGFloat baseFactor = 4.0;
    CGPoint newOffset = CGPointMake(self.contentOffset.x + baseFactor*_scrollAnimationVelocityFactor*_normalizedScrollAnimationDirection.x, 
                                    self.contentOffset.y + baseFactor*_scrollAnimationVelocityFactor*_normalizedScrollAnimationDirection.y);
    
    [UIView animateWithDuration:animationDuration 
                          delay:0 
                        options:options 
                     animations:^{
                         
                         self.contentOffset = newOffset;
                         
                     } completion:^(BOOL finished) {
                         if (_shouldStopAnimation == NO) {
                             [self _performAnimation];
                         } else {
                            _animatingScrolling = NO;
                             _shouldStopAnimation = NO;
                         }
                     }];
}

@end
