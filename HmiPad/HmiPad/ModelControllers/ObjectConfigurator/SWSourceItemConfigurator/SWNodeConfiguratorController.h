//
//  SWNodeConfiguratorController.h
//  HmiPad
//
//  Created by Joan Martin on 9/19/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWConfigurationController.h"

@class SWSourceItem;
@class SWIdentifierHeaderView;

@interface SWNodeConfiguratorController : SWConfigurationController
{
    NSArray *_configuringObjects;
}

//- (id)initWithSourceItem:(SWSourceItem*)sourceItem andNodesAtIndexes:(NSIndexSet*)nodesIndexes;
- (id)initWithConfiguringObject:(NSArray*)object;    // array de nodes

//@property (nonatomic, readonly) NSArray *configuringNodesArray;

@property (nonatomic, readonly) NSIndexSet *nodesIndexes;
@property (nonatomic, readonly) SWSourceItem *sourceItem;

@property (nonatomic, strong) SWIdentifierHeaderView *identifierHeaderView;
@property (nonatomic, strong) UITableView *tableView;


@end
