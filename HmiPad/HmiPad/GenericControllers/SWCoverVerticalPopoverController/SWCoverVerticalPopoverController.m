//
//  SWCoverVerticalPopoverController.m
//  HmiPad
//
//  Created by Joan Lluch on 27/01/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWCoverVerticalPopoverController.h"
#import "UIViewController+ModalPresenter.h"

@interface SWCoverVerticalPopoverController()
{
    __weak UIViewController *_swParentViewController;
    UIViewController *_swContentViewController;
}
@end


@implementation SWCoverVerticalPopoverController

- (id)initWithContentViewController:(UIViewController *)viewController forPresentingInController:(UIViewController*)parentViewController
{
    self = [super init];
    if ( self )
    {
        _swContentViewController = viewController;
        _swParentViewController = parentViewController;
    }
    return self;
}


- (UIViewController*)contentViewController
{
    return _swContentViewController;
}


typedef enum
{
    SWCoverVerticalPopoverPositionUp,
    SWCoverVerticalPopoverPositionDown,
} SWCoverVerticalPopoverPosition;


- (void)presentCoverVerticalPopoverAnimated:(BOOL)animated completion:(void (^)(void))completion
{
    [self _transitionCoverVerticalPopoverToPosition:SWCoverVerticalPopoverPositionUp animated:animated completion:completion];
}


- (void)dismissCoverVerticalPopoverAnimated:(BOOL)animated completion:(void (^)(void))completion
{
    [self _transitionCoverVerticalPopoverToPosition:SWCoverVerticalPopoverPositionDown animated:animated completion:completion];
}


- (void)_transitionCoverVerticalPopoverToPosition:(SWCoverVerticalPopoverPosition)position animated:(BOOL)animated completion:(void (^)(void))completion
{
    UIView *parentView = _swParentViewController.view;
    CGRect bounds = parentView.bounds;
    CGRect frameUp = bounds;
    CGRect frameDown = bounds;
    CGFloat hOffset = _displacementOffset;
    
    frameDown.origin.y += bounds.origin.y + bounds.size.height;
    frameDown.size.height -= hOffset;

    frameUp.origin.y += bounds.origin.y + hOffset;
    frameUp.size.height -= hOffset;
    
    CGRect initialFrame, finalFrame;
    UIViewController *initialController, *finalController;
    switch ( position )
    {
        case SWCoverVerticalPopoverPositionUp:
            initialFrame = frameDown;
            finalFrame = frameUp;
            initialController = nil;
            finalController = _swContentViewController;
            break;
            
        default:
        case SWCoverVerticalPopoverPositionDown:
            initialFrame = frameUp;
            finalFrame = frameDown;
            initialController = _swContentViewController;
            finalController = nil;
            break;
    }
    
    UIView *contentViewControllerView = _swContentViewController.view;
    contentViewControllerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    void (^deploymentCompletion)() = [_swParentViewController _transitionFromViewController:initialController toViewController:finalController inView:parentView];

    [contentViewControllerView setFrame:initialFrame];
    
    NSTimeInterval duration = animated?0.3:0.0;

    //[UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseOut
    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:1 initialSpringVelocity:0 options:0
    animations:^
    {
        [contentViewControllerView setFrame:finalFrame];
    }
    completion:^(BOOL finished)
    {
        deploymentCompletion();
        if (completion )
            completion();
    }];
}

@end
