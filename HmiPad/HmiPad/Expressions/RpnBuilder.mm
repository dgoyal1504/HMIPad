//
//  RpnBuilder.m
//  HmiPad_101114
//
//  Created by Joan on 15/11/10.
//  Copyright 2010 SweetWilliam, S.L. All rights reserved.
//

#import "RpnBuilder.h"
#import "RPNValue.h" 
#import "RpnInterpreter.h"
#import "SWExpression.h"
#import "PrimitiveParser.h"




//////////////////////////////////////////////////////////////////////////////////////
#pragma mark SimbolicTable
//////////////////////////////////////////////////////////////////////////////////////
@interface SymbolicTable : NSObject  // <QuickCoding>

{
    CFMutableDictionaryRef symbolsDict ;
    CFMutableArrayRef symbolsTable ;  // conté objectes _SymbolicSource
    CFDataRef infoBits ;    // (no es codifica)
    CFIndex symbolsCount ;
}

- (CFIndex)symbolsCount ;
- (CFMutableArrayRef)symbolsTable ;
- (CFDataRef)infoBits ;
- (CFIndex)registerSymbol:(SymbolicSource*)symbol infoBit:(BOOL)infoBit ;
- (void)commitTable ;
- (void)clear ;

@end




//------------------------------------------------------------------------------------------
@implementation SymbolicTable


//------------------------------------------------------------------------------------------
- (id)init
{
    if ( ( self = [super init]) )
    {
    }
    return self ;
}


//------------------------------------------------------------------------------------------
- (CFDictionaryRef)symbolsDict
{
    return symbolsDict ;
}

- (CFMutableArrayRef)symbolsTable
{
    return symbolsTable ;
}

- (CFDataRef)infoBits
{
    return infoBits ;
}

- (CFIndex)symbolsCount
{
    CFIndex count = 0 ;
    if ( symbolsTable ) count = CFArrayGetCount( symbolsTable ) ;
    return count ;
}

//------------------------------------------------------------------------------------------
- (void)dealloc
{
    if ( symbolsDict) CFRelease( symbolsDict ) ;
    if ( symbolsTable ) CFRelease( symbolsTable ) ;
    if ( infoBits ) CFRelease( infoBits ) ;
    // ARC [super dealloc] ;
}


//-------------------------------------------------------------------------------------------
typedef struct
{
    SymbolicSource * __strong *s ;
    UInt8 *b ;
} ContextInfoStruct ;

static void symbolsApplierFunc( const void *key, const void *value, void *context )
{
    SymbolicSource *symbol = (__bridge SymbolicSource*)key ;
    CFIndex indx = ((long)value)>>1 ;
    ContextInfoStruct *contextInfo = (ContextInfoStruct *)context ;
    (contextInfo->s)[indx] = symbol ;
    (contextInfo->b)[indx] = ((long)value)&1 ;
}

static Boolean equalCallBack (const void *value1, const void *value2 )
{
    const SymbolicSource *c1 = (__bridge const SymbolicSource*)value1 ;
    const SymbolicSource *c2 = (__bridge const SymbolicSource*)value2 ;
    BOOL equal = [c1->symObject isEqualToString:c2->symObject] &&
                 [c1->symProperty isEqualToString:c2->symProperty] ;
    return equal ;
    //return CFEqual( c1->symObject, c2->symObject ) && CFEqual( c1->symProperty, c2->symProperty ) ;
}

static CFHashCode hashCallBack( const void *value )
{
    const SymbolicSource *c1 = (__bridge const SymbolicSource*)value ;
    return [c1->symObject hash] ;
    //return [c1->symObject hash] ;
}


//------------------------------------------------------------------------------------------
- (CFIndex)registerSymbol:(SymbolicSource *)symbol infoBit:(BOOL)infoBit
{
    if ( symbolsDict == NULL )
    {
        const CFDictionaryKeyCallBacks keyCallBacks = 
        { 
            0, 
            kCFTypeDictionaryKeyCallBacks.retain, 
            kCFTypeDictionaryKeyCallBacks.release, 
            kCFTypeDictionaryKeyCallBacks.copyDescription, 
            equalCallBack, 
            hashCallBack 
        } ;
        symbolsDict = CFDictionaryCreateMutable(NULL, 0, &keyCallBacks, NULL) ;
        symbolsCount = 0 ;
    }
    
    const void *value ;
    if ( NO == CFDictionaryGetValueIfPresent( symbolsDict, (__bridge const void*)symbol, &value ) )
    { 
        // not present
        if ( symbolsCount > 254 ) return -1 ;   // maxim de simbols en una expressio
        value = (void*)((symbolsCount<<1) | infoBit ) ;
        symbolsCount++ ;
        CFDictionaryAddValue( symbolsDict, (__bridge CFTypeRef)symbol, value ) ;
    }
    else
    {
        // present
        if ( infoBit == 0 && ((CFIndex)value & 1) )
        {
            value = (void*)((CFIndex)value & ~0x1) ;  // posa el ultim bit a zero
            CFDictionarySetValue( symbolsDict, (__bridge CFTypeRef)symbol, value ) ;
        }
    }
    return (CFIndex)(value) >> 1 ;
}


//------------------------------------------------------------------------------------------
- (void)commitTable
{
    if ( symbolsDict == NULL ) return ;
    
    CFIndex symbolCnt = CFDictionaryGetCount( symbolsDict ) ;   // symbolCnt hauria de coincidir amb symbolCount en aquest punt
    NSAssert ( symbolsCount == symbolCnt, @"symbolCount no es igual que el numero de simbols en el diccionari" ) ;
    if ( symbolCnt > 0 )
    {
        //CFStringRef cArray[symbolCnt] ;
        SymbolicSource *cArray[symbolCnt] ;
        UInt8 bArray[symbolCnt] ;
        ContextInfoStruct contextInfo = { cArray, bArray } ;
    
        CFDictionaryApplyFunction( symbolsDict, symbolsApplierFunc, &contextInfo ) ;
        symbolsTable = CFArrayCreateMutable(NULL, symbolCnt, &kCFTypeArrayCallBacks) ;
        for ( int i=0; i<symbolCnt ; i++ ) 
        {
            //CFStringRef str = cArray[i] ;
            //NSLog( @"%@", str ) ;
            CFArrayAppendValue( symbolsTable, (__bridge CFTypeRef)cArray[i] ) ;  // l'array ha de ser mutable
        }
        
        infoBits = CFDataCreate(NULL, bArray, symbolCnt) ;
        
        CFDictionaryRemoveAllValues( symbolsDict ) ;
        symbolsCount = 0 ;
    }
}


//------------------------------------------------------------------------------------------
- (void)clear
{
    symbolsCount = 0 ;
    if ( symbolsDict ) CFDictionaryRemoveAllValues( symbolsDict ) ;
    if ( symbolsTable ) CFRelease( symbolsTable ), symbolsTable = NULL ;  // no poder fer removeValues perque el array s'utilitza en altres llocs
    if ( infoBits ) CFRelease( infoBits ), infoBits = NULL ;
}



////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark protocol QuickCoder
////////////////////////////////////////////////////////////////////////////////////////////


//------------------------------------------------------------------------------------------
- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super init] ;
    // decodifiquem les string constants
    int count = [decoder decodeInt] ;
    if ( count > 0 )
    {
        symbolsTable = CFArrayCreateMutable(NULL, count, &kCFTypeArrayCallBacks) ;
        for ( int i=0 ; i<count ; i++ )
        {
            SymbolicSource *symbol = [decoder decodeObject] ;  // retingut per el array
            CFArrayAppendValue(symbolsTable, (__bridge CFTypeRef)symbol) ;
        }
    }
    return self ;
}


//------------------------------------------------------------------------------------------
- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
{
    //[super encodeWithCoder:encoder] commented out because NSObject does not implement NSCoding
    // codifiquem els constantStrings
    if ( symbolsTable )
    {
        // codifiquem el numero de items i el contingut de symbols
        int count = (int)CFArrayGetCount(symbolsTable) ;
        [encoder encodeInt:count] ;
        for ( int i=0 ; i<count ; i++ )
        {
            __unsafe_unretained SymbolicSource *symbol = (__bridge id)CFArrayGetValueAtIndex(symbolsTable, i) ;
            [encoder encodeObject:symbol] ;
        }
    }
    else
    {
        [encoder encodeInt:0] ;
    }
}

@end



//////////////////////////////////////////////////////////////////////////////////////
#pragma mark  RpnBuilder
//////////////////////////////////////////////////////////////////////////////////////


typedef enum
{
    RpnBuilderCommitTypeNone,
    RpnBuilderCommitTypeNormal,
    RpnBuilderCommitTypeWithMoveToLocal,
} RpnBuilderCommitType;






//------------------------------------------------------------------------------------
@interface RpnBuilder()
{
    RpnBuilderCommitType commitType;
}

- (BOOL)expression ;

@end


//------------------------------------------------------------------------------------
@implementation RpnBuilder


//////////////////////////////////////////////////////////////////////////////////////
#pragma mark  Generacio de codi
//////////////////////////////////////////////////////////////////////////////////////

#define DATA_INITIAL_LENGTH 32
#define DATA_LENGTH_INCREMENT 256

//------------------------------------------------------------------------------------
- (void)increaseDataLength:(CFIndex)size
{
    CFIndex increment = (size/DATA_LENGTH_INCREMENT + 1)*DATA_LENGTH_INCREMENT;
    
    size_t offset = p - CFDataGetMutableBytePtr( data ) ;
    CFDataIncreaseLength( data, increment ) ;
    
    UInt8* begin = CFDataGetMutableBytePtr( data ) ;
    p = begin + offset ;
    max = begin + CFDataGetLength( data ) ;
}


//-------------------------------------------------------------------------------------------
#define _guardBytes(size) if (p+(size) > max) [self increaseDataLength:size]


//-------------------------------------------------------------------------------------------
#define _genBytes(bytes,length) \
{ \
    _guardBytes(length) ; \
    memcpy( p, (bytes), (length) ) ; \
    p += (length) ; \
}


//-------------------------------------------------------------------------------------------
#define _genScalar(type,value) \
{ \
    _guardBytes(sizeof(type)) ; \
    *(type*)p = (value) ; \
    p += sizeof(type) ; \
}


//-------------------------------------------------------------------------------------------
#define _genValue(value) \
{ \
    _guardBytes(sizeof(value)) ; \
    memcpy( p, &(value), sizeof(value) ) ; \
    p += sizeof(value) ; \
}

//-------------------------------------------------------------------------------------------
#define _genOpCode(value) _genScalar(UInt8,value)


//------------------------------------------------------------------------------------
- (void)increaseDataSLength:(CFIndex)size
{
    CFIndex increment = (size/DATA_LENGTH_INCREMENT + 1)*DATA_LENGTH_INCREMENT;

    UInt8 *begin = CFDataGetMutableBytePtr( dataS ) ;
    size_t offset = pS - begin ;
    size_t offsetP = ppS - begin ;
    CFDataIncreaseLength( dataS, increment /*DATA_LENGTH_INCREMENT*/ ) ;
    
    begin = CFDataGetMutableBytePtr( dataS ) ;
    pS = begin + offset ;
    ppS = begin + offsetP ;
    maxS = begin + CFDataGetLength( dataS ) ;
}


//-------------------------------------------------------------------------------------------
#define _guardBytesS(size) if (pS+(size) > maxS) [self increaseDataSLength:size]


//-------------------------------------------------------------------------------------------
#define _genBytesS(bytes,length) \
{ \
    _guardBytesS(length) ; \
    *(UInt16*)ppS = (length) ; \
    memcpy( pS, (bytes), (length) ) ; \
    pS += (length) ; \
}



//-------------------------------------------------------------------------------------------
//#define _genBytesS(bytes,length) \
//{ \
//    _guardBytesS(length) ; \
//    *(UInt16*)ppS = (length) ; \
//    memcpy( pS, (bytes), (length) ) ; \
//    pS += (length) ; \
//}





//-------------------------------------------------------------------------------------------
#define _genSPlaceholder(var) \
{ \
    _guardBytesS(sizeof(UInt8)+sizeof(UInt16)) ; \
    *(UInt8*)pS = (var) ; \
    pS += sizeof(UInt8) ; \
    ppS = pS ; \
    *(UInt16*)pS = 0 ; \
    pS += sizeof(UInt16) ; \
}


/////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark  Creacio/Destruccio
/////////////////////////////////////////////////////////////////////////////////////////////

//-------------------------------------------------------------------------------------------
- (id)init
{
    if ( (self = [super init]) )
    {
        expressions = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks) ; // retenim les expressions
        //localTable = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, NULL ) ; // nomes retenim la clau no retenim els holders
        globalTable = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, NULL ) ; // nomes retenim la clau no retenim els holders
        systemTable = nil ;
    }
    return self ;
}


//-------------------------------------------------------------------------------------------
- (void)setSystemTable:(CFDictionaryRef)table
{
    if ( table != systemTable )
    {
        if ( systemTable ) CFRelease( systemTable ) ;
        if ( table ) CFRetain( table ) ;
        systemTable = table ;
    }
}


//-------------------------------------------------------------------------------------------
- (void)dealloc
{
    if ( expressions ) CFRelease( expressions ) ;
    if ( localTables ) CFRelease( localTables ) ;
//    if ( localTableKeys ) CFRelease( localTableKeys ) ;
//    if ( localTableValues ) CFRelease( localTableValues ) ;
    if ( localTable ) CFRelease( localTable ) ;
    if ( globalTable ) CFRelease( globalTable ) ;
    if ( systemTable ) CFRelease( systemTable ) ;
    if ( methodSelectors ) CFRelease( methodSelectors ) ;
    if ( classSelectors ) CFRelease( classSelectors ) ;
    if ( methodSelectorDictionaries ) CFRelease( methodSelectorDictionaries ) ;
    // ARC if ( symbols ) CFRelease( symbols ) ;
    if ( constStrings ) CFRelease( constStrings ) ;
    if ( data ) CFRelease( data ) ;
    if ( dataS ) CFRelease( dataS ) ;
    // ARC [super dealloc] ;
}


//-------------------------------------------------------------------------------------------
- (int)selectorForClass:(CFStringRef)name
{
    // Generem un diccionari per els noms de les clases amb els seus selectors.
    // Aquest métode es podria implementar en torn de RPNValue::selectorForClass pero per motius de generacio de codi
    // volem que la busqueda sigui case sensitive, i se suposa que accedir a un diccionari es més eficient

    if ( classSelectors == NULL ) 
    {
        CFStringRef keys[RPNClassesCount] ;
        long values[RPNClassesCount] ;
        
        for ( int i=0 ; i<RPNClassesCount ; i++ )
        {
            keys[i] = RPNClasses[i].name ;
            values[i] = i ;
        }
        classSelectors = CFDictionaryCreate(NULL, (const void**)keys, (const void**)values, 
                        RPNClassesCount, &kCFTypeDictionaryKeyCallBacks, NULL) ;
    }

    const void *sel ;
    if ( CFDictionaryGetValueIfPresent(classSelectors, name, &sel) ) 
    {
        return (int)(long)sel ;
    }
    
    return -1 ;
}




//-------------------------------------------------------------------------------------------
- (int)selectorForMethod:(CFStringRef)name inClassWithSelector:(int)clSel
{
    // Generem un array de diccionaris per els noms dels metodes de cada clase amb els seus selectors.
    // Aquest métode es podria implementar en torn de RPNValue::selectorForMethod_inClassWithSelector
    // pero per motius de generacio de codi volem que la busqueda sigui case sensitive,
    // i se suposa que accedir a un diccionari es més eficient

    CFDictionaryRef methodSels ;
    if ( clSel != RPNClSelGenericClass )
    {
        // si el array de metodes no hi es crearlo ple de kCFNulls de longitud RPNClassesCount
        if ( methodSelectorDictionaries == NULL )
        {
            methodSelectorDictionaries = CFArrayCreateMutable( NULL, RPNClassesCount, &kCFTypeArrayCallBacks ) ;
            for ( CFIndex i=0 ; i<RPNClassesCount ; i++ ) CFArrayAppendValue( methodSelectorDictionaries, kCFNull ) ;
        }
    
        // si per el selector de la clase el array te un kCFNull crear un dictionari de metodes i posarlo al array
        methodSels = (CFDictionaryRef)CFArrayGetValueAtIndex( methodSelectorDictionaries, clSel ) ;
    }
    else
    {
        // si clSel es RPNClSelGenericClass optimizem la peticio tornant metodes de la clase amb selector zero
        methodSels = methodSelectors ;
    }
    
    // si per el selector de la clase el array te un kCFNull crear un dictionari de metodes i posarlo al array
    if ( methodSels == NULL || methodSels == (void *)kCFNull )
    {
        CFIndex methodCount = RPNClasses[clSel].methodCount ;
        const RPNMethodsStruct *methods = RPNClasses[clSel].methods ;
    
        CFStringRef keys[methodCount] ;
        long values[methodCount] ;
        
        for ( int i=0 ; i<methodCount ; i++ )
        {
            keys[i] = methods[i].name ;
            values[i] = i ;
        }
        methodSels = CFDictionaryCreate(NULL, (const void**)keys, (const void**)values, methodCount, &kCFTypeDictionaryKeyCallBacks, NULL) ;
        
        if ( clSel != RPNClSelGenericClass )
        {
            CFArraySetValueAtIndex( methodSelectorDictionaries, clSel, methodSels ) ;
            CFRelease( methodSels ) ;
        }
        else
        {
            methodSelectors = methodSels ;
        }
    }
    
    // tornar el valor del dictionari en el lloc del selector de la clase.
    const void *sel = NULL;
    if ( CFDictionaryGetValueIfPresent( methodSels, name, &sel ) ) 
    {
        return (int)(long)sel ;
    }
    
    return -1 ;
}


/////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark  Parseig
/////////////////////////////////////////////////////////////////////////////////////////////

//-------------------------------------------------------------------------------------------
- (void)error:(ExpressionErrorCode)code
{
    // nomes apuntem el primer que trobem
    if ( errCode != 0 ) return ;
    
    errCode = code ;
    errInfo.sourceOffset = c - beg ; // podem utilitzar aquest offset perque en cas d'error el source string no contindra informacio simbolica
}


//-------------------------------------------------------------------------------------------
// left to right generation (lineal)
// si no ha trobat cap expressio actCount no es modifica
// actCount conte el nombre d'arguments bons que ha trobat encara que el resultat sigui false
- (BOOL)argumentListWithMaxCount:(unsigned int)maxCount outActualCount:(unsigned int*)actCount
{
    if ( [self expression] )
    {
        *actCount = 1 ;
        while( *actCount < maxCount )
        {
            _skip
            if ( _parseChar( ',' ) )
            {
                _skip ;
                if ( [self expression] ) 
                {
                    *actCount += 1 ;
                    continue ;
                }
                else return NO ;
            }
            break ;
        }
        return YES ;
    }
    return NO ;
}


//-------------------------------------------------------------------------------------------
- (BOOL)hashPair
{
    if ( [self expression] )
    {
        _skip;
        if ( _parseChar(':') || _parseCString("=>", 2) )
        {
            _skip;
            if ( [self expression] )
            {
                return YES;
            }
        }
    }
    return NO;
}





//-------------------------------------------------------------------------------------------
// left to right generation (lineal)
// si no ha trobat cap expressio actCount no es modifica
// actCount conte el nombre de parelles bons que ha trobat encara que el resultat sigui false
- (BOOL)hashArgumentListWithMaxCount:(unsigned int)maxCount outActualCount:(unsigned int*)actCount
{
    if ( [self hashPair] )
    {
        *actCount = 2 ;
        while( *actCount < maxCount )
        {
            _skip;
            if ( _parseChar( ',' ) )
            {
                _skip ;
                if ( [self hashPair] )
                {
                    *actCount += 2 ;
                    continue ;
                }
                else return NO ;
            }
            break ;
        }
        return YES ;
    }
    return NO ;
}


//-------------------------------------------------------------------------------------------
// 
//- (BOOL) _genFunctionAndArguments:(unsigned char *)cstr len:(size_t)len
- (BOOL)functionArgumentsWithClSel:(int)clSel withMeSel:(int)meSel
{
    unsigned int count = 0 ;
    if ( _parseChar( '(' ) )
    {
        _skip ;
        if ( _parseChar( ')' ) )
        {
            // vale no arguments ;
        }
        else if ( [self argumentListWithMaxCount:255 outActualCount:&count] )
        {
            _skip ;
            if ( _parseChar( ')' ) )
            {
                // vale ;
            }
            else
            {
                [self error:ExpressionErrorCodeMissingTrailingBracket1] ;
                return NO ;
            }
        }
        else 
        {
            [self error:ExpressionErrorCodeTooManyArguments] ;
            return NO ; // error en els arguments
        }
    }
    
    classSelector = RPNClSelGenericClass ;
    _genOpCode( RpnCallFunct ) ;
    _genScalar( UInt16, count ) ;   // arguments count
    _genScalar( UInt16, clSel ) ;   // class selector
    _genScalar( UInt16, meSel ) ;   // method selector
    return YES ;
}


//-------------------------------------------------------------------------------------------    
// Genera el codi per accedir a un simbol per index
// Atencio que no copiem els bytes per posarlos al diccionari, per tant el simbol sera valid nomes mentre els source bytes siguin valids, 
// es per això que durant el commit d'expressions, els symbols que no s'han comitat s'han de convertir a inmutables,
// veure [expression commitUsingLocalSymbol...]
- (BOOL)_genVarWithSymObject:(CFStringRef)symObject symProperty:(CFStringRef)symProperty
{
    SymbolicSource *symbol = [[SymbolicSource alloc] init] ;
    symbol->symObject = (__bridge id)symObject ;
    symbol->symProperty = (__bridge id)symProperty ;

    //[symbol setSymObject:(__bridge id)symObject] ;
    //[symbol setSymProperty:(__bridge id)symProperty] ;

    CFIndex value = [symbols registerSymbol:symbol infoBit:skipDependencies] ;
    // ARC [symbol release] ;
    
    if ( value == -1 ) 
    {
        [self error:ExpressionErrorCodeTooManySources] ;
        return NO ;
    }
    
    classSelector = RPNClSelGenericClass ;     // ATENCIO aqui posar un tipus de selector que implica variable
    _genOpCode( RpnVarLd ) ;
    _genScalar( UInt8, (int)value ) ;
    
    _genSPlaceholder(value) ;
    //cS = c ;
    
    return YES ;
}


//-------------------------------------------------------------------------------------------
// left to right generation (lineal)
- (BOOL)restIndexIndirection
{
    unsigned int count = 0 ;
    if ( [self argumentListWithMaxCount:2 outActualCount:&count] )
    {
        _skip ;
        if ( _parseChar( ']' ) )
        {
            classSelector = RPNClSelGenericClass ;
            _genOpCode( RpnGetElement )  ;
            _genScalar( UInt16, count ) ;
            return YES ;
        }
        else [self error:ExpressionErrorCodeMissingTrailingSqBracket1] ;
    }
    
    return NO ;
}


//-------------------------------------------------------------------------------------------
// left to right generation (lineal)
- (BOOL)restDotIndirectionWithSymObject:(CFStringRef)symObject
{

    // en un futur, en aquest punt hauria de saber el tipus d'objecte que hi haura en el stack d'execucio
    // per determinar el selector rellevant (metode o propietat) depenent de l'objecte, sense interferir en altres
    // per ara tots els selectors son generals
    
    const unsigned char *cstr ;
    size_t len ;
    if ( [self parseToken:&cstr length:&len] )
    {
        BOOL result = YES ;
        CFStringRef dotSymbol = CFStringCreateWithBytesNoCopy(NULL, cstr, len, kCFStringEncodingASCII, // tokens son ASCII
                false, kCFAllocatorNull) ;  
        int funcSelector = [self selectorForMethod:dotSymbol inClassWithSelector:classSelector] ;
        
        if ( symObject ) // si hi ha un simbol pendent el generem ara
        {
            CFStringRef symProperty = dotSymbol ;
            if ( funcSelector >= 0 ) symProperty = NULL ;
            
            if ( symProperty ) cS = c ;
            result = [self _genVarWithSymObject:symObject symProperty:symProperty]  ;
        }
        
        if ( funcSelector >= 0 ) // si es un nom de funcio
        {
            _skip ;
            result = [self functionArgumentsWithClSel:classSelector withMeSel:funcSelector] ;
        }
//        else if ( symObject == nil )
//        {
//            [self error:ExpressionErrorCodeUnknownMethodIdentifier] ; 
//            result = NO ;
//        }
        
        if ( symObject == nil && funcSelector < 0 )
        {
            [self error:ExpressionErrorCodeUnknownMethodIdentifier] ; 
            result = NO ;
        }
        
        if ( dotSymbol ) CFRelease( dotSymbol ) ;
        return result ;
    }
    else
    {
        [self error:ExpressionErrorCodeExpectedPropertyOrMethodIdentifier] ;
    }
    return NO ;
}


//-------------------------------------------------------------------------------------------

- (BOOL)varAndDotIndirectionWithSymObject:(CFStringRef)symbol
{
    BOOL result = YES ;
    //if ( _parseChar( '.' ) )
    if ( _parseExclusiveChar( '.' ) )
    {
        _skip ;
        result = [self restDotIndirectionWithSymObject:symbol] ;
    }
    else
    {
        result = [self _genVarWithSymObject:symbol symProperty:NULL] ;
    }
    return result ;
}


//-------------------------------------------------------------------------------------------
// left to right generation (lineal)
- (BOOL)indirection
{
    while ( 1 )
    {
        _skip ;
        if ( _parseChar( '[' ) )
        {
            _skip ;
            if ( [self restIndexIndirection] )
            {
                // vale
            }
            else return NO ;
        }
        
        //else if ( _parseChar( '.' ) )
        else if ( _parseExclusiveChar( '.' ) )
        {
            if ( [self restDotIndirectionWithSymObject:NULL] )
            {
                // vale
            }
            else return NO ;
        } 
    
        else 
        {
            break ;
        }
        
    } // end while
    
    return YES ;
}


//-------------------------------------------------------------------------------------------
// left to right generation (lineal)
// les variables poden tenir punts, si el ultim es una funcio generem el codi aqui mateix
- (BOOL)simbolicToken
{
    const unsigned char *cstr ;
    size_t len ;
    BOOL result = YES ;
    if ( [self parseToken:&cstr length:&len] )
    {
        CFStringRef symObject = CFStringCreateWithBytesNoCopy(NULL, cstr, len, kCFStringEncodingASCII, false, kCFAllocatorNull) ;  // tokens son ASCII
        
        // primer mirem si es una clase identificable per nom ( ex: Math, SM )
        int clSel = [self selectorForClass:symObject] ;   
        if ( clSel >= 0 )
        {
            classSelector = clSel ;
            _genOpCode(RpnClassLd) ;   // cridarem el metode de una clase, posem la clase
            _genScalar( UInt16, clSel ) ;
        }
        else
        {
            // si no mirem si es una funcio de la RPNClSelRootClass ( ex: format )
            int funcSelector = [self selectorForMethod:symObject inClassWithSelector:RPNClSelRootClass] ;
            if ( funcSelector >= 0 )
            {
                classSelector = RPNClSelRootClass ;
                _genOpCode(RpnClassLd) ;  // cridarem una funcio generica, posem la clase funcio generica
                _genScalar( UInt16, RPNClSelRootClass ) ;
                _skip ;
                result = [self functionArgumentsWithClSel:classSelector withMeSel:funcSelector] ;
            }
            
            // si no, es una variable
            else
            {
                _genBytesS( cS, cstr-cS  ) ;
                cS = c ;  // tentativament
                _skip ;
                result = [self varAndDotIndirectionWithSymObject:symObject] ;
            }
        }
        
        if ( symObject ) CFRelease( symObject ) ;
        if ( result ) return YES ;
    }
    return NO ;
}


////-------------------------------------------------------------------------------------------
//// left to right generation (lineal)   // ATENCIO NO S'UTILITZA
//- (BOOL)restEmbeddedTagV
//{
//    const unsigned char *cstr ;
//    size_t len ;
//    if ( [self parseToken:&cstr length:&len] )
//    {
//        _skip ;
//        if ( _parseChar( '}' ) )
//        {
//            CFStringRef symObject = CFStringCreateWithBytesNoCopy(NULL, cstr, len, kCFStringEncodingASCII, false, kCFAllocatorNull) ;
//            
//            _skip ;
//            BOOL result = [self varAndDotIndirectionWithSymObject:symObject] ;
//            if ( symObject ) CFRelease(symObject) ;
//            if ( result ) return YES ;
//        }
//        else [self error:ExpressionErrorCodeMissingTrailingCrBracket] ;
//    }
//    else
//    {
//        if ( len > 0 ) [self error:ExpressionErrorCodeSymbolSyntaxError] ;
//        else [self error:ExpressionErrorCodeSymbolExpected] ;
//    }
//
//    return NO ;
//}


//-------------------------------------------------------------------------------------------
// left to right generation (lineal)   // ATENCIO NO S'UTILITZA
- (BOOL)restEmbeddedTag
{
    const unsigned char *cstr ;
    size_t len ;
    if ( [self parseToken:&cstr length:&len] )
    {
      
        CFStringRef symObject = CFStringCreateWithBytesNoCopy(NULL, cstr, len, kCFStringEncodingASCII, false, kCFAllocatorNull) ;
            
        _skip ;
        BOOL result = [self varAndDotIndirectionWithSymObject:symObject] ;
        if ( symObject ) CFRelease(symObject) ;
        if ( result )
        {
            _skip ;
            if ( _parseChar( '}' ) )
            {
                return YES ;
            }
            else [self error:ExpressionErrorCodeMissingTrailingCrBracket] ;
        }
    }
    else
    {
        if ( len > 0 ) [self error:ExpressionErrorCodeSymbolSyntaxError] ;
        else [self error:ExpressionErrorCodeSymbolExpected] ;
    }

    return NO ;
}





////-------------------------------------------------------------------------------------------
//// left to right generation (lineal)
//- (BOOL)stringConstantV
//{
//    const unsigned char *cstr ;
//    size_t len ;
//    if ( [ self parseConstantString:&cstr length:&len doubleQuote:doubleQuoted dollarCom:NO] )
//    {
//        // generar codi
//        CFStringRef string = CFStringCreateWithBytes(NULL, cstr, len, stringEncoding, false ) ;
//        if ( string == NULL )
//        {
//            string = CFSTR("<unknown_encoding>");
//        }
//        
//        CFIndex value = CFArrayGetCount( constStrings ) ;
//        CFArrayAppendValue( constStrings, string ) ;
//        if ( string ) CFRelease( string ) ;
//                                                                                    //if ( value > 255 ) return NO ;
//        if ( value > 1000 ) return NO ;
//        classSelector = RPNClSelGenericClass ;
//        _genOpCode( RpnConstStrLd ) ;
//                                                                                        //_genScalar( UInt8, (int)value ) ;
//        _genScalar( UInt16, value ) ;
//        
//        return YES ;
//    }
//    return NO ;
//}


//-------------------------------------------------------------------------------------------
// left to right generation (lineal)
- (BOOL)stringConstant
{
    CFStringRef string = [ self parseEscapedCreateStringWithEncoding:stringEncoding ];
    
    if ( string == NULL )
        return NO;
        
    CFIndex value = CFArrayGetCount( constStrings ) ;
    CFArrayAppendValue( constStrings, string ) ;
    CFRelease( string ) ;
                                                                                    //if ( value > 255 ) return NO ;
    if ( value > 1000 ) return NO ;
    classSelector = RPNClSelGenericClass ;
    _genOpCode( RpnConstStrLd ) ;
                                                                                        //_genScalar( UInt8, (int)value ) ;
    _genScalar( UInt16, value ) ;
        
    return YES ;
}


//-------------------------------------------------------------------------------------------
// left to right generation (lineal)
- (BOOL)constant
{
    double num ;
    BOOL isTime = NO;
    if ( [self parseNumber:&num isTime:&isTime] )
    {
        classSelector = RPNClSelGenericClass ;
        _genOpCode( isTime?RpnTimeLd:RpnConstLd ) ;
        _genValue( num ) ;
        return YES ;
    }
    
    return NO ;
}


//-------------------------------------------------------------------------------------------
// left to right generation (lineal)
- (BOOL)restParenthesis
{
    //if ( [self expression] )
    if ( [self expressionList] )
    {
        _skip ;
        if ( _parseChar( ')' ) )
        {
            return YES ;
        }
        else [self error:ExpressionErrorCodeMissingTrailingBracket2] ;
    }
    return NO ;
}



//-------------------------------------------------------------------------------------------
// left to right generation (lineal)
- (BOOL)restArray
{
    unsigned int count = 0 ;
    
    classSelector = RPNClSelGenericClass ;
    _genOpCode( RpnArrayLd )  ;
    
    _skip ;
    if ( _parseChar( ']' ) )
    {
        // vale, array buit
    }
    else if ( [self argumentListWithMaxCount:2500 outActualCount:&count] )
    {
        _skip ;
        if ( _parseChar( ']' ) )
        {
            // vale, final de array
        }
        else
        {
            [self error:ExpressionErrorCodeMissingTrailingSqBracket2] ;
            return NO ;
            
        }
    } 
    else return NO ; // error en els arguments
    
    classSelector = RPNClSelGenericClass ;
    _genOpCode( RpnFillArray )  ;
    _genScalar( UInt16, count ) ;
    return YES ;
}

//-------------------------------------------------------------------------------------------
// left to right generation (lineal)
- (BOOL)restHash
{
    unsigned int count = 0 ;
    
    classSelector = RPNClSelGenericClass ;
    _genOpCode( RpnHashLd )  ;
    
    _skip ;
    if ( _parseChar( '}' ) )
    {
        // vale, hash buit
    }
    else if ( [self hashArgumentListWithMaxCount:1000 outActualCount:&count] )
    {
        _skip ;
        if ( _parseChar( '}' ) )
        {
            // vale, final del hash
        }
        else
        {
            [self error:ExpressionErrorCodeMissingTrailingCrBracket2] ;
            return NO ;
            
        }
    } 
    else return NO ; // error en els arguments
    
    classSelector = RPNClSelGenericClass ;
    _genOpCode( RpnFillHash )  ;
    _genScalar( UInt16, count ) ;
    return YES ;
}



//-------------------------------------------------------------------------------------------
// left to right generation (lineal)
- (BOOL)restDisconnectedSource
{
    // es considera valid qualsevol token amb punts i sense espais entre '<' '>'
    const unsigned char *cstr ;
    size_t len ;
    if ( [self parseToken:&cstr length:&len withOptionalChar:'.'] )
    {
        _genBytesS( cS, cstr-cS-1  ) ;    // -1 per considerar el '<'
        if ( _parseChar('>') )
        {
            cS = c;
            BOOL result = [self _genVarWithSymObject:(CFStringRef)NoSourceSym symProperty:NULL] ;
            return result;
        }
    }
    return NO ;

}

//-------------------------------------------------------------------------------------------
// left to right generation (lineal)
- (BOOL)primaryExpr
{

  
//    NSLog( @"aqui0" );
//    
//    if ( *c == '\"' &&  *(c+1) == 'O' && *(c+2) == '0')
//    {
//        NSLog( @"aquiInicial" );
//    }
    
    
    // parentesis
    if ( _parseChar( '(' ) ) 
    {
        _skip ;
        if ( [self restParenthesis] )
        {
            return YES ;
        }
        
//        if ( *c == ':' )
//        {
//            NSLog( @"aqui1" );
//        }
    }
    
    // array
    else if ( _parseChar( '[' ) ) 
    {
        _skip ;
        if ( [self restArray] )
        {
            return YES ;
        }
        
//        if ( *c == ':' )
//        {
//            NSLog( @"aqui2" );
//        }
    }
    
    // hash
    else if ( _parseChar( '{' ) )
    {
        _skip;
        if ( [self restHash] )
        {
            return YES;
        }
        
//        if ( *c == ':' )
//        {
//            NSLog( @"aqui3" );
//        }
    }

    /*
    // embedded tag
    else if ( _parseCString( "#{", 2 ) )
    {
        _genBytesS( cS, c-cS-2  ) ;
        _skip ;
        if ( [self restEmbeddedTag] )
        {
            return YES ;
        }
    }
    */
    
    // constants
    else if ( [self constant] ) // abans que simbolic per supportar true, false
    {
        return YES ;
    }
    
    // simbols
    else if ( [self simbolicToken] ) 
    {
        return YES ;
    }
    
    // string constants
    else if ( [self stringConstant] )
    {
        return YES ;
    }
    
    // disconnectedSource
    else if ( _parseChar( '<' ) )
    {
        _skip;
        if ( [self restDisconnectedSource] )
        {
            return YES;
        }
    }
    
//    if ( *c == ':' )
//    {
//        NSLog( @"aquiFinal" );
//    }
    
    ExpressionErrorCode err = ExpressionErrorCodeExpectedPrimitiveExpression ;
    if ( c == beg ) err = ExpressionErrorCodeExpectedExpression ;
    [self error:err] ;
    return NO ;
}


//-------------------------------------------------------------------------------------------
// left to right generation (lineal)
- (BOOL)sufixedPrimaryExpr
{
    // constants
    if ( [self primaryExpr] ) 
    {
        _skip ;
        if ( [self indirection] )
        {
            return YES ;
        }
    }
    return NO ;
}


//-------------------------------------------------------------------------------------------
// left to right generation (lineal)
- (BOOL)unaryExpr
{
    int op = RpnNoOperation ;
    if ( _parseChar( '+' ) ) op = RpnNoOperation ;
    else if ( _parseChar( '-' ) ) op = RpnOpMinus ;
    else if ( _parseChar( '!' ) ) op = RpnOpNot ;
    else if ( _parseChar( '~' ) ) op = RpnOpCompl ;
        
    _skip ;
    if ( [self sufixedPrimaryExpr] )
    {
        if ( op != RpnNoOperation )
        {
            classSelector = RPNClSelGenericClass ;
            _genOpCode( op ) ;
        }
        return YES ;
    }
    return NO ;
}


//-------------------------------------------------------------------------------------------
// left to right generation (lineal)
- (BOOL)binaryOperatorsExpr
{
    if ( [self unaryExpr] )
    {
        UInt16 opStack[16] ; // operator stack
        int sp = 0 ; // next possition
        while ( 1 )
        {
            _skip ;
            int op = RpnNoOperation ;
            if ( c < end )
            {
                switch( *c )
                {
                    case '*' : ++c; op=RpnOpTimes ; break ;
                    case '/' : ++c; op=RpnOpDiv ; break ;
                    case '%' : ++c; op=RpnOpMod ; break ;
                    
                    case '+' : ++c; op=RpnOpAdd ; break ;
                    case '-' : ++c; op=RpnOpSub ; break ;
                    
                    case '&' : ++c; op = ( (c<end && *c=='&') ? (++c, RpnOpAnd) : RpnOpBitAnd ) ; break ;
                    case '^' : ++c; op=RpnOpBitXor ; break ;
                    case '|' : ++c; op = ( (c<end && *c=='|') ? (++c, RpnOpOr) : RpnOpBitOr ) ; break ;
                
                    case '=' : ++c; op = ( (c<end && *c=='=') ? (++c, RpnOpEq) : (--c, RpnNoOperation) ) ; break ;
                    case '!' : ++c; op = ( (c<end && *c=='=') ? (++c, RpnOpNe) : (--c, RpnNoOperation) ) ; break ;
                    case '<' : ++c; op = ( (c<end && *c=='=') ? (++c, RpnOpLe) : RpnOpLt ) ; break ;
                    case '>' : ++c; op = ( (c<end && *c=='=') ? (++c, RpnOpGe) : RpnOpGt ) ; break ;
                    
                    case '.' : ++c; op = ( (c<end && *c=='.') ? (++c, RpnOpRange) : (--c, RpnNoOperation) ) ; break ;
                }
            }
        
            if ( op != RpnNoOperation )
            {
                classSelector = RPNClSelGenericClass ;
                while ( sp > 0 && (opStack[sp-1]&RpnPrecedenceMask) >= (op&RpnPrecedenceMask) )
                {
                    _genOpCode( opStack[--sp] ) ;
                }
                opStack[sp++] = op ;
                if ( sp >= 16 ) 
                { 
                    // no passa mai perque no hi ha tants nivells de prioritat
                    NSAssert( false, @"Masses nivells de operadors binaris") ;
                }
                
                _skip ;
                if ( [self unaryExpr] ) 
                {
                    continue ;
                }
                return NO ;
            }
            else 
            {
                classSelector = RPNClSelGenericClass ;
                while ( sp > 0 )
                {
                    _genOpCode( opStack[--sp] ) ;
                }
                return YES ;
            }
        }
    }
    return NO ;
}


//-------------------------------------------------------------------------------------------
// right-to left generation (recursive)
- (BOOL)ternaryConditional
{
    if ( [self binaryOperatorsExpr ] )
    {
        _skip ;
        if ( _parseChar( '?' ) )
        {
            _skip ;
            if ( [self expression] )
            {
                _skip ;
                if ( _parseChar( ':' ) )
                {
                    _skip ;
                    if ( [self expression] )
                    {
                        classSelector = RPNClSelGenericClass ;
                        _genOpCode( RpnOpTern ) ;
                        return YES ;
                    }
                }
                else
                {
                    [self error:ExpressionErrorCodeMissingColonInTernaryOperator] ;
                }
            }
        }
        else
        {
            return YES ;
        }
    }
    return NO ;
}


//-------------------------------------------------------------------------------------------
- (BOOL)restIfStatement
{
    // per "if a then b else c end" genera
    // 1: a
    // 2: jeq 5
    // 3: b
    // 4: jmp 6
    // 5: c
    // 6: endIf

    // per "if a then b end" genera
    // 1: a
    // 2: jeq 5
    // 3: b
    // 4: jmp 6
    // 5: exit
    // 6: endIf
    
    // adicionalment activa skipDepenecencies per les expressions que es trobem en el then o else

// 1:
    skipDependencies = NO ;
    if ( [self expression] )
    {
// 2:
        _genOpCode( RpnOpJeq ) ;                    // generacio la instruccio
        _genScalar( UInt16, 0 ) ;  // generacio temptativa del increment del je
        long jeqpos = p - CFDataGetBytePtr(data) ; // guardem la posicio
        UInt16 offset ;
        
        _skip ;
        if ( [self parseConcreteToken:"then" length:4] ) 
        {
            // vale, es opcional
            _skip ;
        }
        
// 3:
        skipDependencies = YES ;
        if ( [self expression] )
        {
// 4:
            _genOpCode( RpnOpJmp ) ;                    // generacio de la instruccio
            _genScalar( UInt16, 0 ) ; // generacio temptativa del increment del jmp
            long jmppos = p - CFDataGetBytePtr(data) ;
                
            offset = jmppos - jeqpos ;
            *(UInt16*)(p-sizeof(UInt16)-offset) = offset ;
            BOOL done = NO ;
        
            _skip ;
            if ( [self parseConcreteToken:"else" length:4] )
            {
// 5 (amb else):
                _skip ;
                skipDependencies = YES ;
                if ( [self expression] )
                {
                    done = YES ;
                }
            }
            else // sense else 
            {
// 5 (sense else):
                done = YES ;
                _genOpCode( RpnExit ) ;    // if sense else
            }
            
            if ( done )
            {
                offset = p - CFDataGetBytePtr(data) - jmppos ;
                *(UInt16*)(p-sizeof(UInt16)-offset) = offset ;
                _genOpCode( RpnEndIf );
                
                skipDependencies = NO ;
                
                _skip ;
                if ( [self parseConcreteToken:"end" length:3] ) 
                {
                    // vale, es opcional
                    _skip ;
                }
                
                return YES ;   // continuem generant codi
            }
        }
    }
    
    skipDependencies = NO ;
    return NO ;
}


//-------------------------------------------------------------------------------------------
- (BOOL)statement
{
    //if ( _parseCString( "if ", 3 ) )  // atencio posem un espai al darrera
    if ( [self parseConcreteToken:"if" length:2] )
    {
        _skip ;
        if ( [self restIfStatement] )
        {
            return YES ;
        }
    }
    
    else if ( [self ternaryConditional] )
    {
        return YES ;
    }
    
    return NO ;
}

//-------------------------------------------------------------------------------------------
- (BOOL)expression
{
    if ( [self statement] )
    {
        return YES ;
    }
    return NO ;
}


//-------------------------------------------------------------------------------------------
- (BOOL)expressionList
{
    unsigned int count = 0 ;
    if ( [self argumentListWithMaxCount:255 outActualCount:&count] )
    {
        if ( count > 1 )
        {
            classSelector = RPNClSelGenericClass ;
            _genOpCode( RpnOpComma )  ;
            _genScalar( UInt16, count ) ;
        }
        return YES;
    }
    return NO;
    

//    if ( [self expression] )
//    {
//        while ( 1 )
//        {
//            _skip;
//            if ( _parseChar(',') )
//            {
//                _skip;
//                if ( [self expression] )
//                {
//                    continue;
//                }
//                return NO;
//            }
//            else
//            {
//                return YES;
//            }
//        }
//    }
//    return NO ;
}

//-------------------------------------------------------------------------------------------
- (BOOL)parseExpressionOutUsedLength:(int*)usedLength
{
   /* 
    UInt8 *ptr = c ;
    CFTimeInterval now = CFAbsoluteTimeGetCurrent() ;
    NSLog( @"start %g", now ) ;
    for ( int i = 0 ; i< 1000000 ; i++ )
    {
        c = ptr ;
        [self ternaryConditional] ;
    }
    NSLog( @"end %g", CFAbsoluteTimeGetCurrent()-now ) ;
    c = ptr ;
    */
    
    _skip ;
    if ( [self expressionList] )
    {
        if ( usedLength == NULL )
        {
            // aqui mirar que no hi hagi res mes _skip i comprovar
            _skip ;
            if ( c == end )
            {
                return YES ;
            }
            else
            {
                [self error:ExpressionErrorCodeExtraCharsAfterExpression] ;
            }
        }
        else
        {
            end = c ;
            *usedLength = end-beg ;
            return YES ;
        }
    }
    return NO ;
}


/////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark  Creacio de una expressio a partir del codi font
/////////////////////////////////////////////////////////////////////////////////////////////

// La idea de crear una expressio es parsejarla i anar anotant els simbols en un diccionari 'symbols'
// que conte parelles de symbols i un index incremental a mida que s'han trobat (CFStringRef, key)
// Un cop la expressio s'ha parsejat correctament el diccionari es transforma en un array que
// conte els simbols en el index corresponent.
// Durant el parseig, el rpn generat direcciona els simbols per el seu index, per tant es poden
// accedir per index en el array. Aquest array de simbols es posa provisionalment 
// com a sourceExpressions de la expressio en newExpressionFromBytes
//
// El metode commitExpressionsUsing.. el que fa es canviar els symbols del array per les corresponents expressions
// que els representen. Les expressions les troba en els dictionaris de simbols, que 
// contenen parelles symbols (CFStringRef, key) i objectes id<ValueHolder>. El metode demana als
// objectes, quina es la expressio rellevant per cada simbol y la substitueix en el sourceExpressions
// de la expressio que ha compilat.

- (BOOL)updateExpression:(SWExpression*)expression
        fromBytes:(const UInt8*)ptr 
        maxLength:(int)maxLength 
        //holder:(id<ValueHolder>)holder
        stringEncoding:(CFStringEncoding)encoding
        usedLength:(int*)usedLength
        doubleQuoted:(BOOL)quoted
        outError:(__autoreleasing NSError**)outError
{
    // per posar els symbols que anem trobant
    if ( symbols == nil ) 
    {
        symbols = [[SymbolicTable alloc] init] ;
    }
    
    // per posar les strings constants que anem trobant
    if ( constStrings == NULL )
    {
        constStrings = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks) ;
    }
    
    // el encoding de les strings
    stringEncoding = encoding ;
        
    // per posar el codi rpn generat 
    data = CFDataCreateMutable( NULL, 0 ) ;
    CFDataSetLength( data, DATA_INITIAL_LENGTH ) ; 
    p = CFDataGetMutableBytePtr( data ) ;
    max = p + CFDataGetLength( data ) ;
    
    // per posar el codi font
    dataS = CFDataCreateMutable( NULL, 0 ) ;
    CFDataSetLength( dataS, DATA_INITIAL_LENGTH ) ;
    pS = CFDataGetMutableBytePtr( dataS ) ;
    maxS = pS + CFDataGetLength( dataS ) ;
    
    // flag de acabament
    BOOL done = NO ;
    
    // punters al codi font, longitud maxima, i longitud utilitzada
    beg = ptr ;
    c = ptr ;
    end = c + maxLength ;
    
    // preparacio del primer placeholder de symbols
    _genSPlaceholder(0xff) ;
    cS = c ;
    
    // error a zero
    errCode = ExpressionErrorCodeNone ;
    errInfo.sourceOffset = 0 ;
    
    // detalls de parseig de strings
    doubleQuoted = quoted ;
    
    // parsejem l'expressio
    if ( [self parseExpressionOutUsedLength:usedLength] )
    {
        // confeccionem el array de sources a partir del diccionari de symbols aplicant una applier function
        // al diccionari que simplement coloca cada simbol al seu index
        [symbols commitTable] ;
        long symbolCnt = [symbols symbolsCount] ;
        
        // determinem la longitud del rpn
        UInt8* begin = CFDataGetMutableBytePtr( data ) ;
        long rpnLength = p-begin ;
        
        // alguns tipus d'expressio molt comuns com constants numeriques i simbols les codifiquem 'a saco' 
        // amb tipus determinat per millorar l'eficiencia en l'execucio
        
        // si la expressio es un numero constant
        if ( rpnLength == sizeof(UInt8)+sizeof(UInt32)+sizeof(UInt32) && begin[0] == RpnConstLd )
        {
            NSAssert ( symbolCnt == 0, @"symbolCount ha de ser zero per una expressio constant" ) ;
            double value ;
            getValueFromByteAddr(value, begin+sizeof(UInt8) ) ;
            [expression setSourceWithConstantValue:value] ;
            done = YES ;
        }
        else
        {
            CFMutableArrayRef sources = [symbols symbolsTable] ;
            CFDataRef dependencySkips = [symbols infoBits] ;
            
            // si la expressio es de simbol unic
            if ( rpnLength == sizeof(UInt8)+sizeof(UInt8) && begin[0] == RpnVarLd )
            {
                NSAssert ( symbolCnt==1 && begin[1]==0, @"symbolCount ha de ser 1 per una expressio de simbol unic" ) ;
                
                __unsafe_unretained SymbolicSource *symbol = (__bridge id)CFArrayGetValueAtIndex(sources, 0) ;
                [expression setSourceWithSymbol:symbol] ;
                [expression setSourceDependanceSkips:dependencySkips] ;
                done = YES ;
            }
            
            // si la expressio pot requerir un rpn
            else
            {
                //expressionType = ExpressionKindCode ;  // no cal pero per claredat
                CFDataSetLength( data, rpnLength ) ; // retallem el rpn per ajustarse a la longitud generada
                
                // aqui podriem iterar per strings de manera que les posem en una taula global
                // per cada string canviar el punter dintre de strings per apuntar a la taula global
                
                // si la expressio no conte sources la evaluem ara i posem el resultat directament
                if ( symbolCnt == 0 )
                {
                    RPNValue rpnVal;
                    ExpressionStateInfo resultInfo;
                    RpnInterpreter *interpreter = [RpnInterpreter sharedRpnInterpreter] ; 
                    RpnInterpreterResultCode result = [interpreter evalRpn:data sources:sources constStrings:constStrings outValue:&rpnVal outStatus:&resultInfo] ;
                    
                    if ( result == RpnInterpreterResultOk )
                    {
                        done = YES ;
                        resultInfo.state = expression.state;
                        // ^-- en aquest punt no hem introduit cap error pero hem de deixar qualsevol estat previ que tenia la expressio
                    }
                    else
                    {
                        [self error:ExpressionErrorCodeCouldNotEvalutateConstantExpression] ;
                    }
                    
                    [expression setSourceWithConstantRpnValue:rpnVal resultInfo:resultInfo];
                }
                
                // la expressio conte sources, la creem amb el seu RPN
                else
                {
                    // posem el data a la expressio
                    NSData *rpnData = [[NSData alloc] initWithBytes:begin length:rpnLength] ;
                    [expression setSourceWithRpnCode:rpnData withSources:sources withConstStrings:constStrings] ;
                    // ARC [rpnData release] ;
                    [expression setSourceDependanceSkips:dependencySkips] ;
                    done = YES ;
                }
            }
        }
    }

    // finalitzacio del source
    if ( done )
    {
        //usedLength = c - ptr ;
        _genBytesS( cS, end-cS  ) ;
    }
    else
    {
        if ( usedLength ) *usedLength = 0 ;
        [expression setSourceEmpty] ;
        pS = CFDataGetMutableBytePtr( dataS ) ; ;
        _genSPlaceholder(0xff) ;
        _genBytesS( ptr, end-ptr  ) ;  // posem tota la expressio ignorant possibles placeholders
    }

    UInt8* beginS = CFDataGetMutableBytePtr( dataS ) ;
    long dataSLength = pS-beginS ;
    
    CFDataSetLength( dataS, dataSLength ) ;
        
    // posem el dataS a la expressio
    NSData *sourceData = [[NSData alloc] initWithBytes:beginS length:dataSLength] ;
    [expression setSourceCodeData:sourceData] ;
    // ARC [sourceData release] ;
    
    // posem el error a la expressio (necesari aqui perque hem fet setSourceEmpty)
    [expression setError:errCode withInfo:errInfo] ;
    
    [symbols clear] ;
    
    if ( constStrings ) CFRelease( constStrings ), constStrings = NULL ;
    if ( data ) CFRelease( data ), data = NULL ;
    if ( dataS ) CFRelease( dataS ), dataS = NULL ;
    
    if ( errCode )
    {
        if ( outError )
        {
            NSString *errMsg = [expression getSourceErrorString] ;
            NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
            *outError = [NSError errorWithDomain:@"com.SweetWilliam.HmiPad" code:0 userInfo:info];
        }
    }
    
    //if ( length ) *length = usedLength; 
    return done ;
}

//-------------------------------------------------------------------------------------------
- (SWExpression*)newExpressionFromBytes:(const UInt8*)ptr 
        maxLength:(int)maxLength 
        stringEncoding:(CFStringEncoding)encoding
        usedLength:(int*)length
        doubleQuoted:(BOOL)quoted
        outError:(__autoreleasing NSError**)outError
{
    SWExpression *expr = [[SWExpression alloc] init] ;
    if ( ! [self updateExpression:expr fromBytes:ptr maxLength:maxLength 
            stringEncoding:encoding usedLength:length 
            doubleQuoted:quoted outError:outError] ) 
    {
        // ARC [expr release] ;
        expr=nil ;
    }
    return expr ;
}



/////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark  Symbol Tables
/////////////////////////////////////////////////////////////////////////////////////////////

//-------------------------------------------------------------------------------------------
- (void)addLocalSymbol:(NSString*)symbol withHolder:(id<ValueHolder>)holder
{
    if ( holder == nil || symbol == NULL ) return ;
    
    if ( localTable == NULL ) 
        localTable = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, NULL ) ; // nomes retenim la clau no retenim els holders
    
    const void* value ;
    if ( CFDictionaryGetValueIfPresent( localTable, (__bridge CFTypeRef)symbol, &value ) )
    {
        value = kCFNull ;  // si ja hi es posem un kCFNull, no pot ser repetit
        CFDictionarySetValue( localTable, (__bridge CFTypeRef)symbol, value ) ; 
    }
    else
    {
        CFDictionaryAddValue( localTable, (__bridge CFTypeRef)symbol, (__bridge CFTypeRef)holder ) ; // no hi era, l'afegim
    }
}


//-------------------------------------------------------------------------------------------
- (void)addGlobalSymbol:(NSString*)symbol withHolder:(id<ValueHolder>)holder
{    
    if ( holder == nil || symbol == NULL ) return ;
    
    CFDictionaryAddValue( globalTable, (__bridge CFTypeRef)symbol, (__bridge CFTypeRef)holder ) ; // l'afegim si no hi era
}






//-------------------------------------------------------------------------------------------
- (NSArray*)getGlobalSymbols
{
    CFIndex count = CFDictionaryGetCount( globalTable );
    CFTypeRef keys[count];
    
    CFDictionaryGetKeysAndValues( globalTable, keys, NULL);
    CFArrayRef cfGlobalSymbols = CFArrayCreate(NULL, keys, count, &kCFTypeArrayCallBacks);
    return CFBridgingRelease(cfGlobalSymbols);
}


typedef void (^EnumerateTableBlock)(NSString *, __unsafe_unretained id<ValueHolder> );

static void _getGlobalSymbolsApplierFunction (const void *symbol, const void *holder, void *context )
{
//    NSString *symbol = (__bridge NSString*)key;
//    id<ValueHolder> holder = (__bridge id<ValueHolder>)value;
    EnumerateTableBlock block = (__bridge EnumerateTableBlock)context;    
    block( (__bridge id)symbol, (__bridge id)holder );
}

- (void)enumerateGlobalTableUsingBlock:( void (^)(NSString *symbol, __unsafe_unretained id<ValueHolder>holder ) )block
{
    if ( block )
    {
        CFDictionaryApplyFunction( globalTable, _getGlobalSymbolsApplierFunction, (void*)block);
    }
}

- (__unsafe_unretained id<ValueHolder>)globalTableObjectForSymbol:(NSString*)symbol
{
    return (__unsafe_unretained id<ValueHolder>)CFDictionaryGetValue( globalTable, (__bridge CFTypeRef)symbol );
}


////-------------------------------------------------------------------------------------------
//- (NSString *)replaceGlobalSymbolV:(NSString*)oldSymbol withHolder:(id<ValueHolder>)holder
//        bySymbol:(NSString*)newSymbol // outError:(NSError**)outError
//{
//    if ( holder == nil )
//    {
//        NSAssert( false, @"Intencio de remplacar simbols amb holder nil!") ;
//    }
//    
//    /*
//    if ( newSymbol )
//    {
//        // en principi tornara NULL si no es ascii, o no NULL si es ascii
//        char buff[81] ;
//        const char *ch = buff ;
//        BOOL valid = CFStringGetCString((CFStringRef)newSymbol, buff, sizeof(buff), kCFStringEncodingASCII) ;
//        
//        if ( valid && *ch != '\0' && ( (*ch >= 'a' && *ch <= 'z' ) 
//            || (*ch >= 'A' && *ch <='Z') || ( *ch == '_' ) || ( *ch == '$' ) ) )
//        {
//            ch++ ;
//            while ( *ch != '\0' && ( (*ch >= 'a' && *ch <= 'z' ) ||
//                    (*ch >= 'A' && *ch <='Z') || (*ch >= '0' && *ch <= '9' ) || ( *ch == '_' )  ) ) ch++ ;
//        }
//        else valid = NO ;
//        
//        if ( !valid || *ch != '\0' )
//        {
//            if ( outError )
//            {
//                NSString *errMsg = [[NSString alloc] initWithFormat:NSLocalizedString(@"InvalidSimbol%@", nil), newSymbol] ;
//                NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
//                *outError = [NSError errorWithDomain:@"com.SweetWilliam.HmiPad" code:0 userInfo:info];
//                [errMsg release] ;
//            }
//            return nil ;
//        }
//    }
//    */
//    
//    const void *oldHolder = NULL ;
//    BOOL oldPresent = oldSymbol && CFDictionaryGetValueIfPresent( globalTable, (__bridge CFTypeRef)oldSymbol, &oldHolder ) ;
//    BOOL newPresent = newSymbol && CFDictionaryGetValueIfPresent( globalTable, (__bridge CFTypeRef)newSymbol, NULL ) ;
//    
//    if ( newPresent )
//    {
//        if ( [oldSymbol isEqualToString:newSymbol] && oldHolder == (__bridge CFTypeRef)holder ) return newSymbol ; // ok el mateix ja hi es
//        
//        if ( oldPresent )
//        {
//            // old value present
//            NSAssert( oldHolder == (__bridge CFTypeRef)holder, @"Intencio de remplacar simbols amb diferent holder") ;
//            CFDictionaryRemoveValue( globalTable, (__bridge CFTypeRef)oldSymbol ) ;
//        }
//        
//        int iter = 1 ;
//        CFStringRef tryString = NULL ;
//        while ( YES )
//        {
//            tryString = CFStringCreateWithFormat( NULL, NULL, CFSTR("%@_%d"), newSymbol, iter++ ) ;
//            if ( NO == CFDictionaryContainsKey( globalTable, tryString ) ) 
//            {
//                CFDictionaryAddValue( globalTable, tryString, (__bridge CFTypeRef)holder ) ;
//                break ;
//            }
//            CFRelease( tryString ) ;
//        }
//        
//        return (__bridge_transfer id)tryString ;
//        // ARC return [(id)tryString autorelease] ;
//    }
//    
//    if ( oldPresent )
//    { 
//        // old value present
//        /*if (oldHolder != holder) {
//            NSLog(@"Atencio! que peta! Old: %@, new: %@",[oldHolder description], [holder description]);
//        }
//        */
//        
//        NSAssert( oldHolder == (__bridge CFTypeRef)holder, @"Intencio de remplacar simbols amb diferent holder") ;
//        CFDictionaryRemoveValue( globalTable, (__bridge CFTypeRef)oldSymbol ) ;
//    }
//    
//    if ( newSymbol )
//    {
//        CFDictionaryAddValue( globalTable, (__bridge CFTypeRef)newSymbol, (__bridge CFTypeRef)holder ) ; // add new symbol
//    }
//    
//    return newSymbol ;
//}
//



//-------------------------------------------------------------------------------------------
- (NSString *)replaceGlobalSymbol:(NSString*)oldSymbol withHolder:(id<ValueHolder>)holder
        bySymbol:(NSString*)newSymbol // outError:(NSError**)outError
{
    if ( holder == nil )
    {
        NSAssert( false, @"Intencio de remplacar simbols amb holder nil!") ;
    }
    
    /*
    if ( newSymbol )
    {
        // en principi tornara NULL si no es ascii, o no NULL si es ascii
        char buff[81] ;
        const char *ch = buff ;
        BOOL valid = CFStringGetCString((CFStringRef)newSymbol, buff, sizeof(buff), kCFStringEncodingASCII) ;
        
        if ( valid && *ch != '\0' && ( (*ch >= 'a' && *ch <= 'z' ) 
            || (*ch >= 'A' && *ch <='Z') || ( *ch == '_' ) || ( *ch == '$' ) ) )
        {
            ch++ ;
            while ( *ch != '\0' && ( (*ch >= 'a' && *ch <= 'z' ) ||
                    (*ch >= 'A' && *ch <='Z') || (*ch >= '0' && *ch <= '9' ) || ( *ch == '_' )  ) ) ch++ ;
        }
        else valid = NO ;
        
        if ( !valid || *ch != '\0' )
        {
            if ( outError )
            {
                NSString *errMsg = [[NSString alloc] initWithFormat:NSLocalizedString(@"InvalidSimbol%@", nil), newSymbol] ;
                NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
                *outError = [NSError errorWithDomain:@"com.SweetWilliam.HmiPad" code:0 userInfo:info];
                [errMsg release] ;
            }
            return nil ;
        }
    }
    */
    
    const void *oldHolder = NULL ;
    BOOL oldPresent = oldSymbol && CFDictionaryGetValueIfPresent( globalTable, (__bridge CFTypeRef)oldSymbol, &oldHolder ) ;
    BOOL newPresent = newSymbol && CFDictionaryGetValueIfPresent( globalTable, (__bridge CFTypeRef)newSymbol, NULL ) ;
    
    if ( newPresent )
    {
        if ( [oldSymbol isEqualToString:newSymbol] && oldHolder == (__bridge CFTypeRef)holder ) return newSymbol ; // ok el mateix ja hi es
        
        if ( oldPresent )
        {
            // old value present
            NSAssert( oldHolder == (__bridge CFTypeRef)holder, @"Intencio de remplacar simbols amb diferent holder") ;
            CFDictionaryRemoveValue( globalTable, (__bridge CFTypeRef)oldSymbol ) ;
        }
        
        long length = newSymbol.length;
        long position = length-1;
        int suffix = 0;
        for ( ; position>=0 ; position-- )
        {
            unichar ch = [newSymbol characterAtIndex:position];
            if ( ch >= '0' && ch <= '9' )
                suffix = suffix*10 + (ch -'0');
            
            else break;
        }
        
        if ( length > position+1 )
            newSymbol = [newSymbol substringToIndex:position+1];
        
        CFStringRef tryString = NULL ;
        while ( YES )
        {
            suffix += 1;
            tryString = CFStringCreateWithFormat( NULL, NULL, CFSTR("%@%d"), newSymbol, suffix ) ;
            if ( NO == CFDictionaryContainsKey( globalTable, tryString ) ) 
            {
                CFDictionaryAddValue( globalTable, tryString, (__bridge CFTypeRef)holder ) ;
                break ;
            }
            CFRelease( tryString ) ;
        }
        
//        int iter = 1 ;
//        CFStringRef tryString = NULL ;
//        while ( YES )
//        {
//            tryString = CFStringCreateWithFormat( NULL, NULL, CFSTR("%@_%d"), newSymbol, iter++ ) ;
//            if ( NO == CFDictionaryContainsKey( globalTable, tryString ) ) 
//            {
//                CFDictionaryAddValue( globalTable, tryString, (__bridge CFTypeRef)holder ) ;
//                break ;
//            }
//            CFRelease( tryString ) ;
//        }
        
        return (__bridge_transfer id)tryString ;
        // ARC return [(id)tryString autorelease] ;
    }
    
    if ( oldPresent )
    { 
        // old value present
        /*if (oldHolder != holder) {
            NSLog(@"Atencio! que peta! Old: %@, new: %@",[oldHolder description], [holder description]);
        }
        */
        
        NSAssert( oldHolder == (__bridge CFTypeRef)holder, @"Intencio de remplacar simbols amb diferent holder") ;
        CFDictionaryRemoveValue( globalTable, (__bridge CFTypeRef)oldSymbol ) ;
    }
    
    if ( newSymbol )
    {
        CFDictionaryAddValue( globalTable, (__bridge CFTypeRef)newSymbol, (__bridge CFTypeRef)holder ) ; // add new symbol
    }
    
    return newSymbol ;
}













/*
//-------------------------------------------------------------------------------------------
- (BOOL)replaceGlobalSymbolV:(NSString*)oldSymbol withHolder:(id<ValueHolder>)holder 
        bySymbol:(NSString*)newSymbol outError:(NSError**)outError
{
    if ( holder == nil ) return NO ;
  
    if ( newSymbol && CFDictionaryGetValueIfPresent( globalTable, newSymbol, NULL ) )
    {
        // new value already present
        if ( outError )
        {
            NSString *errMsg = [[NSString alloc] initWithFormat:NSLocalizedString(@"DuplicatedSimbol%@", nil), newSymbol] ;
            NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
            *outError = [NSError errorWithDomain:@"com.SweetWilliam.HmiPad" code:0 userInfo:info];
            [errMsg release] ;
        }
        return NO ;
    }
        
    // new value not present or null
    const void* value ;
    if ( oldSymbol && CFDictionaryGetValueIfPresent( globalTable, oldSymbol, &value ) )
    { 
        // old value present
        NSAssert( value == holder, @"Intencio de remplacar simbols amb diferent holder") ;
        CFDictionaryRemoveValue( globalTable, oldSymbol ) ;
    }
    
    if ( newSymbol )
    {
        CFDictionaryAddValue( globalTable, newSymbol, holder ) ; // add new symbol
    }

    return YES ;
}
*/


/////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark  Registre per Finalitzacio
/////////////////////////////////////////////////////////////////////////////////////////////

//-------------------------------------------------------------------------------------------
// Les expressions que torna newExpression han de ser sotmeses a la substitucio dels
// simbols per les expressions rellevants. Nomes les expressions registrades es tindran
// en compte per commitExpressionsUsing.. Aixo dona la oportunitat de descartar les
// expressions que no interesen
- (void)registerExpressionForCommit:(SWExpression*)expression
{
    // anotem la expressio per el commit
    if ( expression != NULL ) CFArrayAppendValue( expressions, (__bridge CFTypeRef)expression ) ;
}



/////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark  Finalitzacio
/////////////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------------
static void moveLocalToGlobalDictApplierFunction(const void *key, const void *value, void *context)
{    
    NSString *symbol = (__bridge id)key ;
    id<ValueHolder>holder = (__bridge id)value ;
    RpnBuilder *self = (__bridge id)context ;
    //NSLog( @"moveToGlobal Holder:%@ Symbol:%@", holder, symbol ) ;
    
    NSString *newSymbol = [self replaceGlobalSymbol:nil withHolder:holder bySymbol:symbol] ;
    [holder setGlobalIdentifier:newSymbol] ;
}

//------------------------------------------------------------------------------------
//static void storeLocalDictApplierFunction(const void *key, const void *value, void *context)
//{
//    RpnBuilder *self = (__bridge id)context ;
//    
//    CFArrayAppendValue( self->localTableKeys, key );
//    CFArrayAppendValue( self->localTableValues, value );
//}



- (BOOL)isCommiting
{
    return commitType == RpnBuilderCommitTypeNormal;
}

- (BOOL)isCommitingWithMoveToGlobal
{
    return commitType == RpnBuilderCommitTypeWithMoveToLocal;
}



//-------------------------------------------------------------------------------------------
// asigna els sourceExpressions i els dependants de les expressions
- (BOOL)commitExpressionsWithMoveToGlobal:(BOOL)moveToGlobal //outError:( NSError**)outError
{
    BOOL pass = YES ;
    //NSError *err = nil ;
    //NSMutableString *errMsg = nil ;
    //int errSymsCount = 0 ;
    
    // aqui posarem les expressions que no podem commitar
    CFMutableArrayRef uncommitedExprs = NULL ;
    commitType = moveToGlobal?RpnBuilderCommitTypeWithMoveToLocal:RpnBuilderCommitTypeNormal;

    // iterem per cada expressio que hem registrat
    long count = CFArrayGetCount( expressions ) ;
    for ( int i=0 ; i<count ; i++ )
    {
        __unsafe_unretained SWExpression *expr = (__bridge id)CFArrayGetValueAtIndex( expressions, i ) ;
        
        //NSLog( @"Expr :%@", [expr fullReference] );
        
        
        if ( NO == [expr commitUsingLocalSymbolTable:localTable
                            globalTable:globalTable
                            systemTable:systemTable
                            wantsLink:YES
                            ignoreFaults:NO
                            outError:nil /*(outError?&err:nil)*/] )
        {
//            if ( outError )
//            {
//                if ( errSymsCount < 5 ) // despres de 5 errors pleguem de acumular a errSyms
//                {
//                    errSymsCount++ ;
//                    NSString *errDescr = [err localizedDescription] ;
//                    if ( errMsg == nil ) errMsg = [[NSMutableString alloc] initWithString:errDescr] ;
//                    else [errMsg appendFormat:@"\n\n%@", errDescr] ;
//                }
//            }
            if ( uncommitedExprs == NULL ) uncommitedExprs = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks) ;
            CFArrayAppendValue( uncommitedExprs, (__bridge CFTypeRef)expr) ;
            pass = NO ;
        }
    }
    
    // deixem en expressions nomes les que han quedat uncommited
    if ( uncommitedExprs == NULL ) 
    {
        CFArrayRemoveAllValues( expressions ) ;
    }
    else
    {
        CFRelease( expressions ) ;
        expressions = uncommitedExprs ;
    }
    
    //if ( moveToGlobal ) CFDictionaryApplyFunction( localTable, moveLocalToGlobalDictApplierFunction, (__bridge void*)self ) ;
    
    // si hem de convertir els simbols locals a globals els guardem en un array abans d'eliminar els locals
    if ( moveToGlobal )
    {
        if ( localTables == NULL ) localTables = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
        if ( localTable ) CFArrayAppendValue( localTables, localTable );
    }
    
    // eliminem la taula de symbols locals, pero deixem el globals i de sistema intactes
    //CFDictionaryRemoveAllValues( localTable ) ;
    if ( localTable ) CFRelease( localTable ), localTable = NULL;
    commitType = RpnBuilderCommitTypeNone;
    
    // tornem el error
//    if ( pass == NO && outError )
//    {
//        NSDictionary *info = nil;
//        info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
//        *outError = [NSError errorWithDomain:@"com.SweetWilliam.HmiPad" code:0 userInfo:info];
//        // ARC [errMsg release] ;
//    }

    // tornem el resultat
    return pass ;
}


//-------------------------------------------------------------------------------------------
// asigna els sourceExpressions i els dependants de les expressions sense afectar la taula global
- (BOOL)commitExpressions  //OutError:( NSError**)outError
{
    return [self commitExpressionsWithMoveToGlobal:NO] ;
}

//-------------------------------------------------------------------------------------------
// asigna els sourceExpressions i els dependants de les expressions convertint els simbols locals a globals
- (BOOL)commitExpressionsByConvertingLocalSymbolsToGlobal //OutError:(NSError**)outError
{
    return [self commitExpressionsWithMoveToGlobal:YES] ;
}


//-------------------------------------------------------------------------------------------
- (BOOL)finishCommitOutError:(NSError**)outError ignoreMissingSymbols:(BOOL)ignore
{
    // si hem de convertir els simbols locals a globals ho fem
    long pendingExprCount = CFArrayGetCount( expressions );
    
    // si cal traspasem les taules de simbols locals a globals
    if ( ignore || pendingExprCount == 0 )
    {
        if ( localTables )
        {
            long count = CFArrayGetCount( localTables );
            for ( long i=0 ; i<count ; i++)
            {
                CFDictionaryRef localT = (CFDictionaryRef)CFArrayGetValueAtIndex( localTables, i );
                CFDictionaryApplyFunction( localT, moveLocalToGlobalDictApplierFunction, (__bridge void*)self ) ;
            }
        }
    }
    
    if ( ignore )
    {
        for ( long i=0 ; i<pendingExprCount ; i++ )
        {
            __unsafe_unretained SWExpression *expr = (__bridge id)CFArrayGetValueAtIndex( expressions, i );
            [expr commitUsingLocalSymbolTable:nil
                globalTable:nil
                systemTable:nil
                wantsLink:YES
                ignoreFaults:YES
                outError:nil];
        }
    }
    
    
    // eliminem les taules de symbols locals, pero deixem els globals i de sistema intactes
    if ( localTables ) CFRelease( localTables ), localTables = nil;
    
    // tornem el error
    if ( pendingExprCount>0 && outError )
    {
        NSMutableString *errMsg = nil;
        for( int i=0 ; i<pendingExprCount && i<4 ; i++ )
        {
            __unsafe_unretained SWExpression *expr = (__bridge id)CFArrayGetValueAtIndex(expressions, i);
            NSString *errDescr = [expr getSourceErrorString];
            if ( errMsg == nil ) errMsg = [[NSMutableString alloc] initWithString:errDescr] ;
            else [errMsg appendFormat:@"\n%@", errDescr] ;
        }
    
        NSDictionary *info = nil;
        info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
        *outError = [NSError errorWithDomain:@"com.SweetWilliam.HmiPad" code:0 userInfo:info];
    }
    
    // eliminem les expressions pendents
    CFArrayRemoveAllValues( expressions ) ;

    // tornem el resultat
    return ( ignore || pendingExprCount==0 );
}



//-------------------------------------------------------------------------------------------
// torna les expressions registrades que queden pendents de commit, pot tornar un objecte diferent
// despres de un commit
- (NSMutableArray*)expressions
{
    return (__bridge NSMutableArray*)expressions ;
}


/////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark  Expressions
/////////////////////////////////////////////////////////////////////////////////////////////

//-------------------------------------------------------------------------------------------
// metode de clase de per verificar una expressio
+ (BOOL)isValidExpressionSource:(NSString*)string forBuilderInstance:(RpnBuilder*)builder outErrString:(NSString**)outErrStr
{
    NSAssert( string && builder, @"M'has passat un string o builder nuls, malament anem!" ) ;
    
    // creem un buffer de bytes per parsejar
    const char *cStr = [string UTF8String] ;
    
    // creem una expresio temporal de test
    NSError *error = nil ;
    SWExpression *testExpr = [builder newExpressionFromBytes:(const UInt8*)cStr maxLength:strlen(cStr) stringEncoding:kCFStringEncodingUTF8 usedLength:NULL doubleQuoted:NO outError:&error] ;
    
    // si en aquest punt hem trobat error, tornem el texte directament
    if ( testExpr == nil )
    {
        if ( outErrStr ) *outErrStr = [error localizedDescription] ;
        return NO ;
    }
            
    // taules del builder
    CFDictionaryRef localTable =  builder->localTable ;
    CFDictionaryRef globalTable =  builder->globalTable ;
    CFDictionaryRef systemTable =  builder->systemTable ;

    // commitem la expressio
    BOOL pass = [testExpr commitUsingLocalSymbolTable:localTable
        globalTable:globalTable
        systemTable:systemTable
        wantsLink:NO
        ignoreFaults:NO
        outError:&error] ;
    
    // la expressio ja no la necesitem mes
    // ARC [testExpr release] ;
 
    // tornem error si n'hi ha un
    if ( !pass )
    {
        if ( outErrStr ) *outErrStr = [error localizedDescription] ;
        return NO ;
    }
    
    // si som aqui es que tot ha anat be
    return YES ;
}

//-------------------------------------------------------------------------------------------
// torna una expressio a partir de un source string
- (SWExpression *)expressionWithSource:(NSString*)string outErrString:(NSString**)outErrStr
{
    NSAssert( string, @"M'has passat un string nul, malament anem!" ) ;

    NSError *error = nil ;
    
    // creem un buffer de bytes per parsejar
    const char *cStr = [string UTF8String] ;
    
    // creem una expresio amb el source
    SWExpression *expr = [self newExpressionFromBytes:(const UInt8*)cStr maxLength:strlen(cStr) stringEncoding:kCFStringEncodingUTF8 usedLength:NULL doubleQuoted:NO outError:&error] ;
    
    BOOL pass = ( expr != nil ) ;

    // commitem la expressio
    pass = pass && [expr commitUsingLocalSymbolTable:localTable
        globalTable:globalTable
        systemTable:systemTable
        wantsLink:NO
        ignoreFaults:NO
        outError:&error] ;
 
    // tornem error si n'hi ha un
    if ( !pass )
    {
        if ( outErrStr ) *outErrStr = [error localizedDescription] ;
        return nil ;
    }
    
    // per defecte el commit no evalua la expressio si wantsLink es NO, ho fem ara per actualitzar el resultat.
    [expr eval] ;
    
    // si som aqui es que tot ha anat be, tornem la expressio
    return expr ;
}


//-------------------------------------------------------------------------------------------
- (SWValue*)valueWithSourceString:(NSString*)string outErrString:(NSString**)outErrStr
{
    SWValue *value = nil ;
    SWExpression *expr = [self expressionWithSource:string outErrString:outErrStr] ;
    if ( expr ) value = [[SWValue alloc] initWithRPNValue:expr.rpnValue] ;
    return value ;
}


//-------------------------------------------------------------------------------------------
- (BOOL)updateExpression:(SWExpression*)expr fromString:(NSString*)string outError:(NSError**)error
{
    // creem un buffer de bytes per parsejar
    const char *cStr = [string UTF8String] ;
    
    NSAssert( cStr, @"Problema al cantu. M'han passat una string que es nil o no representable en utf8") ;
    
    // modifiquem la expressio amb el nou codi font
    BOOL pass = [self updateExpression:expr fromBytes:(const UInt8*)cStr maxLength:strlen(cStr) 
            stringEncoding:kCFStringEncodingUTF8 usedLength:NULL doubleQuoted:NO outError:error] ;
            
    // commitem la expressio
    pass = pass && [expr commitUsingLocalSymbolTable:localTable
        globalTable:globalTable
        systemTable:systemTable
        wantsLink:YES
        ignoreFaults:NO
        outError:error] ;
 
    // per defecte el commit no evalua la expressio si hi ha un error, ho fem ara per promoure l'error a les expressions depenents.
    if ( !pass ) [expr eval] ;
    
    // // eliminem els symbols locals, pero deixem el globals i de sistema intactes
    // // CFDictionaryRemoveAllValues( localTable ) ;
    //if ( localTable ) CFRelease( localTable ), localTable = NULL;
    
    // tornem el resultat
    return pass ;
}






/////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark QuickCoder protocol
/////////////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------------
- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super init] ; 
    
    // decodifiquem
    expressions = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks) ; // retenim les expressions
    //localTable = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, NULL ) ; // nomes retenim la clau no retenim els holders
    globalTable = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, NULL ) ; // nomes retenim la clau no retenim els holders
    systemTable = nil ;
    
    int length = [decoder decodeInt] ;
    if (length > 0 ) for ( int i=0 ; i<length ; i++ )
    {
        SWExpression *expr = [decoder decodeObject] ;
        CFArrayAppendValue( expressions, (__bridge CFTypeRef)expr ) ;
    }
    
    length = [decoder decodeInt] ;
    if ( length > 0 ) for ( int i=0 ; i<length ; i++ )
    {
        id key = [decoder decodeObject] ;
        id value = [decoder decodeObject] ;
        CFDictionaryAddValue( localTable, (__bridge CFTypeRef)key, (__bridge CFTypeRef)value ) ;
    }
    
    length = [decoder decodeInt] ;
    if ( length > 0 )
    {
        localTable = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, NULL ) ; // nomes retenim la clau no retenim els holders
        for ( int i=0 ; i<length ; i++ )
        {
            id key = [decoder decodeObject] ;
            id value = [decoder decodeObject] ;
            CFDictionaryAddValue( globalTable, (__bridge CFTypeRef)key, (__bridge CFTypeRef)value ) ;
        }
    }
        
    return self ;
}

//------------------------------------------------------------------------------------
static void encodeDictApplierFunction(const void *key, const void *value, void *context)
{
    QuickArchiver *encoder = (__bridge id)context ;
    [encoder encodeObject:(__bridge id)key] ;
    [encoder encodeObject:(__bridge id)value] ;
}

- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
{
    // codifiquem
    int length = CFArrayGetCount( expressions ) ;
    [encoder encodeInt:length] ;
    if (length > 0 ) for ( int i=0 ; i<length ; i++ )
    {
        __unsafe_unretained SWExpression *expr = (__bridge id)CFArrayGetValueAtIndex( expressions, i ) ;
        [encoder encodeObject:expr] ;
    }
    
    length = localTable != NULL ? CFDictionaryGetCount( localTable ) : 0 ;
    [encoder encodeInt:length] ;
    if ( length > 0 ) CFDictionaryApplyFunction( localTable, encodeDictApplierFunction, (__bridge void*)encoder ) ; 
    
    length = CFDictionaryGetCount( globalTable ) ;
    [encoder encodeInt:length] ;
    if ( length > 0 ) CFDictionaryApplyFunction( globalTable, encodeDictApplierFunction, (__bridge void *)encoder ) ; 
}





@end
