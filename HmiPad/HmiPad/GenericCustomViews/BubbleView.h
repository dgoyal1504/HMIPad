//
//  BubbleView.h
//  iPhoneDomusSwitch_090409
//
//  Created by Joan on 09/04/09.
//  Copyright 2009 SweetWilliam, S.L.. All rights reserved.

#import <UIKit/UIKit.h>
#import "GradientBackgroundView.h"


//////////////////////////////////////////////////////////////////////////////
#pragma mark BubbleView
//////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------
@interface BubbleView : GradientBackgroundView /*UIView*/
{
    UILabel *messageViewLabel;
    __weak UIView *owner ;      // weak
    __weak id delegate;         //weak ;
}

@property (nonatomic, readonly) UILabel *messageViewLabel ;
@property (nonatomic, weak) id delegate ;

// - (id)initWithView:(UIView*)theOwner atPoint:(CGPoint)point vGap:(CGFloat)vGap message:(NSString*)msg ;    // deprecated
- (id)initWithPresentingView:(UIView*)theOwner ;
- (void)presentFromView:(UIView*)view vGap:(CGFloat)vGap message:(NSString*)msg animated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated ;

@end



//////////////////////////////////////////////////////////////////////////////
#pragma mark BubbleView delegate methods
//////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------
// implementem els callbacks de l'owner com a una categoria de NSObject
@interface NSObject(BubbleViewDelegate)

- (void)bubbleViewTouched:(BubbleView*)sender; //opcional

@end






