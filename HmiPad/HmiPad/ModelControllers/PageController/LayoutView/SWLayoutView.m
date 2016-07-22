//
//  SWLayoutView.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/26/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWLayoutView.h"
#import "SWLayoutViewCell.h"
#import "SWLayoutOverlayView.h"
#import "SWLayoutOverlayCoordinatorView.h"

#import "NSMutableSet+Additions.h"
#import "CGGeometry+Additions.h"
#import "NSString+Additions.h"
#import "NSIndexSet+Additions.h"
#import "NSSet+Additions.h"

#import <QuartzCore/QuartzCore.h>


typedef enum {
    SWLayoutViewRulerTypeNone = 0,
    SWLayoutViewRulerTypeTop = 1<<0,
    SWLayoutViewRulerTypeBottom = 1<<1,
    SWLayoutViewRulerTypeRight = 1<<2,
    SWLayoutViewRulerTypeLeft = 1<<3,
    SWLayoutViewRulerTypeCenterVertical = 1<<4,
    SWLayoutViewRulerTypeCenterHorizontal = 1<<5
} SWLayoutViewRulerType;



//@protocol SWLayoutViewRulerCell
//@property (nonatomic) BOOL selected;
//
//@end




#pragma mark SWLayoutViewRuler

@interface SWLayoutViewRuler : NSObject

@property (nonatomic, readonly, assign) SWLayoutViewRulerType mask;
@property (nonatomic, readonly, strong) SWLayoutViewCell *cell;
@property (nonatomic, readonly, strong) SWLayoutViewCell *referenceCell;

+ (SWLayoutViewRuler*)layoutViewRulerWithMask:(SWLayoutViewRulerType)mask andCell:(UIView*)cell andReferenceCell:(UIView*)referenceCell;
+ (NSData*)rulersForMask:(SWLayoutViewRulerType)mask forFrame:(CGRect)frame andReferenceFrame:(CGRect)referenceFrame;

- (id)initWithMask:(SWLayoutViewRulerType)mask andCell:(UIView*)cell andReferenceCell:(UIView*)referenceCell;

- (NSData*)rulers;
- (NSInteger)numberOfRulers;

+ (NSArray*)intersectionOfRulers:(NSArray*)rulers1 withRulers:(NSArray*)rulers2;

@end

@implementation SWLayoutViewRuler
@synthesize mask = _mask;
@synthesize cell = _cell;
@synthesize referenceCell = _referenceCell;

+ (SWLayoutViewRuler*)layoutViewRulerWithMask:(SWLayoutViewRulerType)mask andCell:(UIView*)cell andReferenceCell:(UIView*)referenceCell
{
    SWLayoutViewRuler *ruler = [[SWLayoutViewRuler alloc] initWithMask:mask andCell:cell andReferenceCell:referenceCell];
    return ruler;
}

+ (NSData*)rulersForMask:(SWLayoutViewRulerType)mask forFrame:(CGRect)frame andReferenceFrame:(CGRect)referenceFrame
{
    NSMutableData *rulers = [NSMutableData data];
        
    CGPoint point1, point2;
    
    size_t rulerSize = sizeof(SWRuler);
    
    CGPoint point11 = frame.origin;
    CGPoint point12 = CGPointMake(frame.origin.x + frame.size.width, frame.origin.y + frame.size.height);
    CGPoint point21 = referenceFrame.origin;
    CGPoint point22 = CGPointMake(referenceFrame.origin.x + referenceFrame.size.width, referenceFrame.origin.y + referenceFrame.size.height);
    
    CGFloat pixelOffset = 0.5;
    
    if (mask & SWLayoutViewRulerTypeTop)
    {
        point1 = CGPointMake(MIN(point11.x, point21.x), referenceFrame.origin.y - pixelOffset);
        point2 = CGPointMake(MAX(point12.x, point22.x), referenceFrame.origin.y - pixelOffset);
        
        SWRuler ruler = SWRulerMake(point1, point2);
        [rulers appendBytes:&ruler length:rulerSize];
    }
    
    if (mask & SWLayoutViewRulerTypeBottom)
    {
        point1 = CGPointMake(MIN(point11.x, point21.x), referenceFrame.origin.y + referenceFrame.size.height + pixelOffset);
        point2 = CGPointMake(MAX(point12.x, point22.x), referenceFrame.origin.y + referenceFrame.size.height + pixelOffset);
        
        SWRuler ruler = SWRulerMake(point1, point2);
        [rulers appendBytes:&ruler length:rulerSize];
    }
    
    if (mask & SWLayoutViewRulerTypeCenterHorizontal)
    {
        
        CGFloat y = referenceFrame.origin.y + referenceFrame.size.height/2.0;
        
        if (((int)referenceFrame.size.height)%2 == 0)
            y += pixelOffset;
        
        point1 = CGPointMake(MIN(point11.x, point21.x), y);
        point2 = CGPointMake(MAX(point12.x, point22.x), y);
        
        SWRuler ruler = SWRulerMake(point1, point2);
        [rulers appendBytes:&ruler length:rulerSize];
    }
    
    if (mask & SWLayoutViewRulerTypeLeft)
    {
        point1 = CGPointMake(referenceFrame.origin.x - pixelOffset, MIN(point11.y, point21.y));
        point2 = CGPointMake(referenceFrame.origin.x - pixelOffset, MAX(point12.y, point22.y));
        
        SWRuler ruler = SWRulerMake(point1, point2);
        [rulers appendBytes:&ruler length:rulerSize];
    }
    
    if (mask & SWLayoutViewRulerTypeRight)
    {
        point1 = CGPointMake(referenceFrame.origin.x + referenceFrame.size.width + pixelOffset, MIN(point11.y, point21.y));
        point2 = CGPointMake(referenceFrame.origin.x + referenceFrame.size.width + pixelOffset, MAX(point12.y, point22.y));
        
        SWRuler ruler = SWRulerMake(point1, point2);
        [rulers appendBytes:&ruler length:rulerSize];
    }
    
    if (mask & SWLayoutViewRulerTypeCenterVertical)
    {    
        CGFloat x = referenceFrame.origin.x + referenceFrame.size.width/2.0;
        
        if (((int)referenceFrame.size.width)%2 == 0)
            x += pixelOffset;
        
        point1 = CGPointMake(x, MIN(point11.y, point21.y));
        point2 = CGPointMake(x, MAX(point12.y, point22.y));
        
        SWRuler ruler = SWRulerMake(point1, point2);
        [rulers appendBytes:&ruler length:rulerSize];
    }
    
    return rulers;
   // return [rulers copy];
}


- (id)init
{
    return [self initWithMask:SWLayoutViewRulerTypeNone andCell:nil andReferenceCell:nil];
}


- (id)initWithMask:(SWLayoutViewRulerType)mask andCell:(SWLayoutViewCell*)cell andReferenceCell:(SWLayoutViewCell*)referenceCell
{
    self = [super init];
    if (self)
    {
        _mask = mask;
        _cell = cell;
        _referenceCell = referenceCell;
    }
    return self;
}


- (BOOL)selected
{
    return NO;
}

- (NSInteger)numberOfRulers
{
    NSInteger count = 0;
    NSInteger maskCopy = _mask;
    for (int i=0; i<32; ++i)
    {
        if (maskCopy & 1<<i)
            count++;
    }
    return count;
}


- (NSData*)rulers
{
    CGRect itemFrame = _cell.frame;
    CGRect referenceItemFrame = _referenceCell.frame;
    
    return [SWLayoutViewRuler rulersForMask:_mask forFrame:itemFrame andReferenceFrame:referenceItemFrame];
}


- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]])
    {
        SWLayoutViewRuler *ruler = (SWLayoutViewRuler*)object;
        
        if (ruler.mask != _mask)
            return NO;
        
        SWLayoutViewCell *rulerCell = ruler.cell;
        SWLayoutViewCell *rulerReferenceCell = ruler.referenceCell;
        
        if ((rulerCell == _cell && rulerReferenceCell == _referenceCell) ||
            (rulerCell == _referenceCell && rulerReferenceCell == _cell))
            return YES;
    }
    
    return NO;
}


+ (NSArray*)intersectionOfRulers:(NSArray*)rulers1 withRulers:(NSArray*)rulers2
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (SWLayoutViewRuler *ruler1 in rulers1)
    {
        for (SWLayoutViewRuler *ruler2 in rulers2)
        {    
            BOOL sameCells = NO;
            
            if ((ruler1.cell == ruler2.cell && ruler1.referenceCell == ruler2.referenceCell) ||
                (ruler1.cell == ruler2.referenceCell && ruler1.referenceCell == ruler2.cell))
                sameCells = YES;
            
            if (sameCells)
            {
                SWLayoutViewRulerType mask = ruler1.mask & ruler2.mask;
                if (mask != SWLayoutViewRulerTypeNone)
                {
                    SWLayoutViewRuler *ruler = [[SWLayoutViewRuler alloc] initWithMask:mask andCell:ruler1.cell andReferenceCell:ruler1.referenceCell];
                    [array addObject:ruler];
                }
            }
        }
    }
    
    return [array copy];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"<%@: 0x%x: mask = %@; cell = 0x%x; referenceCell = 0x%x;>",[self.class description],(int)self,[NSString stringWithBitsOfInteger:_mask],(int)_cell,(int)_referenceCell];
}

@end


#pragma mark SWLayoutView

#define RulerProximityNone 0.01

@interface SWLayoutView()<SWLayoutOverlayViewDataSource,SWLayoutOverlayViewDelegate/*,SWLayoutResizerViewDelegate*/>
{
    NSMutableArray *_cells;
    SWLayoutViewCell *_lastSelectedCell;
    NSMutableSet *_coveredCells;
    SWLayoutOverlayView *_layoutOverlayView;
}
@end



@implementation SWLayoutView 


- (void)_doInit
{
    _cells = [NSMutableArray array];
    _coveredCells = [NSMutableSet set];

    _autoAlignmentProximity = 8;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self _doInit];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self _doInit];
    }
    return self;
}


#pragma mark - Properties

- (void)setLayoutOverlayView:(SWLayoutOverlayView *)layoutOverlayView
{
    _layoutOverlayView = layoutOverlayView;
    
    _layoutOverlayView.phoneIdiomRulerSize = _phoneIdiomRulerSize;
    _layoutOverlayView.isBottomPosition = _isBottomPosition;
    
    [self _reloadOverlayData];
}


- (void)setEditMode:(BOOL)editing
{
    _editMode = editing;
    //_layoutOverlayView.editMode = editing;
    for ( SWLayoutViewCell *cell in _cells )
        [cell reloadLayoutSettings];
}


- (void)setShowsErrorFramesInEditMode:(BOOL)showsErrorFramesInEditMode
{
    _showsErrorFramesInEditMode = showsErrorFramesInEditMode;
    for ( SWLayoutViewCell *cell in _cells )
        [cell reloadLayoutSettings];
}


- (void)setShowsHiddenItemsInEditMode:(BOOL)showsHiddenItemsInEditMode
{
    _showsHiddenItemsInEditMode = showsHiddenItemsInEditMode;
    for ( SWLayoutViewCell *cell in _cells )
        [cell reloadLayoutSettings];
}


//- (void)setPhoneIdiomRulerPosition:(CGFloat)phoneIdiomRulerPosition
//{
//    _phoneIdiomRulerPosition = phoneIdiomRulerPosition;
//    [_layoutOverlayView setPhoneIdiomRulerPosition:phoneIdiomRulerPosition];
//}

- (void)setPhoneIdiomRulerSize:(CGSize)phoneIdiomRulerSize
{
    _phoneIdiomRulerSize = phoneIdiomRulerSize;
    [_layoutOverlayView setPhoneIdiomRulerSize:phoneIdiomRulerSize];
}


- (void)setConstrainToRulerPosition:(BOOL)constrainToRulerPosition
{
    _constrainToRulerPosition = constrainToRulerPosition;
    [self setNeedsLayout];
}


- (void)setIsBottomPosition:(BOOL)isBottomPosition
{
    _isBottomPosition = isBottomPosition;
    _layoutOverlayView.isBottomPosition = isBottomPosition;
}

- (void)setZoomScaleFactor:(CGFloat)zoomScaleFactor
{
    for ( SWLayoutViewCell *cell in _cells )
    {
        [cell setZoomScaleFactor:zoomScaleFactor];
    }
}


#pragma mark - Getters

- (SWLayoutViewCell*)cellAtIndex:(NSInteger)index
{
    if (index < 0 || index >= _cells.count)
        return nil;
    
    return [_cells objectAtIndex:index];
}


- (NSInteger)_indexOfCellAtPoint:(CGPoint)point VVinView:(UIView*)view
{
    NSInteger count = _cells.count;
    
    for (NSInteger i=0; i<count ; ++i)
    {
        NSInteger reverseIndex = count - i - 1;
        SWLayoutViewCell *cell = [_cells objectAtIndex:reverseIndex];
        CGPoint finalPoint = [cell convertPoint:point fromView:view];
        
        if ([cell pointInside:finalPoint withEvent:nil])
            return reverseIndex;
    }
    
    return NSNotFound;
}


- (NSInteger)_indexOfCellAtPoint:(CGPoint)point inView:(UIView*)view opaque:(BOOL)opaque
{
    NSInteger count = _cells.count;
    
    for (NSInteger i=0; i<count ; ++i)
    {
        NSInteger reverseIndex = count - i - 1;
        SWLayoutViewCell *cell = [_cells objectAtIndex:reverseIndex];
        CGPoint finalPoint = [cell convertPoint:point fromView:view];
        
        if ( opaque )
            return CGRectContainsPoint(cell.bounds, finalPoint);
        
        else if ( [cell pointInside:finalPoint withEvent:nil] )
            return reverseIndex;
    }
    
    return NSNotFound;
}


- (SWLayoutViewCell*)_cellAtPoint:(CGPoint)point opaque:(BOOL)opaque
{
    SWLayoutViewCell *cell = nil;
    NSInteger index = [self _indexOfCellAtPoint:point inView:self opaque:opaque];
    
    if ( index!=NSNotFound)
        cell = [_cells objectAtIndex:index];

    return cell;
}


- (NSArray*)cells
{
    return _cells;
}

#pragma mark - Reloading Data


- (void)reloadDataAnimated:(BOOL)animated
{
    [self _undeployCells:_cells animation:SWLayoutViewViewAnimationNone completion:nil];
    
    [_cells removeAllObjects];
    
    NSInteger size = [_dataSource numberOfCellsForlayoutView:self];
    
    for (NSInteger i=0; i<size; ++i)
    {
        SWLayoutViewCell *cell = [_dataSource layoutView:self layoutViewCellAtIndex:i];
        cell.frame = [_dataSource layoutView:self frameForCellAtIndex:i];
        [_cells addObject:cell];
        [self _prepareForDeploymentCellAtIndex:i];

        if (cell.enabled)
        {
            SWLayoutView *contentLayoutView = cell.contentLayoutView;
            if ( contentLayoutView )
                [_layoutOverlayCoordinatorView addLayoutViewLayer:contentLayoutView];
        }
    }
    
    SWLayoutViewViewAnimation animation = animated ? SWLayoutViewViewAnimationAppear : SWLayoutViewViewAnimationNone;
    
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, size)];
    [self _deployCells:_cells toIndexes:indexes animation:animation completion:^
    {
        [self _reloadOverlayData];
    }];
}


- (void)_reloadOverlayData
{
    [_layoutOverlayView unmarkAllAnimated:NO];
    
    NSMutableArray *lockedCells = [NSMutableArray array];
    NSMutableArray *selectCells = [NSMutableArray array];
    
    for ( SWLayoutViewCell *cell in _cells )
    {
        if (cell.locked)
            [lockedCells addObject:cell];
        
        if (cell.selected)
            [selectCells addObject:cell];
    }
    
    [self _doLockCells:lockedCells animated:NO];
    [self _doSelectCells:selectCells animated:NO];
}


- (void)reloadFrameForCell:(SWLayoutViewCell*)cell animated:(BOOL)animated
{
    void (^block)(void) = ^()
    {
        NSInteger idx = [_cells indexOfObjectIdenticalTo:cell];
        if ( idx != NSNotFound )
        {
            CGRect frame = [_dataSource layoutView:self frameForCellAtIndex:idx];
            cell.frame = frame;
            [_layoutOverlayView reloadOverlayFrameForCell:cell];
        }
    };
    
    if (animated)
        [UIView animateWithDuration:0.25 animations:block];
    else
        block();
}


- (void)reloadCellFramesAnimated:(BOOL)animated
{
    void (^block)(void) = ^()
    {
        NSInteger count = _cells.count;
        for ( NSInteger idx=0 ; idx<count ; idx++ )
        {
            SWLayoutViewCell *cell = [_cells objectAtIndex:idx];
            CGRect frame = [_dataSource layoutView:self frameForCellAtIndex:idx];
            cell.frame = frame;
            //if ( idx == 0 ) [self layoutSubviews];
        }
    };
    
    if (animated)
    {
        //[self setSelectionHidden:YES];
        [_layoutOverlayCoordinatorView setSelectionHidden:YES];
        [UIView animateWithDuration:0.25 animations:block completion:^(BOOL finished)
        {
            //[self setSelectionHidden:NO];
            [_layoutOverlayCoordinatorView setSelectionHidden:NO];
        }];
    }
    else
    {
        block();
    }
    
    //[_layoutOverlayView reloadOverlayFrames];
}


- (void)reloadOverlayFrames
{
    [_layoutOverlayView reloadOverlayFrames];
}


#pragma mark - Insertion & Deletion

- (void)insertCellsAtIndexes:(NSIndexSet*)indexes withAnimation:(SWLayoutViewViewAnimation)animation
    willAppear:(void (^)())willAppear didAppear:(void (^)())didAppear
{
    NSInteger newSize = [_dataSource numberOfCellsForlayoutView:self];
    
    if (newSize != _cells.count + indexes.count)
    {
        NSException *e = [NSException exceptionWithName:NSInternalInconsistencyException
                                                 reason:[NSString stringWithFormat:@"The number while inserting doesn't fit the expected size. Requesting to add %lu elements to %lu existing ones (%lu total expected), but found %ld through data source.", (unsigned long)indexes.count, (unsigned long)_cells.count, (long)indexes.count+_cells.count, (long)newSize]
                                               userInfo:[NSDictionary dictionary]];
        [e raise];
    }
    
    NSMutableArray *cells = [NSMutableArray array];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        SWLayoutViewCell *cell = [_dataSource layoutView:self layoutViewCellAtIndex:idx];
        
        cell.frame = [_dataSource layoutView:self frameForCellAtIndex:idx];
        
        [cells addObject:cell];
        [_cells insertObject:cell atIndex:idx]; 
        [self _prepareForDeploymentCellAtIndex:idx];
    }];
    
    if ( willAppear )
        willAppear();
    
    [self _deployCells:cells toIndexes:indexes animation:animation completion:^
    {
        if (didAppear)
            didAppear();
    }];
}


- (void)deleteCellsAtIndexes:(NSIndexSet*)indexes withAnimation:(SWLayoutViewViewAnimation)animation
    willDisappear:(void (^)())willDisappear didDisappear:(void (^)())didDisappear
{
    NSInteger newSize = [_dataSource numberOfCellsForlayoutView:self];
        
    if (newSize + indexes.count != _cells.count)
    {
        NSException *e = [NSException exceptionWithName:NSInternalInconsistencyException 
                                                 reason:[NSString stringWithFormat:@"The number while deleting doesn't fit the expected size. Requesting to delete %lu elements to %lu existing ones (%lu total expected), but found %ld through data source.", (unsigned long)indexes.count, (unsigned long)_cells.count, (long)_cells.count - indexes.count, (long)newSize]
                                               userInfo:[NSDictionary dictionary]];
        [e raise];
    }
    
    if ( willDisappear )
        willDisappear();
    
    NSArray *cells = [_cells objectsAtIndexes:indexes];

    [self _doDeselectCells:cells animated:NO];
    [self _doUnlockCells:cells animated:NO];
    
    [_cells removeObjectsAtIndexes:indexes];
    
    [self _undeployCells:cells animation:animation completion:^
    {
        if(didDisappear)
            didDisappear();
    }];
}


#pragma mark - Selection


- (void)performSelectionAtPoint:(CGPoint)point
{
    NSInteger index = [self _indexOfCellAtPoint:point inView:self opaque:NO];
    if ( index != NSNotFound )
    {
        BOOL shouldSelect = YES;
        if ( [_delegate respondsToSelector:@selector(layoutView:shouldSelectCellAtIndex:)] )
            shouldSelect = [_delegate layoutView:self shouldSelectCellAtIndex:index];
    
        if ( shouldSelect)
            if ( [_delegate respondsToSelector:@selector(layoutView:didSelectCellsAtIndexes:)] )
                [_delegate layoutView:self didSelectCellsAtIndexes:[NSIndexSet indexSetWithIndex:index]];
    }
}


- (void)selectCellsAtIndexes:(NSIndexSet *)indexes animated:(BOOL)animated
{
    NSMutableArray *selectCells = [NSMutableArray array];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        SWLayoutViewCell *cell = [_cells objectAtIndex:idx];
        
        if (!cell.selected)
            [selectCells addObject:cell];
    }];
    
    if (selectCells.count > 0)
        [self _doSelectCells:selectCells animated:animated];
}


- (void)deselectCellsAtIndexes:(NSIndexSet *)indexes animated:(BOOL)animated
{
    NSMutableArray *selectedCells = [NSMutableArray array];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        SWLayoutViewCell *cell = [_cells objectAtIndex:idx];
        
        if (cell.selected)
            [selectedCells addObject:cell];
    }];
    
    if (selectedCells.count > 0)
        [self _doDeselectCells:selectedCells animated:animated];
}


- (void)setEnabledStateTo:(BOOL)state forCellAtIndex:(NSInteger)index
{
    SWLayoutViewCell *cell = [_cells objectAtIndex:index];
    [self _doSetEnabledState:state forCell:cell];
}


- (void)lockCellsAtIndexes:(NSIndexSet *)indexes animated:(BOOL)animated
{
    NSMutableArray *lockCells = [NSMutableArray array];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        SWLayoutViewCell *cell = [_cells objectAtIndex:idx];
        
        if (!cell.locked)
            [lockCells addObject:cell];
    }];
    
    if (lockCells.count > 0)
        [self _doLockCells:lockCells animated:animated];
}


- (void)unlockCellsAtIndexes:(NSIndexSet *)indexes animated:(BOOL)animated
{
    NSMutableArray *lockedCells = [NSMutableArray array];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        SWLayoutViewCell *cell = [_cells objectAtIndex:idx];
        
        if (cell.locked)
            [lockedCells addObject:cell];
    }];
    
    if (lockedCells.count > 0)
        [self _doUnlockCells:lockedCells animated:animated];
}


#pragma mark - Content scale

- (void)setContentScaleFactor:(CGFloat)contentScaleFactor
{
    // posem el contentScaleFactor dels subviews inmediats
    [super setContentScaleFactor:contentScaleFactor];
    
    //[_cellsContainer setContentScaleFactor:contentScaleFactor];
    
    for ( SWLayoutViewCell *cell in _cells )
        [cell setContentScaleFactor:contentScaleFactor]; 
    
    [_layoutOverlayView setContentScaleFactor:contentScaleFactor];
}


// #pragma mark - Covering

//- (NSIndexSet*)coveredCells
//{
//    return [_coveredCells indexesOfObjectsInArray:_cells];
//}
//
//- (void)coverCellsAtIndexes:(NSIndexSet*)indexes withColors:(NSArray*)colors
//{
//    __block NSInteger i = 0;
//    
//    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
//    {
//        SWLayoutViewCell *cell = [self cellAtIndex:idx];
//        UIColor *color = [colors objectAtIndex:i];
//        cell.coverTintColor = color;
//        [_coveredCells addObject:cell];
//        ++i;
//    }];
//}
//
//- (void)decoverCellsAtIndexes:(NSIndexSet*)indexes
//{
//    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
//    {
//        SWLayoutViewCell *cell = [self cellAtIndex:idx];
//        
//        if (cell == nil) 
//            return;
//        
//        cell.coverTintColor = nil;
//        [_coveredCells removeObject:cell];
//    }];
//}
//
//- (NSArray*)coverColorsForCellsAtIndexes:(NSIndexSet*)indexes
//{
//    NSMutableArray *array = [NSMutableArray array];
//    
//    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
//    {
//        SWLayoutViewCell *cell = [self cellAtIndex:idx];
//        UIColor *color = cell.coverTintColor;
//    
//        if (color)
//            [array addObject:color];
//        else
//            [array addObject:[NSNull null]];
//    }];
//    
//    return array;
//}

#pragma mark - Views hierarcy

- (void)sendToBackCellAtIndex:(NSInteger)index
{
    SWLayoutViewCell *cell = [_cells objectAtIndex:index];
    
    [_cells removeObjectIdenticalTo:cell];
    [_cells insertObject:cell atIndex:0];
    
    //[_cellsContainer sendSubviewToBack:cell];
    [self sendSubviewToBack:cell];
}


- (void)bringToFrontCellAtIndex:(NSInteger)index
{
    SWLayoutViewCell *cell = [_cells objectAtIndex:index];
    
    [_cells removeObjectAtIndex:index];
    [_cells addObject:cell];
    
//    [_cellsContainer bringSubviewToFront:cell];
    [self bringSubviewToFront:cell];
}


- (void)sendCellAtIndex:(NSInteger)index toZPosition:(NSInteger)position
{
    SWLayoutViewCell *cell = [_cells objectAtIndex:index];
    
    [_cells removeObjectAtIndex:index];
    [_cells insertObject:cell atIndex:position];
    
    [cell removeFromSuperview];
        
//    [_cellsContainer insertSubview:cell atIndex:position];
    [self insertSubview:cell atIndex:position];
}


- (void)exchangeCellAtIndex:(NSInteger)index1 withCellAtIndex:(NSInteger)index2
{
    SWLayoutViewCell *cell1 = [_cells objectAtIndex:index1];
    SWLayoutViewCell *cell2 = [_cells objectAtIndex:index2];
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndex:index1];
    [indexSet addIndex:index2];
    [_cells removeObjectsAtIndexes:indexSet];
    
    if (index1 < index2)
    {
        [_cells insertObject:cell2 atIndex:index1];
        [_cells insertObject:cell1 atIndex:index2];
    }
    else
    {
        [_cells insertObject:cell1 atIndex:index2];
        [_cells insertObject:cell2 atIndex:index1];
    }
    
//    [_cellsContainer exchangeSubviewAtIndex:index1 withSubviewAtIndex:index2];
    [self exchangeSubviewAtIndex:index1 withSubviewAtIndex:index2];
}





#pragma mark - Private Methods

- (NSArray*)_autoalignCellV:(SWLayoutViewCell*)cell atFrame:(CGRect)frame newFrame:(CGRect*)newFrame eventType:(SWLayoutViewCellEventType)eventType
{    
    CGFloat proximity = _autoAlignmentProximity;
    if ( eventType & SWLayoutViewCellEventTypeZeroProximity ) proximity = RulerProximityNone;
    
    // --- Creating the "will" frame of the cell -- //    
    CGRect cellFrame = frame;
    CGPoint cellOrigin = frame.origin;
    CGSize cellSize = frame.size;
    
    // --- Creating reference points for the current cell --- //
    CGPoint topLeft = CGPointTopLeft(cellFrame);
    CGPoint bottomRight = CGPointBottomRight(cellFrame);
    CGPoint center = CGPointCenter(cellFrame);
    
    // --- Suport data Structures --- //
    NSMutableData *offsetsH = [NSMutableData data];
    NSMutableData *offsetsV = [NSMutableData data];
    
    NSMutableData *autoalignOriginH = [NSMutableData data];
    NSMutableData *autoalignOriginV = [NSMutableData data];
    
    NSMutableData *autoalignSizeH = [NSMutableData data];
    NSMutableData *autoalignSizeV = [NSMutableData data];
    
    NSMutableArray *rulersH = [NSMutableArray array];
    NSMutableArray *rulersV = [NSMutableArray array];
    
    NSMutableArray *auxiliarResizingRulers = [NSMutableArray array];
    
//    NSArray *selectedCells = [_cells objectsAtIndexes:[self selectedCellsIndexes]];
    
    // --- Let's iterate all cells --- //
    for (SWLayoutViewCell *referenceCell in _cells)
    {    
        // --- Avoid to make autoalignments to the same current cell -- //
        if (referenceCell == cell)
            continue;
        
        // No fem apareixer rulers de celdes que estem també operant ni tampoc ens hi aliniem
        if ( referenceCell.selected )   // JLZ
            continue;
        
        // -- Creating reference points for the referenceCell --- //
        CGRect referenceCellFrame = referenceCell.frame;
        CGSize refSize = referenceCellFrame.size;
        
        CGPoint refTopLeft = CGPointTopLeft(referenceCellFrame);
        CGPoint refBottomRight = CGPointBottomRight(referenceCellFrame);
        CGPoint refCenter = CGPointCenter(referenceCellFrame);
        
        // --- Getting the offsets to compute if may create a ruler --- //
        CGFloat topOffset = topLeft.y - refTopLeft.y;
        CGFloat centerHOffset = center.y - refCenter.y;
        CGFloat bottomOffset = bottomRight.y - refBottomRight.y;
        CGFloat leftOffset = topLeft.x - refTopLeft.x;
        CGFloat centerVOffset = center.x - refCenter.x;
        CGFloat rightOffset = bottomRight.x - refBottomRight.x;
        
        CGFloat factor = eventType & SWLayoutViewCellEventTypeButtons?2.0:1.0;
        centerHOffset *= factor;
        centerVOffset *= factor;
                
        // --- Computing Ruler Types --- //
        
        // -- Horizontal Rulers -- //
        SWLayoutViewRulerType rulerH = SWLayoutViewRulerTypeNone;
        CGFloat smallestOffsetH = CGFLOAT_MAX;
        CGFloat autoalignOriginY = cellOrigin.y;
        CGFloat autoalignHeight = cellSize.height;
        
        // - Top - //
        if (fabsf(topOffset) < proximity)
        {
            if (fabsf(topOffset) < fabsf(smallestOffsetH))
            {
                if (eventType & SWLayoutViewCellEventTypeInsideZeroProximity)
                {
                    smallestOffsetH = topOffset;
                    rulerH = SWLayoutViewRulerTypeTop;
                    autoalignOriginY = refTopLeft.y;
                    
                }
                else if (eventType & SWLayoutViewCellEventTypeTop)
                {
                    smallestOffsetH = topOffset;
                    rulerH = SWLayoutViewRulerTypeTop;
                    autoalignOriginY = refTopLeft.y;
                    autoalignHeight = cellSize.height - (refTopLeft.y - topLeft.y);
                }
            }
            else if (topOffset == smallestOffsetH)
            {
//                if (!(!(eventType & SWLayoutViewCellEventTypeTop)))
                    rulerH |= SWLayoutViewRulerTypeTop;
            }
        }
        
        // - Center Horizontal - //
        if (fabsf(centerHOffset) < proximity)
        {
            if (fabsf(centerHOffset) < fabsf(smallestOffsetH))
            {
                if (eventType & SWLayoutViewCellEventTypeInsideZeroProximity)
                {
                    smallestOffsetH = centerHOffset;
                    rulerH = SWLayoutViewRulerTypeCenterHorizontal;
                    //autoalignOriginY = refCenter.y - cellFrame.size.height/2.0;
                    autoalignOriginY = refCenter.y - cellSize.height/2.0;
                }
                else if ((eventType & SWLayoutViewCellEventTypeTopBottom))
                {
                    smallestOffsetH = centerHOffset;
                    rulerH = SWLayoutViewRulerTypeCenterHorizontal;
                    if (eventType & SWLayoutViewCellEventTypeTop)
                    {
                        autoalignHeight = 2*(topLeft.y + cellSize.height - refCenter.y);
                        autoalignOriginY = cellOrigin.y + cellSize.height - autoalignHeight;
                    }
                    else if (eventType & SWLayoutViewCellEventTypeBottom)
                    {
                        autoalignOriginY = cellOrigin.y;
                        autoalignHeight = 2*(refCenter.y - topLeft.y);
                    }
                }
            }
            else if (centerHOffset == smallestOffsetH)
            {
                rulerH |= SWLayoutViewRulerTypeCenterHorizontal;
            } 
        }
        
        // - Bottom - //
        if(fabsf(bottomOffset) < proximity)
        {
            if (fabsf(bottomOffset) < fabsf(smallestOffsetH))
            {
                if (eventType & SWLayoutViewCellEventTypeInsideZeroProximity)
                {
                    smallestOffsetH = bottomOffset;
                    rulerH = SWLayoutViewRulerTypeBottom;
                    //autoalignOriginY = refBottomRight.y - cellFrame.size.height;
                    autoalignOriginY = refBottomRight.y - cellSize.height;
                }
                else if ((eventType & SWLayoutViewCellEventTypeBottom))
                {
                    smallestOffsetH = bottomOffset;
                    rulerH = SWLayoutViewRulerTypeBottom;
                    autoalignOriginY = cellOrigin.y;
                    autoalignHeight = refSize.height - topLeft.y + refTopLeft.y; 
                } 
            }
            else if (bottomOffset == smallestOffsetH)
            {
//                if (!(!(eventType & SWLayoutViewCellEventTypeBottom)))
                    rulerH |= SWLayoutViewRulerTypeBottom;
            }
        }
        
        // -- Save horizontal the ruler if needed -- //
        if (rulerH != SWLayoutViewRulerTypeNone)
        {
            [offsetsH appendBytes:&smallestOffsetH length:sizeof(CGFloat)];
            [autoalignOriginH appendBytes:&autoalignOriginY length:sizeof(CGFloat)];
            [autoalignSizeH appendBytes:&autoalignHeight length:sizeof(CGFloat)];
            SWLayoutViewRuler *layoutViewRuler = [SWLayoutViewRuler layoutViewRulerWithMask:rulerH andCell:cell andReferenceCell:referenceCell];
            [rulersH addObject:layoutViewRuler];
        }
        
        // -- Vertical Rulers -- //
        SWLayoutViewRulerType rulerV = SWLayoutViewRulerTypeNone;
        CGFloat smallestOffsetV = CGFLOAT_MAX;
        CGFloat autoalignOriginX = cellOrigin.x;
        CGFloat autoalignWidth = cellSize.width;
        
        // - Left - //
        if (fabsf(leftOffset) < proximity)
        {
            if (fabsf(leftOffset) < fabsf(smallestOffsetV))
            {
                if (eventType & SWLayoutViewCellEventTypeInsideZeroProximity)
                {
                    smallestOffsetV = leftOffset;
                    rulerV = SWLayoutViewRulerTypeLeft;
                    autoalignOriginX = refTopLeft.x;
                }
                else if ((eventType & SWLayoutViewCellEventTypeLeft))
                {
                    smallestOffsetV = leftOffset;
                    rulerV = SWLayoutViewRulerTypeLeft;
                    autoalignOriginX = refTopLeft.x;
                    autoalignWidth = cellSize.width - (refTopLeft.x - topLeft.x);
                }
            }
            else if (leftOffset == smallestOffsetV)
            {
//                if (!(!(eventType & SWLayoutViewCellEventTypeLeft)))
                    rulerV |= SWLayoutViewRulerTypeLeft;
            } 
        }
        
        // - Center Vertical - //
        if (fabsf(centerVOffset) < proximity)
        {
            if (fabsf(centerVOffset) < fabsf(smallestOffsetV))
            {
                if (eventType & SWLayoutViewCellEventTypeInsideZeroProximity)
                {
                    smallestOffsetV = centerVOffset;
                    rulerV = SWLayoutViewRulerTypeCenterVertical;
                    //autoalignOriginX = refCenter.x - cellFrame.size.width/2.0;
                    autoalignOriginX = refCenter.x - cellSize.width/2.0;
                }
                else if ((eventType & SWLayoutViewCellEventTypeLeftRight))
                {
                    smallestOffsetV = centerVOffset;
                    rulerV = SWLayoutViewRulerTypeCenterVertical;
                    if (eventType & SWLayoutViewCellEventTypeLeft)
                    { // Resizing from LEFT
                        autoalignWidth = 2*(topLeft.x + cellSize.width - refCenter.x);
                        autoalignOriginX = cellOrigin.x + cellSize.width - autoalignWidth;
                    }
                    else if (eventType & SWLayoutViewCellEventTypeRight)
                    { // Resizing from RIGHT
                        autoalignOriginX = cellOrigin.x;
                        autoalignWidth = 2*((refTopLeft.x + refSize.width/2.0) - topLeft.x);
                    }
                }
            }
            else if (centerVOffset == smallestOffsetV)
            {
                rulerV |= SWLayoutViewRulerTypeCenterVertical;
            } 
        }
        
        // - Right - //
        if (fabsf(rightOffset) < proximity)
        {
            if (fabsf(rightOffset) < fabsf(smallestOffsetV))
            {
                if (eventType & SWLayoutViewCellEventTypeInsideZeroProximity)
                {
                    smallestOffsetV = rightOffset;
                    rulerV = SWLayoutViewRulerTypeRight;
                    //autoalignOriginX = refBottomRight.x - cellFrame.size.width;
                    autoalignOriginX = refBottomRight.x - cellSize.width;
                }
                else if ((eventType & SWLayoutViewCellEventTypeRight))
                {
                    smallestOffsetV = rightOffset;
                    rulerV = SWLayoutViewRulerTypeRight;
                    autoalignOriginX = cellOrigin.x;
                    autoalignWidth = refSize.width - topLeft.x + refTopLeft.x;
                }   
            }
            else if (rightOffset == smallestOffsetV)
            {
//                if (!(!(eventType & SWLayoutViewCellEventTypeRight)))
                    rulerV |= SWLayoutViewRulerTypeRight;
            }
        }
        
        // -- Save vertical the ruler if needed -- //
        if (rulerV != SWLayoutViewRulerTypeNone)
        {
            [offsetsV appendBytes:&smallestOffsetV length:sizeof(CGFloat)];
            [autoalignOriginV appendBytes:&autoalignOriginX length:sizeof(CGFloat)];
            [autoalignSizeV appendBytes:&autoalignWidth length:sizeof(CGFloat)];
            SWLayoutViewRuler *layoutViewRuler = [SWLayoutViewRuler layoutViewRulerWithMask:rulerV andCell:cell andReferenceCell:referenceCell];
            [rulersV addObject:layoutViewRuler];
        }
        
        // -- Getting auxiliar rulers for resizing -- //
        if (eventType & SWLayoutViewCellEventTypeButtons)
        {
            SWLayoutViewRulerType type = SWLayoutViewRulerTypeNone;
            
            if ((fabsf(topOffset) < RulerProximityNone))
                if (!(eventType & SWLayoutViewCellEventTypeTop))
                    type |= SWLayoutViewRulerTypeTop;
            
            if ((fabsf(bottomOffset) < RulerProximityNone)) 
                if (!(eventType & SWLayoutViewCellEventTypeBottom))
                    type |= SWLayoutViewRulerTypeBottom;
            
            if ((fabsf(centerHOffset) < RulerProximityNone)) 
                if (!(eventType & SWLayoutViewCellEventTypeTopBottom))
                    type |= SWLayoutViewRulerTypeCenterHorizontal;
            
            if ((fabsf(leftOffset) < RulerProximityNone)) 
                if (!(eventType & SWLayoutViewCellEventTypeLeft))
                    type |= SWLayoutViewRulerTypeLeft;
            
            if ((fabsf(rightOffset) < RulerProximityNone)) 
                if (!(eventType & SWLayoutViewCellEventTypeRight))
                    type |= SWLayoutViewRulerTypeRight;
            
            if ((fabsf(centerVOffset) < RulerProximityNone)) 
                if (!(eventType & SWLayoutViewCellEventTypeLeftRight))
                    type |= SWLayoutViewRulerTypeCenterVertical;

            // - Creating the ruler if needed - //
            if (type != SWLayoutViewRulerTypeNone)
            {
                SWLayoutViewRuler *ruler = [SWLayoutViewRuler layoutViewRulerWithMask:type andCell:cell andReferenceCell:referenceCell];
                [auxiliarResizingRulers addObject:ruler];
            }
        }
    }

    // --- Get the most close horizontal rule from all cells --- // 
    NSMutableIndexSet *indexesH = [NSMutableIndexSet indexSet];

    const NSInteger countH = offsetsH.length / sizeof(CGFloat);
    const CGFloat *c_offsetsH = [offsetsH bytes];
    CGFloat smallerOffsetH = CGFLOAT_MAX;
    
    for (NSInteger i=0; i<countH; ++i)
    {
        if (fabsf(c_offsetsH[i]) < fabsf(smallerOffsetH))
        {
            smallerOffsetH = c_offsetsH[i];
            [indexesH removeAllIndexes];
            [indexesH addIndex:i];
        }
        else if (c_offsetsH[i] == smallerOffsetH)
        {
            [indexesH addIndex:i];
        }
    }
    
    // --- Get the most close vertical rule from all cells -- //
    NSMutableIndexSet *indexesV = [NSMutableIndexSet indexSet];
    
    const NSInteger countV = offsetsV.length / sizeof(CGFloat);
    const CGFloat *c_offsetsV = [offsetsV bytes];
    CGFloat smallerOffsetV = CGFLOAT_MAX;
    
    for (NSInteger i=0; i<countV; ++i)
    {
        if (fabsf(c_offsetsV[i]) < fabsf(smallerOffsetV))
        {
            smallerOffsetV = c_offsetsV[i];
            [indexesV removeAllIndexes];
            [indexesV addIndex:i];
        }
        else if (c_offsetsV[i] == smallerOffsetV)
        {
            [indexesV addIndex:i];
        }
    }
    
    // --- Creating the new autoaligned frame (if needed) --- //
    if (newFrame != NULL)
    {
        CGPoint finalPoint = cellOrigin;
        CGSize finalSize = cellSize;
        
        NSInteger indexH = [indexesH firstIndex];
        if (indexH != NSNotFound)
        {
            const CGFloat *c_autoalignOriginH = [autoalignOriginH bytes];
            const CGFloat *c_autoalignSizeH = [autoalignSizeH bytes];
            finalPoint.y = c_autoalignOriginH[indexH];
            finalSize.height = c_autoalignSizeH[indexH];
        }
        
        NSInteger indexV = [indexesV firstIndex];
        if (indexV != NSNotFound)
        {
            const CGFloat *c_autoalignOriginV = [autoalignOriginV bytes];
            const CGFloat *c_autoalignSizeV = [autoalignSizeV bytes];
            finalPoint.x = c_autoalignOriginV[indexV]; 
            finalSize.width = c_autoalignSizeV[indexV];
        }
        
        (*newFrame).origin = CGPointMake(roundf(finalPoint.x), roundf(finalPoint.y));
        (*newFrame).size = CGSizeMake(roundf(finalSize.width), roundf(finalSize.height));
    }
    
    // --- Finaly, define the rulers array --- //
    NSMutableArray *rulers = [NSMutableArray array];
    [rulers addObjectsFromArray:[rulersH objectsAtIndexes:indexesH]];
    [rulers addObjectsFromArray:[rulersV objectsAtIndexes:indexesV]];
    [rulers addObjectsFromArray:auxiliarResizingRulers];
    
    return [rulers copy];
}



- (NSArray*)_autoalignCell:(SWLayoutViewCell*)cell atFrame:(CGRect)frame newFrame:(CGRect*)newFrame eventType:(SWLayoutViewCellEventType)eventType
{    
    CGFloat proximity = _autoAlignmentProximity;
    if ( eventType & SWLayoutViewCellEventTypeZeroProximity ) proximity = RulerProximityNone;
    
    // --- Creating the "will" frame of the cell -- //    
    CGRect cellFrame = frame;
    CGPoint cellOrigin = frame.origin;
    CGSize cellSize = frame.size;
    
    // --- Creating reference points for the current cell --- //
    CGPoint topLeft = CGPointTopLeft(cellFrame);
    CGPoint bottomRight = CGPointBottomRight(cellFrame);
    CGPoint center = CGPointCenter(cellFrame);
    
    // --- Suport data Structures --- //
    NSMutableData *offsetsH = [NSMutableData data];
    NSMutableData *offsetsV = [NSMutableData data];
    
    NSMutableData *autoalignOriginH = [NSMutableData data];
    NSMutableData *autoalignOriginV = [NSMutableData data];
    
    NSMutableData *autoalignSizeH = [NSMutableData data];
    NSMutableData *autoalignSizeV = [NSMutableData data];
    
    NSMutableArray *rulersH = [NSMutableArray array];
    NSMutableArray *rulersV = [NSMutableArray array];
    
    NSMutableArray *auxiliarResizingRulers = [NSMutableArray array];
    
//    NSArray *selectedCells = [_cells objectsAtIndexes:[self selectedCellsIndexes]];
    
    // --- Let's iterate all cells --- //
    NSInteger cellsCount = _cells.count;
    for (NSInteger rIndex = -1 ;  rIndex<cellsCount ; rIndex++ )
    {
        UIView *referenceCell ;
        if ( rIndex >= 0 )
        {
            SWLayoutViewCell *rCell = [_cells objectAtIndex:rIndex];
            if ( rCell.selected )   // JLZ
                continue;
            
            referenceCell = rCell;
        }
        else
        {
            // aliniem als marges de la pagina
            referenceCell = self;
        }
        
        // --- Avoid to make autoalignments to the same current cell -- //
        if (referenceCell == cell)
            continue;
    
        
        // -- Creating reference points for the referenceCell --- //
        CGRect referenceCellFrame = referenceCell.frame;
        CGSize refSize = referenceCellFrame.size;
        
        CGPoint refTopLeft = CGPointTopLeft(referenceCellFrame);
        CGPoint refBottomRight = CGPointBottomRight(referenceCellFrame);
        CGPoint refCenter = CGPointCenter(referenceCellFrame);
        
        // --- Getting the offsets to compute if may create a ruler --- //
        CGFloat topOffset = topLeft.y - refTopLeft.y;
        CGFloat centerHOffset = center.y - refCenter.y;
        CGFloat bottomOffset = bottomRight.y - refBottomRight.y;
        CGFloat leftOffset = topLeft.x - refTopLeft.x;
        CGFloat centerVOffset = center.x - refCenter.x;
        CGFloat rightOffset = bottomRight.x - refBottomRight.x;
        
        CGFloat factor = eventType & SWLayoutViewCellEventTypeButtons?2.0:1.0;
        centerHOffset *= factor;
        centerVOffset *= factor;
                
        // --- Computing Ruler Types --- //
        
        // -- Horizontal Rulers -- //
        SWLayoutViewRulerType rulerH = SWLayoutViewRulerTypeNone;
        CGFloat smallestOffsetH = CGFLOAT_MAX;
        CGFloat autoalignOriginY = cellOrigin.y;
        CGFloat autoalignHeight = cellSize.height;
        
        // - Top - //
        if (fabsf(topOffset) < proximity)
        {
            if (fabsf(topOffset) < fabsf(smallestOffsetH))
            {
                if (eventType & SWLayoutViewCellEventTypeInsideZeroProximity)
                {
                    smallestOffsetH = topOffset;
                    rulerH = SWLayoutViewRulerTypeTop;
                    autoalignOriginY = refTopLeft.y;
                    
                }
                else if (eventType & SWLayoutViewCellEventTypeTop)
                {
                    smallestOffsetH = topOffset;
                    rulerH = SWLayoutViewRulerTypeTop;
                    autoalignOriginY = refTopLeft.y;
                    autoalignHeight = cellSize.height - (refTopLeft.y - topLeft.y);
                }
            }
            else if (topOffset == smallestOffsetH)
            {
//                if (!(!(eventType & SWLayoutViewCellEventTypeTop)))
                    rulerH |= SWLayoutViewRulerTypeTop;
            }
        }
        
        // - Center Horizontal - //
        if (fabsf(centerHOffset) < proximity)
        {
            if (fabsf(centerHOffset) < fabsf(smallestOffsetH))
            {
                if (eventType & SWLayoutViewCellEventTypeInsideZeroProximity)
                {
                    smallestOffsetH = centerHOffset;
                    rulerH = SWLayoutViewRulerTypeCenterHorizontal;
                    //autoalignOriginY = refCenter.y - cellFrame.size.height/2.0;
                    autoalignOriginY = refCenter.y - cellSize.height/2.0;
                }
                else if ((eventType & SWLayoutViewCellEventTypeTopBottom))
                {
                    smallestOffsetH = centerHOffset;
                    rulerH = SWLayoutViewRulerTypeCenterHorizontal;
                    if (eventType & SWLayoutViewCellEventTypeTop)
                    {
                        autoalignHeight = 2*(topLeft.y + cellSize.height - refCenter.y);
                        autoalignOriginY = cellOrigin.y + cellSize.height - autoalignHeight;
                    }
                    else if (eventType & SWLayoutViewCellEventTypeBottom)
                    {
                        autoalignOriginY = cellOrigin.y;
                        autoalignHeight = 2*(refCenter.y - topLeft.y);
                    }
                }
            }
            else if (centerHOffset == smallestOffsetH)
            {
                rulerH |= SWLayoutViewRulerTypeCenterHorizontal;
            } 
        }
        
        // - Bottom - //
        if(fabsf(bottomOffset) < proximity)
        {
            if (fabsf(bottomOffset) < fabsf(smallestOffsetH))
            {
                if (eventType & SWLayoutViewCellEventTypeInsideZeroProximity)
                {
                    smallestOffsetH = bottomOffset;
                    rulerH = SWLayoutViewRulerTypeBottom;
                    //autoalignOriginY = refBottomRight.y - cellFrame.size.height;
                    autoalignOriginY = refBottomRight.y - cellSize.height;
                }
                else if ((eventType & SWLayoutViewCellEventTypeBottom))
                {
                    smallestOffsetH = bottomOffset;
                    rulerH = SWLayoutViewRulerTypeBottom;
                    autoalignOriginY = cellOrigin.y;
                    autoalignHeight = refSize.height - topLeft.y + refTopLeft.y; 
                } 
            }
            else if (bottomOffset == smallestOffsetH)
            {
//                if (!(!(eventType & SWLayoutViewCellEventTypeBottom)))
                    rulerH |= SWLayoutViewRulerTypeBottom;
            }
        }
        
        // -- Save horizontal the ruler if needed -- //
        if (rulerH != SWLayoutViewRulerTypeNone)
        {
            [offsetsH appendBytes:&smallestOffsetH length:sizeof(CGFloat)];
            [autoalignOriginH appendBytes:&autoalignOriginY length:sizeof(CGFloat)];
            [autoalignSizeH appendBytes:&autoalignHeight length:sizeof(CGFloat)];
            SWLayoutViewRuler *layoutViewRuler = [SWLayoutViewRuler layoutViewRulerWithMask:rulerH andCell:cell andReferenceCell:referenceCell];
            [rulersH addObject:layoutViewRuler];
        }
        
        // -- Vertical Rulers -- //
        SWLayoutViewRulerType rulerV = SWLayoutViewRulerTypeNone;
        CGFloat smallestOffsetV = CGFLOAT_MAX;
        CGFloat autoalignOriginX = cellOrigin.x;
        CGFloat autoalignWidth = cellSize.width;
        
        // - Left - //
        if (fabsf(leftOffset) < proximity)
        {
            if (fabsf(leftOffset) < fabsf(smallestOffsetV))
            {
                if (eventType & SWLayoutViewCellEventTypeInsideZeroProximity)
                {
                    smallestOffsetV = leftOffset;
                    rulerV = SWLayoutViewRulerTypeLeft;
                    autoalignOriginX = refTopLeft.x;
                }
                else if ((eventType & SWLayoutViewCellEventTypeLeft))
                {
                    smallestOffsetV = leftOffset;
                    rulerV = SWLayoutViewRulerTypeLeft;
                    autoalignOriginX = refTopLeft.x;
                    autoalignWidth = cellSize.width - (refTopLeft.x - topLeft.x);
                }
            }
            else if (leftOffset == smallestOffsetV)
            {
//                if (!(!(eventType & SWLayoutViewCellEventTypeLeft)))
                    rulerV |= SWLayoutViewRulerTypeLeft;
            } 
        }
        
        // - Center Vertical - //
        if (fabsf(centerVOffset) < proximity)
        {
            if (fabsf(centerVOffset) < fabsf(smallestOffsetV))
            {
                if (eventType & SWLayoutViewCellEventTypeInsideZeroProximity)
                {
                    smallestOffsetV = centerVOffset;
                    rulerV = SWLayoutViewRulerTypeCenterVertical;
                    //autoalignOriginX = refCenter.x - cellFrame.size.width/2.0;
                    autoalignOriginX = refCenter.x - cellSize.width/2.0;
                }
                else if ((eventType & SWLayoutViewCellEventTypeLeftRight))
                {
                    smallestOffsetV = centerVOffset;
                    rulerV = SWLayoutViewRulerTypeCenterVertical;
                    if (eventType & SWLayoutViewCellEventTypeLeft)
                    { // Resizing from LEFT
                        autoalignWidth = 2*(topLeft.x + cellSize.width - refCenter.x);
                        autoalignOriginX = cellOrigin.x + cellSize.width - autoalignWidth;
                    }
                    else if (eventType & SWLayoutViewCellEventTypeRight)
                    { // Resizing from RIGHT
                        autoalignOriginX = cellOrigin.x;
                        autoalignWidth = 2*((refTopLeft.x + refSize.width/2.0) - topLeft.x);
                    }
                }
            }
            else if (centerVOffset == smallestOffsetV)
            {
                rulerV |= SWLayoutViewRulerTypeCenterVertical;
            } 
        }
        
        // - Right - //
        if (fabsf(rightOffset) < proximity)
        {
            if (fabsf(rightOffset) < fabsf(smallestOffsetV))
            {
                if (eventType & SWLayoutViewCellEventTypeInsideZeroProximity)
                {
                    smallestOffsetV = rightOffset;
                    rulerV = SWLayoutViewRulerTypeRight;
                    //autoalignOriginX = refBottomRight.x - cellFrame.size.width;
                    autoalignOriginX = refBottomRight.x - cellSize.width;
                }
                else if ((eventType & SWLayoutViewCellEventTypeRight))
                {
                    smallestOffsetV = rightOffset;
                    rulerV = SWLayoutViewRulerTypeRight;
                    autoalignOriginX = cellOrigin.x;
                    autoalignWidth = refSize.width - topLeft.x + refTopLeft.x;
                }   
            }
            else if (rightOffset == smallestOffsetV)
            {
//                if (!(!(eventType & SWLayoutViewCellEventTypeRight)))
                    rulerV |= SWLayoutViewRulerTypeRight;
            }
        }
        
        // -- Save vertical the ruler if needed -- //
        if (rulerV != SWLayoutViewRulerTypeNone)
        {
            [offsetsV appendBytes:&smallestOffsetV length:sizeof(CGFloat)];
            [autoalignOriginV appendBytes:&autoalignOriginX length:sizeof(CGFloat)];
            [autoalignSizeV appendBytes:&autoalignWidth length:sizeof(CGFloat)];
            SWLayoutViewRuler *layoutViewRuler = [SWLayoutViewRuler layoutViewRulerWithMask:rulerV andCell:cell andReferenceCell:referenceCell];
            [rulersV addObject:layoutViewRuler];
        }
        
        // -- Getting auxiliar rulers for resizing -- //
        if (eventType & SWLayoutViewCellEventTypeButtons)
        {
            SWLayoutViewRulerType type = SWLayoutViewRulerTypeNone;
            
            if ((fabsf(topOffset) < RulerProximityNone))
                if (!(eventType & SWLayoutViewCellEventTypeTop))
                    type |= SWLayoutViewRulerTypeTop;
            
            if ((fabsf(bottomOffset) < RulerProximityNone)) 
                if (!(eventType & SWLayoutViewCellEventTypeBottom))
                    type |= SWLayoutViewRulerTypeBottom;
            
            if ((fabsf(centerHOffset) < RulerProximityNone)) 
                if (!(eventType & SWLayoutViewCellEventTypeTopBottom))
                    type |= SWLayoutViewRulerTypeCenterHorizontal;
            
            if ((fabsf(leftOffset) < RulerProximityNone)) 
                if (!(eventType & SWLayoutViewCellEventTypeLeft))
                    type |= SWLayoutViewRulerTypeLeft;
            
            if ((fabsf(rightOffset) < RulerProximityNone)) 
                if (!(eventType & SWLayoutViewCellEventTypeRight))
                    type |= SWLayoutViewRulerTypeRight;
            
            if ((fabsf(centerVOffset) < RulerProximityNone)) 
                if (!(eventType & SWLayoutViewCellEventTypeLeftRight))
                    type |= SWLayoutViewRulerTypeCenterVertical;

            // - Creating the ruler if needed - //
            if (type != SWLayoutViewRulerTypeNone)
            {
                SWLayoutViewRuler *ruler = [SWLayoutViewRuler layoutViewRulerWithMask:type andCell:cell andReferenceCell:referenceCell];
                [auxiliarResizingRulers addObject:ruler];
            }
        }
    }

    // --- Get the most close horizontal rule from all cells --- // 
    NSMutableIndexSet *indexesH = [NSMutableIndexSet indexSet];

    const NSInteger countH = offsetsH.length / sizeof(CGFloat);
    const CGFloat *c_offsetsH = [offsetsH bytes];
    CGFloat smallerOffsetH = CGFLOAT_MAX;
    
    for (NSInteger i=0; i<countH; ++i)
    {
        if (fabsf(c_offsetsH[i]) < fabsf(smallerOffsetH))
        {
            smallerOffsetH = c_offsetsH[i];
            [indexesH removeAllIndexes];
            [indexesH addIndex:i];
        }
        else if (c_offsetsH[i] == smallerOffsetH)
        {
            [indexesH addIndex:i];
        }
    }
    
    // --- Get the most close vertical rule from all cells -- //
    NSMutableIndexSet *indexesV = [NSMutableIndexSet indexSet];
    
    const NSInteger countV = offsetsV.length / sizeof(CGFloat);
    const CGFloat *c_offsetsV = [offsetsV bytes];
    CGFloat smallerOffsetV = CGFLOAT_MAX;
    
    for (NSInteger i=0; i<countV; ++i)
    {
        if (fabsf(c_offsetsV[i]) < fabsf(smallerOffsetV))
        {
            smallerOffsetV = c_offsetsV[i];
            [indexesV removeAllIndexes];
            [indexesV addIndex:i];
        }
        else if (c_offsetsV[i] == smallerOffsetV)
        {
            [indexesV addIndex:i];
        }
    }
    
    // --- Creating the new autoaligned frame (if needed) --- //
    if (newFrame != NULL)
    {
        CGPoint finalPoint = cellOrigin;
        CGSize finalSize = cellSize;
        
        NSInteger indexH = [indexesH firstIndex];
        if (indexH != NSNotFound)
        {
            const CGFloat *c_autoalignOriginH = [autoalignOriginH bytes];
            const CGFloat *c_autoalignSizeH = [autoalignSizeH bytes];
            finalPoint.y = c_autoalignOriginH[indexH];
            finalSize.height = c_autoalignSizeH[indexH];
        }
        
        NSInteger indexV = [indexesV firstIndex];
        if (indexV != NSNotFound)
        {
            const CGFloat *c_autoalignOriginV = [autoalignOriginV bytes];
            const CGFloat *c_autoalignSizeV = [autoalignSizeV bytes];
            finalPoint.x = c_autoalignOriginV[indexV]; 
            finalSize.width = c_autoalignSizeV[indexV];
        }
        
        (*newFrame).origin = CGPointMake(roundf(finalPoint.x), roundf(finalPoint.y));
        (*newFrame).size = CGSizeMake(roundf(finalSize.width), roundf(finalSize.height));
    }
    
    // --- Finaly, define the rulers array --- //
    NSMutableArray *rulers = [NSMutableArray array];
    [rulers addObjectsFromArray:[rulersH objectsAtIndexes:indexesH]];
    [rulers addObjectsFromArray:[rulersV objectsAtIndexes:indexesV]];
    [rulers addObjectsFromArray:auxiliarResizingRulers];
    
    return [rulers copy];
}



- (void)_prepareForDeploymentCellAtIndex:(NSInteger)index
{
    SWLayoutViewCell *cell = [_cells objectAtIndex:index];
    
    if ([_dataSource respondsToSelector:@selector(layoutView:minimumSizeForCellAtIndex:)])
        cell.minimalSize = [_dataSource layoutView:self minimumSizeForCellAtIndex:index];
    else
        cell.minimalSize = CGSizeZero;
    
    if ([_dataSource respondsToSelector:@selector(layoutView:resizingStyleForCellAtIndex:)])
        cell.resizingStyle = [_dataSource layoutView:self resizingStyleForCellAtIndex:index];
}


- (void)_deployCells:(NSArray*)cells toIndexes:(NSIndexSet*)indexes animation:(SWLayoutViewViewAnimation)animation
    completion:(void (^)())completion
{
    __block NSInteger completions = 0;
    NSInteger count = cells.count;
    
    NSAssert( cells.count == indexes.count,
        @"ASSERT Failure, deploying inconsistent number of cells, number of indexes" );
    
    void (^animationCompletion)(BOOL) = ^(BOOL finished)
    {
        completions++;
        if (completions == count)
            if (completion)
                completion();
    };
    
    NSUInteger currentIndex = [indexes firstIndex];
    for (SWLayoutViewCell *cell in cells)
    {
        void (^animations)(void) = nil;
        
        [cell removeFromSuperview];
        
        switch (animation)
        {
            case SWLayoutViewViewAnimationNone:
                //[_cellsContainer insertSubview:cell atIndex:currentIndex];
                [self insertSubview:cell atIndex:currentIndex];
                animationCompletion(YES);
                break;
                
            case SWLayoutViewViewAnimationAppear:
            {
                CGFloat duration = 0.3f;
                CGFloat currentAlpha = cell.alpha;
                cell.alpha = 0.0;
                //[_cellsContainer insertSubview:cell atIndex:currentIndex];
                [self insertSubview:cell atIndex:currentIndex];
                animations = ^(void) { cell.alpha = currentAlpha; };
    
                [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseIn
                animations:animations completion:animationCompletion];
                
//                [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseIn
//                animations:^
//                {
//                    cell.alpha = 1.0;
//                } completion:animationCompletion];
                
                break;
            }
            case SWLayoutViewViewAnimationHorizontalFlip:
            {
                CGFloat duration = 0.30;
                cell.layer.transform = CATransform3DMakeRotation(M_PI/2.0,0.0,1.0,0.0);
                
                //[_cellsContainer insertSubview:cell atIndex:currentIndex];
                [self insertSubview:cell atIndex:currentIndex];
                [UIView animateWithDuration:duration 
                                 animations:^{
                                     cell.layer.transform = CATransform3DIdentity;
                                 } completion:animationCompletion];   
                break;
            }
            case SWLayoutViewViewAnimationVerticalFlip:
            {
                CGFloat duration = 0.30;
                cell.layer.transform = CATransform3DMakeRotation(M_PI/2.0,1.0,0.0,0.0);
                
                //[_cellsContainer insertSubview:cell atIndex:currentIndex];
                [self insertSubview:cell atIndex:currentIndex];
                [UIView animateWithDuration:duration 
                                 animations:^{
                                     cell.layer.transform = CATransform3DIdentity;
                                 } completion:animationCompletion];  
                break;
            }
            default:
                break;
        }
        
        [cell setContentScaleFactor:self.contentScaleFactor];
        currentIndex = [indexes indexGreaterThanIndex:currentIndex];
    }
}


- (void)_undeployCells:(NSArray*)cells animation:(SWLayoutViewViewAnimation)animation completion:(void (^)())completion
{
    __block NSInteger completions = 0;
    NSInteger count = cells.count;
    
    for (SWLayoutViewCell *cell in cells)
    {    
        void (^animationCompletion)(BOOL) = ^(BOOL finished)
        {
            [cell removeFromSuperview];
            
            completions++;
            if (completions == count)
            {
                if (completion)
                    completion();
            }
        };
        
        switch (animation)
        {
            case SWLayoutViewViewAnimationNone:
                animationCompletion(YES);
                
                break;
            case SWLayoutViewViewAnimationAppear:
            {
                CGFloat duration = 0.25;
                [UIView animateWithDuration:duration 
                                 animations:^{
                                     cell.alpha = 0.0;
                                 } completion:animationCompletion];
            }
                break;
            case SWLayoutViewViewAnimationHorizontalFlip:
            {
                CGFloat duration = 0.30;
                [UIView animateWithDuration:duration 
                                 animations:^{
                                     cell.layer.transform = CATransform3DMakeRotation(M_PI/2.0,0.0,1.0,0.0);
                                 } completion:animationCompletion];   
            }
                break;
            case SWLayoutViewViewAnimationVerticalFlip:
            {
                CGFloat duration = 0.30;            
                [UIView animateWithDuration:duration 
                                 animations:^{
                                     cell.layer.transform = CATransform3DMakeRotation(M_PI/2.0,1.0,0.0,0.0);
                                 } completion:animationCompletion];  
            }
                break;
            default:
                break;
        }
    }
}


#pragma mark Selection (private)

- (void)_doSelectCells:(NSArray*)cells animated:(BOOL)animated
{
    for ( SWLayoutViewCell *cell in cells )
    {
        cell.selected = YES;
    }
    
    [_layoutOverlayView markCells:cells animated:animated];
}


- (void)_doDeselectCells:(NSArray*)cells animated:(BOOL)animated
{
    for ( SWLayoutViewCell *cell in cells )
    {
        cell.selected = NO;
        //[self _endSelectionForCell:cell];
    }
    [_layoutOverlayView unmarkCells:cells animated:animated];
}


- (void)_doSetEnabledState:(BOOL)enabled forCell:(SWLayoutViewCell*)cell
{
    BOOL change = (cell.enabled != enabled);
    if ( change )
    {
        cell.enabled = enabled;
        SWLayoutView *contentLayout = cell.contentLayoutView;
        if ( contentLayout )
        {
            if ( enabled )
                [_layoutOverlayCoordinatorView addLayoutViewLayer:contentLayout];
            else
                [_layoutOverlayCoordinatorView removeLayoutViewLayer:contentLayout];
        }
    
        [_layoutOverlayView updateEnabledEstateForCell:cell];
    }
}


//- (void)_endSelectionForCell:(SWLayoutViewCell*)cell
//{
//}

#pragma mark Lock (private)


- (void)_doLockCells:(NSArray*)cells animated:(BOOL)animated
{
    [self _doSetLockState:YES forCells:cells animated:animated];
}


- (void)_doUnlockCells:(NSArray*)cells animated:(BOOL)animated
{
    [self _doSetLockState:NO forCells:cells animated:animated];
}


- (void)_doSetLockState:(BOOL)lock forCells:(NSArray*)cells animated:(BOOL)animated
{
    for ( SWLayoutViewCell *cell in cells )
        cell.locked = lock;
    
    [_layoutOverlayView updateLockStateForCells:cells animated:animated];
}


#pragma mark - SWLayoutOverlayViewDataSource

- (NSData*)layoutOverlayView:(SWLayoutOverlayView *)overlayView rulersForCell:(SWLayoutViewCell *)cell
    movingToFrame:(CGRect)frame correctedFrame:(CGRect*)correctedFrame eventType:(SWLayoutViewCellEventType)eventType
{
    CGRect localFrame = [overlayView convertRect:frame toView:self];
    CGRect localCorrectedFrame = CGRectZero;
    
    NSArray *rulersArray = [self _autoalignCell:cell atFrame:localFrame newFrame:&localCorrectedFrame eventType:eventType];
    if ( correctedFrame ) *correctedFrame = [overlayView convertRect:localCorrectedFrame fromView:self];
    
    NSMutableData *data = [NSMutableData data];
    for (SWLayoutViewRuler *layoutViewRuler in rulersArray)
        [data appendData:[layoutViewRuler rulers]];    
    
    NSInteger count = [data length] / sizeof(SWRuler);
    SWRuler *c_rulersData = [data mutableBytes];
        
    for ( int i=0 ; i<count ; i++)
    {
        SWRuler ruler = c_rulersData[i];
        ruler.fromPoint = [overlayView convertPoint:ruler.fromPoint fromView:self];
        ruler.toPoint = [overlayView convertPoint:ruler.toPoint fromView:self];
        c_rulersData[i] = ruler;
    }

    return data;
}


- (SWLayoutViewCell*)layoutOverlayView:(SWLayoutOverlayView*)overlayView cellAtPoint:(CGPoint)point
{
    CGPoint localPoint = [overlayView convertPoint:point toView:self];
    SWLayoutViewCell *cell = [self _cellAtPoint:localPoint opaque:NO];
    return cell;
}


- (SWLayoutViewCell*)layoutOverlayView:(SWLayoutOverlayView*)overlayView opaqueCellAtPoint:(CGPoint)point
{
    CGPoint localPoint = [overlayView convertPoint:point toView:self];
    SWLayoutViewCell *cell = [self _cellAtPoint:localPoint opaque:YES];
    return cell;
}


- (NSInteger)layoutOverlayView:(SWLayoutOverlayView*)view indexOfCell:(SWLayoutViewCell*)cell
{
    return [_cells indexOfObjectIdenticalTo:cell];
}


#pragma mark - SWLayoutOverlayViewDelegate

- (void)layoutOverlayView:(SWLayoutOverlayView*)overlayView cell:(SWLayoutViewCell*)cell
    didMoveToFrame:(CGRect)frame eventType:(SWLayoutViewCellEventType)eventType
{
    CGRect localFrame = [overlayView convertRect:frame toView:self];
    cell.frame = localFrame;
}


- (void)layoutOverlayView:(SWLayoutOverlayView*)view commitEditionForEventType:(SWLayoutViewCellEventType)eventType
{
    NSInteger count = _cells.count;
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSInteger i=0; i<count; ++i)
    {
        SWLayoutViewCell *cell = [_cells objectAtIndex:i];
        
        if (cell.selected)
            [indexSet addIndex:i];
    }
    
    if ([_dataSource respondsToSelector:@selector(layoutView:commitEditionForCellsAtIndexes:)])
        [_dataSource layoutView:self commitEditionForCellsAtIndexes:indexSet];
}


- (void)layoutOverlayView:(SWLayoutOverlayView*)overlayView didPerformTapAtPoint:(CGPoint)point
{
    if ( [_delegate respondsToSelector:@selector(layoutView:didPerformTapInRect:)] )
    {
        CGPoint localPoint = [overlayView convertPoint:point toView:self];
        SWLayoutViewCell *cell = [self _cellAtPoint:localPoint opaque:NO];
        if ( cell && cell.selected )
        {
            CGRect rect = cell.frame;
            [_delegate layoutView:self didPerformTapInRect:rect];
        }
    }
}


- (void)layoutOverlayView:(SWLayoutOverlayView*)overlayView didPerformLongPresureAtPoint:(CGPoint)point
{
    if ( [_delegate respondsToSelector:@selector(layoutView:didPerformLongPresureInRect:)] )
    {
        CGPoint localPoint = [overlayView convertPoint:point toView:self];
        CGRect rect = CGRectZero;
        rect.origin = localPoint;
        [_delegate layoutView:self didPerformLongPresureInRect:rect];
    }
}


- (void)layoutOverlayView:(SWLayoutOverlayView *)view didPerformDoubleTapAtPoint:(CGPoint)point
{
}


- (BOOL)layoutOverlayView:(SWLayoutOverlayView*)view shouldSelectCell:(SWLayoutViewCell*)cell
{
    BOOL shouldSelect = YES;
    
    if ([_delegate respondsToSelector:@selector(layoutView:shouldSelectCellAtIndex:)])
    {
        NSInteger indx = [_cells indexOfObjectIdenticalTo:cell];
        shouldSelect = [_delegate layoutView:self shouldSelectCellAtIndex:indx] ;
    }
    return shouldSelect;
}

- (void)layoutOverlayView:(SWLayoutOverlayView*)view didSelectCell:(SWLayoutViewCell*)cell
{
    cell.selected = YES;
    if ([_delegate respondsToSelector:@selector(layoutView:didSelectCellsAtIndexes:)])
    {
        NSInteger index = [_cells indexOfObjectIdenticalTo:cell];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
        [_delegate layoutView:self didSelectCellsAtIndexes:indexSet];
    }
}

- (void)layoutOverlayView:(SWLayoutOverlayView*)view didDeselectCell:(SWLayoutViewCell*)cell
{
    cell.selected = NO;
    //[self _endSelectionForCell:cell];
    
    if ([_delegate respondsToSelector:@selector(layoutView:didDeselectCellsAtIndexes:)])
    {
        NSInteger index = [_cells indexOfObjectIdenticalTo:cell];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
        [_delegate layoutView:self didDeselectCellsAtIndexes:indexSet];
    }
}

- (void)layoutOverlayViewDidDeselectAll:(SWLayoutOverlayView*)view
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    NSInteger count = _cells.count;
    
    for (NSInteger i=0; i<count; ++i)
    {
        SWLayoutViewCell *cell = [_cells objectAtIndex:i];
        
        if (cell.selected)
        {
            cell.selected = NO;
            [indexSet addIndex:i];
            
            //[self _endSelectionForCell:cell];
        }
    }

    if ( [_delegate respondsToSelector:@selector(layoutView:didDeselectCellsAtIndexes:)] )
    {
        [_delegate layoutView:self didDeselectCellsAtIndexes:indexSet];
    }
}


- (void)layoutOverlayView:(SWLayoutOverlayView *)view selectionDidChange:(NSSet *)overlayCells
{
}




@end
