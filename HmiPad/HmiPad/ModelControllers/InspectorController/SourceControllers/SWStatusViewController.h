//
//  SWSourcesViewController.h
//  HmiPad
//
//  Created by Joan Martin on 7/30/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewController.h"

@class SWDocumentModel;
@class SWSourcesViewControllerHeader;

@interface SWStatusViewController : SWTableViewController

//@property (nonatomic, strong) IBOutlet UISwitch *enableConnectionsSwitch;
@property (nonatomic, strong) IBOutlet SWSourcesViewControllerHeader *headerView;

@property (nonatomic, strong) SWDocumentModel *documentModel;


@end

