//
//  SWSegmentController.h
//  SegmentConroller
//
//  Created by Joan Martín Hernàndez on 7/23/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWSegmentControllerDelegate.h"

@interface SWSegmentController : UINavigationController

- (id)initWithTabbedViewControllers:(NSArray*)viewControllers;

@property (nonatomic, weak) IBOutlet id <SWSegmentControllerDelegate> delegate;

@property (nonatomic, copy) NSArray *tabbedViewControllers;
@property(nonatomic, weak) UIViewController *selectedViewController;
@property(nonatomic, readwrite) NSUInteger selectedIndex;
@property(nonatomic,assign) BOOL showsCloseButtonWhenFloating;

- (void)setTabbedViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;

@end
