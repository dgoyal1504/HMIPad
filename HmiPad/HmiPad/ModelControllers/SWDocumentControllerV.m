//
//  SWDocumentController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/29/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SWDocumentControllerV.h"
#import "SWPageController.h"
#import "SWSplitViewController.h"
#import "SWSourcesListController.h"
#import "SWSourceDetailsController.h"
#import "SWDocumentController+SWSourceItemsController.h"

#import "SWFileManager.h"

#import "UIView+ScreenShot.h"
#import "UIImage+Scaling.h"

#import "FilesViewController.h"

#import "SWKeyboardListener.h"

#import "SWItemConfigurationController.h"
#import "SWModelBrowserController.h"
#import "SWFloatingPopoverController.h"

#import "SWColor.h"
#import "AppModel.h"

enum ActionSheetTag {
    ActionSheetPages,
    ActionSheetSources,
    ActionSheetMenu
};

enum  AlertViewTag {
    AlertViewUnsavedChanges
};

typedef enum {
    SWDocumentControllerAnimationNone,
    SWDocumentControllerAnimationRight,
    SWDocumentControllerAnimationLeft
} SWDocumentControllerAnimation;

@interface SWDocumentControllerV ()

- (void)_doViewDidAppear;
- (void)_documentDidOpenSuccessfully;
- (void)_refreshControllerViewForOpenedDocument;
- (SWPageController*)_pageControllerAtIndex:(NSInteger)index;
- (void)_notificationReceived:(NSNotification*)notification;
- (void)_performTransitionFromController:(UIViewController*)vc1 toController:(UIViewController*)vc2 animation:(SWDocumentControllerAnimation)animation completion:(void (^)(BOOL finished))completion;

- (void)_generateScreenShotForPageController:(SWPageController*)pageController;

- (void)_updateControllerTitle;
- (void)_updateControllerViewsWhenPageChanging;
- (void)_updateUndoAndRedoButtons;
- (void)_updatePagesButton;
- (void)_updateAutoAlignButton;

- (NSArray*)_rightBarButtonItems;
- (NSArray*)_leftBarButtonItems;

- (void)_presentEditingToolbar:(BOOL)isEditing animated:(BOOL)animated;
- (void)_hideEditingToolbar:(BOOL)hide animated:(BOOL)animated;

- (void)_gestureRecognized:(UISwipeGestureRecognizer*)recognizer;

@end

@implementation SWDocumentControllerV


@synthesize document = _document;
@synthesize docModel = _docModel;

@synthesize contentView = _contentView;
@synthesize undoManager = _undoManager;
@synthesize controllerContentView = _controllerContentView;
@synthesize horizontalBarView = _horizontalBarView;
@synthesize togglePreviewButtonItem = _togglePreviewButtonItem;
@synthesize pagesButtonItem = _pagesButtonItem;
@synthesize itemsButtonItem = _itemsButtonItem;
@synthesize sourcesButtonItem = _sourcesButtonItem;
@synthesize previousPageButtonItem = _previousPageButtonItem;
@synthesize nextPageButtonItem = _nextPageButtonItem;
@synthesize loadingView = _loadingView;
@synthesize editingToolbar = _editingToolbar;
@synthesize undoButtonItem = _undoButtonItem;
@synthesize redoButtonItem = _redoButtonItem;
@synthesize menuButtonItem = _menuButtonItem;
@synthesize autoAlignButtonItem = _autoAlignButtonItem;
@synthesize multipleSelectionItem = _multipleSelectionItem;
@synthesize searchItemsItem = _searchItemsItem;

@dynamic currentPageController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithDocument:nil];
}

- (void)doInit
{    
    _pageControllers = [NSMutableArray array];
    
    _floatingPopovers = [NSMutableSet set];
    
    _state = SWDocumentControllerStateUndefined;
    _selectedPageControllerIndex = NSNotFound;
        
    self.navigationItem.hidesBackButton = YES;
    
    _autoAlignPageItems = YES;
    
    // Document Notifications
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self 
           selector:@selector(_notificationReceived:) 
               name:UIDocumentStateChangedNotification 
             object:_document];   
    
    [nc addObserver:self 
           selector:@selector(_notificationReceived:) 
               name:SWPageControllerSelectionDidChangeNotification 
             object:nil];   
    
    [nc addObserver:self 
           selector:@selector(_notificationReceived:) 
               name:SWPageControllerShowConfigurationNotification 
             object:nil];
}

- (id)initWithDocument:(SWDocument*)document
{
    self = [super initWithNibName:@"SWDocumentController" bundle:nil];
    if (self) {
        _document = document;
        
        NSLog( @"%@,%@,%d", _document, _docModel, _docModel.selectedPageIndex );
        [self doInit];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{ 
    [_docModel removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
}

#pragma mark - Properties

- (SWPageController*)currentPageController
{
    if (_selectedPageControllerIndex != NSNotFound) {
        return [self _pageControllerAtIndex:_selectedPageControllerIndex];
    }
    
    return nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *recognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_gestureRecognized:)];
    UISwipeGestureRecognizer *recognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_gestureRecognized:)];
    recognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
    recognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    recognizerLeft.delegate = self;
    recognizerRight.delegate = self;
    [self.view addGestureRecognizer:recognizerRight];
    [self.view addGestureRecognizer:recognizerLeft];
    
    _loadingView.layer.cornerRadius = 5;
    _loadingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    
    // Setting up the horizontal table view
    CGRect outFrame = CGRectMake(0, -self.horizontalBarView.frame.size.width, self.horizontalBarView.frame.size.width, self.horizontalBarView.frame.size.height);
    self.horizontalBarView.rowWidth = 300;
    self.horizontalBarView.frame = outFrame;
    self.horizontalBarView.backgroundColor = [[UIColor scrollViewTexturedBackgroundColor] colorWithAlphaComponent:0.85];
    
    self.horizontalBarView.layer.masksToBounds = NO;
    self.horizontalBarView.layer.shadowOffset = CGSizeMake(0,0);
    self.horizontalBarView.layer.shadowRadius = 4;
    self.horizontalBarView.layer.shadowOpacity = 1;
    CGFloat height = self.horizontalBarView.frame.size.height;
    CGRect shadowRect = CGRectMake(0, height-1, 1024, 3);
    self.horizontalBarView.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowRect].CGPath;
    
    // Setting up the navigation items
    self.navigationItem.rightBarButtonItems = [self _rightBarButtonItems];
    self.navigationItem.leftBarButtonItems = [self _leftBarButtonItems];

    
    if (_document.documentState == UIDocumentStateNormal) {
        [self _refreshControllerViewForOpenedDocument];
    } else {
        NSLog(@"Document state is not normal: %d",_document.documentState);
    }
    
    self.undoButtonItem.title = @"Undo";
    self.redoButtonItem.title = @"Redo";
    self.autoAlignButtonItem.title = @"AutoAlign";
    self.itemsButtonItem.title = @"Items";
    self.pagesButtonItem.title = @"Pages";
    self.sourcesButtonItem.title = @"Sources";
    self.searchItemsItem.title = @"Search";
    
    [self _updateMultipleSelectionButtonItem];
}

- (void)viewDidUnload
{
    [self setContentView:nil];
    [self setControllerContentView:nil];
    [self setHorizontalBarView:nil];
    [self setPagesButtonItem:nil];
    [self setItemsButtonItem:nil];
    [self setSourcesButtonItem:nil];
    [self setPreviousPageButtonItem:nil];
    [self setNextPageButtonItem:nil];
    [self setRedoButtonItem:nil];
    [self setUndoButtonItem:nil];
    [self setMenuButtonItem:nil];
    [self setLoadingView:nil];
    [self setEditingToolbar:nil];
    [self setTogglePreviewButtonItem:nil];
    [self setMultipleSelectionItem:nil];
    [self setSearchItemsItem:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self _presentEditingToolbar:self.editing animated:animated];
}

- (void)_doViewDidAppear
{
    [_docModel igniteSources] ;    
    [_docModel addObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //[self _doViewDidAppear];
    
    if (_state != SWDocumentControllerStatePage) {
        
        UIDocumentState state = _document.documentState;
        
        if (state == UIDocumentStateNormal) {
            
            [self _documentDidOpenSuccessfully];
            
        } else if (state == UIDocumentStateClosed) {
                        
            [_document openWithCompletionHandler:^(BOOL success) {
                NSLog(@"Document Opened successfully: %@",STRBOOL(success));
                
                [UIView animateWithDuration:0.25 
                                 animations:^{
                                     _loadingView.alpha = 0;
                                 } completion:^(BOOL finished) {
                                      [_loadingView removeFromSuperview];
                                 }];   
            }];
            
        } else {
            NSLog(@"[oldp13] Document state %d is not handled while initializing controller", state);
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_docModel clausureSources] ;
    
    [_docModel removeObserver:self];
    
    [_popover dismissPopoverAnimated:YES];
    
    [self.docModel.document closeWithCompletionHandler:^(BOOL success2) {}]; 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Properties

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    [self.currentPageController setEditing:editing animated:animated];
    [self _presentEditingToolbar:editing animated:animated];
    [self.horizontalBarView setEditing:editing animated:animated];    
    
    NSLog(@"EDITING : %@", STRBOOL(editing));
    
    if (editing == NO) {
        [self _generateScreenShotForPageController:self.currentPageController];
        
        // Dismiss all Configuration Controllers
        for (SWFloatingPopoverController *popover in _floatingPopovers)
            [popover dismissFloatingPopoverAnimated:YES];
        [_floatingPopovers removeAllObjects];
    }
}

#pragma mark - Main Methods

- (IBAction)moveToRightViewController:(id)sender
{        
    if (_state == SWDocumentControllerStatePage) {

        if (_docModel.selectedPageIndex == -1)
            return;
        if (_docModel.selectedPageIndex+1 >= _docModel.pages.count)
            return;
    
        _docModel.selectedPageIndex = _docModel.selectedPageIndex + 1;
    }
}

- (IBAction)moveToLeftViewController:(id)sender
{    
    if (_state == SWDocumentControllerStatePage) {
        
        if (_docModel.selectedPageIndex == -1)
            return;
        
        if (_docModel.selectedPageIndex-1 < 0)
            return;
        
        _docModel.selectedPageIndex = _docModel.selectedPageIndex - 1;
    }
}

- (IBAction)mainMenu:(id)sender
{
    if (_actionSheet) {
        [_actionSheet dismissWithClickedButtonIndex:[_actionSheet cancelButtonIndex] animated:YES];
        _actionSheet = nil;
        return;
    }
    
    _actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                               delegate:self 
                                      cancelButtonTitle:nil 
                                 destructiveButtonTitle:@"Close Project" 
                                      otherButtonTitles:@"Export as Symbolic",@"Save Project", nil];
    
    _actionSheet.tag = ActionSheetMenu;
    [_actionSheet showFromBarButtonItem:self.menuButtonItem animated:YES];
    NSLog( @"mainMenu" );
}

- (IBAction)pagesAction:(id)sender
{
    if (_actionSheet) {
        [_actionSheet dismissWithClickedButtonIndex:[_actionSheet cancelButtonIndex] animated:YES];
        _actionSheet = nil;
        return;
    }
    
    if (_selectedPageControllerIndex != NSNotFound) {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                   delegate:self 
                                          cancelButtonTitle:nil 
                                     destructiveButtonTitle:@"Delete Current Page" 
                                          otherButtonTitles:@"New Page",@"Customize Current Page", nil];
    } else {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                   delegate:self 
                                          cancelButtonTitle:nil 
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:@"New Page", nil];
    }
    
    _actionSheet.tag = ActionSheetPages;
    [_actionSheet showFromBarButtonItem:self.pagesButtonItem animated:YES];
}

#import "SWPropertyListTableViewController.h"

- (IBAction)itemsAction:(id)sender
{
    if (_popover.isPopoverVisible)
        return;
    
    SWPropertyListTableViewController *ctrl = [[SWPropertyListTableViewController alloc] initWithPropertyList:@"ItemMenu" inBundle:nil style:UITableViewStyleGrouped];
    ctrl.delegate = self;
    ctrl.title = @"Items";
    ctrl.contentSizeForViewInPopover = ctrl.popoverSize;

    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:ctrl];
    
    _popover = [[UIPopoverController alloc] initWithContentViewController:nvc];
    _popover.delegate = self;
    
    [_popover presentPopoverFromBarButtonItem:self.itemsButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)sourcesAction:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SourceItemsConfiguration" bundle:nil];
    
    SWSourcesListController *sourcesListController = [storyboard instantiateViewControllerWithIdentifier:@"SWSourcesListController"];
    [sourcesListController setDocModel:_docModel];
    
    UINavigationController *sourcesListControllerNC = [[UINavigationController alloc] initWithRootViewController:sourcesListController];
    sourcesListController.delegate = self;
    
    SWSplitViewController *swSplitViewController = [[SWSplitViewController alloc] initWithNibName:@"SWSplitViewController" bundle:nil];
    swSplitViewController.leftViewController = sourcesListControllerNC;
    swSplitViewController.modalPresentationStyle = UIModalPresentationPageSheet;
    swSplitViewController.rightLabel.text = @"Select a Source to configure";
    
    [self presentModalViewController:swSplitViewController animated:YES];
}

- (IBAction)insertNewViewController
{    
    NSInteger insertionIndex = 0;
    NSInteger selectedPageIndex = _docModel.selectedPageIndex;
    
    if (selectedPageIndex != NSNotFound) 
        insertionIndex = selectedPageIndex+1 ;
    
    [self performPageInsertionAtIndex:insertionIndex];
}

- (IBAction)deleteCurrentPage:(id)sender
{
    [self performPageDeletionAtIndex:_docModel.selectedPageIndex];
}

- (IBAction)undo:(id)sender
{
    if ([_docModel.undoManager canUndo]) {
        [_docModel.undoManager undo];
    }
}

- (IBAction)redo:(id)sender
{
    if ([_docModel.undoManager canRedo]) {
        [_docModel.undoManager redo];
    }
}

- (void)doTogglePreview:(id)sender
{
    CGRect hBarViewFrame = _horizontalBarView.frame ;
    CGRect inFrame = CGRectMake(0, 0, hBarViewFrame.size.width, hBarViewFrame.size.height);
    CGRect outFrame = CGRectMake(0, -hBarViewFrame.size.width, hBarViewFrame.size.width, hBarViewFrame.size.height);
    
    BOOL isIn = CGRectEqualToRect(inFrame, hBarViewFrame);
    
    [UIView animateWithDuration:0.25 
                          delay:0 
                        options:UIViewAnimationCurveLinear 
                     animations:^{
                         
                         if (isIn) {
                             self.horizontalBarView.frame = outFrame;
                         } else {
                             self.horizontalBarView.frame = inFrame;
                         }
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (IBAction)togglePreview:(id)sender
{
    [self doTogglePreview:sender] ;
}

- (IBAction)toggleAutoAlignItems:(id)sender
{
    _autoAlignPageItems = !_autoAlignPageItems;
    
    [self _updateAutoAlignButton];
        
    self.currentPageController.autoAlignItems = _autoAlignPageItems;
}

- (IBAction)hideToolbar:(id)sender
{
    [self _hideEditingToolbar:YES animated:YES];
}

- (IBAction)toggleMutipleSelectionAction:(id)sender
{
    self.currentPageController.multipleSelection = !self.currentPageController.multipleSelection;
    
    [self _updateMultipleSelectionButtonItem];
}

- (IBAction)searchItems:(id)sender
{
    SWModelBrowserController *mbc = [[SWModelBrowserController alloc] initWithDocumentModel:_docModel];
    mbc.title = @"Model Browser";
    mbc.contentSizeForViewInPopover = CGSizeMake(320, 480);
    
//    _searchItemsFloatingPopover = [[SWFloatingPopoverController alloc] initWithContentViewController:mbc];
//    _searchItemsFloatingPopover.delegate = self;
//    _searchItemsFloatingPopover.frameColor = UIColorWithRgb(SystemDarkerBlueColor);
//    
//    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
//                                                                               target:_searchItemsFloatingPopover
//                                                                               action:@selector(dismissFloatingPopoverAnimated:)];
//    mbc.navigationItem.rightBarButtonItem = closeItem;
//    
//    [_searchItemsFloatingPopover presentFloatingPopoverAtPoint:CGPointMake(self.view.frame.size.width/2.0, self.view.frame.size.height/2.0) inView:self.view animated:YES];
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:mbc];
    _searchItemsFloatingPopover = [[UIPopoverController alloc] initWithContentViewController:nvc];
    [_searchItemsFloatingPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)performPageInsertionAtIndex:(NSInteger)index
{    
    NSInteger numberOfPages = _docModel.pages.count;
    NSInteger newSelectedPage = index;
    
    if (index > numberOfPages)
        return;
    
    SWPage *page = [[SWPage alloc] initInDocument:_docModel];
    page.title.valueAsString = [NSString stringWithFormat:@"Page",index];
    page.subtitle.valueAsString = @"You can start customizing this page right now!";
    
    NSUndoManager *undoManager = _docModel.undoManager;
    
    [undoManager beginUndoGrouping];
    [_docModel insertPage:page atIndex:index];
    [_docModel setSelectedPageIndex:newSelectedPage registerIntoUndoManager:YES];
    [undoManager endUndoGrouping];
}


- (void)performPageDeletionAtIndex:(NSInteger)index
{    
    
    NSInteger numberOfPages = _docModel.pages.count;
    NSInteger selectedPageIndex = _docModel.selectedPageIndex;
    NSInteger newSelectedPage = selectedPageIndex;
    
    if (index >= numberOfPages)
        return;
    
    if (index == selectedPageIndex) {
        if (selectedPageIndex + 1 < numberOfPages) {
            newSelectedPage = selectedPageIndex+1;
        } else if (selectedPageIndex - 1 < numberOfPages) {
            newSelectedPage = selectedPageIndex - 1;
        } else {
            newSelectedPage = NSNotFound;
        }
    }
    
    NSUndoManager *undoManager = _docModel.undoManager;
    
    [undoManager beginUndoGrouping];
    [_docModel setSelectedPageIndex:newSelectedPage registerIntoUndoManager:YES];
    [_docModel removePageAtIndex:index];
    [undoManager endUndoGrouping];
}

#pragma mark - Private Methods

- (void)_documentDidOpenSuccessfully
{
    if (_docModel) {
        NSLog(@"[73udq1] WARNING! DOC MODEL NOT NIL");
    }
    
    _docModel = _document.docModel;
    
    NSLog( @"%@,%@,%d", _document, _docModel, _docModel.selectedPageIndex );
    
    self.undoManager = [_docModel undoManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(_notificationReceived:) 
                                                 name:NSUndoManagerCheckpointNotification 
                                               object:self.undoManager];
    
    _selectedPageControllerIndex = NSNotFound;
    _state = SWDocumentControllerStatePage;

    if (self.isViewLoaded) {
        [self _refreshControllerViewForOpenedDocument];
        
        if (self.view.superview) {
            [self _doViewDidAppear];
        }
    }
}

- (void)_refreshControllerViewForOpenedDocument
{
    SWDocumentModel *docModel = _document.docModel;
    if (!docModel)
        return;
    
    [_pageControllers removeAllObjects];
    [self.horizontalBarView reloadData];
    
    NSLog( @"%@,%@,%d", _document, docModel, docModel.selectedPageIndex );

    if (docModel.selectedPageIndex != NSNotFound) {

        _selectedPageControllerIndex = docModel.selectedPageIndex;
        
        SWPageController *pc = self.currentPageController;
    
        pc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        pc.view.frame = self.controllerContentView.bounds;
        
        [self.controllerContentView addSubview:pc.view];       
        
        [self addChildViewController:pc];
        [pc didMoveToParentViewController:self];
        
        [self.horizontalBarView selectRowAtIndex:_selectedPageControllerIndex 
                                        animated:NO 
                                  scrollPosition:SWHorizontalTableViewScrollPositionMiddle];
    }
    
    [self _updateControllerViewsWhenPageChanging];
}

- (SWPageController*)_pageControllerAtIndex:(NSInteger)index
{
    if (index >= _docModel.pages.count)
        return nil;
    
    BOOL isNull = NO;
    
    if (index < _pageControllers.count) {
        SWPageController *vc = [_pageControllers objectAtIndex:index];
        if ((id)vc != [NSNull null]) {
            return vc;
        } else {
            isNull = YES;
        }
    }
    
    SWPage *page = [_docModel.pages objectAtIndex:index];
    SWPageController *vc = [[SWPageController alloc] initWithPage:page];
    
    if (isNull) {
        
        [_pageControllers replaceObjectAtIndex:index withObject:vc];
        
    } else {
        if (index == _pageControllers.count) {
            [_pageControllers addObject:vc];
            
        } else if (index > _pageControllers.count) {
            
            NSInteger count = _pageControllers.count;
            
            for (NSInteger i=0; i<index-count; ++i) {
                [_pageControllers addObject:[NSNull null]];
            }
            
            [_pageControllers addObject:vc];
        }
    }
    
    return vc;
}


- (void)_notificationReceived:(NSNotification*)notification
{   
    NSString *notificationName = [notification name];
    
    if ([notificationName isEqualToString:UIDocumentStateChangedNotification]) 
    {
        UIDocumentState state = _document.documentState;
        
        if (state == UIDocumentStateNormal) 
            [self _documentDidOpenSuccessfully];
        
        if (state == UIDocumentStateEditingDisabled) 
            [self setEditing:NO animated:YES];
        
        if (state == UIDocumentStateInConflict) 
        {
            NSLog(@"Document state is IN CONFLICT");
            // Fix Conflicts
            // TODO
        }    
    } 
    else if ([notificationName isEqualToString:NSUndoManagerCheckpointNotification]) 
    {    
        [self _updateUndoAndRedoButtons];
    } 
    else if ([notificationName isEqualToString:SWPageControllerSelectionDidChangeNotification]) 
    {
        // Nothing to validate right now
    } 
    else if ([notificationName isEqualToString:SWPageControllerShowConfigurationNotification])
    {
        SWItem *item = [notification.userInfo objectForKey:SWPageControllerItemConfigurationKey];
        
        for (SWFloatingPopoverController *popover in _floatingPopovers) {
            SWItemConfigurationController *icc = (id)popover.contentViewController;
            if (icc.modelObject == item) {
                [self.view bringSubviewToFront:popover.view];
                return;
            }
        }
        
        SWItemConfigurationController *icc = [[SWItemConfigurationController alloc] initWithObject:item];
        
        SWFloatingPopoverController *popover = [[SWFloatingPopoverController alloc] initWithContentViewController:icc];
        
        popover.delegate = self;
        //popover.frameColor = UIColorWithRgb(SystemDarkerBlueColor);
        popover.frameColor = DarkenedUIColorWithRgb(SystemDarkerBlueColor, 1.2f);
        
        [_floatingPopovers addObject:popover];
        
        CGRect itemFrame;
        
        switch (self.interfaceOrientation) {
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
                itemFrame = [item.frameLandscape valueAsCGRect];
                break;
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationPortraitUpsideDown:
                itemFrame = [item.framePortrait valueAsCGRect];
                break;
            default:
                break;
        }
        
        CGPoint point = CGPointMake(itemFrame.origin.x + roundf(itemFrame.size.width/2.0), 
                                    itemFrame.origin.y + roundf(itemFrame.size.height/2.0));
        
        UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                   target:popover 
                                                                                   action:@selector(dismissFloatingPopoverAnimated:)];
        icc.navigationItem.rightBarButtonItem = closeItem;
        
        [popover presentFloatingPopoverAtPoint:point inView:self.view animated:YES];
    } 
}

- (void)_performTransitionFromController:(UIViewController*)vc1 toController:(UIViewController*)vc2 animation:(SWDocumentControllerAnimation)animation completion:(void (^)(BOOL finished))completion
{
    CGRect controllerContentViewBounds = self.controllerContentView.bounds ;
    vc1.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    vc2.view.frame = controllerContentViewBounds;
    
    if (vc2) {
        [vc2 willMoveToParentViewController:nil];
        [vc2 removeFromParentViewController];
    }
       
    if (vc2) {
        CGRect frame = controllerContentViewBounds;
        
        if (animation == SWDocumentControllerAnimationNone) {
            // Nothing to do
        } else if (animation == SWDocumentControllerAnimationLeft) {
            frame.origin = CGPointMake(controllerContentViewBounds.size.width+20, 0);
        } else if (animation == SWDocumentControllerAnimationRight) {
            frame.origin = CGPointMake(-controllerContentViewBounds.size.width-20, 0);
        }
        
        vc2.view.frame = frame;
        
        [self.controllerContentView addSubview:vc2.view];
        [self addChildViewController:vc2];
    }
    
    [vc1 willMoveToParentViewController:nil];
    
    if (animation != SWDocumentControllerAnimationNone) {

        [UIView animateWithDuration:0.35 
                         animations:^{
                             NSLog(@"Animations! %@", vc1.description);
                             
                             vc2.view.frame = self.controllerContentView.bounds;
                             
                             CGRect oldControllerFrame = vc1.view.frame;
                             
                             if (animation == SWDocumentControllerAnimationLeft) {
                                 vc1.view.frame = CGRectMake(-oldControllerFrame.size.width, 0, 
                                                             oldControllerFrame.size.width, oldControllerFrame.size.height);
                             } else if (animation == SWDocumentControllerAnimationRight) {
                                 vc1.view.frame = CGRectMake(oldControllerFrame.size.width, 0, 
                                                             oldControllerFrame.size.width, oldControllerFrame.size.height);
                             }
                             
                             vc1.view.alpha = 0.5;
                             
                         } completion:^(BOOL finished) {
                             
                             [vc1.view removeFromSuperview];
                             [vc1 removeFromParentViewController];
                             
                             CGRect frame = vc1.view.frame;
                             frame.origin = CGPointZero;
                             vc1.view.frame = frame;
                             vc1.view.alpha = 1.0;
                             
                             [vc2 didMoveToParentViewController:self];
                             completion(YES);
                         }];
        
    } else {
        
        [vc1.view removeFromSuperview];
        [vc1 removeFromParentViewController];
        
        [vc2 didMoveToParentViewController:self];
        completion(YES);
    }
}

- (void)_generateScreenShotForPageController:(SWPageController*)pageController
{    
    SWPage *originPage = pageController.page;
    NSString *originUuid = originPage.uuid;
    NSURL *screenshotsURLFolderURL = [self.docModel urlForDocumentCacheDirectory:SWDocumentCacheDirectoryScreenShots];
    
    UIView *view = pageController.view;
    
//#warning Podem accedir de manera segura al view en un thread secundari ?
#warning Resposta--> De fet dona problemes, a vegades, per això no s'està cridant aquest mètode. És un TODO pendent a resoldre.

    dispatch_queue_t q_default = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(q_default, ^{
        
        UIImage *originalImage = nil;
        
//        if (!view.superview) {
//            //NSLog(@"asdf");
//            //pageController.editing = NO;
//            CGRect frame = view.frame;  
//            view.frame = CGRectMake(0, 0, 1024, 704);
//            originalImage = [view screenShotWithScale:1.0];
//            view.frame = frame;
//        } else {
            originalImage = [view screenShotWithScale:1.0];
//        }
        
        CGSize size = CGSizeMake(originalImage.size.width*0.5, originalImage.size.height*0.5);
        UIImage *scaledImage = [originalImage scaleToSize:size];
        
        NSData *data = UIImagePNGRepresentation(scaledImage);
        NSString *pageScreenShotName = [NSString stringWithFormat:@"%@.png", originUuid];
        NSURL *url = [screenshotsURLFolderURL URLByAppendingPathComponent:pageScreenShotName];
        
        if(![data writeToURL:url atomically:YES]) {
            //NSLog(@"[PAGE] Error saving screenshot to path: %@",url.path);
        }
        
        dispatch_queue_t q_main = dispatch_get_main_queue();
        dispatch_async(q_main, ^{
            
            NSInteger pageIndex = [_docModel indexOfPageWithUUID:originUuid];

            if (pageIndex != NSNotFound) {
                [self.horizontalBarView reloadRowsAtIndexes:[NSIndexSet indexSetWithIndex:pageIndex] 
                                           withRowAnimation:SWHorizontalTableViewRowAnimationNone];
            }
        });
    });
}

- (void)_updateControllerTitle
{
    if (_docModel.pages.count > 0 && _selectedPageControllerIndex != NSNotFound) {
        self.title = [[_docModel.pages objectAtIndex:_selectedPageControllerIndex] identifier];
    } else {
        self.title = @"No Pages";
    }
}

- (void)_updateControllerViewsWhenPageChanging
{
    [self _updatePagesButton];
    [self _updateControllerTitle];
    [self _updateMultipleSelectionButtonItem];
    
    self.itemsButtonItem.enabled = _selectedPageControllerIndex != NSNotFound;
}

- (UIButton *)_buttonWithImageNamed:(NSString*)imageName action:(SEL)selector
{
    NSInteger iconIndex = _docModel.pages.count ;
    if ( iconIndex < 2 || iconIndex > 8 ) iconIndex = 0 ;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom] ;
    [button setFrame:CGRectMake(0,0,24,24)] ;
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal] ;
    [button setShowsTouchWhenHighlighted:YES] ;
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside] ;

    return button ;
}

- (void)_updatePagesButton
{
    NSInteger iconIndex = _docModel.pages.count ;
    if ( iconIndex < 2 || iconIndex > 8 ) iconIndex = 0 ;
    NSString *imageFile = [NSString stringWithFormat:@"tab%d.png", iconIndex] ;
    [_pagesButton setImage:[UIImage imageNamed:imageFile] forState:UIControlStateNormal] ;
}

- (void)_updateMultipleSelectionButtonItem
{
    if (self.currentPageController == nil) {
        self.multipleSelectionItem.enabled = NO;
    } else {
        self.multipleSelectionItem.enabled = YES;
        
        if (self.currentPageController.multipleSelection) {
            self.multipleSelectionItem.image = [UIImage imageNamed:@"multipleSelectionON.png"];
            self.multipleSelectionItem.title = @"MultipleSelection ON";
        } else {
            self.multipleSelectionItem.image = [UIImage imageNamed:@"multipleSelectionOFF.png"];
            self.multipleSelectionItem.title = @"MultipleSelection OFF";
        }
    }
}

- (void)_updateAutoAlignButton
{
    _autoAlignButtonItem.title = _autoAlignPageItems?@"AutoAlign ON":@"AutoAlign OFF";
}

- (void)_updateUndoAndRedoButtons
{
    self.undoButtonItem.enabled = _docModel.undoManager.canUndo;
    self.redoButtonItem.enabled = _docModel.undoManager.canRedo;
}

- (NSArray*)_rightBarButtonItems
{
    return [NSArray arrayWithObjects:self.editButtonItem,self.nextPageButtonItem,self.previousPageButtonItem, self.togglePreviewButtonItem, nil];
}

- (NSArray*)_leftBarButtonItems
{
    if (!self.menuButtonItem)
        self.menuButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" 
                                                               style:UIBarButtonItemStyleBordered 
                                                              target:self 
                                                              action:@selector(mainMenu:)];
    
    return [NSArray arrayWithObjects:self.menuButtonItem,nil];
}

- (void)_presentEditingToolbar:(BOOL)isEditing animated:(BOOL)animated
{
    if (isEditing && self.editingToolbar.superview != nil)
        return;
    
    [self _updateUndoAndRedoButtons];
    [self _updatePagesButton];
    [self _updateAutoAlignButton];
    
    CGRect beforeFrame = self.editingToolbar.bounds;
    CGRect afterFrame = self.editingToolbar.bounds;
    
    beforeFrame.size.width = self.view.frame.size.width;
    afterFrame.size = beforeFrame.size;
    
    if (isEditing) {
        beforeFrame.origin = CGPointMake(0, self.view.frame.size.height);
        afterFrame.origin = CGPointMake(0, self.view.frame.size.height - self.editingToolbar.frame.size.height);
        self.editingToolbar.userInteractionEnabled = YES;
    } else {
        afterFrame.origin = CGPointMake(0, self.view.frame.size.height);
        beforeFrame.origin = CGPointMake(0, self.view.frame.size.height - self.editingToolbar.frame.size.height);
    }
            
    if (animated) {
        if (isEditing) {
            self.editingToolbar.frame = beforeFrame;
            [self.view addSubview:self.editingToolbar];
        }
        
        [UIView animateWithDuration:0.12 
                         animations:^{
                             self.editingToolbar.frame = afterFrame; 
                         } completion:^(BOOL finished) {
                             if (!isEditing) {
                                 [self.editingToolbar removeFromSuperview];
                                 _toolbarIsHidden = NO;
                             }
                         }];
    } else {
        self.editingToolbar.frame = afterFrame;
        [self.view addSubview:self.editingToolbar];
        
        if (!isEditing) {
            [self.editingToolbar removeFromSuperview];
            _toolbarIsHidden = NO;
        }
    }
}

- (void)_hideEditingToolbar:(BOOL)hide animated:(BOOL)animated
{
    if (hide == _toolbarIsHidden) {
        return;
    }
    
    CGRect afterFrame = self.editingToolbar.bounds;
    
    if (hide) {
        afterFrame.origin = CGPointMake(0, self.view.frame.size.height - 4);
        self.editingToolbar.userInteractionEnabled = NO;
        
        _hiddenToolbarRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_gestureRecognized:)];
        _hiddenToolbarRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
        _hiddenToolbarRecognizer.delegate = self;
        [self.view addGestureRecognizer:_hiddenToolbarRecognizer];
        
    } else {
        afterFrame.origin = CGPointMake(0, self.view.frame.size.height - self.editingToolbar.frame.size.height);
        self.editingToolbar.userInteractionEnabled = YES;
        
        [self.view removeGestureRecognizer:_hiddenToolbarRecognizer];
        _hiddenToolbarRecognizer = nil;
    }
    
    if (animated) {        
        [UIView animateWithDuration:0.12 
                         animations:^{
                             self.editingToolbar.frame = afterFrame; 
                         } completion:^(BOOL finished) {

                         }];
    } else {
        self.editingToolbar.frame = afterFrame;
    }

    _toolbarIsHidden = hide;
}

- (void)_gestureRecognized:(UISwipeGestureRecognizer*)recognizer
{
    CGPoint point = [recognizer locationInView:self.view];
        
    switch (recognizer.state) {
        case UIGestureRecognizerStateEnded:
            
            if (recognizer == _hiddenToolbarRecognizer) {
                if (self.view.frame.size.height - point.y < 40) 
                    [self _hideEditingToolbar:NO animated:YES];
                
            } else {
                if (point.x < 40 && recognizer.direction == UISwipeGestureRecognizerDirectionRight)
                    _firstTouchIsValidForPageChanging = YES;
                else if (self.view.frame.size.width - point.x < 40 && recognizer.direction == UISwipeGestureRecognizerDirectionLeft) 
                    _firstTouchIsValidForPageChanging = YES;
                else 
                    _firstTouchIsValidForPageChanging = NO;
                
                if (_firstTouchIsValidForPageChanging) {
                    if ( recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
                        [self moveToLeftViewController:nil];
                    } 
                    
                    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
                        [self moveToRightViewController:nil];
                    }
                }
            }
            
            break;
        default:
            break;
    }
}

- (void)_delayedTransitionTo:(NSNumber*)nsIndex
{
        NSInteger index = [nsIndex integerValue] ;
    
        SWPageController *currentViewController = self.currentPageController;
        SWPageController *nextViewController = [self _pageControllerAtIndex:index];
    
        [nextViewController setEditing:self.editing animated:NO];
        nextViewController.autoAlignItems = _autoAlignPageItems;
        nextViewController.multipleSelection = currentViewController.multipleSelection;
        
        SWDocumentControllerAnimation animation = SWDocumentControllerAnimationNone;

        if (_selectedPageControllerIndex == NSNotFound) {
            animation = SWDocumentControllerAnimationNone;
        } else if (index > _selectedPageControllerIndex) {
            animation = SWDocumentControllerAnimationLeft;
        } else {
            animation = SWDocumentControllerAnimationRight;
        }
        
        _selectedPageControllerIndex = index;
        [self _updateControllerViewsWhenPageChanging];
        
        [self _performTransitionFromController:currentViewController 
                                  toController:nextViewController 
                                     animation:animation 
                                    completion:^(BOOL finished) {

                                        // Update the exiting view controller's view screenshot
                                        [self _generateScreenShotForPageController:currentViewController];
                                        
                                        // Update the entering view controlle'rs vew screenshot if not available
                                        if (!nextViewController.page.screenShotIsAvailable) {
                                            [self _generateScreenShotForPageController:nextViewController];   
                                        }
                                    }];
}

#pragma mark - DocumentModelObserver

- (void)documentModel:(SWDocumentModel *)docModel didChangeSelectedPage:(NSInteger)index
{    
    // If showing the requested page, nothing to do
    if (_selectedPageControllerIndex == index)
        return;
    
    [self.horizontalBarView selectRowAtIndex:index animated:YES scrollPosition:SWHorizontalTableViewScrollPositionMiddle];
    
//    [self performSelector:@selector(_delayedTransitionTo:) withObject:[NSNumber numberWithInteger:index] afterDelay:0] ;
    [self _delayedTransitionTo:[NSNumber numberWithInteger:index]];
}

- (void)documentModel:(SWDocumentModel *)docModel didInsertPageAtIndex:(NSInteger)index
{
    if (index < _pageControllers.count) {
        [_pageControllers insertObject:[NSNull null] atIndex:index];
    }
    
    if (_selectedPageControllerIndex == NSNotFound /*&& _docModel.pages.count > 0*/) {
//        _docModel.selectedPageIndex = index;
    } else {
        if (index <= _selectedPageControllerIndex) {
            _selectedPageControllerIndex++;
        }
    }
    
    [self.horizontalBarView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:index] withRowAnimation:SWHorizontalTableViewRowAnimationAutomatic];
    [self _updateControllerViewsWhenPageChanging];
}

- (void)documentModel:(SWDocumentModel *)docModel didRemovePageAtIndex:(NSInteger)index
{
    if (index != _selectedPageControllerIndex) {
        // Eliminem el controlador de la llista de controladors
        if (index < _pageControllers.count) 
            [_pageControllers removeObjectAtIndex:index];
        
        // Actualitzem el valor de la variable selectedPageControllerIndex
        if (index < _selectedPageControllerIndex && _selectedPageControllerIndex != NSNotFound)
            _selectedPageControllerIndex--;
        
        
    // Si eliminem una pàgina que estem mostrant:
    } else if (index == _selectedPageControllerIndex && _selectedPageControllerIndex != NSNotFound) {
        
        UIViewController *vcToDelete = [_pageControllers objectAtIndex:index];
        UIViewController *vcToShow = nil;
        
        // Eliminem el controlador de la llista de controladors
        [_pageControllers removeObjectAtIndex:index];
        
        [self _performTransitionFromController:vcToDelete 
                                  toController:vcToShow 
                                     animation:SWDocumentControllerAnimationLeft 
                                    completion:^(BOOL finished) {
                                        _selectedPageControllerIndex = NSNotFound;
                                        [self.horizontalBarView selectRowAtIndex:NSNotFound 
                                                                        animated:YES 
                                                                  scrollPosition:SWHorizontalTableViewScrollPositionNone];
                                        
                                        [self _updateControllerViewsWhenPageChanging];
                                    }];

    }
    
    // Actualitzem la Horizontal Bar
    if (index != NSNotFound)
        [self.horizontalBarView deleteRowsAtIndexes:[NSIndexSet indexSetWithIndex:index] withRowAnimation:SWHorizontalTableViewRowAnimationAutomatic];
    
    [self _updateControllerViewsWhenPageChanging];
}

- (void)documentModel:(SWDocumentModel *)docModel didMovePageAtIndex:(NSInteger)index toIndex:(NSInteger)finalIndex
{     
    _selectedPageControllerIndex = _docModel.selectedPageIndex;
    [self _updateControllerViewsWhenPageChanging];
    
    // Updating state of _pageControllers
    if (index < _pageControllers.count) {
        UIViewController *svc = [_pageControllers objectAtIndex:index];
        [_pageControllers removeObjectIdenticalTo:svc];
        
        if (finalIndex <= _pageControllers.count) {
            [_pageControllers insertObject:svc atIndex:finalIndex];
        } else {
            // Do nothing
        }
    } else {
        if (finalIndex < _pageControllers.count) {
            [_pageControllers insertObject:[NSNull null] atIndex:finalIndex];
        } else {
            // Do nothing
        }
    }
    
    if (_shouldUpdatePagePreview) {
        [self.horizontalBarView deselectRowAtIndex:self.horizontalBarView.selectedRow animated:NO];
        [self.horizontalBarView reloadRowsAtIndexes:[self.horizontalBarView indexesForVisibleRows] 
                                   withRowAnimation:SWHorizontalTableViewRowAnimationAutomatic];
        [self.horizontalBarView selectRowAtIndex:_docModel.selectedPageIndex animated:NO scrollPosition:SWHorizontalTableViewScrollPositionMiddle];
    }
    _shouldUpdatePagePreview = YES;
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger firstOtherButtonIndex = [actionSheet firstOtherButtonIndex];
    NSInteger destructiveButtonIndex = [actionSheet destructiveButtonIndex];
//    NSInteger cancelButtonIndex = [actionSheet cancelButtonIndex];
    
    switch (actionSheet.tag) {
        case ActionSheetPages:
            if (buttonIndex == destructiveButtonIndex && destructiveButtonIndex > -1) { // Delete Page
                [self deleteCurrentPage:self];
            } else if (buttonIndex == firstOtherButtonIndex) { // New Page
                [self insertNewViewController];
            } else if (buttonIndex == firstOtherButtonIndex + 1) { // Customize Current Page
                
                if (_popover.isPopoverVisible)
                    break;
                                
                SWPage *page = [_docModel.pages objectAtIndex:_docModel.selectedPageIndex];
                
                for (SWFloatingPopoverController *popover in _floatingPopovers) {
                    SWItemConfigurationController *icc = (id)popover.contentViewController;
                    if (icc.modelObject == page) {
                        [self.view bringSubviewToFront:popover.view];
                        return;
                    }
                }
                
                SWItemConfigurationController *icc = [[SWItemConfigurationController alloc] initWithObject:page];
                
                icc.contentSizeForViewInPopover = CGSizeMake(320, 480);
                
                SWFloatingPopoverController *fp = [[SWFloatingPopoverController alloc] initWithContentViewController:icc];
                fp.delegate = self;
                //fp.frameColor = UIColorWithRgb(SystemDarkerBlueColor);
                fp.frameColor = DarkenedUIColorWithRgb(SystemDarkerBlueColor, 1.2f);

                [_floatingPopovers addObject:fp];
                
                UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:fp 
                                                                                           action:@selector(dismissFloatingPopoverAnimated:)];
                icc.navigationItem.rightBarButtonItem = closeItem;
                
                CGPoint point = CGPointMake(self.view.frame.size.width/2.0, self.view.frame.size.height/2.0);
                [fp presentFloatingPopoverAtPoint:point inView:self.view animated:YES];
            }
            break;
        case ActionSheetMenu:
            
            if (buttonIndex == destructiveButtonIndex) { // Must Quit
                
                [_document saveToURL:_document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                    if (!success) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                                        message:@"The document couldn't be saved" 
                                                                       delegate:nil 
                                                              cancelButtonTitle:@"Dismiss" 
                                                              otherButtonTitles:nil];
                        [alert show];
                    } else {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }];

            } else if (buttonIndex == firstOtherButtonIndex) { // Must Export as symbolic
                
                [model() saveSymbolicVersionForDocument:_document];
                
            } else if (buttonIndex == firstOtherButtonIndex + 1) { // Must Save

                [_document saveToURL:_document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                    if (!success) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                                        message:@"The document couldn't be saved" 
                                                                       delegate:nil 
                                                              cancelButtonTitle:@"Dismiss" 
                                                              otherButtonTitles:nil];
                        [alert show];
                    }
                }];
            }
        default:
            break;
    }
    
    _actionSheet = nil;
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger firstOtherButtonIndex = [alertView firstOtherButtonIndex];
    NSInteger cancelButtonIndex = [alertView cancelButtonIndex];
    
    switch (alertView.tag) {
        case AlertViewUnsavedChanges:
            if (buttonIndex == cancelButtonIndex) {
                // Nothing to do
            } else if (buttonIndex == firstOtherButtonIndex) { // Save and quit
                SWDocument *document = _docModel.document;
                [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                    if (success) {
                        [self.navigationController popViewControllerAnimated:YES];
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                                        message:@"The document couldn't be saved" 
                                                                       delegate:nil 
                                                              cancelButtonTitle:@"Dismiss" 
                                                              otherButtonTitles:nil];
                        [alert show];
                    }
                }];
            } else if (buttonIndex == firstOtherButtonIndex + 1) { // Quit anyway
                [self.navigationController popViewControllerAnimated:YES];
            }
            break;
            
        default:
            break;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch 
{        
    if ([touch.view isKindOfClass:[UIControl class]]){
        return NO;
    }
    if (self.editing && [touch.view isKindOfClass:[SWLayoutViewCell class]]) {
        return NO;
    }
        
    return YES;
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if ( popoverController == _popover )
    {
        _popover = nil;
    }
}

#pragma mark - SWPropertyListTableViewControllerDelegate

- (void)propertyListTableViewControllerDelegate:(SWPropertyListTableViewController *)controller didSelectOption:(NSString *)option
{
    [_popover dismissPopoverAnimated:YES];
    
    _popover = nil;
    
    SWPage *page = [_docModel.pages objectAtIndex:_docModel.selectedPageIndex];
    
    Class itemType = NSClassFromString(option);
    
    SWItem *item = [[itemType alloc] initInPage:page];
    
    NSUndoManager *undoManager = _docModel.undoManager;
    
    [undoManager beginUndoGrouping];

    SWValue *framePortrait = item.framePortrait;
    SWValue *frameLandscape = item.frameLandscape;
    
    CGRect frame = self.view.frame;
    CGRect frameP = framePortrait.valueAsCGRect;
    CGRect frameL = frameLandscape.valueAsCGRect;

    frameP.origin = CGPointMake(frame.size.width/2.0 - frameP.size.width/2.0, frame.size.height/2.0 - frameP.size.height/2.0);
    frameL.origin = CGPointMake(frame.size.width/2.0 - frameL.size.width/2.0, frame.size.height/2.0 - frameL.size.height/2.0);
    
    framePortrait.valueAsCGRect = frameP; 
    frameLandscape.valueAsCGRect = frameL;
    
    [page addItem:item];
    
    [undoManager endUndoGrouping];
}

#pragma mark - SWFloatingPopoverControllerDelegate

- (void)floatingPopoverControllerDidDismissPopover:(SWFloatingPopoverController *)floatingPopoverController
{
    [_floatingPopovers removeObject:floatingPopoverController];
}

@end


@implementation SWDocumentController (ScreenShots)

#pragma mark - Data Source

- (NSInteger)numberOfRowsInTableView:(SWHorizontalTableView *)tableView
{
    if (_document.documentState != UIDocumentStateNormal)
        return 0;
    
    return _docModel.pages.count;
}

- (SWHorizontalTableViewCell*)tableView:(SWHorizontalTableView *)tableView cellForRowAtIndex:(NSInteger)index
{    
    static NSString *CellIdentifier = @"Cell";
    
    SWHorizontalTableViewCell *cell = [tableView dequeueCellWithReusableIdentifier:CellIdentifier];
    
    if (!cell) { 
        cell = [[SWHorizontalTableViewCell alloc] initWithStyle:SWHorizontalTableViewCellStyleImage reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    SWPage *page = [_docModel.pages objectAtIndex:index];
    
    UIImage *image = page.screenShot;
        
    cell.imageView.image = image;
    
    return cell;
}

- (BOOL)tableView:(SWHorizontalTableView *)tableView canEditRowAtIndex:(NSInteger)index
{
    return YES;
}

- (void)tableView:(SWHorizontalTableView *)tableView commitEditingStyle:(SWHorizontalTableViewCellEditingStyle)editingStyle forRowAtIndex:(NSInteger)index
{
    NSLog(@"Horizontal Table View Commit Deletion At Index: %d",index);
    switch (editingStyle) {
        case SWHorizontalTableViewCellEditingStyleDelete:
        {
            [self performPageDeletionAtIndex:index];
        }
            break;
        default:
            break;
    }
}

- (BOOL)tableView:(SWHorizontalTableView *)tableView canMoveRowAtIndex:(NSInteger)index
{
    return self.editing;
}

- (void)tableView:(SWHorizontalTableView *)tableView moveRowAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex
{
    _shouldUpdatePagePreview = NO;
    [_docModel movePageAtIndex:sourceIndex toIndex:destinationIndex];
}

#pragma mark - Horizontal Table View Delegate

- (void)tableView:(SWHorizontalTableView *)tableView didSelectRowAtIndex:(NSInteger)index
{    
    if (index >= _docModel.pages.count || index < 0)
        return;
    
    if (index == _docModel.selectedPageIndex)
        return;
    
    _docModel.selectedPageIndex = index;
}

@end
