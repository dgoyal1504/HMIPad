//
//  SWTableViewController.h
//  HmiPad
//
//  Created by Joan on 25/02/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>


// A simple replacement for the UITableViewController that will not mess with content insets

@interface SWTableViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

// UITableViewController like methods
- (id)initWithStyle:(UITableViewStyle)style;
@property (nonatomic,retain) UITableView *tableView;
@property(nonatomic) BOOL clearsSelectionOnViewWillAppear;

@end
