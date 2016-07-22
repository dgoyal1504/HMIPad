//
//  SWFlowViewDataSource.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/8/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SWFlowView;

#import "SWFlowViewItem.h"

@protocol SWFlowViewDataSource <NSObject>

// -- Configuring a Flow View -- //
@required
- (NSInteger)numberOfViewsInFlowView:(SWFlowView*)flowView;
- (UIView*)flowView:(SWFlowView*)flowview contentForViewAtIndex:(NSInteger)index;
//- (SWFlowViewItem*)flowView:(SWFlowView*)flowview flowViewItemAtIndex:(NSInteger)index;

@optional
- (NSString*)flowView:(SWFlowView*)flowView titleForViewAtIndex:(NSInteger)index;
- (NSString*)flowView:(SWFlowView*)flowView subtitleForViewAtIndex:(NSInteger)index;
- (NSString*)flowView:(SWFlowView*)flowView titleForFooterForViewAtIndex:(NSInteger)index;

// -- Inserting or Deleting Views -- //
@optional
- (BOOL)flowView:(SWFlowView*)flowView canEditViewAtIndex:(NSInteger)index;
- (void)flowView:(SWFlowView*)flowView commitEditingStyle:(SWFlowViewItemEditingStyle)editingStyle forViewAtIndex:(NSInteger)index;

// -- Reordering Views -- //
@optional
- (BOOL)flowView:(SWFlowView*)flowView canMoveViewAtIndex:(NSInteger)index;
- (void)flowView:(SWFlowView*)flowView moveViewAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

@end
