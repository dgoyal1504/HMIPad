//
//  SWGroupItemController.m
//  HmiPad
//
//  Created by Joan Lluch on 18/10/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWGroupItemController.h"
#import "SWPageController.h"
#import "SWGroupItem.h"

#import "SWLayoutView.h"
#import "SWLayoutViewCell.h"
#import "SWGroupLayoutViewCell.h"


NSString * const SWGroupItemControllerSelectionDidChangeNotification = @"SWGroupItemControllerSelectionDidChangeNotification";

@interface SWGroupItemController()<GroupItemObserver,/*SWGroupLayoutViewDataSource,*/SWLayoutViewDataSource,SWLayoutViewDelegate>
{
    SWLayoutView *_groupLayoutView;
    NSMutableArray *_itemControllers;
}

@end


@implementation SWGroupItemController


#pragma mark - life cycle

- (id)initWithItem:(SWItem *)item parentController:(SWItemController *)parent
{
    self = [super initWithItem:item parentController:parent];
    if ( self )
    {
        _itemControllers = [NSMutableArray array];
        SWGroupItem *groupItem = [self _groupItem];
    
        // Loading Item Controllers
        for (SWItem *subItem in groupItem.items)
        {
            Class ItemController = [subItem.class objectDescription].controllerClass;
            SWItemController *itemController = [(SWItemController*)[ItemController alloc] initWithItem:subItem parentController:self];
            [_itemControllers addObject:itemController];
        }
    }
    return self;
}


- (void)loadView
{
    _groupLayoutView = [[SWLayoutView alloc] initWithFrame:CGRectMake(0,0,100,100)];
    _groupLayoutView.isBottomPosition = NO;
    
    SWGroupItem *groupItem = [self _groupItem];
    SWDocumentModel *docModel = groupItem.docModel;
    _groupLayoutView.showsErrorFramesInEditMode = docModel.showsErrorFrameInEditMode;
    _groupLayoutView.showsHiddenItemsInEditMode = docModel.showsHiddenItemsInEditMode;
    _groupLayoutView.editMode = docModel.editMode;
    
    _groupLayoutView.delegate = self;
    _groupLayoutView.dataSource = self;
    
    self.view = _groupLayoutView;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_groupLayoutView reloadDataAnimated:NO];
    
    for ( SWItemController *itemController in _itemControllers )
        [itemController viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    for ( SWItemController *itemController in _itemControllers )
        [itemController viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    for ( SWItemController *itemController in _itemControllers )
        [itemController viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    for ( SWItemController *itemController in _itemControllers )
        [itemController viewDidDisappear:animated];
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    for ( SWItemController *itemController in _itemControllers )
        [itemController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    for ( SWItemController *itemController in _itemControllers )
        [itemController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [_groupLayoutView reloadCellFramesAnimated:NO];
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    for ( SWItemController *itemController in _itemControllers )
        [itemController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [_groupLayoutView reloadOverlayFrames];
}




#pragma mark overrides

- (BOOL)shouldUseAlphaChannelToComputePointInside
{
    return NO;
}


- (void)refreshZoomScaleFactor:(CGFloat)contentScaleFactor
{
    // no cridem el super,
    for ( SWItemController *itemController in _itemControllers )
        [itemController setZoomScaleFactor:contentScaleFactor];
}

//- (void)refreshZoomScaleFactor:(CGFloat)contentScaleFactor
//{
//    [super refreshZoomScaleFactor:contentScaleFactor];    // wwscale
//    for ( SWItemController *itemController in _itemControllers )
//        [itemController setZoomScaleFactor:contentScaleFactor];
//}


- (void)refreshInterfaceIdiomFromModel
{
    [super refreshInterfaceIdiomFromModel];
    [_groupLayoutView reloadCellFramesAnimated:YES];
    [_groupLayoutView reloadOverlayFrames];
    
    for ( SWItemController *itemController in _itemControllers )
        [itemController refreshInterfaceIdiomFromModel];
}


- (void)refreshEditingPropertiesFromModel
{
    [super refreshEditingPropertiesFromModel];
    
    for ( SWItemController *itemController in _itemControllers )
        [itemController refreshEditingPropertiesFromModel];
}


- (void)refreshEditingStateFromModel
{
    [super refreshEditingStateFromModel];
    
    for ( SWItemController *itemController in _itemControllers )
        [itemController refreshEditingStateFromModel];
}


#pragma mark - private


- (void)_updateFrame
{
    // to do
}


- (SWGroupItem*)_groupItem
{
    if ([self.item isKindOfClass:[SWGroupItem class]])
    {
        return (SWGroupItem*)self.item;
    }
    return nil;
}




#pragma mark - SWLayoutViewDataSource

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
        [contentLayoutView setLayoutOverlayCoordinatorView:_groupLayoutView.layoutOverlayCoordinatorView];
        //layoutViewCell = [[SWGroupLayoutViewCell alloc] initWithContentView:contentLayoutView];
    }
    
    SWLayoutViewCell *layoutViewCell = [[layoutCellClass alloc] initWithContentView:contentView];

    layoutViewCell.parentLayoutView = _groupLayoutView;
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
    SWGroupItem *groupItem = [self _groupItem];
    SWDeviceInterfaceIdiom idiom = groupItem.docModel.interfaceIdiom;

    [indexset enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        SWLayoutViewCell *cell = [layoutView cellAtIndex:idx];
    
        CGRect frame = cell.frame;
    
        SWItemController *itemController = [_itemControllers objectAtIndex:idx];
        SWItem *item = itemController.item;
        [item setFrame:frame withOrientation:orientation idiom:idiom];
    }];
    
    [groupItem adjustFrameToFitSubItemsForOrientation:orientation idiom:idiom];
}


#pragma mark SWLayoutViewDelegate

- (BOOL)layoutView:(SWLayoutView *)layoutView shouldSelectCellAtIndex:(NSInteger)index
{
    return YES;
}


- (void)layoutView:(SWLayoutView *)layoutView didSelectCellsAtIndexes:(NSIndexSet*)indexSet
{
    SWGroupItem *groupItem = [self _groupItem];
    [groupItem selectItemsAtIndexes:indexSet];
}


- (void)layoutView:(SWLayoutView *)layoutView didDeselectCellsAtIndexes:(NSIndexSet*)indexSet
{
    SWGroupItem *groupItem = [self _groupItem];
    [groupItem deselectItemsAtIndexes:indexSet];
}



//- (void)layoutView:(SWLayoutView *)layoutView didPerformTapInRect:(CGRect)rect
//{
//    SWPageController *pageController = self.parentPageController;
//    
//    SWGroupItem *groupItem = [self _groupItem];
//
//    NSIndexSet *indexes = [groupItem selectedItemIndexes];
//    NSArray *items = groupItem.items;
//    
//    // ^- Esencialment hem de passar un id<SWGroup> i ja tindrem els items i els i els selected items
//    
//
//    _touchInPage = NO;
//    
//    //[_modelManager.inputController resignResponder];
//    //[self becomeFirstResponder];
//    
//    UIMenuController *menu = [UIMenuController sharedMenuController];
//    [menu setTargetRect:rect inView:self.view];
//    [menu setArrowDirection:UIMenuControllerArrowDefault];
//    [menu setMenuVisible:YES animated:YES];
//    [self performDelayedHideMenu];
//}

- (void)layoutView:(SWLayoutView *)layoutView didPerformTapInRect:(CGRect)rect
{
    SWPageController *pageController = self.parentPageController;
    CGRect rectInPage = [layoutView convertRect:rect toView:pageController.view];

    SWGroupItem *groupItem = [self _groupItem];
    [pageController displayMenuInRect:rectInPage target:groupItem];
}



//
//- (void)performDelayedHideMenu
//{
//    [NSThread cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayedHideMenu) object:nil];
//    [self performSelector:@selector(delayedHideMenu) withObject:nil afterDelay:4.0];
//}
//
//- (void)delayedHideMenu
//{
//    UIMenuController *menu = [UIMenuController sharedMenuController];
//    [menu setMenuVisible:NO animated:YES];
//}



//
//
//- (void)layoutView:(SWLayoutView *)layoutView didPerformLongPresureInRect:(CGRect)rect
//{
//    _longPressurePoint = rect.origin;
//    _touchInPage = YES;
//    
//    [_modelManager.inputController resignResponder];
//    [self becomeFirstResponder];
//    
//    UIMenuController *menu = [UIMenuController sharedMenuController];
//    [menu setTargetRect:rect inView:self.view];
//    [menu setArrowDirection:UIMenuControllerArrowDefault];
//    [menu setMenuVisible:YES animated:YES];
//    [self performDelayedHideMenu];
//}
//
//
//- (void)layoutView:(SWLayoutView *)layoutView didChangeResizerPosition:(CGPoint)position
//{
//    SWDocumentModel *docModel = _page.docModel;
//    
//    if ( UIInterfaceOrientationIsLandscape(self.interfaceOrientation) )
//        docModel.landscapeResizerPosition = position;
//    else
//        docModel.portraitResizerPosition = position;
//}




//#pragma mark - SWGroupLayoutViewDataSource
//
//
//- (NSInteger)numberOfCellsForGrouplayoutView:(SWGroupLayoutView*)groupLayoutView
//{
//    return _itemControllers.count;
//}
//
//
//- (SWLayoutViewCell*)groupLayoutView:(SWGroupLayoutView*)groupLayoutView layoutViewCellAtIndex:(NSInteger)index
//{
//    SWItemController *itemController = [_itemControllers objectAtIndex:index];
//    UIView *contentView = itemController.view;
//    
//    SWLayoutViewCell *layoutViewCell = [[SWLayoutViewCell alloc] initWithContentView:contentView];
//    
//    SWPageController *pageController = [self parentPageController];
//    SWLayoutView *parentLayoutView = pageController.layoutView;
//    layoutViewCell.parentLayoutView = parentLayoutView;
//    
//    layoutViewCell.parentGroupLayoutView = _groupLayoutView;
//    
//    layoutViewCell.useAlphaChanelToComputePointInside = [itemController shouldUseAlphaChannelToComputePointInside];
//    
//    SWItem *item = itemController.item;
//    layoutViewCell.useSubviewsToComputePointInside = item.isGroupItem;
//    layoutViewCell.selected = /*NO*/ item.selected;
//    layoutViewCell.locked = YES /*item.locked*/;
//    
//    //layoutViewCell.editMode = layoutView.editMode;
//    //layoutViewCell.showsCoverInEditMode = layoutView.showsErrorFramesInEditMode;
//    //layoutViewCell.showsHiddenItemsInEditMode = layoutView.showsHiddenItemsInEditMode;
//    
//    [layoutViewCell setHiddenStatus:itemController.hiddenStatus animated:NO];
//    [layoutViewCell setCoverViewColor:itemController.itemStateColor];
//    [layoutViewCell setViewBackColor:itemController.itemBackColor];
//    return layoutViewCell;
//}
//
//
//- (CGRect)groupLayoutView:(SWGroupLayoutView*)groupLayoutView frameForCellAtIndex:(NSInteger)index
//{
//    SWItemController *itemController = [_itemControllers objectAtIndex:index];
//    SWItem *item = itemController.item;
//    CGRect frame = [item frameForOrientation:self.interfaceOrientation idiom:item.docModel.interfaceIdiom];
//    return frame;
//}



#pragma mark - SWExpressionObserver

- (void)value:(SWValue*)value didEvaluateWithChange:(BOOL)changed
{
    SWGroupItem *item = [self _groupItem];
    
    if (value == item.framePortrait || value == item.frameLandscape ||
        value == item.framePortraitPhone || value == item.frameLandscapePhone)
    {
        [self _updateFrame];
        [super value:value didEvaluateWithChange:changed];
    }
    else
    {
        [super value:value didEvaluateWithChange:changed];
    }
}


#pragma mark - GroupItemObserver<SWGroupObserver>


- (void)group:(id<SWGroup>)groupItem didSelectItemsAtIndexes:(NSIndexSet *)indexes
{
    [_groupLayoutView selectCellsAtIndexes:indexes animated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:SWGroupItemControllerSelectionDidChangeNotification object:self];
}


- (void)group:(id<SWGroup>)groupItem didDeselectItemsAtIndexes:(NSIndexSet *)indexes
{
    [_groupLayoutView deselectCellsAtIndexes:indexes animated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:SWGroupItemControllerSelectionDidChangeNotification object:self];
}


- (void)group:(id<SWGroup>)page didLockItemsAtIndexes:(NSIndexSet *)indexes
{
    [_groupLayoutView lockCellsAtIndexes:indexes animated:NO];
}


- (void)group:(id<SWGroup>)page didUnlockItemsAtIndexes:(NSIndexSet *)indexes
{
    [_groupLayoutView unlockCellsAtIndexes:indexes animated:NO];
}


- (void)group:(id<SWGroup>)groupItem groupItemAtIndex:(NSInteger)index didChangePickEnabledStateTo:(BOOL)state
{
    [_groupLayoutView setEnabledStateTo:state forCellAtIndex:index];
}


@end






