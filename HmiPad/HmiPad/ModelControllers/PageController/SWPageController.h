//
//  SWPageController.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/15/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWZoomableViewController.h"
#import "SWLayoutResizerView.h"
#import "SWGroup.h"

//#import "SWPage.h"
//#import "SWLayoutView.h"
//#import "SWItemController.h"

extern NSString * const SWPageControllerSelectionDidChangeNotification;
extern NSString * const SWPageControllerTitleChangeNotification;
//extern NSString * const SWPageControllerInterfaceIdiomChangeNotification;
extern NSString * const SWPageControllerThumbnailChangeNotification;


@class SWLayoutView;
@class SWPage;



@interface SWPageController : UIViewController
{
    NSMutableArray *_itemControllers;
    __weak UIView *_pullUpView;
    CGPoint _longPressurePoint;
    NSInteger _lastItemSelected;
    BOOL _touchInPage;
}

- (id)initWithPage:(SWPage*)page;

@property (nonatomic, strong, readonly) SWPage *page;

- (void)displayMenuInRect:(CGRect)rect target:(id<SWGroup>)target;

- (void)invalidateLayer;

- (void)moveToDirection:(SWLayoutResizerViewDirection)direction;
- (void)resizeToDirection:(SWLayoutResizerViewDirection)direction;

@end


@interface SWPageController(Zoomable)<SWZoomableViewController>
@property (nonatomic) CGFloat zoomScaleFactor;
@end


