//
//  SWGaugeView.h
//  HmiPad
//
//  Created by Lluch Joan on 01/06/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWLayer.h"
#import "SWEnumTypes.h"

@interface SWGaugeView : UIView

@property (nonatomic, assign) double majorTickInterval;
@property (nonatomic, assign) int minorTicksPerInterval;

@property (nonatomic, strong) UIColor *needleColor;
@property (nonatomic, strong) UIColor *tintsColor;
@property (nonatomic, strong) UIColor *borderColor;

@property (nonatomic, strong) NSString *format;
@property (nonatomic, strong) NSString *labelText;

@property (nonatomic, assign) SWGaugeStyle gaugeStyle;
@property (nonatomic, assign) double angleRange;
@property (nonatomic, assign) double deadAnglePosition;

- (void)setRange:(SWRange)range animated:(BOOL)animated;
- (void)setValue:(double)value animated:(BOOL)animated;

- (void)setRanges:(NSData*)ranges;   // array de parelles de doubles
- (void)setRangeRgbColors:(NSData*)rangeColors;   // array de rgbcolors

@end
