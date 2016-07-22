//
//  SWScaleView.h
//  HmiPad
//
//  Created by Lluch Joan on 23/05/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWLayer.h"
#import "SWEnumTypes.h"

#pragma mark SWScaleView

@interface SWScaleView : UIView

@property (nonatomic, assign) double majorTickInterval ;
@property (nonatomic, assign) int minorTicksPerInterval ;
@property (nonatomic, strong) NSString *format ;
@property (nonatomic, assign) SWOrientation orientation;

- (void)setRange:(SWRange)range animated:(BOOL)animated ;

@end