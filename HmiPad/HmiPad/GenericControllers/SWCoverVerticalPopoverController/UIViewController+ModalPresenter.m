//
//  UIViewController+ModalPresenter.m
//  HmiPad
//
//  Created by Joan Lluch on 27/01/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "UIViewController+ModalPresenter.h"

@implementation UIViewController (Containment)

//- (void)presentViewControllerModally:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
//{
//    UIView *selfView = self.view;
//    CGRect bounds = selfView.bounds;
//    CGRect initialFrame = bounds;
//    CGRect finalFrame = bounds;
//    CGFloat hOffset = 0;
//    
//    void (^deploymentCompletion)() = [self _transitionFromViewController:nil toViewController:viewControllerToPresent inView:selfView];
//    
//    initialFrame.origin.y += bounds.origin.y + bounds.size.height;
//    initialFrame.size.height -= hOffset;
//
//    finalFrame.origin.y += bounds.origin.y + hOffset;
//    finalFrame.size.height -= hOffset;
//
//    UIView *controllerView = viewControllerToPresent.view;
//    controllerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [controllerView setFrame:initialFrame];
//
//    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
//    animations:^
//    {
//        [controllerView setFrame:finalFrame];
//    }
//    completion:^(BOOL finished)
//    {
//        deploymentCompletion();
//        if (completion )
//            completion();
//    }];
//}


//- (void)dismissViewControllerModallyAnimated:(BOOL)flag completion:(void (^)(void))completion
//{
//
//    UIView *selfView = self.view;
//    CGRect bounds = selfView.bounds;
//    CGRect initialFrame = bounds;
//    CGRect finalFrame = bounds;
//    CGFloat hOffset = 0;
//    
//    UIViewController *presentedController = [self.childViewControllers lastObject];
//    
//    void (^deploymentCompletion)() = [self _transitionFromViewController:presentedController toViewController:nil inView:selfView];
//    
//    initialFrame.origin.y += bounds.origin.y + hOffset;
//    initialFrame.size.height -= hOffset;
//    
//    finalFrame.origin.y += bounds.origin.y + bounds.size.height;
//    finalFrame.size.height -= hOffset;
//
//    [presentedController.view setFrame:initialFrame];
//
//    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
//    animations:^
//    {
//        [presentedController.view setFrame:finalFrame];
//    }
//    completion:^(BOOL finished)
//    {
//        deploymentCompletion();
//        if (completion )
//            completion();
//    }];
//}


//- (UIViewController *)modallyPresentedViewController
//{
//    UIViewController *presentedController = [self.childViewControllers lastObject];
//    return presentedController;
//}


//- (void)dismissModallyPresentedViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
//{
//    UIViewController *parentController = [self parentViewController];
//
//    UIView *parentView = self.view;
//    CGRect bounds = parentView.bounds;
//    CGRect initialFrame = bounds;
//    CGRect finalFrame = bounds;
//    CGFloat hOffset = 0;
//    
//    void (^deploymentCompletion)() = [parentController _transitionFromViewController:self toViewController:nil inView:parentView];
//    
//    initialFrame.origin.y += bounds.origin.y + hOffset;
//    initialFrame.size.height -= hOffset;
//    
//    finalFrame.origin.y += bounds.origin.y + bounds.size.height;
//    finalFrame.size.height -= hOffset;
//
//    [self.view setFrame:initialFrame];
//
//    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
//    animations:^
//    {
//        [self.view setFrame:finalFrame];
//    }
//    completion:^(BOOL finished)
//    {
//        deploymentCompletion();
//        if (completion )
//            completion();
//    }];
//}


//- (void (^)(void))_deploymentForViewController:(UIViewController*)controller inView:(UIView*)view appear:(BOOL)appear disappear:(BOOL)disappear
//{
//    if ( appear ) return [self _deployForViewController:controller inView:view];
//    if ( disappear ) return [self _undeployForViewController:controller];
//    return ^{};
//}


#pragma mark Containment view controller deployment and transition

// Containment Deploy method. Returns a block to be invoked at the
// animation completion, or right after return in case of non-animated deployment.
- (void (^)(void))_deployForViewController:(UIViewController*)controller inView:(UIView*)view
{
    if ( !controller || !view )
        return ^(void){};
    
//    CGRect frame = view.bounds;
    
    UIView *controllerView = controller.view;
//    controllerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    controllerView.frame = frame;
    
    [view addSubview:controllerView];
    
    void (^completionBlock)(void) = ^(void)
    {
        // nothing to do on completion at this stage
    };
    
    return completionBlock;
}

// Containment Undeploy method. Returns a block to be invoked at the
// animation completion, or right after return in case of non-animated deployment.
- (void (^)(void))_undeployForViewController:(UIViewController*)controller
{
    if (!controller)
        return ^(void){};

    // nothing to do before completion at this stage
    
    void (^completionBlock)(void) = ^(void)
    {
        [controller.view removeFromSuperview];
    };
    
    return completionBlock;
}

// Containment Transition method. Returns a block to be invoked at the
// animation completion, or right after return in case of non-animated transition.
- (void(^)(void))_transitionFromViewController:(UIViewController*)fromController toViewController:(UIViewController*)toController inView:(UIView*)view
{
    if ( fromController == toController )
        return ^(void){};
    
    if ( toController ) [self addChildViewController:toController];
    
    void (^deployCompletion)() = [self _deployForViewController:toController inView:view];
    
    [fromController willMoveToParentViewController:nil];
    
    void (^undeployCompletion)() = [self _undeployForViewController:fromController];
    
    void (^completionBlock)(void) = ^(void)
    {
        undeployCompletion() ;
        [fromController removeFromParentViewController];
        
        deployCompletion() ;
        [toController didMoveToParentViewController:self];
    };
    return completionBlock;
}






@end
