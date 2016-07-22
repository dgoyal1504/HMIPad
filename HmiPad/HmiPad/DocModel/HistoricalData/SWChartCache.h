//
//  SWChartCache.h
//  HmiPad
//
//  Created by Joan Lluch on 14/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SymbolicCoder.h"
#import "QuickCoder.h"

#import "PlotGroup.h"


@class SWChartCache;
@class PlotGroup;
@class PlotData;
@class SWHistoValuesDatabaseContext;


// protocol a implementar per els controladors d'aquest item
@protocol SWChartCacheDelegate <NSObject>

@optional
- (void)chartCache:(SWChartCache*)chartCache didAddPlotGroup:(PlotGroup*)plotGroup atIndex:(NSInteger)indx ;
- (void)chartCache:(SWChartCache*)chartCache didremovePlotGroupAtIndex:(NSInteger)indx ;

- (void)chartCache:(SWChartCache*)chartCache didAddPlotData:(PlotData*)plotData toGroupAtIndex:(NSInteger)indx ;
- (void)chartCache:(SWChartCache*)chartCache didRemovePlotData:(PlotData*)plotData fromGroupAtIndex:(NSInteger)indx;

//- (void)chartCache:(SWChartCache*)chartCache didUpdatePlotsForGroupAtIndex:(NSInteger)indx;
- (void)chartCache:(SWChartCache*)chartCache didUpdatePlotsAtRange:(SWPlotRange)dataRange forGroupAtIndex:(NSInteger)indx;
// ^-- nomes es crida si especifiquem un dbContext

@end


@interface SWChartCache : NSObject<QuickCoding,SymbolicCoding>

@property (nonatomic, readonly) NSArray *plotGroups;  // conte objectes PlotGroup accedits per index
@property (nonatomic, readonly) NSDictionary *plotDatas;  // conte objectes PlotData accedits per key

@property (nonatomic, weak) id<SWChartCacheDelegate> delegate;
- (void)setupWithPlotsCount:(NSInteger)count forPlotGroupIndex:(NSInteger)indx;  // ho prepara per el numero de plots en el grup especificat

- (void)setDbContext:(SWHistoValuesDatabaseContext *)dbContext forPlotGroupAtIndex:(NSInteger)indx;

- (NSArray*)plotsForPlotGroupAtIndex:(NSInteger)indx;
- (NSArray *)pointsDatasForPlotGroupAtIndex:(NSInteger)indx inRange:(SWPlotRange)range;
//- (NSData *)UNUSEDpointsForPlotDataWithKey:(id)key inRange:(SWPlotRange)range;

// compatibility

@end


#pragma mark - compatibility

@interface SWChartCache(compatibility)
@property (nonatomic, readwrite) NSMutableArray *plotGroups;
- (void)makePlotDatasAfterDecodingGroup;
@end;


