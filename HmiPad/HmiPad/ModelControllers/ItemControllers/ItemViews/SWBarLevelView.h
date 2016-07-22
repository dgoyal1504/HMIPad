//
//  SWBarLevelView.h
//  HmiPad
//
//  Created by Joan Lluch on 4/16/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWLayer.h"
#import "SWEnumTypes.h"

@interface SWBarLevelView : UIView

@property (nonatomic, strong) UIColor *barColor;
@property (nonatomic, strong) UIColor *tintsColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) NSString *format ;
@property (nonatomic, assign) SWDirection direction;

- (void)setRange:(SWRange)range animated:(BOOL)animated ;
- (void)setValue:(double)value animated:(BOOL)animated ;

@end
