//
//  SWPageNavigatorController.h
//  HmiPad
//
//  Created by Joan Martin on 1/16/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewController.h"

@class SWDocumentModel;
@class SWTableViewController;

extern NSString * const SWPageNavigatorControllerHasVisiblePagesNotification;

//@interface SWPageNavigatorController : UITableViewController
@interface SWPageNavigatorController : SWTableViewController

- (id)initWithDocumentModel:(SWDocumentModel*)documentModel;

@property (nonatomic, strong, readonly) SWDocumentModel *documentModel;

@end
