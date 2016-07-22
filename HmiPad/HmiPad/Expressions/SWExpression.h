//
//  SWExpression.h
//  HmiPad_101010SJ
//
//  Created by Joan on 04/11/10.
//  Copyright 2010 SweetWilliam, S.L. All rights reserved.

#import "QuickCoder.h"
#import "SWValue.h"
#import "SWExpressionProtocols.h"
#import "SWExpressionCommonTypes.h"

#if __cplusplus
#import "RPNValue.h"
#endif


@interface SymbolicSource : NSObject<NSCopying,QuickCoding, SWExpressionSourceObject> 
{
    @public
    __strong NSString *symObject;
    __strong NSString *symProperty;
}

- (id)initWithSymObject:(NSString*)symbol andSymProperty:(NSString*)property;

@end

extern NSString * const NoSourceSym;

// --------------------------------------------------------------------------------- //
//                               CLASS IMPLEMENTATION                                //
// --------------------------------------------------------------------------------- //

@interface SWExpression : SWValue <QuickCoding, ValueDependant>
{    
    //UInt8 state;
    ExpressionKind kind; // indica el tipus d'expressio ( atencio no confondre amb el tipus de resultat )
    //ExpressionCondition condition;  // condicions durant la compilacio o execucio
    ExpressionErrorCode errCode;  // indica condicions d'error durant parseig o commit
    ExpressionErrorInfo errInfo;  // representacio interna de la posicio del error o el source afectat durant parse o commit
    ExpressionStateInfo rpnResultInfo;  // representacio interna del source afectat durant execucio
    
    NSData *sourceCodeData;
    CFMutableArrayRef sourceExpressions;  // expressions o simbols (SymbolicSource)
    CFDataRef sourceDependanceSkips;  // s'utilitza durant el commit per anotar els sources que no han de tenir aquesta com a dependent (no es codifica)
    
    //int clusterDependantCount;
    CFMutableArrayRef constantStrings; // strings constants (CFStrings)
    NSData *rpnCode;
}

// evaluacio i promocio de la expressio, el metode eval emet observacions propies i dels depenents
//- (void)eval;

// evaluacio forcada i promocio de la expressio sense canviar el origen,
- (void)evalWithConstantValue:(double)val;
- (void)evalWithConstantValuesFromData:(CFDataRef)dataValues;  // dataValues conte un array C de doubles
- (void)evalWithStringConstant:(CFStringRef)str;
- (void)evalWithStringConstantsFromCFArray:(CFArrayRef)strArray;
- (void)evalWithForcedState:(ExpressionStateCode)state;  // força un estat de la expressio i promou, no canvia el resultat
- (void)invalidate;  // crida el super i forca el estat de invalid

// estats de la expressio
- (ExpressionKind)kind;
//- (BOOL)isPromoting;

// Torna el codi d'error de la expressio o zero (ExpressionErrorCodeNone) si no hi ha error
// Torna una string representativa del codi d'error de la expressio o nil si no hi ha error
- (ExpressionErrorCode)errorCode;
- (NSString*)getSourceErrorString;

// Torna si el estat del resultat de la expressio
// Torna una string representativa del error de la expressio si es invalida
// Torna un color en principi adequat per representar un estat
- (ExpressionStateCode)state;
- (NSString*)getResultErrorString;  // torna nil si no hi ha error
- (UIColor*)getResultColor;  // torna nil si no hi ha error

// Torna el source del que depen, o nil si no podem assegurar que hi ha un relacio inequivoca
- (SWValue*)getExclusiveSource;

// Iteracio recursiva de sources
- (void)enumerateSourcesUsingBlock:(void (^)(id obj))block;

@end

// ---------------- SWValue Addition ---------------- //
@interface SWValue (ExpressionAdditons)

- (BOOL)isConstantValue;            // torna YES
//- (BOOL)isPromoting;                // torna NO
- (ExpressionStateCode)state;       // pot tornar ExpressionStateOk ExpressionStateOperationError
- (NSString*)getResultErrorString;  // pot tornar nil o ValueStateInvalid si el rpnValue associat conte un error
- (UIColor*)getResultColor;         // torna nil

@end

// ---------------- SWValue Addition ---------------- //
@interface SWValue (ExpressionAccess)
- (void)promote;  // implementada a SWValue
- (ExpressionKind)kind;
@end

//// ---------------- CLUSTER ---------------- //
//@interface SWExpression (Cluster)
//- (id)initAsClusterWithSources:(id)sources; // pot ser expressio, CFStringRef o CFMutableArray (de expressions o CFStringRef),
//- (id)initAsMutableCluster;  // podem afegir CFStringRefs i expressions mes tard amb add
//- (void)mutableClusterAddSource:(id)source;  // si no es mutable llanca una excepcio
//- (void)mutableClusterRemoveSource:(SWExpression*)source; // si no es mutable llanca una excepcio
//@end

// ---------------- RPN Builder ---------------- //
@interface SWExpression(RPNBuilder)
- (BOOL)commitUsingLocalSymbolTable:(CFDictionaryRef)symbolTable
            globalTable:(CFDictionaryRef)globalTable 
            systemTable:(CFDictionaryRef)systemTable
            wantsLink:(BOOL)wantsLink
            ignoreFaults:(BOOL)ignoreFaults
            outError:(NSError**)outError;
           
// considerades primitives, no afecten els observadors ni alteren el state de la expressio
#if __cplusplus
- (void)setSourceWithConstantRpnValue:(const RPNValue&)rpnVal resultInfo:(ExpressionStateInfo)resultInfo;
#endif

- (void)setSourceWithSymbol:(SymbolicSource *)symbol; // necessita commit
- (void)setSourceWithExpression:(SWExpression*)sourceExpr;
- (void)setSourceWithConstantValue:(double)value;

- (void)setSourceEmpty;
- (void)setError:(ExpressionErrorCode)err withInfo:(ExpressionErrorInfo)errDta;
- (void)setSourceCodeData:(NSData*)data;
- (void)setSourceDependanceSkips:(CFDataRef)dataSkips;
- (void)setSourceWithRpnCode:(NSData*)rpnCde withSources:(CFMutableArrayRef)sources withConstStrings:(CFMutableArrayRef)constStrings;
@end


// ---------------- RPN Interpreter ---------------- //
@interface SWExpression (RPNInterpreter)
//- (ExpressionCondition)condition;
- (CFMutableArrayRef)sourceExpressions;  // es mutable pero de longitud fixa
- (CFMutableArrayRef)constantStrings;   // es mutable pero de longitud fixa
- (NSData *)rpnCode;
@end
