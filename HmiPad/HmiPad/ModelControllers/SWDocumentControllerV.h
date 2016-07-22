//
//  SWDocumentController.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/29/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWDocument.h"

#import "SWHorizontalTableView.h"

#import "SWPropertyListTableViewController.h"
#import "SWFloatingPopoverController.h"

typedef enum {
    SWDocumentControllerStateUndefined,
    SWDocumentControllerStatePage
} SWDocumentControllerState;

@class SWDocumentModel;
@class SWPageController;

@interface SWDocumentControllerV : UIViewController <DocumentModelObserver, UIActionSheetDelegate, UIPopoverControllerDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate,SWPropertyListTableViewControllerDelegate, SWFloatingPopoverControllerDelegate> {
    
    NSInteger _selectedPageControllerIndex;
    NSMutableArray *_pageControllers;
    
    SWDocumentControllerState _state;
    
    BOOL _shouldUpdatePagePreview;
        
    UIActionSheet *_actionSheet;
    UIPopoverController *_popover;
    
    UIButton *_pagesButton ;
    
    BOOL _autoAlignPageItems;
    
    BOOL _firstTouchIsValidForPageChanging;
    BOOL _toolbarIsHidden;
    UISwipeGestureRecognizer *_hiddenToolbarRecognizer;
    
    NSMutableSet *_floatingPopovers;
    
    //SWFloatingPopoverController *_searchItemsFloatingPopover;
    UIPopoverController *_searchItemsFloatingPopover;
}

- (id)initWithDocument:(SWDocument*)document;

- (IBAction)moveToRightViewController:(id)sender;
- (IBAction)moveToLeftViewController:(id)sender;
- (IBAction)pagesAction:(id)sender;
- (IBAction)itemsAction:(id)sender;
- (IBAction)sourcesAction:(id)sender;
- (IBAction)insertNewViewController;
- (IBAction)deleteCurrentPage:(id)sender;
- (IBAction)undo:(id)sender;
- (IBAction)redo:(id)sender;
- (IBAction)mainMenu:(id)sender;
- (IBAction)togglePreview:(id)sender;
- (IBAction)toggleAutoAlignItems:(id)sender;
- (IBAction)hideToolbar:(id)sender;
- (IBAction)toggleMutipleSelectionAction:(id)sender;
- (IBAction)searchItems:(id)sender;

- (void)performPageInsertionAtIndex:(NSInteger)index;
- (void)performPageDeletionAtIndex:(NSInteger)index;

@property (nonatomic, readonly, strong) SWDocument *document;
@property (nonatomic, readonly, strong) SWDocumentModel *docModel;

@property (nonatomic, readonly) SWPageController *currentPageController;

@property (strong, nonatomic) NSUndoManager *undoManager;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *controllerContentView;
@property (weak, nonatomic) IBOutlet SWHorizontalTableView *horizontalBarView;

@property (strong, nonatomic) UIBarButtonItem *menuButtonItem;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *togglePreviewButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *previousPageButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *nextPageButtonItem;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *undoButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *redoButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *pagesButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *itemsButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sourcesButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *autoAlignButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *multipleSelectionItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchItemsItem;

@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UIToolbar *editingToolbar;

@end

@interface SWDocumentController (ScreenShots) <SWHorizontalTableViewDelegate, SWHorizontalTableViewDataSource>

@end

