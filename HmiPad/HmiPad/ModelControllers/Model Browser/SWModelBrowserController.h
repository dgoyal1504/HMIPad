//
//  SWModelBrowserController.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/13/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWModelBrowserProtocols.h"
#import "SWDocumentModel.h" // SWArrayType

@interface SWModelBrowserController : UIViewController<SWModelBrowserViewController>

- (id)initWithModel:(SWDocumentModel*)documentModel;

@property (nonatomic, readonly, strong) SWDocumentModel *documentModel;

@property (nonatomic, readonly, getter = isSearchActive) BOOL searchActive;
@property (nonatomic, readonly) NSString *searchText;
@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, assign) BOOL searchDisabled;

- (void)setSearchText:(NSString *)searchText;

- (void)setExtraViewControllers:(NSArray*)extraViewControllers animated:(BOOL)animated;

- (void)setFrontViewControllerOfArrayType:(SWArrayType)arrayType animated:(BOOL)animated;

@end
