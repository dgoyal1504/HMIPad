//
//  RpnInterpreter.m
//  HmiPad_101116
//
//  Created by Joan on 17/11/10.
//  Copyright 2010 SweetWilliam, S.L. All rights reserved.
//

#import "RpnInterpreter.h"
#import "SWExpression.h"

//------------------------------------------------------------------------------------
@implementation RpnInterpreter


//------------------------------------------------------------------------------------
+ (RpnInterpreter*)sharedRpnInterpreter
{
    static RpnInterpreter *rpnInterpreter = nil;
    if ( rpnInterpreter == nil )
    {
        rpnInterpreter = [[RpnInterpreter alloc] init];
    }
    return rpnInterpreter;
}

//------------------------------------------------------------------------------------
- (id)init
{
    if ( (self = [super init]) )
    {
        acc = (RPNValue*)accbytes;
    }
    return self;
}

//------------------------------------------------------------------------------------
- (void)dealloc
{
// arc    [super dealloc];
}

//------------------------------------------------------------------------------------
static void clearUsedStackObjects( RpnInterpreter *self )
{
    for ( int i=0; i<self->accMaxIndx; i++ )
    {
        RPNValue &rpnValue = self->acc[i];
        rpnValue.clear();
    }
}

////------------------------------------------------------------------------------------
//- (RpnInterpreterResult)resultInfo
//{
//    return resultInfo;
//}

//------------------------------------------------------------------------------------
- (RpnInterpreterResultCode)resultWithHalt
{
    _resultInfo->state = ExpressionStateOk;
    _resultInfo->sourceIndx = 0xff ;
    clearUsedStackObjects( self );
    return RpnInterpreterResultHalt;
}




//------------------------------------------------------------------------------------
- (RpnInterpreterResultCode)resultWithUknownIdentifierErrorForSourceIndex:(UInt8)indx
{
    //_result->clear();  // el valor no cambia
    _resultInfo->state = ExpressionStateUnknownIdentifier;
    _resultInfo->sourceIndx = indx;
    clearUsedStackObjects( self );
    return RpnInterpreterResultInvalid;
}

//------------------------------------------------------------------------------------
- (RpnInterpreterResultCode)resultWithInvalidSourceExpression:(SWExpression*)expr sourceIndex:(UInt8)indx
{
    // _result->clear();  // el valor no canvia
    
    ExpressionStateCode state = [expr state];
    if ( state > ExpressionStateInvalidSource ) state = ExpressionStateInvalidSource;
    
    _resultInfo->state = state;
    _resultInfo->sourceIndx = indx;
    clearUsedStackObjects( self );
    return RpnInterpreterResultInvalid;
}

////------------------------------------------------------------------------------------
//- (UInt8)resultWithSourceError:(UInt8)error sourceIndex:(UInt8)indx
//{
//    (*result).clear();
//    resultInfo.state = error;
//    resultInfo.sourceIndx = indx;
//    clearUsedStackObjects( self );
//    return error;
//}

//------------------------------------------------------------------------------------
- (RpnInterpreterResultCode)resultWithOperationErrorWithRpnValue:(const RPNValue*)value
{
    *_result = *value;   // el resultat es el rpnValue (error amb un codi de error)
    _resultInfo->state = ExpressionStateOperationError; // el error es OperationError
    _resultInfo->sourceIndx = 0xff;
    clearUsedStackObjects( self );
    
    if ( _result->err == RPNVaErrorCodedWrongType )
        return RpnInterpreterResultOk;
    
    return RpnInterpreterResultRpnError;
}

//------------------------------------------------------------------------------------
- (RpnInterpreterResultCode)resultWithInterpreterError:(ExpressionStateCode)error
{
    _result->clear();  // el valor es: error generic
    _resultInfo->state = error;   // el error es del RPNInterpreter
    _resultInfo->sourceIndx = 0xff;
    clearUsedStackObjects( self );
    return RpnInterpreterResultRpnError;
}

//------------------------------------------------------------------------------------
- (RpnInterpreterResultCode)evalRpn:(CFDataRef)rpnCode sources:(CFArrayRef)sources constStrings:(CFArrayRef)constStrings outValue:(RPNValue *)rpnValue outStatus:(ExpressionStateInfo*)resultInfo;
{
    const UInt8 *p = (UInt8*)CFDataGetBytePtr( rpnCode );
    const UInt8 *max = p + CFDataGetLength( rpnCode );
    accIndx = 0;
    _result = rpnValue;  // guardem el punter al rpnValue que hem de modificar
    _resultInfo = resultInfo; // guardem el punter al resultInfo que hem d'actualitzar
    
    while ( p < max )
    {
        if ( accIndx+3 >= AccDepth ) return [self resultWithInterpreterError:ExpressionStateTooComplex];
        if ( accIndx < 0 ) return [self resultWithInterpreterError:ExpressionStateWrongRpn];

        UInt8 opCode = *p;
        p += sizeof(UInt8);
        
        switch ( opCode & RpnOffsetMask )
        {
            case RpnOffsetPrimitive :
            {
                switch ( opCode )
                {
                    case RpnVarLd  :
                    {
                        if ( sources == NULL ) return [self resultWithInterpreterError:ExpressionStateWrongRpn];
                        UInt8 indx = *p;
                        __unsafe_unretained SWValue *value = (__bridge id)CFArrayGetValueAtIndex( sources, indx );
                        p += sizeof(UInt8);
                        
                         // si no es un referenceable value no hauria d'haver arribat aqui
                        if ( ![value isKindOfClass:[SWValue class]] )
                        {
                            return [self resultWithUknownIdentifierErrorForSourceIndex:indx]; 
                        }
                        
                        // a partir d'aqui es una expressio
                        //if ( [value state] != ExpressionStateOk )
                        if ( [value state] != ExpressionStateOk )
                        {
                            return [self resultWithInvalidSourceExpression:(id)value sourceIndex:indx];
                        }
                        
                        const RPNValue &rpnVal = [value rpnValue];
                        acc[accIndx] = rpnVal;
                        //acc[accIndx].status = [value isPromoting];
                        acc[accIndx].status.changing = [value isPromoting]?1:0;
                        accIndx++;
                        break;
                    }
                    
//                    case RpnDisconnectedLd:
//                    {
//                        UInt8 dummy = *p;
//                        (void)dummy;
//                        p += sizeof(UInt8);
//                        acc[accIndx].noSource();
//                        acc[accIndx].status.changing = 0;
//                        accIndx++;
//                        break;
//                    }
                    
                    case RpnConstLd:
                    {
                        double value;
                        getValueFromByteAddr( value, p );
                        p += sizeof(double);
                        acc[accIndx] = value;
                        acc[accIndx].status.changing = 0;
                        accIndx++;
                        break;
                    }
                    
                    case RpnTimeLd:
                    {
                        double value;
                        getValueFromByteAddr( value, p );
                        p += sizeof(double);
                        acc[accIndx] = value;
                        acc[accIndx].typ = SWValueTypeAbsoluteTime;  // overridem el tipus a sacu
                        acc[accIndx].status.changing = 0;
                        accIndx++;
                        break;
                    }
                    
//                    case RpnConstStrLd:
//                    {
//                        if ( constStrings == NULL ) 
//                        {
//                            return [self resultWithInterpreterError:ExpressionStateWrongRpn];
//                        }
//
//                        CFStringRef str = (CFStringRef)CFArrayGetValueAtIndex( constStrings, *p );
//                        p += sizeof(UInt8);
//                        acc[accIndx] = str;
//                        acc[accIndx].status.changing = 0;
//                        accIndx++;
//                        break;
//                    }
                    
                    case RpnConstStrLd:
                    {
                        if ( constStrings == NULL ) 
                        {
                            return [self resultWithInterpreterError:ExpressionStateWrongRpn];
                        }
                        
                        UInt16 strIndx = *(UInt16*)p;
                        p += sizeof(UInt16);
                        
                        CFStringRef str = (CFStringRef)CFArrayGetValueAtIndex( constStrings, strIndx );
                        acc[accIndx] = str;
                        acc[accIndx].status.changing = 0;
                        accIndx++;
                        break;
                    }
                    
                    case RpnArrayLd:
                    case RpnHashLd:
                    {
                        acc[accIndx].clear();   // inicialitzem una posicio buida per posar l'array o hash
                        acc[accIndx].status.changing = 0;
                        accIndx++;
                        break;
                    }
                    
                    case RpnClassLd:
                    {
                        UInt16 clSel = *(UInt16*)p;
                        p += sizeof(UInt16);
                        acc[accIndx] = (UInt32)clSel;
                        acc[accIndx].status.changing = 0;
                        accIndx++;
                        break;
                    }
                    case RpnExit:
                    {
//                        resultInfo.all = 0;
//                        clearUsedStackObjects( self );
//                        return RpnInterpreterResultHalt;
                        return [self resultWithHalt];
                    }
                    default : return [self resultWithInterpreterError:ExpressionStateWrongRpn];
                    
                }
                
                accMaxIndx = accIndx;
                break;
            }
            
            
            case RpnOffsetIndirection :
            {
                UInt16 count = *(UInt16*)p;   // nombre de arguments
                p += sizeof(UInt16);   
                RPNValue &rpnA = acc[accIndx-count-1]; // element base
                RPNValue *args = &rpnA + 1; // punter als arguments
                accIndx -= count;
                
                switch ( opCode )
                {
                    case RpnGetElement :
                    {
                        rpnA.getElement( count, args );
                        break;
                    }
                    case RpnFillArray :
                    {
                        rpnA.arrayMake( count, args );
                        break;
                    }
                    case RpnFillHash :
                    {
                        rpnA.hashMake( count, args );
                        break;
                    }
                    case RpnCallFunct :
                    {
                        UInt16 csl = *(UInt16*)p;  // selector de clase
                        p += sizeof(UInt16);
                        UInt16 msl = *(UInt16*)p;  // selector de metode
                        p += sizeof(UInt16);
                        rpnA.callFunct( csl, msl, count, args );
                        break;
                    }
                    default : return [self resultWithInterpreterError:ExpressionStateWrongRpn];
                }
                
                if ( rpnA.isError() ) return [self resultWithOperationErrorWithRpnValue:&rpnA];
                for ( int i=0; i<count; i++ ) rpnA.status.changing |= args[i].status.changing;
                break;
            }
              
            case RpnOffsetUnary:
            {
                RPNValue &rpnA = acc[accIndx-1];
                switch ( opCode )
                {
                    case RpnOpMinus:
                    {
                        rpnA.minus();
                        break;
                    }
                    case RpnOpNot:
                    {
                        rpnA.opnot();
                        break;
                    }
                    case RpnOpCompl:
                    {
                        rpnA.opcompl();
                        break;
                    }
                    
                    default : return [self resultWithInterpreterError:ExpressionStateWrongRpn];
                }
                
                if ( rpnA.isError() ) return [self resultWithOperationErrorWithRpnValue:&rpnA];
                break;
            }
               
            //case RpnOffsetArith:
            case RpnOffsetFactor:
            case RpnOffsetTerm:
            case RpnOffsetBitAnd:
            case RpnOffsetBitOrXor:
            case RpnOffsetCompare:
            case RpnOffsetLogAnd:
            case RpnOffsetLogOr:
            case RpnOffsetRange:
            {
                RPNValue &rpnA = acc[accIndx-2];
                RPNValue &rpnB = acc[accIndx-1];
                accIndx--;
                
                switch ( opCode )
                {
                    //--
                    case RpnOpTimes:
                    {
                        rpnA.times(rpnB);
                        break;
                    }
                    case RpnOpDiv:
                    {
                        rpnA.div(rpnB);
                        break;
                    }
                    case RpnOpMod:
                    {
                        rpnA.mod(rpnB);
                        break;
                    }
                        
                    //--
                    case RpnOpAdd:
                    {
                        rpnA.add(rpnB);
                        break;
                    }
                    case RpnOpSub:
                    {
                        rpnA.sub(rpnB);
                        break;
                    }
                       
                    //--
                    case RpnOpBitAnd:
                    {
                        rpnA.opbitand(rpnB);
                        break;
                    }
                    
                    //--
                    case RpnOpBitOr:
                    {
                        rpnA.opbitor(rpnB);
                        break;
                    }
                    case RpnOpBitXor:
                    {
                        rpnA.opbitxor(rpnB);
                        break;
                    }

                    //--
                    case RpnOpLt:
                    {
                        rpnA.lt(rpnB);
                        break;
                    }
                    case RpnOpLe:
                    {
                        rpnA.le(rpnB);
                        break;
                    }
                    case RpnOpEq:
                    {
                        rpnA.eq(rpnB);
                        break;
                    }
                    case RpnOpNe:
                    {
                        rpnA.ne(rpnB);
                        break;
                    }
                    case RpnOpGe:
                    {
                        rpnA.ge(rpnB);
                        break;
                    }
                    case RpnOpGt:
                    {
                        rpnA.gt(rpnB);
                        break;
                    }
                        
                    //--
                    case RpnOpAnd:
                    {
                        rpnA.opand(rpnB);
                        break;
                    }
                    
                    //--
                    case RpnOpOr:
                    {
                        rpnA.opor(rpnB);
                        break;
                    }
                    
                    //--
                    case RpnOpRange:
                    {
                        rpnA.range(rpnB);
                        break;
                    }                 
                    
                    default : return [self resultWithInterpreterError:ExpressionStateWrongRpn];
                }
                
                if ( rpnA.isError() ) return [self resultWithOperationErrorWithRpnValue:&rpnA];
                rpnA.status.changing |= rpnB.status.changing;  // 1 si al menys un es 1
                break;
            }
                        
            case RpnOffsetTern:
            {
                RPNValue &rpnA = acc[accIndx-3];
                RPNValue &rpnB = acc[accIndx-2];
                RPNValue &rpnC = acc[accIndx-1];
                accIndx -= 2;
                
                switch ( opCode )
                {
                    case RpnOpTern:
                    {
                        rpnA.tern(rpnB, rpnC);
                        break;
                    }
                    default : return [self resultWithInterpreterError:ExpressionStateWrongRpn];
                }
                
                if ( rpnA.isError() ) return [self resultWithOperationErrorWithRpnValue:&rpnA];
                rpnA.status.changing |= (rpnB.status.changing | rpnC.status.changing);
                break;
            }
            
            case RpnOffsetIf:
            {
                if ( opCode == RpnEndIf )
                {
                    acc[accIndx-2] = acc[accIndx-1];    // movem el resultat una posicio enrera (posicio de la expressio if)
                    accIndx--;   // el status resultant sera el que tenia la expressio if
                }
                else
                {
                    UInt16 inc = *(UInt16*)p;   // increment
                    p += sizeof(UInt16);
                
                    switch ( opCode )
                    {
                        case RpnOpJeq:
                        {
                            RPNValue &rpnA = acc[accIndx-1];
                            bool jeq = rpnA.jeq();
                            if ( jeq ) p += inc;
                            //accIndx -= 1;   // la expressio if no la treiem de la pila
                            if ( rpnA.isError() ) return [self resultWithOperationErrorWithRpnValue:&rpnA];
                            break;
                        }
                    
                        case RpnOpJmp:
                        {
                            p += inc;
                            break;
                        }
                    
                        default : return [self resultWithInterpreterError:ExpressionStateWrongRpn];
                    }
                }
                break;
            }
            
            case RpnOffsetList :
            {
                UInt16 count = *(UInt16*)p;   // nombre de elements
                if ( count == 0 ) return [self resultWithInterpreterError:ExpressionStateWrongRpn];
                
                p += sizeof(UInt16);
                RPNValue *listP = &acc[accIndx-count]; // punter a la llista
                accIndx -= count-1;
                switch ( opCode )
                {
                    case RpnOpComma :
                    {
                        BOOL change = listP->commaList( count, listP );
                        if ( !change ) return [self resultWithHalt];
                        break;
                    }
                    default : return [self resultWithInterpreterError:ExpressionStateWrongRpn];
                }
                
                //if ( listP->isError() ) return [self resultWithOperationErrorWithValue:listP];
                listP->status.changing = 1; //RPNVaFlagChanging;
                break;
            }
            
            default : return [self resultWithInterpreterError:ExpressionStateWrongRpn];
        }
    }
    
    if ( accIndx != 1 ) return [self resultWithInterpreterError:ExpressionStateWrongRpn];
    
    *_result = acc[0];
    _resultInfo->state = ExpressionStateOk;
    _resultInfo->sourceIndx = 0xff;
    clearUsedStackObjects( self );
    return RpnInterpreterResultOk;
}



//------------------------------------------------------------------------------------
- (RpnInterpreterResultCode)evalExpression:(SWExpression*)expression outValue:(RPNValue*)rpnValue outStatus:(ExpressionStateInfo*)resultInfo
{
    accIndx = 0;
    accMaxIndx  = 0;
    _result = rpnValue;  // guardem el punter al rpnValue que hem d'actualitzar
    _resultInfo = resultInfo; // guardem el punter al resultInfo que hem d'actualitzar
    
    UInt8 kind = [expression kind];
    
    // tipus desconegut
    if ( kind == ExpressionKindUnknown )
    {
        return [self resultWithInterpreterError:ExpressionStateInvalidSource];
    }

    // expressions constants
    else if ( kind == ExpressionKindConst )
    {
        // res, tornara el resultat d'ella mateixa
        //_resultInfo->state = ExpressionStateOk;
        _resultInfo->state = rpnValue->typ==SWValueTypeError ? ExpressionStateOperationError : ExpressionStateOk;
        _resultInfo->sourceIndx = 0xff;
        return RpnInterpreterResultOk;
    }

    // expresions code
    else if ( kind == ExpressionKindCode )
    {
        NSData *rpnCode = [expression rpnCode];
        CFArrayRef sources = [expression sourceExpressions];
        CFArrayRef constStrings = [expression constantStrings];
        return [self evalRpn:(CFDataRef)rpnCode sources:sources constStrings:constStrings outValue:rpnValue outStatus:resultInfo];
    }

    // expressions amb un source
    else if ( kind == ExpressionKindSymb )
    {
        __unsafe_unretained SWValue *value = expression;
        CFArrayRef sources = [expression sourceExpressions];
        if ( sources == NULL || CFArrayGetCount( sources ) != 1 )
        {
            return [self resultWithInterpreterError:ExpressionStateWrongRpn];
        }
        
        value = (__bridge id)CFArrayGetValueAtIndex( sources, 0 );
        
        if ( ![value isKindOfClass:[SWValue class]] )
        {
            return [self resultWithUknownIdentifierErrorForSourceIndex:0];
        }
    
        if ( [value state] != ExpressionStateOk )
        {
            return [self resultWithInvalidSourceExpression:(id)value sourceIndex:0];
        }
        
        *_result = [value rpnValue];
        _resultInfo->state = ExpressionStateOk;
        _resultInfo->sourceIndx = 0xff;
        return RpnInterpreterResultOk;
    }
    
    // malu, aqui no hauria d'haver arribat mai
    return [self resultWithInterpreterError:ExpressionStateWrongRpn];
}



@end
