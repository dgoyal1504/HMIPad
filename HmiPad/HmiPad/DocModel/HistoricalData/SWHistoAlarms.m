//
//  SWHistoAlarmsCenter.m
//  HmiPad
//
//  Created by Joan Lluch on 30/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWHistoAlarms.h"

#import "SWDatabaseManager.h"
#import "SWHistoAlarmsDatabaseContext.h"

#import "SWDocumentModel.h"

#import "SWEvent.h"

@interface SWHistoAlarms()
{
    NSString *_name;
    SWDatabaseContextTimeRange _dbContextRange;
}
@end


@interface SWHistoAlarms()
{
    SWHistoAlarmsDatabaseContext *_dbContextMain;  // <- retenim el contexte principal
}
@end


@implementation SWHistoAlarms

- (id)initInDocumentModel:(SWDocumentModel*)docModel
{
    self = [super initInDocumentModel:docModel];
    if ( self )
    {
        _dbContextRange = SWDatabaseContextTimeRangeMonthly;
    }
    return self;
}


- (NSString *)_baseName
{
    if ( _name == nil )
    {
        NSString *docName = [self.docModel documentName];
        _name = [docName stringByAppendingString:@"_alarms"];
    }
    return _name;
}


- (SWDatabaseContextTimeRange)dbContextRange
{
    return _dbContextRange;
}


- (SWHistoAlarmsDatabaseContext *)dbContextForWriting
{
    CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
    SWHistoAlarmsDatabaseContext *dbContext = [self dbContextForReadingWithReferenceTime:now];
    
    if ( ![dbContext isLoaded] )
    {
        [dbContext setWriteFlag:YES];
    }
    
    return dbContext;
}


- (SWHistoAlarmsDatabaseContext *)dbContextForReadingWithReferenceTime:(CFAbsoluteTime)referenceTime
{
    NSString *name = [self _baseName];
    if ( name == nil )
        return nil;

    NSString *key = [SWDatabaseContext dictionaryKeyForName:name range:_dbContextRange referenceTime:referenceTime];
    SWHistoAlarmsDatabaseContext *dbContext = (id)[self contextForKey:key];
    
    if ( dbContext == nil )
    {
        dbContext = [[SWHistoAlarmsDatabaseContext alloc] init];
        [dbContext setDelegate:self];
        
        [dbContext setName:name range:_dbContextRange referenceTime:referenceTime];
        
        [self addContext:dbContext];  // afegim weak, els que hi ha ja s'eliminaran si no s'utilitzen
    }
    
    return dbContext;
}

@end




@implementation SWHistoAlarms(convenience)


- (void)addEvent:(SWEvent*)event
{
    _dbContextMain = [self dbContextForWriting];
    [_dbContextMain addEvent:event completion:nil];
}

@end
