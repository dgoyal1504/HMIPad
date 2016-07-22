//
//  SWHistoAlarmsDatabaseContext.h
//  HmiPad
//
//  Created by Joan Lluch on 16/04/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWDatabaseContext.h"

@class SWEvent;

extern NSString* kSWHistoAlarmsDidAddEventNotification;
extern NSString* kSWHistoAlarmsDidFetchEventsNotification;

@interface SWHistoAlarmsDatabaseContext : SWDatabaseContext;

- (void)addEvent:(SWEvent*)event completion:(void (^)(BOOL success))block;
- (void)fetchEventsInRange:(NSRange)range filterString:(NSString*)filterString completion:(void (^)(NSArray *events, NSInteger totalRows))block;

@end