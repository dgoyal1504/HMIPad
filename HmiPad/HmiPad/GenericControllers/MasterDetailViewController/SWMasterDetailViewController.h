//
//  SWMasterDetailViewController.h
//  HmiPad
//
//  Created by Joan Martin on 7/26/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWMasterDetailViewControllerDelegate.h"
#import "SWZoomableViewController.h"


//typedef enum {
//    SWDetailViewControllerPresentationStyleLeft,
//    SWDetailViewControllerPresentationStyleRight
//} SWDetailViewControllerPresentationStyle;


typedef enum {
    SWMasterViewControllerPresentationBaseAnimationNone,
    SWMasterViewControllerPresentationBaseAnimationFade,
    SWMasterViewControllerPresentationBaseAnimationCurl,
    SWMasterViewControllerPresentationBaseAnimationVerticalShift,
    SWMasterViewControllerPresentationBaseAnimationHorizontalShift,
    SWMasterViewControllerPresentationBaseAnimationHorizontalFlip,
} SWMasterViewControllerPresentationBaseAnimation;


typedef enum {
    SWMasterViewControllerPresentationAnimationNone,
    
    // transitionFromView based animations
    SWMasterViewControllerPresentationAnimationFade,
    SWMasterViewControllerPresentationAnimationCurlUp,
    SWMasterViewControllerPresentationAnimationCurlDown,
    SWMasterViewControllerPresentationAnimationFlipFromLeft,
    SWMasterViewControllerPresentationAnimationFlipFromRight,
    
    // animateWithDuration based animations
    SWMasterViewControllerPresentationAnimationLeft,
    SWMasterViewControllerPresentationAnimationRight,
    SWMasterViewControllerPresentationAnimationUp,
    SWMasterViewControllerPresentationAnimationDown
} SWMasterViewControllerPresentationAnimation;





@interface SWMasterDetailViewController : UIViewController 

//- (id)initWithViewControllers:(NSArray*)array;

@property (nonatomic, readonly) UIViewController<SWZoomableViewController> *masterViewController;
- (void)setMasterViewController:(UIViewController<SWZoomableViewController> *)masterViewController animated:(BOOL)animated;
@property (nonatomic, strong) UIViewController *rightDetailViewController;
@property (nonatomic, strong) UIViewController *leftDetailViewController;
@property (nonatomic, strong) UIView *controllerOverlayView;

@property (nonatomic, assign) CGFloat rightDetailWidth;
@property (nonatomic, assign) CGFloat leftDetailWidth;

@property (nonatomic, assign) BOOL scalingEnabled;
//- (void)setScalingEnabled:(BOOL)enable animated:(BOOL)animated;
- (void)setMasterSize:(CGSize)size animated:(BOOL)animated;

//@property (nonatomic, readonly, getter = isLeftDetailViewControllerVisible) BOOL leftDetailViewControllerVisible;
//@property (nonatomic, readonly, getter = isRightDetailViewControllerVisible) BOOL rightDetailViewControllerVisible;

//@property (nonatomic, strong) UIViewController* (^getDetailViewController)(SWDetailViewControllerPresentationStyle style);

@property (nonatomic, weak) id<SWMasterDetailViewControllerDelegate> delegate;

- (void)replaceMasterViewControllerByController:(UIViewController<SWZoomableViewController>*)controller withAnimation:(SWMasterViewControllerPresentationAnimation)animation;

//- (void)presentRightDetailViewController:(UIViewController*)controller animated:(BOOL)animated;
//- (void)presentRightDetailViewControllerAnimated:(BOOL)animated;
//- (void)dismissRightDetailViewControllerAnimated:(BOOL)animated;
- (void)toggleRightDetailViewControllerAnimated:(BOOL)animated;
- (void)toggleLeftDetailViewControllerAnimated:(BOOL)animated;

//- (void)presentLeftDetailViewController:(UIViewController*)controller animated:(BOOL)animated;
////- (void)presentLeftDetailViewControllerAnimated:(BOOL)animated;
//- (void)dismissLeftDetailViewControllerAnimated:(BOOL)animated;


@property (nonatomic, readonly) BOOL pagingMode;
@property (nonatomic, readonly) SWRightViewPosition rightViewPosition;
@property (nonatomic, readonly) SWLeftViewPosition leftViewPosition;


//- (UIPanGestureRecognizer*)panGestureRecognizer;

@end


#pragma mark - UIViewController(SWMasterDetailViewController) Category

// We add a category of UIViewController to let childViewControllers easily access their parent SWRevealViewController
@interface UIViewController(SWMasterDetailViewController)

- (SWMasterDetailViewController*)masterDetailViewController;

@end
