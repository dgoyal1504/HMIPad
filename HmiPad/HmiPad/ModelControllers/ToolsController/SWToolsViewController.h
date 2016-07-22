//
//  SWToolsViewController.h
//  HmiPad
//
//  Created by Joan on 24/12/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SWDocumentModel;
@class SWToolsViewController;


@protocol SWToolsViewControllerDelegate <NSObject>

- (void)toolsViewControllerDidChangeSelection:(SWToolsViewController*)toolsController;
- (void)toolsViewControllerInterfaceIdiomDidChange:(SWToolsViewController*)toolsController;

@end



@interface SWToolsViewController : UITableViewController

- (id)initWithDocument:(SWDocumentModel*)documentModel;
@property (nonatomic, weak) id<SWToolsViewControllerDelegate> delegate;

@end
