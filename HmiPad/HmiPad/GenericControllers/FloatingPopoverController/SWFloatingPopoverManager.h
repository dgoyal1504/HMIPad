//
//  SWFloatingPopoverManager.h
//  HmiPad
//
//  Created by Joan Martin on 8/6/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SWFloatingPopoverController.h"


@protocol SWFloatingPopoverManagerDataSource<NSObject>

- (UIViewController*)floatingPopoverManager:(SWFloatingPopoverManager*)floatingPopoverManager viewControllerForKey:(id)key;
- (id)floatingPopoverManager:(SWFloatingPopoverManager*)floatingPopoverManager parentKeyForViewControllerWithKey:(id)key;
- (UIView*)floatingPopoverManager:(SWFloatingPopoverManager*)floatingPopoverManager revealViewForKey:(id)key;

@optional
- (CGRect)floatingPopoverManager:(SWFloatingPopoverManager*)floatingPopoverManager centerRectForKey:(id)key;
// ^-- do not implement or return CGRectNull to ignore

@end

@protocol SWFloatingPopoverManagerDelegate<NSObject>

@optional
- (void)floatingPopoverManager:(SWFloatingPopoverManager*)floatingPopoverManager
    willPresentViewController:(UIViewController*)viewController withKey:(id)key;

- (void)floatingPopoverManager:(SWFloatingPopoverManager*)floatingPopoverManager
    closeViewController:(UIViewController*)viewController withKey:(id)key;

- (void)floatingPopoverManager:(SWFloatingPopoverManager*)floatingPopoverManager
    willDismissViewController:(UIViewController*)viewController withKey:(id)key;

- (void)floatingPopoverManager:(SWFloatingPopoverManager*)floatingPopoverManager
    didDismissViewController:(UIViewController*)viewController withKey:(id)key;

@end



@interface SWFloatingPopoverManager : NSObject <SWFloatingPopoverControllerDelegate>

@property (nonatomic, weak) id<SWFloatingPopoverManagerDataSource> dataSource;
@property (nonatomic, weak) id<SWFloatingPopoverManagerDelegate> delegate;
@property (nonatomic, assign) BOOL showsInFullScreen;

- (id)initWithPresentingController:(UIViewController*)presentingController;

- (void)presentFloatingPopoverWithKey:(id)key animationKind:(SWFloatingPopoverAnimationKind)animationKind;
- (void)dismissFloatingPopoverWithKey:(id)key animationKind:(SWFloatingPopoverAnimationKind)animationKind;
- (void)removeFloatingPopoverWithKey:(id)key animationKind:(SWFloatingPopoverAnimationKind)animationKind;
- (void)removeAllPopoversAnimationKind:(SWFloatingPopoverAnimationKind)animationKind;

- (void)hidePresentedPopoversAnimationKind:(SWFloatingPopoverAnimationKind)animationKind;
- (void)presentHiddenPopoversAnimationKind:(SWFloatingPopoverAnimationKind)animationKind;

- (SWFloatingPopoverController*)floatingPopoverControllerWithKey:(id)key;

@end