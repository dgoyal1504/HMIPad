//
//  SWFlowViewDelegate.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/8/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SWFlowView;

@protocol SWFlowViewDelegate <NSObject, UIScrollViewDelegate>

@optional

// -- Managing Selections -- //
- (NSInteger)flowView:(SWFlowView*)flowView willSelectViewAtIndex:(NSInteger)index;
- (void)flowView:(SWFlowView*)flowView didSelectViewAtIndex:(NSInteger)indexPath;

// -- Managing Presentations -- //
- (void)flowView:(SWFlowView *)flowView willPresentViewAtIndex:(NSInteger)index;
- (void)flowView:(SWFlowView *)flowView didPresentViewAtIndex:(NSInteger)index;
- (void)flowView:(SWFlowView *)flowView willDismissViewAtIndex:(NSInteger)index;
- (void)flowView:(SWFlowView *)flowView didDismissViewAtIndex:(NSInteger)index;

// -- Reordering Flow View's -- //
- (NSInteger)flowView:(SWFlowView*)flowView targetIndexForMoveFromViewAtIndex:(NSInteger)sourceIndex toProposedIndex:(NSInteger)proposedDestinationIndex;

- (void)flowView:(SWFlowView *)flowView willAppearViewAtIndex:(NSInteger)index;
- (void)flowView:(SWFlowView *)flowView didAppearViewAtIndex:(NSInteger)index;
- (void)flowView:(SWFlowView *)flowView willDisappearViewAtIndex:(NSInteger)index;
- (void)flowView:(SWFlowView *)flowView didDisappearViewAtIndex:(NSInteger)index;

@end
