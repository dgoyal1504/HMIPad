//
//  SWLayoutViewCell.h
//  HmiPad
//
//  Created by Joan Martin on 9/6/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWLayoutTypes.h"
#import "SWZoomableViewController.h"

@class SWLayoutView;
@class SWGroupLayoutView;

@interface SWLayoutViewCell : UIView<SWZoomableViewController>
{
    UIView *_contentView;
}

- (id)initWithContentView:(UIView*)contentView;

// Properties
@property (nonatomic, weak) SWLayoutView *parentLayoutView;
@property (nonatomic, readonly) SWLayoutView *contentLayoutView;

@property (nonatomic, assign) CGSize minimalSize;
@property (nonatomic, assign) SWLayoutViewCellResizingStyle resizingStyle;

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL locked;

@property (nonatomic, assign) BOOL useAlphaChanelToComputePointInside;

// Write only properties
- (void)setViewBackColor:(UIColor*)color;
- (void)setCoverViewColor:(UIColor*)color;
- (void)setHiddenStatus:(BOOL)hidden animated:(BOOL)animated;

// Reloading
- (void)reloadLayoutSettings;
- (void)reloadLayoutFrame;

@end


@interface SWLayoutViewCell(subLayout)

// Returns bounds expressed in overlay coordinates
- (CGRect)layoutViewConvertedFrame;

@end;

