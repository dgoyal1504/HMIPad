//
//  SWLayoutOverlayViewCell.h
//  HmiPad
//
//  Created by Joan Martin on 9/6/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWLayoutTypes.h"

@class SWLayoutOverlayViewCell;

@protocol SWLayoutOverlayViewCellDelegate <NSObject>

@optional
- (CGRect)layoutOverlayViewCell:(SWLayoutOverlayViewCell*)overlayCell willMoveToFrame:(CGRect)frame eventType:(SWLayoutViewCellEventType)eventType;
- (void)layoutOverlayViewCell:(SWLayoutOverlayViewCell*)overlayCell didMoveToFrame:(CGRect)frame eventType:(SWLayoutViewCellEventType)eventType;
- (void)layoutOverlayViewCell:(SWLayoutOverlayViewCell*)overlayCell didBeginEventType:(SWLayoutViewCellEventType)eventType;
- (void)layoutOverlayViewCell:(SWLayoutOverlayViewCell*)overlayCell didEndEventType:(SWLayoutViewCellEventType)eventType;

@required
//- (CGSize)layoutOverlayViewCellMinimalSize:(SWLayoutOverlayViewCell*)overlayCell;
- (BOOL)layoutOverlayViewCellAllowsFrameEditing:(SWLayoutOverlayViewCell*)overlayCell;
//- (CGFloat)layoutOverlayViewCellContentScale:(SWLayoutOverlayViewCell*)overlayCell;
- (CGFloat)layoutOverlayViewCellZoomScaleFactor:(SWLayoutOverlayViewCell*)overlayCell;

@end

@class SWLayoutViewCell;

@interface SWLayoutOverlayViewCell : NSObject //UIView

- (id)initWithLayoutViewCell:(SWLayoutViewCell*)cell;

- (void)reloadFromCellFrame;
- (void)reloadButtons;

// punts expressats en coordinades del super (SWLayoutOverlayView)
- (SWLayoutViewCellEventType)eventTypeAtPoint:(CGPoint)point;
- (void)beginTouchAtPoint:(CGPoint)point;
- (void)moveTouchToPoint:(CGPoint)point;
- (void)endTouch;

- (CGRect)contentFrame;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) CGFloat contentScale;
@property (nonatomic, assign) BOOL enableEditing;
@property (nonatomic, assign) BOOL innerEditing;
- (SWLayoutViewCellResizingStyle)resizeStyle;

@property (nonatomic, weak) SWLayoutViewCell *layoutViewCell;
@property (nonatomic, weak) id <SWLayoutOverlayViewCellDelegate> delegate;

@end
