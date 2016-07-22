//
//  SWMasterDetailViewControllerDelegate.h
//  HmiPad
//
//  Created by Joan Martin on 7/26/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SWMasterDetailViewController;

typedef enum
{
    SWRightViewPositionHidden,
    SWRightViewPositionShown,
} SWRightViewPosition;

typedef enum
{
    SWLeftViewPositionHidden,
    SWLeftViewPositionShown,
} SWLeftViewPosition;

@protocol SWMasterDetailViewControllerDelegate <NSObject>

@optional

// Right
//- (void)masterDetailViewController:(SWMasterDetailViewController*)controller willPresentDetailViewControllerAnimated:(BOOL)animated;
//- (void)masterDetailViewController:(SWMasterDetailViewController*)controller didPresentDetailViewControllerAnimated:(BOOL)animated;
//- (void)masterDetailViewController:(SWMasterDetailViewController*)controller willDismissDetailViewControllerAnimated:(BOOL)animated;
//- (void)masterDetailViewController:(SWMasterDetailViewController*)controller didDismissDetailViewControllerAnimated:(BOOL)animated;


- (void)masterDetailViewController:(SWMasterDetailViewController*)controller
    willMoveDetailViewControllerToPosition:(SWRightViewPosition)position animated:(BOOL)animated;

- (void)masterDetailViewController:(SWMasterDetailViewController*)controller
    didMoveDetailViewControllerToPosition:(SWRightViewPosition)position animated:(BOOL)animated;


// Left
- (void)masterDetailViewController:(SWMasterDetailViewController*)controller willPresentLeftDetailViewControllerAnimated:(BOOL)animated;
- (void)masterDetailViewController:(SWMasterDetailViewController*)controller didPresentLeftDetailViewControllerAnimated:(BOOL)animated;
- (void)masterDetailViewController:(SWMasterDetailViewController*)controller willDismissLeftDetailViewControllerAnimated:(BOOL)animated;
- (void)masterDetailViewController:(SWMasterDetailViewController*)controller didDismissLeftDetailViewControllerAnimated:(BOOL)animated;

@end
