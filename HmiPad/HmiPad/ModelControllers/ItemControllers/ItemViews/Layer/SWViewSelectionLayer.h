//
//  SWViewSelectionLayer.h
//  HmiPad
//
//  Created by Joan on 09/10/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface SWViewSelectionLayer : CALayer

- (void)addToView:(UIView*)view;
- (void)remove;
- (void)layoutInSuperview;

@end
