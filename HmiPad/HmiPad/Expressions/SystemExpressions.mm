//
//  SystemExpressions.m
//  HmiPad_101120
//
//  Created by Joan on 20/11/10.
//  Copyright 2010 SweetWilliam, S.L. All rights reserved.
//

#import "SystemExpressions.h"
#import "RpnBuilder.h"
#import "SWPropertyDescriptor.h"

NSString *kAckChangedNotification = @"AckChangedNotification" ;

@implementation SystemExpressions
{
    struct
    {
        unsigned int pulse1:1;
        unsigned int pulse10:1;
        unsigned int pulse30:1;
        unsigned int pulse60:1;
        unsigned int dateTime:1;
    } _active;
    
    dispatch_source_t _pulse1Source ;
    
    int _pulse1Count ;
    
    CFDateFormatterRef _dateFormatter ;
    
    CFDictionaryRef _symbolTable ; // conte parelles CFStringRef, ExpressionHolder
    RpnBuilder *_builder;
}

static SWObjectDescription *_objectDescription = nil;

+ (SWObjectDescription *)objectDescription
{
    if ( _objectDescription == nil ) {
        _objectDescription = [[SWObjectDescription alloc] initWithObjectClass:[self class]];
    }
    return _objectDescription ;
}

+ (NSString*)defaultIdentifier
{
    return nil;
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"SYSTEM EXPRESSION", nil);
}

//+ (NSArray*)expressionDescriptions
//{
//    return [NSArray array];
//}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
            [SWPropertyDescriptor propertyDescriptorWithName:@"$SMPulse1s" type:SWTypeBool propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:0.0]],
            [SWPropertyDescriptor propertyDescriptorWithName:@"$SMPulse10s" type:SWTypeBool propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:0.0]],
            [SWPropertyDescriptor propertyDescriptorWithName:@"$SMPulse30s" type:SWTypeBool propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:0.0]],
            [SWPropertyDescriptor propertyDescriptorWithName:@"$SMPulse60s" type:SWTypeBool propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:0.0]],
            [SWPropertyDescriptor propertyDescriptorWithName:@"$SMAckButton" type:SWTypeBool propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:0.0]],
            [SWPropertyDescriptor propertyDescriptorWithName:@"$SMDate" type:SWTypeDouble propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:0.0]],
            [SWPropertyDescriptor propertyDescriptorWithName:@"$SMCommState" type:SWTypeInteger propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:0.0]],
            [SWPropertyDescriptor propertyDescriptorWithName:@"$SMCurrentUserAccessLevel" type:SWTypeInteger propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:0.0]],
            [SWPropertyDescriptor propertyDescriptorWithName:@"$SMActiveAlarmCount" type:SWTypeInteger propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:0.0]],
            [SWPropertyDescriptor propertyDescriptorWithName:@"$SMUnacknowledgedAlarmCount" type:SWTypeInteger propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:0.0]],
            [SWPropertyDescriptor propertyDescriptorWithName:@"$SMCurrentPageName" type:SWTypeString propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithString:@""]],
            [SWPropertyDescriptor propertyDescriptorWithName:@"$SMCurrentUserName" type:SWTypeString propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithString:@""]],
            nil];
}

#pragma mark - Init and Properties

- (id)initWithBuilder:(RpnBuilder *)builder
{
    self = [super initInDocument:nil];
    if (self)
    {
        _builder = builder;
        [_builder setSystemTable:[self symbolTable]];
    }
    return self;
}

- (SWValue*)pulse1Expression
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+0];
}

- (SWValue*)pulse10Expression
{    
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+1];
}

- (SWValue*)pulse30Expression
{    
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+2];
}

- (SWValue*)pulse60Expression
{    
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+3];
}

- (SWValue*)ackExpression
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+4];
}

- (SWValue*)dateTimeExpression
{    
    return  [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+5];
}

- (SWValue*)commStateExpression
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+6];
}

- (SWValue*)currentUserAccessLevelExpression
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+7];
}

- (SWValue*)activeAlarmCountExpression
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+8];
}


- (SWValue*)unacknowledgedAlarmCountExpression
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+9];
}

- (SWValue*)currentPageNameExpression
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+10];
}

- (SWValue*)currentUserNameExpression
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+11];
}

#pragma mark - dealloc

- (void)dealloc
{
    NSLog( @"system expressions dealloc" ) ;
    if ( _pulse1Source ) dispatch_source_cancel( _pulse1Source ) ;
    if ( _dateFormatter ) CFRelease( _dateFormatter ) ;
    
//    for ( int i=0; i<ExpressionsCount ; i++ )
//    {
//        SEL getSel = Expressions[i].getSel ;
//        //SWExpression *expr = [self performSelector:getSel] ;   // aixo crea un warning amb ARC !
//        SWExpression *expr = objc_msgSend( self, getSel ) ;
//        [expr setHolder:nil] ;   /*, [expr release] ;*/
//    }
    
    if ( _symbolTable ) CFRelease( _symbolTable ) ;
}

#pragma mark symbolTable

////------------------------------------------------------------------------------------
//- (CFDictionaryRef)symbolTable
//{
//    if ( symbolTable == nil )
//    {
//        int count = self.expressions.count ;
//    
//        CFStringRef keys[ExpressionsCount] ; 
//        CFTypeRef values[ExpressionsCount] ;
//        
//        for ( int i=0 ; i<ExpressionsCount ; i++ ) 
//        {
//            keys[i] = Expressions[i].name ;
//            values[i] = (__bridge CFTypeRef)self ;
//        }
//        
//        symbolTable = CFDictionaryCreate( NULL, (const void **)keys, values, ExpressionsCount, &kCFTypeDictionaryKeyCallBacks, NULL) ;
//    }
//    
//    return symbolTable ;
//}

- (CFDictionaryRef)symbolTable
{
    if ( _symbolTable == nil )
    {
        NSArray *descriptions = [[self class] objectDescription].allPropertyDescriptions;
        NSInteger count = _properties.count;
        
        CFStringRef keys[count]; 
        CFTypeRef values[count];
        
        for ( int i=0 ; i<count ; i++ ) 
        {
            SWPropertyDescriptor *descriptor = [descriptions objectAtIndex:i];
            keys[i] = (__bridge CFStringRef)descriptor.name ;
            values[i] = (__bridge CFTypeRef)self ;
        }
        
        _symbolTable = CFDictionaryCreate( NULL, (const void **)keys, values, count, &kCFTypeDictionaryKeyCallBacks, NULL) ;
    }
    
    return _symbolTable ;
}

#pragma mark pulseExpressions

////------------------------------------------------------------------------------------
//- (SWExpression*)pulse1ExpressionMake
//{
//    if ( pulse1Expression == nil )
//    {
//        pulse1Expression = [[SWExpression alloc] initWithDouble:0] ;
//        p1ea = (UInt32)pulse1Expression ;
//        [pulse1Expression setHolder:self] ;
//        [self mayBeStartPulse1Timer] ;
//    }
//
//    return pulse1Expression ;
//}
//
////------------------------------------------------------------------------------------
//- (SWExpression*)pulse10ExpressionMake
//{
//    if ( pulse10Expression == nil )
//    {
//        pulse10Expression = [[SWExpression alloc] initWithDouble:0] ;
//        [pulse10Expression setHolder:self] ;
//        [self mayBeStartPulse1Timer] ;
//    }
//
//    return pulse10Expression ;
//}
//
////------------------------------------------------------------------------------------
//- (SWExpression*)pulse30ExpressionMake
//{
//    if ( pulse30Expression == nil )
//    {
//        pulse30Expression = [[SWExpression alloc] initWithDouble:0] ;
//        [pulse30Expression setHolder:self] ;
//        [self mayBeStartPulse1Timer] ;
//    }
//
//    return pulse30Expression ;
//}
//
////------------------------------------------------------------------------------------
//- (SWExpression*)pulse60ExpressionMake
//{
//    if ( pulse60Expression == nil )
//    {
//        pulse60Expression = [[SWExpression alloc] initWithDouble:0] ;
//        [pulse60Expression setHolder:self] ;
//        [self mayBeStartPulse1Timer] ;
//    }
//
//    return pulse60Expression ;
//}
//
//



#pragma mark time/date Expressions

- (CFDateFormatterRef)_dateFormatter
{
    if ( _dateFormatter == NULL )
    {
        _dateFormatter = CFDateFormatterCreate( NULL, NULL, kCFDateFormatterNoStyle, kCFDateFormatterNoStyle );
        //CFDateFormatterSetFormat( dateFormatter, CFSTR("yyyy-MM-dd HH:mm:ss ZZ") );
        CFDateFormatterSetFormat( _dateFormatter, CFSTR("yyyy-MM-dd HH:mm:ss") );
    }
    return _dateFormatter;
}

////------------------------------------------------------------------------------------
//- (SWExpression*)dateTimeExpressionMake
//{
//    if ( dateTimeExpression == nil )
//    {
//        dateTimeExpression = [[SWExpression alloc] initWithString:@""] ;
//        [dateTimeExpression setHolder:self] ;
//        [self mayBeStartPulse1Timer] ;
//    }
//
//    return dateTimeExpression ;
//}

#pragma mark pulseExpressions

- (void)_evalPulseExpressionsIfNeeded
{
    _pulse1Count += 5 ;    // decimes de segon
    
    // pulse 1
    if ( _active.pulse1 && _pulse1Count%5 == 0 ) // cada 0.5 segons fa un canvi, es a dir el periode es 1
    {
        [self.pulse1Expression evalWithDouble:(_pulse1Count%10)!=0] ;
    }
    
    // pulse 10
    if ( _active.pulse10 && _pulse1Count%50 == 0 ) // cada 5 segons fa un canvi, es a dir el periode es 10
    {
        [self.pulse10Expression evalWithDouble:(_pulse1Count%100)!=0] ;
    }

    // pulse 30
    if ( _active.pulse30 && _pulse1Count%150 == 0 ) 
    {
        [self.pulse30Expression evalWithDouble:(_pulse1Count%300)!=0] ;
    }
    
    // pulse 60
    if ( _active.pulse60 && _pulse1Count%300 == 0 ) 
    {
        [self.pulse60Expression evalWithDouble:(_pulse1Count%600)!=0] ;
    }
    
    // date/time
    if ( _active.dateTime && _pulse1Count%10 == 0) 
    {
        CFAbsoluteTime timeStamp = CFAbsoluteTimeGetCurrent() ;
        CFDateRef date = CFDateCreate( NULL, timeStamp ) ;
        CFStringRef dateFormatedStr = CFDateFormatterCreateStringWithDate( NULL, [self _dateFormatter], date ) ;    
    
        [self.dateTimeExpression evalWithString:(__bridge NSString*)dateFormatedStr] ;

        CFRelease( dateFormatedStr ) ;
        CFRelease( date ) ; 
    }
}

- (void)_mayBeStartPulse1Timer
{
//    NSLog( @"_active.pulse1 :%d", _active.pulse1 ) ;
//    NSLog( @"_active.pulse10 :%d", _active.pulse10 ) ;
//    NSLog( @"_active.pulse30 :%d", _active.pulse30 ) ;
//    NSLog( @"_active.pulse60 :%d", _active.pulse60 ) ;
//    NSLog( @"_active.pulse.dateTime :%d", _active.dateTime ) ;
    if ( ! ( _active.pulse1 || _active.pulse10 || _active.pulse30 || _active.pulse60 || _active.dateTime ) ) return ;
    
    if ( _pulse1Source == NULL )
    {
        _pulse1Source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_current_queue());
    
        dispatch_source_t thePulse1Source = _pulse1Source;
        __unsafe_unretained id theSelf = self ;// evitem el retain cycle entre pulse1Source i el self, en el dealloc eliminem el pulse1Source

        dispatch_source_set_event_handler( _pulse1Source, 
        ^{
            @autoreleasepool {
                [theSelf _evalPulseExpressionsIfNeeded] ;
            }
        });

        dispatch_source_set_cancel_handler( _pulse1Source, 
        ^{
            dispatch_release( thePulse1Source );
        });
    

        dispatch_resume( _pulse1Source );
        dispatch_source_set_timer( _pulse1Source, DISPATCH_TIME_NOW, NSEC_PER_SEC/2, 0 );      // 0.5 seg
        _pulse1Count = 0 ;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark protocol ExpressionHolder
////////////////////////////////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
// Torna la expressio corresponent segons el id que es un NSSTring
//- (ExpressionBase *)selfValueExpressionWithId:(id)strId
- (SWValue *)valueWithSymbol:(NSString *)sym property:(NSString *)prop
{
    SWValue *value = [super valueWithSymbol:nil property:sym];
    
    if ( _active.pulse1 == 0 && value == self.pulse1Expression ) _active.pulse1 = 1;
    if ( _active.pulse10 == 0 && value == self.pulse10Expression ) _active.pulse10 = 1;
    if ( _active.pulse30 == 0 && value == self.pulse30Expression ) _active.pulse30 = 1;
    if ( _active.pulse60 == 0 && value == self.pulse60Expression ) _active.pulse60 = 1;
    if ( _active.dateTime == 0 && value == self.dateTimeExpression ) _active.dateTime = 1;
    [self _mayBeStartPulse1Timer];
    
    return value ;
}

//-----------------------------------------------------------------------------
- (NSString *)symbolForValue:(SWValue*)value
{
    NSString *sym = [super propertyForValue:value];
    
    if ( sym == nil ) 
        return @"<UnknownSystemExpr>";
        
    return sym;
}

//-----------------------------------------------------------------------------
- (NSString *)propertyForValue:(SWValue*)theExpr
{
    return nil;
}

////-----------------------------------------------------------------------------
//// Torna la expressio per escriure corresponent segons el id que es un NSSTring
//- (SWExpression*)selfValueWExpressionWithId:(id)strId
//{
//    
//    for ( int i=0 ; i<WExpressionsCount ; i++ )
//    {
//        CFStringRef name = WExpressions[i].name ;
//        if ( CFEqual( (__bridge CFTypeRef)strId, name ) )
//        {
//            SEL makeSel = WExpressions[i].makeSel ;
//            //return [self performSelector:makeSel] ;
//            return objc_msgSend( self, makeSel ) ;
//        }
//    }
//    return nil ;
//}

//-----------------------------------------------------------------------------
- (NSString *)identifier
{
    // l'objecte globalExpression no conte en si mateix cap valor
    return @"System Value";   // localitzar
}

////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark protocol QuickCoder
////////////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------------
- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super initWithQuickCoder:decoder];
    
    [decoder decodeBytes:&_active length:sizeof(_active)];
    _builder = [decoder decodeObject];
    
    [_builder setSystemTable:[self symbolTable]]; 
    [self _mayBeStartPulse1Timer]; // forcem la inicialitzacio del timer

    return self ;
}

//------------------------------------------------------------------------------------
- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
{
    [super encodeWithQuickCoder:encoder];
    
    [encoder encodeBytes:&_active length:sizeof(_active)];
    [encoder encodeObject:_builder];
}

@end
