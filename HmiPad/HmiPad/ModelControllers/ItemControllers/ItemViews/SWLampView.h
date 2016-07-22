//
//  SWLampView.h
//  HmiPad
//
//  Created by Lluch Joan on 09/07/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWLampView : UIView

@property (nonatomic, assign) BOOL blink;
@property (nonatomic, strong) UIColor *color;

- (void)setValue:(BOOL)value animated:(BOOL)animated;

@end
