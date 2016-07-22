//
//  SWExpression.m
//  HmiPad_101010SJ
//
//  Created by Joan on 04/11/10.
//  Copyright 2010 SweetWilliam, S.L. All rights reserved.
//

#import "SWExpression.h"

#import "RpnInterpreter.h"
#import "SWFormatUtils.h"
#import "RPNValue.h"
#import "SWColor.h"

#pragma mark - SymbolicSource



@implementation SymbolicSource

- (id)init
{
    self = [super init];
    return self;
}

- (id)initWithSymObject:(NSString*)symbol andSymProperty:(NSString*)property
{
    self = [super init];
    if (self) {
        symObject = symbol;
        symProperty = property;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    SymbolicSource *symItem = [[SymbolicSource allocWithZone:zone] init];
    symItem->symObject = [symObject copy];
    symItem->symProperty = [symProperty copy];
    return symItem;
} 

- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super init];
    if (self) {
        symObject = [decoder decodeObject];
        symProperty = [decoder decodeObject];
    }
    return self;
}

- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
{
    [encoder encodeObject:symObject];
    [encoder encodeObject:symProperty];
}

#pragma mark Protocol SWExpressionSourceObject

- (NSString*)fullReference
{
    if ( symProperty ) 
        return [NSString stringWithFormat:@"%@.%@", symObject, symProperty];
        
    return symObject ;
}

- (NSString *)symbol
{
    return symObject;
}

- (NSString *)property
{
    return symProperty;
}

- (id)holder
{
    return nil;
}

- (void)observerCountRetainBy:(int)n
{
    // do nothing
}

- (void)observerCountReleaseBy:(int)n
{
    // do nothing
}

@end

NSString * const NoSourceSym = @"<NoSource>";


#pragma mark - Expression

//UIColor* UIColorForState(UInt8 state)
//{
//    switch (state)
//    {
//        case ExpressionStateOk:
//            return [UIColor greenColor];
//            break;
//        case ExpressionStateInvalid:
//            return [UIColor redColor];
//            break;
//        case ExpressionStateCircular:
//            return [UIColor brownColor];
//            break;
//        
//        default:
//            return [UIColor yellowColor];
//            break;
//    }
//    return nil;
//}

@implementation SWExpression

#pragma mark C Methods

static UInt8 getIndexOfSource_fromExpression( SWValue *source, SWExpression *expr )
{
    UInt8 result = 0xff;
    if ( source && expr->sourceExpressions )
    {
        CFIndex length = CFArrayGetCount(expr->sourceExpressions);
        CFIndex indx = CFArrayGetFirstIndexOfValue(expr->sourceExpressions, CFRangeMake(0,length), (__bridge CFTypeRef)source);
        result = (indx>=0)?indx:0xff;
    }
    return result;
}


static void removeSource_fromExpression( SWValue *source, SWExpression *expr)
{
    if ( expr->sourceExpressions )
    {
        CFIndex length = CFArrayGetCount(expr->sourceExpressions);
        CFIndex indx = CFArrayGetLastIndexOfValue(expr->sourceExpressions, CFRangeMake(0,length), (__bridge CFTypeRef)source );
        if ( indx >= 0 ) CFArrayRemoveValueAtIndex(expr->sourceExpressions, indx);
    }
}

static void removeDependant_fromReferenceableValue( SWExpression *dependant, SWValue *value )
{
    if ( value->dependants )
    {
        CFIndex length = CFArrayGetCount(value->dependants);
        CFIndex indx = CFArrayGetLastIndexOfValue(value->dependants, CFRangeMake(0,length), (__bridge CFTypeRef)dependant );
        if ( indx >= 0 ) 
        {
            CFArrayRemoveValueAtIndex(value->dependants, indx);
//            if ( dependant->kind == ExpressionKindCluster ) 
//            {
//                __unsafe_unretained SWExpression *expr = (SWExpression*)value ;
//                expr->clusterDependantCount -= 1;   // nomes suportem clusters de expressions
//            }
        }
    }
}

//static void addDependant_toExpression( SWExpression *dependant, SWExpression *expr )
static void addDependant_toReferenceableValue( SWExpression *dependant, SWValue *value )
{
    if ( dependant == nil || value == nil ) return;
    if ( value->dependants == NULL ) value->dependants = CFArrayCreateMutable(NULL, 0, NULL);
    CFArrayAppendValue( value->dependants, (__bridge CFTypeRef)dependant );
//    if ( dependant->kind == ExpressionKindCluster ) 
//    {
//        __unsafe_unretained SWExpression *expr = (SWExpression*)value ;
//        expr->clusterDependantCount += 1;  // nomes suportem clusters de expressions
//    }
}

static void addSource_toExpression( id source, SWExpression *expr )
{
    if ( source == NULL || expr == nil ) return; 
    if ( expr->sourceExpressions == NULL ) expr->sourceExpressions = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
    CFArrayAppendValue( expr->sourceExpressions, (__bridge CFTypeRef)source );
}

static void unlinkExpressionFromSources( SWExpression *expr )
{
    if ( expr->sourceExpressions == NULL ) return;
    
    CFIndex count = CFArrayGetCount( expr->sourceExpressions );
    if ( count )
    {
        for ( CFIndex i=0; i<count; i++ )
        {
            __unsafe_unretained SWValue *source = (__bridge id)CFArrayGetValueAtIndex(expr->sourceExpressions, i);
            if ( ![source isKindOfClass:[SWValue class]] ) continue;

            removeDependant_fromReferenceableValue( expr, source );
        }
        
        CFArrayRemoveAllValues( expr->sourceExpressions );
        CFRelease( expr->sourceExpressions );
        expr->sourceExpressions = NULL;
    }
}

//static void removeExpressionFromClusterDependants( SWExpression *expr )
//{
//    if ( expr->dependants == NULL ) return;
//    
//    CFIndex count = CFArrayGetCount( expr->dependants );
//    if ( count )
//    {
//        for ( CFIndex i=0; i<count; i++ )
//        {
//            __unsafe_unretained SWExpression *dependant = (__bridge id)CFArrayGetValueAtIndex( expr->dependants, i);
//            if ( dependant->kind == ExpressionKindCluster )
//            {
//                removeSource_fromExpression( expr, dependant );
//            }
//        }
//        expr->clusterDependantCount = 0;
//    }
//}

static void setSingleSource_toExpression( CFTypeRef source, SWExpression *expr )
{
    if ( expr == nil ) return;
    unlinkExpressionFromSources( expr );
    //if ( expr->sourceExpressions ) CFRelease( expr->sourceExpressions ), expr->sourceExpressions = NULL;
    if ( source )
    {
        expr->sourceExpressions = CFArrayCreateMutable(NULL, 1, &kCFTypeArrayCallBacks);
        CFArrayAppendValue( expr->sourceExpressions, source );
    }
}

static void doExpressionSourceStringDidChange( SWExpression * expr )
{
    //expr->condition &= ~ExpressionConditionSourceChanged;  // posa a 0
    expr->condition.expressionConditionSourceChanged = 0;
    if ( expr->observers )
    {
        CFIndex obCount = CFArrayGetCount( expr->observers  );
        for ( CFIndex j=0; j<obCount; j++ )
        {
            __unsafe_unretained id<ExpressionObserver>observer = (__bridge id)CFArrayGetValueAtIndex( expr->observers, j );
            if ( [observer respondsToSelector:@selector(expressionSourceStringDidChange:)] )
            {
                [observer expressionSourceStringDidChange:expr];
            }
        }
    }
}

static NSString *errSymsForExpression( SWExpression *expr )
{
    NSMutableString *errSyms = nil;
    if ( expr->sourceExpressions == NULL ) return errSyms;
    if ( expr->errCode <= ExpressionErrorCodeCommitError ) return errSyms; 
    
    CFIndex count = CFArrayGetCount( expr->sourceExpressions );
    for ( int i=0; i<4; i++ )
    {
        UInt8 sourceIndx = expr->errInfo.sourceIndx[i];
        if ( sourceIndx != 0xff && sourceIndx < count )
        @autoreleasepool
        {
            __unsafe_unretained id<SWExpressionSourceObject> symbol = (__bridge id)CFArrayGetValueAtIndex( expr->sourceExpressions, sourceIndx );
            NSString *fullName = [symbol fullReference];//fullNameForValue( symbol );
            if ( errSyms == nil ) errSyms = [[NSMutableString alloc] initWithFormat:@"'%@'", fullName];
            else [errSyms appendFormat:@", '%@'", fullName];
        }
    }
    return errSyms; // autorelease];
}

static void doDidChangeExpressionState(SWExpression *expression /*, UInt8 oldState*/)
{    
    if (expression->observers)
    {
        CFIndex count = CFArrayGetCount(expression->observers);
        for (CFIndex i=0; i<count; i++)
        {
            __unsafe_unretained id<ExpressionObserver>obj = (__bridge id)CFArrayGetValueAtIndex(expression->observers, i);
            
//            if ([obj respondsToSelector:@selector(expression:didChangeState:)]) 
//            {
//                [obj expression:expression didChangeState:oldState];
//            }
            if ([obj respondsToSelector:@selector(expressionStateDidChange:)])
            {
                [obj expressionStateDidChange:expression];
            }
        }
    }
}

//static void doDidEvalutateExpression_fromOldState_withValueChange(SWExpression *expression, UInt8 oldError, BOOL change)
//{ 
//    if ( /*expression->state != oldState ||*/ expression->rpnResultInfo.state != oldError)
//    {
//        doDidChangeExpressionState(expression /*, oldError*/);
//        change = YES ; // volem indicar change tambe en el cas de canvi de estat
//    }
//    
//    doDidEvaluateReferenceableValue_withChange(expression, change);   // change indica canvi de state o de valor
//}

static void doDidEvalutateExpression_fromOldValue_oldState(SWExpression *expression, const RPNValue &oldValue,  ExpressionStateCode oldState, BOOL forcedChange)
{
    BOOL change = forcedChange ;
    if ( expression->rpnResultInfo.state != oldState)
    {
        doDidChangeExpressionState(expression /*, oldError*/);
        change = YES ; // volem indicar change tambe en el cas de canvi de estat
    }
    
    if ( !change )
    {
        change = oldValue != expression->rpnValue;
    }
    
    // cridem el delegat sempre, amb canvi o no, pero indiquem si hi ha hagut canvi
    doDidEvaluateReferenceableValue_withChange(expression, change);   // change indica canvi de state o de valor
}

#pragma mark Initializers

- (void)_doInitWithConstant
{
    rpnResultInfo.state = ExpressionStateOk;
    rpnResultInfo.sourceIndx = 0xff ;
    kind = ExpressionKindConst;
    //ppp state = ExpressionStateOk;
    //condition = ExpressionConditionNone;
    condition.all = 0;
}

- (id)initWithValue:(SWValue*)value
{
    self = [super initWithValue:value];
    if (self)
    {
        [self _doInitWithConstant];
        rpnResultInfo.state = rpnValue.typ==SWValueTypeError ? ExpressionStateOperationError : ExpressionStateOk;
    }
    return self;
}

- (id)initWithDouble:(double)value
{
    self = [super initWithDouble:value];
    if (self) {
        [self _doInitWithConstant];
    }
    return self;
}

- (id)initWithAbsoluteTime:(CFAbsoluteTime)value
{
    self = [super initWithAbsoluteTime:value];
    if (self) {
        [self _doInitWithConstant];
    }
    return self;
}

- (id)initWithCGPoint:(CGPoint)value
{
    self = [super initWithCGPoint:value];
    if (self) {
        [self _doInitWithConstant];
    }
    return self;
}

- (id)initWithCGSize:(CGSize)value
{
    self = [super initWithCGSize:value];
    if (self) {
        [self _doInitWithConstant];
    }
    return self;
}

- (id)initWithCGRect:(CGRect)value
{
    self = [super initWithCGRect:value];
    if (self) {
        [self _doInitWithConstant];
    }
    return self;
}

- (id)initWithSWValueRange:(SWValueRange)value
{
    self = [super initWithSWValueRange:value];
    if (self) {
        [self _doInitWithConstant];
    }
    return self;
}

- (id)initWithString:(NSString*)value
{
    self = [super initWithString:value];
    if (self) {
        [self _doInitWithConstant];
    }
    return self;
}

//- (id)initWithObject:(id <QuickCoding, SymbolicCoding>)value
//{
//    self = [super initWithObject:value];
//    if (self) {
//        [self doInitWithConstant];
//    }
//    return self;
//}

#pragma mark Overriden Methods

- (void)dealloc
{
    //NSLog( @"SWExpression dealloc:%x", (unsigned)self );
    
    if ( sourceExpressions )
    {
        unlinkExpressionFromSources( self );
    }
    
    if ( constantStrings ) CFRelease( constantStrings ), constantStrings=NULL;
    if ( sourceDependanceSkips ) CFRelease( sourceDependanceSkips ), sourceDependanceSkips=NULL;
    if ( rpnCode ) /*[rpnCode release],*/ rpnCode=nil;
    
//    if ( dependants && clusterDependantCount>0 ) 
//    {
//        removeExpressionFromClusterDependants( self );
//    }
    
    if ( sourceCodeData ) /*[sourceCodeData release],*/ sourceCodeData=nil;
    
    // aqui cridara el super
}

- (void)setValueAsDouble:(double)value
{
    NSAssert(NO, @"CALLING THIS METHOD IN EXPRESSION IS NOT ALLOWED");
}

- (void)setValueAsAbsoluteTime:(double)value
{
    NSAssert(NO, @"CALLING THIS METHOD IN EXPRESSION IS NOT ALLOWED");
}

- (void)setValueAsCGPoint:(CGPoint)value
{
    NSAssert(NO, @"CALLING THIS METHOD IN EXPRESSION IS NOT ALLOWED");
}

- (void)setValueAsCGSize:(CGSize)value
{
    NSAssert(NO, @"CALLING THIS METHOD IN EXPRESSION IS NOT ALLOWED");
}

- (void)setValueAsCGRect:(CGRect)value
{
    NSAssert(NO, @"CALLING THIS METHOD IN EXPRESSION IS NOT ALLOWED");
}

- (void)setValueAsSWValueRange:(SWValueRange)value
{
    NSAssert(NO, @"CALLING THIS METHOD IN EXPRESSION IS NOT ALLOWED");
}

- (void)setValueAsString:(NSString*)value
{
    NSAssert(NO, @"CALLING THIS METHOD IN EXPRESSION IS NOT ALLOWED");
}

- (void)setValueAsObject:(id <QuickCoding, SymbolicCoding>)value
{
    NSAssert(NO, @"CALLING THIS METHOD IN EXPRESSION IS NOT ALLOWED");
}

- (void)setValueAsArray:(NSArray*)array
{
    NSAssert(NO, @"CALLING THIS METHOD IN EXPRESSION IS NOT ALLOWED");
}

- (void)setValueAsDoubles:(const double *)nums count:(const int)count
{
    NSAssert(NO, @"CALLING THIS METHOD IN EXPRESSION IS NOT ALLOWED");
}


- (BOOL)isConstantValue
{
    if ( kind == ExpressionKindConst ) 
        return YES;
    
    if ( sourceExpressions ) 
        return ( CFArrayGetCount(sourceExpressions) == 0 );
    
    return YES;
}

#pragma mark Protocol SWExpressionSourceObject

//- (NSString*)fullReferenceV
//{    
//    NSString *symbol = [_holder symbolForValue:self];
//    
//    if ( symbol == nil ) 
//        return @"<unknown>";
//    
//    //if ( symbol && (self->condition & ExpressionConditionAsleep) )
//    if ( symbol && (self->condition.expressionConditionAsleep) )
//        symbol = [NSString stringWithFormat:@"<%@_disociated>", symbol];
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


//- (NSString*)fullReference
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
//        symbol = [NSString stringWithFormat:@"%@.%@", symbol, property];
//    
//    if ( self->condition.expressionConditionAsleep)
//    {
//        symbol = [NSString stringWithFormat:@"<%@>", symbol];
//    }
//    
//    return symbol;
//}





#pragma mark Public Methods

- (void)evalWithConstantValue:(double)nValue
{
    //ppp UInt8 oldState = state;
    //ppp state = ExpressionStateOk; // posa a 0
    
    RPNValue oldValue = rpnValue;
    ExpressionStateCode oldState = rpnResultInfo.state;
    
    rpnValue = nValue;
    rpnResultInfo.state = ExpressionStateOk;
    rpnResultInfo.sourceIndx = 0xff ;
        
    //doDidEvalutateExpression_fromOldState_withValueChange(self, oldError, changed);
    doDidEvalutateExpression_fromOldValue_oldState(self, oldValue, oldState, NO);
    [self promote];
}

//- (void)evalWithConstantValuesFromData:(CFDataRef)dataValues
//{
//    double *values = (double*)CFDataGetBytePtr(dataValues);
//    int count = CFDataGetLength(dataValues)/sizeof(double);
//    [self evalWithConstantValuesFromCArray:values count:count];  
//}

- (void)evalWithConstantValuesFromData:(CFDataRef)dataValues
{
    RPNValue oldValue = rpnValue;
    ExpressionStateCode oldState = rpnResultInfo.state;
    
    double *values = (double*)CFDataGetBytePtr(dataValues);
    int count = CFDataGetLength(dataValues)/sizeof(double);
    
    rpnValue = RPNValue(values,count);
    rpnResultInfo.state = ExpressionStateOk;
    rpnResultInfo.sourceIndx = 0xff ;
    
    doDidEvalutateExpression_fromOldValue_oldState(self, oldValue, oldState, NO);
    [self promote];
}

- (void)evalWithStringConstant:(CFStringRef)str
{
    //ppp UInt8 oldState = state;
    //ppp state = ExpressionStateOk; // posa a 0
    
    RPNValue oldValue = rpnValue;
    ExpressionStateCode oldState = rpnResultInfo.state;

    rpnValue = str;
    rpnResultInfo.state = ExpressionStateOk;
    rpnResultInfo.sourceIndx = 0xff ;
        
    //doDidEvalutateExpression_fromOldState_withValueChange(self, oldError, changed);
    doDidEvalutateExpression_fromOldValue_oldState(self, oldValue, oldState, NO);
    [self promote];
}

//- (void)evalWithStringConstantsFromCFArray:(CFArrayRef)strArray
//{
//    //ppp UInt8 oldState = state;
//    //ppp state = ExpressionStateOk; // posa a 0
//    UInt8 oldError = rpnResultInfo.state;
//
//    
//    int count = CFArrayGetCount(strArray);
//    CFStringRef cStrArray[count];
//    CFArrayGetValues( strArray, CFRangeMake(0,count), (const void**)cStrArray );
//    
//    //for ( int i=0; i<count; i++ )
//    //{
//    //    NSLog( @"String [%d]:%@", i, cStrArray[i] );
//    //}
//    
//    
//    RPNValue newValue(cStrArray,count);
//    
//    BOOL changed = ( newValue != rpnValue );
//    rpnValue = newValue;
//    rpnResultInfo.all = 0;
//    
//    doDidEvalutateExpression_fromOldState_withValueChange(self, oldError, changed);
//    [self promote];
//}

- (void)evalWithStringConstantsFromCFArray:(CFArrayRef)strArray
{
    RPNValue oldValue = rpnValue;
    ExpressionStateCode oldState = rpnResultInfo.state;

    int count = CFArrayGetCount(strArray);
    CFStringRef cStrArray[count];
    CFArrayGetValues( strArray, CFRangeMake(0,count), (const void**)cStrArray );
    
    //for ( int i=0; i<count; i++ )
    //{
    //    NSLog( @"String [%d]:%@", i, cStrArray[i] );
    //}
    
    rpnValue = RPNValue(cStrArray,count);
    rpnResultInfo.state = ExpressionStateOk;
    rpnResultInfo.sourceIndx = 0xff ;
    
    doDidEvalutateExpression_fromOldValue_oldState(self, oldValue, oldState, NO);
    [self promote];
}

- (void)evalWithForcedState:(ExpressionStateCode)state
{
    ExpressionStateCode oldState = rpnResultInfo.state;
    
    rpnResultInfo.state = state;
    rpnResultInfo.sourceIndx = 0xff;
    
    doDidEvalutateExpression_fromOldValue_oldState(self, rpnValue, oldState, NO);
    [self promote];
}

- (void)invalidate
{
    [super invalidate];
    [self evalWithForcedState:ExpressionStateInvalidSource];
}

//- (void)invalidatee
//{
//    ExpressionStateCode oldState = rpnResultInfo.state;
//    
//    //rpnResultInfo.state = ExpressionStateInvalidSource;
//    rpnResultInfo.state = ExpressionStateBadQualitySource;
//    rpnResultInfo.sourceIndx = 0xff;
//    
//    //doDidEvalutateExpression_fromOldState_withValueChange(self, oldError, NO);
//    
//    doDidEvalutateExpression_fromOldValue_oldState(self, rpnValue, oldState);
//    [self promote];
//}
//
//- (void)invalidatep
//{
//    ExpressionStateCode oldState = rpnResultInfo.state;
//    
//    rpnResultInfo.state = ExpressionStatePendingSource;
//    rpnResultInfo.sourceIndx = 0xff;
//    
//    //doDidEvalutateExpression_fromOldState_withValueChange(self, oldError, NO);
//    
//    doDidEvalutateExpression_fromOldValue_oldState(self, rpnValue, oldState);
//    [self promote];
//}

- (ExpressionStateCode)state;
{
    //return state;
    return rpnResultInfo.state;
}

- (ExpressionKind)kind;
{
    return kind;
}

//- (BOOL)isPromoting
//{
//    //return (condition & ExpressionConditionPromoting) != 0;
//    return condition.expressionConditionPromoting != 0;
//}

- (NSString *)getSourceString
{
    UInt8 *begin = (UInt8*)[sourceCodeData bytes];
    UInt8 *end = begin + [sourceCodeData length];
    
    if ( begin == end )
    {
        // si no tenim source en generem una (si podem) a partir del tipus d'expressio
        if ( kind == ExpressionKindConst )
        {
            return [super getSourceString];
        }
        return nil; // return @"<no source info available>";
    } 
    
    // generem el source a partir del sourceCodeData i els sources
    NSMutableString *sourceTxt = [NSMutableString string];
   
    for ( UInt8 *p = begin; p<end; )
    {
        UInt8 var = *p;
        p+=sizeof(UInt8);
        
        if ( var != 0xff )
        {
            __unsafe_unretained SWExpression *source = (__bridge id)CFArrayGetValueAtIndex( sourceExpressions, var );
            //NSString *varName = symbolForExpression( source );    // aqui posar fullNameForExpression
            NSString *varName = [source fullReference];//fullNameForValue( source );    // aqui posar fullNameForValue
            [sourceTxt appendString:varName];
        }
        
        UInt16 siz = *(UInt16*)p;
        p+=sizeof(UInt16);
        
        if ( siz > 0 )
        {
            CFStringRef part = CFStringCreateWithBytesNoCopy(NULL, p, siz, kCFStringEncodingUTF8, false, kCFAllocatorNull);
            [sourceTxt appendString:(__bridge id)part];
            if ( part ) CFRelease( part );
        }
        
        p+=siz;
    }
    
    return sourceTxt;
}

- (ExpressionErrorCode)errorCode
{
    return errCode;
}

- (NSString*)_getPrimitiveOperationErrorString
{
    NSString *errStr = nil;
    if ( rpnValue.typ == SWValueTypeError )
    {
        switch ( rpnValue.err )
        {
            case RPNVaErrorWrongType:
            case RPNVaErrorCodedWrongType:
                errStr = @"RpnInterpreterIncompatibleType";
                break;
                        
            case RPNVaErrorWrongTypeForMethod:
                errStr = @"RpnInterpreterIncompatibleTypeForMethod";
                break;
            
            case RPNVaErrorArrayBounds:
                errStr = @"RpnInterpreterArrayBoundsError";
                break;
                
            case RPNVaErrorStringBounds:
                errStr = @"RpnInterpreterStringBoundsError";
                break;
                
            case RPNVaErrorHashBounds:
                errStr = @"RpnInterpreterHashBoundsError";
                break;
                
            case RPNVaErrorNumArguments:
                errStr = @"RpnInterpreterNumArgumentsError";
                break;
                
            case RPNVaErrorArgumentsType:
                errStr = @"RpnInterpreterArgumentsTypeError";
                break;
                        
            case RPNVaErrorBitNumArguments:
                errStr = @"RpnInterpreterBitNumArguments";
                break;
                    
            case RPNVaErrorBitArgumentsType:
                errStr = @"RpnInterpreterBitArgumentsType";
                break;
                        
            case RPNVaErrorStringArgumentsType:
                errStr = @"RpnInterpreterStringArgumentsType";
                break;
                    
            case RPNVaErrorArrayNumArguments:
                errStr = @"RpnInterpreterArrayNumArguments";
                break;
                    
            case RPNVaErrorArrayArgumentsType:
                errStr = @"RpnInterpreterArrayArgumentsType";
                break;
                
            case RPNVaErrorHashArgumentsTypeError:
                errStr = @"RpnInterpreterHashArgumentsTypeError";
                break;
                
            case RPNVaErrorHashOddNumItems:
                errStr = @"RpnInterpreterHashOddNumItems";
                break;
                
            case RPNVaErrorHashItemsTypeError:
                errStr = @"RpnInterpreterHashItemsTypeError";
                break;
                
            case RPNVaErrorHashNumArguments:
                errStr = @"RpnInterpreterHashNumArguments";
                break;
                
            case RPNVaErrorEnumerableItemsTypeError:
                errStr = @"RpnInterpreterEnumerableItemsTypeError";
                break;
                
            case RPNVaErrorEnumerableNumItems:
                errStr = @"RpnInterpreterEnumerableNumItems";
                break;
                        
            default :
                errStr = @"RpnInterpreterUnknownError";
                break;
        }
    }
    return errStr;
}

// A partir de la informacio continguda a errInfo genera una string amb la descripcio de l'error.
- (NSString*)getSourceErrorString
{
    NSString *errTxt = nil;
    if ( errCode == 0 ) return errTxt;
    
    if ( errCode < ExpressionErrorCodeCommitError )
        // errors de parseig
    {
        UInt8 *begin = (UInt8*)[sourceCodeData bytes];
        UInt8 *p = begin;
        
        p+=sizeof(UInt8);  // saltem var
        
        UInt16 siz = *(UInt16*)p;  // determinem siz
        p+=sizeof(UInt16);
        
        UInt16 offset = errInfo.sourceOffset;
        if ( offset > siz ) offset = siz;     // no hauria de passar mai pero per seguretat
        
        CFStringRef preStr = NULL;
        if ( offset > 0 ) 
        {
            int plus = 0;
            if ( offset > 40 ) plus = offset-40;
            preStr = CFStringCreateWithBytesNoCopy(NULL, p+plus, offset-plus, 
                                                   kCFStringEncodingUTF8, false, kCFAllocatorNull);
        }
        
        CFStringRef postStr = nil;
        if ( siz-offset > 0 ) 
        {
            int actualSiz = 0;
            while ( actualSiz<offset+siz && actualSiz<40 )
            {
                if (p[actualSiz] == '\r' || p[actualSiz] == '\n')
                {
                    break;
                }
                actualSiz++;
            }
            
            postStr = CFStringCreateWithBytesNoCopy(NULL, p+offset, actualSiz,
                                                    kCFStringEncodingUTF8, false, kCFAllocatorNull);
            
//            int plus = 0;
//            plus = siz-offset-i;
//    
//            if ( siz-offset > 40 ) plus = siz-offset-40;
//            postStr = CFStringCreateWithBytesNoCopy(NULL, p+offset, siz-offset-plus, 
//                                                    kCFStringEncodingUTF8, false, kCFAllocatorNull);
        }
        
        NSString *errStr = nil;
        
        if ( errCode == ExpressionErrorCodeCouldNotEvalutateConstantExpression )
        {
            errStr = NSLocalizedString( @"RpnBuilderConstantExpressionError", nil );
//            if ( preStr && (/*rpnResultInfo.state != ExpressionStateOk ||*/ rpnValue.typ == SWValueTypeError) )
//            {
//                //errStr = [NSString stringWithFormat:@"%@ '%@'. %@", errStr, preStr, [self getResultErrorString]];
//                NSString *operErr = NSLocalizedString( [self _getPrimitiveOperationErrorString], nil );
//                errStr = [NSString stringWithFormat:@"%@ '%@'. %@", errStr, preStr, operErr];
//                CFRelease( preStr );
//                preStr = NULL;
//            }
            
            if ( preStr && (/*rpnResultInfo.state != ExpressionStateOk ||*/ rpnValue.typ == SWValueTypeError) )
            {
                errStr = [NSString stringWithFormat:@"%@ '%@'. %@", errStr, preStr, [self getResultErrorString]];
                CFRelease( preStr );
                preStr = NULL;
            }
        }
        
        else
        {
            switch ( errCode )
            {
                case ExpressionErrorCodeMissingTrailingBracket1 :
                    errStr = @"RpnBuilderMissingEndBracket1";
                    break;
                    
                case ExpressionErrorCodeTooManyArguments :
                    errStr = @"RpnBuilderTooManyArguments";
                    break;
                    
                case ExpressionErrorCodeTooManySources :
                    errStr = @"RpnBuilderTooManySymbols";
                    break;
                    
                case ExpressionErrorCodeMissingTrailingSqBracket1 :
                    errStr = @"RpnBuilderMissingEndSqBracket1";
                    break;
                    
                case ExpressionErrorCodeUnknownMethodIdentifier :
                    errStr = @"RpnBuilderUnknownIdentifier";
                    break;
                    
                case ExpressionErrorCodeExpectedPropertyOrMethodIdentifier :
                    errStr = @"RpnBuilderExpectingMethod";
                    break;
                    
                case ExpressionErrorCodeMissingTrailingCrBracket :
                    errStr = @"RpnBuilderMissingEndCrBracket";
                    break;
                    
                case ExpressionErrorCodeSymbolSyntaxError :
                    errStr = @"RpnBuilderSymbolSyntaxError";
                    break;
                    
                case ExpressionErrorCodeSymbolExpected :
                    errStr = @"RpnBuilderSymbolExpected";
                    break;
                    
                case ExpressionErrorCodeMissingTrailingBracket2 :
                    errStr = @"RpnBuilderMissingEndBracket2";
                    break;
                    
                case ExpressionErrorCodeMissingTrailingSqBracket2 :
                    errStr = @"RpnBuilderMissingEndSqBracket2";
                    break;
                    
                case ExpressionErrorCodeMissingTrailingCrBracket2 :
                    errStr = @"RpnBuilderMissingTrailingCrBracket2";
                    break;
                    
                case ExpressionErrorCodeExpectedPrimitiveExpression :
                    errStr = @"RpnBuilderExpectingPrimitive";
                    break;
                    
                case ExpressionErrorCodeMissingColonInTernaryOperator :
                    errStr = @"RpnBuilderMissingSemilocon";
                    break;
                    
                case ExpressionErrorCodeExtraCharsAfterExpression :
                    errStr = @"RpnBuilderExtraChars";
                    break;
                    
                case ExpressionErrorCodeExpectedExpression :
                    errStr = @"RpnBuilderNoExpression";
                    break;
                    
                default :
                    errStr = @"RpnBuilderUnknownParsingError";
                    break;
            }
            errStr = NSLocalizedString( errStr, nil );
        }
        
        if ( preStr )
        {
            errTxt = [NSString stringWithFormat:@"%@ '%@'", errStr, preStr];
            CFRelease( preStr );
            preStr = NULL;
        }
        else errTxt = errStr;
        
        if ( postStr )
        {
            NSString *format = NSLocalizedString(@"RpnBuilderPre%@Post%@", nil);
            errTxt = [NSString stringWithFormat:format, errTxt, postStr];
            CFRelease( postStr );
            postStr = NULL;
        }
    }
    else // errors de commit
    {
        NSString *errStr = nil;
        switch ( errCode )
        {
            case ExpressionErrorCodeSymbolNotFound :
                errStr = @"RpnLinkerSymbolNotFound";
                break;
                
            default :
                errStr = @"RpnLinkerUnknownError";
                break;
        }
        
        errStr = NSLocalizedString( errStr, nil );
        errStr = [NSString stringWithFormat:@"%@ %@", errStr, errSymsForExpression( self )];
        
        if ( _holder )
        {
            NSString *format = NSLocalizedString( @"RpnLinkerPre%@Ref%@", nil );
            errTxt = [NSString stringWithFormat:format, errStr, [self fullReference]];
        }
        else errTxt = errStr;
    }
    return errTxt;
}

//- (BOOL)resultIsInvalid
//{
//    return ( rpnResultInfo.state != ExpressionStateOk );
//}

//- (ExpressionStateCode)resultErrorCode
//{
////    UInt8 err = ExpressionStateOk;
////    if ( state & ExpressionStateInvalid )
////    {
////        err = rpnResultInfo.state ;
////    }
////    return err;
//    
//    return rpnResultInfo.state;
//}

- (NSString *)getResultErrorString
{
    NSString *errStr = nil;
    NSString *sourceStr = nil;
    UInt8 error = rpnResultInfo.state;
    
//    if ( (state & ExpressionStateCircular ) ) 
//    {
//        errStr = @"ExpressionCircularReference";
//    }
//    
//    else if ( state & ExpressionStateInvalid )


    if ( error != ExpressionStateOk )
    {
        switch ( error )
        {
            case ExpressionStateUnknownIdentifier:
                errStr = @"ExpressionStateUnknownIdentifier";
                break;

            case ExpressionStateInvalidSource:
                errStr = @"ExpressionStateInvalidSource";
                break;
                
            case ExpressionStatePendingSource:
                errStr = @"ExpressionStatePendingSource";
                break;
                
            case ExpressionStateBadQualitySource:
                errStr = @"ExpressionStateBadQualitySource";
                break;
                
            case ExpressionStateDisconnectedSource:
                errStr = @"ExpressionStateDisconnectedSource";
                break;
                
            case ExpressionStateCircularReference:
                errStr = @"ExpressionStateCircularReference";
                break;
        
            case ExpressionStateWrongRpn:
                errStr = @"ExpressionStateWrongRpn";
                break;
    
            case ExpressionStateTooComplex:
                errStr = @"ExpressionStateTooComplex";
                break;
                
            case ExpressionStateOperationError:
                errStr = [self _getPrimitiveOperationErrorString];
                break ;

            default:
                errStr = @"RpnInterpreterUnknownError";
                break;
        }
        
        UInt8 index = rpnResultInfo.sourceIndx;
        if ( index != 0xff && sourceExpressions )
        {
            __unsafe_unretained SWExpression *expr = (__bridge id)CFArrayGetValueAtIndex( sourceExpressions, index );
            sourceStr = [expr fullReference];//fullNameForValue( expr );
        }
    }
    
    if ( errStr )
    {
        errStr = NSLocalizedString( errStr, nil );
    }
    
    if ( sourceStr )
    {
        errStr = [NSString stringWithFormat:@"%@: '%@'", errStr, sourceStr];
    }
    
    return errStr;
}


- (UIColor*)getResultColor
{
    UIColor *color = nil;
    UInt8 error = rpnResultInfo.state;

    if ( error != ExpressionStateOk )
    {
    
        switch ( error )
        {
            case ExpressionStateDisconnectedSource:
            case ExpressionStatePendingSource:
                //color = [UIColor lightGrayColor];
                color = [UIColor yellowColor];
                break;
                
            case ExpressionStateBadQualitySource:
                color = [UIColor brownColor];
                break;
                
            case ExpressionStateCircularReference:
                color = [UIColor yellowColor];
                break;
        
            default:
                color = [UIColor redColor];
                break;
        }

    
//        if ( error == ExpressionStatePendingSource )
//        {
//            color = [UIColor lightGrayColor];
//        }
//        else if ( error == ExpressionStateBadQualitySource  )
//        {
//            color = [UIColor yellowColor];
//        }
//        else if ( error == ExpressionStateCircularReference  )
//        {
//            color = [UIColor yellowColor];
//        }
//        else
//        {
//            color = [UIColor redColor];
//        }
    }
    
    return color;
}

- (SWValue*)getExclusiveSource
{
    __unsafe_unretained SWValue *result = nil;
    if ( kind == ExpressionKindSymb )
    {
        result = (__bridge id)CFArrayGetValueAtIndex( sourceExpressions, 0 );
    }
    return result;
}

#pragma mark data source retain/release pattern

- (void)observerCountRetainBy:(int)n
{
    if ( [_holder respondsToSelector:@selector(canPerformRetainForValue:)] )
        if ( ![_holder canPerformRetainForValue:self] )
            return;

    // delegate block
    void (^dBlock)(SWExpression *value) = ^(SWExpression *value)
    {
        observerCountOfValue_retainBy(value, n);
    };

    // source block
    void (^sBlock)(SWValue *value) = ^(SWValue *value)
    {
        [value observerCountRetainBy:n];
    };

    // enumerate
    _enumerateSourcesOfExpression_usingBlock_withSourceBlock(self, dBlock, sBlock);
}

- (void)observerCountReleaseBy:(int)n
{
    if ( [_holder respondsToSelector:@selector(canPerformReleaseForValue:)] )
        if ( ![_holder canPerformReleaseForValue:self] )
            return;

    // delegate block
    void (^dBlock)(SWExpression *value) = ^(SWExpression *value)
    {
        observerCountOfValue_ReleaseBy(value, n);
    };

    // source block
    void (^sBlock)(SWValue *value) = ^(SWValue *value)
    {
        [value observerCountReleaseBy:n];
    };

    // enumerate
    _enumerateSourcesOfExpression_usingBlock_withSourceBlock(self, dBlock, sBlock);
}

- (void)enumerateSourcesUsingBlock:(void (^)(id obj))dBlock
{
    // source block
    void (^sBlock)(SWValue *value) = ^(SWValue *value)
    {
        if ( value.isConstantValue )
        {
            if ( dBlock ) dBlock( value );
        }
        else
        {
            [(id)value enumerateSourcesUsingBlock:dBlock];
        }
    };
    
    // enumerate
    _enumerateSourcesOfExpression_usingBlock_withSourceBlock(self, dBlock, sBlock );
}

//static BOOL _enumerateSourcesOfValue_UsingBlock( SWExpression *value, void (^block)(id obj, BOOL *stop) ) 
//{
//    BOOL stop = NO;
//    
//    // en aquest punt pot ser un SWValue o una SWexpression
//    if ( value.isConstantValue )
//    {
//        block( value, &stop );
//        return stop;
//    }
//    
//    // aqui asumim que es una SWExpression
//    //if ( !(value->condition & ExpressionConditionUpSearching) )  // en cas de referencia circular no el tornem a contar
//    if ( !(value->condition.expressionConditionUpSearching) )  // en cas de referencia circular no el tornem a contar
//    {
//        block( value, &stop );
//
//        if ( value->sourceExpressions && !stop )
//        {
//            //value->condition |= ExpressionConditionUpSearching; // posem a 1
//            value->condition.expressionConditionUpSearching = 1; // posem a 1
//            int sourcesCount = CFArrayGetCount( value->sourceExpressions );
//            for ( int i=0 ; i<sourcesCount ; i++ )
//            {
//                __unsafe_unretained SWExpression *sExpr = (__bridge id)CFArrayGetValueAtIndex( value->sourceExpressions, i );
//                stop = _enumerateSourcesOfValue_UsingBlock(sExpr, block);
//                if ( stop ) break;
//            }
//        }
//        //value->condition &= ~ExpressionConditionUpSearching; // posem a 0
//        value->condition.expressionConditionUpSearching = 0; // posem a 0
//    }
//    return stop;
//}

static BOOL _enumerateSourcesOfExpression_usingBlock_withSourceBlock( SWExpression *value, void (^dBlock)(id obj), void (^sBlock)(id obj)) 
{
    BOOL stop = NO;
        
    // aqui asumim que es una SWExpression
    //if ( !(value->condition & ExpressionConditionUpSearching) )  // en cas de referencia circular no el tornem a contar
    if ( !(value->condition.expressionConditionUpSearching) )  // en cas de referencia circular no el tornem a contar
    {
        if ( dBlock ) dBlock( value );
        if ( value->sourceExpressions && !stop )
        {
            //value->condition |= ExpressionConditionUpSearching; // posem a 1
            value->condition.expressionConditionUpSearching = 1; // posem a 1
            int sourcesCount = CFArrayGetCount( value->sourceExpressions );
            for ( int i=0 ; i<sourcesCount ; i++ )
            {
                __unsafe_unretained SWExpression *sExpr = (__bridge id)CFArrayGetValueAtIndex( value->sourceExpressions, i );
                if ( sBlock ) sBlock( sExpr );
            }
        }
        //value->condition &= ~ExpressionConditionUpSearching; // posem a 0 un cop hem iterat per tots els sources
        value->condition.expressionConditionUpSearching = 0; // posem a 0 un cop hem iterat per tots els sources
    }
    return stop;
}

#pragma mark Private Methods

- (void)clear
{
    // atencio no canviem state ni rpnResultInfo
    
    kind = ExpressionKindUnknown;
    //condition = ExpressionConditionNone;
    condition.all = 0;
    errCode = ExpressionErrorCodeNone;
    if ( sourceCodeData ) /*[sourceCodeData release],*/ sourceCodeData=nil;
    unlinkExpressionFromSources( self );
    if ( sourceDependanceSkips ) CFRelease( sourceDependanceSkips ), sourceDependanceSkips = NULL;
    if ( constantStrings ) CFRelease(constantStrings), constantStrings=nil;
    if ( rpnCode ) /*[rpnCode release],*/ rpnCode=nil;
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
//            __unsafe_unretained SWExpression *expr = (__bridge id)CFArrayGetValueAtIndex(dependants, i);
//            [expr evalFromOriginator:self];
//        }
//    }
//    condition.expressionConditionPromoting = 0; // posem a 0
//}

// ^-- implemented on SWValue


- (void)evalFromOriginatorVV:(SWExpression*)originator
{

    NSLog( @"eval:%@ fromOriginator:%@", [self.holder identifier], [originator.holder identifier]);
    
    
    RPNValue oldValue = rpnValue;
    ExpressionStateCode oldState = rpnResultInfo.state;
    
    BOOL changed;  // avisar del canvi
    BOOL promote;  // promoure el resultat
    BOOL forced = NO; // canvi forçat
    
    //if ( condition & ExpressionConditionAsleep )
    if ( condition.expressionConditionAsleep )
    {
        changed = NO;
        promote = NO;
    }
    
    //else if ( condition & ExpressionConditionPromoting )
    else if ( condition.expressionConditionPromoting )
    {
        UInt8 sourceIndx = getIndexOfSource_fromExpression(originator, self);
        rpnResultInfo.state = ExpressionStateCircularReference;
        rpnResultInfo.sourceIndx = sourceIndx;
        changed = YES;
        promote = NO;
    }

    else if ( kind == ExpressionKindConst  )
    {
        rpnResultInfo.state = rpnValue.typ==SWValueTypeError ? ExpressionStateOperationError : ExpressionStateOk;
        rpnResultInfo.sourceIndx = 0xff ;
        changed = YES;
        promote = YES;
        forced = (condition.expressionConditionSourceChanged != 0);
    }

    else
    {
        RpnInterpreter *interpreter = [RpnInterpreter sharedRpnInterpreter];
        RpnInterpreterResultCode rpnResult = [interpreter evalExpression:self outValue:&rpnValue outStatus:&rpnResultInfo];
    
        if ( rpnResult == RpnInterpreterResultHalt )
        {
            changed = NO;
            promote = NO;
        }
        else    // <- 23-02-2014
        {
            // per qualsevol altre cas promoure el resultat i avisar el canvi
            changed = YES;
            promote = YES;
        }
    }
    
    if ( condition.expressionConditionSourceChanged )
    {
        doExpressionSourceStringDidChange( self );
    }

    if ( changed )
    {
        doDidEvalutateExpression_fromOldValue_oldState(self, oldValue, oldState, forced);
    }
    
    if ( promote )
    {
        [self promote];
    }
}


- (BOOL)evalFromOriginator:(SWExpression*)originator
{
    //NSLog( @"eval:%@ fromOriginator:%@", [self.holder identifier], [originator.holder identifier]);
    
    RPNValue oldValue = rpnValue;
    ExpressionStateCode oldState = rpnResultInfo.state;
    
    BOOL changed;  // avisar del canvi
    BOOL promote;  // promoure el resultat
    BOOL forced = NO; // canvi forçat
    
    if ( condition.expressionConditionAsleep )
    {
        changed = NO;
        promote = NO;
    }
    
    else if ( condition.expressionConditionPromoting )
    {
        UInt8 sourceIndx = getIndexOfSource_fromExpression(originator, self);
        rpnResultInfo.state = ExpressionStateCircularReference;
        rpnResultInfo.sourceIndx = sourceIndx;
        changed = YES;
        promote = NO;
    }

    else if ( kind == ExpressionKindConst  )
    {
        rpnResultInfo.state = rpnValue.typ==SWValueTypeError ? ExpressionStateOperationError : ExpressionStateOk;
        rpnResultInfo.sourceIndx = 0xff ;
        changed = YES;
        promote = YES;
        forced = (condition.expressionConditionSourceChanged != 0);
    }

    else
    {
        RpnInterpreter *interpreter = [RpnInterpreter sharedRpnInterpreter];
        RpnInterpreterResultCode rpnResult = [interpreter evalExpression:self outValue:&rpnValue outStatus:&rpnResultInfo];
    
        if ( rpnResult == RpnInterpreterResultHalt )
        {
            changed = NO;
            promote = NO;
        }
        else    // <- 23-02-2014
        {
            // per qualsevol altre cas promoure el resultat i avisar el canvi
            changed = YES;
            promote = YES;
        }
    }
    
    if ( condition.expressionConditionSourceChanged )
    {
        doExpressionSourceStringDidChange( self );
    }

    if ( changed )
    {
        doDidEvalutateExpression_fromOldValue_oldState(self, oldValue, oldState, forced);
    }
    
    return promote;
//    if ( promote )
//    {
//        [self promote];
//    }
}




- (void)evalWithDisconnectedSource
{
    [self evalWithForcedState:ExpressionStateDisconnectedSource];
}



#pragma mark Potocol QuickCoder

- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super initWithQuickCoder:decoder];   
        
    // decodifiquem el tipus de expressio
    kind = (ExpressionKind)[decoder decodeInt];

    // decodifiquem el estat de validesa i compilacio (despres del anterior doncs el init el canvia)
    //state = [decoder decodeInt];
    condition.all = [decoder decodeInt];
    errCode = (ExpressionErrorCode)[decoder decodeInt];
    
    // estats dels errors
//    errInfo.all = [decoder decodeInt];
//    rpnResultInfo.all = [decoder decodeInt];
    
    [decoder decodeBytes:&errInfo length:sizeof errInfo];
    [decoder decodeBytes:&rpnResultInfo length:sizeof rpnResultInfo];
    
    // descodifiquem el clusterDependantCount
    //clusterDependantCount = [decoder decodeInt];

    // decodifiquem el source code
    sourceCodeData = [decoder decodeObject]; //retain];
    
    // decodifiquem els sourceExpressions
    int count = [decoder decodeInt];
    if ( count > 0 )
    {
        sourceExpressions = CFArrayCreateMutable(NULL, count, &kCFTypeArrayCallBacks);
        for ( int i=0; i<count; i++ )
        {
            SWExpression *expr = [decoder decodeObject];
            CFArrayAppendValue(sourceExpressions, (__bridge CFTypeRef)expr);
        }
    }
    
    // decodifiquem les string constants
    count = [decoder decodeInt];
    if ( count > 0 )
    {
        constantStrings = CFArrayCreateMutable(NULL, count, &kCFTypeArrayCallBacks);
        for ( int i=0; i<count; i++ )
        {
            NSString *string = [decoder decodeObject];
            CFArrayAppendValue(constantStrings, (__bridge CFTypeRef)string);
        }
    }
    
    // decodifiquem el rpnCode
    rpnCode = [decoder decodeObject]; // retain];
    
    //NSLog(@"EXP Init %x: %@, %@.%@",(unsigned)self, [self getSourceString], [self symbol], [self getName]);
    
    return self;
}

- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
{    
    //NSLog(@"EXP Encoder: <%@> isZombie: %@",[self getSourceString],STRBOOL((self->condition & ExpressionConditionZombie)));
    
    [super encodeWithQuickCoder:encoder] ;
    
    // codifiquem el tipus
    [encoder encodeInt:kind];
    
    // codifiquem el estat de validesa i compilacio
    //[encoder encodeInt:state];
    [encoder encodeInt:condition.all];
    [encoder encodeInt:errCode];
    
    //[encoder encodeObject:infoStr];
    // codifiquem els estats de error
    //[encoder encodeInt:errInfo.all];
    //[encoder encodeInt:rpnResultInfo.all];
    [encoder encodeBytes:&errInfo length:sizeof errInfo];
    [encoder encodeBytes:&rpnResultInfo length:sizeof rpnResultInfo];
    
    // clusterDependantCount
    //[encoder encodeInt:clusterDependantCount];
    
    // codifiquem el source code
    [encoder encodeObject:sourceCodeData];

    // codifiquem el numero de items i el contingut de sourceExpressions
    if ( sourceExpressions )
    {
        
        int count = CFArrayGetCount(sourceExpressions);
        [encoder encodeInt:count];
        
        for ( int i=0; i<count; i++ )
        {
            __unsafe_unretained SWExpression *expr = (__bridge id)CFArrayGetValueAtIndex(sourceExpressions, i);
            [encoder encodeObject:expr];
            //[self doTompinWithExpr:expr];
            //NSLog(@"EXP encoded sourceExpr %x:",expr);
            //expr = expr;
        }
    }
    else
    {
        [encoder encodeInt:0];
    }
    
    // codifiquem els constantStrings
    if ( constantStrings )
    {
        // codifiquem el numero de items i el contingut de sourceExpressions
        int count = CFArrayGetCount(constantStrings);
        [encoder encodeInt:count];
//            NSLog( @"constStrings %x count %ld", constantStrings, CFArrayGetCount(constantStrings));
//            NSLog( @"constStrings %@", constantStrings );
        for ( int i=0; i<count; i++ )
        {
            __unsafe_unretained NSString *string = (__bridge id)CFArrayGetValueAtIndex(constantStrings, i);
            //NSLog( @"string %@", string );
            [encoder encodeObject:string];
        }
    }
    else
    {
        [encoder encodeInt:0];
    }
    
    // el rpnCode
    [encoder encodeObject:rpnCode];
}

- (void)retrieveWithQuickCoder:(QuickUnarchiver *)decoder
{
    [super retrieveWithQuickCoder:decoder];
    condition.all = [decoder decodeInt];
}

- (void)storeWithQuickCoder:(QuickArchiver *)encoder
{
    [super storeWithQuickCoder:encoder];
    [encoder encodeInt:condition.all];
}

#pragma mark Protocol ValueDependant

- (void)sourceSymbolDidChange
{
    if (observers) {
        doExpressionSourceStringDidChange(self);
    }
}

@end

#pragma mark - SWValue ExpressionAdditons

@implementation SWValue (ExpressionAdditons)

- (BOOL)isConstantValue
{
    return YES;
}

//- (BOOL)isPromoting
//{
//    return NO;
//}

- (ExpressionStateCode)state
{
    ExpressionStateCode st = rpnValue.typ==SWValueTypeError ? ExpressionStateOperationError : ExpressionStateOk;
    return st;
}

//- (void)evalWithForcedState:(ExpressionStateCode)state
//{
//    return;
//}

- (NSString*)getResultErrorString
{
    NSString *errStr = nil;
    
    if (  rpnValue.typ==SWValueTypeError )
        errStr = NSLocalizedString(@"ValueStateInvalid", nil);

    return errStr;
}

- (UIColor*)getResultColor
{
    return nil;
}

@end

#pragma mark - SWExpression Cluster  ( DEPRECATED - DO NOT USE - NOT TESTED )

//@implementation SWExpression (Cluster)
//
//- (id)initAsClusterWithSources:(id)sources
//{
//    if ( ( self = [self init] ) )
//    {
//        //ppp state = ExpressionStateInvalid; // posa a 1
//        rpnResultInfo.state = ExpressionStateInvalidSource;
//        rpnResultInfo.sourceIndx = 0xff;
//        
//        
//        //state = ExpressionStateOk;
//        //rpnValue = 0.0;
//        
//        condition = ExpressionConditionNone; // en un pricipi suposem que no cal comitar
//        kind = ExpressionKindCluster;
//        
//        CFTypeID typeId = CFGetTypeID((__bridge CFTypeRef)sources);
//        
//        if ( typeId == CFArrayGetTypeID() )
//        {
//            //sourceExpressions = (CFMutableArrayRef)CFRetain(sources);
//            //int count = CFArrayGetCount( sourceExpressions );
//            
//            int count = CFArrayGetCount( (__bridge CFArrayRef)sources );
//            sourceExpressions = CFArrayCreateMutableCopy( NULL, count, (__bridge CFArrayRef)sources );
//            for ( int i=0; i<count; i++ )
//            {
//                //CFTypeRef symbolOrExp = CFArrayGetValueAtIndex( sourceExpressions, i );
//                //if ( CFGetTypeID(symbolOrExp) == CFStringGetTypeID() ) condition = ExpressionConditionNeedsCompile;  //
//                // else addDependant_toExpression( self, (ExpressionBase*)symbolOrExp ); // se suposa que es ExpressionBase o derivada
//                // jjj
//                
//                __unsafe_unretained SWExpression *expr = (__bridge id)CFArrayGetValueAtIndex( sourceExpressions, i );
//                if ( [expr isKindOfClass:[SymbolicSource class]] ) 
//                    condition |= (ExpressionConditionNeedsCompile|ExpressionConditionSourceChanged);
//                    
//                else if ( [expr isKindOfClass:[SWExpression class]] )
//                    addDependant_toReferenceableValue( self, expr );
//                    
//                else NSAssert( false, @"Clase no suportada per cluster" ) ;
//            }
//        }
//        
//        else // se suposa que es o be un SymbolicSource o un derivat de Expression
//        {
//            sourceExpressions = CFArrayCreateMutable( NULL, 1, &kCFTypeArrayCallBacks );
//            CFArrayAppendValue( sourceExpressions, (__bridge CFTypeRef)sources );
//            
//            if ( [sources isKindOfClass:[SymbolicSource class]] )
//                condition |= (ExpressionConditionNeedsCompile|ExpressionConditionSourceChanged);
//                
//            else if ( [sources isKindOfClass:[SWExpression class]] )
//                addDependant_toReferenceableValue( self, sources );// se suposa que es Expression
//                
//            else NSAssert( false, @"Clase no suportada per cluster" ) ;
//        }
//    }
//    return self;
//}
//- (id)initAsMutableCluster
//{
//    if ( ( self = [self init] ) )
//    {
//        //ppp state = ExpressionStateInvalid; // posa a 1
//        rpnResultInfo.state = ExpressionStateInvalidSource;
//        rpnResultInfo.sourceIndx = 0xff;
//        
//        //state = ExpressionStateOk;
//        //rpnValue = 0.0;
//        
//        condition = ExpressionConditionNone; // en un pricipi suposem que no cal comitar
//        kind = ExpressionKindCluster;
//    }
//    return self;
//}
//
//- (void)mutableClusterAddSource:(id)source
//{
//    if ( kind == ExpressionKindCluster )
//    {
//        //if ( sourceExpressions == NULL) sourceExpressions = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
//        //CFArrayAppendValue( sourceExpressions, source );  // llenca una excepcio si estava iniciat com no mutable
//        
//        addSource_toExpression( source, self );
//        //if ( CFGetTypeID(source) == CFStringGetTypeID() ) condition = ExpressionConditionNeedsCompile;   // jjj
//        if ( [source isKindOfClass:[SymbolicSource class]] ) 
//            condition |= (ExpressionConditionNeedsCompile|ExpressionConditionSourceChanged);
//            
//        else if ( [source isKindOfClass:[SWExpression class]] )
//            addDependant_toReferenceableValue( self, source );  // se suposa que es Expression
//        
//        else NSAssert( false, @"Clase no suportada per cluster" ) ;
//        
//        return;
//    }
//    
//    NSAssert( false, @"Ha de ser iniciat com mutable cluster" );
//}
//
//- (void)mutableClusterRemoveSource:(SWExpression*)source
//{
//    if ( kind == ExpressionKindCluster )
//    {
//        removeDependant_fromReferenceableValue( self, source );
//        removeSource_fromExpression( source, self );
//        return;
//    }
//    
//    NSAssert( false, @"Ha de ser iniciat com mutable cluster" );
//}
//
//@end

#pragma mark - SWExpressionRPNBuilder

@implementation SWExpression (RPNBuilder)

// Canvia els elements de sourceExpressions que encara son SymbolicSources per
// expressions agafades de taules de simbols.
// Les taules de simbols son CFDictionary amb parelles de CFStringRef, id<ValueHolder>
// wantsLink==YES indica que volem enllacar-nos com a depenents dels nostres sources
// ignoreFaults==YES indica que generem un SWValue vuit per els sources que no trobem

- (BOOL)commitUsingLocalSymbolTable:(CFDictionaryRef)symbolTable
                        globalTable:(CFDictionaryRef)globalTable 
                        systemTable:(CFDictionaryRef)systemTable
                          wantsLink:(BOOL)wantsLink
                          ignoreFaults:(BOOL)ignoreFaults
                           outError:(NSError**)outError
{
    //NSMutableString *errSyms = nil;
    
    BOOL allDone = YES;
    //if ( sourceExpressions && ( condition & ExpressionConditionNeedsCompile ) )
    if ( sourceExpressions && condition.expressionConditionNeedsCompile )
    {
        //errInfo.all = 0xffffffff;  // els cuatre sourceIndex a 0xff;
        errInfo.sourceIndx[0] = 0xff;
        errInfo.sourceIndx[1] = 0xff;
        errInfo.sourceIndx[2] = 0xff;
        errInfo.sourceIndx[3] = 0xff;
        int count = CFArrayGetCount( sourceExpressions );
        
        // iterem per cada source expressio
        for ( int i=0; i<count; i++ )
        {
            // en aquest moment el array de sourceExpressions pot contenir SymbolicSources
            __unsafe_unretained SymbolicSource *symbol = (__bridge id)CFArrayGetValueAtIndex( sourceExpressions, i );
            
            // si aquest source no es un SymbolicSource, ja esta commitat, anem per el seguent
            if ( ! [symbol isKindOfClass:[SymbolicSource class]] ) continue;
            
            __unsafe_unretained id<ValueHolder> exprHolder = nil;
            SWValue *exprSource = nil;
            if ( symbol->symObject == NoSourceSym )
            {
                exprSource = [[SWValue alloc] init];
            }
            else
            {
                // busquem el holder del simbol a les diferent taules de simbols
                if ( exprHolder == nil && systemTable ) 
                    exprHolder = (__bridge id)CFDictionaryGetValue( systemTable, (__bridge CFTypeRef)symbol->symObject ); // sistema
                
                if ( exprHolder == nil && symbolTable ) 
                    exprHolder = (__bridge id)CFDictionaryGetValue( symbolTable, (__bridge CFTypeRef)symbol->symObject ); // locals
                
                if ( exprHolder == nil && globalTable ) 
                    exprHolder = (__bridge id)CFDictionaryGetValue( globalTable, (__bridge CFTypeRef)symbol->symObject ); // globals
            
                if ( exprHolder && exprHolder != (id)kCFNull ) // pot ser kCFNull (vol dir simbol duplicat)
                {
                    // determinem la expressio que representa el SymObject
                    exprSource = [exprHolder valueWithSymbol:symbol->symObject property:symbol->symProperty];
                }
    
                if ( ignoreFaults && exprSource == nil )
                {
                    // creem un value vuit si cal
                    exprSource = [[SWValue alloc] init];
                }
            }
            
            if ( exprSource )
            {
                // canviem el SymObject per la expressio que representa si podem (i volem)
                if ( wantsLink )
                {
                    CFArraySetValueAtIndex( sourceExpressions, i, (__bridge CFTypeRef)exprSource );  // la expressio com a source
                    BOOL addDependant = ( sourceDependanceSkips == NULL || ((UInt8*)CFDataGetBytePtr( sourceDependanceSkips ))[i] == 0 );
                    if ( addDependant ) addDependant_toReferenceableValue(self, exprSource); // aquest com a dependent de la expresio
                }
                else
                {
                    CFArraySetValueAtIndex( sourceExpressions, i, (__bridge CFTypeRef)exprSource );
                }
            }
            else
            {
                // creem una copia inmutable del SymbolicSource i el deixem
                allDone = NO;
                SymbolicSource *copySymbol = [symbol copy];   // si ja era inmutable nomes incrementara el retain count
                CFArraySetValueAtIndex( sourceExpressions, i, (__bridge CFTypeRef)copySymbol );  // machaquem el symbol i retenim el copySymbol
                //CFRelease( copySymbol );
                
                errCode = ExpressionErrorCodeSymbolNotFound;
                for ( int j=0; j<4; j++ ) // guardem fins a 3 sources
                    if ( errInfo.sourceIndx[j] == 0xff ) { errInfo.sourceIndx[j] = i; break; }
                /*
                 if ( outError )
                 {
                 if ( errSyms == nil ) errSyms = [[NSMutableString alloc] initWithString:copySymbol->symObject];
                 else [errSyms appendFormat:@", %@", copySymbol->symObject];
                 if ( copySymbol->symProperty ) [errSyms appendFormat:@".%@", copySymbol->symProperty];
                 }
                 */
            }
        }
    }
    
    if ( allDone )
    {
        if ( sourceDependanceSkips ) CFRelease( sourceDependanceSkips ), sourceDependanceSkips = NULL;
        //condition &= ~ExpressionConditionNeedsCompile;  // posa a 0
        condition.expressionConditionNeedsCompile = 0;  // posa a 0
        
        /*
         if ( condition & ExpressionConditionSourceChanged )
         {
         doExpressionSourceStringDidChange( self );
         }
         
         BOOL changed;
         BOOL promote = [self selfEval:&changed]; 
         
         //if ( promote && state == ExpressionStateOk )
         if ( promote  )
         {
         doDidEvaluateExpression_withChange( self, changed );
         [self promote];
         }
         */
        //if ( wantsLink )
            [self eval];
        
        return YES; 
    }
    
    if ( outError )
    {
        //NSString *errSyms = errSymsForExpression( self );
        //NSString *errMsg = [NSString stringWithFormat:NSLocalizedString(@"SymbolsNotFound%@", nil), errSyms];
        
        NSString *errMsg = [self getSourceErrorString];
        NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
        *outError = [NSError errorWithDomain:@"com.SweetWilliam.HmiPad" code:0 userInfo:info];
    }
    
    return NO;
}

//- (void)setSourceWithConstantRpnValue:(const RPNValue&)rpnVal //resultInfo:(RpnInterpreterResult)resultInfo  // falta state
- (void)setSourceWithConstantRpnValue:(const RPNValue&)rpnVal resultInfo:(ExpressionStateInfo)resultInfo
{
    [self clear];
    
    if ( rpnValue != rpnVal )
    {
        rpnValue = rpnVal;
        condition.expressionConditionSourceChanged = 1; // a 1
    }

    kind = ExpressionKindConst;

//    //rpnResultInfo = resultInfo;  25-Juny-2013
//    rpnResultInfo.sourceIndx = 0xff;

    rpnResultInfo = resultInfo;  // 16-Febrer-2014
}


- (void)setSourceWithSymbol:(SymbolicSource *)symbol
{
    [self clear];
    
    kind = ExpressionKindSymb;
    //condition |= ExpressionConditionNeedsCompile|ExpressionConditionSourceChanged;  // a 1
    condition.expressionConditionNeedsCompile = 1;
    condition.expressionConditionSourceChanged = 1;  // a 1
    
    setSingleSource_toExpression( (__bridge CFTypeRef)symbol, self);
}    

- (void)setSourceWithExpression:(SWExpression*)sourceExpr
{
    [self clear];
    rpnValue = sourceExpr->rpnValue ;
    
    kind = ExpressionKindSymb;
    //condition |= ExpressionConditionSourceChanged;    // a 1
    condition.expressionConditionSourceChanged = 1;    // a 1
          
    setSingleSource_toExpression( (__bridge CFTypeRef)sourceExpr, self );
    addDependant_toReferenceableValue( self, sourceExpr );
}

- (void)setSourceWithConstantValue:(double)value
{
    [self clear];
    
    if ( rpnValue != value )
    {
        rpnValue = value;
        condition.expressionConditionSourceChanged = 1;
    }
    
    kind = ExpressionKindConst;
    //rpnResultInfo.all = 0; 
    
    //condition.expressionConditionSourceChanged = 1;   // a 1
}

- (void)setSourceEmpty
{
    [self clear];
    //state = ExpressionStateInvalid;
}

- (void)setError:(ExpressionErrorCode)err withInfo:(ExpressionErrorInfo)errDta;
{
    errCode = err;
    errInfo = errDta;
}

- (void)setSourceCodeData:(NSData*)data
{
    if ( data != sourceCodeData )
    {
        //        [sourceCodeData release];
        //        sourceCodeData = [data retain];
        sourceCodeData = data;
        //condition |= ExpressionConditionSourceChanged;
        condition.expressionConditionSourceChanged = 1;
    }
}

- (void)setSourceDependanceSkips:(CFDataRef)dataSkips 
{
    if ( dataSkips != sourceDependanceSkips ) 
    {
        if ( sourceDependanceSkips ) CFRelease( sourceDependanceSkips );
        if ( dataSkips ) CFRetain( dataSkips );
        sourceDependanceSkips = dataSkips;
    }
}

- (void)setSourceWithRpnCode:(NSData*)rpnCde withSources:(CFMutableArrayRef)sources withConstStrings:(CFMutableArrayRef)constStrings
{
    //SWValueState theState = state;
    
    [self clear]; // atencio no canviem el state
    
    //rpnCode = [rpnCde retain];
    rpnCode = rpnCde;
    
    if ( sources ) CFRetain( sources );
    sourceExpressions = sources;
    
    if ( constStrings ) CFRetain( constStrings );
    constantStrings = constStrings;
    
    kind = ExpressionKindCode;
    //state = ExpressionStateInvalid; // posa a 1
    
    //state = theState; //recupera el state
    //condition |= (ExpressionConditionNeedsCompile|ExpressionConditionSourceChanged);
    condition.expressionConditionNeedsCompile = 1;
    condition.expressionConditionSourceChanged = 1;
}

@end

#pragma mark - SWExpression RPNInterpreter

@implementation SWExpression (RPNInterpreter)

//- (UInt8)condition
//- (ExpressionCondition)condition
//{
//    return condition;
//}

- (CFMutableArrayRef)sourceExpressions
{
    return sourceExpressions;
}

- (CFMutableArrayRef)constantStrings
{
    return constantStrings;
}

- (NSData *)rpnCode
{
    return rpnCode;
}

@end

