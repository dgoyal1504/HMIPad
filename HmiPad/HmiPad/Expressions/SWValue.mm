//
//  SWValue.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/4/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWValue.h"
#import "RPNValue.h"
#import "SWPropertyDescriptor.h"

#import "SWColor.h"

#pragma mark - C Method Declarations

static void doExpressionNameDidChange( SWValue * value );

#pragma mark - SWValue

@implementation SWValue

@synthesize holder = _holder;
@synthesize observerCount = _observerCount;
@dynamic valueType;
//@synthesize state = _state;

#pragma mark Initializers

- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

//- (id)initWithSourceString:(NSString*)string usingBuilder:(RpnBuilder*)builder outErrorStr:(NSString**)errStr  // may return nil
//{
//    self = [super init] ;
//    if ( self )
//    {
//        self = [builder valueWithSourceString:string outErrString:errStr] ;  // ATENCIO pot tornar nil !!
//    }
//    return self ;
//}

- (id)initWithValue:(SWValue*)value
{
    self = [super init];
    if (self) {
        rpnValue = value->rpnValue;
    }
    return self;
}

- (id)initWithDouble:(double)value
{
    self = [super init];
    if (self) {
        rpnValue = value;
    }
    return self;
}

- (id)initWithAbsoluteTime:(CFAbsoluteTime)value
{
    self = [super init];
    if (self) {
        rpnValue = value+NSTimeIntervalSince1970;
        rpnValue.typ = SWValueTypeAbsoluteTime;   // sobreescribim el tipus
    }
    return self;
}

- (id)initWithCGPoint:(CGPoint)value
{
    self = [super init];
    if (self) {
        rpnValue = value;
    }
    return self;
}

- (id)initWithCGSize:(CGSize)value
{
    self = [super init];
    if (self) {
        rpnValue = value;
    }
    return self;
}

- (id)initWithCGRect:(CGRect)value
{
    self = [super init];
    if (self) {
        rpnValue = value;
    }
    return self;
}

- (id)initWithSWValueRange:(SWValueRange)value
{
    self = [super init];
    if (self) {
        rpnValue = value;
    }
    return self;
}

- (id)initWithString:(NSString*)value
{
    self = [super init];
    if (self) {
        rpnValue = (__bridge CFStringRef)value;
    }
    return self;
}

- (id)initWithObject:(id <QuickCoding, SymbolicCoding>)value
{
    self = [super init];
    if (self) {
        NSAssert( NO, @"Not implemented" );
        //rpnValue = (__bridge CFTypeRef)value;
    }
    return self;
}

- (id)initWithArray:(NSArray*)array
{
    self = [super init];
    if (self)
    {
        [self _primitiveSetRpnValueWithArray:array];
    }
    return self;     
}

- (id)initWithDoubles:(const double *)nums count:(const int)count
{
    self = [super init];
    if (self)
    {
        rpnValue = RPNValue(nums,count);
    }
    return self;  
}

- (id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self)
    {
        [self _primitiveSetRpnValueWithDictionary:dict];
    }
    return self;     
}

- (id)initWithRPNValue:( const RPNValue& )value
{
    self = [super init];
    if (self) {
        rpnValue = value;
    }
    return self;     
}

+ (SWValue*)valueWithValue:(SWValue*)value
{
    return [[SWValue alloc] initWithValue:value];
}

+ (SWValue*)valueWithDouble:(double)value
{
    return [[SWValue alloc] initWithDouble:value];
}

+ (SWValue*)valueWithAbsoluteTime:(double)value
{
    return [[SWValue alloc] initWithAbsoluteTime:value];
}

+ (SWValue*)valueWithCGPoint:(CGPoint)value
{
    return [[SWValue alloc] initWithCGPoint:value];
}

+ (SWValue*)valueWithCGSize:(CGSize)value
{
    return [[SWValue alloc] initWithCGSize:value];
}

+ (SWValue*)valueWithCGRect:(CGRect)value
{
    return [[SWValue alloc] initWithCGRect:value];
}

+ (SWValue*)valueWithSWValueRange:(SWValueRange)value
{
    return [[SWValue alloc] initWithSWValueRange:value];
}

+ (SWValue*)valueWithString:(NSString*)value
{
    return [[SWValue alloc] initWithString:value];
}

+ (SWValue*)valueWithObject:(id <QuickCoding, SymbolicCoding>)value
{
    return [[SWValue alloc] initWithObject:value];
}

+ (SWValue*)valueWithArray:(NSArray*)value
{
    return [[SWValue alloc] initWithArray:value];
}

+ (SWValue*)valueWithDoubles:(const double *)nums count:(const int)count
{
    return [[SWValue alloc] initWithDoubles:nums count:count];
}

+ (SWValue*)valueWithDictionary:(NSDictionary*)value
{
    return [[SWValue alloc] initWithDictionary:value];
}

- (SWPropertyDescriptor*)valueDescription
{
    if ([_holder respondsToSelector:@selector(valueDescriptionForValue:)])
        return [_holder valueDescriptionForValue:self];
    
    return nil;
}

- (SWValue*)getDefaultValue
{
    SWValue *defaultValue = nil;
    
    if ( [_holder respondsToSelector:@selector(defaultValueForValue:)] )
        defaultValue = [_holder defaultValueForValue:self];
    
    else
        defaultValue = [self valueDescription].defaultValue;
    
    return defaultValue;
}

//- (SWValue*)getDefaultValueVV
//{
//    SWPropertyDescriptor *descriptor = [self valueDescription];
//    SWValue *defaultValue = descriptor.defaultValue;
//    return defaultValue;
//}

#pragma mark Overriden Methods

- (void)dealloc
{
    //NSLog( @"SWValue dealloc:%x, %@", (unsigned)self, [self fullReference] );
    
    if ( dependants ) 
        CFRelease( dependants ), dependants=NULL;
    
    if ( observers ) 
        CFRelease(observers), observers=NULL;
}

#pragma mark Observers

- (void)addObserver:(id<ValueObserver>)obj
{
    if ( obj == nil ) 
        return;
    
    if ( observers == NULL ) 
        observers = CFArrayCreateMutable(NULL, 0, NULL);
    
    CFArrayAppendValue( observers, (__bridge CFTypeRef)obj );
    
    [self observerCountRetainBy:1];
}

- (void)removeObserver:(id<ValueObserver>)obj
{
    if ( observers )
    {
        CFIndex length = CFArrayGetCount( observers );
        CFIndex indx = CFArrayGetLastIndexOfValue( observers, CFRangeMake(0,length), (__bridge CFTypeRef)obj );
        if ( indx >= 0 )
        {
            CFArrayRemoveValueAtIndex( observers, indx );
            
            [self observerCountReleaseBy:1];
        }
    }
}


#pragma mark data source retain/release pattern

//- (void)observerCountRetainByx:(int)n
//{
//    if ( [_holder respondsToSelector:@selector(valuePerformRetain:)] )
//    {
//        [_holder valuePerformRetain:self];
//    }
//}
//
//- (void)observerCountReleaseByx:(int)n
//{
//    if ( [_holder respondsToSelector:@selector(valuePerformRelease:)] )
//    {
//        [_holder valuePerformRelease:self]; 
//    }
//}


void observerCountOfValue_ReleaseBy(SWValue *value, int n)
{
    value->_observerCount -= n;
    if ( value->_observerCount == 0 )
    {
        if ( [value->_holder respondsToSelector:@selector(valuePerformRelease:)] )
            [value->_holder valuePerformRelease:value];
    }
    //NSLog( @"Value observer Release :%d :%@", value->_observerCount, [value fullReference]);
}


void observerCountOfValue_retainBy(SWValue *value, int n)
{
    if ( value->_observerCount == 0 )
    {
        if ([value->_holder respondsToSelector:@selector(valuePerformRetain:)])
            [value->_holder valuePerformRetain:value];
    }
    value->_observerCount += n;
    //NSLog( @"Value observer Retain :%d :%@", value->_observerCount, [value fullReference]);
}


- (void)observerCountRetainBy:(int)n
{
    observerCountOfValue_retainBy(self, n);
}


- (void)observerCountReleaseBy:(int)n
{
    observerCountOfValue_ReleaseBy(self, n);
}



#pragma mark Identifiers

- (void)promoteSymbol
{
    CFIndex count = 0;
    doExpressionNameDidChange( self );
    
    if ( dependants ) 
        count = CFArrayGetCount(dependants);
    
    for ( CFIndex i=0; i<count; i++ ) 
    {
        __unsafe_unretained id<ValueDependant> dependant = (__bridge id)CFArrayGetValueAtIndex( dependants, i );
        [dependant sourceSymbolDidChange];
    }
}


#pragma mark Promotions

- (void)enablePromotions
{
    if ( (condition.expressionConditionAsleep) )
    {
        condition.expressionConditionAsleep = 0;  // posem a 0
        [self promoteSymbol];
        // [self eval];
    }
}

- (void)disablePromotions
{
    if ( condition.expressionConditionAsleep == 0 )
    {
        condition.expressionConditionAsleep = 1;           // posem a 1
        [self promoteSymbol];
        //[self evalWithDisconnectedSource];
    }
}


- (void)invalidate
{
    _holder = nil;
    [self promoteSymbol];
}

#pragma mark States

- (BOOL)hasDependants
{
    if ( dependants ) 
        return ( CFArrayGetCount(dependants) > 0 );
    
    return NO;
}

- (BOOL)isPromoting
{
    return condition.expressionConditionPromoting != 0;
}

#pragma mark Source String

//- (NSString *)getSourceString
//{
//    NSString *string = nil;
//    
//    CFStringRef str = createStringForRpnValue_withFormat( rpnValue, NULL );
//    string = (__bridge_transfer NSString*)str;
//    
//    if (rpnValue.typ == SWValueTypeString) 
//    {
//        string = [NSString stringWithFormat:@"\"%@\"",string];
//    }
//    
//    return string;
//}

// generic, implementat tambe a SWExpression
- (NSString *)getSourceString
{
    CFStringRef str = createSourceStringForRpnValue_withFormat( rpnValue, NULL );
    NSString *string = CFBridgingRelease(str);
    
    return string;
}

// torna el value com una string parsejable
- (NSString *)getValueSourceString
{
    CFStringRef str = createSourceStringForRpnValue_withFormat( rpnValue, NULL );
    NSString *string = CFBridgingRelease(str);
    
    return string;
}

- (NSString*)getBindableString
{
    if (_holder != nil)
        return [self fullReference];
    else
        return [self getValueSourceString];
}


// esencialment es el mateix que valueAsString pero pot tornar la string entre cometes i amb el tipus com a capsalera
- (NSString *)getValuePrintableString
{
    NSString *str = CFBridgingRelease(createPrintableStringForRpnValue( rpnValue ));
    return str;
//    NSString *strType = NSLocalizedStringFromSWValueType( rpnValue.typ );
//    NSString *string = [NSString stringWithFormat:@"%@: %@", strType, str];
//    return string;
}

#pragma mark Getters

- (int)observerCount
{
    return _observerCount;
}

- (BOOL)hasManagedObserverRetains
{
    BOOL result = [_holder respondsToSelector:@selector(canPerformRetainForValue:)];
    return result;
}

- (BOOL)hasManagedObserverReleases
{
    BOOL result = [_holder respondsToSelector:@selector(canPerformReleaseForValue:)];
    return result;
}

- (SWValueType)valueType
{
    return rpnValue.typ;
}

- (double)valueAsDouble
{
    return valueAsDoubleForRpnValue( rpnValue );
}

- (CFAbsoluteTime)valueAsAbsoluteTime
{
    return valueAsAbsoluteTimeForRpnValue( rpnValue )-NSTimeIntervalSince1970;
}

- (CGPoint)valueAsCGPoint
{
    return valueAsCGPointForRpnValue( rpnValue );
}

- (CGSize)valueAsCGSize
{
    return valueAsCGSizeForRpnValue( rpnValue );
}

- (CGRect)valueAsCGRect
{
    return valueAsCGRectForRpnValue( rpnValue );
}

- (SWValueRange)valueAsSWValueRange
{
    return valueAsSWValueRangeForRpnValue( rpnValue );
}

- (NSString*)valueAsString
{
    CFStringRef str = createStringForRpnValue_withFormat( rpnValue, NULL );
    return (__bridge_transfer NSString*)str;
}

- (NSString*)valueAsStringWithFormat:(NSString*)format
{        
    CFStringRef str = createStringForRpnValue_withFormat( rpnValue, (__bridge CFStringRef)format );
    return (__bridge_transfer NSString*)str;
}

- (id)valueAsObject
{
    return (__bridge_transfer id)rpnValue.obj;
}

- (BOOL)valueIsEmpty
{
    if ( rpnValue.typ == SWValueTypeArray )
        return (rpnValue.arrayCount() == 0);
    
    if ( rpnValue.typ == SWValueTypeString )
        return ( CFStringGetLength((CFStringRef)rpnValue.obj) == 0 );
    
    if ( rpnValue.typ == SWValueTypeHash )
        return ( rpnValue.hashCount() == 0 );
    
    return NO;
}


- (NSArray*)valueAsArray
// El metode no suporta arrays amb estructures com CGRect o arrays anidats.
// En general ha de ser mes efectiu utilitzar el fast enumeration en el seu lloc
{
    NSInteger count = rpnValue.arrayCount();
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
    
    for (NSInteger i=0; i<count; ++i) 
    {
        const RPNValue &value = rpnValue.valueAtIndex(i);
        
        switch (value.typ) 
        {
            case SWValueTypeNumber:
                [array addObject:[NSNumber numberWithDouble:valueAsDoubleForRpnValue( value )]];
                break;
                
            case SWValueTypeString:
                [array addObject:(__bridge_transfer NSString*)createStringForRpnValue_withFormat( value, nil )];
                break;
                
            case SWValueTypeObject:
                [array addObject:(__bridge_transfer id)value.obj];
                break;
                
            default:
                // no suportem estructures ni arrays ni absolute times
                NSLog(@"[plok99] CASE NOT POSSIBLE (%@)",NSStringFromSWValueType(value.typ));
                [array addObject:[NSNull null]];
                break;
        }
    }
    
    return array;
}

- (NSDictionary*)valueAsDictionary
// El metode nomes suporta diccionaris amb string keys i objectes que siguin numeros o strings
// Les keys han de ser strings
{
    NSInteger count = rpnValue.hashCount();
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //[dict setObject:@1 forKey:@"pep"];
    
    if ( count > 0 )
    {
        const RPNValue *keys[count];
        const RPNValue *values[count];
        
        rpnValue.getHashKeysAndValues(keys, values);
        
        for (NSInteger i=0; i<count; ++i) 
        {
            const RPNValue *key = keys[i];
            const RPNValue *rpValue = values[i];
            
            NSString *sKey = (__bridge_transfer NSString*)createStringForRpnValue_withFormat( *key, nil );
                // ^-- atencio pot crear keys esoteriques si key no es string
            
            switch (rpValue->typ)
            {
                case SWValueTypeNumber:
                {
                    NSNumber *number = [NSNumber numberWithDouble:valueAsDoubleForRpnValue( *rpValue )];
                    [dict setObject:number forKey:sKey];
                    break;
                }
                case SWValueTypeString:
                {
                    NSString *string = (__bridge_transfer NSString*)createStringForRpnValue_withFormat( *rpValue, nil );
                    [dict setObject:string forKey:sKey];
                    break;
                }
                
                // si el value no es ni string ni number no creem la key en el diccionari
//                default:
//                    // no suportem estructures ni arrays ni absolute times
//                    NSLog(@"[plok99] CASE NOT POSSIBLE (%@)",NSStringFromSWValueType(value.typ));
//                    [array addObject:[NSNull null]];
//                    break;
            }
        }
    }
    return dict;
}



- (NSDictionary*)valueAsDictionaryWithValues
// El metode nomes suporta diccionaris amb string keys i objectes que siguin numeros o strings
// Les keys han de ser strings
{
    NSInteger count = rpnValue.hashCount();
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //[dict setObject:@1 forKey:@"pep"];
    
    if ( count > 0 )
    {
        const RPNValue *keys[count];
        const RPNValue *values[count];
        
        rpnValue.getHashKeysAndValues(keys, values);
        
        for (NSInteger i=0; i<count; ++i) 
        {
            const RPNValue *key = keys[i];
            const RPNValue *rpValue = values[i];
            
            NSString *sKey = (__bridge_transfer NSString*)createStringForRpnValue_withFormat( *key, nil );
                // ^-- atencio pot crear keys esoteriques si key no es string
            
            SWValue *value = [[SWValue alloc] initWithRPNValue:*rpValue];
            [dict setObject:value forKey:sKey];
        }
    }
    return dict;
}






- (BOOL)valueAsBool
{
    //return [self valueAsInteger] != 0;  // Atencio aixo es incorrecte
    return valueAsDoubleForRpnValue( rpnValue ) != 0.0;
}

- (int)valueAsInteger
{
    return (int)valueAsDoubleForRpnValue( rpnValue );
}

- (UInt32)valueAsRGBColor
{
    UInt32 colorValue = Theme_RGB(0, 255, 255, 255) ;   // per defecte blanc  (podria ser negre o gris fosc)
    SWValueType valueType = rpnValue.typ;
    
    // utilitzacio de SM.Color  ( retorna un 'colorValue' numeric ) (normalment nomes fariem això)
    if ( valueType == SWValueTypeNumber ) colorValue = valueAsDoubleForRpnValue( rpnValue );
    
    // suport per el nom del color directament ( retorna una string, per exemple "blue" )
    if ( valueType == SWValueTypeString ) 
    {
        CFStringRef str = createStringForRpnValue_withFormat( rpnValue, nil ) ;
        colorValue = getRgbValueForString( (__bridge id)str ) ;
        if ( str ) CFRelease( str ) ;
    }
    return colorValue;
}


- (UIColor*)valueAsColor
{
    UInt32 colorValue = [self valueAsRGBColor];
    return UIColorWithRgb(colorValue) ;
}

#pragma mark Array Support

//- (NSInteger)countz
//{
//    int count = rpnValue.arrayCount();
//    
//    if ( count == 0 ) 
//        count = 1;
//    
//    return count;
//}


- (NSInteger)count
{
    if ( rpnValue.typ == SWValueTypeArray )
        return rpnValue.arrayCount();
    
    return 1;
}


//- (SWValue*)valueAtIndexZ:(NSInteger)index
//{
//    SWValue *result = nil;
//    
//    int count = rpnValue.arrayCount();
//    
//    if ( index == 0 && count == 0 ) 
//    {
//        result = self;
//    } 
//    else if ( index >= 0 && index < count ) 
//    {
//        const RPNValue& value = rpnValue.valueAtIndex(index);
//        result = [[SWValue alloc] initWithRPNValue:value];
//    }
//    
//    return result;
//}


- (SWValue*)valueAtIndex:(NSInteger)index
{
    SWValue *result = nil;
    
    if ( rpnValue.typ == SWValueTypeArray )
    {
        int count = rpnValue.arrayCount();
        if ( index >= 0 && index < count )
        {
            const RPNValue& value = rpnValue.valueAtIndex(index);
            result = [[SWValue alloc] initWithRPNValue:value];
        }
    }
    
    else if ( index == 0 )
    {
        result = self;
    }
    
    return result;
}


- (double)doubleAtIndex:(NSInteger)index
{
    double result = 0;
    
    if ( rpnValue.typ == SWValueTypeArray )
    {
        int count = rpnValue.arrayCount();
        if ( index >= 0 && index < count )
        {
            const RPNValue& value = rpnValue.valueAtIndex(index);
            result = valueAsDoubleForRpnValue(value);
        }
    }
    
    else if ( index == 0 )
    {
        result = valueAsDoubleForRpnValue(rpnValue);
    }
    
    return result;
}


- (id)valuesAsStrings
{
    if ( rpnValue.typ == SWValueTypeArray )
    {
        CFArrayRef cfArray = createStringsArrayForRpnValue_withFormat(rpnValue, nil);
        NSArray *array = CFBridgingRelease(cfArray);
        return array;
    }

    CFStringRef cfString = createStringForRpnValue_withFormat(rpnValue, nil);
    NSString *string = CFBridgingRelease(cfString);
    return string;
}

- (CFDataRef)createDataWithValuesAsDoubles
{
    return createDataWithDoublesForRpnValue( rpnValue );
}


- (CFArrayRef)createArrayWithValuesAsStringsWithFormat:(NSString*)format
{
    return createStringsArrayForRpnValue_withFormat(rpnValue,  (__bridge CFStringRef)format);
}


#pragma mark Dictionary Support

- (SWValue*)valueForStringKey:(NSString*)key
{
    SWValue *result = nil;
    
    int count = rpnValue.hashCount();
    
    if ( count > 0 )
    {
        const RPNValue *rpValue = rpnValue.getHashValueForKey( (__bridge CFStringRef)key );
        if ( rpValue )
            result = [[SWValue alloc] initWithRPNValue:*rpValue];
    }
    
    if ( result == nil )
    {
        result = [[self getDefaultValue] valueForStringKey:key];
    }
    
    return result;
}


- (SWValue*)valueForValueKey:(SWValue*)key
{
    SWValue *result = nil;
    
    int count = rpnValue.hashCount();
    
    if ( count > 0 )
    {
        const RPNValue& rpKey = key.rpnValue;
        const RPNValue *rpValue = rpnValue.getHashValueForKey( rpKey );
        if ( rpValue )
            result = [[SWValue alloc] initWithRPNValue:*rpValue];
    }
    
    if ( result == nil )
    {
        result = [[self getDefaultValue] valueForValueKey:key];
    }
    
    return result;
}



#pragma mark Setters

- (void)setValueFromValue:(SWValue*)value
{
    if ([_holder respondsToSelector:@selector(registerToUndoManagerCurrentValue:)])
        [_holder registerToUndoManagerCurrentValue:self];
    
    [self evalWithValue:value];
}

- (void)setValueAsDouble:(double)value
{
    if ([_holder respondsToSelector:@selector(registerToUndoManagerCurrentValue:)])
        [_holder registerToUndoManagerCurrentValue:self];
    
    [self evalWithDouble:value];
}

- (void)setValueAsAbsoluteTime:(CFAbsoluteTime)value
{
    if ([_holder respondsToSelector:@selector(registerToUndoManagerCurrentValue:)])
        [_holder registerToUndoManagerCurrentValue:self];
    
    [self evalWithAbsoluteTime:value];
}

- (void)setValueAsCGPoint:(CGPoint)value
{
    if ([_holder respondsToSelector:@selector(registerToUndoManagerCurrentValue:)])
        [_holder registerToUndoManagerCurrentValue:self];
    
    [self evalWithCGPoint:value];
}

- (void)setValueAsCGSize:(CGSize)value
{
    if ([_holder respondsToSelector:@selector(registerToUndoManagerCurrentValue:)])
        [_holder registerToUndoManagerCurrentValue:self];
    
    [self evalWithCGSize:value];
}

- (void)setValueAsCGRect:(CGRect)value
{
    if ([_holder respondsToSelector:@selector(registerToUndoManagerCurrentValue:)])
        [_holder registerToUndoManagerCurrentValue:self];
    
    [self evalWithCGRect:value];
}

- (void)setValueAsString:(NSString*)value
{
    if ([_holder respondsToSelector:@selector(registerToUndoManagerCurrentValue:)])
        [_holder registerToUndoManagerCurrentValue:self];
    
    [self evalWithString:value];
}

- (void)setValueAsObject:(id <QuickCoding, SymbolicCoding>)value
{
    if ([_holder respondsToSelector:@selector(registerToUndoManagerCurrentValue:)])
        [_holder registerToUndoManagerCurrentValue:self];
    
    [self evalWithObject:value];
}

- (void)setValueAsArray:(NSArray*)value
{
    if ([_holder respondsToSelector:@selector(registerToUndoManagerCurrentValue:)])
        [_holder registerToUndoManagerCurrentValue:self];
    
    [self evalWithArray:value];
}

- (void)setValueAsDoubles:(const double *)nums count:(const int)count;
{
    if ([_holder respondsToSelector:@selector(registerToUndoManagerCurrentValue:)])
        [_holder registerToUndoManagerCurrentValue:self];
    
    [self evalWithDoubles:nums count:count];
}

#pragma mark Evaluers

- (void)evalWithValue:(SWValue*)value
{
    rpnValue = value->rpnValue;
    
    doDidEvaluateReferenceableValue_withChange( self, NO );
    [self promote];
}


- (void)evalWithDouble:(double)value
{
    rpnValue = value;
        
    doDidEvaluateReferenceableValue_withChange( self, NO );
    [self promote];
}

- (void)evalWithAbsoluteTime:(CFAbsoluteTime)value
{
    rpnValue = value+NSTimeIntervalSince1970;
    rpnValue.typ = SWValueTypeAbsoluteTime;
        
    doDidEvaluateReferenceableValue_withChange( self, NO );
    [self promote];
}

- (void)evalWithCGPoint:(CGPoint)value
{
    rpnValue = value;
    
    doDidEvaluateReferenceableValue_withChange( self, NO );
    [self promote];
}

- (void)evalWithCGSize:(CGSize)value
{
    rpnValue = value;
    
    doDidEvaluateReferenceableValue_withChange( self, NO );
    [self promote];
}

- (void)evalWithCGRect:(CGRect)value
{
    rpnValue = value;
    
    doDidEvaluateReferenceableValue_withChange( self, NO );
    [self promote];
}

- (void)evalWithString:(NSString*)value
{
    rpnValue = (__bridge CFStringRef)value;
    
    doDidEvaluateReferenceableValue_withChange( self, NO );
    [self promote];
}

- (void)evalWithObject:(id <QuickCoding,SymbolicCoding>)value
{
    NSAssert( NO, @"Not implemented" );
//    rpnValue = (__bridge CFTypeRef)value;
//    
//    doDidEvaluateReferenceableValue_withChange( self, NO );
//    [self promote];
}


- (void)evalWithArray:(NSArray*)array
{
    [self _primitiveSetRpnValueWithArray:array];
        
    doDidEvaluateReferenceableValue_withChange( self, NO );
    [self promote];
}


- (void)evalWithDoubles:(const double *)nums count:(const int)count
{
    rpnValue = RPNValue(nums,count);
    
    doDidEvaluateReferenceableValue_withChange( self, NO );
    [self promote];
}



#pragma mark Private Methods


- (void)_primitiveSetRpnValueWithArray:(NSArray*)array
{
    NSInteger count = array.count;
        
    RPNValue *values = new RPNValue[count];

    for (NSInteger i=0; i<count; ++i)
    {
        id object = [array objectAtIndex:i];
    
        if ([object isKindOfClass:[NSString class]])
        {
            NSString *string = object;
            values[i] = (__bridge CFStringRef)string;
        }
        else if ([object isKindOfClass:[NSNumber class]])
        {
            NSNumber *number = object;
            values[i] = number.doubleValue ;
        }
        else if ( [object isKindOfClass:[NSArray class]])
        {
            SWValue *value = [SWValue valueWithArray:object];
            values[i] = value.rpnValue;
        }
        else if ( [object isKindOfClass:[NSDictionary class]])
        {
            SWValue *value = [SWValue valueWithDictionary:object];
            values[i] = value.rpnValue;
        }
        else if ([object isKindOfClass:[SWValue class]])
        {
            SWValue *value = object;
            values[i] = value.rpnValue;
        }
        else
        {
            NSAssert([object conformsToProtocol:@protocol(QuickCoding)], nil);
            NSAssert([object conformsToProtocol:@protocol(SymbolicCoding)], nil);
            NSAssert( NO, @"Not implemented" );
            //values[i] = (__bridge CFTypeRef)object;
        }
    }
    
    rpnValue.arrayMake(count, values);
    
    delete [] values;
}




- (void)_primitiveSetRpnValueWithDictionary:(NSDictionary*)dict
{
    NSInteger count = dict.count;
        
    __block RPNValue *keyValuePairs = new RPNValue[count*2];
    __block int i = 0;
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {
        if ( [key isKindOfClass:[NSString class]] )  // <<- atencio nomes suportem keys que son NSStrings o NSNumbers
            keyValuePairs[i] = (__bridge CFStringRef)key;   
        else if ( [key isKindOfClass:[NSNumber class]] )
            keyValuePairs[i] = [key doubleValue];
        
        //id object = [dict objectForKey:key];
        id object = obj;
    
        if ([object isKindOfClass:[NSString class]])
        {
            NSString *string = object;
            keyValuePairs[i+1] = (__bridge CFStringRef)string;
        }
        else if ([object isKindOfClass:[NSNumber class]])
        {
            NSNumber *number = object;
            keyValuePairs[i+1] = number.doubleValue ;
        }
        else if ( [object isKindOfClass:[NSArray class]])
        {
            SWValue *value = [SWValue valueWithArray:object];
            keyValuePairs[i+1] = value.rpnValue;
        }
        else if ( [object isKindOfClass:[NSDictionary class]])
        {
            SWValue *value = [SWValue valueWithDictionary:object];
            keyValuePairs[i+1] = value.rpnValue;
        }
        else if ([object isKindOfClass:[SWValue class]])
        {
            SWValue *value = (id)object;
            keyValuePairs[i+1] = value.rpnValue;
        }
        else
        {
            NSAssert([object conformsToProtocol:@protocol(QuickCoding)], nil);
            NSAssert([object conformsToProtocol:@protocol(SymbolicCoding)], nil);
            NSAssert( NO, @"Not implemented" );
            //keyValuePairs[i+1] = (__bridge CFTypeRef)object;
        }
        
        i += 2;
    }];
    
    rpnValue.hashMake( count*2, keyValuePairs );
    //rpnValue.hashLog();

    delete [] keyValuePairs;
}





#pragma mark Private Methods

// populates an expression change
- (void)promoteV
{
    if ( dependants )
    {
        CFIndex count = CFArrayGetCount(dependants);
        for ( CFIndex i=0; i<count; i++ )
        {
            __unsafe_unretained SWValue *expr = (__bridge id)CFArrayGetValueAtIndex(dependants, i);
            [expr eval];
        }
    }
}


//// populates an expression change
//- (void)promote
//{
//    if ( dependants )
//    {
//        condition.expressionConditionPromoting = 1; // posem a 1
//        CFIndex count = CFArrayGetCount(dependants);
//        for ( CFIndex i=0; i<count; i++ )
//        {
//            __unsafe_unretained SWValue *value = (__bridge id)CFArrayGetValueAtIndex(dependants, i);
//            [value evalFromOriginator:self];
//        }
//    }
//    condition.expressionConditionPromoting = 0; // posem a 0
//}


// populates an expression change
- (void)promoteBO
{
    if ( dependants )
    {
        condition.expressionConditionPromoting = 1; // posem a 1
        CFIndex count = CFArrayGetCount(dependants);
        for ( CFIndex i=0; i<count; i++ )
        {
            __unsafe_unretained SWValue *value = (__bridge id)CFArrayGetValueAtIndex(dependants, i);
            BOOL shouldPromote = [value evalFromOriginator:self];
            if ( shouldPromote ) [value promote];
        }
    }
    condition.expressionConditionPromoting = 0; // posem a 0
}



// populates an expression change
- (void)promote
{

    //NSLog( @"promote:%@", [self.holder identifier]);

    if ( dependants )
    {
        condition.expressionConditionPromoting = 1; // posem a 1
        CFIndex count = CFArrayGetCount(dependants);
        for ( CFIndex i=0; i<count; i++ )
        {
            __unsafe_unretained SWValue *value = (__bridge id)CFArrayGetValueAtIndex(dependants, i);
            value->condition.expressionConditionShouldPromote = [value evalFromOriginator:self];;
        }
    
        for ( CFIndex i=0; i<count; i++ )
        {
            __unsafe_unretained SWValue *value = (__bridge id)CFArrayGetValueAtIndex(dependants, i);
            if ( value->condition.expressionConditionShouldPromote)
            {
                [value promote];
                value->condition.expressionConditionShouldPromote = 0;
            }
        }
    }
    
    condition.expressionConditionPromoting = 0; // posem a 0
}

- (ExpressionKind)kind
{
    return ExpressionKindConst;
}








//- (void)eval
//{
//    [self evalFromOriginator:nil];
//}


- (void)eval
{
    BOOL shouldPromote = [self evalFromOriginator:nil];
    if ( shouldPromote ) [self promote];
}


#pragma mark Overridable Methods

//- (void)evalFromOriginator:(SWValue*)value
//{
//    doDidEvaluateReferenceableValue_withChange( self, NO );
//    [self promote];
//}


- (BOOL)evalFromOriginator:(SWValue*)value
{
    doDidEvaluateReferenceableValue_withChange( self, NO );
    return YES;
}


- (void)evalWithDisconnectedSource
{
    // do nothing. Subclasses may override
}


#pragma mark Protocol NSFastEnumeration

//// suport per fast enumeration
//// ( mes info a http://cocoawithlove.com/2008/05/implementing-countbyenumeratingwithstat.html )
//// ( i a http://www.informit.com/articles/article.aspx?p=1436920&seqNum=5 )
//- (NSUInteger)countByEnumeratingWithStateV:(NSFastEnumerationState *)state
//                                  objects:(id __unsafe_unretained [])stackbuf 
//                                    count:(NSUInteger)len
//{
//    static unsigned long mutationsDummy = 0;
//    
//    // posem un valor invariable al mutationsPtr
//    state->mutationsPtr = &mutationsDummy;
//    
//    // mida total del array a iterar
//    NSUInteger arrayCount = rpnValue.arrayCount();
//    
//    
//    // [1] - si no es un array farem una unica iteracio tornant ell mateix
//    if ( arrayCount == 0 )
//    {
//        if ( state->state == 1 ) // si ja hem fet la iteracio, tornem zero
//        {
//            return 0;
//        }
//        state->state = 1;          // 1 per la seguent iteracio
//        state->itemsPtr = (id __unsafe_unretained *)(void*)&self;   // tornem ell mateix
//        return 1;                  // la longitud es de 1 element
//    }
//    
//    // [2] - alternativa a 1:
//    // si no es un array tornarem un SWValue creat d'ell mateix
//    // if ( arrayCount == 0 ) arrayCount = 1 ;
//    
//    // alliberem els valors passats en la ronda anterior
//    for ( int i=0; i<state->extra[0]; i++ )
//    {
//        //[stackbuf[i] release];
//        CFRelease( (__bridge CFTypeRef)stackbuf[i] );  // forcem el release !
//        stackbuf[i] = nil;
//    }
//    
//    // copiem la seguent ronda de valors
//    unsigned long offset = state->state;
//    unsigned long n = arrayCount - offset;
//    if ( n > len ) n = len;
//    
//    for ( unsigned long i=0; i<n; i++ )
//    {
//        const RPNValue &currentRpnValue = rpnValue.valueAtIndex( i+offset );
//        CFTypeRef value = (__bridge_retained CFTypeRef)[[SWValue alloc] initWithRPNValue:currentRpnValue];
//        stackbuf[i] = (__bridge __unsafe_unretained id)value;
//    }
//    
//    state->state = n+offset;       // punt de partida per la seguent iteracio
//    state->itemsPtr = stackbuf;    // punter al buffer amb els objectes
//    state->extra[0] = n;           // utilitzem extra[0] per posar la longitud anterior utilitzada del buffer
//    return n;                      // longitud utilitzada del buffer
//}



// suport per fast enumeration
// ( mes info a http://cocoawithlove.com/2008/05/implementing-countbyenumeratingwithstat.html )
// ( i a http://www.informit.com/articles/article.aspx?p=1436920&seqNum=5 )
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state 
                                  objects:(id __unsafe_unretained [])stackbuf 
                                    count:(NSUInteger)len
{
    static unsigned long mutationsDummy = 0;
    
    // posem un valor invariable al mutationsPtr
    state->mutationsPtr = &mutationsDummy;
    
    // [1] - si no es un array farem una unica iteracio tornant ell mateix
    if ( rpnValue.typ != SWValueTypeArray )
    {
        if ( state->state == 1 ) // si ja hem fet la iteracio, tornem zero
        {
            return 0;
        }
        state->state = 1;          // 1 per la seguent iteracio
        state->itemsPtr = (id __unsafe_unretained *)(void*)&self;   // tornem ell mateix
        return 1;                  // la longitud es de 1 element
    }
    
    // [2] - alternativa a 1:
    // si no es un array tornarem un SWValue creat d'ell mateix
    // if ( arrayCount == 0 ) arrayCount = 1 ;
    
    // alliberem els valors passats en la ronda anterior
    for ( int i=0; i<state->extra[0]; i++ )
    {
        //[stackbuf[i] release];
        CFRelease( (__bridge CFTypeRef)stackbuf[i] );  // forcem el release !
        stackbuf[i] = nil;
    }
    
    // mida total del array a iterar
    NSUInteger arrayCount = rpnValue.arrayCount();
    
    // copiem la seguent ronda de valors
    unsigned long offset = state->state;
    unsigned long n = arrayCount - offset;
    if ( n > len ) n = len;
    
    for ( unsigned long i=0; i<n; i++ )
    {
        const RPNValue &currentRpnValue = rpnValue.valueAtIndex( i+offset );
        CFTypeRef value = (__bridge_retained CFTypeRef)[[SWValue alloc] initWithRPNValue:currentRpnValue];
        stackbuf[i] = (__bridge __unsafe_unretained id)value;
    }
    
    state->state = n+offset;       // punt de partida per la seguent iteracio
    state->itemsPtr = stackbuf;    // punter al buffer amb els objectes
    state->extra[0] = n;           // utilitzem extra[0] per posar la longitud anterior utilitzada del buffer
    return n;                      // longitud utilitzada del buffer
}


#pragma mark Potocol QuickCoder

- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super init];   
    
    // decodifiquem el valor
    rpnValue.decode(decoder);
    
    // decodifiquem el holder
    _holder = [decoder decodeObject];    // asignacio weak, no retenim pero es mantindra autoreleased fins el final de la codificacio
    
    // creem els dependants
    int count = [decoder decodeInt];
    if ( count > 0 )
    {
        dependants = CFArrayCreateMutable(NULL, 0, NULL);
        for ( int i=0; i<count; i++ )
        {
            SWExpression *expr = [decoder decodeObject]; // no retingut per ell mateix
            CFArrayAppendValue(dependants, (__bridge CFTypeRef)expr);
        }
    }
    
    //NSLog(@"EXP Init %x: %@, %@.%@",(unsigned)self, [self getSourceString], [self symbol], [self getName]);
    
    return self;
}

- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
{
    
    //NSLog(@"EXP Encoder: <%@> isZombie: %@",[self getSourceString],STRBOOL((self->condition & ExpressionConditionZombie)));
        
    // codifiquem el valor
    rpnValue.encode(encoder);

    // codifiquem el holder
    [encoder encodeObject:_holder];
    
    // codifiquem el numero de items i el contingut de dependants
    if ( dependants )
    {
        int count = CFArrayGetCount(dependants);
        [encoder encodeInt:count];   
        for ( int i=0; i<count; i++ )
        {
            __unsafe_unretained SWExpression *expr = (__bridge id)CFArrayGetValueAtIndex(dependants, i);
            [encoder encodeObject:expr];
        }
    }
    else
    {
        [encoder encodeInt:0]; 
    }
}

- (void)retrieveWithQuickCoder:(QuickUnarchiver *)decoder
{
    rpnValue.decode(decoder);
}

- (void)storeWithQuickCoder:(QuickArchiver *)encoder
{
    rpnValue.encode(encoder);
}

#pragma mark Protocol SWExpressionSourceObject

//- (NSString*)fullReferenceV
//{    
//    NSString *symbol = [_holder symbolForValue:self];
//    
//    if ( symbol == nil ) 
//        return @"<unknown>";
//    
//    NSString *property = nil;
//       
//    if ( [_holder respondsToSelector:@selector(propertyForValue:)] )
//        property = [_holder propertyForValue:self];
//    
//    if ( property ) 
//        return [NSString stringWithFormat:@"%@.%@", symbol, property];
//    
//    return symbol;
//}


- (NSString*)fullReference
{    
    NSString *symbol = [_holder symbolForValue:self];
    
    if ( symbol == nil ) 
        return @"<unknown>";
    
    NSString *property = nil;
    
    if ( [_holder respondsToSelector:@selector(propertyForValue:)] )
        property = [_holder propertyForValue:self];
    
    if ( property ) 
        symbol = [NSString stringWithFormat:@"%@.%@", symbol, property];
    
    if ( self->condition.expressionConditionAsleep)
    {
        symbol = [NSString stringWithFormat:@"<%@>", symbol];
    }
    
    return symbol;
}



- (NSString *)symbol
{
    return [_holder symbolForValue:self];
}

- (NSString *)property
{
    return [_holder propertyForValue:self];
}

@end

#pragma mark - Category RpnInterpreter

@implementation SWValue (RPNInterpreter)

- (const RPNValue&)rpnValue
{
    return rpnValue;
}


@end


#pragma mark - C Methods

@implementation SWValue (CMethods)

static void doExpressionNameDidChange( SWValue * value )
{
    if ( value->observers )
    {
        CFIndex obCount = CFArrayGetCount( value->observers  );
        for ( CFIndex j=0; j<obCount; j++ )
        {
            __unsafe_unretained id<ValueObserver>observer = (__bridge id)CFArrayGetValueAtIndex( value->observers, j );
            if ( [observer respondsToSelector:@selector(valueDidChangeName:)] )
            {
                [observer valueDidChangeName:value];
            }
        }
    }
}

NSString *stringForDouble_withFormat( double d, NSString *format )
{
    CFStringRef str = createStringForRpnValue_withFormat( d, (__bridge CFStringRef)format ) ;
    return (__bridge_transfer NSString*)str ;
    //return [str autorelease] ;
}

void doDidEvaluateReferenceableValue_withChange(SWValue *value, BOOL changed)
{
    if ( [value->_holder respondsToSelector:@selector(value:didTriggerWithChange:)] )
    {
        [value->_holder value:value didTriggerWithChange:changed];
    }

    if ( value->observers )
    {
        CFIndex count = CFArrayGetCount( value->observers );
        for ( CFIndex i=0; i<count; i++ )
        {
            __unsafe_unretained id<ValueObserver>obj = (__bridge id)CFArrayGetValueAtIndex( value->observers, i );
            [obj value:value didEvaluateWithChange:changed];
        }
    }
}

//static NSString* fullNameForValue(id value)
//{
//    NSString *symbol = nil;
//    NSString *property = nil;
//    
//    if ( [value isKindOfClass:[SWValue class]] )
//    {   
//        id<ValueHolder> holder = [value holder];
//        symbol = [holder symbolForValue:value];
//        
//        if ( [holder respondsToSelector:@selector(propertyForValue:)] )
//            property = [holder propertyForValue:value];
//    }
//    
//    if ( symbol == nil ) 
//        return @"<unknown>";
//    
//    if ( property ) 
//        return [NSString stringWithFormat:@"%@.%@", symbol, property];
//    
//    return symbol;
//}

@end
