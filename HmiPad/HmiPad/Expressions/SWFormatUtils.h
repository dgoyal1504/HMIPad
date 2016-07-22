//
//  SWFormatUtils.h
//  HmiPad
//
//  Created by Joan on 19/05/11.
//  Copyright 2011 SweetWilliam, S.L. All rights reserved.
//


//----------------------------------------------------------------------------------
// torna 0 si es double, 1 si es int, 2 si es string, -1 si hi ha error

//----------------------------------------------------------------------------------
#ifdef __cplusplus
extern "C" {
#endif

//----------------------------------------------------------------------------------

enum
{
    kSpfNone = 0,
    kSpfDouble,
    kSpfLazyDouble, // sense especifier (nomes quan lazySpec es YES)
    kSpfInt,
    kSpfUInt,
    kSpfChar,
    kSpfString,
};

typedef struct
{
    UInt8 type ;
    UInt8 base ;
    char flags ;
    char specifier ;
    UInt16 width ;
    UInt16 precision ;
} FormatFields ;

//----------------------------------------------------------------------------------

extern double SWGetDoubleValueFromCString( const UInt8 *bytes, UInt8** outEndPtr, BOOL *isTime ) ;  // suporta 0b, 0x, 0t
extern double SWCFStringGetDoubleValue( CFStringRef str ) ;  // suporta 0b, 0x
extern unsigned long SWCFStringGetLongValueWithBase( CFStringRef str, const int base ) ;  

extern CFIndex SWGetDataTypeFromInlineBuf_indx_outFields_lazySpec( CFStringInlineBuffer *inlineBuffer, const CFIndex indx, FormatFields *outFields, BOOL lazySpec ) ;
extern CFIndex SWGetDataTypeFromSimpleFormat_outFields( CFStringRef simpleFormat, FormatFields *outFields ) ;
extern CFStringRef SWCFStringCreateWithFormat( const char *cfrmt, ... ) ;  // es un simple wrap de sprintf
//extern CFStringRef SWCFStringCreateWithCFStringFormat( CFStringRef frmt, ... ) ;  // es un simple wrap de CFStringCreateWithFormat


//----------------------------------------------------------------------------------
static inline int toInt( double d )
{
    if ( d >= (double)INT_MAX ) return INT_MAX ;
    if ( d <= (double)INT_MIN ) return INT_MIN ;
    return (int)d ;
}

//static inline unsigned int toUIntVV( double d )
//{
//    if ( d >= (double)UINT_MAX ) return UINT_MAX ;
//    if ( d <= -(double)UINT_MAX ) return -UINT_MAX ;
//    return (unsigned int)d ;
//}

static inline unsigned int toUInt( double d )
{
    if ( d >= (double)UINT_MAX ) return UINT_MAX ;
    if ( d <= -(double)UINT_MAX ) return -UINT_MAX ;
    if ( d < 0.0 ) return  -(unsigned int)(-d);
    return (unsigned int)d ;
}

#ifdef __cplusplus
}
#endif


