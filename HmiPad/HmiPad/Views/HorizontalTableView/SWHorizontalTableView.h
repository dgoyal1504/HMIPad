//
//  SWHorizontalTableView.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/27/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWScrollView.h"

#import "SWHorizontalTableViewCell.h"

typedef enum {
    SWHorizontalTableViewStylePlain
} SWHorizontalTableViewStyle;

typedef enum {
    SWHorizontalTableViewRowAnimationNone,
    SWHorizontalTableViewRowAnimationAutomatic = 100
} SWHorizontalTableViewRowAnimation;

typedef enum {
    SWHorizontalTableViewScrollPositionNone,
    SWHorizontalTableViewScrollPositionLeft,
    SWHorizontalTableViewScrollPositionMiddle,
    SWHorizontalTableViewScrollPositionRight
} SWHorizontalTableViewScrollPosition;

@class SWHorizontalTableView;

/**
 * Horizontal Table View Delegate Protocol
 */
@protocol SWHorizontalTableViewDelegate <NSObject, UIScrollViewDelegate>

@optional

// Display customization
- (void)tableView:(SWHorizontalTableView *)tableView willDisplayCell:(SWHorizontalTableViewCell *)cell forRowAtIndex:(NSInteger)index;

// Variable height support
//- (CGFloat)tableView:(SWHorizontalTableView *)tableView widthForRowAtIndex:(NSInteger)index;

// Selection
- (NSInteger)tableView:(SWHorizontalTableView *)tableView willSelectRowAtIndex:(NSInteger)index;
- (NSInteger)tableView:(SWHorizontalTableView *)tableView willDeselectRowAtIndex:(NSInteger)index;
- (void)tableView:(SWHorizontalTableView *)tableView didSelectRowAtIndex:(NSInteger)index;
- (void)tableView:(SWHorizontalTableView *)tableView didDeselectRowAtIndex:(NSInteger)index;

// Editing
// --- WARNING: NOT CALLED YET -- //
- (SWHorizontalTableViewCellEditingStyle)tableView:(SWHorizontalTableView *)tableView editingStyleForRowAtIndex:(NSInteger)index; // NOT CALLED YET

// Moving/reordering
// --- WARNING: NOT CALLED YET -- //
- (NSInteger)tableView:(SWHorizontalTableView *)tableView targetIndexForMoveFromRowAtIndex:(NSInteger)sourceIndex toProposedIndex:(NSInteger)proposedDestinationIndex;

@end


/**
 * Horizontal Table View DataSource Protocol
 */
@protocol SWHorizontalTableViewDataSource <NSObject>

@required

- (NSInteger)numberOfRowsInTableView:(SWHorizontalTableView *)tableView;
- (SWHorizontalTableViewCell *)tableView:(SWHorizontalTableView *)tableView cellForRowAtIndex:(NSInteger)index;

@optional

// Editing
// --- WARNING: NOT CALLED YET -- //
- (BOOL)tableView:(SWHorizontalTableView *)tableView canEditRowAtIndex:(NSInteger)index;

// Moving/reordering
// --- WARNING: NOT CALLED YET -- //
- (BOOL)tableView:(SWHorizontalTableView *)tableView canMoveRowAtIndex:(NSInteger)index;

// Data manipulation - insert and delete support
// --- WARNING: NOT CALLED YET -- //
- (void)tableView:(SWHorizontalTableView *)tableView commitEditingStyle:(SWHorizontalTableViewCellEditingStyle)editingStyle forRowAtIndex:(NSInteger)index;

// Data manipulation - reorder / moving support
- (void)tableView:(SWHorizontalTableView *)tableView moveRowAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex;

@end


/**
 * Horizontal Table View Main Class
 */
@interface SWHorizontalTableView : SWScrollView <UIGestureRecognizerDelegate> {
    NSInteger _numberOfRows;
    
    NSMutableArray *_visibleCells;
    NSMutableDictionary *_reusableTableCells;
    
    NSRange _visibleRows;
    
    unsigned int _selectedRow;
    unsigned int _lastSelectedRow;
    
    // -- Moving cells -- //
    BOOL _isMoving;
    NSInteger _movingIndexCell;
    CGFloat _startOffset;
    NSInteger _startingMovingCellIndex;
    NSInteger _proposedIndex;
}

- (id)initWithFrame:(CGRect)frame style:(SWHorizontalTableViewStyle)style;

@property(nonatomic,readonly) SWHorizontalTableViewStyle                 style;
@property(nonatomic,weak) IBOutlet id <SWHorizontalTableViewDataSource>  dataSource;
@property(nonatomic,weak) IBOutlet id <SWHorizontalTableViewDelegate>    delegate;
@property(nonatomic, assign)  CGFloat                                    rowWidth;
@property(nonatomic, assign, getter = isEditing) BOOL                    editing;
@property(nonatomic, readonly) NSUInteger selectedRow;

- (void)reloadData;

- (SWHorizontalTableViewCell*)dequeueCellWithReusableIdentifier:(NSString*)identifier;

- (NSInteger)numberOfRows;

- (NSInteger)indexForCell:(SWHorizontalTableViewCell *)cell;

- (SWHorizontalTableViewCell *)cellForRowAtIndex:(NSInteger)index;

- (NSArray *)visibleCells;
- (NSIndexSet*)indexesForVisibleRows;

- (void)selectRowAtIndex:(NSInteger)index animated:(BOOL)animated scrollPosition:(SWHorizontalTableViewScrollPosition)scrollPosition;
- (void)deselectRowAtIndex:(NSInteger)index animated:(BOOL)animated;

- (void)insertRowsAtIndexes:(NSIndexSet *)indexes withRowAnimation:(SWHorizontalTableViewRowAnimation)animation;
- (void)deleteRowsAtIndexes:(NSIndexSet *)indexes withRowAnimation:(SWHorizontalTableViewRowAnimation)animation;
- (void)reloadRowsAtIndexes:(NSIndexSet *)indexes withRowAnimation:(SWHorizontalTableViewRowAnimation)animation;

// --- WARNING: NOT IMPLEMENTED YET -- //
- (void)setEditing:(BOOL)editing animated:(BOOL)animated;
- (void)moveRowAtIndex:(NSInteger)index toIndex:(NSInteger)newIndex;
// ----------------------------------- //

@end
