//
//  SWItemConfigurationController.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/27/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWConfigurationController.h"

//#import "SWObject.h"
//#import "SWTableFieldsControllerDelegate.h"
//#import "RoundedTextViewDelegate.h"
//#import "SWExpressionCell.h"
//#import "SWValueTypeEnumCell.h"
//#import "SWEnumTypes.h"
//#import "SWModelBrowserProtocols.h"

//#import "SWModelManager.h"

@class SWTableFieldsController;
@class SWObjectDescription;
@class SWObject;

@class SWTextField;
//@class SWIdentifierView;
@class SWIdentifierHeaderView;

//extern NSString * const SWItemConfigurationControllerDidStartEditingNotification;
//extern NSString * const SWItemConfigurationControllerDidEndEditingNotification;

extern NSString * const SWItemConfigurationControllerDidChangeNameNotification;

@interface SWObjectConfiguratorController : SWConfigurationController <UITableViewDelegate, UITableViewDataSource>
{
    SWObject *_configuringObject;
}

- (void)headerAction:(id)sender;

@property (nonatomic, strong) SWIdentifierHeaderView *identifierHeaderView;
@property (nonatomic, strong) UITableView *tableView;

@end

