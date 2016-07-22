//
//  SWFloatingPopover.h
//  FloatingPopover
//
//  Created by Joan Martín Hernàndez on 6/27/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SWFloatingPopoverController;
@class SWFloatingPopoverManager;

@protocol SWFloatingPopoverControllerDelegate <NSObject>

@optional
- (void)floatingPopoverControllerWillPresentPopover:(SWFloatingPopoverController *)floatingPopoverController;
- (void)floatingPopoverControllerWillDismissPopover:(SWFloatingPopoverController *)floatingPopoverController;
- (void)floatingPopoverControllerDidDismissPopover:(SWFloatingPopoverController *)floatingPopoverController;

- (void)floatingPopoverController:(SWFloatingPopoverController *)floatingPopoverController didMoveToPoint:(CGPoint)point;
- (void)floatingPopoverControllerDidMoveToFront:(SWFloatingPopoverController *)floatingPopoverController;
- (void)floatingPopoverControllerCloseButton:(SWFloatingPopoverController *)floatingPopoverController;

- (CGRect)floatingPopoverControllerGetRevealRect:(SWFloatingPopoverController *)floatingPopoverController;
// ^ not called when presenting a new popover, popovers are always presented on top
@end


typedef enum
{
    SWFloatingPopoverAnimationNone,
    SWFloatingPopoverAnimationFade,
    SWFloatingPopoverAnimationScale,
    SWFloatingPopoverAnimationGenie,
} SWFloatingPopoverAnimationKind;



@interface SWFloatingPopoverController : UIViewController <UIGestureRecognizerDelegate>

+ (CGFloat)framePadding;

- (id)initWithContentViewController:(UIViewController*)viewController withKey:(id)key forPresentingInController:(UIViewController*)mainController;

//- (void)presentFloatingPopoverAnimated:(BOOL)animated;
//- (void)presentFloatingPopoverAtPoint:(CGPoint)point animated:(BOOL)animated;
//- (void)dismissFloatingPopoverAnimated:(BOOL)animated;


- (void)dismissFloatingPopoverWithAnimation:(SWFloatingPopoverAnimationKind)animationKind; // toRect:(CGRect)rect;


//- (void)presentFloatingPopoverWithAnimation:(SWFloatingPopoverAnimationKind)animationKind;

- (void)presentChildFloatingPopoverAtPoint:(CGPoint)point withAnimation:(SWFloatingPopoverAnimationKind)animationKind;
- (void)presentFloatingPopoverAtPoint:(CGPoint)point withAnimation:(SWFloatingPopoverAnimationKind)animationKind;
- (void)presentFloatingPopoverAtFixedPoint:(CGPoint)center withAnimation:(SWFloatingPopoverAnimationKind)animationKind;

- (void)bringToFront;

@property (nonatomic, strong) UIColor *frameColor;
@property (nonatomic, readonly, getter = isPresented) BOOL presented;
@property (nonatomic, readonly, getter = isFixed) BOOL fixed;
@property (nonatomic, readonly) UIViewController *contentViewController;
@property (nonatomic, readonly, weak) UIViewController *mainViewController;   //
@property (nonatomic, readonly) id key;  // readonly i passar a la inicialitzacio

@property (nonatomic, assign) BOOL showsCloseButton;
@property (nonatomic, assign) BOOL showsInFullScreen;

@property (nonatomic, weak) id <SWFloatingPopoverControllerDelegate> delegate;

@property (nonatomic, readonly) CGPoint presentationPosition;

- (void)searchBarWillShiftUp;
- (void)searchBarWillShiftDown;

@end


@interface UIViewController(SWFloatingPopover)

- (SWFloatingPopoverController*)floatingPopoverController;

@end
