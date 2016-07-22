//
//  SWHistoValuesDatabaseContext.m
//  HmiPad
//
//  Created by Joan Lluch on 19/04/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWHistoValuesDatabaseContext.h"
//#import "SWValue.h"
//#import "SWDatabaseItem.h"

//static NSString *_rangeSuffixStrings[] = { @"_1", @"_10", @"_100", @"_1000" };
//static double _rangeTriggerIntervals[] = { 1, 10, 100, 1000 };
//
//const int _RangeCount = sizeof(_rangeTriggerIntervals)/sizeof(double);


static NSString *_suffixString = @"_db";
//static double _rangeTriggerIntervals[] = { 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024 };
//
//const int _RangeCount = sizeof(_rangeTriggerIntervals)/sizeof(double);


const int _RangeCount = 16;

@interface SWHistoValuesDatabaseContext()
{
//    SWValue *_lastValue;
    
    NSArray *_allFieldNames;
    NSInteger _valuesCount;
    //NSString *_createTableString;
    //NSString *_updateTableString;
    
    NSString *_createArgs;
    NSString *_updateArgs;
    NSString *_updateArgsQ;
    
    CFAbsoluteTime _lastTimeStamps[_RangeCount];
    CFAbsoluteTime _lastAbsoluteTimeStamp;
}

@end



#define dataSourceDef "dataSource"
#define TRIGGERINSERT 0.5

#define ExtraFields 3
#define timeRangeDef "timeRange"
#define timeStampDef "timeStamp"
#define timeStampStrDef "timeStampStr"

@implementation SWHistoValuesDatabaseContext

- (void)setFieldNames:(NSArray*)fieldNames valuesCount:(NSInteger)valuesCount
{
    SWDatabaseManager *dbManager = [SWDatabaseManager defaultManager];

    [dbManager dispatchNowBlock:^
    {
        double dPast = [[NSDate distantPast] timeIntervalSinceReferenceDate];
        for ( int i=0 ; i<_RangeCount ; i++ ) _lastTimeStamps[i] = dPast + NSTimeIntervalSince1970;
        
        [self _setupArgumentsWithFieldNames:fieldNames valuesCount:valuesCount];
    }];
}


- (void)databaseDidLoad
{
    [super databaseDidLoad];
    
    SWDatabaseManager *dbManager = [SWDatabaseManager defaultManager];
    
    [dbManager transactionWithContext:self nowBlock:^(FMDatabase *db, BOOL *rollback)
    {
        BOOL success = YES;
        BOOL useExisting = (_allFieldNames.count == 0);
    
        if ( useExisting )
        {
            NSArray *columnNames = [self _columnNamesFromDatabase:db];
            [self _setupArgumentsWithExistingFieldNames:columnNames];
        }
        
        
        NSString *q = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS " dataSourceDef "%@ (%@);", _suffixString, _createArgs];
        BOOL done = [db executeUpdate:q];
        success = success && done;
        
        q = [NSString stringWithFormat:@"CREATE UNIQUE INDEX IF NOT EXISTS timeIndex ON " dataSourceDef "%@ (" timeRangeDef ", " timeStampDef ");", _suffixString];
        done = [db executeUpdate:q];
        success = success && done;
 
        if ( success  )
        {
            [self _rebuildIfNeededWithDatabase:db];
        }
    }];
}


- (void)rebuildWithFieldNames:(NSArray*)fieldNames valuesCount:(NSInteger)valuesCount
{
    SWDatabaseManager *dbManager = [SWDatabaseManager defaultManager];
    
//    [dbManager dispatchNowBlock:^
//    {
//        [self _setupArgumentsWithFieldNames:fieldNames];
//    }];
    
    
    [dbManager transactionWithContext:self asyncBlock:^(FMDatabase *db, BOOL *rollback)
    {
        [self _setupArgumentsWithFieldNames:fieldNames valuesCount:valuesCount];
        [self _rebuildIfNeededWithDatabase:db];
    }];
}


- (void)addValues:(NSArray*)values absoluteTime:(CFAbsoluteTime)timeStamp
{
    static CFDateFormatterRef staticDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
            staticDateFormatter = CFDateFormatterCreate( NULL, NULL, kCFDateFormatterNoStyle, kCFDateFormatterNoStyle );
            CFDateFormatterSetFormat( staticDateFormatter, CFSTR("yy-MM-dd HH:mm:ss") );
        });

    double timeStamp70 = timeStamp + NSTimeIntervalSince1970;
 
    // no afegim si fa poc temps que ho hem fet
    if ( timeStamp70 - _lastAbsoluteTimeStamp < TRIGGERINSERT)
        return;     // <- do not honor too quick inserts 
    
    _lastAbsoluteTimeStamp = timeStamp70;

    SWDatabaseManager *dbManager = [SWDatabaseManager defaultManager];
    
    [dbManager transactionWithContext:self asyncBlock:^(FMDatabase *db, BOOL *rollback)
    {
        //NSArray *valuesArray = [ @[@(timeStamp)] arrayByAddingObjectsFromArray:values];
        //if ( valuesArray.count < _fieldNames.count )
        
        
        NSInteger valuesCount = values.count;
        if (  valuesCount > _valuesCount )
        {
            [self _setupArgumentsWithFieldNames:_allFieldNames valuesCount:valuesCount];
            [self _rebuildIfNeededWithDatabase:db];
        }
        
        //double timeStamp70 = timeStamp + NSTimeIntervalSince1970;
        NSMutableArray *valuesArray = [NSMutableArray array];
        NSInteger namesCount = _allFieldNames.count;
        
        if ( namesCount > 0)
            [valuesArray addObject:@(0)];
        
        if ( namesCount > 1 )
            [valuesArray addObject:@(timeStamp70)];
        
        if ( namesCount > 2 )
        {
            NSString *dateFormatterStr = CFBridgingRelease(CFDateFormatterCreateStringWithAbsoluteTime(NULL, staticDateFormatter, timeStamp));
            [valuesArray addObject:dateFormatterStr];
        }
        
        for ( NSInteger i=0 ; i<namesCount-ExtraFields; i++ )
        {
            id value;
            if ( i < valuesCount ) value = [values objectAtIndex:i];
            else value = [NSNull null];
            
            [valuesArray addObject:value];
        }
        
        BOOL success = YES;
        NSInteger rangeIndex = 0;
 
        for ( NSInteger i=0 ; i<_RangeCount ; i++ )
        {
            if ( i == 0 || timeStamp70 - _lastTimeStamps[i] >= (1<<i) /*_rangeTriggerIntervals[i]*/ )
            {
                _lastTimeStamps[i] = timeStamp70;
                rangeIndex = i;
            }
        }
        
        [valuesArray replaceObjectAtIndex:0 withObject:@(rangeIndex)];

        NSString *q = [NSString stringWithFormat:@"INSERT OR REPLACE INTO " dataSourceDef "%@ (%@) VALUES (%@)", _suffixString, _updateArgs, _updateArgsQ];
//       //NSLog( @"-- %@\n%g", q, [valuesArray[2] doubleValue] );
        BOOL done = [db executeUpdate:q withArgumentsInArray:valuesArray];
        success = success && done;

        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            (void)success;
            //NSLog( @"completed with success A: %d", success );
        });
    }];
}


- (void)fetchPointsDatasInRange:(SWPlotRange)range completion:(void(^)(NSArray *pointDatas, double factor))block
{
    SWDatabaseManager *dbManager = [SWDatabaseManager defaultManager];

    [dbManager transactionWithContext:self asyncBlock:^(FMDatabase *db, BOOL *rollback)
    {
        NSInteger fieldsCount = _allFieldNames.count;
        
        // creem un array amb els NSDatas que tornarem
        
        NSMutableArray *pointDatas = [NSMutableArray array];
        for ( NSInteger i=0 ; i<fieldsCount-ExtraFields ; i++ )
        {
            NSMutableData *data = [NSMutableData data];
            [pointDatas addObject:data];
        }
        
        // ajustem el interval amb floor, ceil per evitar problemes de precisio
        
        double rangeExtension = (range.max-range.min)/2;
        
        SWPlotRange efRange;
        efRange.min = floor( 1000*(range.min-rangeExtension) )/1000;   // rounded down to the nearest milisecond
        efRange.max = ceil( 1000*(range.max+rangeExtension) )/1000;    // rounded up to the nearest milisecond
        
        // determinem el suffix de la taula que ens interessa
        
        double rangeGap = efRange.max - efRange.min;
        NSInteger rangeIndex=0;
        while ( rangeIndex < _RangeCount-1 && rangeGap > 1000.0*(1<<rangeIndex) /*_rangeTriggerIntervals[rangeIndex]*/ ) rangeIndex++ ;

        // seleccionem els valors en el rang
        
        NSString *q = nil;
        q = [NSString stringWithFormat:@"SELECT rowid,* FROM " dataSourceDef "%@"
            " WHERE  " timeRangeDef ">=%ld AND " timeStampDef ">=%1.15g AND " timeStampDef "<=%1.15g"
            " ORDER BY " timeStampDef ";",
            _suffixString, (long)rangeIndex, efRange.min+NSTimeIntervalSince1970, efRange.max+NSTimeIntervalSince1970];
    
        FMResultSet *s3 = nil;
        s3 = [db executeQuery:q];
        
        BOOL hasFirstRow = NO;
        //BOOL hasLastRow = NO;
        SInt64 firstRowId;
        SInt64 lastRowId;
        while ( [s3 next] )
        {
            double time = [s3 doubleForColumn:@ timeStampDef ];
            time = time-NSTimeIntervalSince1970;
            
            for ( NSInteger i=0 ; i<fieldsCount-ExtraFields ; i++ )
            {
                NSString *fieldName = [_allFieldNames objectAtIndex:i+ExtraFields];
                double fieldValue = [s3 doubleForColumn:fieldName];
                SWPlotPoint plotPoint = { time, fieldValue };
                
                NSMutableData *data = [pointDatas objectAtIndex:i];
                [data appendBytes:&plotPoint length:sizeof(SWPlotPoint)];
                if ( !hasFirstRow ) [data appendBytes:&plotPoint length:sizeof(SWPlotPoint)];  // deixem espai per el punt anterior
            }
            
            lastRowId = [s3 longLongIntForColumn:@"rowid"];
            if ( !hasFirstRow) hasFirstRow = YES, firstRowId = lastRowId;
        }
        
        // si no hem trobat valors en el rang, seleccionem la ultima fila
        
        if ( !hasFirstRow )
        {
            firstRowId = [db lastInsertRowId];
            lastRowId = firstRowId-1;
        }
        
        if ( hasFirstRow )
        {
        
        //BOOL hasNextRow = NO;
        
        q = [NSString stringWithFormat:@"SELECT rowid,* FROM " dataSourceDef "%@"
            " WHERE ((rowid>%lld AND rowid<%lld) OR (rowid>%lld AND rowid<%lld)) AND " timeRangeDef ">=%ld"
            " ORDER BY rowid",
            _suffixString, firstRowId-12, firstRowId, lastRowId, lastRowId+12, (long)rangeIndex];
        
        FMResultSet *s4 = nil;
        s4 = [db executeQuery:q];
    
        while ( [s4 next] )
        {
            double time = [s4 doubleForColumn:@ timeStampDef ];
            time = time-NSTimeIntervalSince1970;
                
            SInt64 row = [s4 longLongIntForColumn:@"rowid"];
        
            for ( NSInteger i=0 ; i<fieldsCount-ExtraFields ; i++ )
            {
                NSString *fieldName = [_allFieldNames objectAtIndex:i+ExtraFields];
                double fieldValue = [s4 doubleForColumn:fieldName];
                SWPlotPoint plotPoint = { time, fieldValue };
                
                NSMutableData *data = [pointDatas objectAtIndex:i];
                
                if ( row < firstRowId )
                {
                    // anem matxacant el primer punt mentre no hem arribat al firstRowId
                    long count = [data length]/sizeof(SWPlotPoint);
                    if ( count > 0 ) *(SWPlotPoint *)[data mutableBytes] = plotPoint;   // modifiquem el primer punt
                    else [data appendBytes:&plotPoint length:sizeof(SWPlotPoint)];      // o afegim un primer punt
                }
                    
                if ( row > lastRowId )
                {
                    // quan trobem un punt despres del firstRowId l'anotem
                    [data appendBytes:&plotPoint length:sizeof(SWPlotPoint)];  // afegim el ultim punt
                }
            }
            
            if ( row > lastRowId )  // <-- no volem continuar mes enlla del primer que ha seleccionat
                break;
        }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
           // NSLog( @"PointDatasSize = %lu", [(NSData*)pointDatas[0] length] / sizeof(SWPlotPoint) );
           
//            {
//                NSData *plotValuesx = pointDatas[0];
//                int countx = [plotValuesx length]/sizeof(SWPlotPoint);
//                SWPlotPoint *pointsx = (SWPlotPoint*)[plotValuesx bytes];
//                if ( countx > 0)
//                NSLog( @"fetchPointsDatasInRange: %@", [NSDate dateWithTimeIntervalSinceReferenceDate:pointsx[countx-1].x] );
//            }
           
            block( pointDatas, (1<<rangeIndex) );
        });
    
    }];
}


#pragma mark - private


- (void)_setupArgumentsWithFieldNames:(NSArray*)fNames valuesCount:(NSInteger)valuesCount
{
    NSMutableString *createArgs = [NSMutableString string];
    NSMutableString *updateArgs = [NSMutableString string];
    NSMutableString *updateArgsQ = [NSMutableString string];
        
//    [createArgs appendString:@ timeStampDef " DOUBLE UNIQUE"];
    [createArgs appendString:@ timeRangeDef " INTEGER, " timeStampDef " DOUBLE, " timeStampStrDef " TEXT"];
    [updateArgs appendString:@ timeRangeDef ", " timeStampDef ", " timeStampStrDef];
    [updateArgsQ appendString:@"?, ?, ?"];
    
    NSMutableArray *fieldNames = [NSMutableArray array];
    
    NSInteger namesCount = fNames.count;
    NSInteger totalCount = valuesCount > namesCount ? valuesCount : namesCount;
    for ( NSInteger i=0 ; i<totalCount ; i++ )
    {
        NSString *f;
        if ( i < namesCount ) f = [fNames objectAtIndex:i];
        else f = [NSString stringWithFormat:@"field_%ld", (long)i];
    
        NSString *escaped = [f stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *fieldName = [ @"c_" stringByAppendingString:escaped];
        
        [fieldNames addObject:fieldName];
        [createArgs appendFormat:@", \"%@\" %@", fieldName, @"TEXT"];
        [updateArgs appendFormat:@", \"%@\"", fieldName];
        [updateArgsQ appendString:@", ?"];
    }
        
    _allFieldNames = [ @[ @ timeRangeDef, @ timeStampDef, @ timeStampStrDef ] arrayByAddingObjectsFromArray:fieldNames];
    _valuesCount = valuesCount;
    _createArgs = [NSString stringWithString:createArgs];
    _updateArgs = [NSString stringWithString:updateArgs];
    _updateArgsQ = [NSString stringWithString:updateArgsQ];
}


- (void)_setupArgumentsWithExistingFieldNames:(NSArray*)fNames
{
    NSMutableString *createArgs = [NSMutableString string];
    NSMutableString *updateArgs = [NSMutableString string];
    NSMutableString *updateArgsQ = [NSMutableString string];
    
    [createArgs appendString:@ timeRangeDef " INTEGER, " timeStampDef " DOUBLE, " timeStampStrDef " TEXT" ];
    [updateArgs appendString:@ timeRangeDef ", " timeStampDef ", " timeStampStrDef ];
    [updateArgsQ appendString:@"?, ?, ?"];
    
    NSMutableArray *fieldNames = [NSMutableArray array];
    
    NSInteger namesCount = fNames.count;
    
//    for ( NSInteger i=ExtraFields ; i<namesCount ; i++ )
//    {
//        NSString *fieldName = [fNames objectAtIndex:i];
//        
//        [fieldNames addObject:fieldName];
//        [createArgs appendFormat:@", \"%@\" %@", fieldName, @"TEXT"];
//        [updateArgs appendFormat:@", \"%@\"", fieldName];
//        [updateArgsQ appendString:@", ?"];
//    }
    
    
    for ( NSInteger i=0 ; i<namesCount ; i++ )
    {
        NSString *fieldName = [fNames objectAtIndex:i];
        
        if ( NSOrderedSame == [fieldName caseInsensitiveCompare:@ timeRangeDef] ||
            NSOrderedSame == [fieldName caseInsensitiveCompare:@ timeStampDef] ||
            NSOrderedSame == [fieldName caseInsensitiveCompare:@ timeStampStrDef] )
        {
            continue;
        }
        
        [fieldNames addObject:fieldName];
        [createArgs appendFormat:@", \"%@\" %@", fieldName, @"TEXT"];
        [updateArgs appendFormat:@", \"%@\"", fieldName];
        [updateArgsQ appendString:@", ?"];
    }
    
    _allFieldNames = [ @[ @ timeRangeDef, @ timeStampDef, @ timeStampStrDef ] arrayByAddingObjectsFromArray:fieldNames];
    _valuesCount = namesCount;
    _createArgs = [NSString stringWithString:createArgs];
    _updateArgs = [NSString stringWithString:updateArgs];
    _updateArgsQ = [NSString stringWithString:updateArgsQ];
}


- (NSArray*)_columnNamesFromDatabase:(FMDatabase*)db
{
    FMResultSet *s = [db executeQuery:[NSString stringWithFormat:@"PRAGMA table_info(" dataSourceDef "%@);", _suffixString ]];
    
    NSMutableArray *currentColumnNames = [NSMutableArray array];
    while ([s next])
    {
        NSString *name = [s stringForColumn:@"name"];
        [currentColumnNames addObject:name];
    }
    
    return currentColumnNames;
}



- (void)_rebuildIfNeededWithDatabase:(FMDatabase*)db
{
    BOOL success = YES;
    
    NSSet *currentColumnNames = [NSSet setWithArray:[self _columnNamesFromDatabase:db]];
    NSSet *targetColumnNames = [NSSet setWithArray:_allFieldNames];
    
    // eliminem del target les que ja hi eren al current, les que queden son les que s'han d'agefir
    NSMutableSet *toAdd = [NSMutableSet setWithSet:targetColumnNames];
    [toAdd minusSet:currentColumnNames];
    
    // elimimen del current les que hi ha a target, les que queden son les que s'han d'eliminar
    NSMutableSet *toRemove = [NSMutableSet setWithSet:currentColumnNames];
    [toRemove minusSet:targetColumnNames];

    
//    for ( int i=0 ; i<_RangeCount ; i++ )
//    {
//        NSString *suffix = _rangeSuffixStrings[i];
    
        // si hem d'afegir, ho fem directament
        for ( NSString *column in toAdd )
        {
            success = success && [db executeUpdate:[NSString stringWithFormat:@"ALTER TABLE " dataSourceDef "%@ ADD COLUMN \"%@\" TEXT;", _suffixString, column]];
        }
        
        // si hem d'eliminar recreem la taula (despres d'haver afegit)
        if ( toRemove.count > 0 )  // hem de recrear la taula
        {
            if ( NO )
            {
                // according to http://www.sqlite.org/faq.html#q11
                success = success && [db executeUpdate:[NSString stringWithFormat:@"CREATE TEMPORARY TABLE " dataSourceDef "%@_backup (%@);",_suffixString,_createArgs]];
                success = success && [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO " dataSourceDef "%@_backup SELECT %@ FROM " dataSourceDef "%@;",_suffixString,_updateArgs,_suffixString]];
                success = success && [db executeUpdate:[NSString stringWithFormat:@"DROP TABLE " dataSourceDef "%@;",_suffixString]];
                success = success && [db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE " dataSourceDef "%@ (%@);",_suffixString,_createArgs]];
                success = success && [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO " dataSourceDef "%@ SELECT %@ FROM " dataSourceDef "%@_backup;",_suffixString,_updateArgs,_suffixString]];
                success = success && [db executeUpdate:[NSString stringWithFormat:@"DROP TABLE " dataSourceDef "%@_backup;",_suffixString]];
            }
            else
            {
                // I guess this is faster (?)
                success = success && [db executeUpdate:[NSString stringWithFormat:@"ALTER TABLE " dataSourceDef "%@ RENAME TO " dataSourceDef "%@_backup;", _suffixString, _suffixString]];
                success = success && [db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE " dataSourceDef "%@ (%@);",_suffixString, _createArgs]];
                success = success && [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO " dataSourceDef "%@ SELECT %@ FROM " dataSourceDef "%@_backup;",_suffixString,_updateArgs,_suffixString]];
                success = success && [db executeUpdate:[NSString stringWithFormat:@"DROP TABLE " dataSourceDef "%@_backup;",_suffixString]];
            }
        }
//    }
    
    if ( success == NO )
    {
        NSLog( @"Error   : %@", [db lastError] );
        NSLog( @"Code    : %d", [db lastErrorCode] );
        NSLog( @"Message : %@", [db lastErrorMessage] );
    }
}


@end
