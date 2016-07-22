//
//  QuickCoder.m
//  iPhoneDomusSwitch_090605
//
//  Created by Joan on 05/06/09.
//  Copyright 2009 SweetWilliam, S.L.. All rights reserved.
//

#import "QuickCoder.h"



///////////////////////////////////////////////////////////////////////////////////////
#pragma mark Decode Helper Functions
///////////////////////////////////////////////////////////////////////////////////////

                    #define ENCODED_STRING_CHUNK 96
                    #define DATA_INITIAL_LENGTH 256
                    #define DATA_LENGTH_INCREMENT 1024
                    #define ENCODING_CONVERSION_CHUNK 256

                    static void increaseDataLength( CFMutableDataRef data, UInt8 **pRef, UInt8 **maxRef, CFIndex size )
                    {
                        CFIndex increment = (size/DATA_LENGTH_INCREMENT + 1)*DATA_LENGTH_INCREMENT;
    
                        size_t offset = *pRef - CFDataGetMutableBytePtr( data ) ;
                        CFDataIncreaseLength( data, increment ) ;
    
                        UInt8* begin = CFDataGetMutableBytePtr( data ) ;
                        *pRef = begin + offset ;
                        *maxRef = begin + CFDataGetLength( data ) ;
                    }

                    BOOL dataContainsUtf16( CFDataRef data )
                    {
                        NSInteger length = CFDataGetLength( data ) ;
                        if ( length >= 2 )
                        {
                            const UInt8 *dataPtr = CFDataGetBytePtr( data ) ;
        
                            UInt8 utf16LE[] = { 0xff, 0xfe } ;
                            UInt8 utf16BE[] = { 0xfe, 0xff } ;
                            if ( memcmp( dataPtr, utf16LE, 2 ) == 0 || memcmp( dataPtr, utf16BE, 2 ) == 0 )
                            {
                                return YES ;
                            }
                        }
                        return NO ;
                    }




//------------------------------------------------------------------------------------
CFDataRef create8bitRepresentationOfData( CFDataRef data )
{
    //CFStringRef str = CFStringCreateWithBytes( NULL, dataPtr, length, kCFStringEncodingUTF16, true ) ;
    
    if ( dataContainsUtf16( data ) == NO )
    {
        return CFRetain( data ) ;
    }
    
    NSInteger numBytes = CFDataGetLength( data ) ;
    const UInt8 *dataPtr = CFDataGetBytePtr( data ) ;
    
    CFStringRef str = CFStringCreateWithBytesNoCopy( NULL, dataPtr, numBytes, kCFStringEncodingUTF16, true, kCFAllocatorNull ) ;
    
    CFIndex stringLength = CFStringGetLength((CFStringRef)str) ;
    CFIndex stringLoc = 0 ;
    CFIndex usedBuffLen = 0 ;
    CFIndex totalBuffLen = 0 ;
    
    CFMutableDataRef data8 = CFDataCreateMutable( NULL, 0 ) ;
    CFDataSetLength( data8, DATA_LENGTH_INCREMENT ) ;
    UInt8 *p = CFDataGetMutableBytePtr( data8 ) ;
    UInt8 *max = p + DATA_LENGTH_INCREMENT ;
            
    while ( stringLoc < stringLength )
    {
        // per començar necesitarem assegurar un cert espai
        if (p+ENCODING_CONVERSION_CHUNK > max) increaseDataLength( data8, &p, &max, ENCODING_CONVERSION_CHUNK ) ;
            
        //CFIndex rangeLen = stringLength-stringLoc < 20 ? stringLength-stringLoc : 20 ;
        CFIndex rangeLen = stringLength-stringLoc ;
            
        // codifiquem un troç
        CFIndex convertedLen = CFStringGetBytes(
            str,      // the string
            CFRangeMake(stringLoc, rangeLen),   // range 
            kCFStringEncodingUTF8,   // encoding
            '?',         // loss Byte
            false,     // is external representation
            p,          // buffer
            ENCODING_CONVERSION_CHUNK,  // max buff length
            &usedBuffLen // used buff length
            ) ; 
    
        // actualitzem la nova posicio de caracters i de bytes, i la longitud de bytes
        stringLoc += convertedLen ;
        p += usedBuffLen ;
        totalBuffLen += usedBuffLen ;
    }
    
    CFDataSetLength( data8, totalBuffLen ) ;
    if ( str ) CFRelease( str ) ;
    
    return data8 ;
}

/*
//------------------------------------------------------------------------------------
typedef union Double
{
    double d ;
    struct
    {
        UInt32 a ;
        UInt32 b ;
    } part ;

} Double ;
*/

//#define doubleFromDoubleByteAddr( value, addr ) ( value.part.a = *(UInt32*)(addr), value.part.b = *(UInt32*)((addr)+sizeof(UInt32)), value.d )
//#define getValueFromByteAddr( value, addr ) ( memcpy(&(value),addr,sizeof(value) )


///////////////////////////////////////////////////////////////////////////////////////
#pragma mark QuickArchiver
///////////////////////////////////////////////////////////////////////////////////////

@interface QuickArchiver()

- (void)_encodeString:(NSString*)str ;
- (void)_encodeCollection:(id)array ;
- (void)_encodeObject:(id)object ;

@end


//------------------------------------------------------------------------------------
@implementation QuickArchiver

/*
//------------------------------------------------------------------------------------
- (void)increaseDataLength
{
    size_t offset = p - CFDataGetMutableBytePtr( data ) ;
    CFDataIncreaseLength( data, DATA_LENGTH_INCREMENT ) ;
    
    UInt8* begin = CFDataGetMutableBytePtr( data ) ;
    p = begin + offset ;
    max = begin + CFDataGetLength( data ) ;
}
*/


//------------------------------------------------------------------------------------
//#define _guardBytes(size) if (p+(size) > max) [self increaseDataLength]
#define _guardBytes(size) if (p+(size) > max) increaseDataLength( data, &p, &max, size )

/*
//------------------------------------------------------------------------------------
- (void)appendBytes:(const UInt8 *)bytes length:(size_t)length
{
    if ( p + length > max ) [self increaseDataLength] ;
    memcpy( p, bytes, length ) ;
    
    p += length ;
}
*/


//------------------------------------------------------------------------------------
//#define _guardBytes(size) if (p+(size) > max) increaseDataLength( data, &p, &max ) ;

//------------------------------------------------------------------------------------
#define _encodeBytes(bytes,length) \
{ \
    _guardBytes(length) ; \
    memcpy( p, (bytes), (length) ) ; \
    p += (length) ; \
}

//------------------------------------------------------------------------------------
#define _encodeScalar(type,value) \
{ \
    _guardBytes(sizeof(type)) ; \
    *(type*)p = (value) ;  \
    p += sizeof(type) ; \
}

//------------------------------------------------------------------------------------
#define _encodeValue(value) \
{ \
    _guardBytes(sizeof(value)) ; \
    memcpy( p, &(value), sizeof(value) ) ;  \
    p += sizeof(value) ; \
}

//------------------------------------------------------------------------------------
// afageix un NSData
- (void)_encodeData:(NSData*)dta
{
    NSUInteger length = [dta length] ;
    _encodeScalar( NSUInteger, length ) ;
    _encodeBytes( [dta bytes], length ) ;
}


//------------------------------------------------------------------------------------
// afageix una string
- (void)_encodeString:(NSString*)str
{
    // codifiquem un puesto per posar la longitud més endevant
    _encodeScalar( CFIndex, 0 ) ;  

    // codifiquem la string per troços
    //CFIndex stringLength = CFStringGetLength((CFStringRef)str) ;
    CFIndex stringLength = [str length] ;
    CFIndex stringLoc = 0 ;
    CFIndex usedBuffLen = 0 ;
    CFIndex totalBuffLen = 0 ;
    while ( stringLoc < stringLength )
    {
        // per començar necesitarem assegurar un cert espai
        _guardBytes(ENCODED_STRING_CHUNK) ;
        
        // codifiquem un troç
        CFIndex convertedLen = CFStringGetBytes(
            (__bridge CFStringRef)str,      // the string
            CFRangeMake(stringLoc, stringLength-stringLoc),   // range 
            kCFStringEncodingUTF8,   // encoding
            '?',         // loss Byte
            false,     // is external representation
            p,          // buffer
            ENCODED_STRING_CHUNK,  // max buff length
            &usedBuffLen // used buff length
            ) ; 
            
        // actualitzem la nova posicio de caracters i de bytes, i la longitud de bytes
        stringLoc += convertedLen ;
        p += usedBuffLen ;
        totalBuffLen += usedBuffLen ;
    }
    
    // Finalment actualitzem la longitud codificada en bytes
    // que es troba sizeof(CFIndex) abans del començament de l'string
    // Atencio que no podem amagatzemar la posicio inicial perque el buffer
    // pot canviar de lloc en una de les cridades a _guardBytes
    *(CFIndex*)(p - totalBuffLen - sizeof(CFIndex)) = totalBuffLen ;
}


//------------------------------------------------------------------------------------
// afageix dos caracters
/*- (void)_encodeTwoChars:(const char *)cstr ;
{
    CFDataAppendBytes(data, (UInt8*)cstr, 2) ;
}
*/

//------------------------------------------------------------------------------------
// afageix un array o un set
- (void)_encodeCollection:(id)collection
{
    NSUInteger count = [collection count] ;
    _encodeScalar( NSUInteger, count ) ;
    if ( count > 0 ) for ( id element in collection )
    {
        [self _encodeObject:element] ;
    }
}


//------------------------------------------------------------------------------------
// afageix un diccionari
- (void)_encodeDictionary:(NSDictionary*)dict
{
    NSUInteger count = [dict count] ;
    _encodeScalar( NSUInteger, count ) ;
    if ( count > 0 ) for ( id key in dict )
    {
        id value = [dict objectForKey:key] ;
        [self _encodeObject:key] ;
        [self _encodeObject:value] ;
    }
}

//------------------------------------------------------------------------------------
// afageix un NSNumber
- (void)_encodeNumberVV:(NSNumber*)number
{
    CFNumberRef cfNum = (__bridge CFNumberRef)number ;
    CFIndex size = CFNumberGetByteSize( cfNum ) ;
    if ( size > sizeof(UInt32) ) NSAssert( false, @"Intent de Codificacio de NSNumber de longitud no suportada" );
    
    UInt32 value = 0 ;
    CFNumberType type = CFNumberGetType( cfNum ) ;
    CFNumberGetValue( cfNum, type, &value ) ;
    
    _encodeScalar( CFNumberType, type ) ;   // codifiquem el tipus
    _encodeValue( value ) ;  // codifiquem el valor
}

- (void)_encodeNumber:(NSNumber*)number
{
    CFNumberRef cfNum = (__bridge CFNumberRef)number ;
    CFIndex size = CFNumberGetByteSize( cfNum ) ;
    if ( size > sizeof(UInt64) ) NSAssert( false, @"Intent de Codificacio de NSNumber de longitud no suportada" );
    
    UInt64 value = 0 ;
    CFNumberType type = CFNumberGetType( cfNum ) ;
    CFNumberGetValue( cfNum, type, &value ) ;
    
    _encodeScalar( CFNumberType, type ) ;   // codifiquem el tipus
    _encodeValue( value ) ;  // codifiquem el valor
}


//------------------------------------------------------------------------------------
// afageix l'index de una classe
- (void)_encodeClassByIndexOrName:(Class)class
{
    // determina si ja tenim aquesta clase
    const void *value ;
    if ( CFDictionaryGetValueIfPresent( classIds, (__bridge void*)class, &value) ) // el diccionari conte parells {class,index}
    {
        // ja hi es, en codifica l'index
        CFIndex indx = (CFIndex)value ;
        _encodeScalar( char, '#' ) ;
        _encodeScalar( CFIndex, indx ) ;
        return ;
    }
        
    // no hi es, se l'apunta i en codifica el nom
    CFDictionaryAddValue( classIds, (__bridge void *)class, (void*)classCount ) ;
    classCount++ ;  
    _encodeScalar( char, '@' ) ;
    [self _encodeString:NSStringFromClass( class )] ;
}

//------------------------------------------------------------------------------------
// torna YES si pot codificar per id un objecte que ja s'ha codificat abans
- (BOOL)_maybeEncodeObjectByIndex:(id)object
{
    // determina si ja tenim aquesta clase
    const void *value ;
    if ( CFDictionaryGetValueIfPresent( objectIds, (__bridge CFTypeRef)object, &value) ) // el diccionari conte parells {id,index}
    {
        // ja hi es, en codifica l'index
        CFIndex indx = (CFIndex)value ;
        _encodeScalar( char, '%' ) ;
        _encodeScalar( CFIndex, indx ) ;
        return YES ;
    }
    return NO ;
}

//------------------------------------------------------------------------------------
// codifica un objecte que no es ni null ni kCFNull i que no s'ha codificat abans
- (void)_encodePrimitiveObject:(id)object
{
    // cas que es nil
    //if ( object == nil )
    //{
    //    _encodeScalar( char, 'n' ) ;
    //    return ;
    //}
    
    
    // cas que sigui un objecte que s'ha trobat previament el codifica per index
   // if ( [self _maybeEncodeObjectByIndex:object] )
   // {
   //     return ;
   // }

    // cas que es NSString
    if ( [object isKindOfClass:[NSString class]] )
    {
        _encodeScalar( char, 's' ) ;
        [self _encodeString:object] ;
        return ;
    }
    
    // cas que es NSArray
    if ( [object isKindOfClass:[NSArray class]] )
    {
        _encodeScalar( char, 'A' ) ;
        [self _encodeCollection:object] ;
        return ;
    }
    
    // cas que es un NSNumber
    if ( [object isKindOfClass:[NSNumber class]] )
    {
        _encodeScalar( char, 'N' ) ;
        [self _encodeNumber:object] ;
        return ;
    }
    
    // cas que es un NSDictionary
    if ( [object isKindOfClass:[NSDictionary class]] )
    {
        _encodeScalar( char, 'D' ) ;
        [self _encodeDictionary:object] ;
        return ;
    }
    
    // cas que es un NSSet
    if ( [object isKindOfClass:[NSSet class]] )
    {
        _encodeScalar( char, 'S' ) ;
        [self _encodeCollection:object] ;
        return ;
    }
    
    // cas que es un NSData
    if ( [object isKindOfClass:[NSData class]] )
    {
        _encodeScalar( char, 'd' ) ;
        [self _encodeData:object] ;
        return ;
    }

    
    // No es cap dels tipus suportats, se suposa doncs que implementa
    // el protocol QuickCoding
    // Codifiquem la classe de l'objecte i a continuació
    // apliquem encodeWithQuickCoder en el objecte
    
    [self _encodeClassByIndexOrName:[object class]] ;
    if ( isStore ) [object storeWithQuickCoder:self] ; 
    else [object encodeWithQuickCoder:self] ;
}


//------------------------------------------------------------------------------------
// codifica un objecte
- (void)_encodeObject:(id)object
{
    // cas que es nil
    if ( object == nil )
    {
        _encodeScalar( char, 'n' ) ;
        return ;
    }
    
    // cas que es un NSNull
    //if ( [object isKindOfClass:[NSNull class]] )
    if ( object == (void*)kCFNull )
    {
        _encodeScalar( char, 'o' ) ;
        return ;
    }
    
    // cas que sigui un objecte que s'ha trobat previament el codifica per index
    if ( [self _maybeEncodeObjectByIndex:object] )
    {
        return ;
    }
    
    // si no el codifica normal i se l'apunta
    CFDictionaryAddValue( objectIds, (__bridge void*)object, (void*)objectCount ) ;
    objectCount++ ;
    [self _encodePrimitiveObject:object] ;
    
    //if ( objectCount<50) NSLog1( @"_maybeEncodeObjectByIndex :%2d,%@", objectCount, object ) ;
    //CFDictionaryAddValue( objectIds, object, (void*)objectCount ) ;
    //objectCount++ ;

}

///////////////////////////////////////////////////////////////////////////////////////
#pragma mark QuickArchiver Public Methods
///////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------------
// inicialitza un Archiver per codificar en el NSMutableData subministrat
// si dta es nil en crea una
- (id)initForWritingWithMutableData:(NSMutableData *)dta version:(int)vers 
{
    if ( (self = [super init]) )
    {
        // treballem amb coreFoundation
        data = (__bridge CFMutableDataRef)dta ;
        
        // si no diem el contrari isStore es NO
        isStore = NO ;
        
        // si ens han passat null en creem una
        if ( data == NULL )
        {
            data = CFDataCreateMutable( NULL, 0 ) ;
            CFDataSetLength( data, DATA_INITIAL_LENGTH ) ;
        }
        
        // en cas contrari simplement la retenim
        else
        {
            CFRetain( data ) ;
        }
        
        // establim els punters i les coleccions de treball
        p = CFDataGetMutableBytePtr( data ) ;
        max = p + CFDataGetLength( data ) ;
        
        classIds = CFDictionaryCreateMutable(NULL, 0, NULL, NULL) ;  // no retain, no releases, unlimited
        classCount = 0 ;
        objectIds = CFDictionaryCreateMutable(NULL, 0, NULL, NULL) ;  // no retain, no releases, unlimited
        objectCount = 0 ;
        
        // codifiquem un identificador del fitxer, seguit de la longitut total de les dades, seguit de la versió
        _encodeBytes( "SWQ1", 4 ) ;
        _encodeScalar( uint32_t, 0 ) ; // ho actualitzarem al final (indicara la longitud total a partir del proxim SWQn)
        //_encodeBytes( "SWQ0", 4 ) ;  // codifiquem en swqVersion 0
        //_encodeBytes( "SWQ1", 4 ) ;  // codifiquem en swqVersion 1
        _encodeBytes( "QQ01", 4 ) ;  // codifiquem en swqVersion 1
        _encodeScalar( int, vers) ;
        
    }
    return self ;
}

//------------------------------------------------------------------------------------
- (void)setIsStore:(BOOL)value
{
    isStore = value ;
}

//------------------------------------------------------------------------------------
// Torna el resultat de la codificacio en un NSData
- (NSData *)archivedData
{
    // primer retalla data per ajustarse a la realitat codificada
    UInt8* begin = CFDataGetMutableBytePtr( data ) ;
    CFIndex actualLength = p - begin ;
    CFDataSetLength( data, actualLength ) ;
    
    // actualitza els punters per el cas que el usuari decideixi continuar codificant
    begin = CFDataGetMutableBytePtr( data ) ;
    p = begin + actualLength ;
    max = p ;
    
    // posem la longitud real de la part SWQ0 just despres de l'identificador (que ocupa 4 bytes)
    *(uint32_t*)(begin+4) = htonl(actualLength-SWQ1HEADER_LENGTH) ;
    
    // torna el data com un NSData que tindrà validesa despres del dealloc del QuickArchiver
    return (__bridge NSData*)data;
    //return [[(NSData *)data retain] autorelease] ;
}


//------------------------------------------------------------------------------------
// A cridar quan s'ha acabat de codificar
- (void)finishEncoding
{
    // simplement retalla data per ajustarse a la realitat codificada
    UInt8* begin = CFDataGetMutableBytePtr( data ) ;
    CFIndex actualLength = p - begin ;
    CFDataSetLength( data, p-begin ) ;
    
    // posem la longitud real de la part SWQ0 just despres de l'identificador (que ocupa 4 bytes)
    begin = CFDataGetMutableBytePtr( data ) ;
    *(uint32_t*)(begin+4) = htonl(actualLength-SWQ1HEADER_LENGTH) ;
}


//------------------------------------------------------------------------------------
- (void)dealloc
{
    if ( data ) CFRelease(data);
    if ( classIds ) CFRelease( classIds );
    if ( objectIds ) CFRelease( objectIds ); 
    //if ( classList ) CFRelease ( classList );
    //[super dealloc];  // arc
}


//------------------------------------------------------------------------------------
// codifica un objecte
- (void)encodeObject:(id)object
{
    [self _encodeObject:object] ;
}

//------------------------------------------------------------------------------------
// codifica un sencer
- (void)encodeInt:(int)value
{
    //_encodeTwoChars("$i") ;
    _encodeScalar( char, 'i' ) ;
    _encodeScalar( int, value) ;
}


//------------------------------------------------------------------------------------
// codifica un float
- (void)encodeFloat:(float)value
{
    _encodeScalar( char, 'f' ) ;
    _encodeValue( value ) ;
}


//------------------------------------------------------------------------------------
// codifica un double
- (void)encodeDouble:(double)value
{
    _encodeScalar( char, 'g' ) ;
    _encodeValue( value ) ;
}

//------------------------------------------------------------------------------------
// codifica una serie arbitraria de bytes
- (void)encodeBytes:(void*)bytes length:(size_t)length
{
    size_t encodedLength = 4*((length+3)/4);   // fem que la longitud codificada sigui multiple de 4
    _encodeScalar( char, '_' ) ;
    _encodeBytes( bytes, length ) ;
    if ( encodedLength-length > 0 )
    {
        UInt32 zero = 0;
        _encodeBytes( &zero, encodedLength-length);
    }
}

@end









///////////////////////////////////////////////////////////////////////////////////////
#pragma mark QuickUnarchiver
///////////////////////////////////////////////////////////////////////////////////////

@interface QuickUnarchiver()

//- (BOOL)_decodeNewString:(NSString **)str;
//- (BOOL)_decodeNewCollection:(Class)collectionClass collection:(id*)collection ;
//- (BOOL)_decodeNewDictionary:(NSMutableDictionary **)dict;
//- (BOOL)_decodeNewObject:(id*)object;
//
//- (BOOL)_retrieveObject:(id)object;

@end

//------------------------------------------------------------------------------------
@implementation QuickUnarchiver 


/*
//------------------------------------------------------------------------------------
- (void)decodeValueOfObjCType:(const char *)valueType at:(void *)address
{
    NSLog1( @"QuickUnArchiver decodeValueOfObjCType:%s at:%u", valueType, address ) ;
    // *((id *)address)=[self decodeObject];
    *((id *)address) = nil ;
}
*/


//------------------------------------------------------------------------------------
// extreu un long del buffer indicat
//#define _decodeLongValue(value) ( p + sizeof(long) <= max ? (value) = *(long *)p, p += sizeof(long), YES : NO )
#define _decodeScalar(type, value) ( p + sizeof(type) <= max ? (value) = *(type *)p, p += sizeof(type), YES : NO )
#define _decodeBytesPtr(bytes, length) ( p + (length) <= max ? (bytes) = p, p += (length), YES : NO )

#define _decodeBytesCpy(bytes, length) ( p + (length) <= max ? memcpy((bytes),p,(length)), p += (length), YES : NO )
#define _decodeValue(value) ( p + sizeof(value) <= max ? memcpy(&(value),p,sizeof(value)), p += sizeof(value), YES : NO )

/*
- (BOOL)_decodeLongValue:(unsigned long *)value
{
   // if ( p + sizeof(long) < max )
   // {
   //     *value = *(long *)p ;    // falta ajustar la endianness
   //     p += sizeof(long) ;
   //     return YES ;
   // }
   // return NO ;
    return ( p + sizeof(long) < max ? *value = *(long *)p, p += sizeof(long), YES : NO ) ;
}
*/



//------------------------------------------------------------------------------------
// afageix un NSData
- (BOOL)_decodeNewData:(CFDataRef*)dta
{
    NSUInteger length ;
    if ( _decodeScalar( NSUInteger, length ) )
    {
        if ( p + length <= max )
        {
            NSData *d = [[NSData alloc] initWithBytes:p length:length] ;
            *dta = (__bridge_retained CFDataRef)d ;
            p += length ;
            return YES ;
        }
    }
    return NO ;
}




//------------------------------------------------------------------------------------
// extreu una string, primer la longitud i despres els caracters com a utf8
// torna per referencia una nova string
- (BOOL)_decodeNewString:(CFStringRef*)string
{
    CFIndex length ;
    if ( _decodeScalar( CFIndex, length ) )
    {
        if ( p + length <= max )
        {
            //CFStringEncoding encoding = CFStringGetSystemEncoding () ;
            *string = CFStringCreateWithBytes(NULL, p, length, kCFStringEncodingUTF8, false) ;
            //*string = str ;
            //CFRelease( str ) ;
            p += length ;
            return YES ;
        }
    }
    return NO ;
}



//------------------------------------------------------------------------------------
// extreu una coleccio (NSArray o NSSet) de la longitud especificada
- (BOOL)_decodeNewCollection:(Class)collectionClass collection:(CFTypeRef*)collection
{
    NSUInteger count ;
    if ( _decodeScalar( NSUInteger, count ) )
    {
        id coll = [[collectionClass alloc] initWithCapacity:count] ;
        if ( swqVersion == 1 ) CFArrayAppendValue( objectIds, (__bridge CFTypeRef)coll ), objectCount++ ;
        NSUInteger i ;
        for ( i=0 ; i<count ; i++ )
        {
            CFTypeRef element ;
            if ( [self _decodeNewObject:&element] )
            {
                [coll addObject:(__bridge id)element] ;
                CFRelease(element) ;
            }
            else break ;
        }
        if ( i==count) 
        {
            *collection = (__bridge_retained CFTypeRef)coll ;
            return YES ;
        }
        // error
        //[coll release] ;   // ARC
    }
    return NO ;
}


//------------------------------------------------------------------------------------
// extreu un array, primer la longitud i despres els elements
// torna per referencia un nou array
- (BOOL)_decodeNewDictionary:(CFMutableDictionaryRef *)dict
{
    NSUInteger count ;
    if ( _decodeScalar( NSUInteger, count ) )
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:count] ; 
        if ( swqVersion == 1 ) CFArrayAppendValue( objectIds, (__bridge CFTypeRef)dic ), objectCount++ ;
        NSUInteger i ;
        for ( i=0 ; i<count ; i++ )
        {
            CFTypeRef key ;
            if ( [self _decodeNewObject:&key] )
            {
                CFTypeRef value ;
                if ( [self _decodeNewObject:&value] )
                {
                    [dic setObject:(__bridge id)value forKey:(__bridge id)key] ;
                    CFRelease( key ) ;
                    CFRelease( value ) ;   // ARC
                }
                else break ;
            }
            else break ;
        }
        if ( i==count) 
        {
            *dict = (__bridge_retained CFMutableDictionaryRef)dic ;
            return YES ;
        }
        // error
        //[dic release] ;  // ARC
    }
    return NO ;
}


//------------------------------------------------------------------------------------
// afageix un NSNumber
- (BOOL)_decodeNewNumberV:(CFNumberRef *)number
{
    CFNumberType type ;
    if ( _decodeScalar( CFNumberType, type ) )
    {
        UInt32 value ;
        if ( _decodeValue( value ) )
        {
            CFNumberRef cfNum = CFNumberCreate( NULL, type, &value ) ;
            *number = cfNum ;
            return YES ;
        }
    }
    return NO ;
}

//------------------------------------------------------------------------------------
// afageix un NSNumber
- (BOOL)_decodeNewNumber:(CFNumberRef *)number
{
    CFNumberType type ;
    if ( _decodeScalar( CFNumberType, type ) )
    {
        UInt64 value=0 ;
        if ( _decodeValue( value ) )
        {
            CFNumberRef cfNum = CFNumberCreate( NULL, type, &value ) ;
            *number = cfNum ;
            return YES ;
        }
    }
    return NO ;
}


//------------------------------------------------------------------------------------
// decodifica un objecte que implementa QuickCoding que es del tipus
// determinat per un nom de classe
- (BOOL)_decodeNewObjectOfClassByName:(CFTypeRef *)object
{
    CFStringRef className ;
    if ( [self _decodeNewString:&className] ) 
    {
        // determina la classe a partir del nom i la amagatzema al final del array
        Class class = NSClassFromString((__bridge NSString*)className) ;
        //[className release] ;  // ARC className ja no el necesitem
        CFRelease( className ) ; // className ja no el necesitem
        if ( class )
        {
            CFArrayAppendValue( classIds, (__bridge void*)class ), classCount++ ; // amagatzem la classe al final del array
            id obj = [class alloc] ;
            if ( swqVersion == 1 ) CFArrayAppendValue( objectIds, (__bridge CFTypeRef)obj ), objectCount++ ;
            
            (void)[obj initWithQuickCoder:self] ;
            *object = (__bridge_retained CFTypeRef)obj ;
            return YES ;
        }
    }
    return NO ;
}

//------------------------------------------------------------------------------------
// decodifica un objecte que implementa QuickCoding que es del tipus
// determinat per un index de classe
- (BOOL)_decodeNewObjectOfClassByIndex:(CFTypeRef*)object
{
    CFIndex indx ;
    if ( _decodeScalar( CFIndex, indx ) && indx < classCount )
    {
        Class class = (__bridge Class)CFArrayGetValueAtIndex( classIds, indx ) ; // extreu la classe amb aquest index
        id obj = [class alloc] ; 
        if ( swqVersion == 1 ) CFArrayAppendValue( objectIds, (__bridge CFTypeRef)obj ), objectCount++ ;
        (void)[obj initWithQuickCoder:self] ;
        *object = (__bridge_retained CFTypeRef)obj ;
        return YES ;
    }
    return NO ;
}

////------------------------------------------------------------------------------------
//// decodifica un objecte que implementa QuickCoding que es del tipus
//// determinat per un index de classe
//- (BOOL)_decodeRetainedObjectByIndex:(id*)object
//{
//    CFIndex indx ;
//    if ( _decodeScalar( CFIndex, indx ) && indx < objectCount )
//    {
//        id obj = (id)CFArrayGetValueAtIndex( objectIds, indx ) ; // extreu el objecte amb aquest index
//        *object = [obj retain] ;
//        return YES ;
//    }
//    return NO ;
//}


//------------------------------------------------------------------------------------
// decodifica un objecte que implementa QuickCoding que es del tipus
// determinat per un index de classe
- (BOOL)_decodeRetainedObjectByIndex:(CFTypeRef*)object
{
    CFIndex indx ;
    if ( _decodeScalar( CFIndex, indx ) && indx < objectCount )
    {        
        CFTypeRef obj = CFArrayGetValueAtIndex( objectIds, indx ) ; // extreu el objecte amb aquest index 
        CFRetain(obj);
        *object = obj;
        
        return YES ;
    }
    return NO ;
}



//------------------------------------------------------------------------------------
- (BOOL)_decodePrimitiveNewObject:(CFTypeRef*)object
{
    // en aquest punt hi ha d'haver un caracter indicatiu
    // de l'objecte
    if ( p < max )
    {        
        // es un objecte de una classe codificada per index
        if ( *p == '#' )
        {
            p++ ;
            return [self _decodeNewObjectOfClassByIndex:object] ;
        }
        
        // es una string
        if ( *p == 's' )
        {
            p++ ;
            if ( [self _decodeNewString:(CFStringRef*)object] )
            {
                if ( swqVersion == 1 ) CFArrayAppendValue( objectIds, (*object) ), objectCount++ ;
                return YES ;
            }
            return NO ;
        }
        
        // es un array
        if ( *p == 'A' )
        {
            p++ ;
            return [self _decodeNewCollection:[NSMutableArray class] collection:object] ;
        }
        
        // es un NSNumber
        if ( *p == 'N' )
        {
            p++ ;
            if ( [self _decodeNewNumber:(CFNumberRef*)object] )
            {
                if ( swqVersion == 1 ) CFArrayAppendValue( objectIds, (*object) ), objectCount++ ;
                return YES ;
            }
        }
        
        // es un dictionary
        if ( *p == 'D' )
        {
            p++ ;
            return [self _decodeNewDictionary:(CFMutableDictionaryRef*)object] ;
        }
        
        // es un set
        if ( *p == 'S' )
        {
            p++ ;
            return [self _decodeNewCollection:[NSMutableSet class] collection:object] ;
        }
        
        // es un data
        if ( *p == 'd' )
        {
            p++ ;
            if ( [self _decodeNewData:(CFDataRef*)object] )
            {
                if ( swqVersion == 1 ) CFArrayAppendValue( objectIds, (*object) ), objectCount++ ;
                return YES ;
            }
            return NO ;
        }
    
        // es un objecte de una clase codificada per nom
        if ( *p == '@' )
        {
            p++ ;
            return [self _decodeNewObjectOfClassByName:object] ;
        }
    }
    return NO ;
}



//------------------------------------------------------------------------------------
- (BOOL)_decodeNewObject:(CFTypeRef*)object
{
    // en aquest punt hi ha d'haver un caracter indicatiu
    // de l'objecte
    if ( p < max )
    {        
        // es nil
        if ( *p == 'n' )
        {
            p++ ;
            *object = nil ;
            return YES ;
        }
            
        // es un NSNull
        if ( *p == 'o' )
        {
            p++ ;
            *object = (void *)kCFNull ;
            return YES ;
        }
        
        // es un objecte ja descodificat previament
        if ( *p == '%' )
        {
            p++ ;
            return [self _decodeRetainedObjectByIndex:object] ;
        }

        
        // es un objecte nou, el descodifiquem i ens l'apuntem
        //CFArrayAppendValue( objectIds, *object ) ;  // amagatzem el objecte al final del array
        //objectCount++ ;
        if ( [self _decodePrimitiveNewObject:object] )
        {
            if ( swqVersion == 0 )
            {
                CFArrayAppendValue( objectIds, (*object) ) ;  // amagatzem el objecte al final del array
                objectCount++ ;
            }
            return YES ;
        }
    }
    return NO ;
}








///////////////////////////////////////////////////////////////////////////////////////
#pragma mark QuickUnarchiver Retrieval Methods
///////////////////////////////////////////////////////////////////////////////////////




//------------------------------------------------------------------------------------
// retreu un NSData, simplement comprova que es un nsdata i se salta la longitud
- (BOOL)_retrieveData:(NSData*)dta
{
    if ( [dta isKindOfClass:[NSData class]]  )
    {
        NSUInteger length ;
        if ( _decodeScalar( NSUInteger, length ) )
        {
            p += length ;
            return YES ;
        }
    }
    return NO ;
}


//------------------------------------------------------------------------------------
// retreu una string, comprova que es string i salta la longitud
- (BOOL)_retrieveString:(NSString *)string
{
    if ( [string isKindOfClass:[NSString class]]  )
    {
        CFIndex length ;
        if ( _decodeScalar( CFIndex, length ) )
        {
            p += length ;
            return YES ;
        }
    }
    return NO ;
}


//------------------------------------------------------------------------------------
// retreu una coleccio (NSArray o NSSet) de la longitud especificada
// comprova el tipus de la coleccio i envia retrieveObject als elements
- (BOOL)_retrieveCollection:(Class)collectionClass collection:(id)collection
{
    if ( [collection isKindOfClass:collectionClass] )
    {
        NSUInteger count ;
        if ( _decodeScalar( NSUInteger, count ) )
        {
            NSUInteger collCount = [collection count] ;
            if ( count == collCount )
            { 
                //id coll = [[collectionClass alloc] initWithCapacity:count] ;
                if ( swqVersion == 1 ) CFArrayAppendValue( objectIds, (__bridge CFTypeRef)collection ), objectCount++ ;
                for ( id element in collection )
                {
                    if ( ! [self _retrieveObject:element] )
                    {
                        return NO ;
                    }
                }
                return YES ;
            }
        }
    }
    return NO ;
}


//------------------------------------------------------------------------------------
// retreu un diccionari, passa retrieve a
// torna per referencia un nou array
- (BOOL)_retrieveDictionary:(NSMutableDictionary *)dict
{
    if ( [dict isKindOfClass:[NSDictionary class]]  )
    {
        NSUInteger count ;
        if ( _decodeScalar( NSUInteger, count ) )
        {
            NSUInteger dicCount = [dict count] ;
            if ( count == dicCount )
            {
                if ( swqVersion == 1 ) CFArrayAppendValue( objectIds, (__bridge CFTypeRef)dict ), objectCount++ ;
                for ( id key in dict )
                {
                    if ( [self _retrieveObject:key] )
                    {
                        id value = [dict objectForKey:key] ;
                        if ( [self _retrieveObject:value] )
                        {
                            //ok continuem
                        }
                        else return NO ;
                    }
                    else return NO ;
                }
                return YES ;
            }
        }
    }
    return NO ;
}


//------------------------------------------------------------------------------------
// retreu un NSNumber, comprova que es numero i salta la longitud
- (BOOL)_retrieveNumber:(NSNumber *)number
{
    if ( [number isKindOfClass:[NSNumber class]]  )
    {
        CFNumberType type ;
        if ( _decodeScalar( CFNumberType, type ) )
        {
            UInt32 value ;
            if ( _decodeValue( value ) )
            {
                return YES ;
            }
        }
    }
    return NO ;
}

//------------------------------------------------------------------------------------
// decodifica un objecte que implementa QuickCoding que es del tipus
// determinat per un nom de classe
- (BOOL)_retrieveObjectOfClassByName:(id)object
{
    CFStringRef className ;
    if ( [self _decodeNewString:&className] ) 
    {
        // determina la classe a partir del nom i la amagatzema al final del array
        Class class = NSClassFromString((__bridge NSString*)className) ;
        //[className release] ;  // ARC className ja no el necesitem
        CFRelease( className ); // className ja no el necesitem
        Class obClass = [object class] ;
        if ( class == obClass  )
        {
            CFArrayAppendValue( classIds, (__bridge void*)class ), classCount++ ; // amagatzem la classe al final del array
            if ( swqVersion == 1 ) CFArrayAppendValue( objectIds, (__bridge CFTypeRef)object ), objectCount++ ;
            [object retrieveWithQuickCoder:self] ;
            return YES ;
        }
    }
    return NO ;
}

//------------------------------------------------------------------------------------
// decodifica un objecte que implementa QuickCoding que es del tipus
// determinat per un index de classe
- (BOOL)_retrieveObjectOfClassByIndex:(id)object
{
    CFIndex indx ;
    if ( _decodeScalar( CFIndex, indx ) && indx < classCount )
    {
        Class class = (__bridge Class)CFArrayGetValueAtIndex( classIds, indx ) ; // extreu la classe amb aquest index
        Class obClass = [object class] ;
        if ( class == obClass )
        {
            if ( swqVersion == 1 ) CFArrayAppendValue( objectIds, (__bridge CFTypeRef)object ), objectCount++ ;
            [object retrieveWithQuickCoder:self] ;
            return YES ;
        }
    }
    return NO ;
}

//------------------------------------------------------------------------------------
// decodifica un objecte que implementa QuickCoding que es del tipus
// determinat per un index de classe
- (BOOL)_retrieveObjectByIndex:(id)object
{
    CFIndex indx ;
    if ( _decodeScalar( CFIndex, indx ) && indx < objectCount )
    {
        id obj = (__bridge Class)CFArrayGetValueAtIndex( objectIds, indx ) ; // extreu el objecte amb aquest index
        if ( obj == object )
        {
            return YES ;
        }
    }
    return NO ;
}

//------------------------------------------------------------------------------------
- (BOOL)_retrievePrimitiveObject:(id)object
{
    // en aquest punt hi ha d'haver un caracter indicatiu
    // de l'objecte
    //if ( p+2 <= max && *p++ == '$' )
    if ( p < max )
    {        
        // es un objecte de una classe codificada per index
        if ( *p == '#' )
        {
            p++ ;
            return [self _retrieveObjectOfClassByIndex:object] ;
        }
        
        // es una string
        if ( *p == 's' )
        {
            p++ ;
            if ( [self _retrieveString:object] )
            {
                if ( swqVersion == 1 ) CFArrayAppendValue( objectIds, (__bridge CFTypeRef)object ), objectCount++ ;
                return YES ;
            }
            return NO ;
        }
        
        // es un array
        if ( *p == 'A' )
        {
            p++ ;
            return [self _retrieveCollection:[NSArray class] collection:object] ;
        }
        
        // es un dictionary
        if ( *p == 'D' )
        {
            p++ ;
            return [self _retrieveDictionary:object] ;
        }
        
        // es un NSNumber
        if ( *p == 'N' )
        {
            p++ ;
            if ( [self _retrieveNumber:object] )
            {
                if ( swqVersion == 1 ) CFArrayAppendValue( objectIds, (__bridge CFTypeRef)object ), objectCount++ ;
                return YES ;
            }
        }
        
        // es un set
        if ( *p == 'S' )
        {
            p++ ;
            return [self _retrieveCollection:[NSSet class] collection:object] ;
        }
        
        // es un data
        if ( *p == 'd' )
        {
            p++ ;
            if ( [self _retrieveData:object] )
            {
                if ( swqVersion == 1 ) CFArrayAppendValue( objectIds, (__bridge CFTypeRef)object ), objectCount++ ;
                return YES ;
            }
            return NO ;
        }
    
        // es un objecte de una clase codificada per nom
        if ( *p == '@' )
        {
            p++ ;
            return [self _retrieveObjectOfClassByName:object] ;
        }
    }
    return NO ;
}



//------------------------------------------------------------------------------------
- (BOOL)_retrieveObject:(id)object
{
    // en aquest punt hi ha d'haver un caracter indicatiu
    // de l'objecte
    //if ( p+2 <= max && *p++ == '$' )
    if ( p < max )
    {        
        // es nil
        if ( *p == 'n' )
        {
            p++ ;
            return ( object == nil ) ;
        }
            
        // es un NSNull
        if ( *p == 'o' )
        {
            p++ ;
            return ( object == (void *)kCFNull ) ;
        }
        
        // es un objecte ja descodificat previament
        if ( *p == '%' )
        {
            p++ ;
            return [self _retrieveObjectByIndex:object] ;
        }

        
        // es un objecte nou, el descodifiquem i ens l'apuntem
        //CFArrayAppendValue( objectIds, *object ) ;  // amagatzem el objecte al final del array
        //objectCount++ ;
        if ( [self _retrievePrimitiveObject:object] )
        {
            if ( swqVersion == 0 )
            {
                CFArrayAppendValue( objectIds, (__bridge CFTypeRef)object ) ;  // amagatzem el objecte al final del array
                objectCount++ ;
            }
            return YES ;
        }
    }
    return NO ;
}




///////////////////////////////////////////////////////////////////////////////////////
#pragma mark QuickUnarchiver Public Methods
///////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------------
+ (uint32_t)SWQ0LengthForSWQ1Data:(NSData*)dta
{
    NSUInteger length = [dta length] ;
    if ( length < SWQ1HEADER_LENGTH ) return 0 ;
    
    const UInt8 *bytes = [dta bytes] ;
    if ( 0 != memcmp( bytes, "SWQ1", 4 ) ) return 0 ;
    
    uint32_t result = ntohl( *(uint32_t*)(bytes+4) ) ;
    return result ;
}


//------------------------------------------------------------------------------------
- (id)initForReadingWithData:(NSData *)dta
{   
    if ( (self = [super init]) )
    {
        // obte els punters i crea les coleccions
        data = (__bridge CFDataRef)dta ;
        p = (UInt8*)CFDataGetBytePtr( data ) ;
        max = p + CFDataGetLength( data ) ;
        classIds = CFArrayCreateMutable( NULL, 0, NULL ) ; // unlimited, no retains, no releases, 
        classCount = 0 ;
        //objectIds = CFArrayCreateMutable( NULL, 0, NULL ) ; // unlimited, no retains, no releases, 
        objectIds = CFArrayCreateMutable( NULL, 0, &kCFTypeArrayCallBacks ) ; // unlimited, with retains, releases, 
        objectCount = 0 ;
        
        // obte l'identificador i la versio
        
        swqVersion = -1 ;
        const UInt8 *b ;
        BOOL done = _decodeBytesPtr( b, 4 ) ;
        
        if ( done && 0==memcmp( b, "SWQ1", 4 ) )
        {
            uint32_t dummyLength ;
            done = _decodeScalar( uint32_t, dummyLength ) ; 
            done = done && _decodeBytesPtr( b, 4 ) ;
        }
        
        if ( done )
        {
            if ( 0==memcmp( b, "QQ01", 4 ) ) swqVersion = 1 ;
            else if ( 0==memcmp( b, "SWQ1", 4 ) ) swqVersion = 1 ;
            else if ( 0==memcmp( b, "SWQ0", 4 ) ) swqVersion = 0 ;
            if ( swqVersion >= 0 )
            {
                done = _decodeScalar( int, version ) ;
            }
        }

        
        if ( !done )
        {
            //[self release] ;    // ARC
            return nil ;
        }
    }
    return self ;
}


//------------------------------------------------------------------------------------
- (void)dealloc
{
    if ( classIds ) CFRelease( classIds ) ;
    if ( objectIds ) CFRelease( objectIds ) ;
    //[super dealloc] ;   // ARC
}

//------------------------------------------------------------------------------------
- (int)version
{
    return version ;
}

//------------------------------------------------------------------------------------
- (id)decodeObject
{
    CFTypeRef object ;
    if ( [self _decodeNewObject:&object] )
    {
        //ARC return [object autorelease] ;
        
        return (__bridge_transfer id)object;
    }
    return nil ;
}

//------------------------------------------------------------------------------------
- (int)decodeInt
{
    if ( p < max && *p == 'i' )
    {
        p++ ;
        int value ;
        if ( _decodeScalar( int, value ) )
        {
            return value ;
        }
    }
    return 0 ;
}

/*
//------------------------------------------------------------------------------------
- (float)decodeFloatv
{
    if ( p < max && *p == 'f' )
    {
        p++ ;
        UInt32 uvalue ;
        if ( _decodeScalar( UInt32, uvalue ) )
        {
            float value = *(float*)&uvalue ;   // no va en LLVM 2.1
            return value ;
        }
    }
    return 0.0f ;
}
*/

//------------------------------------------------------------------------------------
- (float)decodeFloat
{
    if ( p < max && *p == 'f' )
    {
        p++ ;
        float value ;
        //if ( _decodeBytesCpy( &value, sizeof(float) ) )
        if ( _decodeValue( value ) )
        {
            return value ;
        }
    }
    return 0.0f ;
}


//------------------------------------------------------------------------------------
- (double)decodeDouble
{
    if ( p < max && *p == 'g' )
    {
        p++ ;
        double value ;
        //if ( _decodeBytesCpy( &value, sizeof(double) ) )
        if ( _decodeValue( value ) )
        {
            return value ;
        }
    }
    return 0.0 ;
}

//------------------------------------------------------------------------------------
- (void)decodeBytes:(void*)bytes length:(size_t)length
{
    if ( p < max && *p == '_' )
    {
        p++ ;
        size_t encodedLength = 4*((length+3)/4);   // la longitud descodificada es multiple de 4
        (void)_decodeBytesCpy(bytes, length) ;
        if ( encodedLength-length > 0 )
        {
            UInt8 *dummy;
            (void)_decodeBytesPtr(dummy, encodedLength-length);
        }
    }
}

/*
//------------------------------------------------------------------------------------
- (double)decodeDoubleV
{
    if ( p < max && *p == 'g' )
    {
        p++ ;
        Double num ;
        if ( _decodeScalar( UInt32, num.part.a ) )
        {
            if ( _decodeScalar( UInt32, num.part.b ) )
            {
                return num.d ;
            }
        }
    }
    return 0.0 ;
}
*/

//------------------------------------------------------------------------------------
- (BOOL)retrieveForObject:(id)object
{
    if ( [self _retrieveObject:object] )
    {
        return YES ;
    }
    return NO ;
}




@end



