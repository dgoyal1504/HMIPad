//
//  SWFormatUtils.m
//  HmiPad
//
//  Created by Joan on 19/05/11.
//  Copyright 2011 SweetWilliam, S.L. All rights reserved.
//

#import "SWFormatUtils.h"
#import <xlocale.h>



//------------------------------------------------------------------------------------------
// parseja bytes fins que troba null o un resultat valid. Torna en outEndPtr el final del resultat valid
double SWGetDoubleValueFromCString( const UInt8 *bytes, UInt8** outEndPtr, BOOL *isTime )
{
    char *nptr = (char*)bytes ;
    char *endptr = nptr ;
    double result = 0 ;
    BOOL isT = NO;
    
    while ( isspace(*nptr) && *nptr != '\0' ) ++nptr ;
    
    if ( !strncasecmp( nptr, "true", 4 ) )
    {
        result = 1.0 ;
        endptr = nptr+4 ;
    }
    else if ( !strncasecmp( nptr, "false", 5 ) )
    {
        result = 0.0 ;
        endptr = nptr+5 ;
    }
    else if ( !strncasecmp( nptr, "0b", 2 ) )
    {
        result = (double)strtoul_l( nptr+2, &endptr, 2, NULL ) ;
        if ( nptr+2 == endptr ) endptr = (char*)bytes ; // si ha fallat apuntem al principi
    }
    else if ( !strncasecmp( nptr, "0t", 2 ) )
    {
        isT = YES;
        result = strtod_l( nptr+2, &endptr, NULL ) ;
        if ( nptr+2 == endptr ) endptr = (char*)bytes ; // si ha fallat apuntem al principi
    }
    else
    {
        result = strtod_l( nptr, &endptr, NULL ) ;   // suporta 0x a mes de doubles
        if ( nptr == endptr ) endptr = (char*)bytes ; // si ha fallat apuntem al principi
    }

    if ( outEndPtr ) *outEndPtr = (UInt8*)endptr ;
    if ( isTime ) *isTime = isT;
    return result ;
}


//------------------------------------------------------------------------------------------
double SWCFStringGetDoubleValue( CFStringRef string )
{
    CFIndex stringLength = CFStringGetLength( string ) ;
    UInt8 bytes[stringLength+1] ;

    CFStringGetBytes(
        (CFStringRef)string,      // the string
        CFRangeMake(0, stringLength),   // range 
        kCFStringEncodingASCII,   // encoding
        '?',         // loss Byte
        false,     // is external representation
        bytes,          // buffer
        stringLength,  // max buff length
        NULL       // out used buff length
    ) ;

    bytes[stringLength] = '\0' ;
    
    return SWGetDoubleValueFromCString( bytes, NULL, NULL ) ;
}



//------------------------------------------------------------------------------------------
unsigned long SWCFStringGetLongValueWithBase( CFStringRef string, const int base )
{
    CFIndex stringLength = CFStringGetLength( string ) ;
    UInt8 bytes[stringLength+1] ;

    CFStringGetBytes(
        (CFStringRef)string,      // the string
        CFRangeMake(0, stringLength),   // range 
        kCFStringEncodingASCII,   // encoding
        '?',         // loss Byte
        false,     // is external representation
        bytes,          // buffer
        stringLength,  // max buff length
        NULL       // out used buff length
    ) ;

    bytes[stringLength] = '\0' ;
    return strtoul_l( (char*)bytes, NULL, base, NULL ) ;
}





//------------------------------------------------------------------------------------------
// Torna informacio per referencia sobre una especificacio de format a inlineBuffer+indx. 
// Retorna la nova posicio de l'index despres d'haver parsejat el format. Si hi ha error torna fins la posicio escanejada i *outType es zero
// admet strings que contenen formats en la forma [flags][width][.precision]specifier el '%' inicial es opcional
//static CFIndex getDataTypeFromInlineBuf_indx_outType_outBase_outFields_lazySpec( CFStringInlineBuffer *inlineBuffer, 
//                    const CFIndex indx, UInt8 *outType, UInt8 *outBase, FormatFields *outFields, BOOL lazySpec )
                    

CFIndex SWGetDataTypeFromInlineBuf_indx_outFields_lazySpec( CFStringInlineBuffer *inlineBuffer, 
                    const CFIndex indx, FormatFields *outFields, BOOL lazySpec )
                    
{
    CFIndex idx = indx ;
    //const UInt8 *formatEnd = format+len ;
    
    // all fields
    
    //UInt8 type = kSpfNone ;  // de moment error
    //UInt8 base = 10 ;  // de moment base 10
    FormatFields fields = { kSpfNone, 10, '\0', 0, 0, '\0' } ;
    
    
    // % es opcional
    UniChar ch = CFStringGetCharacterFromInlineBuffer( inlineBuffer, idx ) ;  // torna 0 si indx esta fora de rang
    if ( ch == '%' ) 
    {
        ch = CFStringGetCharacterFromInlineBuffer( inlineBuffer, ++idx ) ;
    }
    
    // flags
    if ( ch == '-' || ch == '+' || ch == ' ' || ch == '#' || ch == '0' ) 
    {
        fields.flags = ch ;
        ch = CFStringGetCharacterFromInlineBuffer( inlineBuffer, ++idx ) ;
    }
    
    // width
    CFIndex beg = idx ;
    while ( ch >= '0' && ch <= '9' ) 
    {
        fields.width = fields.width*10 + (ch - '0') ;
        if ( idx-beg >= 2) goto done ; 
        ch = CFStringGetCharacterFromInlineBuffer( inlineBuffer, ++idx ) ;
    }
    
    // precision
    if ( ch == '.' )
    {
        ch = CFStringGetCharacterFromInlineBuffer( inlineBuffer, ++idx ) ;
        beg = idx ;
        while ( ch >= '0' && ch <= '9' ) 
        {
            fields.precision = fields.precision*10 + (ch - '0') ; 
            if ( idx-beg >= 2) goto done ; 
            ch = CFStringGetCharacterFromInlineBuffer( inlineBuffer, ++idx ) ;
        }
    }

    
    // specifier
    if ( ch )
    {
        fields.specifier = ch ;
        if ( ch == 'f' || ch == 'g' || ch == 'G' || ch == 'e' || ch == 'E' )
        {
            ++idx ;
            fields.type = kSpfDouble ;
        }
        else if ( ch == 'd' || ch == 'i' )
        {
            ++idx ;
            fields.type = kSpfInt ;   // tipus int
        }
        else if ( ch == 'u' )
        {
            ++idx ;
            fields.type = kSpfUInt ;   // tipus uint
        }
        else if ( ch == 'x' || ch == 'X' )
        {
            ++idx ;
            fields.type = kSpfUInt ;   // tipus uint
            fields.base = 16 ;  // base 16
        }       
        else if ( ch == 'o' )
        {
            ++idx ;
            fields.type = kSpfInt ;   // tipus int (signed octal)
            fields.base = 8 ;   // base 1
        }
        else if ( ch == 'b' )
        {
            ++idx ;
            fields.type = kSpfUInt ;   // tipus uint
            fields.base = 2 ;   // base 1
        }
        else if ( ch == 'c' )
        {
            ++idx ;
            fields.type = kSpfChar ;   // tipus caracter
        }
        else if ( ch == 's' )
        {
            ++idx ;
            fields.type = kSpfString ;   // tipus string
        }
    }
    else
    {
        if ( lazySpec )
        {
            fields.specifier = 'f' ;
            fields.type = kSpfLazyDouble ;
        }
    }

done:
    //if ( outType ) *outType = type ;
    //if ( outBase ) *outBase = base ;
    if ( outFields ) *outFields = fields ;
    return idx ;
}


//------------------------------------------------------------------------------------------
CFIndex SWGetDataTypeFromSimpleFormat_outFields( CFStringRef simpleFormat, FormatFields *outFields )
{
    CFIndex length = CFStringGetLength(simpleFormat) ;
    CFStringInlineBuffer inlineBuffer ;
    CFStringInitInlineBuffer( simpleFormat, &inlineBuffer, CFRangeMake(0, length) ) ;  // funciona per qualsevol encoding
    return SWGetDataTypeFromInlineBuf_indx_outFields_lazySpec( &inlineBuffer, 0, outFields, YES ) ;
}


//------------------------------------------------------------------------------------------
// crea una CFString a partir de "c" format i arguments, atencio que format ha de ser ASCII
CFStringRef SWCFStringCreateWithFormat( const char *cfrmt, ... )
{
    va_list ap ;
    char sValue[256] ;
    va_start(ap, cfrmt) ;
    int len = vsnprintf_l( sValue, 256, NULL, cfrmt, ap ) ;
    va_end(ap) ;
    if ( len < 0 ) return CFRetain(CFSTR("")) ;
    if ( len > 255 ) len = 255 ;
    CFStringRef strResult = CFStringCreateWithBytes(NULL, (UInt8*)sValue, len, kCFStringEncodingASCII, NO) ;
    return strResult ;
}

/*
//------------------------------------------------------------------------------------------
// crea una CFString a partir de CFString format i arguments, atencio que format ha de ser
CFStringRef SWCFStringCreateWithCFFormat( CFStringRef frmt, ... )
{
    CFStringRef strResult ;
    va_list ap ;
    va_start(ap, frmt) ;
    strResult = CFStringCreateWithFormatAndArguments( NULL, NULL, frmt, ap ) ;
    va_end(ap) ;
    return strResult ;
}
*/





