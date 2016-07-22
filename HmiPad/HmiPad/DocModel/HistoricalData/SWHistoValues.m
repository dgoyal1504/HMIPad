//
//  SWHistoAlarmsCenter.m
//  HmiPad
//
//  Created by Joan Lluch on 30/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWHistoValues.h"

@interface SWHistoValues()<SWDatabaseContextDelegate>
@end


@interface SWHistoValues()
{
    __weak SWDocumentModel *_docModel;
    NSMapTable *_contextsDict;
}
@end

@implementation SWHistoValues

- (id)initInDocumentModel:(SWDocumentModel*)docModel
{
    self = [super init];
    {
        _docModel = docModel;
    }
    return self;
}


# pragma mark - Methods


- (SWHistoValuesDatabaseContext *)dbContextForWritingWithName:(NSString*)name range:(SWDatabaseContextTimeRange)timeRange fieldNames:(NSArray*)fields valuesCount:(NSInteger)valuesCount
{
    CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
    NSString *key = [SWDatabaseContext dictionaryKeyForName:name range:timeRange referenceTime:now];
    
    SWHistoValuesDatabaseContext *dbContext = (id)[self contextForKey:key];
    
    if ( dbContext == nil )
    {
        dbContext = [[SWHistoValuesDatabaseContext alloc] init];
        [dbContext setDelegate:self];
        
        [dbContext setName:name range:timeRange referenceTime:now];
        [dbContext setFieldNames:fields valuesCount:valuesCount];
       // [dbContext setWriteFlag:YES];
        
        [self addContext:dbContext];  // afegim weak, els que hi ha ja s'eliminaran si no s'utilitzen
    }
    
    if ( ![dbContext isLoaded] )
    {
        [dbContext setWriteFlag:YES];
    }
    
    return dbContext;
}


- (SWHistoValuesDatabaseContext *)dbContextForReadingWithName:(NSString*)name range:(SWDatabaseContextTimeRange)range referenceTime:(CFAbsoluteTime)referenceTime
{
    NSString *key = [SWDatabaseContext dictionaryKeyForName:name range:range referenceTime:referenceTime];
    SWHistoValuesDatabaseContext *dbContext = (id)[self contextForKey:key];
    
    if ( dbContext == nil )
    {
        dbContext = [[SWHistoValuesDatabaseContext alloc] init];
        [dbContext setDelegate:self];
        
        [dbContext setName:name range:range referenceTime:referenceTime];
        
        [self addContext:dbContext];  // afegim weak, els que hi ha ja s'eliminaran si no s'utilitzen
    }
    
    return dbContext;
}


# pragma mark - Database Context delegate

- (void)databaseContextDidClose:(SWDatabaseContext *)dbContext
{
    [self removeContext:dbContext];
}


# pragma mark - Private

- (NSMapTable*)_contextsDict
{
    if ( _contextsDict == nil )
        _contextsDict = [[NSMapTable alloc] initWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory capacity:0];
    
    return _contextsDict;
}

@end

# pragma mark - Public

@implementation SWHistoValues(subclassingHooks)

- (SWDatabaseContext*)contextForKey:(NSString*)key
{
    SWDatabaseContext *dbContext = [_contextsDict objectForKey:key];
    return dbContext;
}


- (void)addContext:(SWDatabaseContext*)dbContext
{
    if ( dbContext == nil )
        return;
    
    NSString *key = [dbContext keyName];
    [[self _contextsDict] setObject:dbContext forKey:key];
}


- (void)removeContext:(SWDatabaseContext *)dbContext
{
    if ( dbContext == nil )
        return;
    
    NSString *key = [dbContext keyName];
    [_contextsDict removeObjectForKey:key];
}


#pragma mark More

//// SWHistoTable
//
//// SWHistoRow
//
//// metodes de SWDBHistoTable
//
//- (NSArray*)histoRowsAtIndexes:(NSIndexSet*)indexes;
//- (SWHistoRow*)histoRowAtIndex:(NSinteger)indx;
//- (NSinteger)numberOfRows;
//
//// delegats
//- (void)histoTableDidBeginUpdates:(SWHistoTable*)histoTable;
//
//- (void)histoTable:(SWHistoTable*)histoTable didUpdateRows:(NSIndexSet*)indexes;
//
//- (void)histoTable:(SWHistoTable*)histoTable didInsertRow:(SWHistoRow*)histoRow atIndex:(NSInteger)indx;
//- (void)histoTable:(SWHistoTable*)histoTable didDeleteRow:(SWHistoRow*)histoRow atIndex:(NSInteger)indx;
//- (void)histoTable:(SWHistoTable*)histoTable didUpdateRow:(SWHistoRow*)histoRow atIndex:(NSInteger)indx;
//
//- (void)histoTableDidEndUpdates:(SWHistoTable*)histoTable;
//
//// begin updates
//// did update rows:(NSIndexSet)





// end updates


@end
