//
//  SWItemController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/16/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SWItemController.h"
#import "SWPageController.h"
#import "SWColor.h"
#import "SWLayoutViewCell.h"
#import "SWSourceItem.h"
#import "SWExpression.h"

#import "SWDocument.h"
#import "SWDocumentModel.h"
#import "SWContrastedViewProtocol.h"

//#import "SWViewControllerNotifications.h"
//#import "SWDocumentController.h"

//NSString * const SWItemControllerIncompatibilityException = @"SWItemControllerIncompatibilityException";

//NSString * const SWItemControllerDidChangeFrameNotification = @"SWItemControllerDidChangeFrameNotification";
//NSString * const SWItemControllerDidChangeCoverNotification = @"SWItemControllerDidChangeCoverNotification";
//NSString * const SWItemControllerCoverColorKey = @"SWItemControllerCoverColorKey";



NSString *_dictStringForKey( NSDictionary *dict, NSDictionary *defDict, NSString *key)
{
    id obj = [dict objectForKey:key];
    if ( obj == nil ) obj = [defDict objectForKey:key];
    if ( [obj isKindOfClass:[NSString class]] )
        return obj;
    
    return nil;
}

SWValue *_dictValueForKey( NSDictionary *dict, NSDictionary *defDict, NSString *key)
{
    id obj = [dict objectForKey:key];
    if ( obj == nil ) obj = [defDict objectForKey:key];
    if ( [obj isKindOfClass:[SWValue class]] )
        return obj;
    
    return nil;
}

double _dictDoubleForKey( NSDictionary *dict, NSDictionary *defDict, NSString *key)
{
    id obj = [dict objectForKey:key];
    if ( obj == nil ) obj = [defDict objectForKey:key];
    return [obj doubleValue];
}





@implementation SWItemController

@synthesize view = _view;
@dynamic isViewLoaded;

//- (id)initWithItem:(SWItem*)item
//{
//    return [self initWithItem:item nibName:nil inBundle:nil];
//}
//
//- (id)initWithItem:(SWItem*)item nibName:(NSString*)nibName inBundle:(NSBundle*)bundle
//{
//    self = [super init];
//
//    if (self)
//    {
//        if (!nibName)
//            nibName = NSStringFromClass([self class]);
//        
//        if (!bundle)
//            bundle = [NSBundle mainBundle];
//        
//        _nibName = nibName;
//        _bundle = bundle;
//        
//        NSString *controllerType = [item.class controllerType];
//        
//        if (![_nibName isEqualToString:controllerType])
//        {
//            NSException *exception = [NSException exceptionWithName:SWItemControllerIncompatibilityException 
//                                                             reason:[NSString stringWithFormat:@"Current Item: %@, itemController: %@, currentController: %@",[item.class description], [item.class controllerType], self.class.description]
//                                                           userInfo:nil];
//            [exception raise];
//        }
// 
//        _item = item;
//        //NSLog( @"SWItemController init" );
//    }
//    return self;
//}


- (id)initWithItem:(SWItem*)item parentController:(id)parent
{
    self = [super init];
    if ( self )
    {
        _item = item;
        _parentController = parent;
        _zoomScaleFactor = 1.0f;
    }
    return self;
}

- (void)dealloc
{
    // Nothing to do. Subclasses may override.
    //NSLog( @"SWItemController dealloc" ) ;
}

- (UIView*)view
{
    if (!_view) 
    {
        [self loadView];
        [self viewDidLoad];
    }
    return _view;
}

- (SWItemController*)parentItemController
{
    if ( [_parentController isKindOfClass:[SWItemController class]] )
        return _parentController;

    return nil;
}


- (SWPageController*)parentPageController
{
    SWItemController *parent = self;
    
    while ( nil != (parent = parent->_parentController) && [parent isKindOfClass:[SWItemController class]] ) {}
    
    if ( [parent isKindOfClass:[SWPageController class]] )
        return (SWPageController*)parent;

    return nil;
}


- (UIInterfaceOrientation)interfaceOrientation
{
    SWPageController *pageController = [self parentPageController];
    UIInterfaceOrientation orientation = [pageController interfaceOrientation];
    return orientation;
}


//- (UIInterfaceOrientation)interfaceOrientation
//{
//    SWItemController *parent = self;
//    
//    while ( nil != (parent = parent->_parentController) && [parent isKindOfClass:[SWItemController class]] )
//    {
//    }
//    
//    if ( [parent isKindOfClass:[UIViewController class]] )
//        return [(UIViewController*)parent interfaceOrientation];
//    
//    return 0;
//}


- (SWLayoutViewCell *)layoutViewCell
{
    UIView *parent = _view;
    Class layoutCellClass = [SWLayoutViewCell class];
    
    while ( nil != (parent = [parent superview]) && ![parent isKindOfClass:layoutCellClass] )
    {
    }
    
    return (id)parent;
}

- (void)setView:(UIView *)view
{
    _view = view;
    //_view.backgroundColor = [UIColor clearColor];
    _view.opaque = NO;
    
    if (!_view)
    {
        [self viewDidUnload];
    }
}

- (BOOL)isViewLoaded
{
    return _view != nil;
}

- (void)loadView
{
    //[_bundle loadNibNamed:_nibName owner:self options:nil];
    // Subclasses may override and set the view
}

- (void)viewDidLoad
{
    // Nothing to do. Subclasses may override.
}

- (void)viewDidUnload
{
    // Nothing to do. Subclasses may override.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self refreshViewFromItem];
    
    //NSLog( @"item: %@, addItemControllerObserver: %@", _item, self);
    [_item addObjectObserver:self];
    //[_item.docModel addObserver:self];
    
    for (SWValue *value in _item.properties)
        [value addObserver:self];
    
    // Subclasses may override.
}

- (void)viewDidAppear:(BOOL)animated
{
    // Nothing to do. Subclasses may override.
}

- (void)viewWillDisappear:(BOOL)animated
{
    //NSLog( @"item: %@, removeItemControllerObserver: %@", _item, self);
    [_item removeObjectObserver:self];
    //[_item.docModel removeObserver:self];
    
    for (SWValue *value in _item.properties)
        [value removeObserver:self];
    
    // Subclasses may override.
}

- (void)viewDidDisappear:(BOOL)animated 
{
    // Nothing to do. Subclasses may override.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
{
    // Nothing to do. Subclasses may override.
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //ICO _interfaceOrientation = toInterfaceOrientation;
    // Subclasses may override.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // Nothing to do. Subclasses may override.
}

#pragma mark - Properties

#pragma mark - Main Methods

- (void)refreshViewFromItem
{
    //[self refreshBackgroundColorFromItem];
    //[self _updateItemState];
    //[self _updateHiddenStateAnimated:NO];
    
    [self _updateItemBackColor];
    [self _updateItemHiddenStateAnimated:NO];
}

- (void)refreshBackgroundColorFromItem
{
    if ( [_view respondsToSelector:@selector(setContrastForBackgroundColor:)] )
    {
        UIColor *backColor = [self itemBackColor];
        [(id<SWContrastedViewProtocol>)_view setContrastForBackgroundColor:backColor];
    }
}

- (void)refreshEditingStateFromModel
{
}

- (void)refreshInterfaceIdiomFromModel
{
}

- (void)refreshEditingPropertiesFromModel
{
    [self _updateFrameEditionStatus];
}

- (void)refreshSelectedState:(BOOL)selected
{
}


- (void)refreshFrameEditingState:(BOOL)frameEditing
{
}



//- (void)refreshZoomScaleFactorV:(CGFloat)contentScale
//{
//   [self _changeScaleforSubviewsOfView:_view contentScale:contentScale];
//}


//- (void)refreshZoomScaleFactor:(CGFloat)contentScale
//{
//   // _zoomScale = contentScale;
//   //wwscale  [self _changeScaleforSubviewsOfView:_view contentScale:contentScale];
//}

- (void)refreshZoomScaleFactor:(CGFloat)zoomScaleFactor
{
    [_view setContentScaleFactor:[[UIScreen mainScreen]scale]*zoomScaleFactor];
}


- (BOOL)shouldUseAlphaChannelToComputePointInside
{
    return NO;
}


#pragma mark - Private Methods

- (void)_updateBackgroundColor__VVV
{
    UIColor *backColor = _item.backgroundColor.valueAsColor;
    self.view.backgroundColor = backColor;
}


//- (void)_updateBackgroundColor
//{
//    UIColor *backColor = [self itemBackColor];
//    
//    if ( [_view respondsToSelector:@selector(setContrastForBackgroundColor:)] )
//    {
//        [(id<SWContrastedViewProtocol>)_view setContrastForBackgroundColor:backColor];
//    }
//}

#pragma mark - Private Methods (layoutViewCell)

- (void)_updateItemBackColor
{
    UIColor *backColor = [self itemBackColor];
    [self.layoutViewCell setBackgroundColor:backColor];
    
    [self refreshBackgroundColorFromItem];
}


- (void)_updateItemState
{
    UIColor *color = [self itemStateColor];
    [self.layoutViewCell setCoverViewColor:color];
}

- (void)_updateItemHiddenStateAnimated:(BOOL)animated
{
    BOOL isHidden = [self hiddenStatus];
    [self.layoutViewCell setHiddenStatus:isHidden animated:animated];
}


- (void)_updateItemFrame
{
    // el view propi es el contentView de un SWLayoutView, per tant postem una notificacio que la capturara el SWPageController
   // [[NSNotificationCenter defaultCenter] postNotificationName:SWItemControllerDidChangeFrameNotification object:self];
    
    [self.layoutViewCell reloadLayoutFrame];
}




- (UIColor*)itemBackColor
{
    // Subclasses May override
    UIColor *color = _item.backgroundColor.valueAsColor;
    return color;
}

- (UIColor*)itemStateColor
{
    UIColor *color = nil;
    
    for (SWValue *value in _item.properties) 
    {
        color = value.getResultColor;
        if ( color ) break;
    }
    return color;
}


- (BOOL)hiddenStatus
{
    BOOL isHidden = _item.hidden.valueAsBool;
    return isHidden;
}


- (void)_updateFrameEditionStatus
{
    BOOL isSelected = _item.selected;
    BOOL allowsEditing = _item.docModel.allowFrameEditing;
    
    BOOL newStatus = isSelected && allowsEditing;
    BOOL oldStatus = _frameEditing;
    
    _frameEditing = newStatus;
    
    if (oldStatus != newStatus)
        [self refreshFrameEditingState:newStatus];
}


#pragma mark - SWZoomableItemController


//- (void)setViewZoomScaleFactorV:(CGFloat)contentScale
//{
//    [_view setContentScaleFactor:contentScale];
//    [self refreshZoomScaleFactor:contentScale];
//}

- (void)setZoomScaleFactor:(CGFloat)zoomScaleFactor
{
    if ( _zoomScaleFactor == zoomScaleFactor )
        return;

    _zoomScaleFactor = zoomScaleFactor;
    [self refreshZoomScaleFactor:zoomScaleFactor];
}

- (void)setZoomScaleFactorDeep
{
    CGFloat contentScale = [[UIScreen mainScreen]scale]*_zoomScaleFactor;
    [self _changeScaleforSubviewsOfView:_view contentScale:contentScale];
}

- (void)willBeginZooming
{
//    [self refreshSelectionHiddenState:YES];
}

- (void)didEndZooming
{
//    [self refreshSelectionHiddenState:NO];
}


#pragma mark - SWZoomableItemController(private)

- (void)_changeScaleforSubviewsOfView:(UIView *)aView contentScale:(CGFloat)contentScale
{
    for ( UIView *view in aView.subviews )
    {
        view.contentScaleFactor = contentScale;
        [view setNeedsDisplay];
        [self _changeScaleforSubviewsOfView:view contentScale:contentScale];
    }
}




#pragma mark - Document model Observer

//- (void)documentModel:(SWDocumentModel *)docModel editingModeDidChangeAnimated:(BOOL)animated
//{
//   // [self _updateHiddenStateAnimated:YES];
//}
//
//
//- (void)documentModelEditingPropertiesDidChange:(SWDocumentModel *)docModel
//{
//    [self _updateFrameEditionStatus];
//}

#pragma mark - Item Observer

- (void)selectedDidChangeForItem:(SWItem*)item
{
    //NSLog(@"ITEM %@ IS SELECTED : %@",item.identifier, STRBOOL(item.selected));
    [self _updateFrameEditionStatus];
    [self refreshSelectedState:_item.selected];
}



#pragma mark - Value Observer

- (void)value:(SWValue*)value didEvaluateWithChange:(BOOL)changed
{    
    if (value == _item.framePortrait || value == _item.frameLandscape ||
        value == _item.framePortraitPhone || value == _item.frameLandscapePhone )
    {
        if ( [_item frameValue:value matchesInterfaceIdiom:_item.docModel.interfaceIdiom forOrientation:self.interfaceOrientation] )
            [self _updateItemFrame];
    } 
    else if (value == _item.backgroundColor) 
    {
        [self _updateItemBackColor];
    } 
    else if (value == _item.hidden) 
    {
        [self _updateItemHiddenStateAnimated:YES];
    }
}

- (void)expressionStateDidChange:(SWExpression *)expression
{
    [self _updateItemState];
}

- (void)expressionSourceStringDidChange:(SWExpression*)expression
{
    //NSLog( @"E Source ErrorString:%@", [expression getSourceErrorString] );
}

@end
