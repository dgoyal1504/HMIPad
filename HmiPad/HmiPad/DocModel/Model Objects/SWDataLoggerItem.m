//
//  SWBackgroundItemDatabase.m
//  HmiPad
//
//  Created by Joan Lluch on 18/04/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWDataLoggerItem.h"
#import "SWPropertyDescriptor.h"
//#import "SWEnumTypes.h"

#import "SWDocumentModel.h"
#import "SWValue.h"

#import "SWHistoValues.h"
#import "SWHistoValuesDatabaseContext.h"

@interface SWDataLoggerItem()
{
    SWHistoValuesDatabaseContext *_dbContext;
    NSInteger _valuesCount;
    BOOL _isWaitingBlock;
}

@end


@implementation SWDataLoggerItem
static SWObjectDescription *_objectDescription = nil;

+ (SWObjectDescription *)objectDescription
{
    if(_objectDescription == nil) {
        _objectDescription = [[SWObjectDescription alloc] initWithObjectClass:[self class]];
    }
    return _objectDescription;
}

+ (NSString*)defaultIdentifier
{
    return @"dataLog";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"DATA LOGGER", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
    
        [SWPropertyDescriptor propertyDescriptorWithName:@"databaseTimeRange" type:SWTypeEnumDatabaseTimeRange
            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWDatabaseTimeRangeMonthly]],
    
        [SWPropertyDescriptor propertyDescriptorWithName:@"databaseName" type:SWTypeString
            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithString:@""]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"databaseFile" type:SWTypeString
            propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithString:@""]],

        [SWPropertyDescriptor propertyDescriptorWithName:@"fieldNames" type:SWTypeArray
            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithArray:@[]]],

        [SWPropertyDescriptor propertyDescriptorWithName:@"values" type:SWTypeArray
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithArray:@[]]],
    
        nil
    ];
}


// #pragma mark init / dealloc / observer retain

- (id)initInDocument:(SWDocumentModel *)docModel
{
    self = [super initInDocument:docModel];
    if ( self )
    {
        [self.values observerCountRetainBy:1];
    }
    return self;
}

- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super initWithQuickCoder:decoder];
    if (self) 
    {
        [self _observerRetainAfterDecode];
    }
    return self;
}

- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString *)ident parentObject:(id<SymbolicCoding>)parent
{
    self = [super initWithSymbolicCoder:decoder identifier:ident parentObject:parent];
    if ( self )
    {
        [self _observerRetainAfterDecode];
    }
    return self;
}



- (void)putToSleep
{
    if ( !self.isAsleep )
        [self.values observerCountReleaseBy:1];
    
    [super putToSleep];
    
    _dbContext = nil;
}

- (void)awakeFromSleepIfNeeded
{
    BOOL isAsleep = self.isAsleep;
    [super awakeFromSleepIfNeeded];
    
    if (isAsleep)
        [self.values observerCountRetainBy:1];
}

- (void)dealloc
{
    if (!self.isAsleep)
        [self.values observerCountReleaseBy:1];
    
    //self.dbContext = nil;
}


#pragma mark - Properties

- (SWValue*)databaseTimeRange
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+0];
}

- (SWValue*)databaseName
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+1];
}

- (SWValue*)databaseFile
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+2];
}

- (SWValue*)fieldNames
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+3];
}

- (SWExpression*)values
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+4];
}


#pragma mark - Private

- (void)_performDelayedBlock:( void(^)(void) )block
{
    if ( _isWaitingBlock == NO )
    {
        _isWaitingBlock = YES;
        dispatch_async(dispatch_get_main_queue(), ^
        {
            _isWaitingBlock = NO;
            block();
        });
    }
}


- (void)_observerRetainAfterDecode
{
    // dispatchem el retain per asegurarnos que el graph d'expressions esta completament carregat 
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self.values observerCountRetainBy:1];
    }) ;
}


#pragma mark - SWValueHolder

- (void)value:(SWExpression *)expression didTriggerWithChange:(BOOL)changed
{
    SWValue *databaseNameVa = self.databaseName;
    SWValue *fieldNamesVa = self.fieldNames;
    SWValue *valuesExp = self.values;
    
    // nomes fem cas si els camps no son vuits
    if ( [databaseNameVa valueIsEmpty] || [fieldNamesVa valueIsEmpty] || [valuesExp valueIsEmpty] )
    {
        return;
    }
    
    if ( expression == valuesExp )
    {
        BOOL isDecoding = [self isCommitingWithMoveToGlobal];
        if ( isDecoding )
            return;

        [self _performDelayedBlock:^
        {
            CFAbsoluteTime timeStamp = CFAbsoluteTimeGetCurrent();
        
            SWDatabaseContextTimeRange timeRange = [self.databaseTimeRange valueAsInteger];
            NSString *name = [databaseNameVa valueAsString];
            NSArray *fields = [fieldNamesVa valuesAsStrings];
            NSInteger valuesCount = [valuesExp count];
        
            SWDatabaseContext *previousDBcontext = _dbContext;
        
            _dbContext = [_docModel.histoValues dbContextForWritingWithName:name range:timeRange fieldNames:fields valuesCount:valuesCount];
        
            if ( valuesCount != _valuesCount )
            {
                [_dbContext rebuildWithFieldNames:fields valuesCount:valuesCount];
                _valuesCount = valuesCount;
            }
        
            if ( previousDBcontext != _dbContext )
            {
                NSString *keyName = [_dbContext keyName];
                [self.databaseFile evalWithString:keyName];
            }

            NSArray *values = [valuesExp valueAsArray];
            [_dbContext addValues:values absoluteTime:timeStamp];
        }];
    }
    
    else if ( expression == fieldNamesVa )
    {
        if ( _dbContext == nil )
            return;
        
        CFAbsoluteTime timeStamp = CFAbsoluteTimeGetCurrent();
        
        NSArray *fields = [fieldNamesVa valuesAsStrings];
        NSInteger valuesCount = [valuesExp count];
        [_dbContext rebuildWithFieldNames:fields valuesCount:valuesCount];
        
        NSArray *values = [valuesExp valueAsArray];
        [_dbContext addValues:values absoluteTime:timeStamp];
    }
    
    else if ( expression == databaseNameVa )
    {
        //self.dbContext = nil;
        _dbContext = nil;
    }
    
    else if ( expression == self.databaseTimeRange )
    {
        //self.dbContext = nil;
        _dbContext = nil;
    }
}


@end
