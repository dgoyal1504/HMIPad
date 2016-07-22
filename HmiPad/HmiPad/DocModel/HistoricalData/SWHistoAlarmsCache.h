//
//  SWHistoAlarmsCache.h
//  HmiPad
//
//  Created by Joan Lluch on 19/05/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWHistoAlarmsDatabaseContext.h"

@class SWEvent;
@class SWHistoAlarmsCache;


@protocol SWHistoAlarmsCacheDelegate<NSObject>

- (void)histoAlarmsCache:(SWHistoAlarmsCache*)haCache didUpdateSection:(NSInteger)section;

@end


@interface SWHistoAlarmsCache : NSObject

@property (nonatomic, weak) id<SWHistoAlarmsCacheDelegate>delegate;
@property (nonatomic,strong) NSArray *dbContexts;
- (void)setSearchText:(NSString*)searchText;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsForSection:(NSInteger)section;
- (SWEvent*)eventAtRow:(NSInteger)row forSection:(NSInteger)section;

@end
