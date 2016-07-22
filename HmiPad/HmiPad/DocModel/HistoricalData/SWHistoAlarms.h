//
//  SWHistoAlarmsCenter.h
//  HmiPad
//
//  Created by Joan Lluch on 30/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWHistoValues.h"
#import "SWHistoAlarmsDatabaseContext.h"

@class SWDocumentModel;
@class SWEvent;

@interface SWHistoAlarms : SWHistoValues

- (id)initInDocumentModel:(SWDocumentModel*)docModel;

- (SWDatabaseContextTimeRange)dbContextRange;
- (SWHistoAlarmsDatabaseContext *)dbContextForWriting;
- (SWHistoAlarmsDatabaseContext *)dbContextForReadingWithReferenceTime:(CFAbsoluteTime)referenceTime;

@end


@interface SWHistoAlarms(convenience)

// convenience
- (void)addEvent:(SWEvent*)event;

@end