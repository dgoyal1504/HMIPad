//
//  SWCoverVerticalPopoverController.h
//  HmiPad
//
//  Created by Joan Lluch on 27/01/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWCoverVerticalPopoverController : NSObject

- (id)initWithContentViewController:(UIViewController *)viewController forPresentingInController:(UIViewController*)parentViewController;
@property (nonatomic, readonly) UIViewController *contentViewController;
@property (nonatomic, assign) CGFloat displacementOffset;

- (void)presentCoverVerticalPopoverAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismissCoverVerticalPopoverAnimated:(BOOL)animated completion:(void (^)(void))completion;

@end
