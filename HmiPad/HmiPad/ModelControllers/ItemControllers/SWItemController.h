//
//  SWItemController.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/16/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWDocumentModel.h"
#import "SWItem.h"
#import "SWExpression.h"
#import "SWZoomableViewController.h"

//extern NSString * const SWItemControllerIncompatibilityException;
//extern NSString * const SWItemControllerDidChangeFrameNotification;
//extern NSString * const SWItemControllerDidChangeCoverNotification;
//extern NSString * const SWItemControllerCoverColorKey;

//@class SWColorCoverView;
@class SWLayoutViewCell;
@class SWPageController;


extern NSString *_dictStringForKey( NSDictionary *dict, NSDictionary *defDict, NSString *key);
extern SWValue *_dictValueForKey( NSDictionary *dict, NSDictionary *defDict, NSString *key);
extern double _dictDoubleForKey( NSDictionary *dict, NSDictionary *defDict, NSString *key);

@interface SWItemController : NSObject <DocumentModelObserver, SWObjectObserver,ExpressionObserver,SWZoomableViewController>
{
    __weak id _parentController;
    
    //SWColorCoverView *_coverView;
}

- (id)initWithItem:(SWItem*)item parentController:(id)parent;

- (void)refreshViewFromItem;
- (void)refreshBackgroundColorFromItem;
- (void)refreshEditingStateFromModel;
- (void)refreshInterfaceIdiomFromModel;
- (void)refreshEditingPropertiesFromModel;

- (void)refreshFrameEditingState:(BOOL)frameEditing;
- (void)refreshZoomScaleFactor:(CGFloat)contentScaleFactor;

- (void)refreshSelectedState:(BOOL)selected;

- (void)loadView;
- (void)viewDidLoad;
- (void)viewDidUnload;

- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidDisappear:(BOOL)animated;

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

- (BOOL)shouldUseAlphaChannelToComputePointInside;


@property (nonatomic, readonly) SWItemController *parentItemController;
@property (nonatomic, readonly) SWPageController *parentPageController;
@property (nonatomic) UIView *view;
@property (nonatomic, readonly) SWLayoutViewCell *layoutViewCell;   // torna el layoutViewCell pare
@property (nonatomic, readonly) BOOL frameEditing;
@property (nonatomic, readonly) BOOL hiddenStatus;
@property (nonatomic, readonly) UIColor *itemStateColor;
@property (nonatomic, readonly) UIColor *itemBackColor;
@property (nonatomic) CGFloat zoomScaleFactor;
- (void)setZoomScaleFactorDeep;


@property (nonatomic, readonly) UIInterfaceOrientation interfaceOrientation;
@property (readonly) BOOL isViewLoaded;

@property (strong, nonatomic, readonly) SWItem *item;

@end

