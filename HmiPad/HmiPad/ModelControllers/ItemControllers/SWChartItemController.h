//
//  SWChartItemController.h
//  HmiPad
//
//  Created by Joan Lluch on 13/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWItemController.h"
#import "SWTrendView.h"

@interface SWChartItemController : SWItemController<SWTrendViewDataSource>

@property (nonatomic) SWTrendView *trendView;

@end
