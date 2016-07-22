//
//  SWHistoAlarmsDatabaseContext.m
//  HmiPad
//
//  Created by Joan Lluch on 16/04/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//


#import "SWHistoAlarmsDatabaseContext.h"
#import "SWEvent.h"

#import "time.h"


NSString* kSWHistoAlarmsDidAddEventNotification = @"kSWHistoAlarmsDidAddEventNotification";
NSString* kSWHistoAlarmsDidFetchEventsNotification = @"kSWHistoAlarmsDidFetchEventsNotification";


@interface SWHistoAlarmsDatabaseContext()
{
    NSArray *_allFieldNames;
    NSString *_createArgs;
    NSString *_updateArgs;
    NSString *_updateArgsQ;
}

@end


@implementation SWHistoAlarmsDatabaseContext


- (void)databaseDidLoad
{
    [super databaseDidLoad];
//    [self.database executeUpdate:@"CREATE TABLE IF NOT EXISTS historian "
//                    "(timestamp DOUBLE UNIQUE, active INTEGER, label TEXT, comment TEXT);" ];
    
    SWDatabaseManager *dbManager = [SWDatabaseManager defaultManager];
    
    [dbManager transactionWithContext:self nowBlock:^(FMDatabase *db, BOOL *rollback)
    {
        BOOL success = YES;
    
        _allFieldNames = @[@"timestamp",@"timestampStr",@"active",@"label",@"comment"];
        _createArgs = @"timestamp DOUBLE, timestampStr TEXT, active INTEGER, label TEXT, comment TEXT";
        _updateArgs = @"timestamp, timestampStr, active, label, comment";
        _updateArgsQ = @"?,?,?,?,?";
        
        NSString *q = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS historian (%@);", _createArgs ];
        BOOL done = [db executeUpdate:q];
        success = success && done;
        
        q = [NSString stringWithFormat:@"CREATE UNIQUE INDEX IF NOT EXISTS timeIndex ON historian (timestamp);"];
        done = [db executeUpdate:q];
        success = success && done;
        
        
        if ( success  )
        {
            [self _rebuildIfNeededWithDatabase:db];
        }
        
    }];
    
    
}


- (void)addEvent:(SWEvent*)event completion:(void (^)(BOOL success))block;
{
    SWDatabaseManager *dbManager = [SWDatabaseManager defaultManager];
    
    double timeStamp = event.timeStamp + NSTimeIntervalSince1970;
    BOOL active = event.active;
    NSString *label = event.labelText;
    NSString *comment = event.commentText;
    NSString *timeStr = [event getTimeStampString];
    
    [dbManager transactionWithContext:self asyncBlock:^(FMDatabase *db, BOOL *rollback)
    {
        NSString *q = [NSString stringWithFormat:@"INSERT INTO historian (%@) VALUES (%@)", _updateArgs, _updateArgsQ];
        BOOL success = [db executeUpdate:q, @(timeStamp), timeStr, @(active), label, comment];
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (block)
                block(success);
            
            if ( success )
            {
                NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                [nc postNotificationName:kSWHistoAlarmsDidAddEventNotification object:self];
            }
        });
    }];
}


- (void)fetchEventsInRange:(NSRange)range filterString:(NSString*)filterString completion:( void (^)(NSArray *events, NSInteger totalRows))block
{
    if ( filterString.length == 0 ) [self _fetchEventsInRange:range completion:block];
    else [self _fetchEventsWithFilterString:filterString completion:block];
}


- (void)_fetchEventsInRange:(NSRange)range completion:( void (^)(NSArray *events, NSInteger totalRows))block
{
    SWDatabaseManager *dbManager = [SWDatabaseManager defaultManager];
    
    [dbManager transactionWithContext:self asyncBlock:^(FMDatabase *db, BOOL *rollback)
    {
        NSMutableArray *events = [NSMutableArray array];
        NSInteger totalRows = 0;
        NSString *q = nil;
        
        // get total rows
        totalRows = (long)[db lastInsertRowId];
        if ( totalRows == 0 )
        {
            q = [NSString stringWithFormat:@"SELECT MAX(rowid) FROM historian"];
            
            FMResultSet *s5 = nil;
            s5 = [db executeQuery:q];
            if ( [s5 next] )
            {
                SInt64 row = [s5 longLongIntForColumnIndex:0];
                totalRows = (long)row;
            }
        }
    
        // Select
        q = [NSString stringWithFormat:@"SELECT rowid,* FROM historian"
            " WHERE (rowid>=%lu AND rowid<%lu)"
            " ORDER BY rowid",
             (unsigned long)range.location+1, (unsigned long)(range.location+range.length+1)];
        
        FMResultSet *s4 = nil;
        s4 = [db executeQuery:q];
    
        NSInteger index = 0;
        while ( [s4 next] )
        {
            SInt64 row = [s4 longLongIntForColumn:@"rowid"];
            NSInteger foundIndex = (long)(row-1)-range.location;
            
            double time = [s4 doubleForColumn:@"timestamp"];
            time = time-NSTimeIntervalSince1970;
            
            BOOL active = [s4 boolForColumn:@"active"];
            NSString *label = [s4 stringForColumn:@"label"];
            NSString *comment = [s4 stringForColumn:@"comment"];
            
            SWEvent *event = [[SWEvent alloc] initWithLabel:label comment:comment active:active timeStamp:time];
            
            while ( foundIndex > index )
            {
                [events addObject:[NSNull null]];
                index += 1;
            }
            
            [events addObject:event];
            index += 1;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (block)
                block( events, totalRows );
            
            if ( NO )
            {
                NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                [nc postNotificationName:kSWHistoAlarmsDidFetchEventsNotification object:self];
            }
        });
    }];
}


- (void)_fetchEventsWithFilterString:(NSString*)filterString completion:( void (^)(NSArray *events, NSInteger totalRows))block
{
    SWDatabaseManager *dbManager = [SWDatabaseManager defaultManager];
    
    [dbManager transactionWithContext:self asyncBlock:^(FMDatabase *db, BOOL *rollback)
    {
        NSMutableArray *events = [NSMutableArray array];
        NSInteger totalRows = 0;
        NSString *q = nil;
    
        // Select
//        q = [NSString stringWithFormat:@"SELECT rowid,* FROM historian"
//            " WHERE instr(label,'%@')>0 OR instr(comment,'%@')>0"
//            " ORDER BY rowid",
//             filterString, filterString];
        
        q = [NSString stringWithFormat:@"SELECT rowid,* FROM historian"
            " WHERE label LIKE '%%%@%%' OR comment LIKE '%%%@%%' OR timeStampStr LIKE '%%%@%%'"
            " ORDER BY rowid",
             filterString, filterString, filterString];
        
        FMResultSet *s4 = nil;
        s4 = [db executeQuery:q];
    
        NSInteger index = 0;
        while ( [s4 next] )
        {
            double time = [s4 doubleForColumn:@"timestamp"];
            time = time-NSTimeIntervalSince1970;
            
            BOOL active = [s4 boolForColumn:@"active"];
            NSString *label = [s4 stringForColumn:@"label"];
            NSString *comment = [s4 stringForColumn:@"comment"];
            
            SWEvent *event = [[SWEvent alloc] initWithLabel:label comment:comment  active:active timeStamp:time];
            
            [events addObject:event];
            index += 1;
        }
        
        totalRows = index;
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            block( events, totalRows );
        });
    }];
}


- (NSArray*)_columnNamesFromDatabase:(FMDatabase*)db
{
    FMResultSet *s = [db executeQuery:[NSString stringWithFormat:@"PRAGMA table_info(historian);"]];
    
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

    
    // si hem d'afegir, ho fem directament
    for ( NSString *column in toAdd )
    {
        success = success && [db executeUpdate:[NSString stringWithFormat:@"ALTER TABLE historian ADD COLUMN \"%@\" TEXT;", column]];
        // ^ ATENCIO, presuposa que es TEXT
    }
        
    // si hem d'eliminar recreem la taula (despres d'haver afegit)
    if ( toRemove.count > 0 )  // hem de recrear la taula
    {
        {
            success = success && [db executeUpdate:[NSString stringWithFormat:@"ALTER TABLE historian RENAME TO historian_backup;"]];
            success = success && [db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE historian (%@);", _createArgs]];
            success = success && [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO historian SELECT %@ FROM historian_backup;",_updateArgs]];
            success = success && [db executeUpdate:[NSString stringWithFormat:@"DROP TABLE historian_backup;"]];
        }
    }

    if ( success == NO )
    {
        NSLog( @"Error   : %@", [db lastError] );
        NSLog( @"Code    : %d", [db lastErrorCode] );
        NSLog( @"Message : %@", [db lastErrorMessage] );
    }
}



@end

