//
//  RpnValue.cpp
//  HmiPad_110323
//
//  Created by Joan on 24/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RPNValue.h"
extern "C" {
//#import "IDomusModel.h"
}

#import "SWValue.h"
#import "SWColor.h"
#import "UIFont+AllFonts.h"
#import "NSData+CommonCrypto.h"





////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark RPNValue objectes auxiliars
////////////////////////////////////////////////////////////////////////////////////////////


// array de metodes primitius "+"

const RPNMethodsStruct RPNMethods[] = 
{ 
    {CFSTR("to_s"), &RPNValue::to_s, NULL },
    {CFSTR("to_f"), &RPNValue::to_f, NULL },
    {CFSTR("to_i"), &RPNValue::to_i, NULL },
    {CFSTR("abs"), &RPNValue::rabs, NULL },
    {CFSTR("round"), &RPNValue::rround, NULL },
    {CFSTR("floor"), &RPNValue::rfloor, NULL },
    {CFSTR("ceil"), &RPNValue::rceil, NULL },
    //{CFSTR("to_a"), &RPNValue::to_a, NULL },   // no es operativa
    {CFSTR("chr"), &RPNValue::chr, NULL },
    {CFSTR("fetch"), &RPNValue::fetch, NULL },
    {CFSTR("length"), &RPNValue::length, NULL },
    {CFSTR("split"), &RPNValue::split, NULL },
    {CFSTR("join"), &RPNValue::join, NULL },
    {CFSTR("keys"), &RPNValue::keys, NULL },
    {CFSTR("values"), &RPNValue::values, NULL },
    
    {CFSTR("origin"), &RPNValue::rect_origin, NULL },
    {CFSTR("size"), &RPNValue::rect_size, NULL },
    {CFSTR("x"), &RPNValue::point_x, NULL },
    {CFSTR("y"), &RPNValue::point_y, NULL },
    {CFSTR("width"), &RPNValue::size_width, NULL },
    {CFSTR("height"), &RPNValue::size_height, NULL },
    
    {CFSTR("timeformatter"), &RPNValue::timeFormatter, NULL },
    {CFSTR("year"), &RPNValue::year, NULL },
    {CFSTR("month"), &RPNValue::month, NULL },
    {CFSTR("day"), &RPNValue::day, NULL },
    {CFSTR("wday"), &RPNValue::wday, NULL },
    {CFSTR("yday"), &RPNValue::yday, NULL },
    {CFSTR("week"), &RPNValue::week, NULL },
    {CFSTR("hour"), &RPNValue::hour, NULL },
    {CFSTR("min"), &RPNValue::min, NULL },   // en cas d'array cridara array_min
    {CFSTR("sec"), &RPNValue::sec, NULL },
    
    {CFSTR("max"), &RPNValue::array_max, NULL },
} ;
const int RPNMethodsCount = sizeof(RPNMethods)/sizeof(RPNMethods[0]) ;


// array de metodes base "+Root" (funcions)

const RPNMethodsStruct RPNRootFunctions[] = 
{ 
    {CFSTR("format"), &RPNValue::format, NULL },
    {CFSTR("rand"), &RPNValue::rand, NULL },
} ;
const int RPNRootFunctionsCount = sizeof(RPNRootFunctions)/sizeof(RPNRootFunctions[0]) ;


// array de metodes Matematics "Math"

typedef double (*CMathFunc1)(double value) ;
typedef double (*CMathFunc2)(double value0, double value1) ;

const RPNMethodsStruct RPNMathMethods[] = 
{ 
    {CFSTR("PI"), &RPNValue::mathPi, NULL },
    {CFSTR("atan2"), &RPNValue::math2, (void*)atan2 },
    {CFSTR("cos"), &RPNValue::math1, (void*)cos },
    {CFSTR("exp"), &RPNValue::math1, (void*)exp },
    {CFSTR("log"), &RPNValue::math1, (void*)log },
    {CFSTR("log10"), &RPNValue::math1, (void*)log10 },
    {CFSTR("sin"), &RPNValue::math1, (void*)sin },
    {CFSTR("sqrt"), &RPNValue::math1, (void*)sqrt },
    {CFSTR("tan"), &RPNValue::math1, (void*)tan },
    {CFSTR("floor"), &RPNValue::math1, (void*)floor },  // eliminar
    {CFSTR("ceil"), &RPNValue::math1, (void*)ceil },    // eliminar
} ;
const int RPNMathMethodsCount = sizeof(RPNMathMethods)/sizeof(RPNMathMethods[0]) ;

// array de metodes "SM"

const RPNMethodsStruct RPNSMMethods[] = 
{ 
    {CFSTR("lookup"), &RPNValue::smLookup, NULL },
    {CFSTR("error"), &RPNValue::smError, NULL },
    {CFSTR("color"), &RPNValue::smColor, NULL },
    {CFSTR("deviceID"), &RPNValue::smDeviceId, NULL },
    {CFSTR("point"), &RPNValue::smPoint, NULL },
    {CFSTR("size"), &RPNValue::smSize, NULL },
    {CFSTR("rect"), &RPNValue::smRect, NULL },
    {CFSTR("allFonts"), &RPNValue::smAllFonts, NULL },
    {CFSTR("allColors"), &RPNValue::smAllColors, NULL },
    {CFSTR("encrypt"), &RPNValue::smEncrypt, NULL },
    {CFSTR("decrypt"), &RPNValue::smDecrypt, NULL },
    {CFSTR("mktime"), &RPNValue::smMkTime, NULL },
} ;
const int RPNSMMethodsCount = sizeof(RPNSMMethods)/sizeof(RPNSMMethods[0]) ;


// array de classes

const RPNClassesStruct RPNClasses[] = 
{ 
    {CFSTR("+"), RPNMethods, RPNMethodsCount },                    // selector especial RPNClSelGenericFunction (0)
    {CFSTR("+Root"), RPNRootFunctions, RPNRootFunctionsCount },    // selector especial RPNClSelRootClass (1)
    {CFSTR("Math"), RPNMathMethods, RPNMathMethodsCount },
    {CFSTR("SM"), RPNSMMethods, RPNSMMethodsCount },
} ;

const int RPNClassesCount = sizeof(RPNClasses)/sizeof(RPNClasses[0]) ;


//typedef void (^EnumerationBlock)(NSString*);



int RPNValue::selectorForClass(NSString *className)
{
    int clsSel = 0;
    for ( ; clsSel<RPNClassesCount; clsSel++ )
    {
        if ( NSOrderedSame == [className caseInsensitiveCompare:(__bridge NSString*)RPNClasses[clsSel].name] )
            break;
    }
    
    if ( clsSel == RPNClassesCount ) clsSel = -1;
    return clsSel;
}


int RPNValue::selectorForMethod_inClassWithSelector(NSString *methodName, int clsSel)
{
    if ( clsSel < 0 ) return -1;

    const RPNClassesStruct *pClassStruct = &RPNClasses[clsSel];
    const int methodCount = pClassStruct->methodCount;
    
    int mtdSel = 0;
    for ( ; mtdSel<methodCount ; mtdSel++)
    {
        if ( NSOrderedSame == [methodName caseInsensitiveCompare:(__bridge NSString*)pClassStruct->methods[mtdSel].name] )
        break;
    }
    
    if ( mtdSel == methodCount ) mtdSel = -1;
    return mtdSel;
}


void RPNValue::enumerateClassesUsingBlock( void (^block)(NSString *name) )
{
    if ( block == nil ) return;
    for ( int i=2 ; i<RPNClassesCount ; i++ )
    {
        NSString *name = (__bridge NSString*)RPNClasses[i].name;
        block( name );
    }
}


void RPNValue::enumerateRootMethodsUsingBlock( void (^block)(NSString *name) )
{
    if ( block == nil ) return;
    for ( int i=0 ; i<RPNRootFunctionsCount ; i++ )
    {
        NSString *name = (__bridge NSString*)RPNRootFunctions[i].name;
        block( name );
    }
}


void RPNValue::enumerateMethodsForClassSelector_usingBlock( int clsSel, void (^block)(NSString *name) )
{
    if ( clsSel < 0 ) return;
    if ( block == nil ) return;
    
    const RPNClassesStruct *pClassStruct = &RPNClasses[clsSel];
    const int methodCount = pClassStruct->methodCount;
    
    for ( int mtdSel=0 ; mtdSel<methodCount ; mtdSel++ )
    {
        NSString *name = (__bridge NSString*)pClassStruct->methods[mtdSel].name;
        block( name );
    }
}


//void RPNValue::enumerateMethodsForClassName_usingBlock( NSString *className, void (^block)(NSString *name) )
//{
//    if ( block == nil ) return;
//    
//    // determine class
//    const RPNClassesStruct *pClassStruct = NULL;
//    for ( int i=0; i<RPNClassesCount; i++ )
//    {
//        pClassStruct = &RPNClasses[i] ;
//        if ( NSOrderedSame == [className caseInsensitiveCompare:(__bridge NSString*)pClassStruct->name] )
//            break;
//    }
//    
//    if ( pClassStruct == NULL ) return;
//    
//    const RPNMethodsStruct *pMethodsStruct = pClassStruct->methods;
//    int methodCount = pClassStruct->methodCount;
//    
//    for ( int i=0 ; i<methodCount ; i++ )
//    {
//        NSString *name = (__bridge NSString*)pMethodsStruct[i].name;
//        block( name );
//    }
//}



////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark RPNArray
////////////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------------------
// tipus per amagatzemar arrays, en realitat es un CFMutableData de longitud count*sizeof(RPNValue)
typedef CFMutableDataRef RPNArrayRef ;

// crea un RPNArray a partir dels RPNValues que se li pasen
// si values es NULL no inicialitza, si count es 0 fa un array buit
static RPNArrayRef RPNArrayCreate( const RPNValue *values, const CFIndex count )
{
    CFMutableDataRef array = CFDataCreateMutable(NULL, count*sizeof(RPNValue)) ;
    CFDataSetLength( array, count*sizeof(RPNValue) ) ;
    if ( values != NULL )
    {
        RPNValue *all = (RPNValue *)CFDataGetMutableBytePtr(array) ;
        for ( CFIndex i=0 ; i<count ; ++i ) all[i] = values[i] ;
    }
    return array ;
}


static RPNArrayRef RPNArrayCreateWithNumbers( const double *numbers, const int count )
{
    CFMutableDataRef array = CFDataCreateMutable(NULL, count*sizeof(RPNValue)) ;
    CFDataSetLength( array, count*sizeof(RPNValue) ) ;
    if ( numbers != NULL )
    {
        RPNValue *all = (RPNValue *)CFDataGetMutableBytePtr(array) ;
        for ( int i=0 ; i<count ; i++ )
        {
            all[i].typ = SWValueTypeNumber ;
            all[i].d = numbers[i] ;
        }
    }
    return array ;
}


static RPNArrayRef RPNArrayCreateWithStrings( CFStringRef *cStrs, const int count )
{
    CFMutableDataRef array = CFDataCreateMutable(NULL, count*sizeof(RPNValue)) ;
    CFDataSetLength( array, count*sizeof(RPNValue) ) ;
    if ( cStrs != NULL )
    {
        RPNValue *all = (RPNValue *)CFDataGetMutableBytePtr(array) ;
        for ( int i=0 ; i<count ; i++ )
        {
            CFStringRef str = cStrs[i] ;
            if ( str )
            {
                all[i].typ = SWValueTypeString ;
                all[i].obj = CFRetain(str) ;
            }
        }
    }
    return array ;
}


static inline CFIndex RPNArrayGetCount( RPNArrayRef array )
{
    return CFDataGetLength( array ) / sizeof(RPNValue);
}

static inline RPNValue *RPNArrayGetValuesPtr( RPNArrayRef array )
{
    return (RPNValue *)CFDataGetMutableBytePtr(array) ;
}

static void RPNArrayRelease( RPNArrayRef array )  
{
    CFIndex retainCount = CFGetRetainCount( array ) ;
    if ( retainCount == 1 )
    {
        CFIndex count = RPNArrayGetCount( array ) ;
        RPNValue *values = RPNArrayGetValuesPtr( array ) ;
        for ( CFIndex i=0 ; i<count ; ++i ) values[i].clear() ;
    }
    
    //NSLog( @"RPNArray retainCount %ld", CFGetRetainCount( array ) ) ;
    CFRelease( array ) ;
}



////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark RPNHash
////////////////////////////////////////////////////////////////////////////////////////////


//------------------------------------------------------------------------------------------
// tipus per amagatzemar arrays, en realitat es un CFMutableData de longitud count*sizeof(RPNValue)
typedef CFMutableDictionaryRef RPNHashRef;


static const void *hashRetainCallback( CFAllocatorRef allocator, const void *value )
{    
    // en realitat no fa res, la idea es que el diccionari guarda RPNValue* unics creats amb 'new'
    return value;
}


static void hashReleaseCallback( CFAllocatorRef allocator, const void *value )
{
    // simplement crida el 'delete'
    RPNValue *rpnValue = (RPNValue*)value;
    delete rpnValue;
}


static Boolean hashEqualCallback( const void *value1, const void *value2 )
{
    RPNValue *rpnValue1 = (RPNValue*)value1;
    RPNValue *rpnValue2 = (RPNValue*)value2;
    
    Boolean isEqual = (*rpnValue1 == *rpnValue2);
    return isEqual;
}


static CFHashCode hashHashCallback( const void *value )
{
    RPNValue *rpnValue = (RPNValue*)value;

    CFHashCode hashCode = rpnValue->hashCode();
    return hashCode;
}


// crea un RPNHash a partir dels parells de RPNValues que se li pasen
// si values es NULL no inicialitza, si count es 0 fa un hash buit, count es el numero de parelles
//static RPNHashRef RPNHashCreateV( const RPNValue *values, const CFIndex count )
//{
//    static const CFDictionaryKeyCallBacks keyCallBacks =
//    {
//        0, // version
//        hashRetainCallback,
//        hashReleaseCallback,
//        NULL,               // copy description callback
//        hashEqualCallback,
//        hashHashCallback,   // hash callback
//    };
//    
//    static const CFDictionaryValueCallBacks valueCallBacks =
//    {
//        0, // version
//        hashRetainCallback,
//        hashReleaseCallback,
//        NULL,   // copy description callback
//        NULL,   // equal callback
//    };   
//    
//    CFMutableDictionaryRef dict = CFDictionaryCreateMutable(NULL, count/2,  &kCFTypeDictionaryKeyCallBacks,  &valueCallBacks);
//    
//    if ( values != NULL )
//    {
//        int i=0;
//        for ( ; i<count*2 ; i+=2 )
//        {
//            const RPNValue &key = values[i];
//            const RPNValue &value = values[i+1];
//        
//            if ( key.typ != SWValueTypeString ) break;
//        
//            RPNValue *dValue = new RPNValue(value);
//            CFDictionarySetValue(dict, key.obj, dValue);
//        }
//    
//        if ( i != count*2 )
//        {
//            if ( dict ) CFRelease( dict );
//            dict = NULL;
//        }
//    }
//    
//    return dict;
//}


// crea un RPNHash a partir dels parells de RPNValues que se li pasen
// si values es NULL no inicialitza, si count es 0 fa un hash buit, count es el numero de parelles
static RPNHashRef RPNHashCreate( const RPNValue *values, const CFIndex count )
{
    static const CFDictionaryKeyCallBacks keyCallBacks =
    {
        0, // version
        hashRetainCallback,
        hashReleaseCallback,
        NULL,               // copy description callback
        hashEqualCallback,
        hashHashCallback,   // hash callback
    };
    
    static const CFDictionaryValueCallBacks valueCallBacks =
    {
        0, // version
        hashRetainCallback,
        hashReleaseCallback,
        NULL,   // copy description callback
        NULL,   // equal callback
    };   
    
    CFMutableDictionaryRef dict = CFDictionaryCreateMutable(NULL, count,  &keyCallBacks,  &valueCallBacks);
    
    if ( values != NULL )
    {
        int i=0;
        for ( ; i<count*2 ; i+=2 )
        {
            const RPNValue &key = values[i];
            const RPNValue &value = values[i+1];
        
            RPNValue *dKey = new RPNValue(key);
            RPNValue *dValue = new RPNValue(value);
            CFDictionarySetValue(dict, dKey, dValue);
        }
    
        if ( i != count*2 )
        {
            if ( dict ) CFRelease( dict );
            dict = NULL;
        }
    }
    
    return dict;
}



static inline CFIndex RPNHashGetCount( RPNHashRef hash )
{
    return CFDictionaryGetCount(hash);
}

//static inline void RPNHashGetKeysAndValues( RPNHashRef hash,  CFTypeRef *keys, const RPNValue **values )
//{
//    CFDictionaryGetKeysAndValues(hash, keys, (const void**)values );
//}

static inline void RPNHashGetKeysAndValues( RPNHashRef hash,  const RPNValue **keys, const RPNValue **values )
{
    CFDictionaryGetKeysAndValues(hash, (const void**)keys, (const void**)values );
}

typedef void (*RPNHashApplierFunction) (const RPNValue *key, const RPNValue *value, void *context);

static inline void RPNHashApplyFunction( RPNHashRef hash, RPNHashApplierFunction applier, void *context)
{
    CFDictionaryApplyFunction(hash, (CFDictionaryApplierFunction)applier, context);
}

//static inline void RPNHashSetNewValueForKey( RPNHashRef hash, RPNValue *dValue, CFTypeRef keyObj )
//{
//    CFDictionarySetValue(hash, keyObj, dValue);
//}

static inline void RPNHashSetNewValueForNewKey( RPNHashRef hash, const RPNValue *dValue, const RPNValue *dKey )
{
    CFDictionarySetValue(hash, dKey, dValue);
}

//static inline RPNValue *RPNHashGetValueForKey( RPNHashRef hash, CFTypeRef keyObj )
//{
//    return (RPNValue*)CFDictionaryGetValue(hash, keyObj);
//}

static inline RPNValue *RPNHashGetValueForKey( RPNHashRef hash, const RPNValue &dKey )
{
    return (RPNValue*)CFDictionaryGetValue(hash, &dKey);
}

static inline void RPNHashRelease( RPNHashRef hash )
{
    CFRelease( hash );
}

////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark RPNStruct
////////////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------------------
// tipus per amagatzemar estructures, en realitat es un CFData de longitud sizeof(struct)
typedef CFDataRef RPNStructRef ;

// crea un RPNArray a partir dels RPNValues que se li pasen
// si values es NULL no inicialitza, si count es 0 fa un array buit
static inline RPNStructRef RPNStructCreate( const void *bytes, const CFIndex length )
{

    CFDataRef structv = CFDataCreate(NULL, (const UInt8*)bytes, length);
    return structv ;
}

static inline size_t RPNStructGetLength( RPNStructRef structv )
{
    return CFDataGetLength( structv ) ;
}

static inline const void *RPNStructGetPtr( RPNStructRef structv )
{
    return CFDataGetBytePtr(structv) ;
}

////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Format
////////////////////////////////////////////////////////////////////////////////////////////




static CFStringRef createDateStringWithDateFormat_absoluteTime( CFStringRef dateFormat, CFAbsoluteTime absoluteTime)
{
    static CFDateFormatterRef staticDateFormatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
            staticDateFormatter = CFDateFormatterCreate( NULL, NULL, kCFDateFormatterNoStyle, kCFDateFormatterNoStyle );
        });
    
    CFDateFormatterSetFormat( staticDateFormatter, dateFormat ) ;
    return CFDateFormatterCreateStringWithAbsoluteTime(NULL, staticDateFormatter, absoluteTime);
}



static CFStringRef createLazyStringForRPNValue_shortVersion_stringQuotes(const RPNValue &rpn, BOOL shortVersion, BOOL printable)
{
    CFStringRef strResult = NULL ;
    if ( rpn.typ == SWValueTypeNumber /*|| rpn.typ == SWValueTypeAbsoluteTime*/ )
    {
        const char *format = shortVersion?"%1.5g":"%1.15g";
        strResult = SWCFStringCreateWithFormat( format, rpn.d ) ;
    }
    else if (rpn.typ == SWValueTypeAbsoluteTime)
    {
        const char *format = "%1.1f";
        CFStringRef absoluteStr = SWCFStringCreateWithFormat( format, rpn.d ) ;
        if ( printable )
        {
            CFMutableStringRef mutableString = CFStringCreateMutable(nil, 0);
            CFStringAppend( mutableString, absoluteStr);
            CFRelease(absoluteStr);
            CFStringAppend( mutableString, CFSTR("\n(\""));
            CFStringRef dateStr = createDateStringWithDateFormat_absoluteTime(CFSTR("yyyy-MM-dd HH:mm:ss.S"), rpn.d-NSTimeIntervalSince1970);
            CFStringAppend( mutableString, dateStr );
            CFRelease( dateStr );
            CFStringAppend( mutableString, CFSTR("\")"));
            strResult = mutableString;
        }
        else
        {
            strResult = absoluteStr;
        }
    }
    else if ( rpn.typ == SWValueTypeString ) 
    {
        if ( printable )
        {
            CFMutableStringRef mutableString = CFStringCreateMutable(nil, 0);
            CFStringAppend( mutableString, CFSTR("\""));
            if ( rpn.obj ) CFStringAppend( mutableString, (CFStringRef)rpn.obj );
            CFStringAppend( mutableString, CFSTR("\""));
            strResult = mutableString;
        }
        else
        {
            if ( rpn.obj ) strResult = (CFStringRef)CFRetain(rpn.obj) ; // atencio pot ser nil
            else strResult = (CFStringRef)CFRetain(CFSTR("") ) ;
        }
    }
    else if ( rpn.typ == SWValueTypeObject ) 
    {
        id object = (__bridge id)rpn.obj;
        if ([object isKindOfClass:[SWValue class]])
        {
            SWValue *value = object;
            const RPNValue &rpnValue = [value rpnValue];
            strResult = createLazyStringForRPNValue_shortVersion_stringQuotes(rpnValue, YES, YES);
        }
        else
        {
            strResult = (CFStringRef)CFRetain(CFSTR("<object>") ) ;
        }
    }
    else if ( rpn.typ == SWValueTypeArray ) 
    {
        CFMutableStringRef mutableString = CFStringCreateMutable(nil, 0);        
        CFStringAppend(mutableString, CFSTR("["));
        
        //int arrayCount = rpn.arrayCount();
        int arrayCount = RPNArrayGetCount((RPNArrayRef)rpn.obj);
        const RPNValue *values = RPNArrayGetValuesPtr((RPNArrayRef)rpn.obj);
        
        for (int i=0; i<arrayCount; ++i)
        {
            const RPNValue &value = values[i];
            CFStringRef itemStr = createLazyStringForRPNValue_shortVersion_stringQuotes(value,YES,YES);
            
            if (i > 0) CFStringAppend(mutableString, CFSTR(", "));
            CFStringAppend(mutableString, itemStr);
            CFRelease( itemStr ) ;
        }
        
        CFStringAppend(mutableString, CFSTR("]"));
        
        strResult = mutableString;
    }
    
    else if ( rpn.typ == SWValueTypeHash )
    {
        CFMutableStringRef mutableString = CFStringCreateMutable(nil, 0);        
        CFStringAppend(mutableString, CFSTR("{"));
        
        int hashCount = RPNHashGetCount((RPNHashRef)rpn.obj);
        
        const RPNValue *keys[hashCount];
        const RPNValue *values[hashCount];
        RPNHashGetKeysAndValues((RPNHashRef)rpn.obj, keys, values);
        
        for (int i=0; i<hashCount; ++i)
        {
            const RPNValue *key = keys[i];
            const RPNValue *value = values[i];
            CFStringRef keyStr = createLazyStringForRPNValue_shortVersion_stringQuotes(*key,YES,YES);
            CFStringRef valueStr = createLazyStringForRPNValue_shortVersion_stringQuotes(*value,YES,YES);
            
            if (i > 0) CFStringAppend(mutableString, CFSTR(", "));
            CFStringAppend(mutableString, keyStr);
            CFStringAppend(mutableString, CFSTR(": "));
            CFStringAppend(mutableString, valueStr);
            
            CFRelease( keyStr );
            CFRelease( valueStr );
        }
        CFStringAppend(mutableString, CFSTR("}"));
        
        strResult = mutableString;
    }
    
    else if ( rpn.typ == SWValueTypePoint )
    {
        //const void *ptr = RPNStructGetPtr((RPNStructRef)rpn.obj);
        const CGPoint *point = (CGPoint*)RPNStructGetPtr((RPNStructRef)rpn.obj);
        strResult = SWCFStringCreateWithFormat("{%1.3g, %1.3g}",point->x, point->y);
    }
    else if ( rpn.typ == SWValueTypeSize )
    {
        //const void *ptr = RPNStructGetPtr((RPNStructRef)rpn.obj);
        const CGSize *size = (CGSize*)RPNStructGetPtr((RPNStructRef)rpn.obj);
        strResult = SWCFStringCreateWithFormat("{%1.3g, %1.3g}",size->width,size->height);
    }
    else if ( rpn.typ == SWValueTypeRect )
    {
        //const void *ptr = RPNStructGetPtr((RPNStructRef)rpn.obj);
        const CGRect *rect = (CGRect*)RPNStructGetPtr((RPNStructRef)rpn.obj);
        strResult = SWCFStringCreateWithFormat("{{%1.3g, %1.3g}, {%1.3g, %1.3g}}",rect->origin.x, rect->origin.y, rect->size.width, rect->size.height);
    }
    else if ( rpn.typ == SWValueTypeRange )
    {
        //const void *ptr = RPNStructGetPtr((RPNStructRef)rpn.obj);
        const SWValueRange *range = (SWValueRange*)RPNStructGetPtr((RPNStructRef)rpn.obj);
        strResult = SWCFStringCreateWithFormat("(%1.3g..%1.3g)", range->min, range->max);
    }
    
    else strResult = (CFStringRef)CFRetain(CFSTR("<error>")) ;

    return strResult;
}


//------------------------------------------------------------------------------------------
// Crea una CFString a partir del format (sense el % inicial) que comenca a inlineBuffer+index
// torna per referencia el index al seguent caracter
static CFStringRef createStringWithFormatFromInlineBuffer( CFStringInlineBuffer *inlineBuffer, const CFIndex indx, 
                CFIndex *outIndx, const RPNValue &rpn, const BOOL lazySpec ) 
{
    CFStringRef strResult = NULL ;
    //UInt8 type = 0 ;
    //UInt8 base ;
    FormatFields fields ;
    CFIndex iEnd = SWGetDataTypeFromInlineBuf_indx_outFields_lazySpec( inlineBuffer, indx, &fields, lazySpec ) ;
    if ( outIndx ) *outIndx = iEnd ;
    
    //char sValue[200] ;
    if ( fields.type != kSpfNone && iEnd > indx )
    { 
        if ( fields.specifier == 'c' )
        {
            if ( rpn.typ == SWValueTypeNumber )
            {
                UniChar chars[fields.width+1] ;
                for ( int i=0; i<fields.width ; i++ ) chars[i] = ' ' ;
                chars[fields.width] = toInt(rpn.d) ;
                strResult = CFStringCreateWithCharacters(NULL, chars, fields.width+1) ;   // pot ser peta si rpn.d no conté un caracter unicode?
                return strResult ;
            }
        }
        
        else if ( fields.specifier == 'b' )
        {
            if ( rpn.typ == SWValueTypeNumber )
            {
                UInt8 chars[256] ;
                unsigned int value = toUInt(rpn.d) ;
                int count = 1 ;  // al menys imprimim un caracter
                if ( value > 0 ) count = 1 + toUInt( log2(value) ) ;
                UInt8 *ebuff = chars+256-1 ;
                int cnt = 0 ;
                for ( ; cnt<count ; cnt++ )
                {
                    *ebuff-- = (value&1) + '0' ;
                    value = value >> 1 ;
                }
                for ( ; cnt<fields.width ; cnt++ )
                {
                    *ebuff-- = ( fields.flags=='0' ? '0' : ' ' ) ;
                }
                strResult = CFStringCreateWithBytes(NULL, chars+256-cnt, cnt, kCFStringEncodingASCII, NO) ;
                return strResult ;
            }
        }
        
        else if ( fields.specifier == 's' )
        {
            if ( rpn.typ == SWValueTypeString )
            {
                CFStringRef str = (CFStringRef)(rpn.obj) ;
                if ( str != NULL )
                {
                    int strLen = CFStringGetLength( str ) ;
                    int trimLen = fields.precision > 0 && fields.precision < strLen ? fields.precision : strLen ;
                    int totalLen = trimLen > fields.width ? trimLen : fields.width ;
                    
                    if ( totalLen == strLen )
                    {
                        strResult = (CFStringRef)CFRetain(str) ;
                        return strResult ;
                    }
                    
                    UniChar chars[totalLen] ;
                    for ( int i=0 ; i<totalLen-trimLen ; i++ ) chars[i] = ' ' ;
                    CFStringGetCharacters( str, CFRangeMake(0, trimLen), chars+totalLen-trimLen ) ;
                    strResult = CFStringCreateWithCharacters( NULL, chars, totalLen ) ;
                    return strResult ;
                }
            }
        }
        
        // tipus suportats per snprintf els gestionem directament
        else
        {
            if ( rpn.typ == SWValueTypeNumber || rpn.typ == SWValueTypeAbsoluteTime )
            {
                char cfmt[iEnd+3-indx] ;  
                cfmt[0] = '%' ; // per el sprintf
                CFIndex i = indx ;
                for ( ; i<iEnd ; i++ )
                {
                    UniChar ch = CFStringGetCharacterFromInlineBuffer( inlineBuffer, i ) ;
                    cfmt[i+1-indx] = ch & 0xff ;
                }
                if ( fields.type == kSpfLazyDouble ) cfmt[i+1-indx] = fields.specifier, i++ ;
                cfmt[i+1-indx] = '\0' ;  // per el sprintf
                
                if ( fields.type == kSpfDouble || fields.type == kSpfLazyDouble ) strResult = SWCFStringCreateWithFormat( cfmt, rpn.d ) ;
                else if ( fields.type == kSpfInt ) strResult = SWCFStringCreateWithFormat( cfmt, toInt(rpn.d) ) ;
                else if ( fields.type == kSpfUInt ) strResult = SWCFStringCreateWithFormat( cfmt, toUInt(rpn.d) ) ;
                return strResult ;
            }
        }
    }
    
    // els que no s'han pogut processar arriben aqui
    if ( lazySpec )
    {
        strResult = createLazyStringForRPNValue_shortVersion_stringQuotes(rpn,NO,NO);
    }
    
    return strResult ;
}


//----------------------------------------------------------------------------------
static CFStringRef createStringWithSimpleFormat( CFStringRef simpleFormat, const RPNValue &rpn )
{
    CFIndex length = CFStringGetLength(simpleFormat) ;
    CFStringInlineBuffer inlineBuffer ;
    CFStringInitInlineBuffer( simpleFormat, &inlineBuffer, CFRangeMake(0, length) ) ;  // funciona per qualsevol encoding
    CFStringRef str = createStringWithFormatFromInlineBuffer( &inlineBuffer, 0, NULL, rpn, YES ) ;
    return str ;
}


//----------------------------------------------------------------------------------
#define MAYBESTORESTRINARRAYANDRELEASE   \
{                                   \
    if ( str )                      \
    {                               \
        if ( strArray == NULL ) strArray = CFArrayCreateMutable( NULL, 0, &kCFTypeArrayCallBacks ) ;    \
        CFArrayAppendValue( strArray, str ) ;   \
        CFRelease( str ) ;          \
        str = NULL ;                \
    }                               \
}


//----------------------------------------------------------------------------------
// admet formatStr que contenen formats en la forma %[flags][width][.precision]specifier 
// veure http://www.cplusplus.com/reference/clibrary/cstdio/sprintf/
// aquesta es la utilitzada per 'to_s' i 'format'
//
static CFStringRef sprintfStringCreate( CFStringRef formatStr, const unsigned int count, const RPNValue *args, const BOOL lazySpec )
{
    CFStringRef strResult = NULL ;
    CFIndex length ;
    if ( formatStr != NULL && (length=CFStringGetLength(formatStr)) > 0 )
    {
        if ( count == 0 )
        {
            strResult = (CFStringRef)CFRetain(formatStr) ;
            return strResult ;
        }
        
        int argsIndex = 0 ;
        CFMutableArrayRef strArray = NULL ; // CFArrayCreateMutable( NULL, 0, &kCFTypeArrayCallBacks ) ;
        CFStringRef str = NULL ;
        CFStringInlineBuffer inlineBuffer ;
        CFStringInitInlineBuffer( formatStr, &inlineBuffer, CFRangeMake(0, length) ) ;  // funciona per qualsevol encoding

        CFIndex iBeg = 0 ;
        CFIndex iEnd = 0 ;
        for ( CFIndex i=0 ; i<length /*&& argsIndex < count*/ ;  ) 
        {
            UniChar ch = CFStringGetCharacterFromInlineBuffer( &inlineBuffer, i ) ;
            
            // saltem fins trobar un %
            if ( ch != '%' )
            {
                i++ ;
                continue ;
            }
            
            // marquem el final i busquem el seguent caracter
            iEnd = i++ ;
            ch = CFStringGetCharacterFromInlineBuffer( &inlineBuffer, i ) ;
            
            // si hi ha part pendent de anotar ho fem ara
            if ( iEnd-iBeg > 0 )
            {
                MAYBESTORESTRINARRAYANDRELEASE ;
                str = CFStringCreateWithSubstring( NULL, formatStr, CFRangeMake(iBeg,iEnd-iBeg) ) ;
            }
            
            // si el caracter actual es un % el saltem i anem per el seguent
            if ( ch == '%' )
            {
                //iEnd = i-1 ;  // apunta al primer %
                iBeg = i++ ;  // despres del segon %
                continue ;
            }
            
            if ( argsIndex < count )
            {
    
                // tenim un format, creem la string amb el format actual
                CFIndex end ;
                MAYBESTORESTRINARRAYANDRELEASE ;
                str = createStringWithFormatFromInlineBuffer( &inlineBuffer, i, &end, args[argsIndex++], lazySpec ) ;
                if ( str ) iBeg = end ;  // apunta al seguent despres del format
                else iBeg = i-1 ;  // apuntem just al comencament del format '%'
                i = end ; // avancem el index al seguent despres del format
            }
        }

        iEnd = length ;
        
        // anotem la part final si n'hi ha una
        if ( iEnd-iBeg > 0 )
        {
            MAYBESTORESTRINARRAYANDRELEASE ;            
            str = CFStringCreateWithSubstring( NULL, formatStr, CFRangeMake(iBeg, iEnd-iBeg) ) ;
            
            /*if ( strArray )
            {
                CFArrayAppendValue( strArray, str ) ;
                CFRelease( str ) ;
                str = NULL ;
            } */
        }
        
        if ( strArray )
        {
            MAYBESTORESTRINARRAYANDRELEASE ; 
            strResult = CFStringCreateByCombiningStrings(NULL, strArray, CFSTR("")) ;
            CFRelease( strArray ) ;
        }
        else
        {
            strResult = str ;
        }
    }
    
    else
    {
        strResult = (CFStringRef)CFRetain(CFSTR("")) ;
    }
    
    return strResult ;
}



void _scapedStringAppend(CFMutableStringRef theString, CFStringRef str)
{
    // codifiquem la string per troços
    //CFIndex stringLength = CFStringGetLength((CFStringRef)str);
    CFIndex stringLength = CFStringGetLength( str );
    
    UniChar characters[stringLength];
    CFStringGetCharacters( str, CFRangeMake(0, stringLength), characters);
    
    CFIndex i = 0;
    CFIndex lastI = i;
    for ( ; i < stringLength ; i++ )
    {
        UniChar ch = characters[i];
        
        if ( ch == '\"' )
        {
            if ( i > lastI )
            {
                CFStringRef substr = CFStringCreateWithCharactersNoCopy(nil, characters+lastI, i-lastI, kCFAllocatorNull);
                CFStringAppend( theString, substr );
                CFRelease( substr );
            }
         
            UniChar appendCh[2] = { '\\', '\"' } ;
            CFStringAppendCharacters( theString, appendCh, 2 );
            
            lastI = i+1;
        }
    }
    
    if ( i > lastI )
    {
        CFStringRef substr = CFStringCreateWithCharactersNoCopy(nil, characters+lastI, i-lastI, kCFAllocatorNull);
        CFStringAppend( theString, substr );
        CFRelease( substr );
    }
}


#pragma mark - Public Functions
//------------------------------------------------------------------------------------
// Crea una CFString en principi utilitzable com a source de una expressio aplicant el format especificat
// d'acord amb la especificacio de sprintfStringCreate per els tipus compatibles.
// Si format es nil crea una representacio adequada del valor, en principi utilitzable com a source de una expressio
// per a tots els tipus
// Si el rpnVal es un array crea una representacio (recursiva) de un array en la que a cada element se li aplica format
//
CFStringRef createSourceStringForRpnValue_withFormat( const RPNValue &rpnVal, CFStringRef format)
{
    CFStringRef str = nil ;
    
    if ( rpnVal.typ == SWValueTypeArray )
    {
        int count = rpnVal.arrayCount() ;
        CFMutableStringRef str0 = CFStringCreateMutable( NULL, 0 ) ;
        CFStringAppend( str0, CFSTR("[") ) ;
        for ( int i=0 ; i<count ; i++ )
        {
            CFStringRef string ;
            const RPNValue &rpnVa = rpnVal.valueAtIndex(i) ;
            string = createSourceStringForRpnValue_withFormat(rpnVa, format) ;
            if ( i > 0 ) CFStringAppend( str0, CFSTR(", ") ) ;
            CFStringAppend( str0, string ) ;
            CFRelease( string ) ;
        }
        CFStringAppend( str0, CFSTR("]") ) ;
        str = str0 ;
        return str ;
    }
    
    if ( rpnVal.typ == SWValueTypeHash )
    {
        int hashCount = RPNHashGetCount((RPNHashRef)rpnVal.obj);

        CFMutableStringRef str0 = CFStringCreateMutable(nil, 0);
        CFStringAppend(str0, CFSTR("{"));
        
        const RPNValue *keys[hashCount];
        const RPNValue *values[hashCount];
        RPNHashGetKeysAndValues((RPNHashRef)rpnVal.obj, keys, values);
        
        for (int i=0; i<hashCount; ++i)
        {
            const RPNValue *key = keys[i];
            const RPNValue *value = values[i];
            CFStringRef keyStr = createSourceStringForRpnValue_withFormat(*key, format);
            CFStringRef valueStr = createSourceStringForRpnValue_withFormat(*value, format);
            
            if (i > 0) CFStringAppend(str0, CFSTR(", "));
            CFStringAppend(str0, keyStr);
            CFStringAppend(str0, CFSTR(": "));
            CFStringAppend(str0, valueStr);
            CFRelease( keyStr );
            CFRelease( valueStr );
        }
        
        CFStringAppend(str0, CFSTR("}"));
        str = str0;
        return str;
    }
    
    // a partir d'aqui no es array ni hash
    if ( format )
    {
        return sprintfStringCreate( format, 1, &rpnVal, YES ) ;
    }

    // a partir d'aqui format es NULL

    if ( rpnVal.typ == SWValueTypeNumber )
    {
        str = SWCFStringCreateWithFormat("%1.15g", rpnVal.d);
    }
    
    else if ( rpnVal.typ == SWValueTypeAbsoluteTime )
    {
        str = SWCFStringCreateWithFormat("0t%1.15g", rpnVal.d);
    }

    else if ( rpnVal.typ == SWValueTypeString ) 
    { 
        CFMutableStringRef str0 = CFStringCreateMutable( NULL, 0 ) ;
        CFStringAppend( str0, CFSTR("\"") );
        //if ( rpnVal.obj ) CFStringAppend( str0, (CFStringRef)rpnVal.obj );   // TO DO: atencio falla si conte cometes
        if ( rpnVal.obj ) _scapedStringAppend( str0, (CFStringRef)rpnVal.obj );   // TO DO: atencio falla si conte cometes
        CFStringAppend( str0, CFSTR("\"") );
        str = str0;
    }
    
    else if ( rpnVal.typ == SWValueTypeObject ) 
    { 
        str = (CFStringRef)CFRetain(CFSTR("(object)")) ;
    }
    
    else if ( rpnVal.typ == SWValueTypePoint ) 
    {
//       CGPoint point = valueAsCGPointForRpnValue( rpnVal ) ;
//       str = SWCFStringCreateWithFormat( "SM.point(%1.6g, %1.6g)", point.x, point.y );
        const CGPoint *point = (CGPoint*)RPNStructGetPtr((RPNStructRef)rpnVal.obj);
        str = SWCFStringCreateWithFormat( "SM.point(%1.6g, %1.6g)", point->x, point->y );
    }
    
    else if ( rpnVal.typ == SWValueTypeSize ) 
    {
//        CGSize size = valueAsCGSizeForRpnValue( rpnVal ) ;
//        str = SWCFStringCreateWithFormat( "SM.size(%1.6g, %1.6g)", size.width, size.height );
        const CGSize *size = (CGSize*)RPNStructGetPtr((RPNStructRef)rpnVal.obj);
        str = SWCFStringCreateWithFormat( "SM.size(%1.6g, %1.6g)", size->width, size->height );
    }
    
    else if ( rpnVal.typ == SWValueTypeRect ) 
    {
//        CGRect rect = valueAsCGRectForRpnValue( rpnVal ) ;
//        str = SWCFStringCreateWithFormat( "SM.rect(%1.6g, %1.6g, %1.6g, %1.6g)", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height );
        const CGRect *rect = (CGRect*)RPNStructGetPtr((RPNStructRef)rpnVal.obj);
        str = SWCFStringCreateWithFormat( "SM.rect(%1.6g, %1.6g, %1.6g, %1.6g)", rect->origin.x, rect->origin.y, rect->size.width, rect->size.height );
    }
    
    else if ( rpnVal.typ == SWValueTypeRange )
    {
//        SWValueRange range = valueAsSWValueRangeForRpnValue( rpnVal );
//        str = SWCFStringCreateWithFormat( "%1.6g..%1.6g", range.min, range.max );
        const SWValueRange *range = (SWValueRange*)RPNStructGetPtr((RPNStructRef)rpnVal.obj);
        str = SWCFStringCreateWithFormat( "%1.6g..%1.6g", range->min, range->max );
    }
    
    else if ( rpnVal.typ == SWValueTypeObject )
    {
        str = (CFStringRef)CFRetain(CFSTR("(object)")); // No suportat !!
    }
    
    else if ( rpnVal.typ == SWValueTypeError ) 
    {
        //RPNValueErrCode err = rpnVal.err;
        str = SWCFStringCreateWithFormat( "SM.error" );
    }
    
    else
    {
        str = (CFStringRef)CFRetain(CFSTR("")) ;
    }
        
    return str ;
}


CFStringRef createPrintableStringForRpnValue( const RPNValue &rpnVal )
{
    return createLazyStringForRPNValue_shortVersion_stringQuotes(rpnVal,NO,YES);
}



CFStringRef createStringForRpnValue_withFormat( const RPNValue &rpnVal, CFStringRef format )
{
    // optimitzacio del format NULL per alguns casos
    if ( format == NULL )
    {        
        return createLazyStringForRPNValue_shortVersion_stringQuotes(rpnVal,NO,NO);
    }

    // cas general
    return sprintfStringCreate( format, 1, &rpnVal, YES ) ;
}


CFArrayRef createStringsArrayForRpnValue_withFormat( const RPNValue &rpnValue, CFStringRef format )
{
    CFMutableArrayRef strings;
    if ( rpnValue.typ == SWValueTypeArray )
    {
        const int count = RPNArrayGetCount( (RPNArrayRef)rpnValue.obj ) ;
        const RPNValue *values = RPNArrayGetValuesPtr( (RPNArrayRef)rpnValue.obj ) ;
        strings = CFArrayCreateMutable(NULL, count, &kCFTypeArrayCallBacks);
        for ( int i=0; i<count; i++ )
        {
            const RPNValue &rpnVal = values[i];
            CFStringRef string = createStringForRpnValue_withFormat(rpnVal, format);
            CFArrayAppendValue( strings, string );
            CFRelease( string );
        }
    }
    else 
    {
        strings = CFArrayCreateMutable(NULL, 1, &kCFTypeArrayCallBacks);
        CFStringRef string = createStringForRpnValue_withFormat(rpnValue, format);
        CFArrayAppendValue( strings, string );
        CFRelease( string );
    }
    return strings;
}


CFDataRef createDataWithDoublesForRpnValue( const RPNValue &rpnValue )
{
    CFDataRef data;
    if ( rpnValue.typ == SWValueTypeArray )
    {
        const int count = RPNArrayGetCount( (RPNArrayRef)rpnValue.obj ) ;
        const RPNValue *values = RPNArrayGetValuesPtr( (RPNArrayRef)rpnValue.obj ) ;
        
        CFMutableDataRef mData = CFDataCreateMutable( NULL, count*sizeof(double) );
        CFDataSetLength( mData, count*sizeof(double) );
        double *pData = (double*)CFDataGetMutableBytePtr( mData );
        
        for ( int i=0; i<count; i++ )
        {
            const RPNValue &rpnVal = values[i];
            double dValue = valueAsDoubleForRpnValue( rpnVal );
            pData[i] = dValue;
        }
        data = mData;
    }
    
    else 
    {
        double dValue = valueAsDoubleForRpnValue( rpnValue );
        data = CFDataCreate( NULL, (UInt8*)&dValue, sizeof(double) );
    }
    
    return data;
}


////------------------------------------------------------------------------------------
//// Crea una CFString amb el format especificat d'acord amb la especificacio de sprintfStringCreate.
//// Si format es nil crea una representacio adequada del valor, en principi utilitzable com a source de una expressio
//// Si el rpnVal es un array crea una representacio (recursiva) de un array en la que a cada element se li aplica format
////
//CFStringRef createStringForRpnValue_withFormat( const RPNValue &rpnVal, CFStringRef format )
//{
//    CFStringRef str = nil ;
//    if ( rpnVal.typ == SWValueTypeArray )
//    {
//        int count = rpnVal.arrayCount() ;
//        CFMutableStringRef str0 = CFStringCreateMutable( NULL, 0 ) ;
//        CFStringAppend( str0, CFSTR("[") ) ;
//        for ( int i=0 ; i<count ; i++ )
//        {
//            CFStringRef string ;
//            const RPNValue &rpnVa = rpnVal.valueAtIndex(i) ;
//            BOOL isString = rpnVa.typ == SWValueTypeString ;
//            string = createStringForRpnValue_withFormat(rpnVa, (CFStringRef)format) ;
//            if ( i > 0 ) CFStringAppend( str0, CFSTR(", ") ) ;
//            if ( isString ) CFStringAppend( str0, CFSTR("\"") ) ;
//            CFStringAppend( str0, string ) ;
//            if ( isString ) CFStringAppend( str0, CFSTR("\"") ) ;
//            CFRelease( string ) ;
//        }
//        CFStringAppend( str0, CFSTR("]") ) ;
//        str = str0 ;
//        return str ;
//    }
//
//    // a partir d'aqui no es array
//    if ( format )
//    {
//        return sprintfStringCreate( format, 1, &rpnVal, YES ) ;
//    }
//    
//    // a partir d'aqui format es NULL
//    if ( rpnVal.typ == SWValueTypeNumber )
//    {
//        //str = CFStringCreateWithFormat(NULL, NULL, CFSTR("%1.15g"), rpnVal.d ) ;
//        str = SWCFStringCreateWithFormat("%1.15g", rpnVal.d);
//    }
//    
//    else if ( rpnVal.typ == SWValueTypeString ) 
//    { 
//        if ( rpnVal.obj ) str = (CFStringRef)CFRetain(rpnVal.obj) ; // atencio pot ser nil
//    }
//    
//    else if ( rpnVal.typ == SWValueTypeObject ) 
//    { 
//        str = (CFStringRef)CFRetain(CFSTR("(object)")) ;
//    }
//    
//    else if ( rpnVal.typ == SWValueTypePoint ) 
//    {
//        CGPoint point = valueAsCGPointForRpnValue( rpnVal ) ;
//        str = SWCFStringCreateWithFormat( "SM.point(%1.6g, %1.6g)", point.x, point.y );
//    }
//    
//    else if ( rpnVal.typ == SWValueTypeSize ) 
//    {
//        CGSize size = valueAsCGSizeForRpnValue( rpnVal ) ;
//        str = SWCFStringCreateWithFormat( "SM.size(%1.6g, %1.6g)", size.width, size.height );
//    }
//    
//    else if ( rpnVal.typ == SWValueTypeRect ) 
//    {
//        CGRect rect = valueAsCGRectForRpnValue( rpnVal ) ;
//        str = SWCFStringCreateWithFormat( "SM.rect(%1.6g, %1.6g, %1.6g, %1.6g)", 
//            rect.origin.x, rect.origin.y, rect.size.width, rect.size.height );
//    }
//    
//    else if ( rpnVal.typ == SWValueTypeError ) 
//    {
//        str = (CFStringRef)CFRetain(CFSTR("(error)")) ;
//    }
//    
//    else 
//    {
//        str = (CFStringRef)CFRetain(CFSTR("")) ;
//    }
//        
//    return str ;
//}


////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Scalar i Structs
////////////////////////////////////////////////////////////////////////////////////////////


//------------------------------------------------------------------------------------------
double valueAsDoubleForRpnValue( const RPNValue &rpnVal )
{
    if ( rpnVal.typ == SWValueTypeNumber ) return rpnVal.d ;
    if ( rpnVal.typ == SWValueTypeString ) return SWCFStringGetDoubleValue((CFStringRef)rpnVal.obj) ;
    return 0 ;
}

//------------------------------------------------------------------------------------------
double valueAsAbsoluteTimeForRpnValue( const RPNValue &rpnVal )
{
    if ( rpnVal.typ == SWValueTypeAbsoluteTime ) return rpnVal.d ;
    // TO DO es podria suportar la extraccio del temps a apartir de string amb CFDateFormatterCreateDateFromString
    return 0 ;
}

/*
//------------------------------------------------------------------------------------------
CGPoint valueAsCGPointForRpnValueVELL( const RPNValue &rpnVal )
{
    CGPoint point = CGPointZero ;
    if ( rpnVal.typ == SWValueTypeArray )
    {
        int count = RPNArrayGetCount( (RPNArrayRef)rpnVal.obj ) ;
        const RPNValue *values = RPNArrayGetValuesPtr( (RPNArrayRef)rpnVal.obj ) ;
        
        if ( count > 0 ) point.x = valueAsDoubleForRpnValue( values[0] ) ;
        if ( count > 1 ) point.y = valueAsDoubleForRpnValue( values[1] ) ;
    }
    return point ;
}
*/

//------------------------------------------------------------------------------------------
CGPoint valueAsCGPointForRpnValue( const RPNValue &rpnVal )
{
    CGPoint point = CGPointZero;
    if ( rpnVal.typ == SWValueTypePoint )
    {
        const void *ptr = RPNStructGetPtr( (RPNStructRef)rpnVal.obj );
        point = *(CGPoint*)ptr;
    }
    return point;
}

/*
//------------------------------------------------------------------------------------------
CGSize valueAsCGSizeForRpnValueVELL( const RPNValue &rpnVal )
{
    CGSize size = CGSizeZero ;
    if ( rpnVal.typ == SWValueTypeArray )
    {
        int count = RPNArrayGetCount( (RPNArrayRef)rpnVal.obj ) ;
        const RPNValue *values = RPNArrayGetValuesPtr( (RPNArrayRef)rpnVal.obj ) ;
        
        if ( count > 0 ) size.width = valueAsDoubleForRpnValue( values[0] ) ;
        if ( count > 1 ) size.height = valueAsDoubleForRpnValue( values[1] ) ;
    }
    return size ;
}
*/

//------------------------------------------------------------------------------------------
CGSize valueAsCGSizeForRpnValue( const RPNValue &rpnVal )
{
    CGSize size = CGSizeZero;
    if ( rpnVal.typ == SWValueTypeSize )
    {
        const void *ptr = RPNStructGetPtr( (RPNStructRef)rpnVal.obj );
        size = *(CGSize*)ptr;
    }
    return size;
}

/*
//------------------------------------------------------------------------------------------
CGRect valueAsCGRectForRpnValueVELL( const RPNValue &rpnVal )
{
    CGRect rect = CGRectZero ;
    if ( rpnVal.typ == SWValueTypeArray )
    {
        int count = RPNArrayGetCount( (RPNArrayRef)rpnVal.obj ) ;
        const RPNValue *values = RPNArrayGetValuesPtr( (RPNArrayRef)rpnVal.obj ) ;
        
        if ( count > 0 ) rect.origin.x = valueAsDoubleForRpnValue( values[0] ) ;
        if ( count > 1 ) rect.origin.y = valueAsDoubleForRpnValue( values[1] ) ;
        if ( count > 2 ) rect.size.width = valueAsDoubleForRpnValue( values[2] ) ;
        if ( count > 3 ) rect.size.height = valueAsDoubleForRpnValue( values[3] ) ;
    }
    return rect ;
}
*/

//------------------------------------------------------------------------------------------
CGRect valueAsCGRectForRpnValue( const RPNValue &rpnVal )
{
    CGRect rect = CGRectZero;
    if ( rpnVal.typ == SWValueTypeRect )
    {
        const void *ptr = RPNStructGetPtr( (RPNStructRef)rpnVal.obj );
        rect = *(CGRect*)ptr ;
    }
    return rect;
}


SWValueRange valueAsSWValueRangeForRpnValue( const RPNValue &rpnVal )
{
    SWValueRange range = SWValueRangeMake(0,0);
    if ( rpnVal.typ == SWValueTypeRange )
    {
        const void *ptr = RPNStructGetPtr( (RPNStructRef)rpnVal.obj );
        range = *(SWValueRange*)ptr ;
    }
    return range;
}


////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark RPNValue
////////////////////////////////////////////////////////////////////////////////////////////


//------------------------------------------------------------------------------------------
// funcions auxiliars (metodes privats)
//

inline void RPNValue::releaseObj()
{
    if ( typ == SWValueTypeArray ) 
    {
        if ( obj ) RPNArrayRelease( (RPNArrayRef)obj ) ;
    }
    else if ( typ&SWValueTypeFlagRPNValueRetainable )
    {
        if ( obj ) CFRelease( obj ) ; 
    }
}


//------------------------------------------------------------------------------------------
// auxiliars (metodes privats)
//
inline void RPNValue::setError( RPNValueErrCode error )
{
    releaseObj() ;
    typ = SWValueTypeError, err = error ;
}

inline void RPNValue::setTypeError() { setError( RPNVaErrorWrongType ) ; }
inline void RPNValue::setTypeMError() { setError( RPNVaErrorWrongTypeForMethod ) ; }
inline void RPNValue::setNumArgumentsError() { setError( RPNVaErrorNumArguments ) ; }
inline void RPNValue::setArgumentsTypeError() { setError( RPNVaErrorArgumentsType ) ; }

inline void RPNValue::setNumber( const double num )
{
    releaseObj() ;
    typ = SWValueTypeNumber, d = num ;
}

inline void RPNValue::setAbsoluteTime( const double num )
{
    releaseObj() ;
    typ = SWValueTypeAbsoluteTime, d = num ;
}

inline void RPNValue::setSelector( const UInt32 slct )
{
    releaseObj() ;
    typ = SWValueTypeClassSelector, sel = slct ;
}


inline void RPNValue::setStructBytes_length_withType( const void* bytes, UInt32 length, SWValueType newType )
{
    RPNStructRef structv = RPNStructCreate( bytes, length );
    setObject_withType( structv, newType ) ;
    CFRelease( structv ) ;
}


void RPNValue::setObject_withType( CFTypeRef newObj, UInt16 newType )
{
    // utilitzem el metode de primer retain, despres release per evitar problemes amb 
    // objectes que es contenen a si mateixos
    if ( (newType == SWValueTypeArray || newType&SWValueTypeFlagRPNValueRetainable) ) 
    {
        if ( newObj ) CFRetain( newObj ) ;    
        releaseObj() ;
        typ = newType ;
        obj = newObj ;
        return ;
    }
    
    setTypeError() ;
    return ;
}



//------------------------------------------------------------------------------------------
// encode/decode
//

void RPNValue::decode( QuickUnarchiver *decoder )
{
    releaseObj() ;  // no hauria de fer res mai ( si que fa!, en els rerieve)
    //obj = NULL;
    
    typ = (SWValueType)[decoder decodeInt] ;
    if ( typ == SWValueTypeNumber || typ == SWValueTypeAbsoluteTime ) 
    {
        d = [decoder decodeDouble] ;
    }

    else if ( typ == SWValueTypeArray )
    {
        int count = [decoder decodeInt] ;
        if ( count == -1 )
        {
            obj = NULL ;
        }
        else
        {
            RPNArrayRef array = RPNArrayCreate( NULL, count ) ;
            RPNValue *values = RPNArrayGetValuesPtr( array ) ;
            for ( int i=0 ; i<count ; i++ )
            {
                values[i].decode( decoder ) ;
            }
//            setObject_withType( array, SWValueTypeArray) ;  // retains
//            if ( array ) RPNArrayRelease( array ) ;
            obj = array ;  // obj ja l'hem releasat abans
        }
    }
    
    else if ( typ == SWValueTypeHash )
    {
        int count = [decoder decodeInt];
        if ( count == -1 )
        {
            obj = NULL;
        }
        else
        {
            RPNHashRef hash = RPNHashCreate(NULL, count);
            for ( int i=0 ; i<count ; i++ )
            {
                RPNValue *dKey = new RPNValue;
                RPNValue *dValue = new RPNValue;
                dKey->decode(decoder);
                dValue->decode(decoder);
                RPNHashSetNewValueForNewKey(hash, dValue, dKey);
            }
            obj = hash;  // obj ja l'hem releasat abans
        }
    }
    
    else if ( typ&SWValueTypeFlagRPNValueRetainable /*typ == SWValueTypeString*/ ) 
    {
        obj = (__bridge_retained CFTypeRef)[decoder decodeObject] ; // retain] ;
    }
    
    else if ( typ == SWValueTypeClassSelector ) 
    {
        sel = [decoder decodeInt] ;
    }
    
    else if ( typ == SWValueTypeError )
    {
        err = (RPNValueErrCode)[decoder decodeInt] ;
    }
    
    else
    {
        NSLog( @"algun tipus t'has deixat a RPNValue::decode");
        assert(NULL);
    }
}


//void RPNValue::retrieve( QuickUnarchiver *decoder )
//{
//    releaseObj() ;  // no hauria de fer res mai
//    
//    typ = (SWValueType)[decoder decodeInt] ;
//    if ( typ == SWValueTypeNumber ) 
//    {
//        d = [decoder decodeDouble] ;
//    }
//
//    else if ( typ == SWValueTypeArray )
//    {
//        int count = [decoder decodeInt] ;
//        if ( count == -1 )
//        {
//            obj = NULL ;
//        }
//        else
//        {
//            RPNArrayRef array = RPNArrayCreate( NULL, count ) ;
//            RPNValue *values = RPNArrayGetValuesPtr( array ) ;
//            for ( int i=0 ; i<count ; i++ )
//            {
//                values[i].decode( decoder ) ;
//            }
//            setObject_withType( array, SWValueTypeArray) ;  // retains
//            if ( array ) RPNArrayRelease( array ) ;
//        }
//    }
//    
//    else if ( typ&SWValueTypeFlagRPNValueRetainable /*typ == SWValueTypeString*/ ) 
//    {
//        obj = (__bridge_retained CFTypeRef)[decoder decodeObject] ; // retain] ;
//    }
//    
//    else if ( typ == SWValueTypeClassSelector ) 
//    {
//        sel = [decoder decodeInt] ;
//    }
//}



static void encodeHashApplierFunction( const RPNValue *key, const RPNValue *value, void *context )
{
    QuickArchiver *encoder = (__bridge QuickArchiver*)context;
    
    key->encode(encoder);
    value->encode(encoder);
}


void RPNValue::encode( QuickArchiver *encoder ) const
{
    [encoder encodeInt:typ] ;
    if ( typ == SWValueTypeNumber || typ == SWValueTypeAbsoluteTime )
    {
        [encoder encodeDouble:d] ;
    }

    else if ( typ == SWValueTypeArray )
    {
        if ( obj )
        {            
            int count = RPNArrayGetCount( (RPNArrayRef)(obj) ) ;
            const RPNValue *values = RPNArrayGetValuesPtr( (RPNArrayRef)(obj) ) ;
            [encoder encodeInt:count] ;
            for ( int i=0 ; i<count ; i++ )
            {
                values[i].encode( encoder ) ;
            }
        }
        else
        {
            [encoder encodeInt:-1] ;
        }
    }
    
    else if ( typ == SWValueTypeHash )
    {
        if ( obj )
        {
            int count = RPNHashGetCount((RPNHashRef)obj);
            [encoder encodeInt:count];
            RPNHashApplyFunction( (RPNHashRef)obj, encodeHashApplierFunction, (__bridge void*)encoder);
        }
        else
        {
            [encoder encodeInt:-1] ;
        }
    }
    
    else if ( typ&SWValueTypeFlagRPNValueRetainable /*typ == SWValueTypeString*/ ) 
    {
        [encoder encodeObject:(__bridge id)obj] ;
    }

    else if ( typ == SWValueTypeClassSelector )
    {
        [encoder encodeInt:sel] ;
    }
    
    else if ( typ == SWValueTypeError )
    {
        [encoder encodeInt:err] ;
    }
    
    else
    {
        NSLog( @"algun tipus t'has deixat a RPNValue::encode %d", typ);
        assert(NULL);
    }
}

#pragma mark Destructor

//------------------------------------------------------------------------------------------
// destructor

RPNValue::~RPNValue()
{
    releaseObj() ;
    typ = SWValueTypeError, d = 0 ; 
}


#pragma mark Constructors

//------------------------------------------------------------------------------------------
// constructors

RPNValue::RPNValue()
{
    //bzero( this, sizeof(*this) ) ;
    memset( this, 0, sizeof(*this) ) ;
}


RPNValue::RPNValue( const double num )
{
    typ = SWValueTypeNumber ;
    d = num ;
}


RPNValue::RPNValue( const double *nums, const int count )
{
    RPNArrayRef array = RPNArrayCreateWithNumbers( nums, count ) ;
    typ = SWValueTypeArray ;
    obj = array ;
}


RPNValue::RPNValue( CFStringRef *cStrs, const int count )
{
    RPNArrayRef array = RPNArrayCreateWithStrings( cStrs, count ) ;
    typ = SWValueTypeArray ;
    obj = array ;
}

RPNValue::RPNValue( const UInt32 slct )
{
    typ = SWValueTypeClassSelector ;
    sel = slct ;
}

RPNValue::RPNValue ( const CGPoint &point )
{
    typ = SWValueTypePoint;
    RPNStructRef structv = RPNStructCreate( &point, sizeof(CGPoint));
    obj = structv;
}

RPNValue::RPNValue ( const CGSize &size )
{
    typ = SWValueTypeSize;
    RPNStructRef structv = RPNStructCreate( &size, sizeof(CGSize));
    obj = structv;
}

RPNValue::RPNValue ( const CGRect &rect )
{
    typ = SWValueTypeRect;
    RPNStructRef structv = RPNStructCreate( &rect, sizeof(CGRect));
    obj = structv;
}

RPNValue::RPNValue ( const SWValueRange &range )
{
    typ = SWValueTypeRange;
    RPNStructRef structv = RPNStructCreate( &range, sizeof(SWValueRange));
    obj = structv;
}

//RPNValue::RPNValue ( const CFTypeRef object )
//{
//    typ = SWValueTypeObject;
//    obj = object ;
//    if ( obj ) CFRetain( obj );
//}

RPNValue::RPNValue( CFStringRef str )
{
    typ = SWValueTypeString;
    obj = str;
    if ( obj ) CFRetain( obj );
}


RPNValue::RPNValue(const RPNValue &rhs)
{
    typ = rhs.typ ;
    if ( rhs.typ == SWValueTypeNumber )
    {
        d = rhs.d ;
    }    
    
    else if ( rhs.typ == SWValueTypeClassSelector )
    {
        sel = rhs.sel ;
    }
    
    else if ( rhs.typ == SWValueTypeArray || (rhs.typ&SWValueTypeFlagRPNValueRetainable) )
    {
        obj = rhs.obj ;
        if ( obj ) CFRetain( obj ) ;
    }
}

//------------------------------------------------------------------------------------------
// asignacio

void RPNValue::operator=( const double num )
{
    setNumber( num ) ;
}

void RPNValue::operator=( const UInt32 slct )
{
    setSelector( slct ) ;
}

void RPNValue::operator=( const CGPoint &point )
{
   setStructBytes_length_withType( &point, sizeof(CGPoint), SWValueTypePoint);
}

void RPNValue::operator=( const CGSize &size )
{
   setStructBytes_length_withType( &size, sizeof(CGSize), SWValueTypeSize);
}

void RPNValue::operator=( const CGRect &rect )
{
   setStructBytes_length_withType( &rect, sizeof(CGRect), SWValueTypeRect);
}

void RPNValue::operator=( const SWValueRange &range )
{
   setStructBytes_length_withType( &range, sizeof(SWValueRange), SWValueTypeRange);
}

//void RPNValue::operator=( const CFTypeRef obj )
//{
//    setObject_withType( obj, SWValueTypeObject ) ;
//}

void RPNValue::operator=( CFStringRef str )
{
    setObject_withType( str, SWValueTypeString ) ;
}

void RPNValue::operator=( const RPNValue &rhs ) 
{
    if ( this != &rhs )
    {
        if ( rhs.typ == SWValueTypeNumber ) setNumber( rhs.d ) ;
        else if ( rhs.typ == SWValueTypeAbsoluteTime ) setAbsoluteTime( rhs.d );
        else if ( rhs.typ == SWValueTypeClassSelector ) setSelector( rhs.sel ) ;
        else if ( rhs.typ == SWValueTypeError ) setError( rhs.err ) ;
        else setObject_withType( rhs.obj, rhs.typ ) ;
    }
}

//------------------------------------------------------------------------------------------
// comparacio

bool RPNValue::operator==( const RPNValue &rhs ) const
{
    if ( this == &rhs )
    {
        // el mateix objecte es igual a ell mateix !
        return 1;
    }

    if ( typ != rhs.typ ) 
    {
        // elements de diferent tipus son sempre diferents
        return 0 ;
    }
    
    if ( typ == SWValueTypeNumber || typ == SWValueTypeAbsoluteTime )
    {
        return d == rhs.d ;
    }

    if ( typ == SWValueTypeString ) 
    {
        if ( obj && rhs.obj ) return CFEqual(obj, rhs.obj) ;
        if ( obj==NULL && rhs.obj==NULL ) return 1 ;
        return 0 ;
    }
    
    if ( typ == SWValueTypeArray )
    {
        // atencio per RPNArrays tornem sempre 0, implementar RPNArrayCompare
        return 0 ;
    }
    
    if ( typ == SWValueTypeHash )
    {
        // atencio per RPNHash tornem sempre 0, implementar RPNHashCompare
        return 0 ;
    }
    
#define MoreOperatorEqual false
#if MoreOperatorEqual
    if ( typ & SWValueTypeFlagRPNValueStruct )
    {
        const void *ptr = RPNStructGetPtr((RPNStructRef)rhs.obj);
        size_t size = RPNStructGetLength((RPNStructRef)rhs.obj);
        
        const void *oPtr = RPNStructGetPtr((RPNStructRef)obj);
        size_t oSize = RPNStructGetLength((RPNStructRef)obj);
        
        return ( size == oSize && 0 == memcmp( oPtr, ptr, size ) );
    }
    
    if ( typ == SWValueTypeObject ) 
    {
        if ( obj && rhs.obj ) return CFEqual(obj, rhs.obj) ;
        if ( obj==NULL && rhs.obj==NULL ) return 1 ;
        return 0 ;
    }
    
    if ( typ == SWValueTypeClassSelector )
    {
        return sel == rhs.sel ;
    }
    
    if ( typ == SWValueTypeError )
    {
        return err == rhs.err ;
    }
#endif

    return 0 ;
}


bool RPNValue::operator!=( const RPNValue &rhs ) const
{
    return ! operator==(rhs) ;
}


bool RPNValue::operator<( const RPNValue &rhs ) const
{
    if ( typ == rhs.typ ) 
    {
        if ( typ == SWValueTypeNumber || typ == SWValueTypeAbsoluteTime )
        {
            return d < rhs.d;
        }
    
        else if ( typ == SWValueTypeString )
        {
            //if ( obj != NULL && rhs.obj != NULL ) 
            //{
                CFComparisonResult result = CFStringCompare((CFStringRef)obj, (CFStringRef)rhs.obj, 0) ;
                return result == kCFCompareLessThan ;
            //}
        }
    }
    return 0;
}

bool RPNValue::operator>( const RPNValue &rhs ) const
{
    if ( typ == rhs.typ ) 
    {
        if ( typ == SWValueTypeNumber || typ == SWValueTypeAbsoluteTime )
        {
            return d > rhs.d;
        }
    
        else if ( typ == SWValueTypeString )
        {
            //if ( obj != NULL && rhs.obj != NULL ) 
            //{
                CFComparisonResult result = CFStringCompare((CFStringRef)obj, (CFStringRef)rhs.obj, 0) ;
                return result == kCFCompareGreaterThan ;
            //}
        }
    }
    return 0;
}

//------------------------------------------------------------------------------------------
// hash code

unsigned long RPNValue::hashCode() const
{    
    if ( typ == SWValueTypeNumber || typ == SWValueTypeAbsoluteTime )
    {
        return (unsigned long)d;
    }

    if ( typ&SWValueTypeFlagRPNValueRetainable )
    {        
        return CFHash(obj);
    }
    
    if ( typ == SWValueTypeClassSelector )
    {
        return (unsigned long)sel;
    }
    
    if ( typ == SWValueTypeError )
    {
        return (unsigned long)err;
    }

    return (unsigned long)this;

}


//------------------------------------------------------------------------------------------
// especials

void RPNValue::clear()
{
    setTypeError() ;    // ATENCIO mirar si te sentit posar no inicialitzat
    //status = 0;
    status.all = 0;
}


//void RPNValue::noSource()
//{
//    releaseObj();
//    typ = SWValueTypeNoSource;
//}



const int RPNValue::arrayCount() const
{
    if ( typ == SWValueTypeArray ) return RPNArrayGetCount( (RPNArrayRef)obj ) ;
    return 0 ;
}


const RPNValue &RPNValue::valueAtIndex(int indx) const
{
    if ( typ == SWValueTypeArray )
    {
        const RPNValue *values = RPNArrayGetValuesPtr( (RPNArrayRef)obj ) ;
        return values[indx] ;
    }
    return *this ;
}


const int RPNValue::hashCount() const
{
    if ( typ == SWValueTypeHash ) return RPNHashGetCount( (RPNHashRef)obj ) ;
    return 0 ;
}


void RPNValue::hashLog()
{
    NSInteger count = hashCount();
    if ( count > 0 )
    {
        
        const RPNValue *keys[count];
        const RPNValue *values[count];
        
        getHashKeysAndValues(keys, values);
        
        
        for (NSInteger i=0; i<count; ++i) 
        {
            const RPNValue *key = keys[i];
            const RPNValue *value = values[i];
        
            NSString *sKey = (__bridge_transfer NSString*)createStringForRpnValue_withFormat( *key, nil );
            NSString *sValue = (__bridge_transfer NSString*)createStringForRpnValue_withFormat( *value, nil );
        
            NSLog( @"sKey: %@", sKey);
            NSLog( @"sValue: %@", sValue);
        }
    }
}



const void RPNValue::getHashKeysAndValues( const RPNValue **keys, const RPNValue **values)
{
    if ( typ == SWValueTypeHash )
    {
        RPNHashGetKeysAndValues( (RPNHashRef)obj, keys, values );
    }
}

const RPNValue *RPNValue::getHashValueForKey(const RPNValue &key)
{
    if ( typ == SWValueTypeHash )
    {
        RPNValue *value = RPNHashGetValueForKey( (RPNHashRef)obj, key);
        return value;    // nil si no hi ha la key
    }
    return NULL;
}

////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark RPNValue execucio de codi en la pila del interpreter
////////////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------------------
// indirection

void RPNValue::getElement( const unsigned int count, const RPNValue *args )
{
    if ( typ == SWValueTypeNumber )
    {
        if ( count == 1 )
        {
            const RPNValue &arg0 = args[0] ;
            if ( arg0.typ == SWValueTypeNumber )
            {
                int bitNo = toInt(arg0.d) ;
                if ( bitNo < 0 || bitNo > 32 )
                {
                    d = 0.0 ;
                    return ;
                }
                int intValue = toInt(d) ;
                d = intValue & (1<<bitNo) ? 1.0 : 0.0 ;
                return ;
            }
            setError( RPNVaErrorBitArgumentsType ) ;
            return ;
        }
        setError( RPNVaErrorBitNumArguments ) ;
        return ;
    }

    else if ( typ == SWValueTypeString )
    {
        if ( obj )
        {
            //error = RPNVaErrorNumArguments ;  // si hi ha error sera en principi aquest
            CFStringRef s = (CFStringRef)(obj) ;
            CFIndex len = CFStringGetLength(s) ;
            
            if ( count < 1 || count > 2 )
            {
                setError( RPNVaErrorStringNumArguments ) ;
                return ; // error
            }
            
            const RPNValue &arg0 = args[0] ;
            if ( arg0.typ == SWValueTypeNumber )
            {
                int indx = toInt(arg0.d) ;
                if ( indx < 0 ) indx = len+indx ;
                
                if ( count == 1 )
                {
                    if ( indx >= 0 && indx < len )
                    {
                        UniChar ch = CFStringGetCharacterAtIndex(s, indx) ;
                        setNumber( ch ) ;
                        return ;
                    }
                    setError( RPNVaErrorStringBounds );
                    return ;
                }
                    
                else // count == 2
                {
                    const RPNValue &arg1 = args[1] ;
                    if ( arg1.typ == SWValueTypeNumber )
                    {
                        int leng = toInt(arg1.d) ;
                            
                        // si indx es massa gran no causa cap problema perque leng sera zero
                        if ( leng > len-indx ) leng = len-indx ;
                        if ( indx < 0 ) leng += indx, indx = 0 ;
                        if ( leng < 0 ) leng = 0 ;
                            
                        // if ( leng < 0 ) leng = 0 ;      // nomes acceptem longituds positives
                        // if ( leng > len-indx ) leng = len-indx ;
                            
                        CFStringRef ab = CFStringCreateWithSubstring(NULL, s, CFRangeMake(indx, leng)) ;
                
                        CFRelease( obj ) ;   // sabem que es CFStringRef
                        obj = ab ;  // continua essent CFStringRef, pot tornar una string vuida
                        return ;
                    }
                }
            }
            //setArgumentsTypeError() ;
            setError( RPNVaErrorStringArgumentsType ) ;
            return ;
        }
    }
        
    else if ( typ == SWValueTypeArray )
    {
        if ( obj )
        {
            //error = RPNVaErrorNumArguments ;  // si hi ha error sera en principi aquest
            RPNArrayRef a = (RPNArrayRef)(obj) ;
            CFIndex len = RPNArrayGetCount(a) ;
            
            if ( count < 1 || count > 2 )
            {
                setError( RPNVaErrorArrayNumArguments ) ;
                return ; // error
            }
            
            const RPNValue &arg0 = args[0] ;
            if ( arg0.typ == SWValueTypeNumber )
            {
                int indx = toInt(arg0.d) ;
                if ( indx < 0 ) indx = len+indx ;
                //if ( indx < 0 ) indx = 0 ;
                //if ( indx > len ) indx = len ;
            
                if ( count == 1 )
                {
                    if ( indx >= 0 && indx < len )
                    {
                        const RPNValue &value = RPNArrayGetValuesPtr(a)[indx] ;
                        operator=(value) ;
                        return ;
                    }
                    setError( RPNVaErrorArrayBounds );
                    return ;
                }
                
                else // count == 2
                {
                    const RPNValue &arg1 = args[1] ;
                    if ( arg1.typ == SWValueTypeNumber )
                    {
                        int leng = toInt(arg1.d) ;
                        
                        // si indx es massa gran no causa cap problema perque leng sera zero
                        if ( leng > len-indx ) leng = len-indx ;
                        if ( indx < 0 ) leng += indx, indx = 0 ;
                        if ( leng < 0 ) leng = 0 ;
                            
                        //if ( leng < 0 ) leng = 0 ;      // nomes acceptem longituds positives
                        //if ( leng > len-indx ) leng = len-indx ;
                        
                        // torna array buit si es out of bounds
                        const RPNValue *values = RPNArrayGetValuesPtr(a) + indx ;
                        RPNArrayRef ab = RPNArrayCreate( values, leng ) ;
                    
                        RPNArrayRelease( (RPNArrayRef)obj ) ;   // sabem que es SWValueTypeArray
                        obj = ab ; // continua essent un RPNTypeArray
                        return ;
                    }
                }
            }
            //setArgumentsTypeError() ;
            setError( RPNVaErrorArrayArgumentsType ) ;
            return ;
        }
    }
    
    else if ( typ == SWValueTypeHash )
    {
        if ( obj )
        {
            RPNHashRef hash = (RPNHashRef)(obj) ;
            if ( count != 1 )
            {
                setError( RPNVaErrorHashNumArguments ) ;
                return;
            }
            
            const RPNValue &arg0 = args[0];
            RPNValue *value = RPNHashGetValueForKey(hash, arg0);
            if ( value != NULL )
            {
                operator=(*value);
                return;
            }
            setError( RPNVaErrorHashBounds );
            return;
        }
    }
    
    
    

    setTypeError() ;
    return ;
}


void RPNValue::arrayMake( const unsigned int count, const RPNValue *args )
{    
    RPNArrayRef array = RPNArrayCreate( args, count ) ;
    setObject_withType( array, SWValueTypeArray ) ;  // retains
    if ( array ) RPNArrayRelease( array ) ;
}


void RPNValue::hashMake( const unsigned int count, const RPNValue *args )
{
    if ( count%2 == 0 )   // count ha de ser parell
    {
        RPNHashRef hash = RPNHashCreate( args, count/2 );
        
        if ( hash != NULL )
        {
            setObject_withType( hash, SWValueTypeHash );  // retains
            CFRelease( hash );
            return ;
        }
        
        setError( RPNVaErrorHashItemsTypeError );
        return;
    }
    
    setError(RPNVaErrorHashOddNumItems);
    return;
}



/*
void RPNValue::callFunct( int csl, int msl, const unsigned int count, const RPNValue *args )
{
    const RPNMethodsStruct &methodsStruct = RPNClasses[csl].methods[msl] ;
    const RPNMethod f = methodsStruct.method ;
    (this->*f)(count,args) ;
}
*/


// unary

void RPNValue::minus()
{
    if ( typ == SWValueTypeNumber )
    {
        d = -d ;
        return ;
    }
    setTypeError() ;
}

void RPNValue::opnot()
{
    if ( typ == SWValueTypeNumber )
    {
        d = ( d == 0.0 ? 1.0 : 0.0 ) ;
        return ;
    }
    setTypeError() ;
}

void RPNValue::opcompl()
{
    if ( typ == SWValueTypeNumber )
    {
        //d = ~toInt(d) ;
        d = ~toUInt(d) ;
        return ;
    }
    setTypeError() ;
}


static void addHashApplierFunction( const RPNValue *key, const RPNValue *value, void *context )
{
    const RPNHashRef hash = (RPNHashRef)context;
    const RPNValue *dKey = new RPNValue(*key);
    const RPNValue *dValue = new RPNValue(*value);
    RPNHashSetNewValueForNewKey(hash, dValue, dKey);
}


// range

void RPNValue::range( const RPNValue &rhs )
{
    if ( typ == rhs.typ ) 
    {
        if ( typ == SWValueTypeNumber )
        {
            SWValueRange range = SWValueRangeMake( d, rhs.d );
            RPNStructRef structv = RPNStructCreate( &range, sizeof(SWValueRange) );
            typ = SWValueTypeRange;
            obj = structv;
            return;
        }
    }
    setTypeError() ;
}

// arith

void RPNValue::add( const RPNValue &rhs )
{
    if ( typ == rhs.typ ) 
    {
        if ( typ == SWValueTypeNumber )
        {
            d += rhs.d ;
            return ;
        }
    
        else if ( typ == SWValueTypeString )
        {
            CFStringRef s1 = (CFStringRef)(obj) ;
            CFStringRef s2 = (CFStringRef)(rhs.obj) ;
            //if ( s1 != NULL && s2 != NULL )
            {
                CFMutableStringRef ab = CFStringCreateMutableCopy(NULL, CFStringGetLength(s1)+CFStringGetLength(s2), s1) ;
                CFStringAppend(ab, s2) ;
        
                CFRelease( obj ) ;
                obj = ab ;
                return ;
            }
        }
        
        else if ( typ == SWValueTypeArray )
        {
            RPNArrayRef a1 = (RPNArrayRef)(obj) ;
            RPNArrayRef a2 = (RPNArrayRef)(rhs.obj) ;
            //if ( a1 != NULL && a2 != NULL )
            {
                int count1 = RPNArrayGetCount( a1 ) ;
                int count2 = RPNArrayGetCount( a2 ) ;
                
                RPNArrayRef array = RPNArrayCreate( NULL, count1+count2 ) ;
                RPNValue *values = RPNArrayGetValuesPtr( array ) ;
                
                const RPNValue *values1 = RPNArrayGetValuesPtr( a1 ) ;
                for ( int i=0 ; i<count1 ; i++ ) *values++ = *values1++ ; 
        
                const RPNValue *values2 = RPNArrayGetValuesPtr( a2 ) ;
                for ( int i=0 ; i<count2 ; i++ ) *values++ = *values2++ ;
        
                RPNArrayRelease( (RPNArrayRef)obj ) ;
                obj = array ;
                return ;
            }
        }
        
        else if ( typ == SWValueTypeHash )
        {
            RPNHashRef h1 = (RPNHashRef)(obj) ;
            RPNHashRef h2 = (RPNHashRef)(rhs.obj) ;
            //if ( h1 != NULL && h2 != NULL )
            {
                int count1 = RPNHashGetCount( h1 ) ;
                int count2 = RPNHashGetCount( h2 ) ;
            
                RPNHashRef hash = RPNHashCreate(NULL, count1+count2);  // capacitat la suma dels dos
            
                RPNHashApplyFunction(h1, addHashApplierFunction, hash);
                RPNHashApplyFunction(h2, addHashApplierFunction, hash);
            
                RPNHashRelease( (RPNHashRef)obj );
                obj = hash;
                return;
            }
        }
        
        // No es poden sumar dos absoluteTimes
    }
    
    else if ( (typ == SWValueTypeAbsoluteTime && rhs.typ == SWValueTypeNumber) ||
              (typ == SWValueTypeNumber && rhs.typ == SWValueTypeAbsoluteTime) )
    {
        // es pot sumar un absolute time a un numero i el resultat es un absolute time
        d += rhs.d ;
        typ = SWValueTypeAbsoluteTime;
        return ;
    }
    setTypeError() ;
}


void RPNValue::sub( const RPNValue &rhs )
{    
    if ( typ == rhs.typ ) 
    {
        if ( typ == SWValueTypeNumber )
        {
            d -= rhs.d ;
            return ;
        }
        else if ( typ == SWValueTypeAbsoluteTime )
        {
            // es poden restar dos absolute times i el resultat es un numero
            d -= rhs.d ;
            typ = SWValueTypeNumber;
            return;
        }
    }
    
    else if ( typ == SWValueTypeAbsoluteTime && rhs.typ == SWValueTypeNumber )
    {
        // es pot restar un numero de un absolute time i el resultat es un absolute time
        d -= rhs.d ;
        typ = SWValueTypeAbsoluteTime;
        return;
    }
    setTypeError() ;
}


void RPNValue::times( const RPNValue &rhs )
{    
    if ( typ == rhs.typ ) 
    {
        if ( typ == SWValueTypeNumber )
        {
            d *= rhs.d ;
            return ;
        }
    }
    setTypeError() ;
}

void RPNValue::div( const RPNValue &rhs )
{    
    if ( typ == rhs.typ ) 
    {
        if ( typ == SWValueTypeNumber )
        {
            d /= rhs.d ;
            return ;
        }
    }
    setTypeError() ;
}

void RPNValue::mod( const RPNValue &rhs )
{    
    if ( typ == rhs.typ ) 
    {
        if ( typ == SWValueTypeNumber )
        {
            //d = toInt(d) % toInt(rhs.d) ;
            d = fmod(d, rhs.d) ;
            return ;
        }
    }
    setTypeError() ;
}


// compare

void RPNValue::eq( const RPNValue &rhs )
{
    if ( typ == rhs.typ ) 
    {
        if ( typ == SWValueTypeNumber || typ == SWValueTypeAbsoluteTime )
        {
            d = ( d == rhs.d ? 1.0 : 0.0 ) ;
            typ = SWValueTypeNumber;    // <-- forcem numero en cas que sigui un absolute time
            return ;
        }
    
        else if ( typ == SWValueTypeString )
        {
            CFComparisonResult result = CFStringCompare((CFStringRef)obj, (CFStringRef)rhs.obj, 0) ;
            setNumber( result == kCFCompareEqualTo ) ;
            return ;
        }
        
        else if ( typ == SWValueTypeArray )
        {
            // TO DO per arrays comparacio recursiva ->implementar RPNArrayCompare
            setNumber( 0.0 ) ;   // per ara els arrays son sempre diferents
            return ;
        }
        
        else if ( typ == SWValueTypeHash )
        {
            // TO DO per hash comparacio recursiva ->implementar RPNHashCompare
            setNumber( 0.0 ) ;   // per ara els hash son sempre diferents
            return ;
        }
    }
    
    // rpns de tipus diferent no es poden comparar
    setTypeError() ;
}
 

void RPNValue::lt( const RPNValue &rhs )
{
//    if ( typ == rhs.typ ) 
//    {
//        if ( typ == SWValueTypeNumber || typ == SWValueTypeAbsoluteTime )
//        {
//            d = ( d < rhs.d ? 1.0 : 0.0 );
//            typ = SWValueTypeNumber;    // <-- forcem numero en cas que sigui un absolute time
//            return ;
//        }
//    
//        else if ( typ == SWValueTypeString )
//        {
//            //if ( obj != NULL && rhs.obj != NULL ) 
//            //{
//                CFComparisonResult result = CFStringCompare((CFStringRef)obj, (CFStringRef)rhs.obj, 0) ;
//                setNumber( result == kCFCompareLessThan ) ;
//                return ;
//            //}
//        }
//    }
//    setTypeError() ;
    
    
    if ( typ == rhs.typ )
    {
        setNumber( *this < rhs );
        return;
    }
    setTypeError() ;
    
}


void RPNValue::gt( const RPNValue &rhs )
{
//    if ( typ == rhs.typ ) 
//    {
//        if ( typ == SWValueTypeNumber || typ == SWValueTypeAbsoluteTime )
//        {
//            d = ( d > rhs.d ? 1.0 : 0.0 );
//            typ = SWValueTypeNumber;    // <-- forcem numero en cas que sigui un absolute time
//            return ;
//        }
//    
//        else if ( typ == SWValueTypeString )
//        {
//            //if ( obj != NULL && rhs.obj != NULL ) 
//            //{
//                CFComparisonResult result = CFStringCompare((CFStringRef)obj, (CFStringRef)rhs.obj, 0) ;
//                setNumber( result == kCFCompareGreaterThan ) ;
//                return ;
//            //}
//        }
//    }
//    setTypeError() ;
    
    
    if ( typ == rhs.typ )
    {
        setNumber( *this > rhs );
        return;
    }
    setTypeError() ;
    
    
    
    
    
}

/*
void RPNValue::le( const RPNValue &rhs )
{
    if ( typ == rhs.typ ) 
    {
        if ( typ == SWValueTypeNumber )
        {
            d = d <= rhs.d ;
            return ;
        }
    
        else if ( typ == SWValueTypeString )
        {
            if ( obj != NULL && rhs.obj != NULL ) 
            {
                CFComparisonResult result = CFStringCompare((CFStringRef)obj, (CFStringRef)rhs.obj, 0) ;
                setNumber( result == kCFCompareLessThan || result == kCFCompareEqualTo ) ;
                return ;
            }
        }
    }
    setError() ;
}
*/


/*
void RPNValue::ne( const RPNValue &rhs )
{
    if ( typ == rhs.typ ) 
    {
        if ( typ == SWValueTypeNumber )
        {
            d = d != rhs.d ;
            return ;
        }
    
        else if ( typ == SWValueTypeString )
        {
            if ( obj != NULL && rhs.obj != NULL ) 
            {
                CFComparisonResult result = CFStringCompare((CFStringRef)obj, (CFStringRef)rhs.obj, 0) ;
                setNumber( ! ( result == kCFCompareEqualTo ) ) ;
                return ;
            }
            else // comparacio per desigualtat valida encara que algun sigui null
            {
                setNumber( obj == NULL && rhs.obj == NULL ? 0.0 : 1.0 ) ;
                return ;
            }
        }
    }
    setError() ;
}
*/


/*
void RPNValue::ge( const RPNValue &rhs )
{
    if ( typ == rhs.typ ) 
    {
        if ( typ == SWValueTypeNumber )
        {
            d = d >= rhs.d ;
            return ;
        }
    
        else if ( typ == SWValueTypeString )
        {
            if ( obj != NULL && rhs.obj != NULL ) 
            {
                CFComparisonResult result = CFStringCompare((CFStringRef)obj, (CFStringRef)rhs.obj, 0) ;
                setNumber( result == kCFCompareGreaterThan || result == kCFCompareEqualTo ) ;
                return ;
            }
        }
    }
    setError() ;
}
*/

void RPNValue::ne( const RPNValue &rhs )
{
    eq( rhs ) ;
    opnot() ;
//    //if ( typ == SWValueTypeNumber ) d = ( d == 0.0 ? 1.0 : 0.0 ) ;
}

void RPNValue::ge( const RPNValue &rhs )
{
    lt( rhs ) ;
    opnot() ;
//    if ( typ == SWValueTypeNumber ) d = ( d == 0.0 ? 1.0 : 0.0 ) ;
}

void RPNValue::le( const RPNValue &rhs )
{
    gt( rhs ) ;
    opnot() ;
//    if ( typ == SWValueTypeNumber ) d = ( d == 0.0 ? 1.0 : 0.0 ) ;
}


// logical

void RPNValue::opor( const RPNValue &rhs )
{    
    if ( typ == rhs.typ ) 
    {
        if ( typ == SWValueTypeNumber )
        {
            d = d!=0.0 || rhs.d!=0.0 ;
            return ;
        }
    }
    setTypeError() ;
}

void RPNValue::opand( const RPNValue &rhs )
{    
    if ( typ == rhs.typ ) 
    {
        if ( typ == SWValueTypeNumber )
        {
            d = d!=0.0 && rhs.d!=0.0 ;
            return ;
        }
    }
    setTypeError() ;
}

void RPNValue::opbitor( const RPNValue &rhs )
{    
    if ( typ == rhs.typ ) 
    {
        if ( typ == SWValueTypeNumber )
        {
            //d = toInt(d) | toInt(rhs.d) ;
            d = toUInt(d) | toUInt(rhs.d) ;
            return ;
        }
    }
    setTypeError() ;
}

void RPNValue::opbitxor( const RPNValue &rhs )
{    
    if ( typ == rhs.typ ) 
    {
        if ( typ == SWValueTypeNumber )
        {
            //d = toInt(d) ^ toInt(rhs.d) ; ;
            d = toUInt(d) ^ toUInt(rhs.d) ; ;
            return ;
        }
    }
    setTypeError() ;
}

void RPNValue::opbitand( const RPNValue &rhs )
{    
    if ( typ == rhs.typ ) 
    {
        if ( typ == SWValueTypeNumber )
        {
            //d = toInt(d) & toInt(rhs.d) ;
            d = toUInt(d) & toUInt(rhs.d) ;
            return ;
        }
    }
    setTypeError() ;
}


// tern

void RPNValue::tern( const RPNValue &rhs1, const RPNValue &rhs2 )
{
    if ( typ == SWValueTypeNumber )
    {  
        if ( rhs1.typ == rhs2.typ ) 
        {
            const RPNValue &rhs = d!=0.0 ? rhs1 : rhs2 ;
            operator=(rhs) ;
            
            return ;
        }
    }
    setTypeError() ;
}

// if

bool RPNValue::jeq()
{
    bool result = true ;
    if ( typ == SWValueTypeNumber )
    {
        result = ( d == 0.0 ) ;
        return result ;
    }
    
    /*
    if ( typ == SWValueTypeError && err == RPNVaErrorNotInitialized )
    {
        return true ;
    }
    */
    
    setTypeError() ;   // sempre torna error perque sera el que queda si no s'executa res
    return true ;
} ;


// comma list
BOOL RPNValue::commaList( const unsigned int count, const RPNValue *args )
{

    //NSLog( @"sizeof RPNValueStatusFlagsFlags:%ld",sizeof(RPNValueStatusFlags) );

    if ( count == 0 )
    {
        setNumArgumentsError() ;
        return NO; // error
    }

    for (int i=0 ; i<count ; i++ )
    {
        //if (args[i].status & RPNVaFlagChanging)
        if ( args[i].status.changing )
        {
            operator=(args[i]);
            return YES;
        }
    }
    return NO;
}


// altres (de tipus RPNMethod) 
void RPNValue::to_s( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( count > 1 )
    {
        setNumArgumentsError() ;
        return ; // error
    }
    
    if ( count == 1 )
    {
        const RPNValue &arg0 = args[0] ;
        CFStringRef format = NULL ;
        if ( arg0.typ == SWValueTypeString ) format = (CFStringRef)arg0.obj ;
        if ( format )
        {
            CFStringRef formated = sprintfStringCreate( format, 1, this, NO ) ;
            if ( typ == SWValueTypeNumber )
            {
                typ = SWValueTypeString ;  // despres de cridar sprintfStringCreate
                obj = formated ;
                return ;
            }
            else if ( typ == SWValueTypeString )
            {
                setObject_withType( formated, SWValueTypeString ) ;  // cridem aquest perque formated pot ser == obj ;
                CFRelease( formated ) ;
                return ;
            }
            // TO DO per arrays crear la str recursivament
        }
        else
        {
            setArgumentsTypeError() ;
            return ; // error
        }
    }
    
    else // count == 0
    {
        if ( typ == SWValueTypeNumber )
        {
            obj = SWCFStringCreateWithFormat( "%1.15g", d ) ;
            typ = SWValueTypeString ;
            return ; // ok
        }
        else if ( typ == SWValueTypeString )
        {
            return ; // ok no cal fer res
        }
        // TO DO per arrays crear la str recursivament
    }

    setTypeMError() ;
    return ; // error
}

/*
void RPNValue::to_sV( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( count > 1 )
    {
        setNumArgumentsError() ;
        return ; // error
    }

    if ( typ == SWValueTypeNumber )
    {
        if ( count == 1 )
        {
            const RPNValue &arg0 = args[0] ;
            if ( arg0.typ == SWValueTypeString )
            {
                CFStringRef simpleFormat = (CFStringRef)arg0.obj ;
                if ( simpleFormat )
                {
                    obj = createStringWithSimpleFormat( simpleFormat, *this ) ;
                    //obj = sprintfStringCreate( simpleFormat, 1, this ) ;         // a posar
                    typ = SWValueTypeString ;  // despres de cridar createStringWithSimpleFormat
                    return ;
                }
            }
            
            setArgumentsTypeError() ;
            return ; // error
        }
        obj = SWCFStringCreateWithFormat( "%g", d ) ;
        typ = SWValueTypeString ;
        return ; // ok
    }
    
    else if ( typ == SWValueTypeString )
    {
                            // a posar sprintfStringCreate ( integrar amb lo anterior )
        return ; // ok
    }
    
    // per arrays crear la str recursivament

    setTypeError() ;
    return ; // error
}
*/

/*
void RPNValue::to_a( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( count != 0 )
    {
        setNumArgumentsError() ;
        return ; // error
    }

    
    //RPNArrayRef array = RPNArrayCreate( this, 1 ) ;
    //setObject_withType( array, SWValueTypeArray ) ;
    //RPNArrayRelease( array ) ;
    //return ;
    
    arrayMake( 1, this ) ;
    return ;
}
*/

void RPNValue::to_f( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( count != 0 ) 
    {
        setNumArgumentsError() ;
        return ;
    }

    if ( typ == SWValueTypeNumber )
    {
        return ;
    }
    
    else if ( typ == SWValueTypeAbsoluteTime )
    {
        typ = SWValueTypeNumber;
        return;
    }
    
    else if ( typ == SWValueTypeString )
    {
        //if ( obj ) 
        //{
            double value = SWCFStringGetDoubleValue( (CFStringRef)obj ) ;
            setNumber( value ) ;
            return ;
        //}
        //setNumber( 0.0 ) ;
        //return ;
    }
    
    setTypeMError() ;
}


void RPNValue::to_i( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( count != 0 ) 
    {
        setNumArgumentsError() ;
        return ;
    }

    if ( typ == SWValueTypeNumber )   // absoluteTimes no estan suportats per to_i
    {
        d = toInt(d) ;
        return ;
    }
    
    else if ( typ == SWValueTypeString )
    {
        //if ( obj ) 
        //{
            double value = SWCFStringGetDoubleValue( (CFStringRef)obj ) ;
            setNumber( toInt(value) ) ;
            return ;
        //}
        //setNumber( 0.0 ) ;
        //return ;
    }
    
    setTypeMError() ;
}


void RPNValue::range_begin( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ == SWValueTypeRange )
    {
        if ( count == 0 )
        {
            const SWValueRange *range = (SWValueRange*)RPNStructGetPtr( (RPNStructRef)obj );
            setNumber(range->min);
            return ;
        }
        setNumArgumentsError();
        return;
    }
    setTypeMError() ;
    return;
}


void RPNValue::range_end( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ == SWValueTypeRange )
    {
        if ( count == 0 )
        {
            const SWValueRange *range = (SWValueRange*)RPNStructGetPtr( (RPNStructRef)obj );
            setNumber(range->max);
            return ;
        }
        setNumArgumentsError();
        return;
    }
    setTypeMError() ;
    return;
}


void RPNValue::rect_origin( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ == SWValueTypeRect )
    {
        if ( count == 0 )
        {
            const CGRect *rect = (CGRect*)RPNStructGetPtr( (RPNStructRef)obj );
            setStructBytes_length_withType(&(rect->origin), sizeof(CGPoint), SWValueTypePoint) ;
            return ;
        }
        setNumArgumentsError();
        return;
    }
    setTypeMError();
    return;
}


void RPNValue::rect_size( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ == SWValueTypeRect )
    {
        if ( count == 0 )
        {
            const CGRect *rect = (CGRect*)RPNStructGetPtr( (RPNStructRef)obj );
            setStructBytes_length_withType(&(rect->size), sizeof(CGPoint), SWValueTypeSize) ;
            return ;
        }
        setNumArgumentsError();
        return;
    }
    setTypeMError();
    return;
}


void RPNValue::point_x( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ == SWValueTypePoint )
    {
        if ( count == 0 )
        {
            const CGPoint *point = (CGPoint*)RPNStructGetPtr( (RPNStructRef)obj );
            setNumber(point->x) ;
            return ;
        }
        setNumArgumentsError();
        return;
    }
    setTypeMError();
    return;
}


void RPNValue::point_y( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ == SWValueTypePoint )
    {
        if ( count == 0 )
        {
            const CGPoint *point = (CGPoint*)RPNStructGetPtr( (RPNStructRef)obj );
            setNumber(point->y) ;
            return ;
        }
        setNumArgumentsError();
        return;
    }
    setTypeMError();
    return;
}


void RPNValue::size_width( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ == SWValueTypeSize )
    {
        if ( count == 0 )
        {
            const CGSize *size = (CGSize*)RPNStructGetPtr( (RPNStructRef)obj );
            setNumber(size->width) ;
            return ;
        }
        setNumArgumentsError();
        return;
    }
    setTypeMError();
    return;
}


void RPNValue::size_height( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ == SWValueTypeSize )
    {
        if ( count == 0 )
        {
            const CGSize *size = (CGSize*)RPNStructGetPtr( (RPNStructRef)obj );
            setNumber(size->height) ;
            return ;
        }
        setNumArgumentsError();
        return;
    }
    setTypeMError();
    return;
}


void RPNValue::rabs( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( count != 0 ) 
    {
        setNumArgumentsError() ;
        return ;
    }

    if ( typ == SWValueTypeNumber )
    {
        d = fabs(d) ;
        return ;
    }
    
    setTypeMError() ;
}


void RPNValue::rround( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( count != 0 ) 
    {
        setNumArgumentsError() ;
        return ;
    }

    if ( typ == SWValueTypeNumber )
    {
        d = round(d) ;
        return ;
    }
    
    setTypeMError() ;
}


void RPNValue::rfloor( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( count != 0 ) 
    {
        setNumArgumentsError() ;
        return ;
    }

    if ( typ == SWValueTypeNumber )
    {
        d = floor(d) ;
        return ;
    }
    
    setTypeMError() ;
}


void RPNValue::rceil( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( count != 0 ) 
    {
        setNumArgumentsError() ;
        return ;
    }

    if ( typ == SWValueTypeNumber )
    {
        d = ceil(d) ;
        return ;
    }
    
    setTypeMError() ;
}



void RPNValue::chr( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( count != 0 ) 
    {
        setNumArgumentsError() ;
        return ;
    }
    
    if ( typ == SWValueTypeNumber )
    {
        UniChar ch = toInt(d) ;
        CFStringRef str = CFStringCreateWithCharacters( NULL, &ch, 1 ) ;
        typ = SWValueTypeString ;
        obj = str ;
        return ;
    }

    setTypeMError() ;
}


//void RPNValue::fetch( const int msl, const unsigned int count, const RPNValue *args )
//{
//    if ( typ != SWValueTypeArray /*|| obj == NULL*/ )
//    {
//        setTypeMError() ;
//        return ;
//    }
//
//    if ( count != 2 )
//    {
//        setNumArgumentsError() ;
//        return ;
//    }
//
//    RPNArrayRef a = (RPNArrayRef)(obj) ;
//    CFIndex len = RPNArrayGetCount(a) ;
//            
//    const RPNValue &arg0 = args[0] ;
//    if ( arg0.typ == SWValueTypeNumber )
//    {
//        int indx = toInt(arg0.d) ;
//        if ( indx < 0 ) indx = len+indx ;
//        
//        if ( indx >= 0 && indx < len )
//        {
//            const RPNValue &value = RPNArrayGetValuesPtr(a)[indx] ;
//            operator=(value) ;
//            return ;
//        }
//        else
//        {
//            const RPNValue &arg1 = args[1] ;
//            operator=( arg1 ) ;
//            return ;
//        }
//    }
//    setArgumentsTypeError() ;
//    return ;
//}


void RPNValue::fetch( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( count != 2 )
    {
        setNumArgumentsError() ;
        return ;
    }
    
    if ( typ == SWValueTypeArray )
    {
        RPNArrayRef a = (RPNArrayRef)(obj) ;
        CFIndex len = RPNArrayGetCount(a) ;
    
        const RPNValue &arg0 = args[0] ;
        if ( arg0.typ == SWValueTypeNumber )
        {
            int indx = toInt(arg0.d) ;
            if ( indx < 0 ) indx = len+indx ;
        
            if ( indx >= 0 && indx < len )
            {
                const RPNValue &value = RPNArrayGetValuesPtr(a)[indx] ;
                operator=(value) ;
                return ;
            }
            const RPNValue &arg1 = args[1] ;
            operator=( arg1 ) ;
            return ;
        }
        setArgumentsTypeError() ;
        return ;
    }
    
    if ( typ == SWValueTypeHash )
    {
        RPNHashRef hash = (RPNHashRef)(obj) ;
        const RPNValue &arg0 = args[0];
        
        RPNValue *value = RPNHashGetValueForKey(hash, arg0);
        if ( value != NULL )
        {
            operator=(*value);
            return;
        }
        const RPNValue &arg1 = args[1];
        operator=( arg1 ) ;
        return;
    }
    
    setTypeMError();
    return;
}





void RPNValue::length( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( count != 0 ) 
    {
        setNumArgumentsError() ;
        return ;
    }
    
    if ( typ == SWValueTypeString )
    {
        //if ( obj )
        //{
            double len = (double)CFStringGetLength( (CFStringRef)obj ) ;
            setNumber( len ) ;
            return ;
        //}
    }
    
    else if ( typ == SWValueTypeArray )
    {
        //if ( obj )
        //{
            double len = (double)RPNArrayGetCount( (RPNArrayRef)obj ) ;
            setNumber( len ) ;
            return ;
        //}
    }
    
    else if ( typ == SWValueTypeHash )
    {
        double len = (double)RPNHashGetCount( (RPNHashRef)obj ) ;
        setNumber( len ) ;
        return ;
    }
    
    setTypeMError() ;
    return;
}

/*
void RPNValue::count( const unsigned int count, const RPNValue *args )
{
    if ( count != 0 ) 
    {
        setNumArgumentsError() ;
        return ;
    }
    
    if ( typ == SWValueTypeArray )
    {
        if ( obj )
        {
            double len = (double)RPNArrayGetCount( (RPNArrayRef)obj ) ;
            setNumber( len ) ;
            return ;
        }
    }
    
    setTypeError() ;
}
*/


void RPNValue::split( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ != SWValueTypeString || obj == NULL )
    {
        setTypeMError() ;
        return ;
    }
    
    if ( count > 1 ) 
    {
        setNumArgumentsError() ;
        return ;
    }
    
    if ( count == 0 )
    {
        arrayMake( 1, this ) ;
        return ;
    }

    const RPNValue &arg0 = args[0] ;
    if ( arg0.typ == SWValueTypeString )
    {
        CFStringRef splitStr = (CFStringRef)arg0.obj ;
        //if ( splitStr )
        //{
            RPNArrayRef array ;
            int splitStrLen = CFStringGetLength( splitStr ) ;
            if ( splitStrLen == 0 )
            {
                // cas especial de string vuida, creem un array amb cada un dels caracters
                int strCount = CFStringGetLength( (CFStringRef)obj ) ;
                CFStringRef cStrArray[strCount] ;
                for ( int i = 0 ; i<strCount ; i++ )
                {
                    UniChar ch = CFStringGetCharacterAtIndex( (CFStringRef)(obj), i ) ;
                    CFStringRef str = CFStringCreateWithCharacters( NULL, &ch, 1 ) ;
                    cStrArray[i] = str ;
                }
                array = RPNArrayCreateWithStrings( cStrArray, strCount ) ;
                for ( int i= 0 ; i<strCount ; i++ ) 
                {
                    CFStringRef str = cStrArray[i] ;
                    CFRelease( str ) ;
                }
            }
            else
            {
                // cas normal
                CFArrayRef strArray = CFStringCreateArrayBySeparatingStrings(NULL, (CFStringRef)obj, splitStr ) ;
                int strCount = CFArrayGetCount(strArray) ;
                CFStringRef cStrArray[strCount] ;
                CFArrayGetValues( strArray, CFRangeMake(0,strCount), (const void**)cStrArray ) ;
                array = RPNArrayCreateWithStrings( cStrArray, strCount ) ;
                CFRelease( strArray ) ;
            }
            
            setObject_withType( array, SWValueTypeArray ) ;
            RPNArrayRelease( array ) ;
            return ;
        //}
    }
    setArgumentsTypeError() ;
    return ;
}


void RPNValue::join( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ != SWValueTypeArray /*|| obj == NULL*/ )
    {
        setTypeMError() ;
        return ;
    }

    if ( count > 1 ) 
    {
        setNumArgumentsError() ;
        return ;
    }
    
    CFStringRef joinStr ;
    if ( count == 0 )
    {
        joinStr = CFSTR( "" ) ;
    }
    else if ( count == 1 )
    {
        const RPNValue &arg0 = args[0] ;
        if ( arg0.typ == SWValueTypeString )
        {
            joinStr = (CFStringRef)arg0.obj ;
            if ( joinStr ) goto do_join ;
        }
        setArgumentsTypeError() ;
        return ;
    }
    else
    {
        setNumArgumentsError() ;
        return ;
    }

do_join:
 
    RPNArrayRef array = (RPNArrayRef)obj ;
    int strCount = RPNArrayGetCount( array ) ;
    CFMutableArrayRef strArray = CFArrayCreateMutable( NULL, strCount, &kCFTypeArrayCallBacks ) ;
    
    const RPNValue *values = RPNArrayGetValuesPtr( array ) ;
    for ( int i=0 ; i<strCount ; i++ )
    {
        if ( values[i].typ == SWValueTypeString )
        {
            CFStringRef str = (CFStringRef)values[i].obj ;
            if ( str ) CFArrayAppendValue( strArray, str ) ;
            else CFArrayAppendValue( strArray, CFSTR("") ) ;
        }
        else if ( values[i].typ == SWValueTypeNumber )
        {
            double num = values[i].d ;
            //CFStringRef str = CFStringCreateWithFormat(NULL, NULL, CFSTR("%g"), num ) ;
            CFStringRef str = SWCFStringCreateWithFormat( "%1.15g", num ) ;
            CFArrayAppendValue( strArray, str ) ;
            CFRelease( str ) ;
        }
        else if ( values[i].typ == SWValueTypeArray )
        {
            // per arrays crear la str recursivament
            RPNValue joined = values[i] ;
            joined.join( msl, count, args) ;
            if ( joined.typ == SWValueTypeString )
            {
                CFArrayAppendValue( strArray, joined.obj ) ;
            }
            else  // no passa mai, doncs passem els mateixos arguments del join que ja s'han comprovat
            {
                CFRelease( strArray );
                return ; // torna el tipus de error generat per join
            }
        }
        
        else
        {
            // per altres tipus no afegim res
            CFArrayAppendValue( strArray, CFSTR("") ) ;
        }
    }
    
    CFStringRef string = CFStringCreateByCombiningStrings( NULL, strArray, joinStr ) ;
    setObject_withType( string, SWValueTypeString ) ;
    CFRelease( string ) ;
    CFRelease( strArray ) ;
    return ; // ok
}


void RPNValue::array_min( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ != SWValueTypeArray )
    {
        setTypeMError() ;
        return ;
    }

    if ( count != 0 )
    {
        setNumArgumentsError() ;
        return ;
    }

    RPNArrayRef array = (RPNArrayRef)obj ;
    int arrCount = RPNArrayGetCount( array ) ;

    if ( arrCount < 1 )  // at least one element array
    {
        setError( RPNVaErrorEnumerableNumItems);
        return;
    }

    const RPNValue *values = RPNArrayGetValuesPtr( array ) ;
    
    int minIndex = 0;
    SWValueType etype = values[0].typ;
    
    for ( int i=0 ; i<arrCount ; i++ )
    {
        if ( values[i].typ != etype )
        {
            setError(RPNVaErrorEnumerableItemsTypeError);
            return;
        }
        
        if ( values[i] < values[minIndex] )
        {
            minIndex = i;
        }
    }
    
    //*this = values[minIndex];
    operator=(values[minIndex]);
}


void RPNValue::array_max( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ != SWValueTypeArray )
    {
        setTypeMError() ;
        return ;
    }

    if ( count != 0 )
    {
        setNumArgumentsError() ;
        return ;
    }

    RPNArrayRef array = (RPNArrayRef)obj ;
    int arrCount = RPNArrayGetCount( array ) ;

    if ( arrCount < 1 )  // at least one element array
    {
        setError( RPNVaErrorEnumerableNumItems);
        return;
    }

    const RPNValue *values = RPNArrayGetValuesPtr( array ) ;
    
    int maxIndex = 0;
    SWValueType etype = values[0].typ;
    
    for ( int i=0 ; i<arrCount ; i++ )
    {
        if ( values[i].typ != etype )
        {
            setError(RPNVaErrorEnumerableItemsTypeError);
            return;
        }
        
        if ( values[i] > values[maxIndex] )
        {
            maxIndex = i;
        }
    }
    
//    *this = values[maxIndex];
    operator=(values[maxIndex]);
}


void RPNValue::keys( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ == SWValueTypeHash )
    {
        if ( count == 0 )
        {
            RPNHashRef hash = (RPNHashRef)obj;
            int hashCount = RPNHashGetCount(hash);
            
            const RPNValue *keys[hashCount];
            RPNHashGetKeysAndValues(hash, keys, NULL);
            
            RPNArrayRef array = RPNArrayCreate(NULL, hashCount);
            RPNValue *ptr = RPNArrayGetValuesPtr(array);
            
            for ( int i=0 ; i<hashCount ; i++ )
            {
                ptr[i] = *(keys[i]);
            }
            
            RPNHashRelease((RPNHashRef)obj);
            obj = array;
            typ = SWValueTypeArray;
            return;
        }
        setNumArgumentsError() ;
        return ;
    }
    setTypeMError() ;
    return ;
}


void RPNValue::values( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ == SWValueTypeHash )
    {
        if ( count == 0 )
        {
            RPNHashRef hash = (RPNHashRef)obj;
            int hashCount = RPNHashGetCount(hash);
            
            const RPNValue *values[hashCount];
            RPNHashGetKeysAndValues(hash, NULL, values);
            
            RPNArrayRef array = RPNArrayCreate(NULL, hashCount);
            RPNValue *ptr = RPNArrayGetValuesPtr(array);
            
            for ( int i=0 ; i<hashCount ; i++ )
            {
                ptr[i] = *(values[i]);
            }
            
            RPNHashRelease((RPNHashRef)obj);
            obj = array;
            typ = SWValueTypeArray;
            return;
        }
        setNumArgumentsError() ;
        return ;
    }
    setTypeMError() ;
    return ;
}


// temps / data

void RPNValue::timeFormatter( const int msl, const unsigned int count, const RPNValue *args )
{
//    static CFDateFormatterRef staticDateFormatter;
//    static dispatch_once_t onceToken;
    
    if ( typ != SWValueTypeAbsoluteTime )
    {
        setTypeError() ;
        return ;
    }

    if ( count != 1 )
    {
        setNumArgumentsError() ;
        return ;
    }
    
    const RPNValue &arg0 = args[0] ;
    if ( arg0.typ == SWValueTypeString )
    {
        double absoluteTime = d - NSTimeIntervalSince1970;
        CFStringRef dateFormat = (CFStringRef)arg0.obj ;
    
//    	dispatch_once(&onceToken, ^{
//            staticDateFormatter = CFDateFormatterCreate( NULL, NULL, kCFDateFormatterNoStyle, kCFDateFormatterNoStyle );
//        });
//        
//        CFDateFormatterSetFormat( staticDateFormatter, dateFormat ) ;
//        obj = CFDateFormatterCreateStringWithAbsoluteTime(NULL, staticDateFormatter, absoluteTime);
        
        obj = createDateStringWithDateFormat_absoluteTime(dateFormat, absoluteTime);
        typ = SWValueTypeString ;
        return;
    }
    setArgumentsTypeError() ;
    return ;
}


void RPNValue::year( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ == SWValueTypeAbsoluteTime )
    {
        if ( count == 0 )
        {
            double absoluteTime = d - NSTimeIntervalSince1970;
            CFTimeZoneRef timeZone = CFTimeZoneCopySystem();
            CFGregorianDate gregDate = CFAbsoluteTimeGetGregorianDate(absoluteTime, timeZone);
            CFRelease(timeZone);
            d = gregDate.year;
            typ = SWValueTypeNumber;
            return;
        }
        setNumArgumentsError() ;
        return ;
    }
    setTypeMError() ;
    return ;
}


void RPNValue::month( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ == SWValueTypeAbsoluteTime )
    {
        if ( count == 0 )
        {
            double absoluteTime = d - NSTimeIntervalSince1970;
            CFTimeZoneRef timeZone = CFTimeZoneCopySystem();
            CFGregorianDate gregDate = CFAbsoluteTimeGetGregorianDate(absoluteTime, timeZone);
            CFRelease(timeZone);
            d = gregDate.month;
            typ = SWValueTypeNumber;
            return;
        }
        setNumArgumentsError() ;
        return ;
    }
    setTypeMError() ;
    return ;
}


void RPNValue::day( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ == SWValueTypeAbsoluteTime )
    {
        if ( count == 0 )
        {
            double absoluteTime = d - NSTimeIntervalSince1970;
            CFTimeZoneRef timeZone = CFTimeZoneCopySystem();
            CFGregorianDate gregDate = CFAbsoluteTimeGetGregorianDate(absoluteTime, timeZone);
            CFRelease(timeZone);
            d = gregDate.day;
            typ = SWValueTypeNumber;
            return;
        }
        setNumArgumentsError() ;
        return ;
    }
    setTypeMError() ;
    return ;
}


void RPNValue::wday( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ == SWValueTypeAbsoluteTime )
    {
        if ( count == 0 )
        {
            double absoluteTime = d - NSTimeIntervalSince1970;
            CFTimeZoneRef timeZone = CFTimeZoneCopySystem();
            SInt32 weekDay = CFAbsoluteTimeGetDayOfWeek(absoluteTime, timeZone);
            CFRelease(timeZone);
            d = (weekDay % 7);   // torna 1-7 per dilluns-diumenge, pero volem diumenge==0
            typ = SWValueTypeNumber;
            return;
        }
        setNumArgumentsError() ;
        return ;
    }
    setTypeMError() ;
    return ;
}


void RPNValue::yday( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ == SWValueTypeAbsoluteTime )
    {
        if ( count == 0 )
        {
            double absoluteTime = d - NSTimeIntervalSince1970;
            CFTimeZoneRef timeZone = CFTimeZoneCopySystem();
            SInt32 yearDay = CFAbsoluteTimeGetDayOfYear(absoluteTime, timeZone);
            CFRelease(timeZone);
            d = yearDay;
            typ = SWValueTypeNumber;
            return;
        }
        setNumArgumentsError() ;
        return ;
    }
    setTypeMError() ;
    return ;
}

void RPNValue::week( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ == SWValueTypeAbsoluteTime )
    {
        if ( count == 0 )
        {
            double absoluteTime = d - NSTimeIntervalSince1970;
            CFTimeZoneRef timeZone = CFTimeZoneCopySystem();
            SInt32 week = CFAbsoluteTimeGetWeekOfYear(absoluteTime, timeZone);
            CFRelease(timeZone);
            d = week;
            typ = SWValueTypeNumber;
            return;
        }
        setNumArgumentsError() ;
        return ;
    }
    setTypeMError() ;
    return ;
}


void RPNValue::hour( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ == SWValueTypeAbsoluteTime )
    {
        if ( count == 0 )
        {
            double absoluteTime = d - NSTimeIntervalSince1970;
            CFTimeZoneRef timeZone = CFTimeZoneCopySystem();
            CFGregorianDate gregDate = CFAbsoluteTimeGetGregorianDate(absoluteTime, timeZone);
            CFRelease(timeZone);
            d = gregDate.hour;
            typ = SWValueTypeNumber;
            return;
        }
        setNumArgumentsError() ;
        return ;
    }
    setTypeMError() ;
    return ;
}


void RPNValue::min( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ == SWValueTypeArray )
    {
        array_min(msl, count, args);
        return;
    }

    if ( typ == SWValueTypeAbsoluteTime )
    {
        if ( count == 0 )
        {
            double absoluteTime = d - NSTimeIntervalSince1970;
            CFTimeZoneRef timeZone = CFTimeZoneCopySystem();
            CFGregorianDate gregDate = CFAbsoluteTimeGetGregorianDate(absoluteTime, timeZone);
            CFRelease(timeZone);
            d = gregDate.minute;
            typ = SWValueTypeNumber;
            return;
        }
        setNumArgumentsError() ;
        return ;
    }
    setTypeMError() ;
    return ;
}

void RPNValue::sec( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ == SWValueTypeAbsoluteTime )
    {
        if ( count == 0 )
        {
            double absoluteTime = d - NSTimeIntervalSince1970;
            CFTimeZoneRef timeZone = CFTimeZoneCopySystem();
            CFGregorianDate gregDate = CFAbsoluteTimeGetGregorianDate(absoluteTime, timeZone);
            CFRelease(timeZone);
            d = gregDate.second;
            typ = SWValueTypeNumber;
            return;
        }
        setNumArgumentsError() ;
        return ;
    }
    setTypeMError() ;
    return ;
}



// funcions

void RPNValue::format( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ != SWValueTypeClassSelector || sel != RPNClSelRootClass )
    {
        setTypeMError() ;
        return ;
    }

    if ( count < 1 ) 
    {
        setNumArgumentsError() ;
        return ;
    }
    
    const RPNValue &arg0 = args[0] ;
    if ( arg0.typ == SWValueTypeString )
    {
        CFStringRef formatStr = (CFStringRef)arg0.obj ;
        CFStringRef resultStr = sprintfStringCreate( formatStr, count-1, args+1, NO ) ;
        obj = resultStr ;
        typ = SWValueTypeString ;
        return ;
    }
    setArgumentsTypeError() ;
    return ;
}

void RPNValue::rand( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ != SWValueTypeClassSelector || sel != RPNClSelRootClass )
    {
        setTypeMError() ;
        return ;
    }
    
    if ( count == 0 )
    {
        const double ARC4RANDOM_MAX = 0x100000000;
        typ = SWValueTypeNumber ;
        d = (double)arc4random()/ARC4RANDOM_MAX;
        return;
    }
    
    if ( count == 1 )
    {
        const RPNValue &arg0 = args[0] ;
        if ( arg0.typ == SWValueTypeNumber )
        {
            typ = SWValueTypeNumber;
            d = (arc4random() % toInt(arg0.d) );
            return;
        }
        setArgumentsTypeError() ;
        return ;
    }
    
    setNumArgumentsError() ;
    return ;
}


// Math

void RPNValue::mathPi( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ != SWValueTypeClassSelector )
    {
        setTypeMError() ;
        return ;
    }
    
    if ( count != 0 ) 
    {
        setNumArgumentsError() ;
        return ;
    }
    
    typ = SWValueTypeNumber ;
    d = M_PI ;
    return ;
}


void RPNValue::math1( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ != SWValueTypeClassSelector )
    {
        setTypeMError() ;
        return ;
    }

    if ( count != 1 ) 
    {
        setNumArgumentsError() ;
        return ;
    }
    
    const RPNValue &arg0 = args[0] ;
    if ( arg0.typ == SWValueTypeNumber )
    {
        CMathFunc1 f = (CMathFunc1)RPNMathMethods[msl].cfunct ;
        typ = SWValueTypeNumber ;
        d = f(arg0.d) ;
        return ;
    }
    setArgumentsTypeError() ;
    return ;
}


void RPNValue::math2( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ != SWValueTypeClassSelector )
    {
        setTypeMError() ;
        return ;
    }

    if ( count != 2 ) 
    {
        setNumArgumentsError() ;
        return ;
    }
    
    const RPNValue &arg0 = args[0] ;
    const RPNValue &arg1 = args[1] ;
    if ( arg0.typ == SWValueTypeNumber && arg1.typ == SWValueTypeNumber )
    {
        CMathFunc2 f = (CMathFunc2)RPNMathMethods[msl].cfunct ;
        typ = SWValueTypeNumber ;
        d = f(arg0.d,arg1.d) ;
        return ;
    }
    setArgumentsTypeError() ;
    return ;
}



// SM

void RPNValue::smLookup( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ != SWValueTypeClassSelector )
    {
        setTypeMError() ;
        return ;
    }

    if ( count != 1 ) 
    {
        setNumArgumentsError() ;
        return ;
    }
    
    const RPNValue &arg0 = args[0] ;
    if ( arg0.typ == SWValueTypeNumber )
    {
        //int key = toInt(arg0.d) ;
        ///CFStringRef str = (CFStringRef)[model() lookupValueForKey:key] ;     // elimitat per SM_IPAD
        //obj = CFRetain(str) ;                                                 // elimitat per SM_IPAD
        obj = CFSTR("not implemented SM_IPAD") ;                                // afegit per SM_IPAD
        
        typ = SWValueTypeString ;
        return ;
    }
    setArgumentsTypeError() ;
    return ;
}



void RPNValue::smError( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ != SWValueTypeClassSelector )
    {
        setTypeMError() ;
        return ;
    }

    if ( count != 0 )
    {
        setNumArgumentsError() ;
        return ;
    }
    
    setError( RPNVaErrorCodedWrongType);
    return;
}





void RPNValue::smDeviceId( const int msl, const unsigned int count, const RPNValue *args )
{
    NSString *uuidStr = nil;
    if ( typ != SWValueTypeClassSelector )
    {
        setTypeError() ;
        return ;
    }
    
    if ( count == 0 )
    {
        if ( uuidStr == nil )
        {
            NSUUID *uuid = [[UIDevice currentDevice] identifierForVendor];
            uuidStr = [uuid UUIDString];
        }
        obj = (CFStringRef)CFBridgingRetain(uuidStr);
        typ = SWValueTypeString;
        return;
    }
    
    setNumArgumentsError() ;
    return ;
}




void RPNValue::smColor( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ != SWValueTypeClassSelector )
    {
        setTypeMError() ;
        return ;
    }

    if ( count == 1 )
    {
        const RPNValue &arg0 = args[0] ;
        if ( arg0.typ == SWValueTypeString )
        {
            CFStringRef colorStr = (CFStringRef)arg0.obj ;
            CFIndex stringLength = CFStringGetLength( colorStr ) ;
            
            UInt8 bytes[stringLength+1] ;
            
            CFStringGetBytes(
                (CFStringRef)colorStr,      // the string
                CFRangeMake(0, stringLength),   // range 
                kCFStringEncodingASCII,   // encoding
                '?',                      // loss Byte
                false,                    // is external representation
                bytes,                    // buffer
                stringLength,             // max buff length
                NULL                      // out used buff length
            ) ;
            
            bytes[stringLength] = '\0' ;
            UInt32 rgbValue = getRgbValueForCName_len( bytes, stringLength ) ;
            rgbValue = SetTheme_toRgbColor(0,rgbValue) ;
            d = (double)rgbValue ;
            typ = SWValueTypeNumber ;
            return ;
        }
        setArgumentsTypeError() ;
        return ;
    }
    
    else if ( count == 3 )
    {
        const RPNValue &arg0 = args[0] ;
        const RPNValue &arg1 = args[1] ;
        const RPNValue &arg2 = args[2] ;
        if ( arg0.typ == SWValueTypeNumber && arg1.typ == SWValueTypeNumber && arg2.typ == SWValueTypeNumber )
        {
            UInt32 rgbValue = Theme_RGB(0, toInt(arg0.d), toInt(arg1.d), toInt(arg2.d)) ;
            d = (double)rgbValue ;
            typ = SWValueTypeNumber ;
            return ;
        }
        setArgumentsTypeError() ;
        return ;
    }
    
    else if ( count == 4 )
    {
        const RPNValue &arg0 = args[0] ;
        const RPNValue &arg1 = args[1] ;
        const RPNValue &arg2 = args[2] ;
        const RPNValue &arg3 = args[3] ;
        if ( arg0.typ == SWValueTypeNumber && arg1.typ == SWValueTypeNumber && 
            arg2.typ == SWValueTypeNumber && arg3.typ == SWValueTypeNumber)
        {
            //UInt32 rgbValue = Theme_RGB(0, toInt(arg0.d), toInt(arg1.d), toInt(arg2.d)) ;
            UInt32 rgbValue = Theme_RGBA(0, toInt(arg0.d), toInt(arg1.d), toInt(arg2.d), 127-toInt(arg3.d*127) ) ;
            d = (double)rgbValue ;
            typ = SWValueTypeNumber ;
            return ;
        }
        setArgumentsTypeError() ;
        return ;
    }
    
    setNumArgumentsError() ;
    return ;
}


void RPNValue::smPoint( const int msl, const unsigned int count, const RPNValue *args ) 
{
    if ( typ != SWValueTypeClassSelector )
    {
        setTypeMError();
        return;
    }
    
    if ( count == 2 )
    {
        const RPNValue &arg0 = args[0];
        const RPNValue &arg1 = args[1];
        if ( arg0.typ == SWValueTypeNumber && arg1.typ == SWValueTypeNumber )
        {
            CGPoint point = CGPointMake( arg0.d, arg1.d );
            RPNStructRef structv = RPNStructCreate( &point, sizeof(CGPoint) );
            typ = SWValueTypePoint;
            obj = structv;
            return;
        }
        setArgumentsTypeError();
    }
    setNumArgumentsError();
    return;
}


void RPNValue::smSize( const int msl, const unsigned int count, const RPNValue *args ) 
{
    if ( typ != SWValueTypeClassSelector )
    {
        setTypeMError();
        return;
    }
    
    if ( count == 2 )
    {
        const RPNValue &arg0 = args[0] ;
        const RPNValue &arg1 = args[1] ;
        if ( arg0.typ == SWValueTypeNumber && arg1.typ == SWValueTypeNumber )
        {
            CGSize size = CGSizeMake( arg0.d, arg1.d );
            RPNStructRef structv = RPNStructCreate( &size, sizeof(CGSize) );
            typ = SWValueTypeSize;
            obj = structv;
            return;
        }
        setArgumentsTypeError();
        return;
    }
    setNumArgumentsError();
    return;
}


void RPNValue::smRect( const int msl, const unsigned int count, const RPNValue *args ) 
{
    if ( typ != SWValueTypeClassSelector )
    {
        setTypeMError();
        return;
    }
    
    if ( count == 4 )
    {
        const RPNValue &arg0 = args[0];
        const RPNValue &arg1 = args[1];
        const RPNValue &arg2 = args[2];
        const RPNValue &arg3 = args[3];
        if ( arg0.typ == SWValueTypeNumber && arg1.typ == SWValueTypeNumber && 
            arg2.typ == SWValueTypeNumber && arg3.typ == SWValueTypeNumber)
        {
            CGRect rect = CGRectMake( arg0.d, arg1.d, arg2.d, arg3.d );
            RPNStructRef structv = RPNStructCreate( &rect, sizeof(CGRect) );
            typ = SWValueTypeRect;
            obj = structv;
            return;
        }
        setArgumentsTypeError();
        return;
    }
    setNumArgumentsError();
    return;
}


void RPNValue::smAllFonts( const int msl, const unsigned int count, const RPNValue *args )
{
    static RPNArrayRef rpnAllFonts;
    static dispatch_once_t onceToken;
    
    if ( typ != SWValueTypeClassSelector )
    {
        setTypeMError();
        return;
    }
    
    if ( count == 0 )
    {
        dispatch_once(&onceToken, ^
        {
            NSArray *allFonts = [UIFont allFonts];
            int fontsCount = allFonts.count;
            
            rpnAllFonts = RPNArrayCreate( NULL, fontsCount );
            RPNValue *values = RPNArrayGetValuesPtr(rpnAllFonts);
            
            for ( int i=0 ; i<fontsCount ; i++ )
            {
                values[i].typ = SWValueTypeString;
                values[i].obj = CFBridgingRetain([allFonts objectAtIndex:i]);
            }
        });
        
        typ = SWValueTypeArray;
        obj = CFRetain(rpnAllFonts);
        return;
    }
    setNumArgumentsError();
    return;
}


void RPNValue::smAllColors( const int msl, const unsigned int count, const RPNValue *args )
{
    static RPNArrayRef rpnAllColors;
    static dispatch_once_t onceToken;
    
    if ( typ != SWValueTypeClassSelector )
    {
        setTypeMError();
        return;
    }
    
    if ( count == 0 )
    {
        dispatch_once(&onceToken, ^
        {
            NSArray *allColors = getAllColorStr();
            int colorsCount = allColors.count;
            
            rpnAllColors = RPNArrayCreate( NULL, colorsCount );
            RPNValue *values = RPNArrayGetValuesPtr(rpnAllColors);
            
            for ( int i=0 ; i<colorsCount ; i++ )
            {
                values[i].typ = SWValueTypeString;
                values[i].obj = CFBridgingRetain([allColors objectAtIndex:i]);
            }
        });
        
        typ = SWValueTypeArray;
        obj = CFRetain(rpnAllColors);
        return;
    }
    setNumArgumentsError();
    return;
}


void RPNValue::smEncrypt( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ != SWValueTypeClassSelector )
    {
        setTypeMError();
        return;
    }
    
    if ( count == 2 )
    {
        const RPNValue &arg0 = args[0];
        const RPNValue &arg1 = args[1];
        if ( arg0.typ == SWValueTypeString && arg1.typ == SWValueTypeString)
        {
            NSString *theString = (__bridge id)arg0.obj;
            NSString *key = (__bridge id)arg1.obj;
            
            NSData *theData = [theString dataUsingEncoding:NSUTF8StringEncoding];
            if ( theData != nil )
            {
                NSData *encryptedData = [theData AES256EncryptedDataUsingKey:key error:nil];
                if ( encryptedData != nil)
                {
                    NSString *result = [encryptedData base64EncodedStringWithOptions:0];
                    typ = SWValueTypeString;
                    obj = CFBridgingRetain(result);
                    return;
                }
            }
            typ = SWValueTypeString;
            obj = (CFStringRef)CFRetain(CFSTR("") ) ;
            return;
        }
        setArgumentsTypeError();
        return;
    }
    setNumArgumentsError();
    return;
}


void RPNValue::smDecrypt( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ != SWValueTypeClassSelector )
    {
        setTypeMError();
        return;
    }
    
    if ( count == 2 )
    {
        const RPNValue &arg0 = args[0];
        const RPNValue &arg1 = args[1];
        if ( arg0.typ == SWValueTypeString && arg1.typ == SWValueTypeString)
        {
            NSString *the64String = (__bridge id)arg0.obj;
            NSString *key = (__bridge id)arg1.obj;
            
            NSData *encryptedData = [[NSData alloc] initWithBase64EncodedString:the64String options:0];
            if ( encryptedData != nil )
            {
                NSData *theData = [encryptedData decryptedAES256DataUsingKey:key error:nil];
                if ( theData != nil)
                {
                    NSString *result = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
                    typ = SWValueTypeString;
                    obj = CFBridgingRetain(result);
                    return;
                }
            }
            typ = SWValueTypeString;
            obj = (CFStringRef)CFRetain(CFSTR("") ) ;
            return;
        }
        setArgumentsTypeError();
        return;
    }
    setNumArgumentsError();
    return;
}


void RPNValue::smMkTime( const int msl, const unsigned int count, const RPNValue *args )
{
    if ( typ != SWValueTypeClassSelector )
    {
        setTypeMError();
        return;
    }
    
    BOOL valid = NO;
    int year   = ( count > 0 && (valid = (args[0].typ==SWValueTypeNumber)) ? args[0].d : 9999 );
    int month  = ( count > 1 && (valid = (args[1].typ==SWValueTypeNumber)) ? args[1].d : 1 );
    int day    = ( count > 2 && (valid = (args[2].typ==SWValueTypeNumber)) ? args[2].d : 1 );
    int hour   = ( count > 3 && (valid = (args[3].typ==SWValueTypeNumber)) ? args[3].d : 0 );
    int minute = ( count > 4 && (valid = (args[4].typ==SWValueTypeNumber)) ? args[4].d : 0 );
    int second = ( count > 5 && (valid = (args[5].typ==SWValueTypeNumber)) ? args[5].d : 0 );
    
    if ( valid )
    {
        CFAbsoluteTime absoluteTime = 0;
        CFCalendarRef gregorian = CFCalendarCreateWithIdentifier(NULL, kCFGregorianCalendar);
        valid = CFCalendarComposeAbsoluteTime(gregorian, &absoluteTime, "yMdHms", year, month, day, hour, minute, second);
        CFRelease(gregorian);

        if ( valid )
        {
            typ = SWValueTypeAbsoluteTime;
            d = absoluteTime + NSTimeIntervalSince1970;
            return;
        }
        setError(RPNVaErrorArgumentsType);
        return;
    }
    setArgumentsTypeError();
    return;
}


