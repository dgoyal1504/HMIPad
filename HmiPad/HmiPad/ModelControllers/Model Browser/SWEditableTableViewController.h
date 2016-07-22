//
//  SWEditableTableViewController.h
//  HmiPad
//
//  Created by Joan Martin on 8/21/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWObject.h"
#import "SWModelBrowserProtocols.h"
#import "SWTableViewController.h"


//@interface SWEditableTableViewController : UITableViewController<SWModelBrowserViewController>
@interface SWEditableTableViewController : SWTableViewController<SWModelBrowserViewController,SWObjectObserver>
{
    BOOL _isMoving;
    //BOOL _presentToolbarWhenAppearing;
    
   SWModelBrowsingStyle _browsingStyle;
    //NSIndexSet *_acceptedTypes;  // conte indexos que son SWType
   __weak id <SWModelBrowserDelegate> _delegate;
}

// Public methods
- (void)revalidateToolbarButtons;

// Methods to override in subclasses
- (void)add:(id)sender;
- (void)configure:(id)sender;
- (void)action:(id)sender;
- (void)trash:(id)sender;

// Methods to override in subclasses
- (BOOL)validateAddButton;
- (BOOL)validateConfigureButton;
- (BOOL)validateActionButton;
- (BOOL)validateTrashButton;

//@property (nonatomic, assign) BOOL presentToolbarWhenAppearing;   
@property (nonatomic, assign) SWModelBrowsingStyle browsingStyle;   // <-- must be set before view load and never changed !
@property (nonatomic, weak) id <SWModelBrowserDelegate> delegate;

- (NSMutableIndexSet*)indexSetForItemsInSelectedRowsWithSection:(NSInteger)aSection;
- (void)markItemsInSection:(NSInteger)section atIndexes:(NSIndexSet*)indexes scrollToVisible:(BOOL)scroll animated:(BOOL)animated;
- (void)unmarkItemsInSection:(NSInteger)section atIndexes:(NSIndexSet *)indexes;

- (void)removeFromContainerController;

@end
