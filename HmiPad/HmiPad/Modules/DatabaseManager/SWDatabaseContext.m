//
//  SWDatabaseContext.m
//  HmiPad
//
//  Created by Joan Lluch on 03/04/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWDatabaseContext.h"
#import "AppModelFilePaths.h"

NSString *SWDatabaseContextDidOpenDatabaseNotification = @"SWDatabaseContextDidOpenDatabaseNotification";
NSString *SWDatabaseContextDidCloseDatabaseNotification = @"SWDatabaseContextDidCloseDatabaseNotification";
NSString *SWDatabaseContextDBNameKey = @"dbName";

@interface SWDatabaseContext()
{
    NSString *_path;
    NSString *_keyName;
    FMDatabase *_db;
    BOOL _writeFlag;
    BOOL _didLoad;
}
@end


@implementation SWDatabaseContext
{
    NSString *_name;
    CFGregorianDate _dbContextGregDate;
    SInt32 _dbContextWeek;
    SWDatabaseContextTimeRange _dbRange;
}

#pragma mark - private functions

//static NSString *_suffixStringForRange_gregDate_week(SWDatabaseContextTimeRange range, const CFGregorianDate g, const SInt32 week)

static NSString *_keyStringForName_Range_gregDate_week(NSString *name, SWDatabaseContextTimeRange range, const CFGregorianDate g, const SInt32 week)
{
    NSString *suffixString = nil;
    switch (range)
    {
        case SWDatabaseContextTimeRangeYearly:
            suffixString = [NSString stringWithFormat:@"_%04d", (int)g.year];
            break;
            
        case SWDatabaseContextTimeRangeWeekly:
            suffixString = [NSString stringWithFormat:@"_%04d:w%02d", (int)g.year, (int)week];
            break;
            
        case SWDatabaseContextTimeRangeUnknown:
        case SWDatabaseContextTimeRangeMonthly:
            suffixString = [NSString stringWithFormat:@"_%04d-%02d", (int)g.year, g.month];
            break;
        
        case SWDatabaseContextTimeRangeDaily:
            suffixString = [NSString stringWithFormat:@"_%04d-%02d-%02d", (int)g.year, g.month, g.day];
            break;
            
        case SWDatabaseContextTimeRangeHourly:
            suffixString = [NSString stringWithFormat:@"_%04d-%02d-%02d:h%02d", (int)g.year, g.month, g.day, g.hour];
            break;
    }
    
    return [name stringByAppendingString:suffixString];
}


static void _getGregorianDateForReferenceTime_outGregDate_outGregWeek(CFAbsoluteTime absoluteTime, CFGregorianDate *g, SInt32 *week)
{
    CFTimeZoneRef timeZone = CFTimeZoneCopySystem();
    *g = CFAbsoluteTimeGetGregorianDate(absoluteTime, timeZone);
    *week = CFAbsoluteTimeGetWeekOfYear(absoluteTime, timeZone);
    CFRelease(timeZone);
}


#pragma mark - class methods

+ (NSString*)dictionaryKeyForName:(NSString*)name range:(SWDatabaseContextTimeRange)range referenceTime:(CFAbsoluteTime)referenceTime
{
    CFGregorianDate g;
    SInt32 week;
    
    _getGregorianDateForReferenceTime_outGregDate_outGregWeek(referenceTime, &g, &week);
    return _keyStringForName_Range_gregDate_week( name, range, g, week);
}


+ (CFTimeInterval)timeIntervalForRange:(SWDatabaseContextTimeRange)range
{
    CFTimeInterval interval = 0;
    switch ( range )
    {
        case SWDatabaseContextTimeRangeYearly:
            interval = 3600*24*365;
            break;
            
        case SWDatabaseContextTimeRangeWeekly:
            interval = 3600*24*7;
            break;
            
        case SWDatabaseContextTimeRangeMonthly:
            interval = 3600*24*30;
            break;
        
        case SWDatabaseContextTimeRangeDaily:
            interval = 3600*24;
            break;
            
        case SWDatabaseContextTimeRangeHourly:
            interval = 3600;
            break;
            
        case SWDatabaseContextTimeRangeUnknown:
            interval = 0;
            break;
    }
    return interval;
}


+ (CFAbsoluteTime)differenceTimeForRange:(SWDatabaseContextTimeRange)range time:(CFAbsoluteTime)time offset:(NSInteger)offset
{
    char *component = "";
    CFAbsoluteTime resultTime = time;
    
    switch ( range )
    {
        case SWDatabaseContextTimeRangeYearly:
            component = "y";
            break;
            
        case SWDatabaseContextTimeRangeWeekly:
            component = "w";
            break;
            
        case SWDatabaseContextTimeRangeMonthly:
            component = "M";
            break;
        
        case SWDatabaseContextTimeRangeDaily:
            component = "d";
            break;
            
        case SWDatabaseContextTimeRangeHourly:
            component = "H";
            break;
            
        case SWDatabaseContextTimeRangeUnknown:
            component = "";
            break;
    }
    
    CFCalendarRef gregorian = CFCalendarCreateWithIdentifier(NULL, kCFGregorianCalendar);
    CFCalendarAddComponents(gregorian, &resultTime, 0, component, offset);
    CFRelease(gregorian);

    return resultTime;
}


+ (CFAbsoluteTime)distantFutureTime
{
    CFAbsoluteTime resultTime = 0;
    CFCalendarRef gregorian = CFCalendarCreateWithIdentifier(NULL, kCFGregorianCalendar);
    CFCalendarComposeAbsoluteTime(gregorian, &resultTime, "y", 2100);
    CFRelease(gregorian);
    return resultTime;
}


//- (NSString *)_currentSuffixStringForRange:(SWDatabaseContextTimeRange)range
//{
//    CFGregorianDate g = _dbContextGregDate;
//    SInt32 week = _dbContextWeek;
//    
//    return _suffixStringForRange_gregDate_week(range, g, week);
//}

#pragma mark - private

- (BOOL)_shouldBeUpdatedForName:(NSString*)name range:(SWDatabaseContextTimeRange)range referenceTime:(CFAbsoluteTime)referenceTime
{
    if ( _dbRange != range )
        return YES;
    
    if ( ![_name isEqualToString:name] )
        return YES;

    CFGregorianDate g;
    SInt32 week;
    _getGregorianDateForReferenceTime_outGregDate_outGregWeek(referenceTime, &g, &week);
    
    BOOL change = NO;
    if ( range == SWDatabaseContextTimeRangeWeekly )
    {
        if ( g.year != _dbContextGregDate.year || week != _dbContextWeek ) change = YES;
    }
    else
    {
        if ( range <= SWDatabaseContextTimeRangeYearly && g.year != _dbContextGregDate.year ) change = YES;
        else if ( range <= SWDatabaseContextTimeRangeMonthly && g.month != _dbContextGregDate.month ) change = YES;
        else if (range <= SWDatabaseContextTimeRangeDaily && g.day != _dbContextGregDate.day ) change = YES;
        else if (range <= SWDatabaseContextTimeRangeHourly && g.hour != _dbContextGregDate.hour ) change = YES;
    }
    
    return change;
}



#pragma mark - implementation main

- (id)init
{
    self = [super init];
    if ( self )
    {
        //_inUseCount = 1;
        _dbRange = SWDatabaseContextTimeRangeUnknown;
    }
    return self;
}

- (void)dealloc
{
    [self closeContext];
}


- (void)setName:(NSString*)name range:(SWDatabaseContextTimeRange)range referenceTime:(CFAbsoluteTime)absoluteTime
{
    BOOL needsUpdate = [self _shouldBeUpdatedForName:name range:range referenceTime:absoluteTime];
    
    if ( !needsUpdate )
        return;
    
    SWDatabaseManager *dbManager = [SWDatabaseManager defaultManager];
    
    [dbManager dispatchNowBlock:^
    {
        [_db close];
        _db = nil;
    }];

    _getGregorianDateForReferenceTime_outGregDate_outGregWeek(absoluteTime, &_dbContextGregDate, &_dbContextWeek);
    NSString *keyName = _keyStringForName_Range_gregDate_week( name, range, _dbContextGregDate, _dbContextWeek);
    _keyName = keyName;
    _dbRange = range;
    
    [dbManager dispatchNowBlock:^
    {
        NSAssert( _db == nil, @"No es pot si ja tenim una db oberta" );

        NSString *basePath = [filesModel().filePaths databasesPath];
        NSString *extendedName = [keyName stringByAppendingPathExtension:@"db"];
        NSString *path = [basePath stringByAppendingPathComponent:extendedName];
        _path = path;
    }];
}


- (void)setWriteFlag:(BOOL)writeFlag
{
    SWDatabaseManager *dbManager = [SWDatabaseManager defaultManager];
    
    [dbManager dispatchNowBlock:^
    {
        _writeFlag = writeFlag;
    }];
}


- (BOOL)isLoaded
{
    BOOL isLoaded = ( _db != nil );    // <- totes les asignacions a _db es fan sincrones, per tant es segur fer això en qualsevol thread
    return isLoaded;

//    __block BOOL isLoaded = NO;
//    SWDatabaseManager *dbManager = [SWDatabaseManager defaultManager];
//    [dbManager dispatchNowBlock:^  // <-- synchronous call
//    {
//        isLoaded = (_db != nil );
//    }];
//    
//    return isLoaded;
}


- (void)databaseDidLoad
{
}


// will be called on a serial queue
- (FMDatabase*)database
{
    SWDatabaseManager *dbManager = [SWDatabaseManager defaultManager];
    
    __block FMDatabase *db = nil;
    [dbManager dispatchNowBlock:^  // <-- synchronous call
    {
        if ( _db == nil)
        {
            //[self _loadDatabase];

            BOOL canOpen = _writeFlag || [[NSFileManager defaultManager] fileExistsAtPath:_path] ;
            if ( canOpen )
            {
                _db = [FMDatabase databaseWithPath:_path];
                [_db open];
            
                [self databaseDidLoad];
            
                BOOL hadError = [_db hadError];
                if ( !hadError )
                {
                    NSString *dbName = [_db.databasePath lastPathComponent];
                    dispatch_async(dispatch_get_main_queue(), ^
                    {
                        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                        NSDictionary *userInfo = @{SWDatabaseContextDBNameKey:dbName};
                        [nc postNotificationName:SWDatabaseContextDidOpenDatabaseNotification object:nil userInfo:userInfo];
                    });
                }
                else
                {
                    _db = nil;
                }
            }
        }
        db = _db;
    }];
    
    return db;
}


- (void)closeContext
{
    SWDatabaseManager *dbManager = [SWDatabaseManager defaultManager];
    [dbManager dispatchNowBlock:^  // <-- synchronous call
    {
        if ( _db )
        {
            NSString *dbName = [_db.databasePath lastPathComponent];
            [_db close];
            _db = nil;
        
            dispatch_async(dispatch_get_main_queue(), ^
            {
                NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                NSDictionary *userInfo = @{SWDatabaseContextDBNameKey:dbName};
                [nc postNotificationName:SWDatabaseContextDidCloseDatabaseNotification object:nil userInfo:userInfo];
            });
        }
    }];
    
    if ( [_delegate respondsToSelector:@selector(databaseContextDidClose:)] )
        [_delegate databaseContextDidClose:self];
}




//#pragma mark - observerRetain
//
//- (int)inUseRetainCount
//{
//    return _inUseCount;
//}
//
//- (void)inUseRetain
//{
//    _inUseCount += 1;
//}
//
//- (void)inUseRelease
//{
//    NSAssert(_inUseCount>0, @"oops!, upaired observer releases" );
//    
//    _inUseCount -= 1;
//    if ( _inUseCount == 0 )
//        [self close];
//}




@end

