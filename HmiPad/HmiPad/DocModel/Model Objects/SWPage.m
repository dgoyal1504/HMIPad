//
//  SWPage.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/14/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import "SWPage.h"
#import "SWEnumTypes.h"
#import "SWPropertyDescriptor.h"

//#import "SWFileManager.h"
#import "SWDocumentModel.h"
//#import "NSFileManager+Directories.h"

#import "SWModelManager.h"
#import "SWItem.h"
#import "SWGroupItem.h"

#define block_return return


@interface SWPage()
{
    NSIndexSet *_selectedIndexes;   // cache dels selectedItemIndexes
    NSIndexSet *_lockedIndexes;     // cache dels lockedItemIndexes
    NSMutableArray *_items;
}
@end


@implementation SWPage

@synthesize uuid = _uuid;
@synthesize items = _items;

#pragma mark - Class Stuff

static SWObjectDescription *_objectDescription = nil;

+ (SWObjectDescription *)objectDescription
{
    if ( _objectDescription == nil ) {
        _objectDescription = [[SWObjectDescription alloc] initWithObjectClass:[self class]];
    }
    return _objectDescription;
}

+ (NSString*)defaultIdentifier
{
    return @"page";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"PAGE", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
    
            [SWPropertyDescriptor propertyDescriptorWithName:@"pageIdentifier" type:SWTypeString
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithString:@""]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"title" type:SWTypeString
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithString:@"Title"]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"shortTitle" type:SWTypeString
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithString:@"TITLE"]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"modalStyle" type:SWTypeEnumModalStyle
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWModalStyleNormal]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"pageTransitionStyle" type:SWTypeEnumPageTransitionStyle
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWPageTransitionStyleHorizontalShift]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"enabledInterfaceIdiom" type:SWTypeEnumPageInterfaceIdiom
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWPageInterfaceIdiomPadAndPhone]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"color" type:SWTypeColor
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"White"/*@"SlateGray"*/]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"image" type:SWTypeImagePath
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@""]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"imageRatio" type:SWTypeEnumAspectRatio
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWImageAspectRatioFill]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"hidden" type:SWTypeBool
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
            
            nil];
    
    
}

#pragma mark - Properties

// -- Coding Properties -- //
//@synthesize items = _items;

//@dynamic backgroundColor;
//@dynamic backgroundImage;
//@dynamic title;
//@dynamic backgroundImageAspectRatio;

// -- Dynamic Properties -- //
//@dynamic screenShot;
//@dynamic screenShotIsAvailable;
//@dynamic documentPageIndex;

- (void)_setUuid
{
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    _uuid = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    CFRelease(uuidRef);
}


- (id)initInDocument:(SWDocumentModel*)docModel
{
    self = [super initInDocument:docModel];
    if (self) 
    {
        [self _setUuid];
        _items = [NSMutableArray array];
    }
    return self;
}

#pragma mark - QuickCoding

- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super initWithQuickCoder:decoder];
    if (self)
    {
        _uuid = [decoder decodeObject];
        _items = [decoder decodeObject];
    }
    return self;
}

- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
{
    [super encodeWithQuickCoder:encoder];
    
    [encoder encodeObject:_uuid];
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

-(id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(SWDocumentModel *)parent
{
    self = [super initWithSymbolicCoder:decoder identifier:ident parentObject:parent];
    if (self) 
    {
        // identifiquem que estem descodificant el model sencer si el root es nil,
        // si no estem en un cas de copy/paste/duplicate i ens interesara crear un uuid nou
        if ( [decoder rootObject] == nil )
            _uuid = [decoder decodeStringForKey:@"uuid"];

        if ( _uuid.length == 0 )
            [self _setUuid];
        
        _items = [decoder decodeCollectionOfObjectsForKey:@"items"];
    }
    return self;
}

-(void)encodeWithSymbolicCoder:(SymbolicArchiver *)encoder
{
    [super encodeWithSymbolicCoder:encoder];
    [encoder encodeString:_uuid forKey:@"uuid"];
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

- (void)dealloc
{
    //NSLog(@"Dealloc %@",[self.class description]);
}


#pragma mark - Value Holder Methods

//- (void)setGlobalIdentifier:(NSString *)ident
//{
//    // interceptem el setGlobalIdentifier per canviar el uuid de la pagina en el cas de copy/paste/duplicate
//    [super setGlobalIdentifier:ident];
//    [self _setUuid];
//}



#pragma mark - Overriden Methods

- (BOOL)matchesSearchWithString:(NSString*)searchString
{
    NSComparisonResult result = [self.title.valueAsString compare:searchString
                                                          options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)
                                                            range:NSMakeRange(0, [searchString length])];
    
    return (result == NSOrderedSame) || [super matchesSearchWithString:searchString];
}

#pragma mark - Properties

- (SWValue*)pageIdentifier
{
     return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

- (SWValue*)title
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}

- (SWValue*)shortTitle
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 2];
}

- (SWValue*)modalStyle
{
     return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 3];
}

- (SWValue*)pageTransitionStyle
{
     return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 4];
}

- (SWValue*)enabledInterfaceIdiom
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 5];
}

//- (SWValue*)interfaceIdiom
//{
//    static SWValue *value = nil;
//    if ( value == nil ) value = [SWValue valueWithDouble:SWPageInterfaceIdiomPad];
//    return value;
//}

- (SWExpression*)backgroundColor
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 6];
}

- (SWExpression*)backgroundImage
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 7];
}

- (SWValue*)backgroundImageAspectRatio
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 8];
}

- (SWExpression*)hidden
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 9];
}


- (NSInteger)documentPageIndex
{
    return [_docModel.pages indexOfObjectIdenticalTo:self];    // cucut
}

#pragma mark Page Observer

//- (void)addPageObserver:(id<PageObserver>)observer
//{
//    [super addObjectObserver:observer];
//}
//
//- (void)removePageObserver:(id<PageObserver>)observer
//{
//    [super removeObjectObserver:observer];
//}


#pragma mark - default size


// page default size
- (CGSize)defaultSizePortraitWithDeviceIdiomV:(SWDeviceInterfaceIdiom)deviceIdiom
{
    SWPageInterfaceIdiom idiom;
    if ( deviceIdiom == SWDeviceInterfaceIdiomPhone ) idiom = SWPageInterfaceIdiomPhone;
    else idiom = [self.enabledInterfaceIdiom valueAsInteger];
    
    if ( idiom == SWPageInterfaceIdiomPhone )
        return CGSizeMake( 320, 1200 );
    
    return CGSizeMake(768, 960);
}


- (CGSize)defaultSizeLandscapeWithDeviceIdiomV:(SWDeviceInterfaceIdiom)deviceIdiom
{
    SWPageInterfaceIdiom idiom;
    if ( deviceIdiom == SWDeviceInterfaceIdiomPhone ) idiom = SWPageInterfaceIdiomPhone;
    else idiom = [self.enabledInterfaceIdiom valueAsInteger];
    
    if ( idiom == SWPageInterfaceIdiomPhone )
        return CGSizeMake( 480, 1200 );
    
    return CGSizeMake(1024, 704);
    
}


// page default size
- (CGSize)defaultSizePortrait
{
    SWPageInterfaceIdiom idiom = [self.enabledInterfaceIdiom valueAsInteger];
    return [self _defaultSizePortraitWithPageIdiom:idiom];
}


- (CGSize)defaultSizeLandscape
{
    SWPageInterfaceIdiom idiom = [self.enabledInterfaceIdiom valueAsInteger];
    return [self _defaultSizeLandscapeWithPageIdiom:idiom];
}


// page default size
- (CGSize)defaultSizePortraitWithDeviceIdiom:(SWDeviceInterfaceIdiom)deviceIdiom
{
    SWPageInterfaceIdiom idiom = SWPageInterfaceIdiomPad;
    if ( deviceIdiom == SWDeviceInterfaceIdiomPhone ) idiom = SWPageInterfaceIdiomPhone;
    return [self _defaultSizePortraitWithPageIdiom:idiom];
}


- (CGSize)defaultSizeLandscapeWithDeviceIdiom:(SWDeviceInterfaceIdiom)deviceIdiom
{
    SWPageInterfaceIdiom idiom = SWPageInterfaceIdiomPad;
    if ( deviceIdiom == SWDeviceInterfaceIdiomPhone ) idiom = SWPageInterfaceIdiomPhone;
    return [self _defaultSizeLandscapeWithPageIdiom:idiom];
}


// page default size
- (CGSize)_defaultSizePortraitWithPageIdiom:(SWPageInterfaceIdiom)idiom
{
    if ( idiom == SWPageInterfaceIdiomPhone )
        return CGSizeMake( 320, 960 );
    
    return CGSizeMake(768, 960);
}


- (CGSize)_defaultSizeLandscapeWithPageIdiom:(SWPageInterfaceIdiom)idiom
{
    if ( idiom == SWPageInterfaceIdiomPhone )
        return CGSizeMake( 568, 704 );
    
    return CGSizeMake(1024, 704);
}



#pragma mark - Main Methods

- (void)addItem:(SWItem*)item
{
    NSInteger index = _items.count;
    [self insertItems:@[item] atIndexes:[NSIndexSet indexSetWithIndex:index]];  // a dalt de tot
}

//- (void)addItem:(SWItem*)item atIndex:(NSInteger)index
//{
//    [self addItems:[NSArray arrayWithObject:item] atIndexes:[NSIndexSet indexSetWithIndex:index]];
//}

- (void)insertItems:(NSArray*)items atIndexes:(NSIndexSet*)indexes
{    
    NSIndexSet *selectedIndexes = [self selectedItemIndexes];
    [self deselectItemsAtIndexes:selectedIndexes];
    
    if ( indexes == nil )
        indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(_items.count, items.count)];
    
    NSAssert( indexes.count > 0 && items.count > 0 && items.count == indexes.count, @"Inserting inconsistent number of items and indexes");
    
    for ( SWItem *item in items )
    {
        [item awakeFromSleepIfNeeded];
        item.parentObject = self;
    }
    
    _selectedIndexes = nil;

    [_items insertObjects:items atIndexes:indexes];
    
    NSUndoManager *undoManager = _docModel.undoManager;
    
    [[undoManager prepareWithInvocationTarget:self] removeItemsAtIndexes:indexes];
    [undoManager setActionName:indexes.count>1?NSLocalizedString(@"Add Items",nil):NSLocalizedString(@"Add Item",nil)];
    
    NSArray *observersCopy = [_observers copy];
    for (id<PageObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(page:didInsertItemsAtIndexes:isGrouping:)])
            [observer page:self didInsertItemsAtIndexes:indexes isGrouping:NO];
    }
    
    [self selectItemsAtIndexes:indexes];
}


- (void)removeItemAtIndex:(NSUInteger)index
{
    [self removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:index]];
}


- (void)removeItemsAtIndexes:(NSIndexSet*)indexes
{    
    if (indexes.count == 0)
        return;
    
    [self deselectItemsAtIndexes:indexes];
    
    _selectedIndexes = nil;
    
    NSArray *observersCopy = [_observers copy];
//    for (id<PageObserver> observer in observersCopy)
//    {
//        if ([observer respondsToSelector:@selector(page:willRemoveItemsAtIndexes:)])
//            [observer page:self willRemoveItemsAtIndexes:indexes];
//    }
    
    NSArray *items = [_items objectsAtIndexes:indexes];
    
    [items makeObjectsPerformSelector:@selector(putToSleep)];
    [_items removeObjectsAtIndexes:indexes];
    
    NSUndoManager *undoManager = _docModel.undoManager;
    
    [[undoManager prepareWithInvocationTarget:self] insertItems:items atIndexes:indexes];
    [undoManager setActionName:indexes.count>1?NSLocalizedString(@"Remove Items",nil):NSLocalizedString(@"Remove Item",nil)];
    
    for (id<PageObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(page:didRemoveItemsAtIndexes:isGrouping:)])
            [observer page:self didRemoveItemsAtIndexes:indexes isGrouping:NO];
    }
}


- (void)sendToBackItemAtIndex:(NSInteger)index
{    
    [self moveItemAtPosition:index toPosition:0];
}


- (void)bringToFrontItemAtIndex:(NSInteger)index
{    
    [self moveItemAtPosition:index toPosition:_items.count-1];
}


- (void)moveItemAtPosition:(NSInteger)starPosition toPosition:(NSInteger)finalPosition
{
    SWItem *item = [_items objectAtIndex:starPosition];
    
    _selectedIndexes = nil;
    
    [_items removeObjectAtIndex:starPosition];
    [_items insertObject:item atIndex:finalPosition];

    NSUndoManager *undoManager = _docModel.undoManager;

    [[undoManager prepareWithInvocationTarget:self] moveItemAtPosition:finalPosition toPosition:starPosition];
    [undoManager setActionName:NSLocalizedString(@"Move Item",nil)];
    
    NSArray *observersCopy = [_observers copy];
    for (id<PageObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(page:didMoveItemAtPosition:toPosition:)])
            [observer page:self didMoveItemAtPosition:starPosition toPosition:finalPosition];
    }
}


- (void)selectItem:(SWItem*)item
{
    NSInteger index = [_items indexOfObjectIdenticalTo:item];
    if ( index != NSNotFound )
    {
        [self selectItemsAtIndexes:[NSIndexSet indexSetWithIndex:index]];
    }
}

//// Selecciona o deselecciona un groupItem aplicant el enabled state. Deselecciona tots els
//- (void)setChildGroupItemV:(SWGroupItem*)groupItem selected:(BOOL)selected enabled:(BOOL)pickEnabled
//{
//    BOOL changeSelected = (groupItem.selected != selected);
//    BOOL changeEnabled = (groupItem.pickEnabled != pickEnabled);
//    
//    if ( ! (changeSelected || changeEnabled) )
//        return;
//
//    NSInteger index = [_items indexOfObjectIdenticalTo:groupItem];
//    if ( index != NSNotFound )
//    {
//        if ( changeSelected )
//        {
//            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
//            
//            if ( selected )
//                [self selectItemsAtIndexes:indexSet];
//            else
//                [self deselectItemsAtIndexes:indexSet];
//        }
//        
//        if ( changeEnabled )
//        {
//            groupItem.pickEnabled = pickEnabled;
//            NSArray *observers = [_observers copy];
//            for (id<PageObserver> observer in observers)
//            {
//                if ([observer respondsToSelector:@selector(page:groupItemAtIndex:didChangePickEnabledStateTo:)])
//                    [observer page:self groupItemAtIndex:index didChangePickEnabledStateTo:pickEnabled];
//            }
//        }
//    }
//}


// Selecciona o deselecciona un groupItem aplicant el enabled state
- (void)setChildGroupItem:(id<SWGroup,SWSelectable>)groupItem selected:(BOOL)select enabled:(BOOL)pickEnabled
{
    BOOL changeSelected = (groupItem.selected != select);
    BOOL changeEnabled = (groupItem.pickEnabled != pickEnabled);
    
    if ( ! (changeSelected || changeEnabled) )
        return;

    NSInteger index = [_items indexOfObjectIdenticalTo:groupItem];
    if ( index != NSNotFound )
    {
        if ( select && pickEnabled )
        {
            // deseleccionem els items germans
            NSIndexSet *excludingIndexSet = [self _selectedItemIndexesExcludingItem:groupItem];
            [self deselectItemsAtIndexes:excludingIndexSet];
        }
    
        if ( changeSelected )
        {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
            
            if ( select )
                [self selectItemsAtIndexes:indexSet];
            else
                [self deselectItemsAtIndexes:indexSet];
        }
        
        if ( changeEnabled )
        {
            [groupItem primitiveSetPickEnabled:pickEnabled];
            NSArray *observers = [_observers copy];
            for (id<PageObserver> observer in observers)
            {
                if ([observer respondsToSelector:@selector(group:groupItemAtIndex:didChangePickEnabledStateTo:)])
                    [observer group:self groupItemAtIndex:index didChangePickEnabledStateTo:pickEnabled];
            }
        }
    }
}


//- (void)selectItemsAtIndexesV:(NSIndexSet*)indexes
//{
//    if (indexes.count == 0)
//        return;
//
//    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
//    {
//        SWItem *item = [_items objectAtIndex:idx];
//        [item primitiveSetSelected:YES];
//    }];
//    
//    _selectedIndexes = nil;
//    
//    NSArray *observers = [_observers copy];
//    for (id<PageObserver> observer in observers)
//    {
//        if ([observer respondsToSelector:@selector(page:didSelectItemsAtIndexes:)])
//            [observer page:self didSelectItemsAtIndexes:indexes];
//    }
//}

- (void)selectItemsAtIndexes:(NSIndexSet*)indexes
{
    if (indexes.count == 0)
        return;

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
    for (id<PageObserver> observer in observers)
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
    for (id<PageObserver> observer in observers)
    {
        if ([observer respondsToSelector:@selector(group:didDeselectItemsAtIndexes:)])
            [observer group:self didDeselectItemsAtIndexes:indexes];
    }
    
    if ( _docModel.allowsMultipleSelection && [self selectedItemIndexes].count == 0 )
    {
        _docModel.allowsMultipleSelection = NO;
    }
}


//- (void)deselectAllItems   // to deprecate
//{
//    NSIndexSet *indexes = [self selectedItemIndexes];
//    [self deselectItemsAtIndexes:indexes];
//}


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
    for (id<PageObserver> observer in observers)
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
    for (id<PageObserver> observer in observers)
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


- (void)insertNewGroupItemForItemsAtIndexes:(NSIndexSet*)indexes
{
    if (indexes.count == 0)
        return;
    
    SWGroupItem *groupItem = [[SWGroupItem alloc] initInPage:self];
    [self insertGroupItem:groupItem forItemsAtIndexes:indexes];
}


//- (void)insertGroupItemVVVV:(SWGroupItem*)groupItem forItemsAtIndexes:(NSIndexSet*)indexes
//{
//    if (indexes.count == 0)
//        return;
//    
//    [self deselectItemsAtIndexes:indexes];
//    
//        // avisem als observers que estem a punt d'agrupar
//    
//    NSArray *observersCopy = [_observers copy];
////    for (id<PageObserver> observer in observersCopy)
////    {
////        if ([observer respondsToSelector:@selector(page:willGroupItemsAtIndexes:)])
////            [observer page:self willGroupItemsAtIndexes:indexes];
////    }
//    
//    for (id<PageObserver> observer in observersCopy)
//    {
//        if ([observer respondsToSelector:@selector(page:willRemoveItemsAtIndexes:)])
//            [observer page:self willRemoveItemsAtIndexes:indexes];
//    }
//    
//    // determinem el frame del groupItem
//
//    CGFloat minXPortrait = CGFLOAT_MAX;
//    CGFloat minYPortrait = CGFLOAT_MAX;
//    CGFloat maxXPortrait = CGFLOAT_MIN;
//    CGFloat maxYPortrait = CGFLOAT_MIN;
//    
//    CGFloat minXLandscape = CGFLOAT_MAX;
//    CGFloat minYLandscape = CGFLOAT_MAX;
//    CGFloat maxXLandscape = CGFLOAT_MIN;
//    CGFloat maxYLandscape = CGFLOAT_MIN;
//
//    NSArray *itemsToGroup = [_items objectsAtIndexes:indexes];
//    
//    for ( SWItem *item in itemsToGroup )
//    {
//        CGRect rect = [item.framePortrait valueAsCGRect];
//        if ( rect.origin.x < minXPortrait  ) minXPortrait = rect.origin.x;
//        if ( rect.origin.x+rect.size.width > maxXPortrait ) maxXPortrait = rect.origin.x+rect.size.width;
//        if ( rect.origin.y < minYPortrait  ) minYPortrait = rect.origin.y;
//        if ( rect.origin.y+rect.size.height > maxYPortrait ) maxYPortrait = rect.origin.y+rect.size.height;
//        
//        rect = [item.frameLandscape valueAsCGRect];
//        if ( rect.origin.x < minXLandscape  ) minXLandscape = rect.origin.x;
//        if ( rect.origin.x+rect.size.width > maxXLandscape ) maxXLandscape = rect.origin.x+rect.size.width;
//        if ( rect.origin.y < minYLandscape  ) minYLandscape = rect.origin.y;
//        if ( rect.origin.y+rect.size.height > maxYLandscape ) maxYLandscape = rect.origin.y+rect.size.height;
//    }
//    
//    CGRect groupFramePortrait = CGRectMake(minXPortrait, minYPortrait, maxXPortrait-minXPortrait, maxYPortrait-minYPortrait);
//    CGRect groupFrameLandscape = CGRectMake(minXLandscape, minYLandscape, maxXLandscape-minXLandscape, maxYLandscape-minYLandscape);
//    
//    [groupItem.framePortrait setValueAsCGRect:groupFramePortrait];
//    [groupItem.frameLandscape setValueAsCGRect:groupFrameLandscape];
//    
//
//    
//    // ajustem els frames dels items i marquem que ara pertanyen al grup
//    
//    [groupItem setGroupedItems:itemsToGroup]; // <- agefim els items al grup
//    for ( SWItem *item in itemsToGroup )
//    {
//        //item.group = groupItem;
//        
//        CGRect rect = [item.framePortrait valueAsCGRect];
//        rect.origin.x -= groupFramePortrait.origin.x;
//        rect.origin.y -= groupFramePortrait.origin.y;
//        [item.framePortrait setValueAsCGRect:rect];
//        
//        rect = [item.frameLandscape valueAsCGRect];
//        rect.origin.x -= groupFrameLandscape.origin.x;
//        rect.origin.y -= groupFrameLandscape.origin.y;
//        [item.frameLandscape setValueAsCGRect:rect];
//    }
//
//    // treiem els items de la pagina
//    
//    [_items removeObjectsAtIndexes:indexes];
//    
//    for (id<PageObserver> observer in observersCopy)
//    {
//        if ([observer respondsToSelector:@selector(page:didRemoveItemsAtIndexes:)])
//            [observer page:self didRemoveItemsAtIndexes:indexes];
//    }
//    
//    // i posem el grup a la pagina
//    
//    NSInteger groupInsertIndex = [indexes lastIndex] - [indexes count] + 1;
//    [_items insertObject:groupItem atIndex:groupInsertIndex];
//    
//    // programem el undo manager
//    
//    NSUndoManager *undoManager = _docModel.undoManager;
//
//    [[undoManager prepareWithInvocationTarget:self] removeGroupItemAtIndex:groupInsertIndex];
//    [undoManager setActionName:NSLocalizedString(@"Group Items",nil)];
//    
//    // avisem als observers que hem agrupat
//    
////    for (id<PageObserver> observer in observersCopy)
////    {
////        if ([observer respondsToSelector:@selector(page:didInsertGroupItemAtIndex:)])
////            [observer page:self didInsertGroupItemAtIndex:groupInsertIndex];
////    }
//    
//    for (id<PageObserver> observer in observersCopy)
//    {
//        if ([observer respondsToSelector:@selector(page:didInsertItemsAtIndexes:)])
//            [observer page:self didInsertItemsAtIndexes:[NSIndexSet indexSetWithIndex:groupInsertIndex]];
//    }
//    
//    [self selectItemsAtIndexes:[NSIndexSet indexSetWithIndex:groupInsertIndex]];
//    
//}


- (CGRect)_computeGroupItemFrameForItems:(NSArray*)itemsToGroup orientation:(UIInterfaceOrientation)orientation idiom:(SWDeviceInterfaceIdiom)idiom
{
    if ( itemsToGroup.count == 0 )
        return CGRectZero;
    
    CGPoint min = CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
    CGPoint max = CGPointMake(-CGFLOAT_MAX, -CGFLOAT_MAX);
    
    for ( SWItem *item in itemsToGroup )
    {
        CGRect rect = [item frameForOrientation:orientation idiom:idiom];
        if ( rect.origin.x < min.x  ) min.x = rect.origin.x;
        if ( rect.origin.x+rect.size.width > max.x ) max.x = rect.origin.x+rect.size.width;
        if ( rect.origin.y < min.y  ) min.y = rect.origin.y;
        if ( rect.origin.y+rect.size.height > max.y ) max.y = rect.origin.y+rect.size.height;
    }
    
    CGRect groupFrame = CGRectMake( min.x, min.y, max.x-min.x, max.y-min.y );

    return groupFrame;
}


- (void)insertGroupItem:(SWGroupItem*)groupItem forItemsAtIndexes:(NSIndexSet*)indexes
{
    if (indexes.count == 0)
        return;
    
    [self deselectItemsAtIndexes:indexes];
    
    // avisem als observers que estem a punt d'agrupar
    
    NSArray *observersCopy = [_observers copy];
//    for (id<PageObserver> observer in observersCopy)
//    {
//        if ([observer respondsToSelector:@selector(page:willGroupItemsAtIndexes:)])
//            [observer page:self willGroupItemsAtIndexes:indexes];
//    }
    
//    for (id<PageObserver> observer in observersCopy)
//    {
//        if ([observer respondsToSelector:@selector(page:willRemoveItemsAtIndexes:)])
//            [observer page:self willRemoveItemsAtIndexes:indexes];
//    }
    
    // determinem el frame del groupItem

//    CGFloat minXPortrait = CGFLOAT_MAX;
//    CGFloat minYPortrait = CGFLOAT_MAX;
//    CGFloat maxXPortrait = -CGFLOAT_MAX;
//    CGFloat maxYPortrait = -CGFLOAT_MAX;
//    
//    CGFloat minXLandscape = CGFLOAT_MAX;
//    CGFloat minYLandscape = CGFLOAT_MAX;
//    CGFloat maxXLandscape = -CGFLOAT_MAX;
//    CGFloat maxYLandscape = -CGFLOAT_MAX;
//    
//    CGFloat minXPortraitPhone = CGFLOAT_MAX;
//    CGFloat minYPortraitPhone = CGFLOAT_MAX;
//    CGFloat maxXPortraitPhone = -CGFLOAT_MAX;
//    CGFloat maxYPortraitPhone = -CGFLOAT_MAX;
//    
//    CGFloat minXLandscapePhone = CGFLOAT_MAX;
//    CGFloat minYLandscapePhone = CGFLOAT_MAX;
//    CGFloat maxXLandscapePhone = -CGFLOAT_MAX;
//    CGFloat maxYLandscapePhone = -CGFLOAT_MAX;
//    
//    NSArray *itemsToGroup = [_items objectsAtIndexes:indexes];
//    
//    for ( SWItem *item in itemsToGroup )
//    {
//        CGRect rect = [item.framePortrait valueAsCGRect];
//        if ( rect.origin.x < minXPortrait  ) minXPortrait = rect.origin.x;
//        if ( rect.origin.x+rect.size.width > maxXPortrait ) maxXPortrait = rect.origin.x+rect.size.width;
//        if ( rect.origin.y < minYPortrait  ) minYPortrait = rect.origin.y;
//        if ( rect.origin.y+rect.size.height > maxYPortrait ) maxYPortrait = rect.origin.y+rect.size.height;
//        
//        rect = [item.frameLandscape valueAsCGRect];
//        if ( rect.origin.x < minXLandscape  ) minXLandscape = rect.origin.x;
//        if ( rect.origin.x+rect.size.width > maxXLandscape ) maxXLandscape = rect.origin.x+rect.size.width;
//        if ( rect.origin.y < minYLandscape  ) minYLandscape = rect.origin.y;
//        if ( rect.origin.y+rect.size.height > maxYLandscape ) maxYLandscape = rect.origin.y+rect.size.height;
//        
//        rect = [item.framePortraitPhone valueAsCGRect];
//        if ( rect.origin.x < minXPortraitPhone  ) minXPortraitPhone = rect.origin.x;
//        if ( rect.origin.x+rect.size.width > maxXPortraitPhone ) maxXPortraitPhone = rect.origin.x+rect.size.width;
//        if ( rect.origin.y < minYPortraitPhone  ) minYPortraitPhone = rect.origin.y;
//        if ( rect.origin.y+rect.size.height > maxYPortraitPhone ) maxYPortraitPhone = rect.origin.y+rect.size.height;
//        
//        rect = [item.frameLandscapePhone valueAsCGRect];
//        if ( rect.origin.x < minXLandscapePhone  ) minXLandscapePhone = rect.origin.x;
//        if ( rect.origin.x+rect.size.width > maxXLandscapePhone ) maxXLandscapePhone = rect.origin.x+rect.size.width;
//        if ( rect.origin.y < minYLandscapePhone  ) minYLandscapePhone = rect.origin.y;
//        if ( rect.origin.y+rect.size.height > maxYLandscapePhone ) maxYLandscapePhone = rect.origin.y+rect.size.height;
//    }
//    
//    CGRect groupFramePortrait = CGRectMake(minXPortrait, minYPortrait, maxXPortrait-minXPortrait, maxYPortrait-minYPortrait);
//    CGRect groupFrameLandscape = CGRectMake(minXLandscape, minYLandscape, maxXLandscape-minXLandscape, maxYLandscape-minYLandscape);
//    CGRect groupFramePortraitPhone = CGRectMake(minXPortraitPhone, minYPortraitPhone, maxXPortraitPhone-minXPortraitPhone, maxYPortraitPhone-minYPortraitPhone);
//    CGRect groupFrameLandscapePhone = CGRectMake(minXLandscapePhone, minYLandscapePhone, maxXLandscapePhone-minXLandscapePhone, maxYLandscapePhone-minYLandscapePhone);


    NSArray *itemsToGroup = [_items objectsAtIndexes:indexes];
    
    CGRect groupFramePortrait = [self _computeGroupItemFrameForItems:itemsToGroup orientation:UIInterfaceOrientationPortrait idiom:SWDeviceInterfaceIdiomPad];
    CGRect groupFrameLandscape = [self _computeGroupItemFrameForItems:itemsToGroup orientation:UIInterfaceOrientationLandscapeLeft idiom:SWDeviceInterfaceIdiomPad];
    CGRect groupFramePortraitPhone = [self _computeGroupItemFrameForItems:itemsToGroup orientation:UIInterfaceOrientationPortrait idiom:SWDeviceInterfaceIdiomPhone];
    CGRect groupFrameLandscapePhone = [self _computeGroupItemFrameForItems:itemsToGroup orientation:UIInterfaceOrientationLandscapeLeft idiom:SWDeviceInterfaceIdiomPhone];
    
    [groupItem.framePortrait setValueAsCGRect:groupFramePortrait];
    [groupItem.frameLandscape setValueAsCGRect:groupFrameLandscape];
    [groupItem.framePortraitPhone setValueAsCGRect:groupFramePortraitPhone];
    [groupItem.frameLandscapePhone setValueAsCGRect:groupFrameLandscapePhone];
    
    // treiem els items de la pagina
    
    [_items removeObjectsAtIndexes:indexes];
    
    _beginGroupingForItems( itemsToGroup );
    for (id<PageObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(page:didRemoveItemsAtIndexes:isGrouping:)])
            [observer page:self didRemoveItemsAtIndexes:indexes isGrouping:YES];
    }

    // ajustem els frames dels items i marquem que ara pertanyen al grup
    
    for ( SWItem *item in itemsToGroup )
    {
        //item.group = groupItem;
        item.parentObject = groupItem;
        
        CGRect rect = [item.framePortrait valueAsCGRect];
        rect.origin.x -= groupFramePortrait.origin.x;
        rect.origin.y -= groupFramePortrait.origin.y;
        [item.framePortrait setValueAsCGRect:rect];
        
        rect = [item.frameLandscape valueAsCGRect];
        rect.origin.x -= groupFrameLandscape.origin.x;
        rect.origin.y -= groupFrameLandscape.origin.y;
        [item.frameLandscape setValueAsCGRect:rect];
        
        rect = [item.framePortraitPhone valueAsCGRect];
        rect.origin.x -= groupFramePortraitPhone.origin.x;
        rect.origin.y -= groupFramePortraitPhone.origin.y;
        [item.framePortraitPhone setValueAsCGRect:rect];
        
        rect = [item.frameLandscapePhone valueAsCGRect];
        rect.origin.x -= groupFrameLandscapePhone.origin.x;
        rect.origin.y -= groupFrameLandscapePhone.origin.y;
        [item.frameLandscapePhone setValueAsCGRect:rect];
    }
    
    // afegim els items al grup
    
    [groupItem setItems:itemsToGroup];
    
    // i posem el grup a la pagina
    
    NSInteger groupInsertIndex = [indexes lastIndex] - [indexes count] + 1;
    
    [groupItem awakeFromSleepIfNeeded];
    [_items insertObject:groupItem atIndex:groupInsertIndex];
    
    // programem el undo manager
    
    NSUndoManager *undoManager = _docModel.undoManager;

    [[undoManager prepareWithInvocationTarget:self] _replaceGroupItemAtIndex:groupInsertIndex byInsertingItemsAtIndexes:indexes];
    [undoManager setActionName:NSLocalizedString(@"Group Items",nil)];
    
    // avisem als observers que hem agrupat
    
//    for (id<PageObserver> observer in observersCopy)
//    {
//        if ([observer respondsToSelector:@selector(page:didInsertGroupItemAtIndex:)])
//            [observer page:self didInsertGroupItemAtIndex:groupInsertIndex];
//    }
    
    for (id<PageObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(page:didInsertItemsAtIndexes:isGrouping:)])
            [observer page:self didInsertItemsAtIndexes:[NSIndexSet indexSetWithIndex:groupInsertIndex] isGrouping:YES];
    }
    
    _endGroupingForItems( itemsToGroup );
    [self selectItemsAtIndexes:[NSIndexSet indexSetWithIndex:groupInsertIndex]];
    
}


- (void)removeGroupItemAtIndex:(NSInteger)index
{
    [self _replaceGroupItemAtIndex:index byInsertingItemsAtIndexes:nil];
}


- (void)_replaceGroupItemAtIndex:(NSInteger)index byInsertingItemsAtIndexes:(NSIndexSet*)itemInsertIndexes
{
    SWGroupItem *groupItem = [_items objectAtIndex:index];
    
    if ( ![groupItem isGroupItem] )
        return;
    
    [self deselectItemsAtIndexes:[NSIndexSet indexSetWithIndex:index]];
    
    // avisem als observers que estem a punt de desagrupar
    
    NSArray *observersCopy = [_observers copy];
//    for (id<PageObserver> observer in observersCopy)
//    {
//        if ([observer respondsToSelector:@selector(page:willUngroupGroupItemAtIndex:)])
//            [observer page:self willUngroupGroupItemAtIndex:index];
//    }
    
//    for (id<PageObserver> observer in observersCopy)
//    {
//        if ([observer respondsToSelector:@selector(page:willRemoveItemsAtIndexes:)])
//            [observer page:self willRemoveItemsAtIndexes:[NSIndexSet indexSetWithIndex:index]];
//    }
    
    // aquests son els items per desagrupar
    
    NSArray *itemsToUngroup = groupItem.items;
    
    // treiem el grup de la pagina
    
    _beginGroupingForItems( itemsToUngroup );
    [_items removeObjectAtIndex:index];
    
    for (id<PageObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(page:didRemoveItemsAtIndexes:isGrouping:)])
            [observer page:self didRemoveItemsAtIndexes:[NSIndexSet indexSetWithIndex:index] isGrouping:YES];
    }
    
    // determinem els frame del groupitem
    CGRect groupFramePortrait = [groupItem.framePortrait valueAsCGRect];
    CGRect groupFrameLandscape = [groupItem.frameLandscape valueAsCGRect];
    CGRect groupFramePortraitPhone = [groupItem.framePortraitPhone valueAsCGRect];
    CGRect groupFrameLandscapePhone = [groupItem.frameLandscapePhone valueAsCGRect];
    
    // ajustem els frames dels items i marquem que ara pertanyen a la pagina
    
    for ( SWItem *item in itemsToUngroup )
    {
        item.parentObject = self;
        
        CGRect rect = [item.framePortrait valueAsCGRect];
        rect.origin.x += groupFramePortrait.origin.x;
        rect.origin.y += groupFramePortrait.origin.y;
        [item.framePortrait setValueAsCGRect:rect];
        
        rect = [item.frameLandscape valueAsCGRect];
        rect.origin.x += groupFrameLandscape.origin.x;
        rect.origin.y += groupFrameLandscape.origin.y;
        [item.frameLandscape setValueAsCGRect:rect];
        
        rect = [item.framePortraitPhone valueAsCGRect];
        rect.origin.x += groupFramePortraitPhone.origin.x;
        rect.origin.y += groupFramePortraitPhone.origin.y;
        [item.framePortraitPhone setValueAsCGRect:rect];
        
        rect = [item.frameLandscapePhone valueAsCGRect];
        rect.origin.x += groupFrameLandscapePhone.origin.x;
        rect.origin.y += groupFrameLandscapePhone.origin.y;
        [item.frameLandscapePhone setValueAsCGRect:rect];
        
    }
    
    // treiem els items del grup
    
    [groupItem setItems:nil];
    [groupItem putToSleep];
    // ^-- posem el groupItem to Sleep despres de treure els grouped items, no volem els items es possin també a sleep!

    // i posem els items a la pagina
    
    if ( itemInsertIndexes == nil )
        itemInsertIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, itemsToUngroup.count)];
    
    NSAssert( itemInsertIndexes.count == itemsToUngroup.count, @"Inconsistent ungroup item count");
    
    [_items insertObjects:itemsToUngroup atIndexes:itemInsertIndexes];
    
    // programem el undo manager
    
    NSUndoManager *undoManager = _docModel.undoManager;

    [[undoManager prepareWithInvocationTarget:self] insertGroupItem:groupItem forItemsAtIndexes:itemInsertIndexes];
    [undoManager setActionName:NSLocalizedString(@"Ungroup Items",nil)];
    
    // avisem als observers que hem desagrupat
    
//    for (id<PageObserver> observer in observersCopy)
//    {
//        if ([observer respondsToSelector:@selector(page:didInsertUngroupedItemsAtIndexes:)])
//            [observer page:self didInsertUngroupedItemsAtIndexes:itemInsertIndexes];
//    }
    
    for (id<PageObserver> observer in observersCopy)
    {
        if ([observer respondsToSelector:@selector(page:didInsertItemsAtIndexes:isGrouping:)])
            [observer page:self didInsertItemsAtIndexes:itemInsertIndexes isGrouping:YES];
    }
    
    _endGroupingForItems( itemsToUngroup );
    [self selectItemsAtIndexes:itemInsertIndexes];
}


static void _beginGroupingForItems( NSArray *items )
{
    for ( SWItem *item in items )
        [item prepareForGroupOperation];
}


static void _endGroupingForItems( NSArray *items )
{
    for ( SWItem *item in items )
        [item finishGroupOperation];
}


#pragma mark - SWValueHolder

- (void)value:(SWExpression *)expression didTriggerWithChange:(BOOL)changed
{
    if ( expression == self.hidden )
    {
        if ( changed )
            [_docModel setPagesVisibilityDirty];
    }
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

@end
