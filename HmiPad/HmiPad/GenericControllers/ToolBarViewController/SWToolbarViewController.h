//
//  SWToolbarViewController.h
//  HmiPad
//
//  Created by Joan on 06/10/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWToolbarViewControllerDelegate.h"

@interface SWToolbarViewController : UIViewController

@property (nonatomic,strong) UIToolbar *toolbar;
//@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,readonly) UIViewController *contentViewController;
@property (nonatomic,readonly) UIViewController *overlayViewController;
@property (nonatomic,readonly) SWLeftOverlayPosition leftOverlayPosition;
@property (nonatomic) CGFloat leftOverlayWidth;
@property (nonatomic) CGFloat leftOverlayExtensionWidth;
@property (nonatomic) CGFloat clipExtensionPercent;
@property (nonatomic,weak) id<SWToolbarViewControllerDelegate> delegate;

//- (id)initWithContentViewController:(UIViewController*)viewController;
- (void)setContentViewController:(UIViewController*)viewController animated:(BOOL)animated;
- (void)setOverlayViewController:(UIViewController*)viewController animated:(BOOL)animated;
- (void)setLeftOverlayPosition:(SWLeftOverlayPosition)position animated:(BOOL)animated;
- (void)leftOverlayPositionToggleAnimated:(BOOL)animated;
- (void)leftOverlayPositionToggle;
- (UIPanGestureRecognizer*)panGestureRecognizer;

@end



@interface UIViewController(SWToolbarContainment)

- (SWToolbarViewController*)toolbarViewController;
@property (nonatomic,strong) NSArray *toolbarControllerItems;
- (void)setToolbarControllerItems:(NSArray *)toolbarItems animated:(BOOL)animated;

@end