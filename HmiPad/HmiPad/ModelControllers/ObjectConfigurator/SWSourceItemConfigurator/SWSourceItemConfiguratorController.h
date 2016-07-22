//
//  SWSourceDetailsController.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/20/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWConfigurationController.h"

//#import "SWSourceItem.h"
//#import "SWTableSelectionController.h"
//#import "SWTableFieldsControllerDelegate.h"

@class SWSourceItem;
@class SWIdentifierHeaderView;
@class SWTableFieldsController;

@interface SWSourceItemConfiguratorController : SWConfigurationController //<SourceItemObserver,SWTableFieldsControllerDelegate, UITextFieldDelegate, SWTableSelectionControllerDelegate>
{
   // SWTableFieldsController *_rightButton;
   // BOOL _viewWillDisappearToReturn;
    SWSourceItem *_sourceItem;  // same as _configuringObjectInstance
}


@property (nonatomic, strong) SWIdentifierHeaderView *identifierHeaderView;
@property (nonatomic, strong) UITableView *tableView;

@end


@interface SWSourceItemConfiguratorController (UITableView) <UITableViewDataSource, UITableViewDelegate>
@end
