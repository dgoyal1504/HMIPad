//
//  SWPageController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/15/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SWPageController.h"
#import "SWPage.h"

#import "SWLayoutOverlayCoordinatorView.h"
#import "SWLayoutView.h"
#import "SWLayoutViewCell.h"
#import "SWGroupLayoutViewCell.h"

//#import "SWViewControllerNotifications.h"

#import "SWColor.h"

#import "SWItemController.h"
//#import "SWDocumentController.h"

#import "SWModelManager.h"
#import "SWExpressionInputController.h"

#import "SWDocumentModel.h"
//#import "SWConfigurationController.h"

//#import "CALayer+ScreenShot.h"
#import "SWKeyboardListener.h"

#import "SWImageManager.h"
#import "AppModel.h"
#import "AppModelImage.h"

#import "SWPasteboardTypes.h"
#import "SWAlertCenter.h"

#import "SWEnumTypes.h"

NSString * const SWPageControllerSelectionDidChangeNotification = @"SWPageControllerSelectionDidChangeNotification";
NSString * const SWPageControllerTitleChangeNotification = @"SWPageControllerTitleChangeNotification";
//NSString * const SWPageControllerInterfaceIdiomChangeNotification = @"SWPageControllerInterfaceIdiomChangeNotification";
NSString * const SWPageControllerThumbnailChangeNotification = @"SWPageControllerThumbnailChangeNotification";

#define PageThumbNailSize (CGSizeMake(88,60))
//#define PageThumbNailSize (CGSizeMake(200,100))
#define ThumbNailUpdateDelay 1.0

#pragma mark - Implemented Protocols

@interface SWPageController (ModelObservation) <PageObserver, ExpressionObserver, DocumentModelObserver>
@end

@interface SWPageController (CustomProtocols) <SWLayoutViewDataSource, SWLayoutViewDelegate>
@end

@interface SWPageController (UIProtocols) <UIPopoverControllerDelegate/*, UIGestureRecognizerDelegate*/>
@end


#pragma mark - Class Implementation

@interface SWPageController()
{
    UIImageView *_backgroundImageView;
    SWLayoutView *_layoutView;
    SWLayoutOverlayCoordinatorView *_layoutOverlayCoordinatorView;
}
@end


@implementation SWPageController
{
   // NSIndexSet *_selectedItemsWhileRotating;
    CGFloat _zoomScaleFactor;
    __weak NSTimer *_thumbnailTimer;
    __weak SWModelManager *_modelManager;
    //UIMenuController *_pageMenu;
    id<SWGroup> _menuTarget;
    BOOL _validLayer;
}


//@synthesize layoutView = _layoutView;
//@synthesize page = _page;
//@synthesize backgroundImageView = _backgroundImageView;
//@dynamic autoAlignItems;
//@dynamic allowsMultipleSelection;
//@dynamic allowFrameEditing;

+ (void)initialize
{
    UIMenuItem *configureItem = [[UIMenuItem alloc] initWithTitle:@"Configure" action:@selector(settings:)];
//    UIMenuItem *editItem = [[UIMenuItem alloc] initWithTitle:@"Edit Frame" action:@selector(editFrame:)];
    UIMenuItem *duplicateItem = [[UIMenuItem alloc] initWithTitle:@"Duplicate" action:@selector(duplicate:)];
    UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyToPasteboard:)];
    UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteAction:)];
    UIMenuItem *sendBack = [[UIMenuItem alloc] initWithTitle:@"SendBack" action:@selector(sendToBack:)];
    UIMenuItem *bringFront = [[UIMenuItem alloc] initWithTitle:@"BringFront" action:@selector(bringToFront:)];
    UIMenuItem *pasteItem = [[UIMenuItem alloc] initWithTitle:@"Paste" action:@selector(pasteFromPasteboard:)];
    UIMenuItem *groupItems = [[UIMenuItem alloc] initWithTitle:@"Group" action:@selector(groupItems:)];
    UIMenuItem *ungroupItems = [[UIMenuItem alloc] initWithTitle:@"Ungroup" action:@selector(ungroupItems:)];
    UIMenuItem *lockItems = [[UIMenuItem alloc] initWithTitle:@"Lock" action:@selector(lockItems:)];
    UIMenuItem *unlockItems = [[UIMenuItem alloc] initWithTitle:@"Unlock" action:@selector(unlockItems:)];
    
    NSArray *menuItems = @
    [
        configureItem, copyItem, pasteItem, duplicateItem, deleteItem,
        sendBack, bringFront, groupItems, ungroupItems,
        lockItems, unlockItems
    ];
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:menuItems];
}

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    return [self initWithPage:nil];
//}


//- (void)setupCustomMenu
//{
//
//    UIMenuItem *configureItem = [[UIMenuItem alloc] initWithTitle:@"Configure" action:@selector(settings:)];
////    UIMenuItem *editItem = [[UIMenuItem alloc] initWithTitle:@"Edit Frame" action:@selector(editFrame:)];
//    UIMenuItem *duplicateItem = [[UIMenuItem alloc] initWithTitle:@"Duplicate" action:@selector(duplicate:)];
//    UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyToPasteboard:)];
//    UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteAction:)];
//    UIMenuItem *sendBack = [[UIMenuItem alloc] initWithTitle:@"SendBack" action:@selector(sendToBack:)];
//    UIMenuItem *bringFront = [[UIMenuItem alloc] initWithTitle:@"BringFront" action:@selector(bringToFront:)];
//    UIMenuItem *pasteItem = [[UIMenuItem alloc] initWithTitle:@"Paste" action:@selector(pasteFromPasteboard:)];
//    
//    NSArray *menuItems = [NSArray arrayWithObjects:configureItem,/*editItem,*/copyItem,pasteItem,duplicateItem,deleteItem,sendBack,bringFront,nil];
//}




- (id)initWithPage:(SWPage*)page
{
//    self = [super initWithNibName:@"SWPageController" bundle:nil];
    self = [super init];
    if (self)
    {
        _page = page;
        _modelManager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_page.docModel];

        _lastItemSelected = NSNotFound;
        _zoomScaleFactor = 1.0f;
        
//        _itemControllers = [NSMutableArray array];
//    
//        // Loading Item Controllers
//        for (SWItem *item in _page.items)
//        {
//            Class ItemController = [item.class objectDescription].controllerClass;
//            SWItemController *itemController = [(SWItemController*)[ItemController alloc] initWithItem:item parentController:self];
//            [_itemControllers addObject:itemController];
//        }
        
        self.title = _page.title.valueAsString;
    }
    
    return self;
}

- (void)dealloc
{
    //NSLog(@"SWPageController dealloc");
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark View lifecycle


- (void)loadView
{
    CGRect rect = CGRectMake(0,0,100,100);
    
    // background
    
    _backgroundImageView = [[UIImageView alloc] initWithFrame:rect];
    [_backgroundImageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [_backgroundImageView setClipsToBounds:YES];
    
    // items
    
    _layoutView = [[SWLayoutView alloc] initWithFrame:rect];
    [_layoutView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    //[_layoutView setBackgroundImageEnabled:YES];
    //_layoutView.normalTouchesEnabled = YES;
    _layoutView.isBottomPosition = YES;
    _layoutView.delegate = self;
    _layoutView.dataSource = self;

    //self.view = _layoutView;
    
    // overlay coordinator
    
    _layoutOverlayCoordinatorView = [[SWLayoutOverlayCoordinatorView alloc] initWithFrame:rect];
    [_layoutOverlayCoordinatorView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    
    [_layoutView setLayoutOverlayCoordinatorView:_layoutOverlayCoordinatorView];
    [_layoutOverlayCoordinatorView addLayoutViewLayer:_layoutView];
    
    // self.view
    
    UIView *selfView = [[UIView alloc] initWithFrame:rect];
    
    [selfView addSubview:_backgroundImageView];
    [selfView addSubview:_layoutView];
    [selfView addSubview:_layoutOverlayCoordinatorView];
    
    [selfView setBackgroundColor:[UIColor colorWithWhite:0.6 alpha:1.0]];
    
    self.view = selfView;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _layoutView.backgroundColor = [UIColor clearColor];

    //[_layoutView reloadData];
    //_layoutView.editMode = self.editing;

//    [_layoutView.layer setMasksToBounds:YES];
//    [_backgroundImageView.layer setMasksToBounds:YES];
    
    [_layoutView setClipsToBounds:YES];
    //[_backgroundImageView setClipsToBounds:YES];
}

- (void)viewDidUnload
{
    //[self setLayoutView:nil];
    _layoutView = nil;
    //[self setBackgroundImageView:nil];
    [super viewDidUnload];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _itemControllers = [NSMutableArray array];
    
    // Loading Item Controllers
    for (SWItem *item in _page.items)
    {
        Class ItemController = [item.class objectDescription].controllerClass;
        SWItemController *itemController = [(SWItemController*)[ItemController alloc] initWithItem:item parentController:self];
        [_itemControllers addObject:itemController];
    }
    
    [_layoutView reloadDataAnimated:animated];   // carregara el
    
    [self _updateLayoutEditing];  // HHH
    [self _updateInterfaceIdiom];  // HHH
    [self _setupBackgroundImageFrameAnimated:NO];
    
//    [_page addPageObserver:self];
    [_page addObjectObserver:self];
    
    [_page.backgroundColor addObserver:self];
    [_page.backgroundImage addObserver:self];
    [_page.backgroundImageAspectRatio addObserver:self];
    [_page.enabledInterfaceIdiom addObserver:self];
    [_page.title addObserver:self];
    
    [_page.docModel addObserver:self];
    
    [self _updateViewFromExpressions];
    [self _setupEditingProperties];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(_textFieldDidBeginEditingNotification:) 
                                                 name:UITextFieldTextDidBeginEditingNotification 
                                               object:nil];
                                               
    [nc addObserver:self selector:@selector(_textFieldDidEndEditingNotification:) 
                                                 name:UITextFieldTextDidEndEditingNotification 
                                               object:nil];
                                               
    [nc addObserver:self selector:@selector(_keyboardWillMoveNotification:) 
                                                 name:SWKeyboardWillShowNotification 
                                               object:nil];
    
    [nc addObserver:self selector:@selector(_keyboardWillMoveNotification:) 
                                                 name:SWKeyboardWillHideNotification 
                                               object:nil];
    
    [nc addObserver:self selector:@selector(_menuControllerNotificationReceived:)
                             name:UIMenuControllerWillHideMenuNotification 
                         object:nil];
    
    [nc addObserver:self selector:@selector(_menuControllerNotificationReceived:)
                             name:UIMenuControllerMenuFrameDidChangeNotification
                         object:nil];
    
    for (SWItemController *itemController in _itemControllers)
    {
        [itemController viewWillAppear:animated];
    }
    
}


- (void)viewDidAppear:(BOOL)animated 
{    
    [super viewDidAppear:animated];
    
    for (SWItemController *itemController in _itemControllers)
        [itemController viewDidAppear:animated];
    
    _validLayer = YES;
    [self _updatePageThumbnail];
//    [UIView animateWithDuration:0.3 animations:^
//    {
//        self.view.alpha = 1.0f;
//    }];
}


- (void)viewWillDisappear:(BOOL)animated 
{
    [super viewWillDisappear:animated];

    for (SWItemController *itemController in _itemControllers)
        [itemController viewWillDisappear:animated];
    
    //[_page removePageObserver:self];
    [_page removeObjectObserver:self];
    
    [_page.backgroundColor removeObserver:self];
    [_page.backgroundImage removeObserver:self];
    [_page.backgroundImageAspectRatio removeObserver:self];
    [_page.enabledInterfaceIdiom removeObserver:self];
    [_page.title removeObserver:self];
    
    [_page.docModel removeObserver:self];
        
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
    [nc removeObserver:self];
    
    _validLayer = NO;
    
    [_thumbnailTimer invalidate];
    _thumbnailTimer = nil;
}

- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
    [nc removeObserver:self]; // <- no hauria de caldre pero no esta de mes
    
    for (SWItemController *itemController in _itemControllers)
        [itemController viewDidDisappear:animated];
    
    _itemControllers = nil;
}




//- (void)setScaledFrame:(CGRect)scaledRect originalSize:(CGSize)originalSize
//{
////    NSLog( @"ScaledFrame: %@", NSStringFromCGRect(scaledRect));
////    NSLog( @"OriginalFrameB: %@", NSStringFromCGRect(originalRect));
//    
//    
//    UIView *view = self.view;
////    CGRect bounds = view.bounds;
////    NSLog( @"FrameB : %@", NSStringFromCGRect(view.frame));
////    NSLog( @"BoundsB: %@", NSStringFromCGRect(view.bounds));
//
//    CGFloat scaleX = scaledRect.size.width / originalSize.width;
//    CGFloat scaleY = scaledRect.size.height / originalSize.height;
//    
//    CGPoint position;
//    position.x = scaledRect.origin.x + scaledRect.size.width/2;
//    position.y = scaledRect.origin.y + scaledRect.size.height/2;
//    
//    CALayer *layer = view.layer;
//    CATransform3D scaleTransform = CATransform3DMakeScale(scaleX, scaleY, 1.0f);
//    [layer setTransform:scaleTransform];
//    [layer setPosition:position];
//    
////    NSLog( @"FrameE : %@", NSStringFromCGRect(view.frame));
////    NSLog( @"BoundsE: %@", NSStringFromCGRect(view.bounds));
//}


#pragma mark Background image Layout


- (void)_setupBackgroundImageFrameAnimated:(BOOL)animated
{
    CGRect bounds = self.view.bounds;
    CGRect backgroundFrame = bounds;
    
    CGFloat phoneRulerPosition = _layoutView.phoneIdiomRulerSize.width;
    if ( _layoutView.constrainToRulerPosition && phoneRulerPosition > 0 )
        backgroundFrame.size.width = phoneRulerPosition;

    void (^block)(void) = ^()
    {
        [_backgroundImageView setFrame:backgroundFrame];
    };

    if ( animated ) [UIView animateWithDuration:0.25 animations:block];
    else block();
}


- (void)viewDidLayoutSubviews
{
    [self _setupBackgroundImageFrameAnimated:NO];
}



#pragma mark Public Methods

- (void)invalidateLayer
{
    _validLayer = NO;
}

- (void)moveToDirection:(SWLayoutResizerViewDirection)direction
{
    [_layoutOverlayCoordinatorView moveToDirection:direction];
}

- (void)resizeToDirection:(SWLayoutResizerViewDirection)direction
{
    [_layoutOverlayCoordinatorView resizeToDirection:direction];
}


#pragma mark Overriden Methods

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{

//    NSIndexSet *selectedItems = [_page selectedItemIndexes];
//    [_page deselectItemsAtIndexes:selectedItems];
//    _selectedItemsWhileRotating = selectedItems;

    for ( SWItemController *itemController in _itemControllers )
    {
        [itemController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
    
    NSString *imageName = [_page.backgroundImage valueAsStringWithFormat:nil];
    
    [filesModel().amImage getOriginalImageWithName:imageName inDocumentName:_page.redeemedName completionBlock:^(UIImage *image)
    {
        _backgroundImageView.image = image;
        //[_layoutView setBackgroundImage:image];
    }];
    
    //[_layoutView setSelectionHidden:YES];
    [_layoutOverlayCoordinatorView setSelectionHidden:YES];

}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self _updateInterfaceIdiom];
    for ( SWItemController *itemController in _itemControllers )
    {
        [itemController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
    
    [_layoutView reloadCellFramesAnimated:NO];  // animated:NO perque ja estem a dins de un block d'animacio
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    for (SWItemController *itemController in _itemControllers)
    {
        [itemController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }
    
    //[self _updateInterfaceIdiomRuler];
    [self _updateBackgroundImage];
//    [_page selectItemsAtIndexes:_selectedItemsWhileRotating];
//    _selectedItemsWhileRotating = nil;

    [_layoutView reloadOverlayFrames];
//    [_layoutView setSelectionHidden:NO];
    [_layoutOverlayCoordinatorView setSelectionHidden:NO];
    
    [self _updatePageThumbnail];
}


#pragma mark Menu Display



- (void)displayMenuInRect:(CGRect)rect target:(id<SWGroup>)target
{
    _touchInPage = NO;
    _menuTarget = target;
    [self _displayMenuInRect:rect];
}


- (void)_displayMenuInRect:(CGRect)rect
{
    [_modelManager.inputController resignResponder];
    [self becomeFirstResponder];
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:rect inView:self.view];
    [menu setArrowDirection:UIMenuControllerArrowDefault];
    [menu setMenuVisible:YES animated:YES];
    [self _performDelayedHideMenu];
}


- (void)_performDelayedHideMenu
{
    [NSThread cancelPreviousPerformRequestsWithTarget:self selector:@selector(_delayedHideMenu) object:nil];
    [self performSelector:@selector(_delayedHideMenu) withObject:nil afterDelay:4.0];
}

- (void)_delayedHideMenu
{
    _menuTarget = nil;
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuVisible:NO animated:YES];

}


#pragma mark UIResponder overrides

- (BOOL)canBecomeFirstResponder
{
    return YES;
}


- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (![self isFirstResponder])
        return NO;
    
    if ( _menuTarget == _page )
    {
        if ( _touchInPage ) return [self _canPerformPageAction:(SEL)action];
        else return [self _canPerformPageItemAction:(SEL)action];
    }
    return [self _canPerformGroupItemAction:(SEL)action];
}


- (BOOL)_canPerformGroupItemAction:(SEL)action
{
    NSIndexSet *selectedIndexes = [_menuTarget selectedItemIndexes];
    NSInteger selectedCount = selectedIndexes.count;
        
    if (selectedCount == 1)
    {
        if (action == @selector(settings:))
        {
            return YES;
        }
    }
    
    if (selectedCount > 0)
    {
        if (action == @selector(copyToPasteboard:))
        {
            return YES;
        }
        
        if ( _layoutOverlayCoordinatorView.allowFrameEditing )
        {
            if ( action == @selector(lockItems:) )
            {
                __block BOOL foundOne = NO;
                NSArray *items = _menuTarget.items;
                [selectedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
                {
                    SWItem *item = [items objectAtIndex:idx];
                    if ( !item.locked ) foundOne = YES, *stop = YES;
                }];
            
                return foundOne;
            }
            
            if ( action == @selector(unlockItems:) )
            {
                __block BOOL foundOne = NO;
                NSArray *items = _menuTarget.items;
                [selectedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
                {
                    SWItem *item = [items objectAtIndex:idx];
                    if ( item.locked ) foundOne = YES, *stop = YES;
                }];
                
                return foundOne;
            }
        }
    }
    return NO;
}


- (BOOL)_canPerformPageAction:(SEL)action
{
    if (action == @selector(settings:) ||
        action == @selector(deleteAction:) ||
        action == @selector(duplicate:) ||
        action == @selector(copyToPasteboard:))
            return YES;
        
    if (action == @selector(pasteFromPasteboard:))
        if ([[UIPasteboard applicationPasteboard] containsPasteboardTypes:[NSArray arrayWithObject:kPasteboardTypeItemList]])
            return YES;
    
    return NO;
}


- (BOOL)_canPerformPageItemAction:(SEL)action
{
    if ( [self _canPerformGroupItemAction:action] )
        return YES;
    
    NSIndexSet *selectedIndexes = [_menuTarget selectedItemIndexes];
    NSInteger selectedCount = selectedIndexes.count;
        
    if (selectedCount == 1)
    {
        NSInteger selectedIndex = selectedIndexes.firstIndex;
            
        NSInteger itemsCount = [_menuTarget.items count];
        if ( itemsCount > 1 )
        {
            if (action == @selector(sendToBack:))
                return selectedIndex > 0;
            
            if (action == @selector(bringToFront:) )
                return selectedIndex < itemsCount-1;
        }

        if ( action == @selector(ungroupItems:))
        {
            SWItem *groupItem = [_menuTarget.items objectAtIndex:selectedIndex];
            return [groupItem isGroupItem];
        }
    }
        
    if (selectedCount > 0)
    {
        if (action == @selector(duplicate:) ||
            action == @selector(deleteAction:))
        {
            return YES;
        }
    }
        
    if (selectedCount > 1)
    {
        if ( action == @selector(groupItems:))
        {
            return YES;
        }
    }
    
    return NO;
}


- (BOOL)_canPerformPageActionV:(SEL)action
{
    if (![self isFirstResponder])
        return NO;
    
    if (_touchInPage)
    {
        if (action == @selector(settings:) ||
            action == @selector(deleteAction:) ||
            action == @selector(duplicate:) ||
            action == @selector(copyToPasteboard:))
            return YES;
        
        if (action == @selector(pasteFromPasteboard:))
            if ([[UIPasteboard applicationPasteboard] containsPasteboardTypes:[NSArray arrayWithObject:kPasteboardTypeItemList]])
                return YES;
    }
    
    else
    {
        //NSIndexSet *selectedIndexes = [_layoutView selectedCellsIndexes];
        NSIndexSet *selectedIndexes = [_menuTarget selectedItemIndexes];
        NSInteger selectedCount = selectedIndexes.count;
        
        if (selectedCount == 1)
        {
            NSInteger selectedIndex = selectedIndexes.firstIndex;
            
            NSInteger itemsCount = [_menuTarget.items count];
            if ( itemsCount > 1 )
            {
                if (action == @selector(sendToBack:))
                    return selectedIndex > 0;
            
                if (action == @selector(bringToFront:) )
                    return selectedIndex < itemsCount-1;
            }
            
//            if (_itemControllers.count > 1 )
//            {
//                if (action == @selector(sendToBack:))
//                    return selectedIndex > 0;
//            
//                if (action == @selector(bringToFront:) )
//                    return selectedIndex < _itemControllers.count-1;
//            }
            
            if ( action == @selector(ungroupItems:))
            {
                SWItem *groupItem = [_menuTarget.items objectAtIndex:selectedIndex];
                return [groupItem isGroupItem];
            }
            
            if (action == @selector(settings:))
            {
                return YES;
            }
            
        }
        
        if (selectedCount > 0)
        {
            if (action == @selector(copyToPasteboard:) ||
                action == @selector(duplicate:) ||
                action == @selector(deleteAction:))
            {
                return YES;
            }
            
            //if ( _layoutView.allowFrameEditing )
            //if ( _layoutOverlayCoordinatorView.allowFrameEditing )
            if ( _page.docModel.allowFrameEditing )
            {
                if ( action == @selector(lockItems:) )
                {
                    __block BOOL foundOne = NO;
                    NSArray *items = _menuTarget.items;
                    [selectedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
                    {
                        SWItem *item = [items objectAtIndex:idx];
                        if ( !item.locked ) foundOne = YES, *stop = YES;
                    }];
                
                    return foundOne;
                }
            
                if ( action == @selector(unlockItems:) )
                {
                    __block BOOL foundOne = NO;
                    NSArray *items = _menuTarget.items;
                    [selectedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
                    {
                        SWItem *item = [items objectAtIndex:idx];
                        if ( item.locked ) foundOne = YES, *stop = YES;
                    }];
                
                    return foundOne;
                }
            }
        }
        
        if (selectedCount > 1)
        {
            if ( action == @selector(groupItems:))
            {
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark UIMenuController Methods

- (void)copyToPasteboard:(id)sender
{
    if (_touchInPage)
    {
        NSData *data = [SymbolicArchiver archivedDataWithArrayOfObjects:@[_menuTarget]
                forKey:kSymbolicCodingCollectionKey
                version:SWVersion];
        
        UIPasteboard *pasteboard = [UIPasteboard applicationPasteboard];
        [pasteboard setData:data forPasteboardType:kPasteboardPageListType];
    }
    else
    {
        //NSArray *itemsToCopy = [_menuTarget.items objectsAtIndexes:[_layoutView selectedCellsIndexes]];
        
        NSIndexSet *selectedIndexes = [_menuTarget selectedItemIndexes];
        NSArray *itemsToCopy = [_menuTarget.items objectsAtIndexes:selectedIndexes];
                                                              
        NSData *data = [SymbolicArchiver archivedDataWithArrayOfObjects:itemsToCopy
                                                               forKey:kSymbolicCodingCollectionKey
                                                              version:SWVersion];
        
        UIPasteboard *pasteboard = [UIPasteboard applicationPasteboard];
        [pasteboard setData:data forPasteboardType:kPasteboardTypeItemList];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPasteboardContentDidChangeNotification object:nil userInfo:nil];
}


- (void)pasteFromPasteboard:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard applicationPasteboard];
    NSData *data = [pasteboard dataForPasteboardType:kPasteboardTypeItemList];
    
    NSError *error = nil;
    NSArray *items = [SymbolicUnarchiver unarchivedObjectsWithData:data
                                                            forKey:kSymbolicCodingCollectionKey
                                                           builder:_page.builder
                                                       parentObject:_page
                                                            version:SWVersion
                                                            outError:&error];
                                                            
    if ( items == nil )
    {
        // Presentar un error aqui no es lo mes elegant, pero mes val aixo que res !
        //NSString *errorStr = [error localizedDescription];
        NSString *errorStr = NSLocalizedString( @"PasteErrorDescription", nil );
        NSString *title = NSLocalizedString( @"PasteError", nil );
        [[SWAlertCenter defaultCenter] postAlertWithMessage:errorStr title:title];
        return;
    }
    
    CGPoint offset;
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    SWDeviceInterfaceIdiom idiom = _page.docModel.interfaceIdiom;
     
    NSInteger count = items.count;
    for (NSInteger i=0; i<count; ++i)
    {
        SWItem *item = [items objectAtIndex:i];
        
        CGRect frame = [item frameForOrientation:orientation idiom:idiom];
        
        if (i==0)
        {
            CGPoint origin = frame.origin;
            frame.origin.x = roundf(_longPressurePoint.x - frame.size.width/2.0f);
            frame.origin.y = roundf(_longPressurePoint.y - frame.size.height/2.0f);
            offset.x = frame.origin.x - origin.x;
            offset.y = frame.origin.y - origin.y;
        }
        else
        {
            frame.origin.x += offset.x;
            frame.origin.y += offset.y;
        }
        
        //[item addPasteOffsetToAllFrames];
        [item itemFramesAddOffset:CGPointMake(10,10)];
        [item setFrame:frame withOrientation:orientation idiom:idiom];
        
//        [item setAllFramesToFrame:frame];
    }
    
    [_page insertItems:items atIndexes:nil];
}

- (void)duplicate:(id)sender
{
    if (_touchInPage)
    {
        SWDocumentModel *docModel = _page.docModel;
        NSData *data = [SymbolicArchiver archivedDataWithArrayOfObjects:@[_page]
                                                               forKey:kSymbolicCodingCollectionKey
                                                              version:SWVersion];
                                                                    
        NSError *error = nil;
        NSArray *items = [SymbolicUnarchiver unarchivedObjectsWithData:data
                                                            forKey:kSymbolicCodingCollectionKey
                                                           builder:_page.builder
                                                       parentObject:docModel
                                                            version:SWVersion
                                                            outError:&error];
        
        if ( items == nil )
        {
            // Presentar un error aqui no es lo mes elegant, pero mes val aixo que res !
            //NSString *errorStr = [error localizedDescription];
            NSString *errorStr = NSLocalizedString( @"DuplicateErrorDescription", nil );
            NSString *title = NSLocalizedString( @"DuplicateError", nil );
            [[SWAlertCenter defaultCenter] postAlertWithMessage:errorStr title:title];
            return;
        }
        
        SWPage *page = [items objectAtIndex:0];
        
        
        NSInteger insertionIndex = [docModel.pages indexOfObjectIdenticalTo:_page] + 1;
        
        [docModel insertPages:[NSArray arrayWithObject:page] atIndexes:[NSIndexSet indexSetWithIndex:insertionIndex]];
        //[docModel selectPageAtIndex:insertionIndex];
    }
    else
    {
    
        //NSArray *itemsToCopy = [_page.items objectsAtIndexes:[_layoutView selectedCellsIndexes]];
        
        NSIndexSet *selectedIndexes = [_menuTarget selectedItemIndexes];
        NSArray *itemsToCopy = [_menuTarget.items objectsAtIndexes:selectedIndexes];
        
        NSData *data = [SymbolicArchiver archivedDataWithArrayOfObjects:itemsToCopy
                                                               forKey:kSymbolicCodingCollectionKey
                                                              version:SWVersion];
                                                                    
        NSError *error = nil;
        NSArray *items = [SymbolicUnarchiver unarchivedObjectsWithData:data
                                                            forKey:kSymbolicCodingCollectionKey
                                                           builder:_page.builder
                                                       parentObject:_page
                                                            version:SWVersion
                                                            outError:&error];
        

        if ( items == nil )
        {
            // Presentar un error aqui no es lo mes elegant, pero mes val aixo que res !
            //NSString *errorStr = [error localizedDescription];
            NSString *errorStr = NSLocalizedString( @"DuplicateErrorDescription", nil );
            NSString *title = NSLocalizedString( @"DuplicateError", nil );
            [[SWAlertCenter defaultCenter] postAlertWithMessage:errorStr title:title];
            return;
        }

    
        for (SWItem *item in items)
        {
//            CGRect frame = [item frameForOrientation:self.interfaceOrientation idiom:_page.docModel.interfaceIdiom];
//            frame.origin.x += 10;
//            frame.origin.y += 10;
//            [item setAllFramesToFrame:frame];
            
            [item itemFramesAddOffset:CGPointMake(10,10)];
        }
        
        [_page insertItems:items atIndexes:nil];
    }
}


- (void)deleteAction:(id)sender
{
    if (_touchInPage)
    {
        SWDocumentModel *docModel = _page.docModel;
        NSInteger index = [docModel.pages indexOfObjectIdenticalTo:_page];
        [docModel removePagesAtIndexes:[NSIndexSet indexSetWithIndex:index]];
    }
    else
    {
        //[_page removeItemsAtIndexes:[self selectedItemIndexes]];
        NSIndexSet *indexSet = [_page selectedItemIndexes];
        [_page removeItemsAtIndexes:indexSet];
    }
}

//- (void)editFrame:(id)sender
//{
//    SWLayoutViewCell *selectedCell = [_layoutView cellAtIndex:_lastItemSelected];
//    BOOL willEdit = !selectedCell.editing;
//    
//    NSIndexSet *indexes = [self selectedItemIndexes];
//    
//    // Avisem els controladors de l'estat d'edició de les seves vistes
//    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
//        SWItemController *ic = [_itemControllers objectAtIndex:idx];
//        ic.frameEditing = willEdit;
//    }];
//}

- (void)sendToBack:(id)sender
{
    NSIndexSet *selectedIndexSet = [_page selectedItemIndexes];
    [selectedIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        [_page sendToBackItemAtIndex:idx];
    }];
}

- (void)bringToFront:(id)sender
{
    NSIndexSet *selectedIndexSet = [_page selectedItemIndexes];
    [selectedIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        [_page bringToFrontItemAtIndex:idx];
    }];
}

- (void)settings:(id)sender
{    
    if (_touchInPage)
    {
        [_modelManager presentModelConfiguratorOnControllerWithIdentifier:nil forObject:_page animated:IS_IPHONE];
        return;
    }
    
    NSIndexSet *selectedIndexSet = [_menuTarget selectedItemIndexes];
    NSInteger cellIndex = selectedIndexSet.firstIndex;
    
    if (cellIndex == NSNotFound)
        return;
    
    SWItem *item = [_menuTarget.items objectAtIndex:cellIndex];
    
    [_modelManager presentModelConfiguratorOnControllerWithIdentifier:nil forObject:item animated:IS_IPHONE];
}

- (void)groupItems:(id)sender
{
    NSIndexSet *selectedIndexSet = [_page selectedItemIndexes];
    [_page insertNewGroupItemForItemsAtIndexes:selectedIndexSet];
}


- (void)ungroupItems:(id)sender
{
    NSIndexSet *selectedIndexSet = [_page selectedItemIndexes]; 
    NSInteger cellIndex = selectedIndexSet.firstIndex;
    
    if (cellIndex == NSNotFound)
        return;
    
    [_page removeGroupItemAtIndex:cellIndex];
}

- (void)lockItems:(id)sender
{
    NSIndexSet *selectedIndexSet = [_menuTarget selectedItemIndexes];
    [_menuTarget lockItemsAtIndexes:selectedIndexSet];
}

- (void)unlockItems:(id)sender
{
    NSIndexSet *selectedIndexSet = [_menuTarget selectedItemIndexes];
    [_menuTarget unlockItemsAtIndexes:selectedIndexSet];
}



#pragma mark Private Methods

- (void)_updateBackgroundColor
{
    _backgroundImageView.backgroundColor = _page.backgroundColor.valueAsColor;
}

//- (NSString*)_backgroundImagePath
//{
//    NSString *imageName = [_page.backgroundImage valueAsStringWithFormat:nil];
//    NSString *imagePath = nil;
//    if (imageName != nil && ![imageName isEqualToString:@""])
//        imagePath = [model() fileFullPathForFileName:imageName forCategory:kFileCategoryAssetFile];
//    
//    return imagePath;
//}

//- (void)_updateBackgroundImage
//{
//    NSString *imagePath = [self _backgroundImagePath];
//    
//    if (imagePath)
//    {
//        UIViewContentMode contentMode = UIViewContentModeFromSWImageAspectRatio(_page.backgroundImageAspectRatio.valueAsInteger);
//        SWImageDescriptor *descriptor = [[SWImageDescriptor alloc] initWithPath:imagePath size:self.backgroundImageView.frame.size contentMode:contentMode];
//        
//        [[SWImageManager defaultContext] getImageWithDescription:descriptor completionBlock:^(UIImage *image) {
//            self.backgroundImageView.image = image;
//        }];
//    }
//    else
//    {
//        self.backgroundImageView.image = nil;
//    }
//}


- (void)_updateBackgroundImage
{
    NSString *imageName = [_page.backgroundImage valueAsStringWithFormat:nil];
    //UIImageView *backImageView = _backgroundImageView;
    if ( imageName.length > 0 )
    {
        UIViewContentMode contentMode = UIViewContentModeFromSWImageAspectRatio(_page.backgroundImageAspectRatio.valueAsInteger);
        //CGSize size = backImageView.bounds.size;
        UIImageView *backImageView = _backgroundImageView;
        CGSize size = _layoutView.bounds.size;
        
        // evitem especificar contentScale per evitar memory pressure
        [filesModel().amImage getImageWithName:imageName inDocumentName:_page.redeemedName size:size contentMode:contentMode completionBlock:^(UIImage *image)
        {
            backImageView.image = image;
            //[_layoutView setBackgroundImage:image];
        }];
    }
    else
    {
        _backgroundImageView.image = nil;
        //[_layoutView setBackgroundImage:nil];
    }
}


- (void)_updateBackgroundAspectRatio
{    
    UIViewContentMode contentMode = UIViewContentModeFromSWImageAspectRatio(_page.backgroundImageAspectRatio.valueAsInteger);
    _backgroundImageView.contentMode = contentMode;
    //[_layoutView setBackgroundContentMode:contentMode];
}

- (void)_updateViewFromExpressions
{
    [self _updateBackgroundColor];
    [self _updateBackgroundImage];
    [self _updateBackgroundAspectRatio];
}


- (void)_setupEditingProperties
{
    SWDocumentModel *docModel = _page.docModel;
    
//    _layoutView.allowFrameEditing = docModel.allowFrameEditing;
//    _layoutView.autoAlignCells = docModel.autoAlignItems;
//    _layoutView.showAlignmentRulers = docModel.autoAlignItems;
//    _layoutView.allowsMultipleSelection = docModel.allowsMultipleSelection;
    _layoutView.showsErrorFramesInEditMode = docModel.showsErrorFrameInEditMode;
    _layoutView.showsHiddenItemsInEditMode = docModel.showsHiddenItemsInEditMode;
        
    _layoutOverlayCoordinatorView.autoAlignCells = docModel.autoAlignItems;
    _layoutOverlayCoordinatorView.showAlignmentRulers = docModel.autoAlignItems;
    
    _layoutOverlayCoordinatorView.allowFrameEditing = docModel.allowFrameEditing;
    _layoutOverlayCoordinatorView.allowsMultipleSelection = docModel.allowsMultipleSelection;
    
    
}


- (void)_updateInterfaceIdiomV
{
    CGSize phoneRulerSize = CGSizeZero;

    SWDocumentModel *docModel = _page.docModel;
    BOOL editMode = docModel.editMode;
    
    SWDeviceInterfaceIdiom deviceIdiom = docModel.interfaceIdiom;

    if ( editMode )
    {
        if ( deviceIdiom == SWDeviceInterfaceIdiomPhone )
        {
            UIInterfaceOrientation orientation = self.interfaceOrientation;
            if ( UIInterfaceOrientationIsLandscape(orientation) )
                phoneRulerSize = [_page defaultSizeLandscapeWithDeviceIdiom:SWDeviceInterfaceIdiomPhone];
            else
                phoneRulerSize = [_page defaultSizePortraitWithDeviceIdiom:SWDeviceInterfaceIdiomPhone];
        }
    }
    
    [_layoutView setPhoneIdiomRulerSize:phoneRulerSize];
    [_layoutView setConstrainToRulerPosition:(deviceIdiom == SWDeviceInterfaceIdiomPhone)];
}


- (void)_updateInterfaceIdiom
{
    CGSize phoneRulerSize = CGSizeZero;

    SWDocumentModel *docModel = _page.docModel;
    BOOL editMode = docModel.editMode;
    
    SWDeviceInterfaceIdiom deviceIdiom = docModel.interfaceIdiom;

    if ( editMode )
    {
        if ( deviceIdiom == SWDeviceInterfaceIdiomPhone )
        {
            CGFloat widthLandscape = [_page defaultSizeLandscapeWithDeviceIdiom:SWDeviceInterfaceIdiomPhone].width;
            CGFloat widthPortrait = [_page defaultSizePortraitWithDeviceIdiom:SWDeviceInterfaceIdiomPhone].width;
            
            UIInterfaceOrientation orientation = self.interfaceOrientation;
            if ( UIInterfaceOrientationIsLandscape(orientation) )
            {
                phoneRulerSize.width = widthLandscape;
                phoneRulerSize.height = widthPortrait-(20+32);
            }
            else
            {
                phoneRulerSize.width = widthPortrait;
                phoneRulerSize.height = widthLandscape-(20+44);
            }
        }
    }
    
    [_layoutView setPhoneIdiomRulerSize:phoneRulerSize];
    [_layoutView setConstrainToRulerPosition:(deviceIdiom == SWDeviceInterfaceIdiomPhone)];
}


- (void)_updateLayoutEditing
{
    SWDocumentModel *docModel = _page.docModel;
    BOOL editMode = docModel.editMode;
    [_layoutOverlayCoordinatorView setEditMode:editMode];
    [_layoutView setEditMode:editMode];
}

//- (void)_adjustLayoutViewForKeyboardIfNeeded_NOMES_LAYOUT_VIEW
//{
//    SWKeyboardListener *keyb = [SWKeyboardListener sharedInstance] ;
//    CGFloat keybOffset = [keyb offset] ;
//    
//    CGFloat offset = 0 ;
//    CGRect layoutViewFrame = _layoutView.frame ;
//    
//    if ( _pullUpView && keybOffset ) // !CGRectEqualToRect(keybframe, CGRectZero) )
//    {
//        CGRect fieldFrame =  [_pullUpView convertRect:_pullUpView.bounds toView:_layoutView] ;
//        CGFloat fieldPosition = fieldFrame.origin.y + fieldFrame.size.height ;
//        
//        const int OffsetMargin = 30 ;
//        offset = (layoutViewFrame.size.height - keybOffset) - fieldPosition - OffsetMargin ;
//    }
//    
//    if ( offset > 0 ) offset = 0 ;
//    if ( offset != layoutViewFrame.origin.y ) // no fem mes animacions de les necesaries
//    {
//        if (offset == 0 || layoutViewFrame.origin.y>offset) // nomes fem el canvi si ha de tirar mes amunt
//        {
//            layoutViewFrame.origin.y = offset ;
//            [UIView animateWithDuration:0.25 animations:^
//            {
//                _layoutView.frame = layoutViewFrame;
//            }];
//        }
//    }
//}


- (void)_adjustLayoutViewForKeyboardIfNeeded
{
    SWKeyboardListener *keyb = [SWKeyboardListener sharedInstance] ;
    CGFloat keybOffset = [keyb offset] ;
    
    UIView *selfView = self.view;
    
    CGFloat offset = 0 ;
    CGRect layoutViewFrame = selfView.frame ;
    
    if ( _pullUpView && keybOffset ) // !CGRectEqualToRect(keybframe, CGRectZero) )
    {
        CGRect fieldFrame =  [_pullUpView convertRect:_pullUpView.bounds toView:selfView] ;
        CGFloat fieldPosition = fieldFrame.origin.y + fieldFrame.size.height ;
        
        const int OffsetMargin = 30 ;
        offset = (layoutViewFrame.size.height - keybOffset) - fieldPosition - OffsetMargin ;
    }
    
    if ( offset > 0 ) offset = 0 ;
    if ( offset != layoutViewFrame.origin.y ) // no fem mes animacions de les necesaries
    {
        if (offset == 0 || layoutViewFrame.origin.y>offset) // nomes fem el canvi si ha de tirar mes amunt o offet es zero
        {
            layoutViewFrame.origin.y = offset ;
            [UIView animateWithDuration:0.25 animations:^
            {
                selfView.frame = layoutViewFrame;
            }];
        }
    }
}

#pragma mark TextField Notifications

- (void)_textFieldDidBeginEditingNotification:(NSNotification*)notification
{
    //_editingField = nil ;
    UIView *field = [notification object] ;
    if ( [field isDescendantOfView:_layoutView] ) 
    {
        _pullUpView = field ;
        
        // contemplem el cas de un TextField parcialment ocult darrera del teclat ja present
        [self _adjustLayoutViewForKeyboardIfNeeded] ;      
    }
}

- (void)_textFieldDidEndEditingNotification:(NSNotification*)notification
{
    UIView *field = [notification object] ;
    if ( [field isDescendantOfView:_layoutView] ) 
    {
        _pullUpView = nil ;
    }
}


#pragma mark Keyboard Notifications

- (void)_keyboardWillMoveNotification:(NSNotification*)notification
{
    [self _adjustLayoutViewForKeyboardIfNeeded];
}

#pragma mark Menu Controller Notifications

- (void)_menuControllerNotificationReceived:(NSNotification*)notification
{
    if ( [notification.name isEqualToString:UIMenuControllerMenuFrameDidChangeNotification] )
    {
        [self _performDelayedHideMenu];
    }
}




#pragma mark thubmnails

- (void)_generatePageThumbnail
{    
    SWPage *page = _page;
    NSString *uuid = page.uuid;
    UIView *view = self.view;
    
    SWImageManager *imageManager = [SWImageManager defaultManager];

    [imageManager makeThumbnailImageFromView:view uuid:uuid size:PageThumbNailSize radius:5
    contentMode:UIViewContentModeScaleAspectFit options:SWImageManagerProcessingOptionsPriorityImage
    cancelBlock:^BOOL
    {
        return ! (_validLayer && self.view.alpha == 1.0f);
    }
    completionBlock:^(UIImage *image)
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:SWPageControllerThumbnailChangeNotification object:page userInfo:@{@1:image}];
    }];
    
    SWDocumentModel *docModel = _page.docModel;
    NSArray *pages = docModel.pages;
    
    SWPage *firstPage = nil;
    if ( pages.count > 0 )
        firstPage = [pages objectAtIndex:0];
    
    if ( _page == firstPage )
    {
        [imageManager makeThumbnailImageFromView:view uuid:docModel.uuid size:DocumentThumbnailSize radius:5
        contentMode:UIViewContentModeScaleAspectFill options:SWImageManagerProcessingOptionsPriorityImage
        cancelBlock:^BOOL
        {
            return ! (_validLayer && self.view.alpha == 1.0f);
        }
        completionBlock:^(UIImage *image)
        {
            [docModel setThumbnailImage:image];
//            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//            [nc postNotificationName:SWPageControllerDocThumbnailChangeNotification object:page userInfo:@{@1:image}];
        }];
    }
}


- (void)_updatePageThumbnail
{
    if ( _thumbnailTimer == nil )
        _thumbnailTimer = [NSTimer scheduledTimerWithTimeInterval:1e100 target:self selector:@selector(_performUpdateThumbnail) userInfo:nil repeats:YES];
    
    [_thumbnailTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:ThumbNailUpdateDelay]];
}

- (void)_performUpdateThumbnail
{
    [_thumbnailTimer invalidate];
    _thumbnailTimer = nil;
    [self _generatePageThumbnail];
}



@end



#pragma mark - ModelObservation

@implementation SWPageController (ModelObservation)


#pragma mark ValueObserver

- (void)value:(SWValue*)value didEvaluateWithChange:(BOOL)changed
{
    if (value == _page.backgroundColor)
    {
        [self _updateBackgroundColor];
    }
    else if (value == _page.backgroundImage)
    {
        [self _updateBackgroundImage];
    }
    else if (value == _page.backgroundImageAspectRatio)
    {
        [self _updateBackgroundAspectRatio];
        [self _updateBackgroundImage];
    }
    else if (value == _page.title)
    {
        self.title = _page.title.valueAsString;
        [[NSNotificationCenter defaultCenter] postNotificationName:SWPageControllerTitleChangeNotification object:self];
    }
    else if ( value == _page.enabledInterfaceIdiom )
    {
//        [self _updateInterfaceIdiomRuler];
//        [[NSNotificationCenter defaultCenter] postNotificationName:SWPageControllerInterfaceIdiomChangeNotification object:self];
//        [self _updatePageThumbnail];
    }
}


#pragma mark Model Observer

- (void)documentModel:(SWDocumentModel *)docModel editingModeDidChangeAnimated:(BOOL)animated
{
//    BOOL editMode = docModel.editMode;
//    [self setLayoutEditing:editMode];
    
    [self _updateLayoutEditing];
    
    for ( SWItemController *itemController in _itemControllers )
    {
        [itemController refreshEditingStateFromModel];
    }
    
    [self _updateInterfaceIdiom];
    [self _updatePageThumbnail];
}

- (void)documentModelEditingPropertiesDidChange:(SWDocumentModel *)docModel
{
    [self _setupEditingProperties];
    
    for ( SWItemController *itemController in _itemControllers )
    {
        [itemController refreshEditingPropertiesFromModel];
    }
}



- (void)documentModelInterfaceIdiomDidChange:(SWDocumentModel *)docModel
{
    [self _updateInterfaceIdiom];

    [_layoutView reloadCellFramesAnimated:YES];
    [_layoutView reloadOverlayFrames];
    [self _setupBackgroundImageFrameAnimated:YES];

    for ( SWItemController *itemController in _itemControllers )
        [itemController refreshInterfaceIdiomFromModel];

    [self _updatePageThumbnail];
}



#pragma mark PageObserver


//- (void)pageV:(SWPage*)page didInsertItemsAtIndexes:(NSIndexSet*)indexes isGrouping:(BOOL)isGrouping
//{
//    NSArray *newItems = [page.items objectsAtIndexes:indexes];
//    
//    NSMutableArray *newControllers = [NSMutableArray array];
//    
//    for (SWItem *item in newItems)
//    {
//        Class ItemController = [item.class objectDescription].controllerClass;
//        SWItemController *itemController = [(SWItemController*)[ItemController alloc] initWithItem:item parentController:self];
//        [newControllers addObject:itemController];
//    }
//    
//    [_itemControllers insertObjects:newControllers atIndexes:indexes];
//    
//    NSArray *itemControllers = newControllers;
//    
//    SWLayoutViewViewAnimation animation = isGrouping?SWLayoutViewViewAnimationNone:SWLayoutViewViewAnimationAppear;
//    
//    [_layoutView insertCellsAtIndexes:indexes withAnimation:animation
//    willAppear:^
//    {
//        for (SWItemController *itemController in itemControllers)
//            [itemController viewWillAppear:YES];
//    }
//    didAppear:^
//    {
//        for (SWItemController *itemController in itemControllers)
//        {
//            [itemController setZoomScaleFactor:_layoutView.contentScaleFactor];
//            [itemController viewDidAppear:YES];
//        }
//    }];
//    
//    [self _updatePageThumbnail];
//}



- (void)page:(SWPage*)page didInsertItemsAtIndexes:(NSIndexSet*)indexes isGrouping:(BOOL)isGrouping
{
    NSArray *newItems = [page.items objectsAtIndexes:indexes];
    
    NSMutableArray *newControllers = [NSMutableArray array];
    
    for (SWItem *item in newItems)
    {
        Class ItemController = [item.class objectDescription].controllerClass;
        SWItemController *itemController = [(SWItemController*)[ItemController alloc] initWithItem:item parentController:self];
        [newControllers addObject:itemController];
    }
    
    [_itemControllers insertObjects:newControllers atIndexes:indexes];
    
    NSArray *itemControllers = newControllers;
    
    SWLayoutViewViewAnimation animation = isGrouping?SWLayoutViewViewAnimationNone:SWLayoutViewViewAnimationAppear;
    
    [_layoutView insertCellsAtIndexes:indexes withAnimation:animation
    willAppear:^
    {
        for (SWItemController *itemController in itemControllers)
            [itemController viewWillAppear:YES];
    }
    didAppear:^
    {
        for (SWItemController *itemController in itemControllers)
        {
            [itemController setZoomScaleFactor:_zoomScaleFactor];
            [itemController viewDidAppear:YES];
        }
    }];
    
    [self _updatePageThumbnail];
}


- (void)page:(SWPage *)page didRemoveItemsAtIndexes:(NSIndexSet *)indexes isGrouping:(BOOL)isGrouping
{
    NSArray *itemControllers = [_itemControllers objectsAtIndexes:indexes];
    [_itemControllers removeObjectsAtIndexes:indexes];
    
    SWLayoutViewViewAnimation animation = isGrouping?SWLayoutViewViewAnimationNone:SWLayoutViewViewAnimationAppear;
    // ^-- Atencio es important que per isGrouping!=NO la animacio sigui none perque en cas contrari els subviews del layoutView
    // no s'eliminen immediatament i com a consequencia la insercio del grup es pot fer en indexos incorrectes
    
    [_layoutView deleteCellsAtIndexes:indexes withAnimation:animation
    willDisappear:^
    {
        for (SWItemController *itemController in itemControllers)
            [itemController viewWillDisappear:YES];
    
    }
    didDisappear:^
    {
        for (SWItemController *itemController in itemControllers)
            [itemController viewDidDisappear:YES];
    }];
    
    [self _updatePageThumbnail];
}


- (void)page:(SWPage*)page didMoveItemAtPosition:(NSInteger)starPosition toPosition:(NSInteger)finalPosition
{
    SWItemController *itemController = [_itemControllers objectAtIndex:starPosition];
    
    [_itemControllers removeObjectAtIndex:starPosition];
    [_itemControllers insertObject:itemController atIndex:finalPosition];
    
    [_layoutView sendCellAtIndex:starPosition toZPosition:finalPosition];
    
    [self _updatePageThumbnail];
}


#pragma mark PageObserver<SWGroupObserver>

- (void)group:(id<SWGroup>)page didSelectItemsAtIndexes:(NSIndexSet *)indexes
{
    [_layoutView selectCellsAtIndexes:indexes animated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:SWPageControllerSelectionDidChangeNotification object:self];
}


- (void)group:(id<SWGroup>)page didDeselectItemsAtIndexes:(NSIndexSet *)indexes
{
    [_layoutView deselectCellsAtIndexes:indexes animated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:SWPageControllerSelectionDidChangeNotification object:self];
}


- (void)group:(id<SWGroup>)page didLockItemsAtIndexes:(NSIndexSet *)indexes
{
    [_layoutView lockCellsAtIndexes:indexes animated:NO];
}


- (void)group:(id<SWGroup>)page didUnlockItemsAtIndexes:(NSIndexSet *)indexes
{
    [_layoutView unlockCellsAtIndexes:indexes animated:NO];
}


- (void)group:(id<SWGroup>)page groupItemAtIndex:(NSInteger)index didChangePickEnabledStateTo:(BOOL)state
{
    [_layoutView setEnabledStateTo:state forCellAtIndex:index];
}

@end


#pragma mark - CustomProtocols

@implementation SWPageController (Zoomable)


#pragma mark SWZoomableViewController


- (void)setZoomScaleFactorV:(CGFloat)contentScale
{
    [_layoutView setContentScaleFactor:contentScale];
   // [_backgroundImageView setContentScaleFactor:contentScale];
    [_layoutOverlayCoordinatorView setContentScaleFactor:contentScale];
    
    for ( SWItemController *itemController in _itemControllers )
        [itemController setZoomScaleFactor:contentScale];
    
}

- (CGFloat)zoomScaleFactor
{
    return _zoomScaleFactor;
}

- (void)setZoomScaleFactor:(CGFloat)zoomScaleFactor
{
    if ( _zoomScaleFactor == zoomScaleFactor )
        return;

    _zoomScaleFactor = zoomScaleFactor;
    
    [_layoutView setZoomScaleFactor:zoomScaleFactor];
    [_layoutOverlayCoordinatorView setZoomScaleFactor:zoomScaleFactor];
    
    for ( SWItemController *itemController in _itemControllers )
        [itemController setZoomScaleFactor:zoomScaleFactor];
    
    // [self _updateBackgroundImage];
    // ^-- no updatem la imatge de fons segons el zoom per evitar memory pressure (comentat fora)
    
}

- (void)willBeginZooming
{
    //[_layoutView setSelectionHidden:YES];
    [_layoutOverlayCoordinatorView setSelectionHidden:YES];
    for ( SWItemController *itemController in _itemControllers )
        [itemController willBeginZooming];
}

- (void)didEndZooming
{
    //[_layoutView setSelectionHidden:NO];
    [_layoutOverlayCoordinatorView setSelectionHidden:NO];
    for ( SWItemController *itemController in _itemControllers )
        [itemController didEndZooming];
}

@end




@implementation SWPageController (CustomProtocols)

#pragma mark SWLayoutViewDataSource

- (NSInteger)numberOfCellsForlayoutView:(SWLayoutView *)layoutView
{
    return _itemControllers.count;
}


- (SWLayoutViewCell*)layoutView:(SWLayoutView *)layoutView layoutViewCellAtIndex:(NSInteger)index
{
    SWItemController *itemController = [_itemControllers objectAtIndex:index];
    UIView *contentView = itemController.view;
    
    SWItem *item = itemController.item;
    BOOL isGroupItem = item.isGroupItem;
    
    Class layoutCellClass = [SWLayoutViewCell class];
    
    if ( isGroupItem )
    {
        layoutCellClass = [SWGroupLayoutViewCell class];
        SWLayoutView *contentLayoutView = (id)contentView;
        [contentLayoutView setLayoutOverlayCoordinatorView:_layoutView.layoutOverlayCoordinatorView];
        //layoutViewCell = [[SWGroupLayoutViewCell alloc] initWithContentView:contentLayoutView];
    }
    
    SWLayoutViewCell *layoutViewCell = [[layoutCellClass alloc] initWithContentView:contentView];
    
    layoutViewCell.parentLayoutView = _layoutView;
    layoutViewCell.useAlphaChanelToComputePointInside = [itemController shouldUseAlphaChannelToComputePointInside];
    
    layoutViewCell.enabled = item.pickEnabled;
    layoutViewCell.selected = item.selected;
    layoutViewCell.locked = item.locked;
    
    [layoutViewCell setHiddenStatus:itemController.hiddenStatus animated:NO];
    [layoutViewCell setCoverViewColor:itemController.itemStateColor];
    [layoutViewCell setViewBackColor:itemController.itemBackColor];
    return layoutViewCell;
}


- (CGRect)layoutView:(SWLayoutView*)layoutView frameForCellAtIndex:(NSInteger)index
{
    SWItemController *itemController = [_itemControllers objectAtIndex:index];
    SWItem *item = itemController.item;
    CGRect frame = [item frameForOrientation:self.interfaceOrientation idiom:item.docModel.interfaceIdiom];
    return frame;
}


- (SWLayoutViewCellResizingStyle)layoutView:(SWLayoutView*)layoutView resizingStyleForCellAtIndex:(NSInteger)index
{
    //SWItemResizeMask resizeMask = [[_page.items objectAtIndex:index] resizeMask];

    SWItemController *itemController = [_itemControllers objectAtIndex:index];
    SWItem *item = itemController.item;
    SWItemResizeMask resizeMask = [item resizeMask];
    
    if (resizeMask == (SWItemResizeMaskFlexibleHeight | SWItemResizeMaskFlexibleWidth))
        return SWLayoutViewCellResizingStyleAll;

    else if (resizeMask == SWItemResizeMaskFlexibleWidth)
        return SWLayoutViewCellResizingStyleHorizontal;
    
    else if (resizeMask == SWItemResizeMaskFlexibleHeight)
        return SWLayoutViewCellResizingStyleVertical;
    
    else
        return SWLayoutViewCellResizingStyleNone;
}


- (CGSize)layoutView:(SWLayoutView*)layoutView minimumSizeForCellAtIndex:(NSInteger)index
{
    SWItemController *itemController = [_itemControllers objectAtIndex:index];
    return [itemController.item minimumSize];
}


- (CGSize)layoutView:(SWLayoutView*)layoutView currentMinimumSizeForCellAtIndex:(NSInteger)index
{
    SWItemController *itemController = [_itemControllers objectAtIndex:index];
    return [itemController.item currentMinimumSize];
}


- (void)layoutView:(SWLayoutView *)layoutView commitEditionForCellsAtIndexes:(NSIndexSet*)indexset
{
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    SWDeviceInterfaceIdiom idiom = _page.docModel.interfaceIdiom;

    [indexset enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        SWLayoutViewCell *cell = [layoutView cellAtIndex:idx];
    
        CGRect frame = cell.frame;
    
        SWItemController *itemController = [_itemControllers objectAtIndex:idx];
        SWItem *item = itemController.item;
        [item setFrame:frame withOrientation:orientation idiom:idiom];
    }];
    
    [self _updatePageThumbnail];
}



#pragma mark SWLayoutViewDelegate

- (BOOL)layoutView:(SWLayoutView *)layoutView shouldSelectCellAtIndex:(NSInteger)index
{
    return YES;
}


- (void)layoutView:(SWLayoutView *)layoutView didSelectCellsAtIndexes:(NSIndexSet*)indexSet
{
    [_page selectItemsAtIndexes:indexSet];
}


- (void)layoutView:(SWLayoutView *)layoutView didDeselectCellsAtIndexes:(NSIndexSet*)indexSet
{
    [_page deselectItemsAtIndexes:indexSet];
}


- (void)layoutView:(SWLayoutView *)layoutView didPerformTapInRect:(CGRect)rect
{    
    _touchInPage = NO;
    _menuTarget = _page;
    [self _displayMenuInRect:rect];
}


- (void)layoutView:(SWLayoutView *)layoutView didPerformLongPresureInRect:(CGRect)rect
{
    _longPressurePoint = rect.origin;
    _touchInPage = YES;
    _menuTarget = _page;
    [self _displayMenuInRect:rect];
}


@end


#pragma mark - UIProtocols

@implementation SWPageController (UIProtocols)


@end
