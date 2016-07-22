//
//  SWBackgroundItemExpression.m
//  HmiPad
//
//  Created by Joan on 26/05/14.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWBackgroundItemDataSnap.h"
#import "SWPropertyDescriptor.h"

@implementation SWBackgroundItemDataSnap
{
    BOOL _isStartingSnap;
    BOOL _isEndingSnap;
    BOOL _isWaitingResult;
    BOOL _isWaitingBlock;
    dispatch_source_t _timeoutTimer;
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
    return @"dataSnap";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"DATA SNAP", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:

        [SWPropertyDescriptor propertyDescriptorWithName:@"snapValue" type:SWTypeAny
            propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"snap" type:SWTypeBool
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"inputValue" type:SWTypeAny
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
        
        nil
    ];
}


// #pragma mark init / dealloc / observer retain

//- (id)initInDocument:(SWDocumentModel *)docModel
//{
//    self = [super initInDocument:docModel];
//    if ( self )
//    {
//        [self.value observerCountRetainBy:1];
//    }
//    return self;
//}

//- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
//{
//    self = [super initWithQuickCoder:decoder];
//    if (self) 
//    {
//        [self _observerRetainAfterDecode];
//    }
//    return self;
//}

//- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString *)ident parentObject:(id<SymbolicCoding>)parent
//{
//    self = [super initWithSymbolicCoder:decoder identifier:ident parentObject:parent];
//    if ( self )
//    {
//        [self _observerRetainAfterDecode];
//    }
//    return self;
//}

//- (void)_observerRetainAfterDecode
//{
//    // dispatchem el retain per asegurarnos que el graph d'expressions esta completament carregat 
//    dispatch_async(dispatch_get_main_queue(), ^
//    {
//        [self.value observerCountRetainBy:1];
//    }) ;
//}

//- (void)putToSleep
//{
//    if ( !self.isAsleep )
//        [self.value observerCountReleaseBy:1];
//    
//    [super putToSleep];
//}

//- (void)awakeFromSleepIfNeeded
//{
//    BOOL isAsleep = self.isAsleep;
//    [super awakeFromSleepIfNeeded];
//    
//    if (isAsleep)
//        [self.value observerCountRetainBy:1];
//}

//- (void)dealloc
//{
//    if (!self.isAsleep)
//        [self.value observerCountReleaseBy:1];
//}


#pragma mark - Properties

- (SWExpression*)snapValue
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+0];
}

- (SWExpression*)snap
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+1];
}


- (SWExpression*)inputValue
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+2];
}



#pragma mark - Dealloc

- (void)dealloc
{
    if ( _timeoutTimer )
        dispatch_source_cancel(_timeoutTimer), _timeoutTimer = NULL;
    
    if ( _isWaitingBlock )
        [self _finishSnap];
}

#pragma mark - ValueHolder



- (void)valuePerformRetain:(SWValue*)value
{
}

- (void)valuePerformRelease:(SWValue*)value
{
}


- (BOOL)canPerformRetainForValue:(SWValue*)value
{
    BOOL canDo = YES;
    if ( value == self.inputValue )
        canDo = _isStartingSnap;
 
    return canDo;
}


- (BOOL)canPerformReleaseForValue:(SWValue*)value
{
   BOOL canDo = YES;
    if ( value == self.inputValue )
        canDo = _isEndingSnap;
 
    return canDo;
}


- (void)value:(SWValue *)value didTriggerWithChange:(BOOL)changed
{
    if ( _isStartingSnap )
        return;

    SWExpression *selfValue = self.inputValue;
    
//    if ( value == selfValue )
//    {
//        ExpressionStateCode state = [selfValue state];
//        NSLog( @"state: %d", state);
//    }
    

    if ( value == self.snap && !_isStartingSnap )
    {
        BOOL snap = [value valueAsBool];
        if ( snap )
        {
            ExpressionStateCode state = [selfValue state];
            if ( state == ExpressionStateOk )
            {
                [self _performSnapNow];
            }
            [self _startSnap];
            
        }
    }
    
    else if ( value == self.inputValue && !_isEndingSnap )
    {
        if ( _isWaitingResult )
        {
            //NSLog( @"log") ;
            [self _performDelayedBlock:^
            {
                [self _performSnapNow];
                [self _finishSnap];
            }];
        }
    }
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


- (void)_startSnap
{
    //NSLog( @"startSnap") ;
    [self _startTimeoutTimer];
    
    if ( !_isWaitingResult )
    {
        _isWaitingResult = YES;
        _isStartingSnap = YES;
        [self.inputValue observerCountRetainBy:1];
        _isStartingSnap = NO;
    }
}


- (void)_finishSnap
{
    //NSLog( @"finishSnap") ;
    [self _stopTimeoutTimer];
    
    if ( _isWaitingResult )
    {
        _isWaitingResult = NO;
        _isEndingSnap = YES;
        [self.inputValue observerCountReleaseBy:1];
        _isEndingSnap = NO;
    }
}


- (void)_performSnapNow
{
    [self.snapValue evalWithValue:self.inputValue];
}


- (void)_startTimeoutTimer
{
    if ( _timeoutTimer == NULL )
    {
        _timeoutTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue() );
    
        __weak SWBackgroundItemDataSnap *weakSelf = self;
        
        dispatch_source_set_event_handler( _timeoutTimer,
        ^{
            [weakSelf _finishSnap];
        });
    
        dispatch_resume( _timeoutTimer );
    }
    
    dispatch_time_t tt = dispatch_time( DISPATCH_TIME_NOW, NSEC_PER_SEC*10 );   // comenca d'aqui a 10 segons
    dispatch_source_set_timer( _timeoutTimer, tt, DISPATCH_TIME_FOREVER, 0 );      // no repeteix mai
}


- (void)_stopTimeoutTimer
{
    if ( _timeoutTimer )
        dispatch_source_set_timer( _timeoutTimer, DISPATCH_TIME_FOREVER, DISPATCH_TIME_FOREVER, 0 );
}

    
@end
