//
//  SWConfigurationController.h
//  HmiPad
//
//  Created by Joan Martin on 8/28/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableFieldsControllerDelegate.h"
#import "RoundedTextViewDelegate.h"

@class SWObject;
@class SWValue;
@class SWModelManager;
@class SWTableFieldsController;

@interface SWConfigurationController : UIViewController<SWTableFieldsControllerDelegate>
{
    id _configuringObjectInstance;
    SWValue *_configuringValue;
    NSIndexPath *_editingIndexPath;
    BOOL _notEditableName;
    
    __weak SWModelManager *_modelManager;
    UIBarButtonItem *_rightBarButtonItem;
    SWTableFieldsController *_rightButton;
}

+ (SWConfigurationController*)configuratorForObject:(id)object;

- (id)initWithConfiguringObject:(id)object;

@property (nonatomic, readonly) id configuringObjectInstance;
@property (nonatomic) BOOL notEditableName;
@property (nonatomic, readonly) SWTableFieldsController *rightButton;

@end
