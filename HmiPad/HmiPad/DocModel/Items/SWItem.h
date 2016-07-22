//
//  SWItem.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/14/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SWObject.h"
#import "SWGroup.h"
#import "SWModelTypes.h"
#import "SWEnumTypes.h"

@class SWItem;
@class SWGroupItem;

@protocol SWItemObserver <SWObjectObserver>

@optional
- (void)selectedDidChangeForItem:(SWItem*)item;
- (void)lockedDidChangeForItem:(SWItem*)item;

@end

@class SWPage;
@class SWItemController;

@interface SWItem : SWObject<SWSelectable>

- (id)initInPage:(SWPage*)page;

- (void)setFrame:(CGRect)frame withOrientation:(UIInterfaceOrientation)orientation idiom:(SWDeviceInterfaceIdiom)idiom;

// Convenience methods for management of frames
- (void)itemFramesAddOffset:(CGPoint)offset;
- (CGRect)frameForOrientation:(UIInterfaceOrientation)orientation idiom:(SWDeviceInterfaceIdiom)idiom;
- (SWValue*)frameSWValueWithOrientation:(UIInterfaceOrientation)orientation idiom:(SWDeviceInterfaceIdiom)idiom;
- (BOOL)frameValue:(SWValue*)value matchesInterfaceIdiom:(SWDeviceInterfaceIdiom)idiom forOrientation:(UIInterfaceOrientation)orientation;

// Parent object
@property (nonatomic, weak) id parentObject;   // may be SWPage o un SWGroupItem

// -- Item Properties -- //
@property (nonatomic, readonly) SWValue *framePortrait;
@property (nonatomic, readonly) SWValue *frameLandscape;
@property (nonatomic, readonly) SWValue *framePortraitPhone;
@property (nonatomic, readonly) SWValue *frameLandscapePhone;

// -- Item Expressions -- //
@property (nonatomic, readonly) SWExpression *backgroundColor;
@property (nonatomic, readonly) SWExpression *hidden;

// -- Sublcases must override this methods -- //
@property (nonatomic, readonly) SWItemResizeMask resizeMask;
@property (nonatomic, readonly) CGSize defaultSize;
@property (nonatomic, readonly) CGSize minimumSize;
@property (nonatomic, readonly) CGSize currentMinimumSize;

@end


//@interface SWItem()<SWSelectable>

//// Properties
//@property (nonatomic, readonly) BOOL selected;
//@property (nonatomic, readonly) BOOL locked;
//@property (nonatomic, readonly) BOOL pickEnabled;
//
//// Setters
//- (void)primitiveSetSelected:(BOOL)selected;
//- (void)primitiveSetLocked:(BOOL)locked;
//- (void)primitiveSetPickEnabled:(BOOL)enabled;
//
//// Used by SWPage to prevent SWItem observers to prevent items to get put on sleep upon grouping operations
//- (void)prepareForGroupOperation;
//- (void)finishGroupOperation;

//@end
