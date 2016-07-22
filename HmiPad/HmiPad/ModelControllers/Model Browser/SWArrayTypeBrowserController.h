//
//  SWAlarmsBrowserController.h
//  HmiPad
//
//  Created by Joan Martin on 8/6/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWEditableTableViewController.h"

//#import "SWModelBrowserProtocols.h"
//#import "SWAddObjectViewController.h"

#import "SWDocumentModel.h"

@interface SWArrayTypeBrowserController : SWEditableTableViewController

- (id)initWithDocumentModel:(SWDocumentModel*)documentModel andArrayType:(SWArrayType)type;

@property (nonatomic, readonly) SWDocumentModel *documentModel;
@property (nonatomic, readonly) SWArrayType arrayType;

@end

@interface SWArrayTypeBrowserController (ModelObserver) <DocumentModelObserver>
@end
