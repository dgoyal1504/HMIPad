//
//  SWItemBroswerController.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/20/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWModelBrowserProtocols.h"
#import "SWEditableTableViewController.h"

@class SWValue;
@class SWObject;

//@interface SWObjectBroswerController : UITableViewController <SWModelBrowserViewController>
@interface SWObjectBroswerController : SWEditableTableViewController //<SWModelBrowserViewController>
{
    NSMutableArray *_sectionObjects;
    NSMutableArray *_sectionDescriptors;
}

- (id)initWithModelObject:(SWObject*)modelObject;

@property (nonatomic, strong, readonly) SWObject *modelObject;

@property (nonatomic, strong) SWValue *selectedValue;
- (void)setSelectedValue:(SWValue *)selectedValue animated:(BOOL)animated;

@end
