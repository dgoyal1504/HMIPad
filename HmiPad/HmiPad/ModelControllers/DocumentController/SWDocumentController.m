//
//  SWDocumentController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/29/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

//#import <QuartzCore/QuartzCore.h>
//#import <CoreImage/CoreImage.h>

#import "SWDocumentController.h"

//#import "AppModelFilesEx.h"
//#import "AppModelDocument.h"

#import "SWDocument.h"
#import "SWDocumentModel.h"
#import "SWPage.h"
#import "SWEnumTypes.h"

#import "SWImageManager.h"

#import "UIViewController+ModalPresenter.h"
#import "SWCoverVerticalPopoverController.h"

#import "SWAddObjectViewController.h"
#import "SWToolsViewController.h"

#import "SWNavBarTitleView.h"
#import "SWDocumentStatusView.h"

#import "SWItemController.h"
#import "SWPageController.h"

#import "SWModelBrowserProtocols.h"
#import "SWModelManager.h"

#import "SWAlertCenter.h"
#import "SWEventCenter.h"

#import "SWInspectorViewController.h"

#import "SWToolbarViewController.h"
#import "SWRevealViewController.h"

#import "SWPageNavigatorController.h"
#import "SWObjectConfiguratorController.h"
#import "SWGroupItemController.h"

#import "SWColor.h"
#import "SWKeyboardListener.h"


//NSString * const SWProjectButtonActionNotification = @"SWProjectButtonActionNotification";
NSString * const SWAllowFrameEditingDidChangeNotification = @"SWAllowFrameEditingDidChangeNotification";
//NSString * const SWEditingFrameStatusKey = @"SWEditingFrameStatusKey";
NSString * const SWDocumentDidBeginEditingNotification = @"SWDocumentDidBeginEditingNotification";
NSString * const SWDocumentDidEndEditingNotification = @"SWDocumentDidEndEditingNotification";
NSString * const SWDocumentCheckPointNotification = @"SWDocumentCheckPointNotification";

NSString * const SWDocumentControllerPartialRevealNotification = @"SWDocumentControllerPartialRevealNotification";
NSString * const SWDocumentControllerFullRevealNotification = @"SWDocumentControllerFullRevealNotification";

NSString * const SWDocumentControllerAllowedInterfaceIdiomOrientationNotification = @"SWDocumentControllerAllowedInterfaceIdiomOrientationNotification";

static NSString * const ModelBrowserIdentifier = @"ModelBrowserIdentifier";

//enum ActionSheetTag {
//    //ActionSheetMenu,
//    //ActionSheetSettings,
//    ActionSheetTimer,
//};

//enum  AlertViewTag {
//    AlertViewUnsavedChanges
//};

#define DisabledAlphaValue 0.7f
//#define DisabledAlphaValue 0.1f


@interface SWDocumentController() <SWDocumentStatusViewDelegate>
{            
    //UIActionSheet *_toolsActionSheet;
    //UIActionSheet *_actionSheet;
    UIPopoverController *_toolsPopover;
    UIPopoverController *_addPopover;
    
    SWCoverVerticalPopoverController *_toolsCoverPopover;
    SWCoverVerticalPopoverController *_addCoverPopover;
    
    UIPopoverController *_popover;

    BOOL _firstTouchIsValidForPageChanging;
    
    
    UIBarButtonItem *_undoButtonItem;
    
    UIBarButtonItem *_redoButtonItem;
    UIBarButtonItem *_flexibleButtonItem;
    UIBarButtonItem *_fixedButtonItem;
    UIBarButtonItem *_shortFixedButtonItem;
    UIBarButtonItem *_modelBrowserButtonItem;
    UIBarButtonItem *_objectPickerButtonItem;  // a eliminar
    UIBarButtonItem *_addButtonItem;
    UIBarButtonItem *_toolsButtonItem;
    UIBarButtonItem *_inspectorButtonItem;
    UIBarButtonItem *_statusViewItem;
    UIBarButtonItem *_pageButtonItem;
    UIBarButtonItem *_projectUserButtonItem;
    UIBarButtonItem *_titleBarButtonItem;
    UIBarButtonItem *_customEditButtonItem;
    
    UIBarButtonItem *_revealButtonItem;
    
    UILabel *_emptyLabel;
    SWLayoutResizerView *_layoutResizerView;
}

- (void)undo:(id)sender;
- (void)redo:(id)sender;
- (void)modelBrowserButtonAction:(id)sender;
//- (IBAction)objectPickerButtonAction:(id)sender;
- (void)addButtonAction:(id)sender;
- (void)toolsButtonAction:(id)sender;
- (void)inspectorButtonAction:(id)sender;
- (void)pageButtonAction:(id)sender;
- (void)customEditButtonAction:(id)sender;

//@property (strong, nonatomic) UIBarButtonItem *revealButtonItem;
- (void)revealButtonAction:(id)sender;

//UIBarButtonItem *undoButtonItem;
//@property (strong, nonatomic) UIBarButtonItem *redoButtonItem;
//@property (strong, nonatomic) UIBarButtonItem *flexibleButtonItem;
//@property (strong, nonatomic) UIBarButtonItem *fixedButtonItem;
//@property (strong, nonatomic) UIBarButtonItem *modelBrowserButtonItem;
//@property (strong, nonatomic) UIBarButtonItem *objectPickerButtonItem;  // a eliminar
//@property (strong, nonatomic) UIBarButtonItem *addButtonItem;
//@property (strong, nonatomic) UIBarButtonItem *toolsButtonItem;
//@property (strong, nonatomic) UIBarButtonItem *inspectorButtonItem;
//@property (strong, nonatomic) UIBarButtonItem *pageButtonItem;
//@property (strong, nonatomic) UIBarButtonItem *titleBarButtonItem;
//@property (strong, nonatomic) UIBarButtonItem *customEditButtonItem;

@property (strong, nonatomic) UIView *infoView;

@end

@interface SWDocumentController (ResizerView) <SWLayoutResizerViewDelegate>
@end

@interface SWDocumentController (ModelObservers) <DocumentModelObserver, SWEventCenterObserver>
@end

@interface SWDocumentController (SWRevealViewController) <SWRevealViewControllerDelegate>
@end

@interface SWDocumentController (SWToolbarViewController) <SWToolbarViewControllerDelegate>
@end

@interface SWDocumentController (CustomProtocols) <SWAddObjectViewControllerDelegate, SWModelBrowserDelegate,
    /*SWFloatingPopoverControllerDelegate,*/ SWToolsViewControllerDelegate>
@end

@interface SWDocumentController (UIProtocols) </*UIActionSheetDelegate,*/ UIPopoverControllerDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate>
@end





@implementation SWDocumentController
{
    NSArray *_addPopoverIndexPathPaths;
    //NSTimer *_integratorTimer;
    //NSTimeInterval _nextTimeInterval;
    //BOOL _projectValidated;
    SWNavBarTitleView *_titleView;
}


- (void)_doInit
{
    self.navigationItem.hidesBackButton = YES;
    
    [self setLeftDetailWidth:IS_IPHONE?90.0f:120.0f];
    
    if ( _docModel )
    {
        SWInspectorViewController *inspectorViewController = [[SWInspectorViewController alloc] initWithDocumentModel:_docModel];
        [self setRightDetailViewController:inspectorViewController];
        
        SWPageNavigatorController *pageNavigator = [[SWPageNavigatorController alloc] initWithDocumentModel:_docModel];
        [self setLeftDetailViewController:pageNavigator];
        
        SWPageController *pageController = nil;
        NSInteger selectedPageIndex = _docModel.selectedPageIndex;
        if (selectedPageIndex != NSNotFound)
            pageController = [self _pageControllerAtIndex:selectedPageIndex];
        
        [self setMasterViewController:pageController animated:YES];
    }
}

//- (id)initWithDocument:(SWDocument*)document
//{
//    self = [super initWithNibName:@"SWDocumentController" bundle:nil];
//    if (self) 
//    {
//        _document = document;
//        _docModel = document.docModel;
//        
//        SWModelManagerCenter *modelManagerCenter = [SWModelManagerCenter defaultCenter];
//        [modelManagerCenter addManagerWithDocumentModel:_docModel forPresentingInController:self];
//        
//        if ( _docModel == nil )
//        {
//            //return nil;   // no volem tenir cap controlador sense model, ara si.
//        }
//
//        [self doInit];
//    }
//    return self;
//}


- (id)initWithDocument:(SWDocument*)document
{
    self = [super init];
    if (self) 
    {
        _document = document;
        _docModel = document.docModel;
        
        SWModelManagerCenter *modelManagerCenter = [SWModelManagerCenter defaultCenter];
        UIViewController *presentingController = IS_IPHONE?nil:self;
        [modelManagerCenter addManagerWithDocumentModel:_docModel defaultPresentingController:presentingController];
        
        if ( _docModel != nil )
        {
        }

        [self _doInit];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    NSLog( @"DocumentController: %@ dealloc", self);
    
    SWModelManagerCenter *modelManagerCenter = [SWModelManagerCenter defaultCenter];
    [modelManagerCenter removeManagerWithDocumentModel:_docModel];
   // [[SWModelManager managerForDocumentModel:_docModel] prepareForDeletion];
}


//- (void)viewDidLoadV
//{
//    [super viewDidLoad];
//    
////    UISwipeGestureRecognizer *recognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_gestureRecognized:)];
////    UISwipeGestureRecognizer *recognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_gestureRecognized:)];
////    recognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
////    recognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
////    recognizerRight.delegate = self;
////    recognizerLeft.delegate = self;
////    recognizerRight.cancelsTouchesInView = NO;
////    recognizerLeft.cancelsTouchesInView = NO;
//    
//    UIView *selfView = self.view;
//    selfView.clipsToBounds = YES;
//    
////    [selfView addGestureRecognizer:recognizerRight];
////    [selfView addGestureRecognizer:recognizerLeft];
////    [selfView setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
//    
//    // Setting up the navigation items
//    _modelBrowserButtonItem.title = NSLocalizedString(@"Model",nil);
//    _objectPickerButtonItem.title = NSLocalizedString(@"Picker",nil);
//    _addButtonItem.title = NSLocalizedString(@"New",nil);
//    _inspectorButtonItem.title = NSLocalizedString(@"Inspector",nil);
//    _pageButtonItem.title = NSLocalizedString( @"Page", nil);
//    
//    _toolsButtonItem.title = NSLocalizedString(@"Tools",nil);
//    _undoButtonItem.title = NSLocalizedString(@"Undo",nil);
//    _redoButtonItem.title = NSLocalizedString(@"Redo",nil);
//    
//    _titleView = [[SWNavBarTitleView alloc] init];
//    _titleView.mainLabel.text = @AppName;
//    _titleView.secondaryLabel.text = @"Secondary HMI Pad";
//    [_titleView sizeToFit];
//    
//    [_titleBarButtonItem setCustomView:_titleView];
//    
//    [self setToolbarControllerItems:[self _barButtonItemsForEditingState:self.editing] animated:NO];
//
//    SWRevealViewController *revealController = [self revealViewController];
//    [revealController setDelegate:self];
//}


- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0,100,100)];
    //[view setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
    [view setBackgroundColor:[UIColor grayColor]];
    self.view = view;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *selfView = self.view;
    selfView.clipsToBounds = YES;
    
    // Setting up the navigation items
    
    //_modelBrowserButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"01-magnify.png"]
    _modelBrowserButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"708-search-toolbar.png"]
    //_modelBrowserButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search-25.png"]
        style:UIBarButtonItemStylePlain target:self action:@selector(modelBrowserButtonAction:)];

    //_modelBrowserButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(modelBrowserButtonAction:)];
    _modelBrowserButtonItem.title = NSLocalizedString(@"Model",nil);
    
//    _objectPickerButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"eyedropper20.png"]
//        style:UIBarButtonItemStylePlain target:self action:@selector(objectPickerButtonAction:)];
//    _objectPickerButtonItem.title = NSLocalizedString(@"Picker",nil);
    
    //_addButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"05-plus.png"]
    _addButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"709-plus-toolbar.png"]
    //_addButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus-25.png"]
        style:UIBarButtonItemStylePlain target:self action:@selector(addButtonAction:)];
    //_addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonAction:)];
    _addButtonItem.title = NSLocalizedString(@"New",nil);
    
    //_inspectorButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"04-eye.png"]
    //_inspectorButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"751-eye.png"]
    //_inspectorButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"718-timer-1.png"]
    //_inspectorButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"visible-25.png"];

    //_inspectorButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"timer-25.png"]
    //_inspectorButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"718-timer-1.png"]
       // style:UIBarButtonItemStylePlain target:self action:@selector(inspectorButtonAction:)];
    
//    UIButton *buttonView = [UIButton buttonWithType:UIButtonTypeInfoDark];
//    [buttonView addTarget:self action:@selector(inspectorButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    _inspectorButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
    //_inspectorButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"938-connections-toolbar.png"]
    _inspectorButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"724-info-toolbar.png"]
        style:UIBarButtonItemStylePlain target:self action:@selector(inspectorButtonAction:)];
    
    _inspectorButtonItem.title = NSLocalizedString(@"Inspector",nil);
    
    UINib *nib = [UINib nibWithNibName:@"SWDocumentStatusView" bundle:nil];
    SWDocumentStatusView *statusView = [nib instantiateWithOwner:nil options:nil][0];
    [statusView setDocumentModel:_docModel];
    [statusView setDelegate:self];
    _statusViewItem = [[UIBarButtonItem alloc] initWithCustomView:statusView];
    
    //_pageButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tab0.png"]
    _pageButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"705-photos-toolbar.png"]
    //_pageButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"virtual_mashine-25.png"]
    //_pageButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"stop-25.png"]
        style:UIBarButtonItemStylePlain target:self action:@selector(pageButtonAction:)];
    _pageButtonItem.title = NSLocalizedString( @"Page", nil);
    
    
    _projectUserButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"779-users-toolbar.png"]
        style:UIBarButtonItemStylePlain target:self action:@selector(projectUserButtonAction:)];
    _projectUserButtonItem.title = NSLocalizedString( @"User", nil);
    
    
    _customEditButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconPlay30.png"] style:UIBarButtonItemStylePlain target:self action:@selector(customEditButtonAction:)];
    
    //_toolsButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"21-wrench.png"]
    _toolsButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"742-wrench-toolbar.png"]
    //_toolsButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings2-25.png"]
        style:UIBarButtonItemStylePlain target:self action:@selector(toolsButtonAction:)];
    _toolsButtonItem.title = NSLocalizedString(@"Tools",nil);
    
    //_undoButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"undoarrow.png"]
    _undoButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"1026-revert-toolbar-flip1.png"]
    //_undoButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left2-25.png"]
        style:UIBarButtonItemStylePlain target:self action:@selector(undo:)];
    _undoButtonItem.title = NSLocalizedString(@"Undo",nil);
    
    //_redoButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"redoarrow.png"]
    _redoButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"1026-revert-toolbar-flip2.png"]
    //_redoButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"right3-25.png"]
        style:UIBarButtonItemStylePlain target:self action:@selector(redo:)];
    _redoButtonItem.title = NSLocalizedString(@"Redo",nil);
    
    _titleView = [[SWNavBarTitleView alloc] init];
    _titleView.mainLabel.text = @ AppName;
    _titleView.secondaryLabel.text = @"Secondary " @AppName;
    [_titleView sizeToFit];
    
    _titleBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_titleView];
    //[_titleBarButtonItem setCustomView:_titleView];
    
    _flexibleButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
        target:nil action:0];
    
    _fixedButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
        target:nil action:0];
    
    _shortFixedButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
        target:nil action:0];
    

    _fixedButtonItem.width = IS_IPHONE?5:20;
    _shortFixedButtonItem.width = IS_IPHONE?0:10;
    
    _fixedButtonItem.width = IS_IPHONE?5:10;
    _shortFixedButtonItem.width = IS_IPHONE?0:10;
    
    //UIImage *revealImage = [UIImage imageNamed:@"1099-list-1-toolbar.png"];
    UIImage *revealImage = [UIImage imageNamed:@"727-more-toolbar.png"];

    _revealButtonItem = [[UIBarButtonItem alloc] initWithImage:revealImage style:UIBarButtonItemStylePlain
        target:self action:@selector(revealButtonAction:)];
    
    [self setToolbarControllerItems:[self _barButtonItemsForEditingState:self.editing] animated:NO];

    SWRevealViewController *revealController = [self revealViewController];
    [revealController setDelegate:self];
    
    SWToolbarViewController *toolbarController = [self toolbarViewController];
    [toolbarController setDelegate:self];
    
    _layoutResizerView = [[SWLayoutResizerView alloc] init];
    [_layoutResizerView setDelegate:self];
    
    [self setControllerOverlayView:_layoutResizerView];

    if ( revealController )
    {
        BOOL revealed = (revealController.frontViewPosition==FrontViewPositionLeft);
        [selfView setAlpha:revealed?1.0:DisabledAlphaValue];
        [selfView setUserInteractionEnabled:revealed];
        
        [self _setRecognizersForPosition:revealController.frontViewPosition];
    }
    
//    if ( toolbarController )
//    {
//        BOOL revealed = (toolbarController.leftOverlayPosition == SWLeftOverlayPositionHidden);
//        [selfView setAlpha:revealed?1.0:DisabledAlphaValue];
//        [selfView setUserInteractionEnabled:revealed];
//    }
    
//    UIPanGestureRecognizer *panGestureRecognizer = revealController.panGestureRecognizer;
//    [toolbarController.toolbar addGestureRecognizer:panGestureRecognizer];
    
    //[self.revealViewController tapGestureRecognizer];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[self _refreshControllerViewForOpenedDocument];
    
    [_docModel igniteSources];
    [_docModel addObserver:self];
    [_docModel.eventCenter addObserver:self];
    
    [self _updateControllerTitle];
    [self _updateControllerTitleColor];
    [self _updateToolbarColor];
    [self _updateInterfaceIdiomAnimated:animated];
    
    [self _setupResizerView];
    [self _setupPageNavigatorEnabled];
    [self _setupUsersEnabled];
    [self _updateUndoAndRedoButtons];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(_undoRedoNotificationReceived:) name:NSUndoManagerWillUndoChangeNotification object:nil]; // will !
    [nc addObserver:self selector:@selector(_undoRedoNotificationReceived:) name:NSUndoManagerDidRedoChangeNotification object:nil];  // did !
    [nc addObserver:self selector:@selector(_undoCheckpointNotificationReceived:) name:NSUndoManagerCheckpointNotification object:nil];
    [nc addObserver:self selector:@selector(_pageControllerNotificationReceived:) name:SWPageControllerTitleChangeNotification object:nil];
   // [nc addObserver:self selector:@selector(_pageControllerNotificationReceived:) name:SWPageControllerInterfaceIdiomChangeNotification object:nil];
    [nc addObserver:self selector:@selector(_pageControllerNotificationReceived:) name:SWPageControllerSelectionDidChangeNotification object:nil];
    [nc addObserver:self selector:@selector(_groupItemControllerNotificationReceived:) name:SWGroupItemControllerSelectionDidChangeNotification object:nil];
    
    [nc addObserver:self selector:@selector(_itemConfigurationControllerNotificationReceived:) name:SWItemConfigurationControllerDidChangeNameNotification object:nil];
//    [nc addObserver:self selector:@selector(_keyboardNotification:) name:SWKeyboardWillHideNotification object:nil];
//    [nc addObserver:self selector:@selector(_keyboardNotification:) name:SWKeyboardWillShowNotification object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //[_docModel clausureSources];
    
    [_docModel removeObserver:self];
    [_docModel.eventCenter removeObserver:self];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    
//    [self _dismissAddPopoverAnimated:YES];
//    //_addPopover = nil;
//    
//    [_toolsPopover dismissPopoverAnimated:YES];
//    _toolsPopover = nil;
    
    [self _dismissPopViews];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return YES;
//}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self _updateInterfaceIdiomAnimated:NO];
}

#pragma mark - Properties

- (SWPageController*)currentPageController
{
    return (id)self.masterViewController;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    [_docModel setEditMode:editing animated:animated];
}

- (UILabel*)emptyLabel
{
    if ( _emptyLabel == nil )
    {
        UIView *selfView = self.view;
        CGSize selfSize = selfView.bounds.size;
        CGRect labelFrame;
        labelFrame.size.width = 320;
        labelFrame.size.height = 40;
        labelFrame.origin.x = (selfSize.width-labelFrame.size.width)/2;
        labelFrame.origin.y = (selfSize.height-labelFrame.size.height)/2;
        _emptyLabel = [[UILabel alloc] initWithFrame:labelFrame];
        [_emptyLabel setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|
            UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        [_emptyLabel setBackgroundColor:[UIColor clearColor]];
        [_emptyLabel setTextColor:UIColorWithRgb(SystemDarkerBlueColor)];
        [_emptyLabel setShadowColor:[UIColor lightGrayColor]];
        [_emptyLabel setShadowOffset:CGSizeMake(0, 1)];
        [_emptyLabel setTextAlignment:NSTextAlignmentCenter];
        [_emptyLabel setFont:[UIFont boldSystemFontOfSize:24]];
        [selfView insertSubview:_emptyLabel atIndex:0];
    }
    return _emptyLabel;
}

- (void)_removeEmptyLabel
{
    [_emptyLabel removeFromSuperview];
    _emptyLabel = nil;
}

#pragma mark - IBActions



- (void)revealButtonActionB:(id)sender
{
    SWRevealViewController *revealController = self.revealViewController;
    if ( revealController )
    {
        [revealController revealToggleAnimated:YES];
        return;
    }
    
    SWToolbarViewController *toolbarController = self.toolbarViewController;
    [toolbarController leftOverlayPositionToggleAnimated:YES];
}




- (void)revealButtonAction:(id)sender
{
    SWRevealViewController *revealController = self.revealViewController;
    if ( revealController )
    {
        UIViewController *rearController = revealController.rearViewController;
        
        if ( rearController == nil )
        {
            SWRevealViewController *grandParentRevealController = revealController.revealViewController;
            [grandParentRevealController revealToggleAnimated:YES];
        }
        else
        {
            [revealController revealToggleAnimated:YES];
        }
        return;
    }
    
    SWToolbarViewController *toolbarController = self.toolbarViewController;
    [toolbarController leftOverlayPositionToggleAnimated:YES];
}


- (void)revealButtonActionN:(id)sender
{
    SWRevealViewController *revealController = self.revealViewController;
    FrontViewPosition position = revealController.frontViewPosition;
    
    SWRevealViewController *grandRevealController = revealController.revealViewController;
    FrontViewPosition grandPosition = grandRevealController.frontViewPosition;
    
    if ( position == FrontViewPositionLeft )
    {
        //[revealController setFrontViewPosition:FrontViewPositionRightMost animated:YES];
    
        FrontViewPosition newGrandPosition = grandPosition > FrontViewPositionLeft? FrontViewPositionLeft:FrontViewPositionRightMost;
        [grandRevealController setFrontViewPosition:newGrandPosition animated:YES];
    }
    else
    {
        [revealController setFrontViewPosition:FrontViewPositionLeft animated:YES];
        
        if ( grandPosition > FrontViewPositionLeft )
            [grandRevealController setFrontViewPosition:FrontViewPositionRightMost animated:YES];
    }
}



//- (IBAction)projectButtonAction:(id)sender
//{
//    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//    [nc postNotificationName:SWProjectButtonActionNotification object:nil userInfo:sender];
//}

- (void)undo:(id)sender
{
    //if ([_docModel.undoManager canUndo])
        [_docModel.undoManager undo];
}

- (void)redo:(id)sender
{
    //if ([_docModel.undoManager canRedo])
        [_docModel.undoManager redo];
}

//#define MODELBROWSER_IN_POPOVER

- (void)modelBrowserButtonAction:(id)sender
{
    [self _dismissPopViews];

    SWModelManager *manager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_docModel];
    //[manager toggleModelBrowserAnimated:YES presentingControllerKey:nil];
    [manager toggleModelBrowserForControllerWithIdentifier:nil animated:YES];
}

//- (IBAction)objectPickerButtonAction:(id)sender
//{
//    SWModelManager *manager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_docModel];
//    [manager toggleObjectPickerAnimated:YES];
//}

- (void)addButtonAction:(id)sender
{
    BOOL done = (_addCoverPopover != nil || _addPopover != nil);
    [self _dismissPopViews];
    
    if ( done )
        return;
    
    SWObjectType objectTypes = SWObjectTypeVisibleItem|SWObjectTypeBackgroundItem|SWObjectTypePage|SWObjectTypeAlarm;
    SWAddObjectViewController *addController = [[SWAddObjectViewController alloc] initWithDocument:_docModel
        allowedObjectTypes:objectTypes];
    addController.delegate = self;
    //addController.contentSizeForViewInPopover = CGSizeMake(320, 460);
    addController.preferredContentSize = CGSizeMake(320, 460);
    //addController.title = NSLocalizedString(@"Add", nil);
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:addController];
    

    if ( IS_IPHONE )
    {
        //[self setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        //[self presentViewController:nvc animated:YES completion:^
        
        _addCoverPopover = [[SWCoverVerticalPopoverController alloc] initWithContentViewController:nvc forPresentingInController:self];
        [_addCoverPopover presentCoverVerticalPopoverAnimated:YES completion:^
        {
            UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                target:self action:@selector(_dismisCoverVerticalController:)];
            [addController.navigationItem setLeftBarButtonItem:buttonItem];
        }];
    }
    else
    {
        _addPopover = [[UIPopoverController alloc] initWithContentViewController:nvc];
        _addPopover.delegate = self;
    
        [_addPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
    }
    [addController pushControllersToIndexPathPaths:_addPopoverIndexPathPaths];  // <- despres de present popover!!
}



- (void)toolsButtonAction:(id)sender
{
    BOOL done = (_toolsCoverPopover != nil || _toolsPopover != nil);
    [self _dismissPopViews];
    
    if ( done )
        return;
    
    SWToolsViewController *toolsController = [[SWToolsViewController alloc] initWithDocument:_docModel];
    toolsController.delegate = self;
    
    if ( IS_IPHONE )
    {
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:toolsController];
        [toolsController setTitle:NSLocalizedString(@"Tool Settings", nil)];
        
        _toolsCoverPopover = [[SWCoverVerticalPopoverController alloc] initWithContentViewController:nvc forPresentingInController:self];
        [_toolsCoverPopover presentCoverVerticalPopoverAnimated:YES completion:^
        {
            UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                target:self action:@selector(_dismisCoverVerticalController:)];
            [toolsController.navigationItem setLeftBarButtonItem:buttonItem];
        }];
        
    }
    else
    {
        _toolsPopover = [[UIPopoverController alloc] initWithContentViewController:toolsController];
        _toolsPopover.delegate = self;
        [_toolsPopover presentPopoverFromBarButtonItem:_toolsButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}


- (void)projectUserButtonAction:(id)sender
{
    [_docModel showProjectUserLogin];
}


- (void)_dismisCoverVerticalController:(id)sender
{
//    UIViewController *presented = [self presentedViewController];
//    [presented dismissViewControllerAnimated:YES completion:nil];
    
    [_toolsCoverPopover dismissCoverVerticalPopoverAnimated:YES completion:nil];
    _toolsCoverPopover = nil;
    
    [self _dismissAddPopoverAnimated:YES];
}


- (void)inspectorButtonAction:(id)sender
{
    [self _dismissPopViews];
    [self toggleRightDetailViewControllerAnimated:YES];
}



- (void)pageButtonAction:(id)sender
{
    [self _dismissPopViews];
    [self toggleLeftDetailViewControllerAnimated:YES];
}





- (void)customEditButtonAction:(id)sender
{
    BOOL nowEditing = !self.editing;
    [self setEditing:nowEditing animated:YES];
}

//- (IBAction)playButtonAction:(id)sender
//{
//    [self setEditing:NO animated:YES];
//}

#pragma mark - Public Methods

- (void)moveToRightViewController
{
    NSInteger selectedPageIndex = _docModel.selectedPageIndex;
    
    if (selectedPageIndex == NSNotFound)
        return;
        
    if (selectedPageIndex+1 >= _docModel.pages.count)
        return;
        
    [_docModel selectPageAtIndex:selectedPageIndex+1];
}

- (void)moveToLeftViewController
{
    NSInteger selectedPageIndex = _docModel.selectedPageIndex;
            
    if (selectedPageIndex == NSNotFound)
        return;
        
    if (selectedPageIndex-1 < 0)
        return;
        
    [_docModel selectPageAtIndex:selectedPageIndex-1];
}

#pragma mark - Private Methods


//- (void)_validateProjectNO
//{
//    if ( _docModel == nil )
//        return;
//    
//    NSString *projectID = _docModel.uuid;
//    
//    UInt32 owner = 0;
//    if ( HMiPadRun ) owner =  _docModel.ownerID;
//
//    [filesModel() validateProjectWithProjectID:projectID ownerID:owner completion:^(BOOL result)
//    {
//        if ( result == NO )
//            NSLog( @"Malu" );
//    }];
//    
//    
//    [filesModel() validateActivation:@"noseque" forProjectID:projectID withOwnerID:owner completion:^(BOOL result)
//    {
//        if ( result == NO )
//            NSLog( @"Malu" );
//    }];
//}



//- (void)_validateProject
//{
//    if ( _docModel == nil )
//        return;
//    
//    _projectValidated = YES;
//    NSString *projectID = _docModel.uuid;
//    
//    if ( HMiPadDev )
//    {
//        UInt32 owner = 0;
//        
//        
//        return;  // treure aixo:
//
//        [filesModel() validateProjectWithProjectID:projectID ownerID:owner completion:^(BOOL result)
//        {
//            _projectValidated = result;
//            [self _stopIntegratorTimer];
//            [self _resumeIntegratorTimer];
//        }];
//        
//        _projectValidated = NO;    // <-- no valid per defecte
//        [self _stopIntegratorTimer];
//        [self _resumeIntegratorTimer];
//    }
//    
//    else if ( HMiPadRun )
//    {
//        UInt32 owner =  _docModel.ownerID;
//        _projectValidated = YES;   // <-- valid per defecte
//        [filesModel() validateProjectWithProjectID:projectID ownerID:owner completion:^(BOOL result)
//        {
//            if ( result == NO )
//                NSLog( @"Malu" );
//        }];
//    }
//    
//}



//- (NSTimer*)integratorTimer
//{
//    if ( _integratorTimer == nil )
//        _integratorTimer = [NSTimer scheduledTimerWithTimeInterval:1e100 target:self selector:@selector(_integratorTimerFired:) userInfo:nil repeats:YES];
//    
//    return _integratorTimer;
//}

//- (void)_dismissTimerActionSheetAnimated:(BOOL)animated
//{
//    [_actionSheet dismissWithClickedButtonIndex:[_actionSheet cancelButtonIndex] animated:animated];
//    _actionSheet = nil;
//}

//- (void)_integratorTimerFired:(id)sender
//{
//    NSString *title = NSLocalizedString(@"Timeout", nil);
//    
//    _actionSheet = [[UIActionSheet alloc]
//        initWithTitle:title delegate:self
//        cancelButtonTitle:nil //NSLocalizedString(@"Cancel",nil)
//        destructiveButtonTitle:nil
//        otherButtonTitles:NSLocalizedString(@"Ok",nil), nil];
//    
//    UIView *view = self.view;
//    [_actionSheet showInView:view];
//    _actionSheet.tag = ActionSheetTimer;
//}


//- (void)_resumeIntegratorTimer
//{
//    if ( !_projectValidated )
//    {
//        [self.integratorTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:_nextTimeInterval]];
//        _nextTimeInterval = ceil(_nextTimeInterval*0.67);
//    }
//}

//- (void)_stopIntegratorTimer
//{
//    if ( _projectValidated && _integratorTimer )
//    {
//        [self _invalidateIntegratorTimer];
//        return;
//    }
//    
//    [_integratorTimer setFireDate:[NSDate distantFuture]];
//    _nextTimeInterval = 60*10;
//    [self _dismissTimerActionSheetAnimated:NO];
//}


//- (void)_freezeIntegratorTimer
//{
//    [_integratorTimer setFireDate:[NSDate distantFuture]];
//    [self _dismissTimerActionSheetAnimated:NO];
//}



//- (void)_invalidateIntegratorTimer
//{
//    [_integratorTimer invalidate];
//    _integratorTimer = nil;
//    [self _dismissTimerActionSheetAnimated:NO];
//}



- (void)_setupPageNavigatorEnabled
{
    BOOL editMode = _docModel.editMode;
    BOOL shouldDisable = editMode ? [_docModel.pages count] == 0 : [_docModel.visiblePages count] == 0;

    [_pageButtonItem setEnabled:!shouldDisable];
    
    SWLeftViewPosition position = self.leftViewPosition;
    BOOL isHidden = (position==SWLeftViewPositionHidden);
    
    if ( shouldDisable && !isHidden  )
        [self toggleLeftDetailViewControllerAnimated:YES];
}


- (void)_setupUsersEnabled
{
    BOOL shouldDisable = [_docModel.projectUsers count] == 0;

    [_projectUserButtonItem setEnabled:!shouldDisable];
}



- (void)_storeAddPopoverState
{
    UINavigationController *navController = (id)[_addPopover contentViewController];
    if ( navController == nil ) navController = (id)[_addCoverPopover contentViewController];
    SWAddObjectViewController *topController = (SWAddObjectViewController*)navController.topViewController;
    _addPopoverIndexPathPaths =  topController.indexPathPaths;
}


- (void)_dismissAddPopoverAnimated:(BOOL)animated
{
    if ( _addPopover == nil && _addCoverPopover == nil )
        return;

    [self _storeAddPopoverState];
    
    [_addPopover dismissPopoverAnimated:animated];
    [_addCoverPopover dismissCoverVerticalPopoverAnimated:YES completion:nil];
    
    _addCoverPopover = nil;
    _addPopover = nil;
}


- (void)_dismissPopViews
{
//    [_toolsActionSheet dismissWithClickedButtonIndex:[_toolsActionSheet cancelButtonIndex] animated:YES];
//    _toolsActionSheet = nil;
    
    //[_addPopover dismissPopoverAnimated:YES];
    [self _dismissAddPopoverAnimated:YES];
    //_addPopover = nil;
    
    [_toolsPopover dismissPopoverAnimated:YES];
    _toolsPopover = nil;
    
    [self _dismisCoverVerticalController:nil];
}

//- (void)_documentPrepare
//{
//    self.undoManager = [_docModel undoManager];
//    //_state = SWDocumentControllerStateUndefined;
//    //_selectedPageControllerIndex = NSNotFound;
//    
//}

//- (void)_refreshControllerViewForOpenedDocument
//{
//    SWDocumentModel *docModel = _document.docModel;
//    
//    if (!docModel)
//        return;
//
//    if (docModel.selectedPageIndex != NSNotFound) 
//    {
//        //_state = SWDocumentControllerStatePage;
//        _selectedPageControllerIndex = docModel.selectedPageIndex;
//        SWPageController *pageController = [self _pageControllerAtIndex:_selectedPageControllerIndex];
//        [self setMasterViewController:pageController];
//    }
//    
//   // [self _updateControllerViewsWhenPageChanging];
//}

//- (void)_refreshControllerViewForOpenedDocument
//{
//    SWPageController *pageController = nil;
//    
//    NSInteger selectedPageIndex = _docModel.selectedPageIndex;
//    if (selectedPageIndex != NSNotFound)
//    {
//        pageController = [self _pageControllerAtIndex:selectedPageIndex];
//    }
//    
//    [self setMasterViewController:pageController animated:YES];
//}

- (SWPageController*)_pageControllerAtIndex:(NSInteger)index
{
    NSArray *pages = _docModel.pages;
    if (index >= pages.count || index < 0)  // inclou el cas index==NSNotFound
        return nil;
    
    SWPage *page = [pages objectAtIndex:index];
    SWPageController *vc = [[SWPageController alloc] initWithPage:page];
    
    return vc;
}


//- (void)_updateControllerTitleV
//{
//    NSString *title = nil;
//    NSString *secondaryTitle = nil;
//
//    NSInteger selectedPageIndex = _docModel.selectedPageIndex;
//    NSArray *pages = _docModel.pages;
//    
//    // al menys una pagina mostrada
//    if ( pages.count > 0 && selectedPageIndex != NSNotFound)
//    {
//        SWPage *page = [_docModel.pages objectAtIndex:selectedPageIndex];
//        NSString *pageTitle = [page.title valueAsString];
//        
//        //NSIndexSet *set = self.currentPageController.selectedItemIndexes;
//        NSIndexSet *selectedIndexSet = page.selectedItemIndexes;
//        NSInteger selectedCount = selectedIndexSet.count;
//        
//        if (selectedCount == 0)
//        {
//            //secondaryTitle = NSLocalizedString(@"Project Name",nil);
//            secondaryTitle = _docModel.title;
//            title = pageTitle;
//        }
//        else if (selectedCount == 1)
//        {
//            SWItem *item = [page.items objectAtIndex:[selectedIndexSet firstIndex]];
//            secondaryTitle = pageTitle;
//            title = [NSString stringWithFormat:@"%@: %@", page.identifier, item.identifier];
//        }
//        else
//        {
//            secondaryTitle = pageTitle;
//            title = NSLocalizedString(@"Multiple Selection", nil);
//        }
//        
//        [self _removeEmptyLabel];
//    }
//    
//    // cap pagina mostrada
//    else
//    {
//        if ( _docModel )
//        {
//            secondaryTitle = _docModel.title;
//            title = NSLocalizedString(@"No Pages",nil);
//            self.emptyLabel.text = NSLocalizedString(@"Project Contains No Pages", nil);
//        }
//        else
//        {
//            secondaryTitle = NSLocalizedString(@"No Project Open",nil);
//            title = NSLocalizedString(@ AppName,nil);
//            self.emptyLabel.text = NSLocalizedString(@"No Project", nil);
//        }
//    }
//    
//    self.title = title;
//    //[_titleBarButtonItem setTitle:title];
//    _titleView.secondaryLabel.text = secondaryTitle;
//    _titleView.mainLabel.text = title;
//    [_titleView sizeToFit];
//}

- (SWPage *)_selectedPage
{
    SWPage *page = nil;
    NSInteger selectedPageIndex = _docModel.selectedPageIndex;
    NSArray *pages = _docModel.pages;
    
    // al menys una pagina mostrada
    if ( pages.count > 0 && selectedPageIndex != NSNotFound)
    {
        page = [_docModel.pages objectAtIndex:selectedPageIndex];
    }
    
    return page;
}


- (void)_updateToolbarColor
{
    BOOL editMode = self.editing;
    UIColor *barColor = UIColorWithRgb(editMode?BlueSelectionColor:SystemRGBWhite);
    UIColor *tintColor = editMode ? UIColorWithRgb(SystemRGBWhite) : nil ;
    UIToolbar *toolbar = self.toolbarViewController.toolbar;
    
    [toolbar setBarTintColor:barColor];
    [toolbar setTintColor:tintColor];
    [self setNeedsStatusBarAppearanceUpdate];
}


- (void)_updateControllerTitleColor
{
    UIColor *tintsColor = UIColorWithRgb(self.editing?SystemRGBWhite:SystemDarkerBlueColor);
    [_titleView setTintsColor:tintsColor];
}



- (NSString*)_getItemSelectionName:(SWObject*)item
{
    NSString *identifier = item.identifier;
    NSString *moreSelected = nil;
    if ( [item conformsToProtocol:@protocol(SWGroup)] )
    {
        id<SWGroup> group = (id)item;
        NSIndexSet *selectedIndexSet = group.selectedItemIndexes;
        NSInteger selectedCount = selectedIndexSet.count;
        
        if ( selectedCount == 1 )
        {
            SWItem *selectedItem = [group.items objectAtIndex:[selectedIndexSet firstIndex]];
            moreSelected = [self _getItemSelectionName:selectedItem];
        }

        else if ( selectedCount > 1 )
            moreSelected = NSLocalizedString(@"Multiple", nil);
        
    }
    
    if ( moreSelected )
        return [NSString stringWithFormat:@"%@:%@", identifier, moreSelected];
    
    return identifier;
}


- (void)_updateControllerTitle
{
    NSString *title = nil;
    NSString *secondaryTitle = nil;
    
//    SWPageController *pageController = [self currentPageController];
//    SWPage *page = pageController.page;
    
    SWPage *page = [self _selectedPage];
    
    // al menys una pagina mostrada
    if ( page != nil )
    {
        NSString *pageTitle = [page.title valueAsString];
        
        NSIndexSet *selectedIndexSet = page.selectedItemIndexes;
        NSInteger selectedCount = selectedIndexSet.count;
        
        if (selectedCount == 0)
        {
            //secondaryTitle = NSLocalizedString(@"Project Name",nil);
            secondaryTitle = _docModel.title;
            title = pageTitle;
        }
        else if (selectedCount == 1)
        {
            //SWItem *item = [page.items objectAtIndex:[selectedIndexSet firstIndex]];
            secondaryTitle = pageTitle;
            //title = [NSString stringWithFormat:@"%@: %@", page.identifier, item.identifier];
            
            title = [self _getItemSelectionName:page];
            
        }
        else
        {
            secondaryTitle = pageTitle;
            title = NSLocalizedString(@"Multiple Selection", nil);
        }
        
        [self _removeEmptyLabel];
    }
    
    // cap pagina mostrada
    else
    {
        if ( _docModel )
        {
            secondaryTitle = _docModel.title;
            title = NSLocalizedString(@"No Pages",nil);
            self.emptyLabel.text = NSLocalizedString(@"Project Contains No Pages", nil);
        }
        else
        {
            secondaryTitle = NSLocalizedString(@"No Project Open",nil);
            title = NSLocalizedString(@ AppName,nil);
            self.emptyLabel.text = NSLocalizedString(@"No Project", nil);
        }
    }
    
    self.title = title;
    //[_titleBarButtonItem setTitle:title];
    _titleView.secondaryLabel.text = secondaryTitle;
    _titleView.mainLabel.text = title;
    [_titleView sizeToFit];
}


- (void)_updateInterfaceIdiomAnimated:(BOOL)animated
{
    BOOL editMode = _docModel.editMode;
    UIInterfaceOrientation orientation = self.interfaceOrientation;

    SWDeviceInterfaceIdiom deviceIdiom = editMode ? SWDeviceInterfaceIdiomPad: _docModel.interfaceIdiom;
    
    SWPage *page = [self _selectedPage];
    CGSize size = self.view.bounds.size;

    if ( UIInterfaceOrientationIsLandscape(orientation) )
        size = [page defaultSizeLandscapeWithDeviceIdiom:deviceIdiom];
    else
        size = [page defaultSizePortraitWithDeviceIdiom:deviceIdiom];
    
    [self setMasterSize:size animated:animated];
}


- (void)_setupResizerView
{
    BOOL showResizer = NO;

    if ( _docModel.enableFineFramePositioning )
    {
        NSInteger selectedPageIndex = _docModel.selectedPageIndex;
        NSArray *pages = _docModel.pages;
    
        // al menys una pagina mostrada
        if ( pages.count > 0 && selectedPageIndex != NSNotFound)
        {
            SWPage *page = [_docModel.pages objectAtIndex:selectedPageIndex];
        
            NSIndexSet *selectedIndexSet = page.selectedItemIndexes;
            showResizer = (selectedIndexSet.count > 0);
        }
    }
    
    if ( showResizer )
    {
        CGPoint position = CGPointZero;
        if ( UIInterfaceOrientationIsLandscape(self.interfaceOrientation) )
            position = _docModel.landscapeResizerPosition;
        else
            position = _docModel.portraitResizerPosition;
    
        if ( CGPointEqualToPoint(CGPointMake(0,0), position) )
        {
            CGSize boundsSize = self.view.bounds.size;
            position.x = boundsSize.width/2;
            position.y = boundsSize.height-200;
        };
            
        _layoutResizerView.center = position;
        [_layoutResizerView presentResizer];
    }
    else
    {
        [_layoutResizerView dismissResizerAnimated:YES];
    }
}



- (void)_updateUndoAndRedoButtons
{
    NSUndoManager *undoManager = _docModel.undoManager;
    
    SWKeyboardListener *keyb = [SWKeyboardListener sharedInstance];
    BOOL canEnable = !keyb.isVisible;
    
    _undoButtonItem.enabled = canEnable && undoManager.canUndo;
    _redoButtonItem.enabled = canEnable && undoManager.canRedo;
}


//- (NSArray*)_rightBarButtonItemsForEditingState_ambView:(BOOL)editing
//{
//    UIBarButtonItem *more = nil;
//
//    UIBarButtonItem *theViewItem = [[UIBarButtonItem alloc] initWithCustomView:_infoView];
//    _infoView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
//    _infoView.layer.cornerRadius = 5;
//    NSArray *fixedItems = [NSArray arrayWithObjects: _flexibleButtonItem, _inspectorButtonItem, theViewItem, nil];
//    
//    UIToolbar *fixedToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,250,44)];
//    [fixedToolBar setItems:fixedItems animated:NO];
//    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithCustomView:fixedToolBar];
//    
//
//    return [NSArray arrayWithObjects:self.editButtonItem, fixed, more, nil];
//}
//
//- (NSArray*)_leftBarButtonItemsForEditingState_ambView:(BOOL)editing
//{            
//    UIBarButtonItem *more = nil;
//    
//    if (editing) 
//    {
//        NSArray *moreItems = [NSArray arrayWithObjects:
//            _toolsButtonItem, _fixedButtonItem,
//            _modelBrowserButtonItem, _addButtonItem, _fixedButtonItem,
//            _undoButtonItem, _redoButtonItem, _flexibleButtonItem, nil];
//            
//        UIToolbar *moreToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,250,44)];
//        [moreToolBar setItems:moreItems animated:YES];
//        more = [[UIBarButtonItem alloc] initWithCustomView:moreToolBar];
//    }
//    
//    return [NSArray arrayWithObjects:_projectButtonItem, more, nil];
//}


- (NSArray*)_barButtonItemsForEditingState:(BOOL)editing
{

    NSMutableArray *items = [NSMutableArray array];

    // left
    
//    UIImage *revealImage = [UIImage imageNamed:@"1099-list-1-toolbar.png"];
//    //UIImage *revealImage = [UIImage imageNamed:@"727-more-selected.png"];
//
//    _revealButtonItem = [[UIBarButtonItem alloc] initWithImage:revealImage style:UIBarButtonItemStylePlain
//        target:self action:@selector(revealButtonAction:)];
    
    [items addObject:_revealButtonItem];
    
    if ( _docModel != nil )
    {
        NSArray *moreItems = nil;
        if ( IS_IPHONE )
        {
        }
        else
        {
            moreItems = @[_shortFixedButtonItem,_pageButtonItem];
            [items addObjectsFromArray:moreItems];
        }
        
        moreItems = @[_fixedButtonItem, _projectUserButtonItem];
        [items addObjectsFromArray:moreItems];
        
        if (editing)
        {
            moreItems = @[_fixedButtonItem, _toolsButtonItem, _fixedButtonItem, _undoButtonItem, _shortFixedButtonItem, _redoButtonItem];
            [items addObjectsFromArray:moreItems];
        }
    }
    
    // center
    
    if ( !IS_IPHONE || !editing || !_docModel )
    {
        [items addObjectsFromArray:@[_flexibleButtonItem,_titleBarButtonItem,_flexibleButtonItem]];
    }
    else
    {
        [items addObject:_flexibleButtonItem];
    }
    
    // right
    
    if ( _docModel != nil )
    {
        if (editing) 
        {
            NSArray *moreItems = nil;
            if ( IS_IPHONE )
            {
                moreItems = @[_addButtonItem, _shortFixedButtonItem, _modelBrowserButtonItem];
            }
            else
            {
                moreItems = @[_addButtonItem, _shortFixedButtonItem, _modelBrowserButtonItem, _fixedButtonItem, _inspectorButtonItem];
            }
            [items addObjectsFromArray:moreItems];
            
        }
        else
        {
            if ( IS_IPHONE )
            {
            }
            else
            {
                [items addObjectsFromArray:@[_statusViewItem] ];
            }
        }

//        NSArray *fixedItems = @[_fixedButtonItem, _inspectorButtonItem];
//        [items addObjectsFromArray:fixedItems];
        
        if ( HMiPadDev )
        {
            // edit button
            NSArray *moreItems = @[_shortFixedButtonItem,self.editButtonItem];
            [items addObjectsFromArray:moreItems];
        }
    }

    return items;
}



- (void)_gestureRecognized:(UISwipeGestureRecognizer*)recognizer
{
    CGPoint point = [recognizer locationInView:self.view];
        
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateEnded:
            if (point.x < 40 && recognizer.direction == UISwipeGestureRecognizerDirectionRight)
                _firstTouchIsValidForPageChanging = YES;
            else if (self.view.frame.size.width - point.x < 40 && recognizer.direction == UISwipeGestureRecognizerDirectionLeft) 
                _firstTouchIsValidForPageChanging = YES;
            else 
                _firstTouchIsValidForPageChanging = NO;
            
            if (_firstTouchIsValidForPageChanging) 
            {
                if ( recognizer.direction == UISwipeGestureRecognizerDirectionRight) 
                {
                    [self moveToLeftViewController];
                } 
                
                if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) 
                {
                    [self moveToRightViewController];
                }
            }
            break;
            
        default:
            break;
    }
}


- (void)_performTransitionTo:(NSInteger)index withDirection:(NSInteger)direction
{
    SWPageController *currentController = [self currentPageController];
    [currentController invalidateLayer];
    
    SWPageController *nextController = [self _pageControllerAtIndex:index];
    [nextController setEditing:self.editing animated:NO];
    
    SWMasterViewControllerPresentationAnimation animation = SWMasterViewControllerPresentationAnimationNone;
    
    if ( direction > 0 )
        animation = SWMasterViewControllerPresentationAnimationLeft;
    
    if ( direction < 0 || index == NSNotFound )
        animation = SWMasterViewControllerPresentationAnimationRight;
    
    
//    if ( direction > 0 )
//        animation = SWMasterViewControllerPresentationAnimationUp;
//    
//    if ( direction < 0 || index == NSNotFound )
//        animation = SWMasterViewControllerPresentationAnimationDown;
//    
//    
//    if ( direction > 0 )
//        animation = SWMasterViewControllerPresentationAnimationCurlUp;
//    
//    if ( direction < 0 || index == NSNotFound )
//        animation = SWMasterViewControllerPresentationAnimationCurlDown;
//    
//    animation = SWMasterViewControllerPresentationAnimationFade;  // <-- fem prevaldre aquesta

    SWPage *currentPage = currentController.page;
    SWPage *nextPage = nextController.page;
    SWModalStyle currentModalStyle = [currentPage.modalStyle valueAsInteger];
    SWModalStyle nextModalStyle = [nextPage.modalStyle valueAsInteger];
    SWPageTransitionStyle currentTransitionStyle = [currentPage.pageTransitionStyle valueAsInteger];
    SWPageTransitionStyle nextTransitionStyle = [nextPage.pageTransitionStyle valueAsInteger];

    SWPageTransitionStyle transitionStyle;
    if ( currentModalStyle == nextModalStyle )
    {
        // els dos modals o els dos normals, agafem el estil del que entra o surt en funcio de la direccio
        transitionStyle = direction>=0?nextTransitionStyle:currentTransitionStyle;
        
//        if ( currentModalStyle == SWModalStyleModal )
//        {
//            // els dos modals, agafem el estil del que entra o surt en funcio de la direccio
//            transitionStyle = direction>=0?nextTransitionStyle:currentTransitionStyle;
//        }
//        else
//        {
//            // els dos normals, agafem el estil del nou
//            transitionStyle = nextTransitionStyle;
//        }
    }
    else
    {
        // un dels dos modals, agafem el estil del modal i forcem la direccio del que es modal
        if ( currentModalStyle == SWModalStyleModal )
        {
            transitionStyle = currentTransitionStyle;
            direction = -1;
        }
        else
        {
            transitionStyle = nextTransitionStyle;
            direction = 1;
        }
    }
    
    animation = SWMasterViewControllerPresentationAnimationNone;
    switch ( transitionStyle )
    {
        case SWPageTransitionStyleNone:
            animation = SWMasterViewControllerPresentationAnimationNone;
            break;
            
        case SWPageTransitionStyleFade:
            animation = SWMasterViewControllerPresentationAnimationFade;
            break;
            
        case SWPageTransitionStyleCurl:
            animation = direction>=0?SWMasterViewControllerPresentationAnimationCurlUp:SWMasterViewControllerPresentationAnimationCurlDown;
            break;
            
        case SWPageTransitionStyleHorizontalShift:
            animation = direction>=0?SWMasterViewControllerPresentationAnimationLeft:SWMasterViewControllerPresentationAnimationRight;
            break;
            
        case SWPageTransitionStyleVerticalShift:
            animation = direction>=0?SWMasterViewControllerPresentationAnimationUp:SWMasterViewControllerPresentationAnimationDown;
            break;
            
        case SWPageTransitionStyleHorizontalFlip:
            animation = direction>=0?SWMasterViewControllerPresentationAnimationFlipFromLeft:SWMasterViewControllerPresentationAnimationFlipFromRight;
            break;
    }


    [self replaceMasterViewControllerByController:nextController withAnimation:animation];
}


//- (void)_saveWithType:(SWDocumentSavingType)savingType
//{
//    NSURL *fileURL = _document.fileURL;
//        
//    _document.savingType = savingType;
//    [_document saveToURL:fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success)
//    {
//        if (!success) 
//        {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
//                        message:@"The document couldn't be saved" 
//                        delegate:nil 
//                        cancelButtonTitle:@"Dismiss" 
//                        otherButtonTitles:nil];
//            [alert show];
//        }
//        _document.savingType = SWDocumentSavingTypeBinary;
//        [model() filesArrayTouchForCategory:kFileCategorySourceFile];
//    }];
//}


//- (void)_closeDocument
//{
//#warning // ATENCIO: mogut aqui per tenir actualitzat el model al obrir, no es correcte perque si falla el guardar quedara desconectat, encara que el switch continui on, a més no va perque el delegat de la desconexio es crida igualment despres d'haver guardat
//    [_docModel clausureSources];
//    
//    _document.savingType = SWDocumentSavingTypeBinary;
//    [_document closeWithCompletionHandler:^(BOOL success)
//    {
//        if (!success) 
//        {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
//                        message:@"The document couldn't be saved"
//                        delegate:nil 
//                        cancelButtonTitle:@"Dismiss" 
//                        otherButtonTitles:nil];
//            [alert show];
//        }
//        else 
//        {
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//        _document.savingType = SWDocumentSavingTypeBinary;
//        [model() filesArrayTouchForCategory:kFileCategorySourceFile];
//    }];
//}


- (void)_setRecognizersForPosition:(FrontViewPosition)position
{
    SWRevealViewController *revealController = self.revealViewController;

    UIPanGestureRecognizer *panGestureRecognizer = revealController.panGestureRecognizer;
    [panGestureRecognizer.view removeGestureRecognizer:panGestureRecognizer];
    
    UIPanGestureRecognizer *grandPanGestureRecognizer = revealController.revealViewController.panGestureRecognizer;
    //[grandPanGestureRecognizer.view removeGestureRecognizer:grandPanGestureRecognizer];

    SWToolbarViewController *toolBarController = self.toolbarViewController;
    
    if ( position > FrontViewPositionLeft )
    {
    
        
    
        if ( grandPanGestureRecognizer )
        {
            UINavigationController *navController = (id)revealController.rearViewController;
            [navController.navigationBar addGestureRecognizer:grandPanGestureRecognizer];
        }
        
        [toolBarController.view addGestureRecognizer:panGestureRecognizer];
    }

    else if ( position == FrontViewPositionLeft )
    {
        if ( grandPanGestureRecognizer )
            [toolBarController.toolbar addGestureRecognizer:grandPanGestureRecognizer];
        
        [self.view setUserInteractionEnabled:YES];
    }
}





#pragma mark - Notifications



- (void)_pageControllerNotificationReceived:(NSNotification*)notification
{
    NSString *notificationName = [notification name];
    SWPageController *pageController = [notification object];
    
    if ( pageController != [self currentPageController] )
        return;
    
    if ([notificationName isEqualToString:SWPageControllerTitleChangeNotification])
    {
        [self _updateControllerTitle];
    }

    else if ( [notificationName isEqualToString:SWPageControllerSelectionDidChangeNotification])
    {
        [self _updateControllerTitle];
        [self _setupResizerView];
    }
}

- (void)_groupItemControllerNotificationReceived:(NSNotification*)notification
{
    NSString *notificationName = [notification name];
    if ( [notificationName isEqualToString:SWGroupItemControllerSelectionDidChangeNotification] )
    {
        [self _updateControllerTitle];
    }
}

- (void)_itemConfigurationControllerNotificationReceived:(NSNotification*)notification
{
    NSString *notificationName = [notification name];
    
    if ( [notificationName isEqualToString:SWItemConfigurationControllerDidChangeNameNotification] )
    {
        [self _updateControllerTitle];
    }
}


- (void)_undoCheckpointNotificationReceived:(NSNotification*)notification
{
    [self _updateUndoAndRedoButtons];
}


- (void)_undoRedoNotificationReceived:(NSNotification*)notification
{
    NSUndoManager *undoManager = _docModel.undoManager;

    NSString *undoRedoString = NSLocalizedString(@"UNDOING",nil);
    if ([undoManager isRedoing])
        undoRedoString = NSLocalizedString(@"REDOING", nil);
    
    SWAlertCenter *ac = [SWAlertCenter defaultCenter];
    [ac postAlertWithMessage:[undoManager undoActionName] title:undoRedoString];
    [ac groupPendingAlerts];
}


//- (void)_keyboardNotification:(NSNotification*)notification
//{
//    [self _updateUndoAndRedoButtons];
//}

//- (void)_pageControllerDocThumbnailChangeNotification:(NSNotification*)note
//{
////    NSArray *pages = _docModel.pages;
////    SWDocument *document = _document;
////    UIImage *image = note.userInfo[@1];
////    NSLog( @"gotImage:%@", image );
//}


#pragma mark - SWDocumentStatusViewDelegate

- (void)documentStatusViewDidTouchUp:(SWDocumentStatusView *)statusView
{
    [self inspectorButtonAction:nil];
}



@end



#pragma mark - SWToolbarViewControllerDelegate

@implementation SWDocumentController (SWToolBarViewController)

- (void)toolbarViewController:(SWToolbarViewController *)controller willMoveLeftOverlayViewControllerToPosition:(SWLeftOverlayPosition)position animated:(BOOL)animated
{
    if ( position == SWLeftOverlayPositionShown)
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:SWDocumentControllerPartialRevealNotification object:nil];
        
        [_document saveWithCompletion:nil];
        
        [self.view setUserInteractionEnabled:NO];
        
        if ( IS_IPHONE )
        {
            SWModelManager *manager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_docModel];
            [manager removeAllModelPopoversFromControllerWithIdentifier:nil animated:YES];
        }
    }
}


- (void)toolbarViewController:(SWToolbarViewController *)controller didMoveLeftOverlayViewControllerToPosition:(SWLeftOverlayPosition)position animated:(BOOL)animated
{
    if ( position == SWLeftOverlayPositionHidden)
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:SWDocumentControllerFullRevealNotification object:nil];
        
        [self.view setUserInteractionEnabled:YES];
    }
}


- (void)toolbarViewControllerDidHandleTapRecognizer:(SWToolbarViewController *)controller
{


}


//- (void)toolbarViewController:(SWToolbarViewController *)controller panGestureMovedToLocation:(CGFloat)location progress:(CGFloat)progress
//{
//    if ( progress > 1 ) progress = 1;
//    [self.view setAlpha:1-(1-DisabledAlphaValue)*progress ];
//}


//- (void)toolbarViewController:(SWToolbarViewController*)controller animateToPosition:(SWLeftOverlayPosition)position
//{
//    BOOL revealed = (position==SWLeftOverlayPositionHidden);
//    [self.view setAlpha:revealed?1.0:DisabledAlphaValue];
//}

@end




#pragma mark - RevealViewControllerDelegate

@implementation SWDocumentController (SWRevealViewController)


//- (void)revealControllerB:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position
//{
//    if ( position > FrontViewPositionLeft )
//    {
//        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//        [nc postNotificationName:SWDocumentControllerPartialRevealNotification object:nil];
//        //[_document saveForSaveOperation:UIDocumentSaveForOverwriting completionHandler:nil];
//        
//        [_document saveWithCompletion:nil];
//        //[filesModel().fileDocument saveDocumentWithCompletion:nil];
//        
//        SWToolbarViewController *toolBarController = self.toolbarViewController;
//        UIPanGestureRecognizer *panGestureRecognizer = revealController.panGestureRecognizer;
//        [panGestureRecognizer.view removeGestureRecognizer:panGestureRecognizer];
//        [toolBarController.view addGestureRecognizer:panGestureRecognizer];
//        
//        [self.view setUserInteractionEnabled:NO];
//        //[self.masterViewController.view setUserInteractionEnabled:NO];
//        
//        if ( IS_IPHONE )
//        {
//            SWModelManager *manager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_docModel];
//            [manager removeAllModelPopoversFromControllerWithIdentifier:nil animated:YES];
//        }
//    }
//    
//    [self _dismissPopViews];
//}
//
//
//- (void)revealControllerB:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
//{
//    if ( position == FrontViewPositionLeft )
//    {
//        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//        [nc postNotificationName:SWDocumentControllerFullRevealNotification object:nil];
//        
//        SWToolbarViewController *toolBarController = self.toolbarViewController;
//        UIPanGestureRecognizer *panGestureRecognizer = revealController.panGestureRecognizer;
//        [panGestureRecognizer.view removeGestureRecognizer:panGestureRecognizer];
//        [toolBarController.toolbar addGestureRecognizer:panGestureRecognizer];
//        
//        [self.view setUserInteractionEnabled:YES];
//    }
//}
//
//
//- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position
//{
//    
//    if ( position > FrontViewPositionLeft )
//    {
//        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//        [nc postNotificationName:SWDocumentControllerPartialRevealNotification object:nil];
//        
//        [_document saveWithCompletion:nil];
//        
//        [self.view setUserInteractionEnabled:NO];
//        
//        if ( IS_IPHONE )
//        {
//            SWModelManager *manager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_docModel];
//            [manager removeAllModelPopoversFromControllerWithIdentifier:nil animated:YES];
//        }
//    }
//    
//    [self _dismissPopViews];
//}
//
//
//- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
//{
//    if ( position == FrontViewPositionLeft )
//    {
//        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//        [nc postNotificationName:SWDocumentControllerFullRevealNotification object:nil];
//        
//        [self.view setUserInteractionEnabled:YES];
//    }
//    
//    [self _setRecognizersForPosition:position];
//}
//
//
//
//
//- (void)revealController:(SWRevealViewController *)revealController panGestureMovedToLocation:(CGFloat)location progress:(CGFloat)progress
//{
//    if ( progress > 1 ) progress = 1;
//    [self.view setAlpha:1-(1-DisabledAlphaValue)*progress ];
//}
//
//
//- (void)revealController:(SWRevealViewController *)revealController animateToPosition:(FrontViewPosition)position
//{
//    BOOL revealed = (position==FrontViewPositionLeft);
//    [self.view setAlpha:revealed?1.0:DisabledAlphaValue];
//}
//


@end


#pragma mark - SWToolbarViewController

@implementation SWDocumentController (SWToolbarViewController)




@end



#pragma mark - ResizerView

@implementation SWDocumentController (ResizerView)

#pragma mark - ResizerView Delegate

- (void)resizerView:(SWLayoutResizerView*)resizerView moveToDirection:(SWLayoutResizerViewDirection)direction
{
    SWPageController *pageController = [self currentPageController];
    //[pageController.layoutView moveToDirection:direction];
    [pageController moveToDirection:direction];
}

- (void)resizerView:(SWLayoutResizerView*)resizerView resizeToDirection:(SWLayoutResizerViewDirection)direction
{
    SWPageController *pageController = [self currentPageController];
    //[pageController.layoutView resizeToDirection:direction];
    [pageController resizeToDirection:direction];
}


- (void)resizerView:(SWLayoutResizerView *)resizerView didChangedPosition:(CGPoint)position
{
    if ( UIInterfaceOrientationIsLandscape(self.interfaceOrientation) )
        _docModel.landscapeResizerPosition = position;
    else
        _docModel.portraitResizerPosition = position;
}

@end



#pragma mark - Document Model

@implementation SWDocumentController (ModelObservers)


#pragma mark - Document Model Observer

- (void)documentModel:(SWDocumentModel *)docModel selectedPageDidChange:(NSInteger)index direction:(NSInteger)direction
{
    [self _performTransitionTo:index withDirection:direction];
    [self _updateControllerTitle];
    [self _updateInterfaceIdiomAnimated:NO];
    [self _setupResizerView];
    
    //[self _performTransitionTo:index withDirection:direction];

}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    if ( self.editing )
        return UIStatusBarStyleLightContent;
    else
        return UIStatusBarStyleDefault;
}


- (void)documentModel:(SWDocumentModel*)docModel editingModeDidChangeAnimated:(BOOL)animated
{
    BOOL editMode = docModel.editMode;
    
    if ( self.editing != editMode )   // evitem la rec
        self.editing = editMode;
    
    //NSLog( @"1");

    if (!editMode)
    {
        for (SWPage *page in _docModel.pages)
            [page deselectItemsAtIndexes:[page selectedItemIndexes]];
    }

    [self setToolbarControllerItems:[self _barButtonItemsForEditingState:editMode] animated:animated];
    
    SWModelManager *manager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_docModel];
    if (editMode)
    {
        [manager presentHiddenPopoversForControllerWithIdentifier:nil animated:animated];
    }
    else
    {
        [manager hidePresentedPopoversForControllerWithIdentifier:nil animated:animated];
        
//        [self _dismissAddPopoverAnimated:YES];
//        _addPopover = nil;
//        
//        [_toolsPopover dismissPopoverAnimated:animated];
//        _toolsPopover = nil;
        
        [self _dismissPopViews];
    }
    
    [self _updateControllerTitleColor];
    [self _updateToolbarColor];
    
    [self setScalingEnabled:editMode];
    [self _updateInterfaceIdiomAnimated:animated];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSString *notificationName = editMode?SWDocumentDidBeginEditingNotification:SWDocumentDidEndEditingNotification;
    [nc postNotificationName:notificationName object:nil userInfo:nil];
    
    
    //NSLog( @"2");
}

- (void)documentModelEditingPropertiesDidChange:(SWDocumentModel *)docModel
{
    [self _setupResizerView];
}


// La elemimiacio de configuradors per els objectes a l'arrel del model la gestionem aqui
// #cucut
//- (void)documentModel:(SWDocumentModel *)docModel willRemoveObjectsOfType:(SWArrayType)type atIndexes:(NSIndexSet *)indexes
//{
//    NSArray *objects = [[docModel objectsOfType:type] objectsAtIndexes:indexes];
//    
//    SWModelManager *manager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_docModel];
//    [manager removeModelConfiguratorForObjects:objects animated:YES];
//}


- (void)documentModelChangeCheckpoint:(SWDocumentModel *)docModel
{
    //[self _stopIntegratorTimer];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:SWDocumentCheckPointNotification object:nil userInfo:nil];
}


- (void)documentModelTitleDidChange:(SWDocumentModel *)docModel
{
    [self _updateControllerTitle];
}


- (void)documentModelInterfaceIdiomDidChange:(SWDocumentModel *)docModel
{
    [self _updateInterfaceIdiomAnimated:YES];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:SWDocumentControllerAllowedInterfaceIdiomOrientationNotification object:nil];
}


- (void)documentModelAllowedOrientationDidChange:(SWDocumentModel *)docModel
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:SWDocumentControllerAllowedInterfaceIdiomOrientationNotification object:nil];
}

- (void)documentModelPagesVisibilityDidChange:(SWDocumentModel *)docModel
{
    [self _setupPageNavigatorEnabled];
}

- (void)documentModelUsersAvailableDidChange:(SWDocumentModel *)docModel
{
    [self _setupUsersEnabled];
}



#pragma mark EventCenter

- (void)eventCenterDidChangeEvents:(SWEventCenter *)alarmCenter
{
    // Hem de fer algo aquí?
}

- (void)eventCenterWantsEventListDisplay:(SWEventCenter *)alarmCenter
{
    if ( self.rightViewPosition == SWRightViewPositionHidden )
        [self toggleRightDetailViewControllerAnimated:YES];
    
    [(SWInspectorViewController*)self.rightDetailViewController showEventsList];
}

@end


#pragma mark - CustomProtocols

@implementation SWDocumentController (CustomProtocols)

- (void)addObjectViewController:(SWAddObjectViewController *)controller didAddObject:(id)object
{
    [self _dismissAddPopoverAnimated:YES];
    //_addPopover = nil;
    
    if ( object && ![object isKindOfClass:[SWItem class]] && ![object isKindOfClass:[SWPage class]] )
    {
        SWModelManager *manager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_docModel];
        [manager presentModelConfiguratorOnControllerWithIdentifier:nil forObject:object animated:IS_IPHONE];
    }
}


- (void)toolsViewControllerDidChangeSelection:(SWToolsViewController*)toolsController
{
    if ( NO )    // <-- treure si cal
    {
        [_toolsPopover dismissPopoverAnimated:YES];
        _toolsPopover = nil;
    }
}

- (void)toolsViewControllerInterfaceIdiomDidChange:(SWToolsViewController *)toolsController
{
    [_toolsPopover dismissPopoverAnimated:YES];
    _toolsPopover = nil;
}

//#pragma mark SWFloatingPopoverDelegate

//- (void)floatingPopoverControllerDidDismissPopover:(SWFloatingPopoverController *)floatingPopoverController
//{
//        _modelBrowserPosition = floatingPopoverController.presentationPosition;
//}

@end

#pragma mark - UIProtocols

@implementation SWDocumentController (UIProtocols)

//#pragma mark UIAcitonSheet Delegate
//
//
//- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//    //NSInteger firstOtherButtonIndex = [actionSheet firstOtherButtonIndex];
//   // NSInteger destructiveButtonIndex = [actionSheet destructiveButtonIndex];
//    //    NSInteger cancelButtonIndex = [actionSheet cancelButtonIndex];
//    
//    switch (actionSheet.tag)
//    {            
////        case ActionSheetSettings:
////
////            if (buttonIndex == firstOtherButtonIndex) // Multiple Selection
////            {
////                _docModel.allowsMultipleSelection = !_docModel.allowsMultipleSelection;
////            }
////            else if (buttonIndex == firstOtherButtonIndex + 1) // AutoAlign
////            {
////                _docModel.autoAlignItems = !_docModel.autoAlignItems;
////            }
////            else if (buttonIndex == firstOtherButtonIndex + 2) // Frame Editing
////            {
////                _docModel.allowFrameEditing = !_docModel.allowFrameEditing;
////            }
////            break;
//
//        case ActionSheetTimer:
//            [self _resumeIntegratorTimer];
//            break;
//    
//        default:
//            break;
//    }
//    
////    _toolsActionSheet = nil;
//    _actionSheet = nil;
//}


//#pragma mark UIAlertView Delegate
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    NSInteger firstOtherButtonIndex = [alertView firstOtherButtonIndex];
//    NSInteger cancelButtonIndex = [alertView cancelButtonIndex];
//    
//    switch (alertView.tag)
//    {
//        case AlertViewUnsavedChanges:
//            if (buttonIndex == cancelButtonIndex)
//            {
//                // Nothing to do
//            }
//            else if (buttonIndex == firstOtherButtonIndex) // Save and quit
//            {
//
//            }
//            else if (buttonIndex == firstOtherButtonIndex + 1) // Quit anyway
//            {
//                [self.navigationController popViewControllerAnimated:YES];
//            }
//            break;
//            
//        default:
//            break;
//    }
//}

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIControl class]])
    {
        return NO;
    }
    
    if (self.editing && [touch.view isKindOfClass:NSClassFromString(@"SWLayoutOverlayViewCell")])
    {
        return NO;
    }
        
    return YES;
}

#pragma mark UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (popoverController == _addPopover)
    {        
        [self _storeAddPopoverState];
        _addPopover = nil;
    }
    else if (popoverController == _toolsPopover)
    {
        _toolsPopover = nil;
    }
}


//#pragma mark SWFloatingPopoverControllerDelegate
//
//- (void)floatingPopoverControllerDidDismissPopover:(SWFloatingPopoverController *)floatingPopoverController
//{
//   // _floating = nil;
//}












//- (void)_generateScreenShotForPageController:(SWPageController*)pageController
//{    
//    SWPage *originPage = pageController.page;
//    NSString *originUuid = originPage.uuid;
//    NSURL *screenshotsURLFolderURL = [self.docModel urlForDocumentCacheDirectory:SWDocumentCacheDirectoryScreenShots];
//    
//    UIView *view = pageController.view;
//    
////#warning Podem accedir de manera segura al view en un thread secundari ?
////#warning Resposta--> De fet dona problemes, a vegades, per això no s'està cridant aquest mètode. És un TODO pendent a resoldre.
//
//    dispatch_queue_t q_default = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(q_default, ^{
//        
//        UIImage *originalImage = nil;
//        
////        if (!view.superview) {
////            //NSLog(@"asdf");
////            //pageController.editing = NO;
////            CGRect frame = view.frame;  
////            view.frame = CGRectMake(0, 0, 1024, 704);
////            originalImage = [view screenShotWithScale:1.0];
////            view.frame = frame;
////        } else {
//            originalImage = [view screenShotWithScale:1.0];
////        }
//        
//        CGSize size = CGSizeMake(originalImage.size.width*0.5, originalImage.size.height*0.5);
//        UIImage *scaledImage = [originalImage scaleToSize:size];
//        
//        NSData *data = UIImagePNGRepresentation(scaledImage);
//        NSString *pageScreenShotName = [NSString stringWithFormat:@"%@.png", originUuid];
//        NSURL *url = [screenshotsURLFolderURL URLByAppendingPathComponent:pageScreenShotName];
//        
//        if(![data writeToURL:url atomically:YES]) {
//            //NSLog(@"[PAGE] Error saving screenshot to path: %@",url.path);
//        }
//        
//        dispatch_queue_t q_main = dispatch_get_main_queue();
//        dispatch_async(q_main, ^{
//            
//            //NSInteger pageIndex = [_docModel indexOfPageWithUUID:originUuid];
//
////            if (pageIndex != NSNotFound) {
////                [self.horizontalBarView reloadRowsAtIndexes:[NSIndexSet indexSetWithIndex:pageIndex] 
////                                           withRowAnimation:SWHorizontalTableViewRowAnimationNone];
////            }
//        });
//    });
//}


@end
