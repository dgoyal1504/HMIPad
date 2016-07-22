//
//  SWHPIndicatorView.h
//  HmiPad
//
//  Created by Joan Lluch on 6/23/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWLayer.h"
#import "SWEnumTypes.h"

@interface SWHPIndicatorView : UIView


@property (nonatomic, strong) UIColor *needleColor;
//@property (nonatomic, strong) UIColor *barColor;
@property (nonatomic, strong) UIColor *tintsColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) NSString *format ;
@property (nonatomic, assign) SWDirection direction;

- (void)setRange:(SWRange)range animated:(BOOL)animated ;
- (void)setValue:(double)value animated:(BOOL)animated ;

- (void)setRanges:(NSData*)ranges;   // array de parelles de doubles
- (void)setRangeRgbColors:(NSData*)rangeColors;   // array de rgbcolors

@end
