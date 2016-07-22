//
//  SWHistoValuesDatabaseContext.h
//  HmiPad
//
//  Created by Joan Lluch on 19/04/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWDatabaseContext.h"

#import "PlotGroup.h"

@interface SWHistoValuesDatabaseContext : SWDatabaseContext

//- (id)initWithName:(NSString*)name fieldNames:(NSArray*)fieldNames;
//- (void)setName:(NSString*)name fieldNames:(NSArray*)fieldNames;
//- (void)setName:(NSString*)name fieldNames:(NSArray*)fieldNames valuesCount:(NSInteger)valuesCount;

- (void)setFieldNames:(NSArray*)fieldNames valuesCount:(NSInteger)valuesCount;

- (void)rebuildWithFieldNames:(NSArray*)fieldNames valuesCount:(NSInteger)valuesCount;

- (void)addValues:(NSArray*)values absoluteTime:(CFAbsoluteTime)time;
- (void)fetchPointsDatasInRange:(SWPlotRange)range completion:(void(^)(NSArray *pointDatas, double factor))block;

@end
