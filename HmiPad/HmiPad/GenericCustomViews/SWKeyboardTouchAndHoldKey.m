//
//  SWKeyboardTouchAndHoldKey.m
//  HmiPad
//
//  Created by Hermes Pique on 5/11/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWKeyboardTouchAndHoldKey.h"

@implementation SWKeyboardTouchAndHoldKey {
    SEL _touchAndHoldSelector;
    id _touchAndHoldTarget;
    NSTimer *_touchAndHoldTimer;
}

- (void)dealloc
{
    [self cancelHold];
}

#pragma mark - Public

- (void)addTouchAndHoldTarget:(id)target action:(SEL)action
{
    _touchAndHoldTarget = target;
    [self addTarget:self action:@selector(sourceTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(sourceTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
    [self addTarget:self action:@selector(sourceTouchDown:) forControlEvents:UIControlEventTouchDown];
    _touchAndHoldSelector = action;
}

- (void)cancelHold
{
    [NSThread cancelPreviousPerformRequestsWithTarget:self selector:@selector(secondTouchAndHoldAction) object:nil];
    [_touchAndHoldTimer invalidate];
    _touchAndHoldTimer = nil;
}

#pragma mark - Private

- (void) sourceTouchUp:(UIButton*) sender
{
    [self cancelHold];
}

- (void) sourceTouchDown:(UIButton*) sender
{
    // Set delay first in case _touchAndHoldSelector cancels the hold 
    [self performSelector:@selector(secondTouchAndHoldAction) withObject:nil afterDelay:0.5];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_touchAndHoldTarget performSelector:_touchAndHoldSelector withObject:nil];
#pragma clang diagnostic pop
}

- (void)secondTouchAndHoldAction
{
    // Set timer first in case _touchAndHoldSelector cancels the hold
    _touchAndHoldTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:_touchAndHoldTarget selector:_touchAndHoldSelector userInfo:nil repeats:YES];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_touchAndHoldTarget performSelector:_touchAndHoldSelector withObject:nil];
#pragma clang diagnostic pop
}

@end
