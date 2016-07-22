//
//  SWHistoAlarmsCenter.h
//  HmiPad
//
//  Created by Joan Lluch on 30/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWHistoValuesDatabaseContext.h"

@class SWDocumentModel;

@interface SWHistoValues : NSObject<SWDatabaseContextDelegate>

- (id)initInDocumentModel:(SWDocumentModel*)docModel;

@property( nonatomic, readonly) SWDocumentModel *docModel;
- (SWHistoValuesDatabaseContext *)dbContextForWritingWithName:(NSString*)name range:(SWDatabaseContextTimeRange)timeRange fieldNames:(NSArray*)fields valuesCount:(NSInteger)valuesCount;
- (SWHistoValuesDatabaseContext *)dbContextForReadingWithName:(NSString*)name range:(SWDatabaseContextTimeRange)range referenceTime:(CFAbsoluteTime)absoluteTime;

@end


@interface SWHistoValues(subclassingHooks)

- (SWDatabaseContext*)contextForKey:(NSString*)key;
- (void)addContext:(SWDatabaseContext*)dbContext;
- (void)removeContext:(SWDatabaseContext *)dbContext;

@end