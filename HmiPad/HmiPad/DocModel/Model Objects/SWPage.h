//
//  SWPage.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/14/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWModelTypes.h"
#import "SWEnumTypes.h"
#import "SWGroup.h"

#import "SWObject.h"
#import "QuickCoder.h"
#import "SymbolicCoder.h"

@class SWItem;
@class SWGroupItem;
@class SWDocumentModel;
@class SWPage;

@protocol PageObserver<SWObjectObserver,SWGroupObserver>

@optional
- (void)page:(SWPage*)page didInsertItemsAtIndexes:(NSIndexSet*)indexes isGrouping:(BOOL)isGrouping;
- (void)page:(SWPage*)page didRemoveItemsAtIndexes:(NSIndexSet*)indexes isGrouping:(BOOL)isGrouping;
- (void)page:(SWPage*)page didMoveItemAtPosition:(NSInteger)starPosition toPosition:(NSInteger)finalPosition;

//- (void)page:(SWPage*)page didSelectItemsAtIndexes:(NSIndexSet*)indexes;
//- (void)page:(SWPage*)page didDeselectItemsAtIndexes:(NSIndexSet*)indexes;
//- (void)page:(SWPage*)page groupItemAtIndex:(NSInteger)index didChangePickEnabledStateTo:(BOOL)state;
//
//- (void)page:(SWPage*)page didLockItemsAtIndexes:(NSIndexSet*)indexes;
//- (void)page:(SWPage*)page didUnlockItemsAtIndexes:(NSIndexSet*)indexes;

@end

@interface SWPage : SWObject <SWGroup, QuickCoding, SymbolicCoding>
{

}

@property (nonatomic, readonly, strong) NSString *uuid;

// -- Page Values -- //
@property (nonatomic, readonly) SWValue *pageIdentifier;
@property (nonatomic, readonly) SWValue *title;
@property (nonatomic, readonly) SWValue *shortTitle;
@property (nonatomic, readonly) SWValue *modalStyle;
@property (nonatomic, readonly) SWValue *pageTransitionStyle;
@property (nonatomic, readonly) SWValue *enabledInterfaceIdiom;
@property (nonatomic, readonly) SWExpression *backgroundColor;
@property (nonatomic, readonly) SWExpression *backgroundImage;
@property (nonatomic, readonly) SWValue *backgroundImageAspectRatio;
@property (nonatomic, readonly) SWExpression *hidden;


//// observing
//- (void)addPageObserver:(id<PageObserver>)observer;
//- (void)removePageObserver:(id<PageObserver>)observer;

//// page default size
//- (CGSize)defaultSizePortrait;
//- (CGSize)defaultSizeLandscape;

// page default size
- (CGSize)defaultSizePortraitWithDeviceIdiom:(SWDeviceInterfaceIdiom)deviceIdiom;
- (CGSize)defaultSizeLandscapeWithDeviceIdiom:(SWDeviceInterfaceIdiom)deviceIdiom;

// Insertion, deletion
- (void)addItem:(SWItem*)item;
- (void)insertItems:(NSArray*)items atIndexes:(NSIndexSet*)indexes;
- (void)removeItemAtIndex:(NSUInteger)index;
- (void)removeItemsAtIndexes:(NSIndexSet*)indexes;

// layout positioning
- (void)sendToBackItemAtIndex:(NSInteger)index;
- (void)bringToFrontItemAtIndex:(NSInteger)index;
- (void)moveItemAtPosition:(NSInteger)starPosition toPosition:(NSInteger)finalPosition;

// selection
//- (void)selectItemsAtIndexes:(NSIndexSet*)indexes;
//- (void)deselectItemsAtIndexes:(NSIndexSet*)indexes;
//- (NSIndexSet*)selectedItemIndexes;
//- (void)selectItem:(SWItem*)item;

// grouping
- (void)insertNewGroupItemForItemsAtIndexes:(NSIndexSet*)indexes;
- (void)removeGroupItemAtIndex:(NSInteger)index;

//// layout locking
//- (void)lockItemsAtIndexes:(NSIndexSet*)indexes;
//- (void)unlockItemsAtIndexes:(NSIndexSet*)indexes;

// -- Page Properties -- //
//@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, readonly) NSInteger documentPageIndex;

// -- Page ScreenShots -- //
@property (nonatomic, readonly) BOOL screenShotIsAvailable;
@property (nonatomic, readonly) UIImage *screenShot;

//- (void)saveScreenShot:(UIImage*)screenShot;

@end
