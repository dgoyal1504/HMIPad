//
//  SWChartItem.h
//  HmiPad
//
//  Created by Joan Lluch on 13/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//


#import "SWItem.h"
#import "PlotGroup.h"

@class SWChartItem ;
@class PlotData ;
@class PlotGroup ;

// protocol a implementar per els controladors d'aquest item
@protocol ChartItemObserver <SWObjectObserver>

@optional
- (void)chartItem:(SWChartItem*)trendItem didAddPlotGroup:(PlotGroup*)plotGroup atIndex:(NSInteger)indx ;
- (void)chartItem:(SWChartItem*)trendItem didremovePlotGroupAtIndex:(NSInteger)indx ;

- (void)chartItem:(SWChartItem*)trendItem didAddPlotData:(PlotData*)plotData toGroupAtIndex:(NSInteger)indx ;
//- (void)chartItem:(SWChartItem*)trendItem didReplacePlotData:(PlotData*)plotData forGroupAtIndex:(NSInteger)indx ;
- (void)chartItem:(SWChartItem*)trendItem didRemovePlotData:(PlotData*)plotData fromGroupAtIndex:(NSInteger)indx ;
@end


// SWChartItem
@interface SWChartItem : SWItem

//@property (nonatomic,assign) int xMajorTickCount ;

@property (nonatomic,readonly) SWValue *style;
@property (nonatomic,readonly) SWValue *updatingStyle;
@property (nonatomic,readonly) SWValue *chartType;
@property (nonatomic,readonly) SWExpression *options;

@property (nonatomic,readonly) SWExpression *takeShot;



//@property (nonatomic,readonly) SWExpression *plotInterval ;
//@property (nonatomic,readonly) SWExpression *intervalOffset ;

@property (nonatomic,readonly) SWExpression *yMin ;
@property (nonatomic,readonly) SWExpression *yMax ;

@property (nonatomic,readonly) SWExpression *xFirstTick ;
@property (nonatomic,readonly) SWExpression *xMajorTickInterval ;
@property (nonatomic,readonly) SWExpression *xMinorTicksPerInterval ;

@property (nonatomic,readonly) SWExpression *yMajorTickInterval ;
@property (nonatomic,readonly) SWExpression *yMinorTicksPerInterval ;

@property (nonatomic,readonly) SWExpression *tintColor;
@property (nonatomic,readonly) SWExpression *borderColor;
@property (nonatomic,readonly) SWExpression *format;

@property (nonatomic,readonly) SWExpression *labels;   // un array amb valors
@property (nonatomic,readonly) SWExpression *colors ;  // un array amb colors
@property (nonatomic,readonly) SWExpression *regions;   // un array amb arrays de valors

//- (NSData *)pointsForPlotDataWithKey:(id)key inRange:(SWPlotRange)range ;
- (NSArray *)pointsDatasInRange:(SWPlotRange)range;
- (NSArray *)plotGroups ;

@end