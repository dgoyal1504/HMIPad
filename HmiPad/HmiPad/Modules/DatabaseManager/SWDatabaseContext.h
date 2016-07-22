//
//  SWDatabaseContext.h
//  HmiPad
//
//  Created by Joan Lluch on 03/04/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SWDatabaseManager.h"
#import "FMDB.h"

//@class SWDatabaseContext;
//
//@protocol SWDatabaseContextDelegate
//
//@required
//- (NSString*)databaseContextGetDatabaseName:(SWDatabaseContext*)dbContext;
//
//@end

@protocol SWDatabaseContextDelegate<NSObject>

@optional
- (void)databaseContextDidClose:(SWDatabaseContext*)dbContext;

@end


extern NSString *SWDatabaseContextDidOpenDatabaseNotification;
extern NSString *SWDatabaseContextDidCloseDatabaseNotification;
extern NSString *SWDatabaseContextDBNameKey;

typedef enum {
    SWDatabaseContextTimeRangeUnknown = -1,
    SWDatabaseContextTimeRangeHourly = 0,
    SWDatabaseContextTimeRangeDaily,
    SWDatabaseContextTimeRangeWeekly,
    SWDatabaseContextTimeRangeMonthly,
    SWDatabaseContextTimeRangeYearly,
}   SWDatabaseContextTimeRange;    // ATENCIO: Ha de coincidir amb SWDatabaseTimeRange

@class FMDatabase;

@interface SWDatabaseContext : NSObject

- (id)init;

@property (nonatomic, weak) id<SWDatabaseContextDelegate> delegate;
- (void)setName:(NSString*)name range:(SWDatabaseContextTimeRange)range referenceTime:(CFAbsoluteTime)absoluteTime;
- (void)setWriteFlag:(BOOL)writeFlag;
- (BOOL)isLoaded;


//- (BOOL)shouldBeUpdatedForRange:(SWDatabaseContextTimeRange)range referenceTime:(CFAbsoluteTime)referenceTime;   // a deprecar

@property (nonatomic, readonly) NSString *keyName;

+ (NSString*)dictionaryKeyForName:(NSString*)name range:(SWDatabaseContextTimeRange)range referenceTime:(CFAbsoluteTime)referenceTime;
+ (CFTimeInterval)timeIntervalForRange:(SWDatabaseContextTimeRange)range;
+ (CFAbsoluteTime)differenceTimeForRange:(SWDatabaseContextTimeRange)range time:(CFAbsoluteTime)time offset:(NSInteger)offset;
+ (CFAbsoluteTime)distantFutureTime;

//@property (nonatomic, weak) id<SWDatabaseContextDelegate> delegate;
@property (nonatomic, readonly) FMDatabase *database;


// to override
- (void)databaseDidLoad;      // Setup initial database updates. Will be executed on the FMDatabase queue

// observer retain/release
//- (void)inUseRetain;
//- (void)inUseRelease;
//- (int)inUseRetainCount;

@end




