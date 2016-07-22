//
//  SWBackgroundItemDelayOn.m
//  HmiPad
//
//  Created by Joan on 26/05/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWBackgroundItemDelayOn.h"
#import "SWPropertyDescriptor.h"

@implementation SWBackgroundItemDelayOn
{
    dispatch_source_t _delaySource;
    unsigned int _circularCatch:1;
}

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
    return @"delayOn";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"DELAY ON TIMER", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:

        [SWPropertyDescriptor propertyDescriptorWithName:@"delayedValue" type:SWTypeBool
            propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"value" type:SWTypeBool
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
        
        [SWPropertyDescriptor propertyDescriptorWithName:@"time" type:SWTypeDouble
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:10.0]],
        
        nil
    ];
}


// #pragma mark init / dealloc / observer retain

- (id)initInDocument:(SWDocumentModel *)docModel
{
    self = [super initInDocument:docModel];
    if ( self )
    {
        [self.value observerCountRetainBy:1];
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

- (void)_observerRetainAfterDecode
{
    // dispatchem el retain per asegurarnos que el graph d'expressions esta completament carregat 
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self.value observerCountRetainBy:1];
    }) ;
}

- (void)putToSleep
{
    if ( !self.isAsleep )
        [self.value observerCountReleaseBy:1];
    
    [super putToSleep];
}

- (void)awakeFromSleepIfNeeded
{
    BOOL isAsleep = self.isAsleep;
    [super awakeFromSleepIfNeeded];
    
    if (isAsleep)
        [self.value observerCountRetainBy:1];
}

- (void)dealloc
{
    //NSLog(@"SWBackgroundItemDelayOn dealloc");
    
    if (!self.isAsleep)
        [self.value observerCountReleaseBy:1];
    
    if(_delaySource)
        dispatch_source_cancel(_delaySource);
}

#pragma mark - Properties

- (SWValue*)delayedValue
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+0];
}

- (SWExpression*)value
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+1];
}

- (SWExpression*)time
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+2];
}


#pragma mark - dispatch timer

- (void)_fireDelayedValue:(BOOL)bValue
{
    [self.delayedValue evalWithDouble:(double)(bValue!=NO)];
}


- (void)_startTimer
{
    if (_delaySource == NULL)
    {
        _delaySource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    
        __weak id theSelf = self;
        dispatch_source_set_event_handler(_delaySource,
        ^{
            @autoreleasepool {
                [theSelf _fireDelayedValue:YES];
            }
        });

        dispatch_source_set_cancel_handler(_delaySource, 
        ^{
            //IOS6 dispatch_release(_delaySource);
        });
    
        dispatch_resume(_delaySource);
    }
    
    double time = [self.time valueAsDouble];
    dispatch_time_t tt = dispatch_time( DISPATCH_TIME_NOW, NSEC_PER_SEC*time );    // comenca d'aqui a time segons
    dispatch_source_set_timer(_delaySource, tt, DISPATCH_TIME_FOREVER, 0);         // no repeteix mai
}

- (void)_resetTimer
{
    if ( _delaySource )
        dispatch_source_set_timer(_delaySource, DISPATCH_TIME_FOREVER, DISPATCH_TIME_FOREVER, 0);
    
    [self _fireDelayedValue:NO];
}


- (void)_stopTimer
{
    if (_delaySource)
        dispatch_source_cancel(_delaySource), _delaySource = NULL;
}


#pragma mark - ValueHolder

//- (void)valueV:(SWValue *)value didTriggerWithChange:(BOOL)changed
//{
//    if ( value == self.value )
//    {
//        BOOL bValue = value.valueAsBool;
//        if ( bValue )
//        {
//            if ( changed )
//                [self _startTimer];
//        }
//        else
//        {
//            [self _resetTimer];
//        }
//    }
//}

- (void)value:(SWValue *)value didTriggerWithChange:(BOOL)changed
{
    if ( value == self.value )
    {
        if ( [self.delayedValue isPromoting] )
            return;
    
        BOOL bValue = value.valueAsBool;
        if ( bValue )
        {
            if ( changed )
                [self _startTimer];
        }
        else
        {
            [self _resetTimer];
        }
    }
}

//- (void)value:(SWValue *)value didTriggerWithChange:(BOOL)changed
//{
//    if ( value == self.value && value.state == ExpressionStateOk )
//    {
//        if ( _circularCatch )
//        {
//            [(SWExpression*)value evalWithForcedState:ExpressionStateCircularReference];
//            return;
//        }
//    
//        _circularCatch = 1;
//        BOOL bValue = value.valueAsBool;
//        if ( bValue )
//        {
//            if ( changed )
//                [self _startTimer];
//        }
//        else
//        {
//            [self _resetTimer];
//        }
//        _circularCatch = 0;
//    }
//}



@end
