//
//  SWFlowView.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/8/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "SWFlowViewDelegate.h"
#import "SWFlowViewDataSource.h"

typedef enum {
    SWFlowViewAnimationNone
} SWFlowViewAnimation;

typedef enum {
    SWFlowViewModeViewSleep,
    SWFlowViewModeViewPresentation,
    SWFlowViewModeViewFlow
} SWFlowViewMode;


@interface SWFlowView : UIView {
    
    // Managing the view
    CAGradientLayer *_gradient;
    UIScrollView *_scrollView;
    CGSize _flowItemsSize;
    CGAffineTransform _smallifyTransform;
    CGFloat _flowItemsYPosition;
    UIPageControl *_pageControl;
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    
    CGFloat _flowItemsSeparation;
    
    // Managing the displayed Items
    NSInteger _numberOfItems;
    NSMutableDictionary *_activeItems;
    NSMutableArray *_reusableItems;
    
    // Managing the flow state
    NSInteger _selectedViewIndex;
    
    // Managing user events
    BOOL _moved;
    NSInteger _firstSelectedItem;
    CGFloat _firstOffset;
    NSTimeInterval _firstTime;
    BOOL _firstTouchInDeleteButton;
    
}

- (void)sleep;
- (void)awakeAtIndex:(NSInteger)index inFullScreen:(BOOL)fullScreen;

// -- Managing Flow View State -- //
- (IBAction)presentCurrentView:(id)sender;
- (IBAction)dismissCurrentView:(id)sender;

@property (assign, nonatomic) SWFlowViewMode flowMode;

// -- Managing Selection -- //
- (NSInteger)indexForSelectedView;
- (void)selectViewAtIndex:(NSInteger)index animated:(BOOL)animated;

// -- Inserting, Deleting, and Moving Views -- //
- (void)insertViewsAtIndexes:(NSIndexSet*)indexes withViewAnimation:(SWFlowViewAnimation)animation;
- (void)deleteViewsAtIndexes:(NSIndexSet*)indexes withViewAnimation:(SWFlowViewAnimation)animation;
- (void)moveViewAtIndex:(NSInteger)index toIndex:(NSInteger)newIndex;

@property (assign, nonatomic, getter = isEditing) BOOL editing;

// -- Reloading the Flow View -- //
- (void)reloadData;
- (void)reloadViewsAtIndexes:(NSIndexSet*)indexes withViewAnimation:(SWFlowViewAnimation)animation;

// -- DataSource & Delegate -- //
@property (weak, nonatomic) id<SWFlowViewDelegate> delegate;
@property (weak, nonatomic) id<SWFlowViewDataSource> dataSource;

@end
