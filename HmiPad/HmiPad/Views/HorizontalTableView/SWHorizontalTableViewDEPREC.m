//
//  SWHorizontalTableView.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/27/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWHorizontalTableView.h"
#import <QuartzCore/QuartzCore.h>

#define DEFAULT_ROW_WIDTH 200

#define insert_delete_exception_description(number_of_rows, inserted_rows, deleted_rows, real_number_of_rows) [NSString stringWithFormat:@"Insertion/deletion failed because the number of rows in tableview is not the expected. The number of rows expected are the current number of rows (%d) plus or minus the number of rows inserted/deleted (inserted: %d, deleted: %d), but founded in data source %d rows.", number_of_rows, inserted_rows, deleted_rows, real_number_of_rows]


@interface SWHorizontalTableView ()

// Manipulating cells
- (void)_reuseCell:(SWHorizontalTableViewCell*)cell;
- (SWHorizontalTableViewCell*)_reusableCellWithIdentifier:(NSString*)identifier;
- (void)_deployCellAtIndex:(NSInteger)index;
- (void)_redeployCellAtIndex:(NSInteger)index;
- (void)_undeployCellAtIndex:(NSInteger)index;
- (void)_computeVisibleCells;
- (NSInteger)_rangeIndexFromIndex:(NSInteger)index;
- (NSInteger)_indexFromRangeIndex:(NSInteger)index;

// Manipulating the geometry
- (NSInteger)_rowAtOffset:(CGFloat)offset;
- (CGFloat)_offsetAtRow:(NSInteger)row;
- (CGSize)_computeContentSize;
- (CGPoint)_positionForCellAtIndex:(NSInteger)index;
- (CGRect)_frameForCellAtIndex:(NSInteger)index;
- (NSRange)_visibleRowsWithOffset:(CGFloat)offset;
- (BOOL)_isIndexInRange:(NSInteger)index ;

// Gesture recognizement
- (void)_didRecognizeTapGesture:(UITapGestureRecognizer*)gestureRecognizer;
- (void)_didRecognizeLongPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer;

// Animations
- (void)_performAnimationMoveCellAtIndex:(NSInteger)atIndex toCellPositionIndex:(NSInteger)toIndex completion:(void (^)(BOOL succeed))completion;

@end

@implementation SWHorizontalTableView
@synthesize style = _style;
@synthesize dataSource = _dataSource;
@synthesize delegate = _tableViewDelegate;
@synthesize rowWidth = _rowWidth;
@synthesize editing = _editing;
@synthesize selectedRow = _selectedRow;

- (id)initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame style:SWHorizontalTableViewStylePlain];
}

- (id)initWithFrame:(CGRect)frame style:(SWHorizontalTableViewStyle)style
{
    self = [super initWithFrame:frame];
    if (self) {
        _style = style;
        _rowWidth = DEFAULT_ROW_WIDTH;
        _numberOfRows = 0;
        _visibleCells = [NSMutableArray array];
        _lastSelectedRow = NSNotFound;
        _selectedRow = NSNotFound;
        _editing = NO;
        self.alwaysBounceHorizontal = YES;
        _isMoving = NO;
        _movingIndexCell = NSNotFound;
        _proposedIndex = NSNotFound;
        _startingMovingCellIndex = NSNotFound;
        _startOffset = 0;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_didRecognizeTapGesture:)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tapGesture];
        
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_didRecognizeLongPressGesture:)];
        longPressGesture.minimumPressDuration = 0.25 ;
        [self addGestureRecognizer:longPressGesture];
        
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _style = SWHorizontalTableViewStylePlain;
    _rowWidth = DEFAULT_ROW_WIDTH;
    _numberOfRows = 0;
    _visibleCells = [NSMutableArray array];
    _lastSelectedRow = NSNotFound;
    _selectedRow = NSNotFound;
    _editing = NO;
    self.alwaysBounceHorizontal = YES;
    _isMoving = NO;
    _movingIndexCell = NSNotFound;
    _proposedIndex = NSNotFound;
    _startingMovingCellIndex = NSNotFound;
    _startOffset = 0;

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_didRecognizeTapGesture:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    tapGesture.cancelsTouchesInView = NO;
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_didRecognizeLongPressGesture:)];
    longPressGesture.minimumPressDuration = 0.25 ;
    [self addGestureRecognizer:longPressGesture];
        
    if (_dataSource)
    {
        _numberOfRows = [_dataSource numberOfRowsInTableView:self];
        self.contentSize = [self _computeContentSize];
    }
}

- (void)dealloc
{
    // TODO
}

#pragma mark - Properties 

- (void)setDelegate:(id<SWHorizontalTableViewDelegate>)delegate
{
    [super setDelegate:delegate];
    _tableViewDelegate = delegate;
}

- (void)setEditing:(BOOL)editing
{
    [self setEditing:editing animated:NO];
}

#pragma mark - Overriden Methods

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Recomputing content size
    self.contentSize = [self _computeContentSize];
    
    // Recomputing visibleRows
    [self _computeVisibleCells];  // does it all, no need for frame change checks
}


//- (void)setContentOffset:(CGPoint)contentOffset
//{
//    //[self _computeVisibleCells];
//    [super setContentOffset:contentOffset];
//}


#pragma mark - Main Methods

- (void)reloadData
{
    for (SWHorizontalTableViewCell*cell in _visibleCells) {
        [cell removeFromSuperview];
        [self _reuseCell:cell];
    }

    self.contentOffset = CGPointMake(0, 0);
    
    _numberOfRows = [_dataSource numberOfRowsInTableView:self];    
    
    [self setNeedsLayout];
}

- (SWHorizontalTableViewCell*)dequeueCellWithReusableIdentifier:(NSString*)identifier
{
    return [self _reusableCellWithIdentifier:identifier];
}

- (NSInteger)numberOfRows
{
    return _numberOfRows;
}

- (NSInteger)indexForCell:(SWHorizontalTableViewCell*)cell
{
    NSInteger visibleCellIndex = [_visibleCells indexOfObjectIdenticalTo:cell];
    
    if (visibleCellIndex != NSNotFound) {
        visibleCellIndex = [self _indexFromRangeIndex:visibleCellIndex];
    }
    
    return visibleCellIndex;
}

- (UITableViewCell*)cellForRowAtIndex:(NSInteger)index
{
    BOOL isIndexInRange = [self _isIndexInRange:index];
        
    if (!isIndexInRange)
        return nil;
    
    NSInteger rangeIndex = [self _rangeIndexFromIndex:index];
    
    return [_visibleCells objectAtIndex:rangeIndex];
}

- (NSArray*)visibleCells
{    
    return _visibleCells;
}

- (NSIndexSet*)indexesForVisibleRows
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    for (NSInteger index = _visibleRows.location; index < _visibleRows.location + _visibleRows.length; index++) {
        [indexSet addIndex:index];
    }
    
    return indexSet;
}

- (void)selectRowAtIndex:(NSInteger)index animated:(BOOL)animated scrollPosition:(SWHorizontalTableViewScrollPosition)scrollPosition
{
    if (_selectedRow == index)
        return;
    
    if (index == NSNotFound) {
        [self deselectRowAtIndex:_selectedRow animated:NO];
        return;
    }
    
    CGFloat newOffset = [self _offsetAtRow:index];
    
    switch (scrollPosition) {
        case SWHorizontalTableViewScrollPositionLeft:
            // Nothing to do, current offset is already left
            break;
        case SWHorizontalTableViewScrollPositionMiddle:
            newOffset += -self.frame.size.width/2.0 + _rowWidth/2.0;
            break;
        case SWHorizontalTableViewScrollPositionRight:
            newOffset += -self.frame.size.width + _rowWidth;
            break;
        case SWHorizontalTableViewScrollPositionNone:
            newOffset = self.contentOffset.x;
            break;
        default:
            break;
    }
    
    newOffset = newOffset>(self.contentSize.width - self.frame.size.width)?(self.contentSize.width - self.frame.size.width):newOffset;
    newOffset = newOffset<0?0:newOffset;
    
    [self setContentOffset:CGPointMake(newOffset, 0) animated:animated];
    
    SWHorizontalTableViewCell *cell = [self cellForRowAtIndex:index];
    SWHorizontalTableViewCell *oldCell = [self cellForRowAtIndex:_selectedRow];
    
    [cell setSelected:YES animated:NO];
    [oldCell setSelected:NO animated:NO];
    
    _lastSelectedRow = _selectedRow;
    _selectedRow = index;
}

- (void)deselectRowAtIndex:(NSInteger)index animated:(BOOL)animated
{    
    if (index == NSNotFound)
        return;
    
    SWHorizontalTableViewCell *cell = [self cellForRowAtIndex:index];
    
    if (cell) {
        [cell setSelected:NO animated:animated];
    }
    
    _lastSelectedRow = _selectedRow;
    _selectedRow = NSNotFound;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    _editing = editing;    
    
    for (SWHorizontalTableViewCell *cell in _visibleCells) {
        [cell setEditing:editing animated:animated];
    }
}

- (void)insertRowsAtIndexes:(NSIndexSet*)indexes withRowAnimation:(SWHorizontalTableViewRowAnimation)animation
{    

    NSInteger newNumberOfRows = [_dataSource numberOfRowsInTableView:self];
    
    // Checking consistency
    if (newNumberOfRows != _numberOfRows + indexes.count) {
        NSString *reason = insert_delete_exception_description(_numberOfRows, indexes.count, 0, newNumberOfRows);
        NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
        [exception raise];
    }
    
    NSInteger oldNumberOfRows = _numberOfRows;
    _numberOfRows = newNumberOfRows;

    NSRange viewedRange = [self _visibleRowsWithOffset:self.contentOffset.x];
    
    NSIndexSet *viewedIndexes = [indexes indexesInRange:viewedRange options:NSEnumerationConcurrent passingTest:^BOOL(NSUInteger idx, BOOL *stop){
        return YES;
    }];

    NSIndexSet *unviewedIndexesAtLeft = [indexes indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        if (idx < viewedRange.location)
            return YES;
        return NO;
    }];

    
    NSIndexSet *unviewedIndexesAtRight = [indexes indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        if (idx >= viewedRange.location + viewedRange.length)
            return YES;
        return NO;
    }];
    
    (void)unviewedIndexesAtRight;
    
    // Actualitzem el content size, content offset i _visibleRows
    self.contentSize = [self _computeContentSize];
    self.contentOffset = CGPointMake(self.contentOffset.x + _rowWidth * unviewedIndexesAtLeft.count, 0);
    
    _visibleRows.location += unviewedIndexesAtLeft.count;
    
    // Reposicionem les celles actuals a les noves posicions temporals
    for (NSInteger i=_visibleRows.location; i<_visibleRows.location + _visibleRows.length; ++i) {
        SWHorizontalTableViewCell *cell = [self cellForRowAtIndex:i];
        cell.frame = [self _frameForCellAtIndex:i];
    }
    
    // Actualitzem, si fa falta, el _selectedRow
    if (_selectedRow == NSNotFound) {
        _lastSelectedRow = NSNotFound;
        _selectedRow = [indexes firstIndex];
    }
    
    NSIndexSet *indexesSmallerThanSelectedRow = [indexes indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        if (idx <= _selectedRow && oldNumberOfRows != 0)
            return YES;         
        return NO;
    }];
    _selectedRow += indexesSmallerThanSelectedRow.count;
    
    
    
    NSIndexSet *indexesSmallerThanLastSelectedRow = [indexes indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        if (idx <= _lastSelectedRow && oldNumberOfRows != 0)
            return YES;         
        return NO;
    }];
    _lastSelectedRow += indexesSmallerThanLastSelectedRow.count;

    
    if (viewedIndexes.count == 0)
        return;
    
    [UIView animateWithDuration:0.5 
                          delay:0.0 
                        options:UIViewAnimationCurveLinear 
                     animations:^{
                                                  
                         NSInteger usedIndexCount = 0;
                         NSInteger index = [viewedIndexes firstIndex];
                         
                         NSRange visibleRows = _visibleRows;
                         
                         for (NSInteger i=visibleRows.location; i<=visibleRows.location + visibleRows.length; ++i) {
   
                             if (i == index) {
                                 usedIndexCount++;
                                 index = [viewedIndexes indexGreaterThanIndex:index];
                             }
                             
                             SWHorizontalTableViewCell *cell = [self cellForRowAtIndex:i];
                             cell.frame = [self _frameForCellAtIndex:i+usedIndexCount];
                         }
                         
                     } completion:^(BOOL finished) {
    
                     }];
    
    [viewedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [self _deployCellAtIndex:idx]; 
    }];
}

- (void)deleteRowsAtIndexes:(NSIndexSet*)indexes withRowAnimation:(SWHorizontalTableViewRowAnimation)animation
{
    NSInteger newNumberOfRows = [_dataSource numberOfRowsInTableView:self];
    
    // Checking consistency
    if (newNumberOfRows != _numberOfRows - indexes.count) {
        NSString *reason = insert_delete_exception_description(_numberOfRows, 0, indexes.count, newNumberOfRows);
        NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
        [exception raise];
    }
    
    _numberOfRows = newNumberOfRows;
    
    NSIndexSet *viewedIndexes = [indexes indexesInRange:_visibleRows options:NSEnumerationConcurrent passingTest:^BOOL(NSUInteger idx, BOOL *stop){
        return YES;
    }];
    
    NSIndexSet *unviewedIndexesAtLeft = [indexes indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        if (idx < _visibleRows.location)
            return YES;
        return NO;
    }];
    
    NSIndexSet *unviewedIndexesAtRight = [indexes indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        if (idx >= _visibleRows.location + _visibleRows.length)
            return YES;
        return NO;
    }];
     
    (void)unviewedIndexesAtRight;
        
    // Actualitzem el content size, content offset i _visibleRows
    CGSize contentSize = [self _computeContentSize];
    self.contentSize = contentSize;
    CGSize frameSize = self.frame.size ;
    CGFloat newOffset = self.contentOffset.x - _rowWidth * unviewedIndexesAtLeft.count;    
    newOffset = newOffset>(contentSize.width - frameSize.width)?(contentSize.width - frameSize.width):newOffset;
    newOffset = newOffset<0?0:newOffset;    
    [self setContentOffset:CGPointMake(newOffset, 0) animated:YES];
    
    _visibleRows.location -= unviewedIndexesAtLeft.count;
    
    // Reposicionem les celles actuals a les noves posicions temporals
    for (NSInteger i=_visibleRows.location; i<_visibleRows.location + _visibleRows.length; ++i) {
        SWHorizontalTableViewCell *cell = [self cellForRowAtIndex:i];
        cell.frame = [self _frameForCellAtIndex:i];
    }
        
    
    if ([indexes containsIndex:_selectedRow]) {
        _lastSelectedRow = _selectedRow;
        _selectedRow = NSNotFound;
    } 
    
    NSIndexSet *indexesSmallerThanSelectedRow = [indexes indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        if (idx <= _selectedRow)
            return YES;         
        return NO;
    }];
    _selectedRow -= indexesSmallerThanSelectedRow.count;
    
    NSIndexSet *indexesSmallerThanLastSelectedRow = [indexes indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        if (idx <= _lastSelectedRow)
            return YES;         
        return NO;
    }];
    _lastSelectedRow -= indexesSmallerThanLastSelectedRow.count;
    
    
    
    if (viewedIndexes.count == 0)
        return;
    
    [UIView animateWithDuration:0.5 
                          delay:0.0 
                        options:UIViewAnimationCurveLinear 
                     animations:^{
                         
                         NSInteger usedIndexCount = 0;
                         NSInteger index = [viewedIndexes firstIndex];
                         
                         NSRange visibleRows = _visibleRows;
                         
                         for (NSInteger i=visibleRows.location; i<visibleRows.location + visibleRows.length; ++i) {
                             
                             if (i == index) {
                                 usedIndexCount++;
                                 index = [viewedIndexes indexGreaterThanIndex:index];
                             }
                             
                             
                             SWHorizontalTableViewCell *cell = [self cellForRowAtIndex:i];
                             cell.frame = [self _frameForCellAtIndex:i-usedIndexCount];
                         }
                         
                     } completion:^(BOOL finished) {
                         
                     }];
    
    [viewedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [self _undeployCellAtIndex:idx]; 
    }];
}

- (void)reloadRowsAtIndexes:(NSIndexSet *)indexes withRowAnimation:(SWHorizontalTableViewRowAnimation)animation
{       
    // Only operate on visible indexes
    NSIndexSet *viewedIndexes = [indexes indexesInRange:_visibleRows options:NSEnumerationConcurrent passingTest:^BOOL(NSUInteger idx, BOOL *stop){
        return YES;
    }];
    
    [viewedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [self _redeployCellAtIndex:idx];
    }];
}

- (void)moveRowAtIndex:(NSInteger)index toIndex:(NSInteger)newIndex
{
    //NSInteger finalIndex = newIndex;
    
//    if ([_tableViewDelegate respondsToSelector:@selector(tableView:targetIndexForMoveFromRowAtIndex:toProposedIndex:)]) {
//        finalIndex = [_tableViewDelegate tableView:self targetIndexForMoveFromRowAtIndex:index toProposedIndex:newIndex];
//    }
    
    if (index >= _numberOfRows || newIndex >= _numberOfRows)
        return;
    
    if (index == newIndex)
        return;

    // TODO
}

#pragma mark - Private Methods

- (void)_reuseCell:(SWHorizontalTableViewCell*)cell
{
    [cell prepareForReuse];
    
    NSMutableArray*cells = [_reusableTableCells valueForKey:cell.reuseIdentifier];
    
    if (!cells) {
        cells = [NSMutableArray array];
        [_reusableTableCells setValue:cells forKey:cell.reuseIdentifier];
    }
    
    [cells addObject:cell];
}

- (SWHorizontalTableViewCell*)_reusableCellWithIdentifier:(NSString*)identifier
{
    SWHorizontalTableViewCell*cell = nil;
    
    NSMutableArray*cells = [_reusableTableCells valueForKey:identifier];
    
    if (cells.count > 0) {
        cell = [cells lastObject];
        [cells removeObjectIdenticalTo:cell];
    }
    
    return cell;
}

- (void)_deployCellAtIndex:(NSInteger)index
{
    SWHorizontalTableViewCell *cell = [_dataSource tableView:self cellForRowAtIndex:index];
    
    cell.editing = self.editing;
    
    cell.frame = [self _frameForCellAtIndex:index];
    
    if (_selectedRow == index) {
        [cell setSelected:YES animated:NO];
    }
    
    NSInteger visibleCellIndex = [self _rangeIndexFromIndex:index];
    
    [_visibleCells insertObject:cell atIndex:visibleCellIndex];
    _visibleRows.length += 1 ;

    if ([_tableViewDelegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndex:)])
        [_tableViewDelegate tableView:self willDisplayCell:cell forRowAtIndex:index];
    
    [self addSubview:cell];
    [self sendSubviewToBack:cell];
}

- (void)_redeployCellAtIndex:(NSInteger)index
{
    SWHorizontalTableViewCell *cell = [_dataSource tableView:self cellForRowAtIndex:index];
    
    cell.editing = self.editing;
    cell.frame = [self _frameForCellAtIndex:index];
    
    if (_selectedRow == index) {
        [cell setSelected:YES animated:NO];
    }
    
    NSInteger visibleCellIndex = [self _rangeIndexFromIndex:index];
    
    SWHorizontalTableViewCell *oldCell = [_visibleCells objectAtIndex:visibleCellIndex];
    
    [oldCell removeFromSuperview];
    [self _reuseCell:oldCell];
    
    [_visibleCells replaceObjectAtIndex:visibleCellIndex withObject:cell];
    
    if ([_tableViewDelegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndex:)])
        [_tableViewDelegate tableView:self willDisplayCell:cell forRowAtIndex:index];
    
    [self addSubview:cell];
    [self sendSubviewToBack:cell];
}


- (void)_undeployCellAtIndex:(NSInteger)index
{ 
    
    NSInteger visibleCellIndex = [self _rangeIndexFromIndex:index];

    if (_visibleCells.count == 0 || visibleCellIndex < 0 || visibleCellIndex >= _visibleCells.count) {
        return;
    }
    
    SWHorizontalTableViewCell *removedCell = [_visibleCells objectAtIndex:visibleCellIndex];
    [removedCell removeFromSuperview];
    
    [_visibleCells removeObjectAtIndex:visibleCellIndex] ;
    _visibleRows.length -= 1 ;
    
    [self _reuseCell:removedCell];
}

- (void)_computeVisibleCells
{    
    // If no rows, nothing to do
    if (_numberOfRows == 0)
        return ;
    
    // Recomputing visibleRows
    NSRange newRange = [self _visibleRowsWithOffset:self.contentOffset.x];
    
    // If range is the same, nothing to do.
    if (newRange.location == _visibleRows.location && newRange.length == _visibleRows.length)
        return ;
    
    NSInteger newFirstCell = newRange.location;
    NSInteger newLastCell = newRange.location + newRange.length - 1;
    
    // MANIPULATING LOCATION
        
    while ( _visibleRows.location != newFirstCell ) 
    {
        if (_visibleRows.location > newFirstCell ) 
        {
            _visibleRows.location -= 1 ;
            [self _deployCellAtIndex:_visibleRows.location];
        } 
        else if (_visibleRows.location < newFirstCell) 
        {
            [self _undeployCellAtIndex:_visibleRows.location];
            _visibleRows.location += 1;
        }
    }

    // MANIPULATING LENGTH
    
    NSInteger lastCell = _visibleRows.location + _visibleRows.length - 1;
    
    while ( lastCell != newLastCell) 
    {
        if (lastCell > newLastCell) 
        {
            if (lastCell < _numberOfRows) {
                [self _undeployCellAtIndex:lastCell];
            } else {
                break;
            }
        }
        else if (lastCell < newLastCell) 
        {
            if (lastCell+1 < _numberOfRows) {
                [self _deployCellAtIndex:lastCell+1];
            } else {
                break;
            }
        }
            
        lastCell = _visibleRows.location + _visibleRows.length - 1;
    }
}

- (NSInteger)_rangeIndexFromIndex:(NSInteger)index
{
    return index - _visibleRows.location;
}

- (NSInteger)_indexFromRangeIndex:(NSInteger)index
{
    return _visibleRows.location + index;
}

- (BOOL)_isIndexInRange:(NSInteger)index
{
    return index >= _visibleRows.location && index < _visibleRows.location + _visibleRows.length ;
}

- (NSInteger)_rowAtOffset:(CGFloat)offset
{
    NSInteger rowIndex = (NSInteger)(offset/_rowWidth);
    return rowIndex;
}

- (CGFloat)_offsetAtRow:(NSInteger)row
{
    CGFloat offset = row * _rowWidth;
    return offset;
}

- (CGSize)_computeContentSize
{
    CGSize size = CGSizeMake(_numberOfRows* _rowWidth, self.frame.size.height);
    return size;
}

- (CGPoint)_positionForCellAtIndex:(NSInteger)index
{
    CGPoint point = CGPointMake(index * _rowWidth, 0);
    return point;
}

- (CGRect)_frameForCellAtIndex:(NSInteger)index
{
    CGRect frame = CGRectZero;
    frame.origin = [self _positionForCellAtIndex:index];
    frame.size = CGSizeMake(_rowWidth, self.frame.size.height);
    
    return frame;
}

- (NSRange)_visibleRowsWithOffset:(CGFloat)offset
{
    NSInteger startRow = [self _rowAtOffset:offset];
    NSInteger endRow = [self _rowAtOffset:(offset + self.frame.size.width - 1 )];  // -1 perque el ultim pixel cau a fora
    
    if ( startRow < 0 ) startRow = 0 ;
    if ( endRow < 0 ) endRow = 0 ;
    
    return NSMakeRange(startRow, endRow + 1 - startRow );
}

- (void)_didRecognizeTapGesture:(UITapGestureRecognizer*)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self];
    
    NSInteger index = [self _rowAtOffset:point.x];
    
    SWHorizontalTableViewCell *cell = [self cellForRowAtIndex:index];
    
    if (cell) {
        
        _lastSelectedRow = _selectedRow;
        _selectedRow = index;
        
        SWHorizontalTableViewCell *lastCell = [self cellForRowAtIndex:_lastSelectedRow];
        
        if (lastCell) {
            if ([_tableViewDelegate respondsToSelector:@selector(tableView:willDeselectRowAtIndex:)])
                [_tableViewDelegate tableView:self willDeselectRowAtIndex:_lastSelectedRow];
        
            [lastCell setSelected:NO];
            
            if ([_tableViewDelegate respondsToSelector:@selector(tableView:didDeselectRowAtIndex:)])
                [_tableViewDelegate tableView:self didDeselectRowAtIndex:_lastSelectedRow];
        }
    
        if ([_tableViewDelegate respondsToSelector:@selector(tableView:willSelectRowAtIndex:)])
            [_tableViewDelegate tableView:self willSelectRowAtIndex:_selectedRow];
        
        [cell setSelected:YES];
        
        if ([_tableViewDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndex:)])
            [_tableViewDelegate tableView:self didSelectRowAtIndex:_selectedRow];
    }
}

- (void)_didRecognizeLongPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer
{
    UIGestureRecognizerState state = gestureRecognizer.state;
    
    if (state == UIGestureRecognizerStateBegan) {
        
//        @synchronized(self){
            if (!_isMoving) {
                _isMoving = YES; 
            } else {
                return;
            }
//        }
        
        CGPoint point = [gestureRecognizer locationInView:self];
        
        NSInteger index = [self _rowAtOffset:point.x];
        
        BOOL canMove = NO;
        
        if ([_dataSource respondsToSelector:@selector(tableView:canMoveRowAtIndex:)])
            canMove = [_dataSource tableView:self canMoveRowAtIndex:index];
        
        if (!canMove || ![self _isIndexInRange:index]) 
            return;
                
        _startingMovingCellIndex = index;
        _movingIndexCell = index;
        _proposedIndex = index;
        _startOffset = [gestureRecognizer locationInView:self].x;
        
        SWHorizontalTableViewCell *cell = [self cellForRowAtIndex:index];
        
        [self bringSubviewToFront:cell];
        
        [UIView animateWithDuration:0.2 animations:^{
            cell.transform = CGAffineTransformMakeScale(1.05, 1.05); 
            
            cell.layer.masksToBounds = NO;
            cell.layer.shadowOffset = CGSizeMake(0,0);
            cell.layer.shadowRadius = 5;
            cell.layer.shadowOpacity = 0.5;
            CGRect shadowRect = cell.imageView.frame;
            cell.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowRect].CGPath;
        }];

        
    } else if (state == UIGestureRecognizerStateChanged) {
        if (!_isMoving)
            return;
        
        CGPoint point = [gestureRecognizer locationInView:self];
        
        SWHorizontalTableViewCell *cell = [self cellForRowAtIndex:_movingIndexCell];
        
        CGFloat newOffset = cell.frame.origin.x + (point.x - _startOffset);
        _startOffset = point.x;
        
//        // -------- WARNING : THE NEXT CODE IS NOT FINISHED YET -------- //
//        
//        // Check if should animate to right/left to allow move cells all long the tableview
//        
//        NSInteger margins = 100;
//        CGFloat relPos = 0.0;
//        CGFloat vel = 1.0;
//        BOOL animateRight = NO;
//        BOOL shouldAnimate = NO;
//        
//        CGFloat relativeOffset = point.x -  ((int)(point.x / self.frame.size.width)) * self.frame.size.width;
//        //NSLog(@"RELATIVE OFFSET: %f",relativeOffset);
//        
//        if (fabs(relativeOffset) < margins) {
//            // Left side
//            relPos = relativeOffset;
//            shouldAnimate = YES;
//        } else if (fabsf(relativeOffset - self.frame.size.width) < margins) {
//            // Right side
//            relPos = fabsf(relativeOffset - self.frame.size.width);
//            animateRight = YES;
//            shouldAnimate = YES;
//        }
//        
//        if (shouldAnimate) {
//            
//            if (fabsf(relPos) < TOL) {
//                vel = 4.0;
//            } else {
//                vel = MIN(margins/relPos,4.0);
//            }
//            
//            self.scrollAnimationDirection = CGPointMake(animateRight?1:-1, 0);
//            self.scrollAnimationVelocityFactor = vel;
//            
//            //NSLog(@"SHOULD ANIMATE TO RIGHT: %@", STRBOOL(animateRight));
//            
//            if (!self.isAnimatingScrolling) {
//                //[self startScrollingAnimation];
//            }
//            
//        } else {
//            //NSLog(@"SHOULD STOP ANIMATION");
//            //[self stopScrollingAnimation];
//        }
//
//        // ------------------------------------------------------------- //
        
        // Moving cells
        CGPoint newOrigin = CGPointMake(newOffset, cell.frame.origin.y);
        CGRect newFrame = cell.frame;
        newFrame.origin = newOrigin;
        cell.frame = newFrame;

        _proposedIndex = [self _rowAtOffset:(newOffset + _rowWidth/2.0)];
        
        if (_proposedIndex != _movingIndexCell) {
            
            NSInteger canMove = YES;
            
            if ([_dataSource respondsToSelector:@selector(tableView:canMoveRowAtIndex:)]) {
                canMove = [_dataSource tableView:self canMoveRowAtIndex:_proposedIndex];
            }
            
            if (canMove) {
                // Quan canvia el proposed Index, actualitzem l'ordre de les nostres vistes
                
                NSInteger visualNewCellIndex = [self _rangeIndexFromIndex:_proposedIndex];
                
                if (visualNewCellIndex < _numberOfRows) {
                    
                    
                    [self _performAnimationMoveCellAtIndex:_proposedIndex toCellPositionIndex:_movingIndexCell completion:^(BOOL succeed) {
                        NSLog(@"Succeed animation: %@",STRBOOL(succeed));
                    }];
                    
                    [_visibleCells removeObjectIdenticalTo:cell];
                    [_visibleCells insertObject:cell atIndex:visualNewCellIndex];
                    
                    if (_selectedRow == _movingIndexCell) {
                        _selectedRow = _proposedIndex;
                    }
                    
                    _movingIndexCell = _proposedIndex;
                }
            }            
            
        }

    } else if (state == UIGestureRecognizerStateEnded) {
//        @synchronized(self){
            if (_isMoving) {
                _isMoving = NO; 
            } else {
                return;
            }
//        }

        //[self stopScrollingAnimation];
        
        SWHorizontalTableViewCell *cell = [self cellForRowAtIndex:_movingIndexCell];
        
        
        
        [UIView animateWithDuration:0.2 animations:^{
            cell.transform = CGAffineTransformIdentity; 
            cell.frame = [self _frameForCellAtIndex:_movingIndexCell];
            
            cell.layer.shadowOffset = CGSizeZero;
            cell.layer.shadowRadius = 0;
            cell.layer.shadowOpacity = 0;
            cell.layer.shadowPath = nil;
            
        } completion:^(BOOL finished) {
            [self sendSubviewToBack:cell];
        }];
        
        if (_movingIndexCell != _startingMovingCellIndex) {
            if ([_dataSource respondsToSelector:@selector(tableView:moveRowAtIndex:toIndex:)]) {
                [_dataSource tableView:self moveRowAtIndex:_startingMovingCellIndex toIndex:_movingIndexCell];
            }
        }

        // Reseting variables
        _startingMovingCellIndex = NSNotFound;
        _movingIndexCell = NSNotFound;
        _proposedIndex = NSNotFound;
        _startOffset = 0;
        
    } else {
        NSLog(@"[8397sd] WARNING: Gesture recognizer did return an unknown state %d", state);
        
//        @synchronized(self){
            if (_isMoving) {
                _isMoving = NO; 
            } else {
                return;
            }
//        }
        
        //[self stopScrollingAnimation];
        
        SWHorizontalTableViewCell *cell = [self cellForRowAtIndex:_movingIndexCell];
        
        [UIView animateWithDuration:0.2 animations:^{
            cell.transform = CGAffineTransformIdentity; 
            cell.frame = [self _frameForCellAtIndex:_movingIndexCell];
            
            cell.layer.shadowOffset = CGSizeZero;
            cell.layer.shadowRadius = 0;
            cell.layer.shadowOpacity = 0;
            cell.layer.shadowPath = nil;
            
        } completion:^(BOOL finished) {
            [self sendSubviewToBack:cell];
        }];
        
        if (_movingIndexCell != _startingMovingCellIndex) {
            if ([_dataSource respondsToSelector:@selector(tableView:moveRowAtIndex:toIndex:)]) {
                [_dataSource tableView:self moveRowAtIndex:_startingMovingCellIndex toIndex:_movingIndexCell];
            }
        }
        
        // Reseting variables
        _startingMovingCellIndex = NSNotFound;
        _movingIndexCell = NSNotFound;
        _proposedIndex = NSNotFound;
        _startOffset = 0;
    }
}

- (void)_performAnimationMoveCellAtIndex:(NSInteger)atIndex toCellPositionIndex:(NSInteger)toIndex completion:(void (^)(BOOL succeed))completion
{
    SWHorizontalTableViewCell *cell = [self cellForRowAtIndex:atIndex];
    
    if (!cell) {
        completion(NO);
        return;
    }
    
    CGRect newFrame = [self _frameForCellAtIndex:toIndex];
    
    [UIView animateWithDuration:0.25 
                          delay:0 
                        options:UIViewAnimationCurveLinear 
                     animations:^{
                         
                         cell.frame = newFrame;
                         
                     } completion:^(BOOL finished) {
                         completion(finished); 
                     }];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIControl class]]){
        return NO;
    }
    
    return YES;
}

@end
