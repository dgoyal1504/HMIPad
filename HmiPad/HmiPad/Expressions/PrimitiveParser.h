//
//  PrimitiveParser.h
//  HmiPad_101116
//
//  Created by Joan on 16/11/10.
//  Copyright 2010 SweetWilliam, S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
//-------------------------------------------------------------------------------------------
// per amagatzemar doubles desalineats
//
// Double value ;
// double num = value.d ;   // access al double
// UInt32 part = value.part.a  // access a les parts 
// UInt32 part = value.part.b 
//
typedef union Double
{
    double d ;
    struct
    {
        UInt32 a ;
        UInt32 b ;
    } part ;

} Double ;

#define doubleFromDoubleByteAddr( value, addr ) ( value.part.a = *(UInt32*)(addr), value.part.b = *(UInt32*)((addr)+sizeof(UInt32)), value.d )
*/

//-------------------------------------------------------------------------------------------
@interface PrimitiveParser : NSObject 
{
    int _line ;
    const unsigned char *c ;
    const unsigned char *beg ;
    const unsigned char *end ;
}

/////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Skip Functions
/////////////////////////////////////////////////////////////////////////////////////////////

//-------------------------------------------------------------------------------------------
// Les funcions skip causen salts del punter en busqueda de condicions
// Potencialment modifiquen el punter independentment del seu resultat

//-------------------------------------------------------------------------------------------
// salta espais, tabs, i finals de linea
//#define _skip { while ( c < end && ( *c == ' ' || *c == '\t' || ((*c == '\r' || *c == '\n' ) && ++line) ) ) c++ ; }
#define _skip { while ( c < end && ( *c == ' ' || *c == '\t' || *c == '\r' || (*c == '\n' && (_line+=1)) ) ) c++ ; }

//-------------------------------------------------------------------------------------------
// salta espais
#define _skipSp { while ( c < end && *c == ' ' ) c++ ; }

//-------------------------------------------------------------------------------------------
// salta espais i tabuladors
#define _skipSpTab { while ( c < end && (*c == ' ' || *c == '\t') ) c++ ; }

//-------------------------------------------------------------------------------------------
// salta fins a trobar el caracter especificat
#define _skipToChar(ch) { while ( c < end && *c != (ch) ) c++ ; }

//-------------------------------------------------------------------------------------------
// salta fins despres de trobar el caracter especificat
#define _skipPastChar(ch) { while ( c < end && *c++ != (ch) ) ; }

//-------------------------------------------------------------------------------------------
// salta fins a trobar la CString especificada
#define _skipToCString(cStr,len) { while ( c+(len) <= end && strncasecmp((char*)c,(cStr),(len)) != 0 ) c++ ; }

//-------------------------------------------------------------------------------------------
// salta fins a trobar algun dels caracters especificats en ccstr
- (void)skipToAnyCharIn:(const char*)ccstr ;

//-------------------------------------------------------------------------------------------
// salta fins a trobar el caracter especificat o el final de dades
- (BOOL)skipToChar:(unsigned char)ch outStr:(const unsigned char**)cstr length:(size_t*)len ;

//-------------------------------------------------------------------------------------------
// salta fins a trobar algun dels caracters especificats en ccstr o el final de dades tornant per
// referencia el lloc i la longitud
- (BOOL)skipToAnyCharIn:(const char*)ccstr outStr:(const unsigned char**)cstr length:(size_t*)len ;

//-------------------------------------------------------------------------------------------
// salta fins a trobar el caracter especificat i torna si ha trobat el caracter
- (BOOL)skipPastChar:(unsigned char)ch ;

//-------------------------------------------------------------------------------------------
// salta fins a trobar el començament de la C string especificada o el final de dades
// i torna per referencia el lloc i la longitud
- (BOOL)skipToCString:(const char *)cStr len:(size_t)cLen outStr:(const unsigned char**)cstr length:(size_t*)len ;


/////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Parse Functions
/////////////////////////////////////////////////////////////////////////////////////////////

//-------------------------------------------------------------------------------------------
// Les funcions parse determinen l'existència d'un element en el lloc actual
// Només modifiquen el punter si el seu resultat es afirmatiu

//-------------------------------------------------------------------------------------------
// parseja una CString especificada
#define _parseCString(cStr,len) ( c+(len) <= end && strncasecmp((char*)c,(cStr),(len)) == 0 && (c+=(len)) )
#define _parseNCString(cStr,len) ( c+(len) <= end && strncmp((char*)c,(cStr),(len)) == 0 && (c+=(len)) )

//-------------------------------------------------------------------------------------------
// parseja un char especificat
#define _parseChar(ch) ( c < end && *c == (ch) && c++ )
//#define _parseExclusiveChar(ch) ( (c+1) < end && *c == (ch) && *(c+1) != (ch) && c++ )

#define _parseExclusiveChar(ch) ( c < end && *c == (ch) && !(c+1 < end && *(c+1) == (ch)) && c++ )

//-------------------------------------------------------------------------------------------
// Parseja un Token. Torna per referencia el lloc i la longitud
// Permet passar NULL si no es vol aquesta informacio al tornar
- (BOOL)parseToken:(const unsigned char**)pcstr length:(size_t*)plen ;

//-------------------------------------------------------------------------------------------
// igual que l'anterior pero s'admet que el token contingui a mes el caracter que se li passa
- (BOOL)parseToken:(const unsigned char**)pcstr length:(size_t*)plen withOptionalChar:(const unsigned char)optch;

//-------------------------------------------------------------------------------------------
// igual que l'anterior pero s'admet que el token contingui un colon ':'
- (BOOL)parseTokenWColon:(const unsigned char**)pcstr length:(size_t*)plen ;

//-------------------------------------------------------------------------------------------
// Parseja un Token concret. Torna YES si ha identificat el token de manera unica
- (BOOL)parseConcreteToken:(const char *)cStr length:(size_t)len ;

//-------------------------------------------------------------------------------------------
// parseja un token amb possibles elements de EIP/Native com index constant d'array
// i notacions amb punt sense espais. Torna la longitud parsejada encara que falli
- (BOOL)parseTokenEx:(const unsigned char**)pcstr length:(size_t*)plen ;

//-------------------------------------------------------------------------------------------
// Parseja un numero. Torna per referencia un double.
// Permet passar NULL si no es vol aquesta informacio
// Si falla no canvia el valor de number
- (BOOL)parseNumber:(double *)number isTime:(BOOL*)isTime;

//-------------------------------------------------------------------------------------------
// Parseja un sencer. Torna per referencia un int.
// Permet passar NULL si no es vol aquesta informacio
// Si falla no canvia el valor de number
- (BOOL)parseUInt:(unsigned int *)number ;

////-------------------------------------------------------------------------------------------
//// Parseja alguna cosa, passada en el parseBlock que es troba opcionalment 
//// entre cometes tenint en compte si esperem cometes dobles.
//- (BOOL)parseQuotedSomethingWithBlock:(BOOL (^)())parseBlock 
//        doubleQuote:(BOOL)quotedComm 
//        dollarCom:(BOOL)dollarComm 
//        optionalQuotes:(BOOL)optional ;

//-------------------------------------------------------------------------------------------
- (BOOL)parseConstantString:(const unsigned char**)pcstr length:(size_t*)plen 
        doubleQuote:(BOOL)quotedComm dollarCom:(BOOL)dollarComm ;


//-------------------------------------------------------------------------------------------
- (CFStringRef)parseEscapedCreateStringWithEncoding:(CFStringEncoding)encoding;

//-------------------------------------------------------------------------------------------
- (int)line;

@end


