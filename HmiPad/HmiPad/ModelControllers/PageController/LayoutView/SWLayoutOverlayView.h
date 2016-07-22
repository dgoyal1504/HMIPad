//
//  SWRulerView.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/26/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWLayoutTypes.h"
#import "SWZoomableViewController.h"

@class SWLayoutViewCell;
@class SWLayoutOverlayView;


@protocol SWLayoutOverlayViewDataSource <NSObject>

@required
- (NSData*)layoutOverlayView:(SWLayoutOverlayView*)view
              rulersForCell:(SWLayoutViewCell*)cell
              movingToFrame:(CGRect)frame
             correctedFrame:(CGRect*)correctedFrame
                  eventType:(SWLayoutViewCellEventType)eventType;

- (SWLayoutViewCell*)layoutOverlayView:(SWLayoutOverlayView*)view cellAtPoint:(CGPoint)point;
- (SWLayoutViewCell*)layoutOverlayView:(SWLayoutOverlayView*)view opaqueCellAtPoint:(CGPoint)point;
- (NSInteger)layoutOverlayView:(SWLayoutOverlayView*)view indexOfCell:(SWLayoutViewCell*)cell;

@end


@protocol SWLayoutOverlayViewDelegate <NSObject>

- (void)layoutOverlayView:(SWLayoutOverlayView*)view cell:(SWLayoutViewCell*)cell didMoveToFrame:(CGRect)frame eventType:(SWLayoutViewCellEventType)eventType;
- (void)layoutOverlayView:(SWLayoutOverlayView*)view commitEditionForEventType:(SWLayoutViewCellEventType)eventType;

- (void)layoutOverlayView:(SWLayoutOverlayView*)view didPerformTapAtPoint:(CGPoint)point;
- (void)layoutOverlayView:(SWLayoutOverlayView*)view didPerformLongPresureAtPoint:(CGPoint)point;

- (void)layoutOverlayView:(SWLayoutOverlayView*)view didPerformDoubleTapAtPoint:(CGPoint)point;

- (BOOL)layoutOverlayView:(SWLayoutOverlayView*)view shouldSelectCell:(SWLayoutViewCell*)cell;
- (void)layoutOverlayView:(SWLayoutOverlayView*)view didSelectCell:(SWLayoutViewCell*)cell;
- (void)layoutOverlayView:(SWLayoutOverlayView*)view didDeselectCell:(SWLayoutViewCell*)cell;
- (void)layoutOverlayViewDidDeselectAll:(SWLayoutOverlayView*)view;

- (void)layoutOverlayView:(SWLayoutOverlayView*)view selectionDidChange:(NSSet*)cells;  // Not used !

@end


@class SWLayoutView;

@interface SWLayoutOverlayView : UIView //<SWLayoutOverlayViewCellDelegate>

// Rulers
@property (nonatomic, strong) UIColor *rulersTintColor;
@property (nonatomic, strong) UIColor *phoneIdiomRulerColor;

// Reloading / updating
- (void)reloadOverlayFrames;
- (void)reloadOverlayFrameForCell:(SWLayoutViewCell*)cell;
- (void)updateEnabledEstateForCell:(SWLayoutViewCell *)cell;
- (void)updateLockStateForCells:(NSArray*)cells animated:(BOOL)animated;

// Selection and Locking
- (void)markCells:(NSArray*)cells animated:(BOOL)animated;
- (void)unmarkCells:(NSArray*)cells animated:(BOOL)animated;
- (void)unmarkAllAnimated:(BOOL)animated;

// Fine positioning and resizing
- (void)moveToDirection:(SWLayoutResizerViewDirection)direction;
- (void)resizeToDirection:(SWLayoutResizerViewDirection)direction;

// Delegate and dataSource
@property (nonatomic, weak) id <SWLayoutOverlayViewDelegate> delegate;
@property (nonatomic, weak) id <SWLayoutOverlayViewDataSource> dataSource;

// Properties
@property (nonatomic, assign) BOOL editMode;
@property (assign, nonatomic) BOOL allowFrameEditing;
@property (assign, nonatomic) BOOL allowsMultipleSelection;
@property (assign, nonatomic) BOOL showAlignmentRulers;
@property (assign, nonatomic) BOOL autoAlignCells;
@property (assign, nonatomic) BOOL isBottomPosition;
//@property (assign, nonatomic) CGFloat phoneIdiomRulerPosition;
@property (assign, nonatomic) CGSize phoneIdiomRulerSize;

// Zoomable
@property (nonatomic, assign) CGFloat zoomScaleFactor;

@end
