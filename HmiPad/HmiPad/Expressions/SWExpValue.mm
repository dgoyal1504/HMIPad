//
//  SWExpValue.m
//  HmiPad
//
//  Created by Lluch Joan on 25/05/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

/*
#import "SWExpValue.h"
#import "SWColor.h"


//////////////////////////////////////////////////////////////////////////////////////
#pragma mark ExpValue
//////////////////////////////////////////////////////////////////////////////////////



//------------------------------------------------------------------------------------

//ExpressionValueType valueTypeForSWValueType(SWValueType typ)
//{
//    if ( typ == SWValueTypeNumber ) return ExpressionValueTypeNumber ;
//    if ( typ == SWValueTypeString ) return ExpressionValueTypeString ;
//    if ( typ == SWValueTypeArray ) return ExpressionValueTypeArray ;
//    return ExpressionValueTypeUnknown ;
//}

//------------------------------------------------------------------------------------
NSString *valueTypeStringForSWValueType(SWValueType typ)
{
    if ( typ == SWValueTypeNumber ) return @"number" ;
    if ( typ == SWValueTypeString ) return @"string" ;
    if ( typ == SWValueTypeArray ) return @"array" ;
    if ( typ == SWValueTypeString ) return @"error" ;
    //if ( rpnValue.typ == SWValueTypeClassSelector ) return @"selector" ;
    return nil ;
}


//------------------------------------------------------------------------------------
// Representa un proxy de un RPNValue que respon a alguns metodes de conveniencia per
// obtenir els valors del contingut
// Es pot obtenir enviant value a una expressio.

@implementation SWExpValue
{
    // guardem un punter l'objecte representat
    const RPNValue *pRpnValue ;
}

- (id)initWithRPNValue:( const RPNValue& )rpnVal
{
    pRpnValue = &rpnVal ;
    return self ;
}

//- (ExpressionValueType)valueType
//{
//    return valueTypeForSWValueType( pRpnValue->typ ) ;
//}

- (NSString *)valueTypeString
{    
    return valueTypeStringForSWValueType( pRpnValue->typ ) ;
}


- (NSInteger)valuesCount
{
    int count = pRpnValue->arrayCount() ;
    if ( count == 0 ) count = 1 ;
    return count ; ;
}

// torna nil si es out of bounds
- (SWExpValue*)valueAtIndex:(NSInteger)indx
{
    SWExpValue *result = nil ;
    int count = pRpnValue->arrayCount() ;
    
    if ( indx == 0 && count == 0 )
    {
        //result = [self retain] ;
        result = self ;
    }
    
    else if ( indx >= 0 && indx < count )
    {
        const RPNValue& value = pRpnValue->valueAtIndex(indx) ;
        result = [[SWExpValue alloc] initWithRPNValue:value] ;
    }

    return result ;
    //return [result autorelease] ;
}

- (double)valueAsDouble
{
    return valueAsDoubleForRpnValue( *pRpnValue );
}

- (NSString *)valueAsStringWithFormat:(NSString*)format
{
    CFStringRef str = createStringForRpnValue_withFormat( *pRpnValue, (__bridge CFStringRef)format ) ;
    return (__bridge_transfer NSString*)str ;
    //return [(NSString*)str autorelease] ;
}

- (UIColor*)valueAsColor
{
    UInt32 colorValue = Theme_RGB(0, 255, 255, 255) ;   // per defecte blanc  (podria ser negre o gris fosc)
    SWValueType valueType = pRpnValue->typ;
    
    // utilitzacio de SM.Color  ( retorna un 'colorValue' numeric ) (normalment nomes fariem això)
    if ( valueType == SWValueTypeNumber ) colorValue = valueAsDoubleForRpnValue( *pRpnValue );
    
    // suport per el nom del color directament ( retorna una string, per exemple "blue" )
    if ( valueType == SWValueTypeString ) 
    {
        CFStringRef str = createStringForRpnValue_withFormat( *pRpnValue, nil ) ;
        colorValue = getRgbValueForString( (__bridge id)str ) ;
        if ( str ) CFRelease( str ) ;
    }
    
    return UIColorWithRgb(colorValue) ;
}

// suport per fast enumeration
// ( mes info a http://cocoawithlove.com/2008/05/implementing-countbyenumeratingwithstat.html )
// ( i a http://www.informit.com/articles/article.aspx?p=1436920&seqNum=5 )
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state 
        objects:(id __unsafe_unretained [])stackbuf count:(NSUInteger)len
{
    static unsigned long mutationsDummy = 0 ;
    
    // posem un valor invariable al mutationsPtr
    state->mutationsPtr = &mutationsDummy ;
    
    // mida total del array a iterar
    NSUInteger arrayCount = pRpnValue->arrayCount() ;
        
    // si no es un array farem una unica iteracio tornant ell mateix
    if ( arrayCount == 0 )
    {
        if ( state->state == 1 ) // si ja hem fet la iteracio, tornem zero
        {
            return 0 ;
        }
        state->state = 1 ;          // 1 per la seguent iteracio
        state->itemsPtr = (id __unsafe_unretained *)(void*)&self ;   // tornem ell mateix
        return 1 ;                  // la longitud es de 1 element
    }
    
    // alliberem els valors passats en la ronda anterior
    for ( int i=0 ; i<state->extra[0] ; i++ )
    {
        //[stackbuf[i] release] ;
        CFRelease( (__bridge CFTypeRef)stackbuf[i] ) ;  // forcem el release !
        stackbuf[i] = nil ;
    }
    
    // copiem la seguent ronda de valors
    unsigned long offset = state->state ;
    unsigned long n = arrayCount - offset ;
    if ( n > len ) n = len ;
    
    for ( unsigned long i=0 ; i<n ; i++ )
    {
        const RPNValue &rpnValue = pRpnValue->valueAtIndex( i+offset ) ;
        //SWExpValue *value = [[SWExpValue alloc] initWithRPNValue:rpnValue] ;
        CFTypeRef value = (__bridge_retained CFTypeRef)[[SWExpValue alloc] initWithRPNValue:rpnValue] ; // forcem releasecount == 1
        stackbuf[i] = (__bridge __unsafe_unretained id)value ;
    }
    
    state->state = n+offset ;       // punt de partida per la seguent iteracio
    state->itemsPtr = stackbuf ;    // punter al buffer amb els objectes
    state->extra[0] = n ;           // utilitzem extra[0] per posar la longitud anterior utilitzada del buffer
    return n ;                      // longitud utilitzada del buffer
}



@end

 */
