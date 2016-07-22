//
//  SWRestApiItem.m
//  HmiPad
//
//  Created by joan on 09/05/15.
//  Copyright (c) 2015 SweetWilliam, SL. All rights reserved.
//

#import "SWRestApiItem.h"
#import "SWPropertyDescriptor.h"

#import "SWDocumentModel.h"
#import "SWValue.h"

#import "SWRestApiTask.h"


@interface SWRestApiItem()<SWRestApiTaskDelegate,SWRestApiTaskDataSource>
{
    SWRestApiTask *_restApiTask;
    BOOL _isWaitingBlock;
}

@end


@implementation SWRestApiItem

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
    return @"restApi";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"REST API", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
    
        [SWPropertyDescriptor propertyDescriptorWithName:@"baseApiUrl" type:SWTypeString
            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithString:@"http://www."]],
    
        [SWPropertyDescriptor propertyDescriptorWithName:@"method" type:SWTypeString
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"GET"]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"restPath" type:SWTypeString
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"/"]],

        [SWPropertyDescriptor propertyDescriptorWithName:@"httpHeaders" type:SWTypeDictionary
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDictionary:@{}]],

        [SWPropertyDescriptor propertyDescriptorWithName:@"requestBody" type:SWTypeDictionary
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDictionary:@{}]],
        
        [SWPropertyDescriptor propertyDescriptorWithName:@"trigger" type:SWTypeBool
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"gotResponse" type:SWTypeBool
            propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"response" type:SWTypeAny
            propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDictionary:@{}]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"statusCode" type:SWTypeInteger
            propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0]],
    
        nil
    ];
}

// #pragma mark init / dealloc / observer retain

- (id)initInDocument:(SWDocumentModel *)docModel
{
    self = [super initInDocument:docModel];
    if ( self )
    {
        [self _restApiObserverRetain];
    }
    return self;
}

- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super initWithQuickCoder:decoder];
    if (self) 
    {
        [self _restApiObserverRetain];
    }
    return self;
}

- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString *)ident parentObject:(id<SymbolicCoding>)parent
{
    self = [super initWithSymbolicCoder:decoder identifier:ident parentObject:parent];
    if ( self )
    {
        [self _restApiObserverRetain];
    }
    return self;
}


- (void)putToSleep
{
    if ( !self.isAsleep )
        [self _restApiObserverRelease];
    
    [super putToSleep];
}

- (void)awakeFromSleepIfNeeded
{
    BOOL isAsleep = self.isAsleep;
    [super awakeFromSleepIfNeeded];
    
    if (isAsleep)
        [self _restApiObserverRetain];
}

- (void)dealloc
{
    if (!self.isAsleep)
        [self _restApiObserverRelease];
}

#pragma mark - Properties

- (SWValue*)baseApiUrl
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+0];
}

- (SWValue*)method
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+1];
}

- (SWExpression*)restPath
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+2];
}

- (SWExpression*)httpHeaders
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+3];
}

- (SWExpression*)requestBody
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+4];
}

- (SWExpression*)trigger
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+5];
}

- (SWValue*)gotResponse
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+6];
}

- (SWValue*)response
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+7];
}

- (SWValue*)statusCode
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+8];
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


- (void)_restApiObserverRetain
{
    [self.trigger observerCountRetainBy:1];
}

- (void)_restApiObserverRelease
{
    [self.trigger observerCountReleaseBy:1];
}

- (void)_restApiObserverRetainAfterDecode
{
    // dispatchem el retain per asegurarnos que el graph d'expressions esta completament carregat 
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self _restApiObserverRetain];
    }) ;
}


#pragma mark - Private


- (SWRestApiTask *)_task
{
    if ( _restApiTask == nil)
    {
        _restApiTask = [[SWRestApiTask alloc] initInDocumentModel:_docModel];
        [_restApiTask setDataSource:self];
        [_restApiTask setDelegate:self];
    }
    return _restApiTask;
}


- (void)_performTrigger
{
    [[self _task] performTask];
}

- (void)_delayedNormalEnd:(id)dummy
{
    [self.gotResponse evalWithDouble:0.0];
}


#pragma mark - SWRestApiTaskDataSource

- (NSString *)baseUrlForRestApiTask:(SWRestApiTask *)restApiTask
{
    NSString *baseUrl = self.baseApiUrl.valueAsString;
    return baseUrl;
}


- (NSString *)restPathForRestApiTask:(SWRestApiTask *)restApiTask
{
    NSString *restPath = self.restPath.valueAsString;
    return restPath;
}

- (NSDictionary *)httpHeadersForRestApiTask:(SWRestApiTask *)restApiTask
{
    NSDictionary *httpHeaders = self.httpHeaders.valueAsDictionary;
    return httpHeaders;
}

- (NSString *)methodForRestApiTask:(SWRestApiTask *)restApiTask
{
    NSString *method = self.method.valueAsString;
    return method;
}

- (NSString *)bodyForRestApiTask:(SWRestApiTask *)restApiTask
{
    NSString *body = self.requestBody.valueAsString;
    return body;
}


#pragma mark - SWRestApiTaskDelegate


- (void)restApiTask:(SWRestApiTask *)restApiTask didCompeteWithResult:(id)responseDictOrArray statusCode:(NSInteger)statusCode
{
    SWValue *value = nil;
    if ( [responseDictOrArray isKindOfClass:[NSDictionary class]] )
        value = [SWValue valueWithDictionary:responseDictOrArray];

    else if ( [responseDictOrArray isKindOfClass:[NSArray class]] )
        value = [SWValue valueWithArray:responseDictOrArray];
    
    else
        value = [SWValue valueWithDictionary:@{}];

    [self.response evalWithValue:value];
    [self.statusCode evalWithDouble:statusCode];
    
    [self.gotResponse evalWithDouble:1];
    [self performSelector:@selector(_delayedNormalEnd:) withObject:nil afterDelay:0.0];
}




#pragma mark - SWValueHolder

- (void)value:(SWExpression *)expression didTriggerWithChange:(BOOL)changed
{
    if ( expression == self.trigger )
    {
        if ( changed && expression.valueAsBool != NO)
        {
            [self _performTrigger];
        }
    }
    
    else
    {
        if ( changed )
        {
            [[self _task] reloadData];
        }
    }
}


@end