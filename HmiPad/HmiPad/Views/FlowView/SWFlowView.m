//
//  SWFlowView.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/8/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import "SWFlowView.h"
#import "SWFlowViewItem.h"

NSString * const SWFlowViewIncompatibilityException = @"SWFlowViewIncompatibilityException";

#pragma mark - Private Class
@interface SWFlowView (Private)

- (SWFlowViewItem*)_dequeueReusableItem;
- (void)_reuseItem:(SWFlowViewItem*)item;

- (SWFlowViewItem*)_getItem;

- (CGPoint)_positionForViewAtIndex:(NSInteger)index;
- (CGPoint)_offsetForViewAtIndex:(NSInteger)index;

- (void)_undeployItemAtIndex:(NSInteger)index;
- (void)_deployItem:(SWFlowViewItem*)item atIndex:(NSInteger)index;

- (void)_commitCurrentDisplayedItemsFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
- (void)_updateSelectedViewWithViewIndex:(NSInteger)index;
- (void)_updateLabelsForSelectedView;

- (void)_refreshFlowView;

- (void)_insertItem:(SWFlowViewItem*)item atIndex:(NSInteger)index animation:(SWFlowViewAnimation)animation;
- (void)_deleteItem:(SWFlowViewItem*)item atIndex:(NSInteger)index animation:(SWFlowViewAnimation)animation;

@end

#pragma mark - Public Class

@implementation SWFlowView

#pragma mark - Properties

@synthesize flowMode = _flowMode;
@synthesize editing = _editing;

@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;

#pragma mark - Initializers

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        // Setting up the background
        self.backgroundColor = [UIColor clearColor];
        _gradient = [CAGradientLayer layer];
        _gradient.frame = self.bounds;
        _gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:145/255.0 green:160/255.0 blue:172/255.0 alpha:1.0] CGColor], 
                                                     (id)[[UIColor colorWithRed:80/255.0 green:105/255.0 blue:123/255.0 alpha:1.0] CGColor], nil];
        [self.layer addSublayer:_gradient];
        
        // Setting up Labels
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:37];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.layer.masksToBounds = NO;
        _titleLabel.layer.shadowOffset = CGSizeMake(0, -1);
        _titleLabel.layer.shadowRadius = 0.2;
        _titleLabel.layer.shadowOpacity = 1.0;
        _titleLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:_titleLabel];
        
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        _subtitleLabel.font = [UIFont systemFontOfSize:18];
        _subtitleLabel.textColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
        _subtitleLabel.layer.masksToBounds = NO;
        _subtitleLabel.layer.shadowOffset = CGSizeMake(0, -0.5);
        _subtitleLabel.layer.shadowRadius = 0.2;
        _subtitleLabel.layer.shadowOpacity = 1.0;
        _subtitleLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
        _subtitleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:_subtitleLabel];
        
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.center = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height - 80);
        _pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _pageControl.backgroundColor = [UIColor clearColor];
        [self addSubview:_pageControl];
        
        // Setting up the scrollView
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.autoresizesSubviews = YES;
        _scrollView.scrollEnabled = NO;
        _scrollView.userInteractionEnabled = NO;
        [self addSubview:_scrollView];
        
        // Class Attributes
        _flowMode = SWFlowViewModeViewFlow;
        _flowItemsSeparation = 50;
        _smallifyTransform = CGAffineTransformMakeScale(0.6, 0.6);
        
        _selectedViewIndex = -1;
        _reusableItems = [NSMutableArray array];
        _activeItems = [NSMutableDictionary dictionary];
        
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _gradient.frame = self.bounds;
    
    _flowItemsSize = CGSizeMake(self.bounds.size.width*_smallifyTransform.a, self.bounds.size.height*_smallifyTransform.d);
    _flowItemsYPosition = (self.bounds.size.height - _flowItemsSize.height)/2.0;
    //_flowItemsSeparation = self.bounds.size.width*0.2;
    
    CGSize size = CGSizeMake(_numberOfItems * (_flowItemsSize.width + _flowItemsSeparation), self.bounds.size.height);
    _scrollView.contentSize = size;
    
    // Repositioning current views
    for (NSNumber *idx in _activeItems) {
        NSInteger index = [idx integerValue];
        
        SWFlowViewItem *item = [_activeItems objectForKey:idx];
        
        CGPoint position = [self _positionForViewAtIndex:index];
        
        CGRect frame = item.frame;
        frame.origin = position;
        frame.size = self.bounds.size;
        item.transform = CGAffineTransformIdentity;
        item.frame = frame;

        if (index == _selectedViewIndex && _flowMode == SWFlowViewModeViewPresentation) {
            item.transform = _smallifyTransform;
            frame = item.frame;
            frame.origin = position;        
            item.frame = frame;
            item.transform = CGAffineTransformIdentity;
        } else {
            item.transform = _smallifyTransform;
            frame = item.frame;
            frame.origin = position;        
            item.frame = frame;
        }
    }
}

#pragma mark - Properties Overriding

- (void)setEditing:(BOOL)editing
{
    _editing = editing;
    // Do something else
}

- (void)setDataSource:(id<SWFlowViewDataSource>)dataSource
{
    _dataSource = dataSource;
    [self reloadData];
}

#pragma mark - Main Methods


- (void)sleep
{
    NSArray *keys = [_activeItems.allKeys copy];
    for (NSNumber *idx in keys) {
        [self _undeployItemAtIndex:idx.integerValue];
    }
    
    _selectedViewIndex = -1;    
    _flowMode = SWFlowViewModeViewSleep;
}

- (void)awakeAtIndex:(NSInteger)index inFullScreen:(BOOL)fullScreen
{
    //_selectedViewIndex = index;
    [self _updateSelectedViewWithViewIndex:index];
    
    if (fullScreen) {
        _flowMode = SWFlowViewModeViewPresentation;
    } else {
        _flowMode = SWFlowViewModeViewFlow;
    }
    
    [self _refreshFlowView];
    
    [self setNeedsLayout];
}

// -- Managing Flow View State -- //
- (IBAction)presentCurrentView:(id)sender;
{
    SWFlowViewItem *item = [_activeItems objectForKey:[NSNumber numberWithInteger:_selectedViewIndex]];
    if (!item) {
        NSLog(@"[WARNING] [3kj9sa] _selectedViewIndex not mapped int _activeItems");
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(flowView:willPresentViewAtIndex:)]) {
        [_delegate flowView:self willPresentViewAtIndex:_selectedViewIndex];
    }
    
    [_scrollView bringSubviewToFront:item];
        
    _flowMode = SWFlowViewModeViewPresentation;
    
    [UIView animateWithDuration:0.25 
                     animations:^{
                        //item.frame = frame;
                        item.transform = CGAffineTransformIdentity; 
                     } completion:^(BOOL finished) {
                         //item.userInteractionEnabled = YES;
                         [item enableUserInteraction];
                         
                         if ([_delegate respondsToSelector:@selector(flowView:didPresentViewAtIndex:)]) {
                             [_delegate flowView:self didPresentViewAtIndex:_selectedViewIndex];
                         }
                     }];
}

- (IBAction)dismissCurrentView:(id)sender;
{
    SWFlowViewItem *item = [_activeItems objectForKey:[NSNumber numberWithInteger:_selectedViewIndex]];
    if (!item) {
        NSLog(@"[WARNING] [3kj9sa] _selectedViewIndex not mapped int _activeItems");
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(flowView:willDismissViewAtIndex:)]) {
        [_delegate flowView:self willDismissViewAtIndex:_selectedViewIndex];
    }
    
    item.contentView = [_dataSource flowView:self contentForViewAtIndex:_selectedViewIndex];
    
    _flowMode = SWFlowViewModeViewFlow;
        
    item.transform = CGAffineTransformIdentity; 
    [UIView animateWithDuration:0.25 
                     animations:^{
                         item.transform = _smallifyTransform; 
                     } completion:^(BOOL finished) {
                         //item.userInteractionEnabled = NO;
                         [item disableUserInteraction];
                         
                         if ([_delegate respondsToSelector:@selector(flowView:didDismissViewAtIndex:)]) {
                             [_delegate flowView:self didDismissViewAtIndex:_selectedViewIndex];
                         }
                     }];
}


// -- Managing Selection -- //
- (NSInteger)indexForSelectedView
{
    return _selectedViewIndex;
}

- (void)selectViewAtIndex:(NSInteger)index animated:(BOOL)animated
{
    if (_selectedViewIndex == index) {
        return;
    }

    if (index > _selectedViewIndex) {
        [self _commitCurrentDisplayedItemsFromIndex:_selectedViewIndex-1 toIndex:index+1];
    } else {
        [self _commitCurrentDisplayedItemsFromIndex:index-1 toIndex:_selectedViewIndex+1];
    }
    
    [self _updateSelectedViewWithViewIndex:index];
    CGPoint newOffset = [self _offsetForViewAtIndex:_selectedViewIndex];
    [_scrollView setContentOffset:newOffset animated:animated];
}


// -- Inserting, Deleting, and Moving Views -- //
- (void)insertViewsAtIndexes:(NSIndexSet*)indexes withViewAnimation:(SWFlowViewAnimation)animation
{
    NSInteger newSize = [_dataSource numberOfViewsInFlowView:self];
    
    if (newSize != _numberOfItems + indexes.count) {
        NSException *e = [NSException exceptionWithName:SWFlowViewIncompatibilityException 
                                                 reason:[NSString stringWithFormat:@"The number while inserting doesn't fit the expected size. Requesting to add %d elements to %d existing ones (%d total expected), but founded %d through data source.", indexes.count, _numberOfItems, indexes.count+_numberOfItems, newSize] 
                                               userInfo:[NSDictionary dictionary]];
        [e raise];
    }
    
    
    _numberOfItems = newSize;
    
    _pageControl.numberOfPages = _numberOfItems;
    
    if (_numberOfItems == 1) { // First Item
        SWFlowViewItem *item = [self _getItem];
        item.contentView = [self.dataSource flowView:self contentForViewAtIndex:0];
        [self _insertItem:item atIndex:0 animation:animation];
        _selectedViewIndex = 0;
        [self _updateLabelsForSelectedView];
        return;
    } 
    
    __block BOOL shouldRedisplay = NO;
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        
        if (idx > _selectedViewIndex + 2) {
            NSLog(@"Added after");
            // Nothing to do. Object added after the current displayed objects
            
        } else if ((NSInteger)idx < _selectedViewIndex - 2) {
            NSLog(@"Added before");
            // Object added before the current displayed objects. Current displayed objects must increase their index position key and should repositionate the content offset and redisplay the objects.
            NSMutableDictionary * activeItems = [NSMutableDictionary dictionary];
            
            for (NSNumber *key in _activeItems.allKeys) {        // ???? utilitzar directament _activeItems !
                [activeItems setObject:[_activeItems objectForKey:key] forKey:[NSNumber numberWithInteger:key.integerValue+1]];
            }
            
            _activeItems = activeItems;
            
            _selectedViewIndex++;
            _pageControl.currentPage++;
            
            shouldRedisplay = YES;
        } else {
            // Object added at around the current displayed objects. Should add Animation if needed and repositionate the views.
            SWFlowViewItem *item = [self _getItem];
            item.contentView = [self.dataSource flowView:self contentForViewAtIndex:idx];
            
            [self _insertItem:item atIndex:idx animation:animation];
            
            [self _updateLabelsForSelectedView];
            
            if (idx > _selectedViewIndex) {
                NSLog(@"Right View");
            } else if (idx < _selectedViewIndex) {
                NSLog(@"Left View");
            } else {
                NSLog(@"Central View");
            }
        }
    }];
    
    if (shouldRedisplay) {
        [_scrollView setContentOffset:[self _offsetForViewAtIndex:_selectedViewIndex]];
        [self _updateLabelsForSelectedView];
        [self setNeedsLayout];
    }
    
    //[self _addItemSubviews:items withPageItemAnimation:animation completion:^{ if(completion) completion(); }];
}
 
- (void)deleteViewsAtIndexes:(NSIndexSet*)indexes withViewAnimation:(SWFlowViewAnimation)animation
{
    NSInteger newSize = [_dataSource numberOfViewsInFlowView:self];
    
    if (newSize != _numberOfItems - indexes.count) {
        NSException *e = [NSException exceptionWithName:SWFlowViewIncompatibilityException 
                                                 reason:[NSString stringWithFormat:@"The number while deleting doesn't fit the expected size. Requesting to remove %d elements from %d existing ones (%d total expected), but founded %d through data source.", indexes.count, _numberOfItems, _numberOfItems-indexes.count, newSize] 
                                               userInfo:[NSDictionary dictionary]];
        [e raise];
    }
    
    
    _numberOfItems = newSize;
    
    _pageControl.numberOfPages = _numberOfItems;
    
//    if (_numberOfItems == 1) { // First Item
//        SWFlowViewItem *item = [self _getItem];
//        item.contentView = [self.dataSource flowView:self contentForViewAtIndex:0];
//        [self _insertItem:item atIndex:0 animation:animation];
//        
//        return;
//    }
    
    __block BOOL shouldRedisplay = NO;
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        
        if (idx > _selectedViewIndex + 2) {
            NSLog(@"Removed after");
            // Nothing to do. Object removed after the current displayed objects
            
        } else if ((NSInteger)idx < _selectedViewIndex - 2) {
            NSLog(@"Removed before");
            // Object removed before the current displayed objects. Current displayed objects must decrease their index position key and should repositionate the content offset and redisplay the objects.
            NSMutableDictionary * activeItems = [NSMutableDictionary dictionary];
            
            for (NSNumber *key in _activeItems.allKeys) {    // ???? utilitzar directament _activeItems !
                [activeItems setObject:[_activeItems objectForKey:key] forKey:[NSNumber numberWithInteger:key.integerValue-1]];
            }
            
            _activeItems = activeItems;
            
            _selectedViewIndex--;
            _pageControl.currentPage--;
            
            shouldRedisplay = YES;
            
        } else {
            // Object removed around the current displayed objects. Should animate if needed and repositionate the views.
            SWFlowViewItem *item = [_activeItems objectForKey:[NSNumber numberWithInteger:idx]];
            
            [self _deleteItem:item atIndex:idx animation:animation];
        }
    }];
    
    if (shouldRedisplay) {
        [_scrollView setContentOffset:[self _offsetForViewAtIndex:_selectedViewIndex]];
        [self setNeedsLayout];
    }

}

- (void)moveViewAtIndex:(NSInteger)index toIndex:(NSInteger)newIndex
{
    // TODO
}


// -- Reloading the Flow View -- //
- (void)reloadData
{
    if (!self.dataSource)
        return;
    
    _numberOfItems = [self.dataSource numberOfViewsInFlowView:self];

    _pageControl.numberOfPages = _numberOfItems;
    
    CGSize size = CGSizeMake(_numberOfItems * (_flowItemsSize.width + _flowItemsSeparation), self.bounds.size.height);
    _scrollView.contentSize = size;
    
    if (_numberOfItems == 0)
        return;
    
    if (_selectedViewIndex == -1 ) { // First time of reloading
        [self _updateSelectedViewWithViewIndex:0];
    }
    
    [self _refreshFlowView];
}

- (void)reloadViewsAtIndexes:(NSIndexSet*)indexes withViewAnimation:(SWFlowViewAnimation)animation
{
    // TODO
}

#pragma mark - User Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{    
    if (_flowMode == SWFlowViewModeViewPresentation) {
        [super touchesBegan:touches withEvent:event];
        return;
    }
    
    _firstOffset = _scrollView.contentOffset.x;
    _firstTime = [[touches anyObject] timestamp];
    _firstSelectedItem = _selectedViewIndex;
    _moved = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{    
    if (_flowMode == SWFlowViewModeViewPresentation) {
        [super touchesMoved:touches withEvent:event];
        return;
    }
    
    _moved = YES;
    
   // NSLog(@"ACTIVE ITEMS SIZE: %d",_activeItems.count);
   // NSLog(@"REUSABLE ITEMS SIZE: %d",_reusableItems.count);
    UITouch *touch = [[event touchesForView:self] anyObject];
    CGPoint previousPosition = [touch previousLocationInView:self];
    CGPoint position = [touch locationInView:self];
    
    CGPoint offset = CGPointMake(position.x - previousPosition.x, position.y - previousPosition.y);

    CGPoint contentOffset = _scrollView.contentOffset;
    
    _scrollView.contentOffset = CGPointMake(contentOffset.x - offset.x, contentOffset.y);
    
    CGFloat window = (_flowItemsSize.width + _flowItemsSeparation);
    
    NSInteger centerItem = (contentOffset.x + window/2.0) / window;
    [self _updateSelectedViewWithViewIndex:centerItem];
    
    NSInteger leftItem = (contentOffset.x + window/2.0 - self.bounds.size.width/2.0) / window;    
    NSInteger rightItem = (contentOffset.x + window/2.0 + self.bounds.size.width/2.0) / window; 
    
    leftItem--;
    rightItem++;
    
    if (leftItem<0)
        leftItem = 0;
    
    if (rightItem<0)
        rightItem = 0;
    
    if (leftItem>_numberOfItems-1)
        leftItem = _numberOfItems-1;
    
    if (rightItem>_numberOfItems-1)
        rightItem = _numberOfItems-1;
    
    [self _commitCurrentDisplayedItemsFromIndex:leftItem toIndex:rightItem];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_flowMode == SWFlowViewModeViewPresentation) {
        [super touchesEnded:touches withEvent:event];
        return;
    }
    
    if (_moved) {
        
        CGFloat window = (_flowItemsSize.width + _flowItemsSeparation);
        NSInteger centerItem = (_scrollView.contentOffset.x + window/2.0) / window; 
        
            
        CGFloat lastOffset = _scrollView.contentOffset.x;
        NSTimeInterval lastTime = [[touches anyObject] timestamp];
        
        NSTimeInterval timeOffset = lastTime - _firstTime;
        CGFloat xOffset = lastOffset - _firstOffset;
        
        CGFloat vel = fabsf(xOffset/timeOffset);
                
        //NSLog(@"timeOffset: %f, xOffset: %f, vel: %f", timeOffset,xOffset, vel);
        
        BOOL toRight = xOffset>0?YES:NO;
        BOOL shouldChangeItem = vel>600.0f?YES:NO;
        
        //NSLog(@"VEL: %f, toRight: %@, apply: %@",vel, toRight?@"YES":@"NO", shouldChangeItem?@"YES":@"NO");
        
        if (shouldChangeItem && centerItem == _firstSelectedItem) {
            centerItem += toRight?1:-1;
        }

        if (centerItem < 0) centerItem = 0;
        if (centerItem >= _numberOfItems) centerItem = _numberOfItems-1;

        [self _updateSelectedViewWithViewIndex:centerItem];
        
        CGPoint newOffset = [self _offsetForViewAtIndex:centerItem];
        [_scrollView setContentOffset:newOffset animated:YES];
        
    } else { // IF NO MOVED
        
        CGPoint point = [[touches anyObject] locationInView:self];
        
        SWFlowViewItem *leftItem = [_activeItems objectForKey:[NSNumber numberWithInteger:_selectedViewIndex-1]];
        SWFlowViewItem *rightItem = [_activeItems objectForKey:[NSNumber numberWithInteger:_selectedViewIndex+1]];
        SWFlowViewItem *centerItem = [_activeItems objectForKey:[NSNumber numberWithInteger:_selectedViewIndex]];
        
        if ([centerItem pointInside:[centerItem convertPoint:point fromView:self] withEvent:event]) {
            
            [self presentCurrentView:nil];
            
        } else if ([rightItem pointInside:[rightItem convertPoint:point fromView:self] withEvent:event]) {
            
            [self selectViewAtIndex:_selectedViewIndex+1 animated:YES];
            
        } else if ([leftItem pointInside:[leftItem convertPoint:point fromView:self] withEvent:event]) {
            
            [self selectViewAtIndex:_selectedViewIndex-1 animated:YES];
        
        }
    }
}

@end

#pragma mark - Private Class

@implementation SWFlowView (Private)

- (SWFlowViewItem*)_dequeueReusableItem
{
    SWFlowViewItem *item = [_reusableItems lastObject];
    
    if (item) {
        [_reusableItems removeLastObject];
    }
    
    return item;
}

- (void)_reuseItem:(SWFlowViewItem*)item
{
    [item prepareForReuse];
    [_reusableItems addObject:item];
}

- (SWFlowViewItem*)_getItem
{
    SWFlowViewItem *item = [self _dequeueReusableItem];
    
    if (!item) {
        item = [[SWFlowViewItem alloc] initWithFrame:self.bounds];
    }
        
    return item;
}

- (CGPoint)_positionForViewAtIndex:(NSInteger)index
{
    CGFloat first = (self.bounds.size.width - _flowItemsSize.width)/2.0;
    CGFloat offsetToNext = _flowItemsSize.width + _flowItemsSeparation;
    CGPoint point = CGPointMake(first+ index*offsetToNext, _flowItemsYPosition);
    return point;
}

- (CGPoint)_offsetForViewAtIndex:(NSInteger)index
{
    CGFloat first = 0;
    CGFloat offsetToNext = _flowItemsSize.width + _flowItemsSeparation;
    return CGPointMake(first + offsetToNext*index, 0);
}

- (void)_removeActiveItems
{
    [_activeItems.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSArray *items = [_activeItems.allValues copy];
    
    [_activeItems removeAllObjects];
    
    for (SWFlowViewItem *item in items) {
        [self _reuseItem:item];
    }
}

- (void)_undeployItemAtIndex:(NSInteger)index
{
    if ([_delegate respondsToSelector:@selector(flowView:willDisappearViewAtIndex:)])
        [_delegate flowView:self willDisappearViewAtIndex:index];
    
    NSNumber *idx = [NSNumber numberWithInteger:index];
    SWFlowViewItem *item = [_activeItems objectForKey:idx];
    [item removeFromSuperview];
    [_activeItems removeObjectForKey:idx];
    [self _reuseItem:item];
    
    if ([_delegate respondsToSelector:@selector(flowView:didDisappearViewAtIndex:)])
        [_delegate flowView:self didDisappearViewAtIndex:index];
}

- (void)_deployItem:(SWFlowViewItem*)item atIndex:(NSInteger)index
{
    if ([_delegate respondsToSelector:@selector(flowView:willAppearViewAtIndex:)])
        [_delegate flowView:self willAppearViewAtIndex:index];
    
    [_activeItems setObject:item forKey:[NSNumber numberWithInteger:index]];    
    [_scrollView addSubview:item];
    
    if (index == _selectedViewIndex) {
        [_scrollView bringSubviewToFront:item];
    }
    
    [self setNeedsLayout];
    
    if ([_delegate respondsToSelector:@selector(flowView:didAppearViewAtIndex:)])
        [_delegate flowView:self didAppearViewAtIndex:index];
}

- (void)_refreshFlowView
{    
    [self _removeActiveItems];
    
    NSInteger firstUpdatingIndex = _selectedViewIndex-1;
    
    NSInteger viewsToShow = 3;
    
    if (_selectedViewIndex == 0) {
        viewsToShow--;
        firstUpdatingIndex = _selectedViewIndex;
    }
    
    if (_selectedViewIndex == _numberOfItems-1)
        viewsToShow--;
    
    [self _commitCurrentDisplayedItemsFromIndex:firstUpdatingIndex toIndex:firstUpdatingIndex+viewsToShow-1];
    
    [_scrollView setContentOffset:[self _offsetForViewAtIndex:_selectedViewIndex] animated:NO];
}

- (void)_commitCurrentDisplayedItemsFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{    
    if (fromIndex<0) fromIndex = 0;
    if (fromIndex>=_numberOfItems) fromIndex = _numberOfItems-1;
    if (toIndex<0) toIndex = 0;
    if (toIndex>=_numberOfItems) toIndex = _numberOfItems-1;
    
    if (toIndex == -1 || fromIndex == -1) {
        // Nothing to display
        return;
    }
    
    for (NSInteger index=fromIndex; index<=toIndex; ++index) {
        NSNumber *idx = [NSNumber numberWithInteger:index];
        
        if (![_activeItems.allKeys containsObject:idx]) {     // ???? ( genera i compara un array a cada iteracio!, utilitzar objectForKey: )
            SWFlowViewItem *item = [self _getItem];

            item.contentView = [self.dataSource flowView:self contentForViewAtIndex:index];
            
            [self _deployItem:item atIndex:index];
        }
    }
        
    if ([_activeItems.allKeys containsObject:[NSNumber numberWithInteger:fromIndex-1]]) {   // ???? Utilitzar objecttForKey !
        [self _undeployItemAtIndex:fromIndex-1];
    }
    
    if ([_activeItems.allKeys containsObject:[NSNumber numberWithInteger:toIndex+1]]) {  // ???? Utilitzar objecttForKey !
        [self _undeployItemAtIndex:toIndex+1];
    }
    
    SWFlowViewItem *centerItem = [_activeItems objectForKey:[NSNumber numberWithInteger:_selectedViewIndex]];
    [_scrollView bringSubviewToFront:centerItem];
}

- (void)_updateSelectedViewWithViewIndex:(NSInteger)index
{
    if (index != _selectedViewIndex && index <_numberOfItems) {
        _selectedViewIndex = index;
        _pageControl.currentPage = _selectedViewIndex;
        [self _updateLabelsForSelectedView];
    }
}

- (void)_updateLabelsForSelectedView
{
    CGRect bounds = self.bounds;
    
    _titleLabel.text = [self.dataSource flowView:self titleForViewAtIndex:_selectedViewIndex];
    [_titleLabel sizeToFit];
    
    CGRect titleLabelFrame = _titleLabel.frame;
    
    _titleLabel.frame = CGRectMake(bounds.size.width/2.0 - titleLabelFrame.size.width/2.0, 30, 
                                   titleLabelFrame.size.width, titleLabelFrame.size.height);
    
    _subtitleLabel.text = [self.dataSource flowView:self subtitleForViewAtIndex:_selectedViewIndex];
    [_subtitleLabel sizeToFit];
    
    CGRect subTitleLabelFrame = _subtitleLabel.frame;
    
    _subtitleLabel.frame = CGRectMake(bounds.size.width/2.0 - subTitleLabelFrame.size.width/2.0, 75, 
                                      subTitleLabelFrame.size.width, subTitleLabelFrame.size.height);

}

- (void)_insertItem:(SWFlowViewItem*)item atIndex:(NSInteger)index animation:(SWFlowViewAnimation)animation
{
    // TODO: Switch between the diferent animations
    // TODO: Animate correctly (should move current displayed items) when deploying an item
    
    [UIView animateWithDuration:0.25 
                     animations:^{
                         
                         NSMutableDictionary *movingItems = [NSMutableDictionary dictionary];
                         
                         for (NSNumber *idx in _activeItems.allKeys) {   // ???? utilitzar directament _activeItems !
                             NSInteger currentIndex = idx.integerValue;
                             
                             if (currentIndex>=index) {
                                 SWFlowViewItem *it = [_activeItems objectForKey:idx];
                                 [movingItems setObject:it forKey:[NSNumber numberWithInt:currentIndex+1]];
                                 [_activeItems removeObjectForKey:idx];
                                 
                                 CGRect frame = it.frame;
                                 frame.origin = [self _positionForViewAtIndex:currentIndex+1];
                                 it.frame = frame;
                             }
                         }
                         
                         [_activeItems addEntriesFromDictionary:movingItems];
                         
                     } completion:^(BOOL finished1) {
                         
                         item.alpha = 0;
                         
                         [self _deployItem:item atIndex:index];
                         
                         [UIView animateWithDuration:0.25 
                                          animations:^{
                                              item.alpha = 1; 
                                          } completion:^(BOOL finished2) {
                                              [self _commitCurrentDisplayedItemsFromIndex:_selectedViewIndex-1 toIndex:_selectedViewIndex+1];
                                          }];
                     }];
}

- (void)_deleteItem:(SWFlowViewItem*)item atIndex:(NSInteger)index animation:(SWFlowViewAnimation)animation
{
    if (index > _selectedViewIndex +1 || index < _selectedViewIndex -1) {
        NSLog(@"[WARNING] [bk5j90]");
        return;
    }
    
//    NSInteger requestedIndex;
//    
//    if (index < _selectedViewIndex) {    
//        requestedIndex = _selectedViewIndex - 2;        
//    } else if (index >= _selectedViewIndex) {
//        requestedIndex = _selectedViewIndex + 2;
//    }
//    
//    requestedIndex--;
//    if (requestedIndex<_numberOfItems) {
//        SWFlowViewItem *auxItem = [self _getItem];
//        auxItem.contentView = [self.dataSource flowView:self contentForViewAtIndex:requestedIndex];
//        [self _deployItem:item atIndex:requestedIndex];
//    }
    
    // Perform the animations and deletion of the requested item
    [UIView animateWithDuration:0.25 
                     animations:^{
                         item.alpha = 0; 
                     } completion:^(BOOL finished1) {
                         
                         [self _undeployItemAtIndex:index];
                         
                         [UIView animateWithDuration:0.25 
                                          animations:^{
                                              
                                              NSMutableDictionary *movingItems = [NSMutableDictionary dictionary];
                                              
                                              for (NSNumber *idx in _activeItems.allKeys) {    // ???? utilitzar directament _activeItems !
                                                  NSInteger currentIndex = idx.integerValue;
                                                  
                                                  if (currentIndex>=index) {
                                                      SWFlowViewItem *it = [_activeItems objectForKey:idx];
                                                      [movingItems setObject:it forKey:[NSNumber numberWithInt:currentIndex-1]];
                                                      [_activeItems removeObjectForKey:idx];
                                                      
                                                      CGRect frame = it.frame;
                                                      frame.origin = [self _positionForViewAtIndex:currentIndex-1];
                                                      it.frame = frame;
                                                  }
                                              }
                                              
                                              [_activeItems addEntriesFromDictionary:movingItems];
                                              
                                          } completion:^(BOOL finished2) {
                                              
                                              if (_selectedViewIndex >= _numberOfItems) {
                                                  if (_numberOfItems > 0) {
                                                      _selectedViewIndex = _numberOfItems - 1;
                                                      [_scrollView setContentOffset:[self _offsetForViewAtIndex:_selectedViewIndex] animated:YES];
                                                  }
                                              }
                                              
                                          }];
                     }];
}


@end
