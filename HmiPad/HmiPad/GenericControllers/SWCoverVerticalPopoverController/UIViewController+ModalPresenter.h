//
//  UIViewController+ModalPresenter.h
//  HmiPad
//
//  Created by Joan Lluch on 27/01/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Containment)

//- (void)presentViewControllerModally:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion;
//
////- (void)dismissViewControllerModallyAnimated:(BOOL)flag completion:(void (^)(void))completion;
//
//- (void)dismissModallyPresentedViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;
//
//@property (nonatomic, readonly) UIViewController *modallyPresentedViewController;

- (void (^)(void))_deployForViewController:(UIViewController*)controller inView:(UIView*)view;
- (void (^)(void))_undeployForViewController:(UIViewController*)controller;
- (void(^)(void))_transitionFromViewController:(UIViewController*)fromController toViewController:(UIViewController*)toController inView:(UIView*)view;

@end
