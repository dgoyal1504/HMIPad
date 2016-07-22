//
//  SWToolbarViewControllerDelegate.h
//  HmiPad
//
//  Created by Joan Lluch on 05/07/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SWToolbarViewController;

typedef enum
{
    SWLeftOverlayPositionHidden,
    SWLeftOverlayPositionShown,
} SWLeftOverlayPosition;


@protocol SWToolbarViewControllerDelegate <NSObject>

@optional

- (void)toolbarViewController:(SWToolbarViewController*)controller
    willMoveLeftOverlayViewControllerToPosition:(SWLeftOverlayPosition)position animated:(BOOL)animated;

- (void)toolbarViewController:(SWToolbarViewController*)controller
    didMoveLeftOverlayViewControllerToPosition:(SWLeftOverlayPosition)position animated:(BOOL)animated;

- (void)toolbarViewController:(SWToolbarViewController*)controller animateToPosition:(SWLeftOverlayPosition)position;

- (void)toolbarViewControllerDidHandleTapRecognizer:(SWToolbarViewController*)controller;


//- (void)toolbarViewController:(SWToolbarViewController *)controller panGestureMovedToLocation:(CGFloat)location progress:(CGFloat)progress;


@end
