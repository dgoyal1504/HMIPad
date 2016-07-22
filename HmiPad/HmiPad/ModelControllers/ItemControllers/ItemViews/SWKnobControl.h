//
//  SWKnobControl.h
//  HmiPad
//
//  Created by Lluch Joan on 26/06/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWLayer.h"
#import "SWEnumTypes.h"


@interface SWKnobControl : UIControl

@property (nonatomic, assign) double majorTickInterval;
@property (nonatomic, assign) int minorTicksPerInterval;

@property (nonatomic, strong) UIColor *needleColor;
@property (nonatomic, strong) UIColor *tintsColor;
@property (nonatomic, strong) UIColor *borderColor;

@property (nonatomic, strong) NSString *format;
@property (nonatomic, strong) NSString *labelText;
@property (nonatomic, readonly) double value;

@property (nonatomic, assign) SWKnobThumbStyle thumbStyle;
@property (nonatomic, assign) SWKnobStyle knobStyle;

- (void)setRange:(SWRange)range animated:(BOOL)animated;
- (void)setValue:(double)value animated:(BOOL)animated;

@end
