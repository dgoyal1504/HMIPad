//
//  SWGroup.h
//  HmiPad
//
//  Created by Joan Lluch on 21/01/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWObject.h"

@class SWItem;


#pragma mark - SWSelectable

@protocol SWSelectable

// Properties
@required
@property (nonatomic, readonly) BOOL selected;
@property (nonatomic, readonly) BOOL locked;
@property (nonatomic, readonly) BOOL pickEnabled;

// Setters
@required
- (void)primitiveSetSelected:(BOOL)selected;
- (void)primitiveSetLocked:(BOOL)locked;
- (void)primitiveSetPickEnabled:(BOOL)enabled;

// Used by SWGroup items to prevent SWSelectable objects to get put on sleep upon grouping operations
@required
- (void)prepareForGroupOperation;
- (void)finishGroupOperation;

@end


#pragma mark - SWGroup

@protocol SWGroup<SWObjectGrouping>

// properties
@required
@property (nonatomic, strong) NSArray *items;       // Should Contain objects conforming to SWSelectable
@property (nonatomic, readonly) BOOL isGroupItem;   // Should return YES when self conforms both to SWGroup and SWSelectable
- (NSIndexSet*)selectedItemIndexes;                 // Returns selected indexes in items

// selection
@required
- (void)selectItemsAtIndexes:(NSIndexSet*)indexes;
- (void)deselectItemsAtIndexes:(NSIndexSet*)indexes;
- (void)setChildGroupItem:(id<SWGroup,SWSelectable>)groupItem selected:(BOOL)select enabled:(BOOL)pickEnabled;

// locking
@optional
- (void)lockItemsAtIndexes:(NSIndexSet*)indexes;
- (void)unlockItemsAtIndexes:(NSIndexSet*)indexes;

@end


#pragma mark - SWGroupObserver

@protocol SWGroupObserver<NSObject>

@optional
- (void)group:(id<SWGroup>)item didSelectItemsAtIndexes:(NSIndexSet*)indexes;
- (void)group:(id<SWGroup>)item didDeselectItemsAtIndexes:(NSIndexSet*)indexes;
- (void)group:(id<SWGroup>)item groupItemAtIndex:(NSInteger)index didChangePickEnabledStateTo:(BOOL)state;

- (void)group:(id<SWGroup>)item didLockItemsAtIndexes:(NSIndexSet*)indexes;
- (void)group:(id<SWGroup>)item didUnlockItemsAtIndexes:(NSIndexSet*)indexes;

@end



