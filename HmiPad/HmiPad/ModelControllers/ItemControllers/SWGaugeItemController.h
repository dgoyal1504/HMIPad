//
//  SWGaugeItemController.h
//  HmiPad
//
//  Created by Lluch Joan on 01/06/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWItemController.h"

@class SWGaugeView ;

@interface SWGaugeItemController : SWItemController


@property (strong, nonatomic) SWGaugeView *gaugeView;

@end
