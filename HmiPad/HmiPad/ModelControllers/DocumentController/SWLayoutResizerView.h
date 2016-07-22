//
//  SWLayoutOverlayResizerView.h
//  HmiPad
//
//  Created by Joan Lluch on 15/10/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWLayoutTypes.h"

@class SWLayoutResizerView;

@protocol SWLayoutResizerViewDelegate <NSObject>

- (void)resizerView:(SWLayoutResizerView*)resizerView moveToDirection:(SWLayoutResizerViewDirection)direction;
- (void)resizerView:(SWLayoutResizerView*)resizerView resizeToDirection:(SWLayoutResizerViewDirection)direction;

@optional
- (void)resizerView:(SWLayoutResizerView *)resizerView didChangedPosition:(CGPoint)position;

@end


@interface SWLayoutResizerView : UIView

@property (nonatomic, weak) id<SWLayoutResizerViewDelegate>delegate;

- (void)presentResizer;
- (void)dismissResizerAnimated:(BOOL)animated;

@end
