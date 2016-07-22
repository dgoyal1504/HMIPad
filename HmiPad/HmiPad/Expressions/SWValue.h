//
//  SWValue.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/4/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SWValueTypes.h"
#import "SWValueProtocols.h"

#import "SymbolicCoder.h"
#import "QuickCoder.h"
#import "SWExpressionSourceObject.h"

#if __cplusplus
extern "C" {   // no volem que el compilador de c++ mutili els noms de les funcions !
#endif

// C Methods Declaration
extern NSString *stringForDouble_withFormat( double d, NSString *format ) ;
extern void doDidEvaluateReferenceableValue_withChange(SWValue *value, BOOL changed);

#if __cplusplus
}
#endif

@class SWPropertyDescriptor;



// flags utilitzats durant les operacions amb expressions
typedef union
{
    struct
    {
        unsigned char expressionConditionNone:1;
        unsigned char expressionConditionPromoting:1;     // indica que esta en fase de promocio, per detectar referencies circulars
        unsigned char expressionConditionShouldPromote:1;
        unsigned char expressionConditionNeedsCompile:1;     // indica que la expressio no ha rebut commit
        unsigned char expressionConditionSourceChanged:1;
        unsigned char expressionConditionDoNotPromote:1;     // indica que la expressio no s'ha de promoure ( execucio de else clause vuida )
        unsigned char expressionConditionAsleep:1;          // indica que no volem promocions per aquesta expressio ( zombie )
        unsigned char expressionConditionUpSearching:1;
    };
    unsigned short all;
    
} ExpressionCondition;


// tipus de expressio
typedef enum : UInt8
{
    ExpressionKindUnknown = 0,
    ExpressionKindConst,  // es el tipus implicit de un SWValue
    ExpressionKindSymb,
    //ExpressionKindCluster,
    ExpressionKindCode
} ExpressionKind;


// Main Interface
@interface SWValue : NSObject <NSFastEnumeration, QuickCoding, SWExpressionSourceObject>
{
    //@public
    __weak id<ValueHolder> _holder;  // weak
    
    CFMutableArrayRef observers; // conte weak objectes id<ExpressionObserver> (no es codifica)
    CFMutableArrayRef dependants; // conte weak expressions
    ExpressionCondition condition;
}

- (id)initWithValue:(SWValue*)value;
- (id)initWithDouble:(double)value;
- (id)initWithAbsoluteTime:(CFAbsoluteTime)value;   // referit a 2001
- (id)initWithCGPoint:(CGPoint)value;
- (id)initWithCGSize:(CGSize)value;
- (id)initWithCGRect:(CGRect)value;
- (id)initWithSWValueRange:(SWValueRange)value;
- (id)initWithString:(NSString*)value;
- (id)initWithObject:(id <QuickCoding, SymbolicCoding>)value;
- (id)initWithArray:(NSArray*)value; // els elements poden ser NSString, NSNumber, SWValue
- (id)initWithDoubles:(const double *)nums count:(const int)count;
- (id)initWithDictionary:(NSDictionary*)dict;  // les keys han de ser NSStrings, els values poden ser NSString, NSNumber, SWValue

+ (SWValue*)valueWithValue:(SWValue*)value;
+ (SWValue*)valueWithDouble:(double)value;
+ (SWValue*)valueWithAbsoluteTime:(CFAbsoluteTime)value;
+ (SWValue*)valueWithCGPoint:(CGPoint)value;
+ (SWValue*)valueWithCGSize:(CGSize)value;
+ (SWValue*)valueWithCGRect:(CGRect)value;
+ (SWValue*)valueWithSWValueRange:(SWValueRange)value;
+ (SWValue*)valueWithString:(NSString*)value;
+ (SWValue*)valueWithObject:(id <QuickCoding, SymbolicCoding>)value;
+ (SWValue*)valueWithArray:(NSArray*)value;
+ (SWValue*)valueWithDoubles:(const double *)nums count:(const int)count;
+ (SWValue*)valueWithDictionary:(NSDictionary*)dict;

- (SWPropertyDescriptor*)valueDescription;
- (SWValue*)getDefaultValue;

@property (nonatomic, weak) id <ValueHolder> holder;

- (void)addObserver:(id<ValueObserver>)obj;
- (void)removeObserver:(id<ValueObserver>)obj;

@property (nonatomic, readonly) int observerCount;
@property (nonatomic, readonly) BOOL hasManagedObserverRetains;
@property (nonatomic, readonly) BOOL hasManagedObserverReleases;

extern void observerCountOfValue_ReleaseBy(SWValue *value, int n);
extern void observerCountOfValue_retainBy(SWValue *value, int n);
- (void)observerCountRetainBy:(int)n;
- (void)observerCountReleaseBy:(int)n;

- (void)promoteSymbol; // promocio de l'identificador
- (void)enablePromotions;  // Permetre promocions
- (void)disablePromotions;  // Aturar promocions
- (void)invalidate;   // posa el holder a nil i promou el identificador invalid

// estats del value
- (BOOL)hasDependants;
- (BOOL)isPromoting;

// codi font del valor (si disponible)
- (NSString *)getSourceString;  // overridable
- (NSString *)getValueSourceString;

// valor en un format adequat per visualitzacio
- (NSString *)getValuePrintableString;

// Retorna una source string per a bindejarse en aquesta expressió: si es pot la fullReference i altrament el valueSourceString
- (NSString*)getBindableString;

// Value Getters
@property (nonatomic, readonly) SWValueType valueType;

- (double)valueAsDouble;
- (CFAbsoluteTime)valueAsAbsoluteTime; // referit a 2001
- (CGPoint)valueAsCGPoint;
- (CGSize)valueAsCGSize;
- (CGRect)valueAsCGRect;
- (SWValueRange)valueAsSWValueRange;
- (NSString*)valueAsString;
- (NSString*)valueAsStringWithFormat:(NSString*)format;
- (id)valueAsObject;
- (NSArray*)valueAsArray;  // torna un array de NSStrings o NSNumbers.
- (NSDictionary*)valueAsDictionary;  // torna un diccionary de NSString keys i values NSStrings o NSNumbers
- (NSDictionary*)valueAsDictionaryWithValues; // torna un diccionary de NSString keys i values SWValues


// Other getters
- (BOOL)valueIsEmpty;
- (BOOL)valueAsBool;
- (int)valueAsInteger;
- (UIColor*)valueAsColor;
- (UInt32)valueAsRGBColor;

// Array Support
- (NSInteger)count;                          // torna 1 si no es un array, la longitud del array en cas contrari
- (SWValue*)valueAtIndex:(NSInteger)index;   // torna ell mateix per index==0 si no es un array, nil en cas contrari
- (double)doubleAtIndex:(NSInteger)index;    // torna ell mateix per index==0 si no es un array, 0 en cas contrari
- (id)valuesAsStrings;    // torna ell mateix si no es un array, o un array de strings en cas contrari
- (CFDataRef)createDataWithValuesAsDoubles;  // sempre torna un CFData
- (CFArrayRef)createArrayWithValuesAsStringsWithFormat:(NSString*)format;  // sempre torna un CFArray

// Dictionary Support
- (SWValue*)valueForStringKey:(NSString*)key;  // <- torna nil si no es troba un value per key
- (SWValue*)valueForValueKey:(SWValue*)key;    // <- torna nil si no es troba un value per key

// Value Setters (Undo + Eval)
- (void)setValueFromValue:(SWValue*)value;
- (void)setValueAsDouble:(double)value;
- (void)setValueAsAbsoluteTime:(double)value;  // referit a 2001
- (void)setValueAsCGPoint:(CGPoint)value;
- (void)setValueAsCGSize:(CGSize)value;
- (void)setValueAsCGRect:(CGRect)value;
- (void)setValueAsString:(NSString*)value;
- (void)setValueAsObject:(id <QuickCoding, SymbolicCoding>)value;
- (void)setValueAsArray:(NSArray*)array;   // pot tenir NSStrings, NSNumbers o SWValues
- (void)setValueAsDoubles:(const double *)nums count:(const int)count;

// evaluacio i promocio de la expressio, el metode eval emet observacions propies i dels depenents
- (void)eval;

// Value evaluers (Pseudo-Primitive Setters)
- (void)evalWithValue:(SWValue*)value;
- (void)evalWithDouble:(double)value;
- (void)evalWithAbsoluteTime:(CFAbsoluteTime)value;    // referit a 2001
- (void)evalWithCGPoint:(CGPoint)value;
- (void)evalWithCGSize:(CGSize)value;
- (void)evalWithCGRect:(CGRect)value;
- (void)evalWithString:(NSString*)value;
- (void)evalWithObject:(id <QuickCoding,SymbolicCoding>)value;
- (void)evalWithArray:(NSArray*)array;   // pot tenir NSStrings, NSNumbers o SWValues
- (void)evalWithDoubles:(const double *)nums count:(const int)count;
- (void)evalWithDisconnectedSource;

@end

#if __cplusplus

#import "RPNValue.h"

@interface SWValue () 
{
@protected
    RPNValue rpnValue;
}
- (id)initWithRPNValue:( const RPNValue& )value;
@end

// ---------------- RPN Interpreter ---------------- //
@interface SWValue(RPNInterpreter)
- (const RPNValue&)rpnValue;
@end

#endif
