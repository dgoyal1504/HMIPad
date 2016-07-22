//
//  SWLayoutOverlayCoordinatorView.h
//  HmiPad
//
//  Created by Joan Lluch on 12/01/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWLayoutTypes.h"
#import "SWZoomableViewController.h"

@class SWLayoutOverlayView;
@class SWLayoutView;

@interface SWLayoutOverlayCoordinatorView : UIView

// Editing
@property (nonatomic) BOOL editMode;

// Autoalignment
@property (nonatomic, assign) BOOL showAlignmentRulers;
@property (nonatomic, assign) BOOL autoAlignCells;
@property (nonatomic, assign) CGFloat autoAlignmentProximity;

// Selection
@property (nonatomic, assign) BOOL allowsMultipleSelection;
@property (nonatomic, assign) BOOL allowFrameEditing;
@property (nonatomic, assign) BOOL selectionHidden;

// Zoomable
@property (nonatomic, assign) CGFloat zoomScaleFactor;

// Adding, removing layout layers
- (void)addLayoutViewLayer:(SWLayoutView*)layoutView;
- (void)removeLayoutViewLayer:(SWLayoutView*)layoutView;

// Fine resizing
- (void)moveToDirection:(SWLayoutResizerViewDirection)direction;
- (void)resizeToDirection:(SWLayoutResizerViewDirection)direction;

@end
