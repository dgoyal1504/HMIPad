//
//  SWDeleteButtonView.h
//  HmiPad
//
//  Created by Joan on 18/11/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWDeleteButtonView;

@protocol SWDeleteButtonViewDelegate

- (void)deleteButtonViewDidTouch:(SWDeleteButtonView*)deleteButtonView;

@end


@interface SWDeleteButtonView : UIView

@property (weak) id<SWDeleteButtonViewDelegate> delegate;

@end
