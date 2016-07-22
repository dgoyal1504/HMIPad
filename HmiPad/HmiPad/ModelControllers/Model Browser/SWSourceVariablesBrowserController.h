//
//  SWSourceVariablesBrowserController.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/16/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "SWTableFieldsControllerDelegate.h"
//#import "SWSourceItem.h"
#import "SWEditableTableViewController.h"

//#import "SWModelBrowserProtocols.h"


extern NSString * const SWSourceNodesDidChangeNotification;    // no s'utilitza (deprecat)

@class SWSourceItem;
@class SWSourceVariablesBrowserController;
@class SWSourceNode;

@interface SWSourceVariablesBrowserController : SWEditableTableViewController //<SWModelBrowserViewController/*, UIActionSheetDelegate ,SourceItemObserver*/>

- (id)initWithSourceItem:(SWSourceItem*)sourceItem;

@property (nonatomic, strong) SWSourceItem *sourceItem;

@property (nonatomic, strong) SWSourceNode *selectedNode;
- (void)setSelectedNode:(SWSourceNode *)selectedNode animated:(BOOL)animated;

@end
