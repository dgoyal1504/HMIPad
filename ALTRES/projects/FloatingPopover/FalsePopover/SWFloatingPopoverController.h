//
//  SWFloatingPopover.h
//  FloatingPopover
//
//  Created by Joan Martín Hernàndez on 6/27/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SWFloatingPopoverController;

@protocol SWFloatingPopoverControllerDelegate <NSObject>

- (void)floatingPopoverControllerDidDismissPopover:(SWFloatingPopoverController *)floatingPopoverController;

@end

@interface SWFloatingPopoverController : UIViewController 

- (id)initWithContentViewController:(UIViewController*)viewController;

- (void)presentFloatingPopoverAtPoint:(CGPoint)point inView:(UIView *)view animated:(BOOL)animated;
- (void)dismissFloatingPopoverAnimated:(BOOL)animated;

@property (nonatomic, strong) UIColor *frameColor;
@property (nonatomic, readonly, getter = isPresented) BOOL presented;
@property (nonatomic, strong) UIViewController *contentViewController;

@property (nonatomic, weak) id <SWFloatingPopoverControllerDelegate> delegate;

@end
