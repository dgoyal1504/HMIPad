//
//  SWScrollView.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/2/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <UIKit/UIKit.h>

//typedef enum {
//    
//} SWScrollView;

@interface SWScrollView : UIScrollView {
    BOOL _shouldStopAnimation;
    CGPoint _normalizedScrollAnimationDirection;
}

@property (nonatomic, readonly, getter = isAnimatingScrolling) BOOL animatingScrolling;
@property (nonatomic, assign) CGPoint scrollAnimationDirection;
@property (nonatomic, assign) CGFloat scrollAnimationVelocityFactor;

- (void)startScrollingAnimation;
- (void)stopScrollingAnimation;

@end
