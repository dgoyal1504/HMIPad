//
//  FilesViewController.h
//  iPhoneDomusSwitch_090421
//
//  Created by Joan on 24/04/09.
//  Copyright 2009 SweetWilliam, S.L.. All rights reserved.
//

#import <UIKit/UIKit.h>


//@class SWTableViewMessage ;
//@class ControlViewCell, InfoViewCell, SwitchViewCell, ManagedTextFieldCell, LabelViewCell;
//@class LoginWindowControllerC;

@interface SWRearViewController : UIViewController

// metodes asimilables a un UITableViewController
- (id)initWithStyle:(UITableViewStyle)style;
@property (nonatomic,retain) UITableView *tableView;
@property(nonatomic) BOOL clearsSelectionOnViewWillAppear;


@end
