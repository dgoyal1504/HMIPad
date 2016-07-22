//
//  SWAddObjectViewController.h
//  HmiPad
//
//  Created by Joan Martin on 8/23/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWSerializedTableViewController.h"

@class SWExamplesViewController;

typedef enum SWObjectType
{
    SWObjectTypeAny = 0xffff,
} SWObjectType;

@interface SWExamplesViewController : SWSerializedTableViewController


//@property (nonatomic, readonly) SWSerializedTableViewController *serializableController;
- (id)init;
@property (nonatomic, readonly) SWObjectType allowedObjectTypes;

@end
