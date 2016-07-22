//
//  RpnInterpreter.h
//  HmiPad_101116
//
//  Created by Joan on 17/11/10.
//  Copyright 2010 SweetWilliam, S.L. All rights reserved.
//

#import <Foundation/Foundation.h>

//class RPNValue ;
#import "SWExpressionCommonTypes.h"


#import "RPNValue.h"

//-------------------------------------------------------------------------------------------
// opcodes

/*
enum
{
    RpnOffsetPrimitive = 0x00,
    RpnOffsetIndirection = 0x10,
    RpnOffsetUnary = 0x20,
    
    RpnOffsetArith = 0x30,
    RpnOffsetCompare = 0x40,
    RpnOffsetLogicalBitwise = 0x50,
    
    RpnOffsetTern = 0x60,
    RpnOffsetIf = 0x70,
    
    RpnOffsetMask = 0xf0,
    RpnOpCodeMask = 0x0f,
} ;
*/



//enum
//{
//    RpnOffsetPrimitive = 0xf0,
//    RpnOffsetIndirection = 0xe0,
//    RpnOffsetUnary = 0xd0,
//
//    RpnOffsetFactor = 0xa0,      // ordenats per ordre de prioritat d'execucio
//    RpnOffsetTerm = 0x90,
//    RpnOffsetBitAnd = 0x80,
//    RpnOffsetBitOrXor = 0x70,
//    RpnOffsetCompare = 0x60,
//    RpnOffsetLogAnd = 0x50,
//    RpnOffsetLogOr = 0x40,
//
//    RpnOffsetTern = 0x30,
//    RpnOffsetIf = 0x20,
//    RpnOffsetList = 0x10,
//    
//    RpnNoOperation = 0x00,
//    
//    RpnPrecedenceMask = 0xf0,
//    RpnOffsetMask = 0xf0,
//    RpnOpCodeMask = 0x0f,
//} ;


enum
{
    RpnOffsetPrimitive = 0xf0,
    RpnOffsetIndirection = 0xe0,
    RpnOffsetUnary = 0xd0,

    RpnOffsetFactor = 0xb0,      // ordenats per ordre de prioritat d'execucio
    RpnOffsetTerm = 0xa0,
    RpnOffsetBitAnd = 0x90,
    RpnOffsetBitOrXor = 0x80,
    RpnOffsetCompare = 0x70,
    RpnOffsetLogAnd = 0x60,
    RpnOffsetLogOr = 0x50,
    RpnOffsetRange = 0x40,

    RpnOffsetTern = 0x30,
    RpnOffsetIf = 0x20,
    RpnOffsetList = 0x10,
    
    RpnNoOperation = 0x00,
    
    RpnPrecedenceMask = 0xf0,
    RpnOffsetMask = 0xf0,
    RpnOpCodeMask = 0x0f,
} ;


// RpnOffsetPrimitive
enum
{
    RpnVarLd = RpnOffsetPrimitive,
    //RpnDisconnectedLd,
    RpnConstLd,
    RpnTimeLd,
    RpnConstStrLd,
    RpnArrayLd,
    RpnHashLd,
    RpnClassLd,
    RpnExit,
} ;

// RpnOffsetIndirection
enum
{
    RpnGetElement = RpnOffsetIndirection ,
    RpnFillArray,
    RpnFillHash,
    RpnCallFunct,
} ;


// RpnOffsetBinaryOperators
enum
{
    RpnOpTimes = RpnOffsetFactor,
    RpnOpDiv,
    RpnOpMod,

    RpnOpAdd = RpnOffsetTerm ,
    RpnOpSub,

    RpnOpBitAnd = RpnOffsetBitAnd,
    
    RpnOpBitOr = RpnOffsetBitOrXor,
    RpnOpBitXor,
    
    RpnOpLt = RpnOffsetCompare,
    RpnOpLe,
    RpnOpEq,
    RpnOpNe,
    RpnOpGe,
    RpnOpGt,
    
    RpnOpAnd = RpnOffsetLogAnd,
    
    RpnOpOr = RpnOffsetLogOr,
    
    RpnOpRange = RpnOffsetRange,

} ;


// RpnOffsetUnary
enum
{
    RpnOpMinus = RpnOffsetUnary,
    RpnOpNot,
    RpnOpCompl,
} ;


// RpnOffsetTern
enum
{
    RpnOpTern = RpnOffsetTern,
} ;


// RPnOffsetIf
enum
{
    RpnOpJeq = RpnOffsetIf,
    RpnOpJmp,
    RpnEndIf
} ;

// RPnOffsetList
enum
{
    RpnOpComma = RpnOffsetList,
} ;


#define getValueFromByteAddr( value, addr ) ( memcpy(&(value), (addr), sizeof(value) ) )

//-------------------------------------------------------------------------------------------
// per amagatzemar doubles o ids en la pila del rpn
//typedef union RpnValue
//{
//    double d ;
//    CFTypeRef obj ;
//} RpnValue ;

//-------------------------------------------------------------------------------------------
// indicacio del tipus amagatzemat a la pila del rpn
//enum
//{
//    kRpnTypeUnknown = 0,
//    kRpnTypeDouble,
//    kRpnTypeString,
//    kRpnTypeIndirectObj
//} ;

//------------------------------------------------------------------------------------
@class SWExpression;

#define AccDepth 2500


//------------------------------------------------------------------------------------
@interface RpnInterpreter : NSObject 
{
    UInt8* accbytes[AccDepth*sizeof(RPNValue)];
    RPNValue *acc;
    int accIndx;
    int accMaxIndx;
    ExpressionStateInfo *_resultInfo;
    RPNValue *_result;
}

+ (RpnInterpreter*)sharedRpnInterpreter ;

// les dues seguents tornen un valor del enum RpnInterpreterResultCode
- (RpnInterpreterResultCode)evalRpn:(CFDataRef)rpnCode sources:(CFArrayRef)sources constStrings:(CFArrayRef)constStrings
        outValue:(RPNValue*)rpnValue outStatus:(ExpressionStateInfo*)resultInfo;
- (RpnInterpreterResultCode)evalExpression:(SWExpression*)expression outValue:(RPNValue*)value
        outStatus:(ExpressionStateInfo*)resultInfo;

@end

