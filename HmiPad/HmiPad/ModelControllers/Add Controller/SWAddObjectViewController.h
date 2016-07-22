//
//  SWAddObjectViewController.h
//  HmiPad
//
//  Created by Joan Martin on 8/23/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWSerializedTableViewController.h"

//typedef enum {
//    SWObjectTypeNone            = 0,
//    SWObjectTypeVisibleItem     = 0b1,
//    SWObjectTypeBackgroundItem  = 0b10,
//    SWObjectTypePage            = 0b100,
//    SWObjectTypeAlarm           = 0b1000,
//    SWObjectTypeSource          = 0b10000,
//    SWObjectTypeAny             = 0b111111
//} SWObjectType;

typedef enum {
    SWObjectTypeNone            = 0,
    SWObjectTypeVisibleItem     = 1 << 0,  // 1
    SWObjectTypeBackgroundItem  = 1 << 1,  // 2
    SWObjectTypePage            = 1 << 2,  // 4
    SWObjectTypeAlarm           = 1 << 3,  // 8
    SWObjectTypeUser            = 1 << 4,  // 16
    SWObjectTypeDatabase        = 1 << 5,  // 32
    SWObjectTypeSource          = 1 << 6,  // 64
    SWObjectTypeAny             = 0xffff
} SWObjectType;

@class SWAddObjectViewController;

@protocol SWAddObjectViewControllerDelegate <NSObject> //<SWSerializedTableViewControllerDelegate>

@optional
- (NSInteger)addObjectViewControllerPageIndexToInsertItems:(SWAddObjectViewController*)controller;
//- (void)didFinishSelectionInAddObjectViewController:(SWAddObjectViewController*)controller;

- (void)addObjectViewController:(SWAddObjectViewController*)controller didAddObject:(id)object;

@end

@class SWDocumentModel;

@interface SWAddObjectViewController : SWSerializedTableViewController // <SWSerializedTableViewControllerDelegate>

- (id)initWithDocument:(SWDocumentModel*)documentModel allowedObjectTypes:(SWObjectType)objectTypes;

@property (nonatomic, readonly) SWSerializedTableViewController *serializableController;
@property (nonatomic, readonly) SWDocumentModel *documentModel;
@property (nonatomic, weak) id<SWAddObjectViewControllerDelegate> delegate;
@property (nonatomic, readonly) SWObjectType allowedObjectTypes;

//@property (nonatomic, assign) BOOL presentConfigurator;

@end
