//
//  SWImagePickerView.m
//  ImagePicker
//
//  Created by Joan Martín Hernàndez on 7/3/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWImagePickerView.h"
#import "SWImagePickerViewCell.h"

//#import "NSFileManager+Directories.h"
#import "SWImageManager.h"

@interface SWImagePickerView () <SWImagePickerViewCellDelegate>

@end

//static SWImageManager *_imageContext = nil;

@implementation SWImagePickerView
{
    CGFloat _thumbnailPadding;
    
    NSMutableArray *_visibleCells;
    NSMutableSet *_reusableCells;
    NSRange _visibleRowRange;
    
    NSInteger _numberOfCells;
    NSInteger _imagesPerRow;
    
    NSMutableIndexSet *_selectedIndexes;
    NSInteger _highlightedIndex;
    BOOL _shouldScrollToHighligted;
}

@synthesize thumbnailSide = _thumbnailSide;
@synthesize editing = _editing;
@synthesize borderedImages = _borderedImages;
@synthesize dataSource = _dataSource;
@dynamic delegate;   // existeix en el super UIScrollView

#pragma mark Overriden Methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.alwaysBounceVertical = YES;
        
//        _thumbnailSide = 75;
//        _thumbnailPadding = 4;
        [self _getThumbnailGeometryForRowWidth:frame.size.width];
        _visibleCells = [NSMutableArray array];
        _visibleRowRange = NSMakeRange(0, 0);
        _reusableCells = [NSMutableSet set];
        _editing = NO;
        _selectedIndexes = [NSMutableIndexSet indexSet];
        _highlightedIndex = NSNotFound;
        
        self.backgroundColor = [UIColor whiteColor];
        self.contentInset = UIEdgeInsetsMake(0, 0, _thumbnailPadding, 0);
        
        
//        static NSString *contextPath = nil;
//        if (!contextPath) 
//        {
//            contextPath = [[NSFileManager defaultManager] applicationCacheDirectoryURL].path;
//            contextPath = [contextPath stringByAppendingPathComponent:@"Thumbnails"];
//        }
//        if (!_imageContext) 
//        {
//            _imageContext = [[SWImageManager alloc] initWithContextAtPath:contextPath];
//            _imageContext.savingOptions = SWImageManagerSavingOptionCreation;
//        }
    }
    return self;
}


- (NSInteger)_getThumbnailGeometryForRowWidth:(CGFloat)width
{
    _thumbnailPadding = 4;
    
    NSInteger imagesPerRow = 4;
    if ( width > 320 )
        imagesPerRow = round((width-_thumbnailPadding)/(75+_thumbnailPadding));
    
    _thumbnailSide = round((width-_thumbnailPadding*(imagesPerRow+1))/imagesPerRow);
    
    return imagesPerRow;
}


#define _rowHeight (_thumbnailSide+_thumbnailPadding)

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    NSInteger newImagesPerRow = [self _getThumbnailGeometryForRowWidth:bounds.size.width];
    
    //NSInteger newImagesPerRow = (bounds.size.width - _thumbnailPadding)/_rowHeight;
    if (newImagesPerRow != _imagesPerRow) 
    {
        _imagesPerRow = newImagesPerRow;
        //CGPoint offset = self.contentOffset;
        [self reloadData];
        //self.contentOffset = offset;
    }

    NSInteger lastRow = _numberOfCells%_imagesPerRow==0?0:1;
    NSInteger rows = _numberOfCells / _imagesPerRow + lastRow;
    self.contentSize = CGSizeMake(bounds.size.width, rows * _rowHeight);
    
    if ( _shouldScrollToHighligted )
    {
        CGRect rect = [self _frameForCellAtIndex:_highlightedIndex];
        [self scrollRectToVisible:rect animated:NO];
        _shouldScrollToHighligted = NO;
    }
    [self _computeVisibleThumbnails];
}

#pragma mark Properties

- (void)setEditing:(BOOL)editing
{
    if (editing == _editing)
        return;
    
    _editing = editing;
    
    if ( !editing )
    {
        for (SWImagePickerViewCell *cell in _visibleCells)
            cell.selected = NO;
        
         [_selectedIndexes removeAllIndexes];
    }
}

- (void)setBorderedImages:(BOOL)borderedImages
{
    if (_borderedImages == borderedImages)
        return;
    
    _borderedImages = borderedImages;
    
    for (SWImagePickerViewCell *cell in _visibleCells)
    {
        cell.showBorder = borderedImages;
    }
}

#pragma mark Public Methods

- (void)reloadData
{    
    for (SWImagePickerViewCell*cell in _visibleCells)
    {
        [cell removeFromSuperview];
        [self _reuseCell:cell];
    }
    
    [_visibleCells removeAllObjects];
    _visibleRowRange = NSMakeRange(0, 0);
    
    //self.contentOffset = CGPointMake(0, 0);
    
    _numberOfCells = [_dataSource numberOfImagesForImagePickerView:self];    
    
    [self setNeedsLayout];
}

- (NSIndexSet*)selectedImageIndexes
{
    return _selectedIndexes;
}

- (void)insertImagesAtIndexes:(NSIndexSet*)indexSet
{   
    NSMutableArray *selected = [NSMutableArray array];
    NSInteger count = _numberOfCells;
    for (int i=0; i<count; ++i)
    {
        if ([_selectedIndexes containsIndex:i])
        {
            [selected addObject:[NSNumber numberWithBool:YES]];
        }
        else
        {
            [selected addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    NSInteger index = indexSet.firstIndex;
    while (index != NSNotFound)
    {
        [selected insertObject:[NSNumber numberWithBool:NO] atIndex:index];
        index = [indexSet indexGreaterThanIndex:index];
    }
    
    NSMutableIndexSet *finalSet = [NSMutableIndexSet indexSet];
    count = selected.count;
    for (int i=0; i<count; ++i)
    {
        if ([[selected objectAtIndex:i] boolValue])
        {
            [finalSet addIndex:i];
        }
    }
    
    _selectedIndexes = finalSet;
    _highlightedIndex = NSNotFound;
    
    //CGPoint offset = self.contentOffset;
    [self reloadData];
    //self.contentOffset = offset;
}



- (void)deleteImagesAtIndexes:(NSIndexSet*)indexSet
{
    NSMutableArray *selected = [NSMutableArray array];
    NSInteger count = _numberOfCells;
    for (int i=0; i<count; ++i)
    {
        if ([_selectedIndexes containsIndex:i])
        {
            [selected addObject:[NSNumber numberWithBool:YES]];
        }
        else
        {
            [selected addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    [selected removeObjectsAtIndexes:indexSet];
    
    NSMutableIndexSet *finalSet = [NSMutableIndexSet indexSet];
    count = selected.count;
    for (int i=0; i<count; ++i)
    {
        if ([[selected objectAtIndex:i] boolValue])
        {
            [finalSet addIndex:i];
        }
    }
    
    _selectedIndexes = finalSet;
    _highlightedIndex = NSNotFound;
    
    //CGPoint offset = self.contentOffset;
    [self reloadData];
    //self.contentOffset = offset;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _imagesPerRow = (frame.size.width - _thumbnailPadding)/_rowHeight;
}


- (void)selectImagesAtIndexes:(NSIndexSet*)indexSet
{
    _selectedIndexes = [indexSet mutableCopy];
    
    //CGPoint offset = self.contentOffset;
    [self reloadData];
    //self.contentOffset = offset;
}

- (void)highlightImageAtIndex:(NSInteger)index
{
    _highlightedIndex = index;
    _shouldScrollToHighligted = YES;
    
//    if ( _imagesPerRow == 0 )
//        return ;
//    
//    CGRect rect = [self _frameForCellAtIndex:index];
//    //self.contentOffset = CGPointMake(0, rect.origin.y-_thumbnailPadding);
//    
//    NSLog( @"ContentOffset:%g", self.contentOffset.y);
//    NSLog( @"ContentSize:%g", self.contentSize.height);
//    if ( self.contentSize.height == 0 )
//    {
//        self.contentOffset = CGPointMake(0, rect.origin.y-_thumbnailPadding);
//    }
//    else
//    {
//        [self scrollRectToVisible:rect animated:NO];
//    }
//    NSLog( @"ContentOffset:%g", self.contentOffset.y);
//    NSLog( @"ContentSize:%g", self.contentSize.height);
    [self reloadData];
}


#pragma mark Private Methods

- (SWImagePickerViewCell*)_dequeueReusableCell
{
    SWImagePickerViewCell *cell = [_reusableCells anyObject];
    
    if (cell)
        [_reusableCells removeObject:cell];
    
    return cell;
}

- (void)_reuseCell:(SWImagePickerViewCell*)cell
{
    [cell prepareForReuse];
    [_reusableCells addObject:cell];
}

//- (CGFloat)_rowHeight
//{
//    return _thumbnailSide + _thumbnailPadding;
//}


- (NSInteger)_rowAtOffset:(CGFloat)offset
{
    NSInteger rowIndex = (NSInteger)(offset/_rowHeight);
    return rowIndex;
}

- (NSRange)_visibleRowsWithOffset:(CGFloat)offset
{
    CGRect bounds = self.bounds;
    NSInteger startRow = [self _rowAtOffset:offset];
    NSInteger endRow = [self _rowAtOffset:(offset + bounds.size.height - 1 )];  // -1 perque el ultim pixel cau a fora
    
    if ( startRow < 0 ) 
        startRow = 0;
    
    if ( endRow < 0 ) 
        endRow = 0;
    
    return NSMakeRange(startRow, endRow + 1 - startRow );
}

- (NSInteger)_rangeIndexFromIndex:(NSInteger)index
{
    return index - _visibleRowRange.location;
}

- (NSInteger)_indexFromRangeIndex:(NSInteger)index
{
    return _visibleRowRange.location + index;
}

- (BOOL)_isIndexInRange:(NSInteger)index
{
    return index >= _visibleRowRange.location && index < _visibleRowRange.location + _visibleRowRange.length ;
}

- (CGRect)_frameForCellAtIndex:(NSInteger)index
{
    NSInteger row = index/_imagesPerRow;
    NSInteger inRow = index % _imagesPerRow;
    
    CGRect frame = CGRectZero;
    frame.origin = CGPointMake(_thumbnailPadding + inRow * _rowHeight, _thumbnailPadding + row * _rowHeight);
    frame.size = CGSizeMake(_thumbnailSide, _thumbnailSide);
    
    return frame;
}

- (void)_deployRowAtIndex:(NSInteger)index
{
    NSInteger firstImage = _imagesPerRow*index;
    NSInteger lastImage = firstImage + _imagesPerRow;
    
    lastImage = lastImage>_numberOfCells?_numberOfCells:lastImage;
    
    NSInteger rangeIndex = [self _rangeIndexFromIndex:index]*_imagesPerRow;
    
    for (int i=lastImage-1; i>=firstImage; --i)
    {
        SWImagePickerViewCell *cell = [self _dequeueReusableCell];
        
        if (!cell)
        {
            cell = [[SWImagePickerViewCell alloc] initWithFrame:CGRectMake(0, 0, _thumbnailSide, _thumbnailSide)];
            cell.delegate = self;
        }
        
        
        if ([_dataSource respondsToSelector:@selector(imagePickerView:imageAtIndex:)])
        {
            cell.image = [_dataSource imagePickerView:self imageAtIndex:i];
        }
        else if ([_dataSource respondsToSelector:@selector(imagePickerView:imagePathAtIndex:)]) 
        {
            NSString *path = [_dataSource imagePickerView:self imagePathAtIndex:i];
            SWImageDescriptor *descriptor = [[SWImageDescriptor alloc] initWithOriginalPath:path
                size:CGSizeMake(_thumbnailSide, _thumbnailSide) contentMode:UIViewContentModeScaleAspectFill];
            [cell setImageWithDescriptor:descriptor];
        } 
        else 
        {
            NSAssert(NO, @"ImagePickerViewDataSoruce does not implement one of the image getter methods.");
        }
        
        cell.frame = [self _frameForCellAtIndex:i];
        
        cell.selected = [_selectedIndexes containsIndex:i];
        cell.highlighted = (_highlightedIndex == i);
        cell.showBorder = _borderedImages;
        
        [_visibleCells insertObject:cell atIndex:rangeIndex];
                
        [self addSubview:cell];
        [self sendSubviewToBack:cell];
    }
    
    _visibleRowRange.length += 1 ;
}

- (void)_undeployRowAtIndex:(NSInteger)index
{
    NSInteger firstImage = _imagesPerRow*index;
    NSInteger lastImage = firstImage + _imagesPerRow;
    
    lastImage = lastImage>_numberOfCells?_numberOfCells:lastImage;

    if (_visibleCells.count == 0)
    {
        return;
    }
    else if (firstImage < 0)
    {
        return;
    }    
    
    NSInteger rangeIndex = [self _rangeIndexFromIndex:index]*_imagesPerRow;
    
    for (int i=firstImage; i<lastImage; ++i)
    {
        
        SWImagePickerViewCell *cell = [_visibleCells objectAtIndex:rangeIndex];
        
        [cell removeFromSuperview];
        
        [_visibleCells removeObjectAtIndex:rangeIndex];
        
        [self _reuseCell:cell];
    }
    
    _visibleRowRange.length -= 1;
}


- (void)_computeVisibleThumbnails
{
    // If no rows, nothing to do
    if (_numberOfCells == 0)
        return ;
    
    // Recomputing visibleRows
    NSRange newRange = [self _visibleRowsWithOffset:self.contentOffset.y];
        
    // If range is the same, nothing to do.
    if (newRange.location == _visibleRowRange.location && newRange.length == _visibleRowRange.length)
        return;
    
    NSInteger newFirstCell = newRange.location;
    NSInteger newLastCell = newRange.location + newRange.length - 1;
        
    // MANIPULATING LOCATION
    while ( _visibleRowRange.location != newFirstCell ) 
    {
        if (_visibleRowRange.location > newFirstCell ) 
        {
            _visibleRowRange.location -= 1 ;
            [self _deployRowAtIndex:_visibleRowRange.location];
        } 
        else if (_visibleRowRange.location < newFirstCell) 
        {
            [self _undeployRowAtIndex:_visibleRowRange.location];
            _visibleRowRange.location += 1;
        }
    }

    // MANIPULATING LENGTH
    NSInteger lastCell = _visibleRowRange.location + _visibleRowRange.length - 1;
    
    while ( lastCell != newLastCell) 
    {
        if (lastCell > newLastCell) 
        {
            if (lastCell < _numberOfCells) [self _undeployRowAtIndex:lastCell];
            else break;
        }
        else if (lastCell < newLastCell) 
        {
            if (lastCell+1 < _numberOfCells) [self _deployRowAtIndex:lastCell+1];
            else break;
        }
        lastCell = _visibleRowRange.location + _visibleRowRange.length - 1;
    }
}

#pragma mark Protocol SWImagePickerViewCellDelegate

- (void)tapReceivedInImagePickerViewCell:(SWImagePickerViewCell *)cell
{
    NSInteger rangeIndex = [_visibleCells indexOfObjectIdenticalTo:cell];    
    NSAssert(rangeIndex != NSNotFound, nil);
    NSInteger row = rangeIndex/_imagesPerRow;
    NSInteger inRow = rangeIndex%_imagesPerRow;
    NSInteger index = [self _indexFromRangeIndex:row]*_imagesPerRow + inRow;
    
//    if (_editing)
//    {
//        cell.selected = !cell.selected;
//        if (cell.selected)
//            [_selectedIndexes addIndex:index];
//        else
//            [_selectedIndexes removeIndex:index];
//    } 
//    else
//    {
//        if ([self.delegate respondsToSelector:@selector(imagePickerView:didSelectImageAtIndex:)])
//            [self.delegate imagePickerView:self didSelectImageAtIndex:index];
//    }
    

    if ( _editing )
    {
        cell.selected = !cell.selected;
        if (cell.selected)
            [_selectedIndexes addIndex:index];
        else
            [_selectedIndexes removeIndex:index];
    }
    
    for ( SWImagePickerViewCell *aCell in _visibleCells )
        aCell.highlighted = NO;
    
    cell.highlighted = YES;
    _highlightedIndex = index;
    
    
    if ( !_editing && (cell.selected || cell.highlighted) )
    {
        if ([self.delegate respondsToSelector:@selector(imagePickerView:didSelectImageAtIndex:)])
            [self.delegate imagePickerView:self didSelectImageAtIndex:index];
    }
    
}

@end
