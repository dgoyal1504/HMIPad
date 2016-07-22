//
//  SWGroupItem.m
//  HmiPad
//
//  Created by Joan Lluch on 18/10/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWGroupItem.h"
#import "SWDocumentModel.h"


@interface SWGroupItem()
{
    BOOL _pickEnabled;
    NSIndexSet *_selectedIndexes;
    NSIndexSet *_lockedIndexes;
    NSMutableArray *_items;
}
@end


@implementation SWGroupItem

@synthesize items = _items;


#pragma mark - Class Stuff


static SWObjectDescription *_objectDescription = nil;

+ (SWObjectDescription *)objectDescription
{
    if ( _objectDescription == nil ) {
        _objectDescription = [[SWObjectDescription alloc] initWithObjectClass:[self class]];
    }
    return _objectDescription ;
}

+ (NSString*)defaultIdentifier
{
    return @"group";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"GROUP", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray array];
}

+ (SWItemControllerType)controllerType
{
    return SWItemControllerTypeGroup;
}


#pragma mark - QuickCoding

- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super initWithQuickCoder:decoder];
    if (self)
    {
        _items = [decoder decodeObject];
    }
        
    return self;
}

- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
{
    [super encodeWithQuickCoder:encoder];
    [encoder encodeObject:_items];
}


- (void)retrieveWithQuickCoder:(QuickUnarchiver *)decoder
{
    [super retrieveWithQuickCoder:decoder];
    [decoder retrieveForObject:_items];
}

- (void)storeWithQuickCoder:(QuickArchiver *)encoder
{
    [super storeWithQuickCoder:encoder];
    [encoder encodeObject:_items];
}


#pragma mark - SymbolicCoding

- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(SWItem *)parent
{
    self = [super initWithSymbolicCoder:decoder identifier:ident parentObject:parent];
    if (self) 
    {
        _items = [decoder decodeCollectionOfObjectsForKey:@"items"];
    }
    return self ;
}

-(void)encodeWithSymbolicCoder:(SymbolicArchiver *)encoder 
{
    [super encodeWithSymbolicCoder:encoder];
    [encoder encodeCollectionOfObjects:_items forKey:@"items"];
}

- (void)retrieveWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(id<SymbolicCoding>)parent
{
    [super retrieveWithSymbolicCoder:decoder identifier:ident parentObject:parent];
    [decoder retrieveForCollectionOfObjects:_items forKey:@"items"];
}

- (void)storeWithSymbolicCoder:(SymbolicArchiver*)encoder
{
    [super storeWithSymbolicCoder:encoder];
    [encoder encodeCollectionOfObjects:_items forKey:@"items"];
}


#pragma mark item methods

- (SWItemResizeMask)resizeMask
{
    return SWItemResizeMaskNone;
}

- (void)prepareForGroupOperation
{
    [super prepareForGroupOperation];
    for (SWItem *item in _items)
        [item prepareForGroupOperation];
}

- (void)finishGroupOperation
{
    [super finishGroupOperation];
    for (SWItem *item in _items)
        [item finishGroupOperation];
}



- (void)adjustFrameToFitSubItemsForOrientation:(UIInterfaceOrientation)orientation idiom:(SWDeviceInterfaceIdiom)idiom
{
    if ( _items.count == 0 )
        return;
    
    CGRect currentFrame = [self frameForOrientation:orientation idiom:idiom];
    
    CGPoint min = CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
    CGPoint max = CGPointMake(-CGFLOAT_MAX, -CGFLOAT_MAX);

    for ( SWItem *item in _items )
    {
        CGRect rect = [item frameForOrientation:orientation idiom:idiom];
        if ( rect.origin.x < min.x  ) min.x = rect.origin.x;
        if ( rect.origin.x+rect.size.width > max.x ) max.x = rect.origin.x+rect.size.width;
        if ( rect.origin.y < min.y  ) min.y = rect.origin.y;
        if ( rect.origin.y+rect.size.height > max.y ) max.y = rect.origin.y+rect.size.height;
    }
    
    CGPoint offset = min;
    
    CGRect newFrame = CGRectMake(currentFrame.origin.x + offset.x, currentFrame.origin.y + offset.y, max.x-min.x, max.y-min.y);
    [self frameSWValueWithOrientation:orientation idiom:idiom].valueAsCGRect = newFrame;
    
    if ( offset.x != 0 || offset.y != 0 )
    {
        for ( SWItem *item in _items )
        {
            CGRect rect = [item frameForOrientation:orientation idiom:idiom];
            rect.origin.x -= offset.x;
            rect.origin.y -= offset.y;
            [item frameSWValueWithOrientation:orientation idiom:idiom].valueAsCGRect = rect;
        }
    }
    
    SWGroupItem *parentItem = self.parentObject;
    if ( [parentItem isGroupItem] )
        [parentItem adjustFrameToFitSubItemsForOrientation:orientation idiom:idiom];
}




#pragma mark - SWAsleepCapable

- (void)putToSleep
{    
    [super putToSleep];
    [_items makeObjectsPerformSelector:@selector(putToSleep)];
}

- (void)awakeFromSleepIfNeeded
{
    [super awakeFromSleepIfNeeded];
    [_items makeObjectsPerformSelector:@selector(awakeFromSleepIfNeeded)];
}


//#pragma mark GroupItem Observer
//
//- (void)addGroupItemObserver:(id<GroupItemObserver>)observer
//{
//    [self addObjectObserver:observer];
//}
//
//- (void)removeGroupItemObserver:(id<GroupItemObserver>)observer
//{
//    [self removeObjectObserver:observer];
//}
//
//- (void)addObjectObserver:(id<SWObjectObserver>)itemObserver
//{
//    [super addObjectObserver:itemObserver];
//}

#pragma mark item selection

- (void)primitiveSetSelected:(BOOL)selected
{
    [super primitiveSetSelected:selected];
    if ( selected == NO )
    {
        // deseleccionem els seus items
        [self deselectItemsAtIndexes:[self selectedItemIndexes]];
    }
}

- (void)primitiveSetPickEnabled:(BOOL)enabled
{
    _pickEnabled = enabled;
}

- (BOOL)pickEnabled
{
    return _pickEnabled;
}


//- (void)selectItem:(SWItem*)item
//{
//    NSInteger index = [_groupedItems indexOfObjectIdenticalTo:item];
//    if ( index != NSNotFound )
//    {
//        [self selectSubItemsAtIndexes:[NSIndexSet indexSetWithIndex:index]];
//    }
//}


//- (void)setChildGroupItemV:(SWGroupItem*)groupItem selected:(BOOL)selected enabled:(BOOL)pickEnabled
//{
//    BOOL changeSelected = (groupItem.selected != selected);
//    BOOL changeEnabled = (groupItem.pickEnabled != pickEnabled);
//    
//    if ( ! (changeSelected || changeEnabled) )
//        return;
//
//    NSInteger index = [_groupedItems indexOfObjectIdenticalTo:groupItem];
//    if ( index != NSNotFound )
//    {
//        if ( changeSelected )
//        {
//            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
//            if ( selected )
//                [self selectSubItemsAtIndexes:indexSet];
//            else
//                [self deselectSubItemsAtIndexes:indexSet];
//        }
//        
//        if ( changeEnabled )
//        {
//            groupItem.pickEnabled = pickEnabled;
//            NSArray *observers = [_observers copy];
//            for (id<GroupItemObserver> observer in observers)
//            {
//                if ([observer respondsToSelector:@selector(groupItem:groupItemAtIndex:didChangePickEnabledStateTo:)])
//                    [observer groupItem:self groupItemAtIndex:index didChangePickEnabledStateTo:pickEnabled];
//            }
//        }
//    }
//}


- (void)setChildGroupItem:(id<SWGroup,SWSelectable>)groupItem selected:(BOOL)selected enabled:(BOOL)pickEnabled
{
    BOOL changeSelected = (groupItem.selected != selected);
    BOOL changeEnabled = (groupItem.pickEnabled != pickEnabled);
    
    if ( ! (changeSelected || changeEnabled) )
        return;

    NSInteger index = [_items indexOfObjectIdenticalTo:groupItem];
    if ( index != NSNotFound )
    {
        if ( select && pickEnabled )
        {
            // deseleccionem els items germans del groupitem
            NSIndexSet *excludingIndexSet = [self _selectedItemIndexesExcludingItem:groupItem];
            [self deselectItemsAtIndexes:excludingIndexSet];
        }
    
        if ( changeSelected )
        {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
            if ( selected )
                [self selectItemsAtIndexes:indexSet];
            else
                [self deselectItemsAtIndexes:indexSet];
        }
        
        if ( changeEnabled )
        {
            [groupItem primitiveSetPickEnabled:pickEnabled];
            NSArray *observers = [_observers copy];
            for (id<GroupItemObserver> observer in observers)
            {
                if ([observer respondsToSelector:@selector(group:groupItemAtIndex:didChangePickEnabledStateTo:)])
                    [observer group:self groupItemAtIndex:index didChangePickEnabledStateTo:pickEnabled];
            }
        }
    }
}



//- (void)selectSubItemsAtIndexesV:(NSIndexSet*)indexes
//{
//    if (indexes.count == 0)
//        return;
//    
//    id parentItem = self.parentObject;
//    [parentItem setChildGroupItem:self selected:YES enabled:YES];
//
//    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
//    {
//        SWItem *item = [_groupedItems objectAtIndex:idx];
//        [item primitiveSetSelected:YES];
//    }];
//    
//    _selectedIndexes = nil;
//    
//    NSArray *observers = [_observers copy];
//    for (id<GroupItemObserver> observer in observers)
//    {
//        if ([observer respondsToSelector:@selector(groupItem:didSelectSubItemsAtIndexes:)])
//            [observer groupItem:self didSelectSubItemsAtIndexes:indexes];
//    }
//}


- (void)selectItemsAtIndexes:(NSIndexSet*)indexes
{
    if (indexes.count == 0)
        return;
    
    id parentItem = self.parentObject;
    [parentItem setChildGroupItem:self selected:YES enabled:YES];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        SWItem *item = [_items objectAtIndex:idx];
        [item primitiveSetSelected:YES];
    }];
    
    _selectedIndexes = nil;
    
    // els SWGroupItems seleccionats al mateix nivell en deseleccionem els fills
    for ( SWItem *item  in _items )
    {
        if ( item.isGroupItem && item.selected )
        {
            id<SWGroup> groupItem = (id)item;
            [groupItem deselectItemsAtIndexes:[groupItem selectedItemIndexes]];
        }
    }
    
    NSArray *observers = [_observers copy];
    for (id<GroupItemObserver> observer in observers)
    {
        if ([observer respondsToSelector:@selector(group:didSelectItemsAtIndexes:)])
            [observer group:self didSelectItemsAtIndexes:indexes];
    }
}


- (void)deselectItemsAtIndexes:(NSIndexSet*)indexes
{
    if (indexes.count == 0)
        return;

    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        SWItem *item = [_items objectAtIndex:idx];
        [item primitiveSetSelected:NO];
    }];
    
    _selectedIndexes = nil;
    
    NSArray *observers = [_observers copy];
    for (id<GroupItemObserver> observer in observers)
    {
        if ([observer respondsToSelector:@selector(group:didDeselectItemsAtIndexes:)])
            [observer group:self didDeselectItemsAtIndexes:indexes];
    }
    
    NSInteger selectedIndexCount = [self selectedIndexCount];
    
    id parentItem = self.parentObject;
    [parentItem setChildGroupItem:self selected:self.selected enabled:selectedIndexCount>0];
}


- (NSInteger)selectedIndexCount
{
    if ( _selectedIndexes )
        return _selectedIndexes.count;

    NSInteger count = 0;
    for ( SWItem *item in _items )
        count += (item.selected != NO);
    
    return count;
}


- (NSIndexSet *)_selectedItemIndexesExcludingItem:(id<SWSelectable>)excludedItem
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    NSInteger count = _items.count;
    for (NSInteger i=0; i<count; ++i)
    {
        SWItem *item = [_items objectAtIndex:i];
        if ( item != excludedItem && item.selected )
            [indexSet addIndex:i];
    }
    return indexSet;
}


- (NSIndexSet*)selectedItemIndexes
{
    if ( _selectedIndexes )
        return _selectedIndexes;
    
//    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
//    
//    NSInteger count = _groupedItems.count;
//    for (NSInteger i=0; i<count; ++i)
//    {
//        SWItem *item = [_groupedItems objectAtIndex:i];
//        if (item.selected)
//            [indexSet addIndex:i];
//    }
//    _selectedIndexes = indexSet;  // [indexSet copy];

    _selectedIndexes = [self _selectedItemIndexesExcludingItem:nil];

    return _selectedIndexes;
}


- (void)lockItemsAtIndexes:(NSIndexSet*)indexes
{
    if (indexes.count == 0)
        return;

    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        SWItem *item = [_items objectAtIndex:idx];
        [item primitiveSetLocked:YES];
    }];
    
    _lockedIndexes = nil;
    
    NSUndoManager *undoManager = _docModel.undoManager;
    
    [[undoManager prepareWithInvocationTarget:self] unlockItemsAtIndexes:indexes];
    [undoManager setActionName:indexes.count>1?NSLocalizedString(@"Lock Items",nil):NSLocalizedString(@"Lock Item",nil)];
    
    NSArray *observers = [_observers copy];
    for (id<SWGroupObserver> observer in observers)
    {
        if ([observer respondsToSelector:@selector(group:didLockItemsAtIndexes:)])
            [observer group:self didLockItemsAtIndexes:indexes];
    }
}


- (void)unlockItemsAtIndexes:(NSIndexSet*)indexes
{
    if (indexes.count == 0)
        return;

    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        SWItem *item = [_items objectAtIndex:idx];
        [item primitiveSetLocked:NO];
    }];
    
    _lockedIndexes = nil;
    
    NSUndoManager *undoManager = _docModel.undoManager;
    
    [[undoManager prepareWithInvocationTarget:self] lockItemsAtIndexes:indexes];
    [undoManager setActionName:indexes.count>1?NSLocalizedString(@"Unlock Items",nil):NSLocalizedString(@"Unlock Item",nil)];
    
    NSArray *observers = [_observers copy];
    for (id<SWGroupObserver> observer in observers)
    {
        if ([observer respondsToSelector:@selector(group:didUnlockItemsAtIndexes:)])
            [observer group:self didUnlockItemsAtIndexes:indexes];
    }
}


- (void)unlockAllItems   // to deprecate
{
    NSIndexSet *indexes = [self lockedItemIndexes];
    [self unlockItemsAtIndexes:indexes];
}


- (NSIndexSet*)lockedItemIndexes
{
    if ( _lockedIndexes )
        return _lockedIndexes;
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    NSInteger count = _items.count;
    for (NSInteger i=0; i<count; ++i)
    {
        SWItem *item = [_items objectAtIndex:i];
        if (item.locked)
            [indexSet addIndex:i];
    }
    _lockedIndexes = indexSet;  // [indexSet copy];
    return _lockedIndexes;
}


#pragma mark Overriden Group Methods


- (BOOL)isGroupItem
{
    return YES;
}

- (NSInteger)groupCount
{
    return _items.count;
}

@end
