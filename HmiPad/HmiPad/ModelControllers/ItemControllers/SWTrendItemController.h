//
//  SWTrendItemController.h
//  HmiPad
//
//  Created by Joan on 29/04/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import "SWItemController.h"
#import "SWTrendView.h"

@interface SWTrendItemController : SWItemController
{
    //SWPlotRange _currentXRange ;
    //dispatch_source_t _reLoadTimer ;
}

@property (nonatomic) SWTrendView *trendView;

@end
