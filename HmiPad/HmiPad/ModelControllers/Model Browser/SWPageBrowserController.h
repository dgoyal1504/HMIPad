//
//  SWPageBrowserController.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/20/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWEditableTableViewController.h"
//#import "SWPage.h"
//#import "SWModelBrowserProtocols.h"
//#import "SWAddObjectViewController.h"

@class SWPage;

@interface SWPageBrowserController : SWEditableTableViewController //<SWModelBrowserViewController>

- (id)initWithPage:(SWPage*)page;

@property (nonatomic, readonly, strong) SWPage *page;

@end
