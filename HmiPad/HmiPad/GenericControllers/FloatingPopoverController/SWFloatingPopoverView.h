//
//  SWFloatingPopoverView.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/29/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWFloatingFrameView;
@class SWFloatingContentOverlayView;

//#define kFramePadding      6.0f
//#define kBorderOffset      2.0f

#define kFramePadding      6.0f
#define kBorderOffset      2.0f

@class SWFloatingPopoverView;

@protocol SWFloatingPopoverViewDelegate
-(void)floatingPopoverViewDidChangeTintsColor:(SWFloatingPopoverView*)popoverView;
@end

@interface SWFloatingPopoverView : UIView

@property (nonatomic, weak) id<SWFloatingPopoverViewDelegate> delegate;
@property (nonatomic, readonly, strong) UIView *contentView;
@property (nonatomic, readonly, strong) SWFloatingFrameView *frameView;
@property (nonatomic, readonly, strong) SWFloatingContentOverlayView *contentOverlayView;

//@property (nonatomic, strong) UIColor *frameColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *frameColor;

- (void)setTintsColor:(UIColor*)frameColor UI_APPEARANCE_SELECTOR;

- (void)prepareFrameWithNavigationBar:(BOOL)withNavigationBar animated:(BOOL)animated;

@end

@interface SWFloatingPopoverView(SWClearNavigationBar)

- (void)touchesMoved_patatim;

@end

//@interface UIView (firstResponder)
//
//- (BOOL)containsFirstResponder;
//- (UIView*)firstResponder;
//
//@end
