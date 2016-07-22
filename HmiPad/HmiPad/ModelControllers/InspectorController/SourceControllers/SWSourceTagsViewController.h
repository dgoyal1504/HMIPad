//
//  SWSourceTagsViewController.h
//  HmiPad
//
//  Created by Joan Martin on 7/30/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWSourceItem.h"
#import "SWTableViewController.h"

@class SWSourceItem;

//@interface SWSourceTagsViewController : UITableViewController <SourceItemObserver>
@interface SWSourceTagsViewController : SWTableViewController <SourceItemObserver>

- (id)initWithSourceItem:(SWSourceItem*)sourceItem;

@property (nonatomic, strong) SWSourceItem *sourceItem;

@end
