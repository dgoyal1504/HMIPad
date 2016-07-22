//
//  SWLayoutController.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/2/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

/******************************************************************/
/******************************************************************/
/**                                                              **/
/** WARNING: THIS CLASS IS ABOUT TO BE DEPRECATED. DO NOT USE IT **/
/**                                                              **/
/******************************************************************/
/******************************************************************/

#import <UIKit/UIKit.h>

extern NSString * const SWLayoutedControllerIncompatibilityException;

@class SWLayoutController;

#import "SWLayoutControllerTypes.h"
#import "SWLayoutControllerDataSource.h"
#import "SWLayoutControllerDelegate.h"

#pragma mark - Class Definition

#import "SWLayoutView.h"

/**
 * A SWLayoutController is a container view controller. Exposes other view controllers as single views floating in a main view and user can interact with them.
 */
@interface SWLayoutController : UIViewController {
    SWLayoutView *_layoutView;
    NSMutableDictionary *_indexMapping;
}

- (void)insertViewControllerAtIndexes:(NSIndexSet*)indexes withAnimation:(SWLayoutItemAnimation)animation;
- (void)deleteViewControllerAtIndexes:(NSIndexSet*)indexes withAnimation:(SWLayoutItemAnimation)animation;

- (void)reloadData;

@property (assign, nonatomic, getter = isEditing) BOOL editing;

@property (weak, nonatomic) IBOutlet id<SWLayoutControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet id<SWLayoutControllerDataSource> dataSource;

@property (readonly) SWLayoutView *layoutView;

@end

@interface SWLayoutController (layoutViewDataSource) <SWLayoutViewDataSource>
@end

@interface SWLayoutController (layoutViewDelegate) <SWLayoutViewDelegate>
@end
