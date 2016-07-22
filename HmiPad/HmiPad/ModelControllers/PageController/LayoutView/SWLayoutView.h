//
//  SWLayoutView.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/26/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWLayoutOverlayView.h"
#import "SWZoomableViewController.h"

typedef enum {
    SWLayoutViewViewAnimationNone,
    SWLayoutViewViewAnimationAppear,
    SWLayoutViewViewAnimationHorizontalFlip,
    SWLayoutViewViewAnimationVerticalFlip
} SWLayoutViewViewAnimation;



@class SWLayoutView;
@class SWLayoutViewCell;
@class SWLayoutOverlayView;
@class SWLayoutResizerView;
@class SWLayoutOverlayCoordinatorView;

// Ruler cell

//@protocol SWLayoutViewRulerCell <NSObject>
//
//@required
//
//@property (nonatomic) BOOL selected;
//
//@end


// Datasource

@protocol SWLayoutViewDataSource <NSObject>

@required

- (NSInteger)numberOfCellsForlayoutView:(SWLayoutView*)layoutView;
- (SWLayoutViewCell*)layoutView:(SWLayoutView*)layoutView layoutViewCellAtIndex:(NSInteger)index;
- (CGRect)layoutView:(SWLayoutView*)layoutView frameForCellAtIndex:(NSInteger)index;

@optional

- (CGSize)layoutView:(SWLayoutView*)layoutView minimumSizeForCellAtIndex:(NSInteger)index;
- (CGSize)layoutView:(SWLayoutView*)layoutView currentMinimumSizeForCellAtIndex:(NSInteger)index;
- (BOOL)layoutView:(SWLayoutView*)layoutView canEditViewAtIndex:(NSInteger)index;

- (SWLayoutViewCellResizingStyle)layoutView:(SWLayoutView*)layoutView resizingStyleForCellAtIndex:(NSInteger)index;
- (void)layoutView:(SWLayoutView *)layoutView commitEditionForCellsAtIndexes:(NSIndexSet*)indexes;

@end


// Delegate

@protocol SWLayoutViewDelegate <NSObject>

@optional

- (BOOL)layoutView:(SWLayoutView *)layoutView shouldSelectCellAtIndex:(NSInteger)index;

//- (NSInteger)layoutView:(SWLayoutView *)layoutView willSelectCellAtIndex:(NSInteger)index;
- (void)layoutView:(SWLayoutView *)layoutView didSelectCellsAtIndexes:(NSIndexSet*)indexSet;

//- (void)layoutView:(SWLayoutView *)layoutView willDeselectCellsAtIndexes:(NSIndexSet*)indexSet;
- (void)layoutView:(SWLayoutView *)layoutView didDeselectCellsAtIndexes:(NSIndexSet*)indexSet;

- (void)layoutView:(SWLayoutView *)layoutView didPerformTapInRect:(CGRect)rect;
- (void)layoutView:(SWLayoutView *)layoutView didPerformLongPresureInRect:(CGRect)rect;
//- (void)layoutView:(SWLayoutView *)layoutView didChangeResizerPosition:(CGPoint)position;

@end


// Class Interface

@interface SWLayoutView : UIView<SWLayoutOverlayViewDataSource,SWLayoutOverlayViewDelegate,SWZoomableViewController>

- (id)initWithFrame:(CGRect)frame;

// Overlay coordinator and overlay view
@property (nonatomic) SWLayoutOverlayCoordinatorView *layoutOverlayCoordinatorView;
@property (nonatomic) SWLayoutOverlayView *layoutOverlayView;  // view used by the coordinator to manage layout at this level

// Getters
- (SWLayoutViewCell*)cellAtIndex:(NSInteger)index;

// Reloading
- (void)reloadDataAnimated:(BOOL)animated;
- (void)reloadFrameForCell:(SWLayoutViewCell*)cell animated:(BOOL)animated;
- (void)reloadCellFramesAnimated:(BOOL)animated;
- (void)reloadOverlayFrames;

// Insertion & Deletion
- (void)insertCellsAtIndexes:(NSIndexSet*)indexes withAnimation:(SWLayoutViewViewAnimation)animation
    willAppear:(void (^)())willAppear didAppear:(void (^)())didAppear;
- (void)deleteCellsAtIndexes:(NSIndexSet*)indexes withAnimation:(SWLayoutViewViewAnimation)animation
    willDisappear:(void (^)())willDisappear didDisappear:(void (^)())didDisappear;

// Selection
- (void)selectCellsAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;
- (void)deselectCellsAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;
- (void)setEnabledStateTo:(BOOL)state forCellAtIndex:(NSInteger)index;

// Lock
- (void)lockCellsAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;
- (void)unlockCellsAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;

// Programatic selection (simulates touch, thus it will call delegates)
- (void)performSelectionAtPoint:(CGPoint)point;

// View hierarcy
- (void)sendToBackCellAtIndex:(NSInteger)index;
- (void)bringToFrontCellAtIndex:(NSInteger)index;
- (void)sendCellAtIndex:(NSInteger)index toZPosition:(NSInteger)position;
- (void)exchangeCellAtIndex:(NSInteger)index1 withCellAtIndex:(NSInteger)index2;

// Editing properties
@property (nonatomic) BOOL editMode;
@property (nonatomic) BOOL showsErrorFramesInEditMode;
@property (nonatomic) BOOL showsHiddenItemsInEditMode;

// Bottom Layout
@property (nonatomic) BOOL isBottomPosition;
//@property (assign, nonatomic) CGFloat phoneIdiomRulerPosition;  // Zero indica que no el volem
@property (nonatomic) CGSize phoneIdiomRulerSize;  // Zero indica que no el volem
@property (nonatomic) BOOL constrainToRulerPosition;    // Contraure el background view

// Autoalignment
@property (nonatomic) CGFloat autoAlignmentProximity;

// Zoom
@property (nonatomic) CGFloat zoomScaleFactor;

// Delegate & DataSource
@property (weak, nonatomic) id <SWLayoutViewDelegate> delegate;
@property (weak, nonatomic) id <SWLayoutViewDataSource> dataSource;

@end

