//
//  PrimitiveParser.m
//  HmiPad_101116
//
//  Created by Joan on 16/11/10.
//  Copyright 2010 SweetWilliam, S.L. All rights reserved.
//

#import "PrimitiveParser.h"
#import "SWFormatUtils.h"
#import <xlocale.h>


@implementation PrimitiveParser


/////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Skip Functions
/////////////////////////////////////////////////////////////////////////////////////////////

//-------------------------------------------------------------------------------------------
// Les funcions skip causen salts del punter en busqueda de condicions
// Potencialment modifiquen el punter independentment del seu resultat

//-------------------------------------------------------------------------------------------
// salta fins a trobar algun dels caracters especificats en ccstr
- (void)skipToAnyCharIn:(const char*)ccstr
{ 
    const unsigned char *cc = (const unsigned char*)ccstr ;
    if ( c < end ) while ( *c != *cc )
    { 
        if ( *++cc != '\0' ) continue ; 
        cc = (const unsigned char*)ccstr ; 
        if ( ++c == end ) break ;
    } 
}

//-------------------------------------------------------------------------------------------
// salta fins a trobar el caracter especificat o el final de dades
// i torna per referencia el lloc i la longitud
- (BOOL)skipToChar:(unsigned char)ch outStr:(const unsigned char**)cstr length:(size_t*)len 
{
    *cstr = c ;
    _skipToChar( ch ) ;
    *len = c - *cstr ;
//    return ( *c == ch ) ;
    return ( c < end ) ;
}

//-------------------------------------------------------------------------------------------
// salta fins a trobar algun dels caracters especificats en ccstr o el final de dades tornant per
// referencia el lloc i la longitud
- (BOOL)skipToAnyCharIn:(const char*)ccstr outStr:(const unsigned char**)cstr length:(size_t*)len 
{ 
    *cstr = c ;
    [self skipToAnyCharIn:ccstr] ;
    *len = c - *cstr ;
    return ( c < end ) ;
}

//-------------------------------------------------------------------------------------------
// salta fins a trobar el caracter especificat i torna si ha trobat el caracter
- (BOOL)skipPastChar:(unsigned char)ch
{
    _skipPastChar(ch) ;
    return ( c <= end ) ;
}

//-------------------------------------------------------------------------------------------
// salta fins a trobar el començament de la C string especificada o el final de dades
// i torna per referencia el lloc i la longitud
- (BOOL)skipToCString:(const char *)cStr len:(size_t)cLen outStr:(const unsigned char**)cstr length:(size_t*)len 
{
    *cstr = c ;
    _skipToCString( cStr, cLen ) ;
    *len = c - *cstr ;
    return ( c < end ) ;
}

#pragma mark properties

- (int)line
{
    return _line;
};


/////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Parse Functions
/////////////////////////////////////////////////////////////////////////////////////////////

//-------------------------------------------------------------------------------------------
// Les funcions parse determinen l'existència d'un element en el lloc actual
// Només modifiquen el punter si el seu resultat es afirmatiu

//-------------------------------------------------------------------------------------------
// Parseja un Token. Torna per referencia el lloc i la longitud
// Permet passar NULL si no es vol aquesta informacio al tornar
- (BOOL)parseToken:(const unsigned char**)pcstr length:(size_t*)plen
{
    const unsigned char *cbeg = c ;
    if ( c < end && ( (*c >= 'a' && *c <= 'z' ) || (*c >= 'A' && *c <='Z') || ( *c == '_' ) || ( *c == '$' ) /*|| ( *c >=192 ) */) )  // abans 224 en lloc de 192
    {
        c++ ;
        while ( c < end && ( (*c >= 'a' && *c <= 'z' ) || (*c >= 'A' && *c <='Z') || (*c >= '0' && *c <= '9' ) || ( *c == '_' ) /*|| ( *c >=192 )*/ ) ) c++ ;
        if ( pcstr ) *pcstr = cbeg ;
        if ( plen ) *plen = c - cbeg ;
        return YES ;
    }
    if ( plen ) *plen = 0 ;
    return NO ;
}


//-------------------------------------------------------------------------------------------
// Parseja un Token concret. Torna YES si ha identificat el token de manera unica.
// S'admet qualsevol caracter fins a len pero el seguent ha de ser no alphanumeric per donar per bo 
- (BOOL)parseConcreteToken:(const char *)cStr length:(size_t)len
{
    if ( c+len <= end && strncmp( (char*)c, cStr, len ) == 0 )
    {
        const unsigned char *ce = c+len ;
        if ( ce < end && ( (*ce >= 'a' && *ce <= 'z' ) || (*ce >= 'A' && *ce <='Z') || (*ce >= '0' && *ce <= '9' ) || ( *ce == '_' ) ) )
            return NO ;
        c = ce ;
        return YES ;
    }
    return NO ;
}


//-------------------------------------------------------------------------------------------
// Parseja un Token. Torna per referencia el lloc i la longitud
// Permet passar NULL si no es vol aquesta informacio al tornar
//- (BOOL)parseTokenWColon:(const unsigned char**)pcstr length:(size_t*)plen
//{
//    const unsigned char *cbeg = c ;
//    if ( c < end && ( (*c >= 'a' && *c <= 'z' ) || (*c >= 'A' && *c <='Z') || ( *c == '_' ) || ( *c == '$' ) /*|| ( *c >=192 ) */) )  // abans 224 en lloc de 192
//    {
//        c++ ;
//        while ( c < end && ( (*c >= 'a' && *c <= 'z' ) || (*c >= 'A' && *c <='Z') || (*c >= '0' && *c <= '9' ) || ( *c == '_' ) /*|| ( *c >=192 ) */ || ( *c == ':' ) ) ) c++ ;
//        if ( pcstr ) *pcstr = cbeg ;
//        if ( plen ) *plen = c - cbeg ;
//        return YES ;
//    }
//    if ( plen ) *plen = 0 ;
//    return NO ;
//}



- (BOOL)parseToken:(const unsigned char**)pcstr length:(size_t*)plen withOptionalChar:(const unsigned char)optch
{
    const unsigned char *cbeg = c ;
    if ( c < end && ( (*c >= 'a' && *c <= 'z' ) || (*c >= 'A' && *c <='Z') || ( *c == '_' ) || ( *c == '$' ) /*|| ( *c >=192 ) */) )  // abans 224 en lloc de 192
    {
        c++ ;
        while ( c < end && ( (*c >= 'a' && *c <= 'z' ) || (*c >= 'A' && *c <='Z') || (*c >= '0' && *c <= '9' ) || ( *c == '_' ) /*|| ( *c >=192 ) */ || ( *c == optch ) ) ) c++ ;
        if ( pcstr ) *pcstr = cbeg ;
        if ( plen ) *plen = c - cbeg ;
        return YES ;
    }
    if ( plen ) *plen = 0 ;
    return NO ;
}

- (BOOL)parseTokenWColon:(const unsigned char**)pcstr length:(size_t*)plen
{
    return [self parseToken:pcstr length:plen withOptionalChar:':'];
}

//-------------------------------------------------------------------------------------------
// auxiliar per parsejar un token amb possibles elements de EIP/Native com index d'array
- (BOOL)parseTokenExInternal
{
    if ( [self parseTokenWColon:NULL length:NULL] )
    { 
        if ( _parseChar( '[' ) )
        {
            if ( [self parseUInt:NULL] )
            {
                while ( 1 )
                {
                    if ( _parseChar( ',' ) )
                    {
                        if ( [self parseUInt:NULL] ) continue ;
                        else return NO ;
                    }
                    break ;
                }
                if ( _parseChar( ']' ) ) ;
                else return NO ;
            }
            else return NO ;
        }
        
        if ( _parseChar( '.' ) )
        {
            if ( [self parseUInt:NULL] ) ;
            else return [self parseTokenExInternal] ;
        }
        return YES ;
    }
    return NO ;
}

//-------------------------------------------------------------------------------------------
// parseja un token amb possibles elements de EIP/Native com index d'array
// i notacions amb punt. Torna la longitud parsejada encara que falli
- (BOOL)parseTokenEx:(const unsigned char**)pcstr length:(size_t*)plen
{
    const unsigned char *cbeg = c ;
    BOOL result = [self parseTokenExInternal] ;
    
    if ( pcstr ) *pcstr = cbeg ;
    if ( plen ) *plen = c - cbeg ;
    return result ;
}



//-------------------------------------------------------------------------------------------
// Parseja un numero. Torna per referencia un double.
// Permet passar NULL si no es vol aquesta informacio
// Si falla no canvia el valor de number
- (BOOL)parseNumber:(double *)number isTime:(BOOL*)isTime
{
    UInt8 *endptr ;
    double result = SWGetDoubleValueFromCString( c, &endptr, isTime) ;
    if ( endptr > c && endptr <= end ) // ok
    {
        if ( *(endptr-1) == '.' ) endptr-- ;  // si acava en '.' el descartem
        c = endptr ; // actualitzem el punter
        if ( number ) *number = result ; // tornem el resultat per referencia
        return YES ;
    }
    return NO ;
}

/*
//-------------------------------------------------------------------------------------------
// Parseja un numero. Torna per referencia un double.
// Permet passar NULL si no es vol aquesta informacio
// Si falla no canvia el valor de number
- (BOOL)parseNumberV:(double *)number
{
    char *nptr = (char*)c ;
    char *endptr ;
    double result ;
    
    result = strtod_l( nptr, &endptr, NULL ) ;
    if ( nptr == endptr ) // ha fallat
    {
        if ( _parseCString( "true", 4 ) ) result = 1.0 ;
        else if ( _parseCString( "false", 5 ) ) result = 0.0 ;
        else return NO ; // ha fallat del tot
    }
    else
    {
        // si acava en '.' el descartem
        if ( *(endptr-1) == '.' ) endptr-- ;
        c = (unsigned char*)endptr ; // actualitzem el punter
    }
    if ( number ) *number = result ; // tornem el resultat per referencia
    return YES ;
}
*/


//-------------------------------------------------------------------------------------------
// Parseja un sencer. Torna per referencia un int.
// Permet passar NULL si no es vol aquesta informacio
// Si falla no canvia el valor de number
- (BOOL)parseUInt:(unsigned int *)number
{
    //char *nptr = (char*)c ;
    UInt8 *endptr ;
    unsigned long result = strtoul_l( (char*)c, (char**)&endptr, 10, NULL ) ;
    if ( endptr > c && endptr <= end ) // ok
    {
        c = endptr ; // actualitzem el punter
        if ( number ) *number = result ; // tornem el resultat per referencia
        return YES ;
    }
    return NO ;
}



//-------------------------------------------------------------------------------------------
// Parseja un sencer. Torna per referencia un int.
// Permet passar NULL si no es vol aquesta informacio
// Si falla no canvia el valor de number
- (BOOL)parseUIntV:(unsigned int *)number
{
    char *nptr = (char*)c ;
    char *endptr ;
    long unsigned int result ;
    
    result = strtoul_l( nptr, &endptr, 10, NULL ) ;
    if ( nptr == endptr ) // ha fallat
    {
         return NO ; // ha fallat del tot
    }
    else
    {
        if ( (unsigned char*)endptr > end ) return NO ;  // ha llegit mes enlla del buffer
        c = (unsigned char*)endptr ; // actualitzem el punter
    }
    if ( number ) *number = result ; // tornem el resultat per referencia
    return YES ;
}




//-------------------------------------------------------------------------------------------
// Parseja alguna cosa, passada en el parseBlock que es troba entre cometes tenint en compte
// si esperem cometes dobles.
- (BOOL)parseQuotedSomethingWithBlock:(BOOL (^)())parseBlock doubleQuote:(BOOL)quotedComm dollarCom:(BOOL)dollarComm optionalQuotes:(BOOL)optional
{
    // aqui tenim en compte que si estava embolicat hem de trobar parelles de cometes
    if ( quotedComm )
    {
        if ( dollarComm )
        {
            if ( _parseCString( "$Q", 2 ) )
            {
                if ( parseBlock() )
                {
                    _skipSp ;
                    if ( _parseCString( "$Q", 2 ) )   // bug si hi ha $$
                    {
                        return YES ;
                    }
                }
            }
            else if ( optional )
            {
                if ( parseBlock() )
                {
                    return YES ;
                }
            }
        }
        else
        {
            if ( _parseChar( '\"' ) )  // no podem utilitzar  _parseCString( "\"\"", 2 ) per evitar que "2.0" es tracti com opcional sense cometes
            {
                if ( _parseChar( '\"' ) )
                {
                    if ( parseBlock() )
                    {
                        _skipSp ;
                        if ( _parseCString( "\"\"", 2 ) )    // bug si hi ha quotes
                        {
                            return YES ;
                        }
                    }
                }
            }
            else if ( optional )
            {
                if ( parseBlock() )
                {
                    return YES ;
                }
            }
        }
    }
    else
    {
        if ( _parseChar( '\"' ) )
        {
            if ( parseBlock() )
            {
                _skipSp ;
                if ( _parseChar( '\"' ) )
                {
                    return YES ;
                }
            }
        }
        else if ( optional )
        {
            if ( parseBlock() )
            {
                return YES ;
            }
        }
    }
    return NO ;
}


//-------------------------------------------------------------------------------------------
// parseja una string constant, que ha d'estar entre cometes
- (BOOL)parseConstantString:(const unsigned char**)pcstr length:(size_t*)plen doubleQuote:(BOOL)quotedComm dollarCom:(BOOL)dollarComm
{
    BOOL (^parseBlock)() = ^()
    {
        const unsigned char *cstr ;
        size_t len ;
        BOOL result ;

        if ( dollarComm )
            result = [self skipToCString:"$Q" len:2 outStr:&cstr length:&len] ;
        else
            result = [self skipToChar:'\"' outStr:&cstr length:&len] ;

        if ( pcstr ) *pcstr = cstr;
        if ( plen ) *plen = len;
        return result;
    } ;
    
    const unsigned char *svc = c ;
    if ( [self parseQuotedSomethingWithBlock:parseBlock doubleQuote:quotedComm dollarCom:dollarComm optionalQuotes:NO] )
    {
        return YES ;
    }
    c = svc ;
    return NO ;
}



- (CFStringRef)parseEscapedCreateStringWithEncoding:(CFStringEncoding)encoding
{
    if ( _parseChar( '\"' ) )
    {
        CFMutableStringRef string = CFStringCreateMutable(nil, 0);
        const unsigned char *svc = c;

        while (1)
        {
            const unsigned char *cstr ;
            size_t len ;
            BOOL result = [self skipToAnyCharIn:"\"\\" outStr:&cstr length:&len];
        
            CFStringRef partString = NULL;
            if ( result )
            {
                partString = CFStringCreateWithBytes(nil, cstr, len, encoding, NO);
                if ( partString )
                {
                    CFStringAppend(string, partString);
                    CFRelease( partString );
                }
            
                if ( _parseChar( '\"' ) )
                {
                    return string;
                }
                
                if ( _parseChar( '\\') )
                {
                    UniChar chars = '\0';
                    if ( _parseChar( '\"' ) ) chars = '\"';
                    else if ( _parseChar( '\\' ) ) chars = '\\';
                    else if ( _parseChar( 'n' ) ) chars = '\n';
            
                    if ( chars != '\0' )
                    {
                        CFStringAppendCharacters(string, &chars, 1);
                    }
                    
                    continue;
                }
            }
            c = svc;
            break;
        }
    }
    return NULL;
}

@end
