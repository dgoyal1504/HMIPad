//
//  SWExpressionCommonTypes.h
//  HmiPad
//
//  Created by Joan on 19/08/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//


// Errors de parseig i commit
typedef enum : UInt8
{
    // cap error
    ExpressionErrorCodeNone = 0,  // sempre zero
    
    // errors de parseig
    ExpressionErrorCodeMissingTrailingBracket1,
    ExpressionErrorCodeTooManyArguments,
    ExpressionErrorCodeTooManySources,
    ExpressionErrorCodeMissingTrailingSqBracket1,
    ExpressionErrorCodeUnknownMethodIdentifier,
    ExpressionErrorCodeExpectedPropertyOrMethodIdentifier,
    ExpressionErrorCodeMissingTrailingCrBracket,
    ExpressionErrorCodeSymbolSyntaxError,
    ExpressionErrorCodeSymbolExpected,
    ExpressionErrorCodeMissingTrailingBracket2,
    ExpressionErrorCodeMissingTrailingSqBracket2,
    ExpressionErrorCodeMissingTrailingCrBracket2,
    ExpressionErrorCodeExpectedPrimitiveExpression,
    ExpressionErrorCodeMissingColonInTernaryOperator,
    ExpressionErrorCodeExtraCharsAfterExpression,
    ExpressionErrorCodeExpectedExpression,
    ExpressionErrorCodeCouldNotEvalutateConstantExpression,
    
    // centinela per el comencament dels errors de commit
    ExpressionErrorCodeCommitError = 64,
    
    // errors de commit
    ExpressionErrorCodeSymbolNotFound,
} ExpressionErrorCode;


// Estructura per la informacio de error de parseig o commit
typedef struct
{
    union
    {
        UInt16 sourceOffset;  // conte el offset a sourceCodeData on l'error s'ha produit (error de parser)
        UInt8 sourceIndx[4];  // conte el index del source afectat o 0xff si no es rellevant (error de commit)
    };
} ExpressionErrorInfo;


// Estats de la Expressio
typedef enum : UInt8
{
    ExpressionStateOk = 0,               // Indica un valor correcte de la expressio
    ExpressionStateCircularReference,    // Indica que un descendent provoca una referencia circular
    ExpressionStatePendingSource,        // Indica que un source esta pendent de evaluar
    ExpressionStateBadQualitySource,     // Indica que el origen de un source es dolent (ex error de tag)
    ExpressionStateDisconnectedSource,   // Indica que el origen de un source es dolent (ex error de comunicacio, o source desconectat)
    
    ExpressionStateInvalidSource,        // Indica que un source es invalid. Durant la evaluacio qualsevol error
                                         // mes gran que aquest en un source es consolida en aquest en la expressio evaluada
                                         // el valor de la expressio no canvia
                                         
    // els seguents errors es consideren de interpretacio del codi rpn i provoquen una condicio de error en el rpnValue
    ExpressionStateWrongRpn,             // Indica que el codi rpn es incorrecte, es pot considerar un error intern
    ExpressionStateTooComplex,           // Indica que la expressio es massa complexe
    ExpressionStateUnknownIdentifier,    // Indica que la expressio conte al menys un source simbol que no ha rebut commit
    ExpressionStateOperationError,       // Indica error en una operacio amb RPNValues, el RPNValue conte un codi de tipus RPNValueErrCode
} ExpressionStateCode;


// Estructura per la informacio d'estat de la expressio
typedef struct ExpressionStateInfo
{
    ExpressionStateCode state;
    UInt8 sourceIndx;
} ExpressionStateInfo;


// Resultats del RpnInterpreter
typedef enum : UInt8
{
    RpnInterpreterResultOk = 0,     // indica interpretacio correcte de la expressio, el valor pot haver canviat i s'ha de promoure
    RpnInterpreterResultHalt,       // indica interpretacio correcte de la expressio, el valor no ha canviat i no s'ha de promoure
    RpnInterpreterResultInvalid,    // indica que un source es invalid, el valor no canvia pero s'ha de promoure
    RpnInterpreterResultRpnError,   // indica un error durant la interpretacio, el valor pot haver canviat, s'ha de promoure
} RpnInterpreterResultCode;

