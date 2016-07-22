//
//  SWTrendItem.h
//  HmiPad
//
//  Created by Joan on 29/04/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import "SWDataPresenterItem.h"
#import "PlotGroup.h"

@class SWTrendItem ;
@class PlotData ;
@class PlotGroup ;

// protocol a implementar per els controladors d'aquest item
@protocol TrendItemObserver <SWObjectObserver>

@optional
- (void)trendItem:(SWTrendItem*)trendItem didAddPlotGroup:(PlotGroup*)plotGroup atIndex:(NSInteger)indx ;
- (void)trendItem:(SWTrendItem*)trendItem didremovePlotGroupAtIndex:(NSInteger)indx ;

- (void)trendItem:(SWTrendItem*)trendItem didAddPlotData:(PlotData*)plotData toGroupAtIndex:(NSInteger)indx ;
- (void)trendItem:(SWTrendItem*)trendItem didReplacePlotDatasForGroupAtIndex:(NSInteger)indx;
//- (void)trendItem:(SWTrendItem*)trendItem didReplacePlotDatasWithRange:(SWPlotRange)dataRange forGroupAtIndex:(NSInteger)indx ;
- (void)trendItem:(SWTrendItem*)trendItem didRemovePlotData:(PlotData*)plotData fromGroupAtIndex:(NSInteger)indx ;
@end



// SWTrendItem
@interface SWTrendItem : SWDataPresenterItem
//{
//    NSMutableArray *_plotGroups ;       // conte objectes PlotGroup accedits per index
//    NSMutableDictionary *_plotDatas ;   // conte objectes PlotData accedits per key
//}

//@property (nonatomic,assign) int xMajorTickCount ;

@property (nonatomic,readonly) SWValue *style;
@property (nonatomic,readonly) SWValue *updatingStyle;
@property (nonatomic,readonly) SWExpression *options;
@property (nonatomic,readonly) SWExpression *enableGestures;

@property (nonatomic,readonly) SWExpression *plotInterval ;
@property (nonatomic,readonly) SWExpression *intervalOffset ;
@property (nonatomic,readonly) SWExpression *yMin ;
@property (nonatomic,readonly) SWExpression *yMax ;

@property (nonatomic,readonly) SWExpression *xMajorTickInterval ;
@property (nonatomic,readonly) SWExpression *xMinorTicksPerInterval ;
@property (nonatomic,readonly) SWExpression *yMajorTickInterval ;
@property (nonatomic,readonly) SWExpression *yMinorTicksPerInterval ;

@property (nonatomic,readonly) SWExpression *tintColor;
@property (nonatomic,readonly) SWExpression *borderColor;

@property (nonatomic,readonly) SWExpression *plots ;   // un array amb valors
@property (nonatomic,readonly) SWExpression *colors ;  // un array amb colors

//@property (nonatomic,readonly) SWValue *databaseIdentifier;


//- (BOOL)plotGroupsAddPlotDataWithKey:(id)key toGroupAtIndex:(NSUInteger)indx ;   // torna YES si s'ha creat un grup nou
//- (BOOL)plotGroupsRemovePlotDataWithKey:(id)key fromGroupAtIndex:(NSUInteger)indx ;
//- (NSData *)pointsForPlotDataWithKey:(id)key inRange:(SWPlotRange)range;
- (NSArray *)pointsDatasInRange:(SWPlotRange)range;
- (NSArray *)plotGroups ;

@end



