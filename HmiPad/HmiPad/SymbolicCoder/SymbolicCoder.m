//
//  SymbolicCoder.m
//  HmiPad
//
//  Created by Joan on 26/02/12.
//  Copyright (c) 2012 SweetWilliam, S.L.. All rights reserved.
//

#import "SymbolicCoder.h"
#import "SWExpression.h"
#import "RpnBuilder.h"
#import "pair.h"

#define DATA_INITIAL_LENGTH 256
#define DATA_LENGTH_INCREMENT 1024

#define ENCODED_STRING_CHUNK 96


///////////////////////////////////////////////////////////////////////////////////////
#pragma mark Encoder Helper Object
///////////////////////////////////////////////////////////////////////////////////////

/*
@interface ObjectInfo : NSObject
 @property (nonatomic, assign) Class class;
 @property (nonatomic, retain) NSString *ident;
 @property (nonatomic, assign) NSArray *properties;
 @property (nonatomic, assign) NSArray *values;
@end

@implementation ObjectInfo
 @synthesize class, ident, properties, values;
- (void)dealloc
{
    [ident release];
    [properties release];
}
@end
*/


@interface _SObject : NSObject
{
    NSString *ident;
    id<SymbolicCoding> object; 
}
@end

@implementation _SObject

- (id)initWithIdent:(NSString *)iden object:(id<SymbolicCoding>)obj
{
    self = [super init];
    if ( self )
    {
        //ident = [iden retain];
        //object = [obj retain];
        ident = iden;
        object = obj;
    }
    return self;
}

/*
- (void)setIdent:(NSString *)iden
{
    if ( iden == ident ) return;
    [ident release];
    ident = [iden retain];
}
*/


- (NSString*)ident
{
    return ident;
}

- (id<SymbolicCoding>)object
{
    return object;
}

- (void)dealloc
{
//    [ident release];
//    [object release];
//    [super dealloc];
}

@end


@interface _SObjects : NSObject
{
    NSString *ident;
    CFMutableArrayRef objects; // conte _Object
}
@end

@implementation _SObjects

- (id)initWithIdent:(NSString *)iden
{
    self = [super init];
    if ( self )
    {
//        ident = [iden retain];
        ident = iden;
    }
    return self;
}


- (NSString*)ident
{
    return ident;
}


- (_SObject *)addObject:(id<SymbolicCoding>)object withKey:(NSString*)key enumeration:(int)indx;
{
    if ( object == nil ) return nil;

    NSString *identifier = nil;
    if ( [object respondsToSelector:@selector(symbolicIdentifier)] )
    {
//        identifier = [[object symbolicIdentifier] retain];
        identifier = [object symbolicIdentifier];
    }
    else
    {
        if ( indx > 0 ) 
            identifier = [[NSString alloc] initWithFormat:@"%@_%@%d", ident, key, indx];
        else
            identifier = [[NSString alloc] initWithFormat:@"%@_%@", ident, key];
    }

    _SObject *sob = [[_SObject alloc] initWithIdent:identifier object:object];
//    [identifier release];

    if ( objects == NULL ) objects = CFArrayCreateMutable( NULL, 0, &kCFTypeArrayCallBacks );
    CFArrayAppendValue( objects, (__bridge CFTypeRef)sob );
//    [sob release];
    
    return sob;   // retingut per el array
}

- (void)enumerateUsingBlock:(void (^)( _SObject * ))block
{
    if ( objects == NULL ) return;
    int count = CFArrayGetCount( objects );
    for ( int i=0; i<count; i++ )
    {
        __unsafe_unretained _SObject *object = (__bridge id)CFArrayGetValueAtIndex( objects, i );
        block( object );
    }
}

- (void)dealloc
{
//    [ident release];
    if ( objects ) CFRelease( objects );
//    [super dealloc];
}

@end



///////////////////////////////////////////////////////////////////////////////////////
#pragma mark StringEncoding Helper Functions
///////////////////////////////////////////////////////////////////////////////////////

const static Pair EncodingPairs[] =
{
    { "UTF-8", kCFStringEncodingUTF8 },
    { "UTF8", kCFStringEncodingUTF8 },
    { "MacRoman", kCFStringEncodingMacRoman },
    { "WindowsLatin1", kCFStringEncodingWindowsLatin1 },
    { "Cyrillic/Mac", kCFStringEncodingMacCyrillic },
    { "Cyrillic/Win", kCFStringEncodingWindowsCyrillic },
    { "Cyrillic/ISO", kCFStringEncodingISOLatinCyrillic },
    { "Japanese/Mac", kCFStringEncodingMacJapanese },
    { "Japanese/Win", kCFStringEncodingDOSJapanese },
    { "Japanese/JIS", kCFStringEncodingShiftJIS_X0213 },
    { "Chinese/Mac", kCFStringEncodingMacChineseSimp },
    { "Chinese/Win", kCFStringEncodingDOSChineseSimplif },
    { "Chinese/GB2312", kCFStringEncodingGB_2312_80 },
};

const static int EncodingPairsCount = sizeof(EncodingPairs)/sizeof(Pair);


static int _getCStringFromEncoding_outCString( CFStringEncoding stringEncoding, const unsigned char** cStringPtr )
{
    *cStringPtr = PairPtrForNumber(EncodingPairs, EncodingPairsCount, stringEncoding);
    int len = strlen( (const char*) *cStringPtr );
    return len;
}

static CFStringEncoding _getEncodingFromCString_len( const unsigned char *cStr, size_t len )
{
     for ( int i=0 ; i<EncodingPairsCount ; i++ )
        if ( 0 == strncmp(EncodingPairs[i].ptr, (const char*)cStr, len))
            if ( len == strlen(EncodingPairs[i].ptr))
                return EncodingPairs[i].number;
    return kCFStringEncodingInvalidId;
}


///////////////////////////////////////////////////////////////////////////////////////
#pragma mark Encode Helper Functions
///////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------------
static void increaseDataLength( CFMutableDataRef data, UInt8 **pRef, UInt8 **maxRef, CFIndex size )
{
    CFIndex increment = (size/DATA_LENGTH_INCREMENT + 1)*DATA_LENGTH_INCREMENT;
    
    size_t offset = *pRef - CFDataGetMutableBytePtr( data );
    CFDataIncreaseLength( data, increment );
    
    UInt8* begin = CFDataGetMutableBytePtr( data );
    *pRef = begin + offset;
    *maxRef = begin + CFDataGetLength( data );
}




//------------------------------------------------------------------------------------
@implementation SymbolicArchiver

///////////////////////////////////////////////////////////////////////////////////////
#pragma mark SymbolicArchiver Private Methods
///////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------------
#define _guardBytes(size) if (p+(size) > max) increaseDataLength( data, &p, &max, size )

//------------------------------------------------------------------------------------
#define _genChars(bytes,length) \
{ \
    _guardBytes(length); \
    memcpy( p, (bytes), (length) ); \
    p += (length); \
}

//------------------------------------------------------------------------------------
#define _genChar(ch) \
{ \
    _guardBytes(1); \
    *p++ = (ch);  \
}

//------------------------------------------------------------------------------------
#define _genNS(string) [self _genString:(string)]
#define _genNewLine _genChars( "\n", 1 )

//------------------------------------------------------------------------------------
#define push(ident) CFArrayInsertValueAtIndex( stack, 0, (__bridge CFTypeRef)(ident) )
#define pop() CFArrayRemoveValueAtIndex( stack, 0 )
#define top() ((__bridge id)CFArrayGetValueAtIndex( stack, 0 ))



//------------------------------------------------------------------------------------
// afageix una string
- (void)_genString:(NSString*)str
{
    // codifiquem la string per troços
    //CFIndex stringLength = CFStringGetLength((CFStringRef)str);
    CFIndex stringLength = [str length];
    CFIndex stringLoc = 0;
    CFIndex usedBuffLen = 0;
    CFIndex totalBuffLen = 0;
    while ( stringLoc < stringLength )
    {
        // per començar necesitarem assegurar un cert espai
        _guardBytes(ENCODED_STRING_CHUNK);
        
        // codifiquem un troç
        CFIndex convertedLen = CFStringGetBytes(
            (__bridge CFStringRef)str,      // the string
            CFRangeMake(stringLoc, stringLength-stringLoc),   // range 
            //kCFStringEncodingUTF8,   // encoding
            stringEncoding,   // encoding
            '?',         // loss Byte
            false,     // is external representation
            p,          // buffer
            ENCODED_STRING_CHUNK,  // max buff length
            &usedBuffLen // used buff length
            ); 
            
        // actualitzem la nova posicio de caracters i de bytes, i la longitud de bytes
        stringLoc += convertedLen;
        p += usedBuffLen;
        totalBuffLen += usedBuffLen;
    }
    
    // Finalment actualitzem la longitud codificada en bytes
    // que es troba sizeof(CFIndex) abans del començament de l'string
    // Atencio que no podem amagatzemar la posicio inicial perque el buffer
    // pot canviar de lloc en una de les cridades a _guardBytes
    //*(CFIndex*)(p - totalBuffLen - sizeof(CFIndex)) = totalBuffLen;
}




//------------------------------------------------------------------------------------
// afageix una string
- (void)_genScapedString:(NSString*)str
{
    // codifiquem la string per troços
    //CFIndex stringLength = CFStringGetLength((CFStringRef)str);
    CFIndex stringLength = [str length];
    
    UniChar characters[stringLength];
    CFStringGetCharacters((__bridge CFStringRef)str, CFRangeMake(0, stringLength), characters);
    
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
                _genNS(CFBridgingRelease(substr));
            }
            _genChars( "\\\"", 2);
            lastI = i+1;
        }
    }
    
    if ( i > lastI )
    {
        CFStringRef substr = CFStringCreateWithCharactersNoCopy(nil, characters+lastI, i-lastI, kCFAllocatorNull);
        _genNS(CFBridgingRelease(substr));
    }
}








//------------------------------------------------------------------------------------
- (void)_genKey:(NSString*)ident
{

}

//------------------------------------------------------------------------------------
- (void)_genPropertyForKey:(NSString *)key withBody:(void (^)(void))block
{
    _SObjects *sobs = top();
    NSString *ident = [sobs ident];
    
    _genNS( ident );
    if ( key )
    {
        _genChar( '.' );
        _genNS( key );
    }
    _genChars( " = ", 3 );
    block();
    _genChar( ';' );
    _genNewLine;
}





- (void)_genPendingObjects
{
    _SObjects *ssobs = top();
    [ssobs enumerateUsingBlock:^(_SObject *sob)
    {
        _genNewLine;
        
        //NSString *ident = [object identifier];
        NSString *ident = [sob ident];
        id<SymbolicCoding>object = [sob object];
        
        _SObjects *sobs = [[_SObjects alloc] initWithIdent:ident];
        push( sobs );
//        [sobs release];
    
        [self _genPropertyForKey:nil withBody:^
        {
            _genNS( NSStringFromClass( [object class] ) );
            _genChars( ".new", 4 );
        }];
        
        if ( isStore ) [object storeWithSymbolicCoder:self];
        else [object encodeWithSymbolicCoder:self];
        [self _genPendingObjects];
        pop();
   
    }];
}


- (void)_genObject:(id<SymbolicCoding>)object forKey:(NSString *)key    // REVISAR: Ha de ser similar a _genCollection o treure
{
    [self _genPropertyForKey:key withBody:^
    {
        _SObjects *sobs = top();
        _SObject *sob = [sobs addObject:object withKey:key enumeration:0];
        
        _genChars( "SWObject", 8 );
        _genChars( ".new(", 5  );
    
        //NSString *objIdent = [object identifier];
        NSString *objIdent = [sob ident];
        _genNS( objIdent );
        
        _genChar( ')' );
    }];
}



- (void)_genCollection:(NSArray *)collection forKey:(NSString *)key
{
    [self _genPropertyForKey:key withBody: ^
    {
        _SObjects *sobs = top();
        
        _genChars( "SWCollection", 12 );
        _genChars( ".new(", 5  );
        int indx = 0;
        for ( id<SymbolicCoding>object in collection )
        {
            _SObject *sob = [sobs addObject:object withKey:key enumeration:indx+1];
            if ( indx++ > 0 ) _genChar( ',' );
            if ( indx%8 == 0 )
            {
                _genNewLine;
                _genChars( "    ", 4 );
            }
            else
            {
                if ( indx>1) _genChar( ' ' );
            }
            //NSString *objIdent = [object identifier];
            NSString *objIdent = [sob ident];
            _genNS( objIdent );
        }
        _genChar( ')' );
    }];
}




//- (void)_genValue:(SWValue*)value forKey:(NSString*)key
//{
//    SWValueType type = value.valueType;
//    
//    switch (type)
//    {
//        case SWValueTypeNumber:
//            [self _genDouble:value.valueAsDouble forKey:key];
//            break;
//            
//        case SWValueTypePoint:
//            [self _genPoint:value.valueAsCGPoint forKey:key];
//            break;
//            
//        case SWValueTypeSize:
//            [self _genSize:value.valueAsCGSize forKey:key];
//            break;
//            
//        case SWValueTypeRect:
//            [self _genRect:value.valueAsCGRect forKey:key];
//            break;
//            
//        case SWValueTypeObject:
//            [self _genObject:value.valueAsObject forKey:key];
//            break;
//            
//        case SWValueTypeString:
//            [self _genString:[value valueAsStringWithFormat:nil] forKey:key];
//            break;
//            
//        default :
//            [self _genInt:0 forKey:key];
//            break;
//    }
//}



//- (void)_genExpression:(SWExpression*)expr forKey:(NSString *)key
//{
//    [self _genPropertyForKey:key withBody: ^
//    {
//        _genNS( [expr getSourceString] );
//    }];
//}


//- (void)_genAbTimeWrapper:(NSString*)atString
//{
//    _genChars( "SWAbsoluteTime", 14 );
//    _genChars( ".new(", 5 );
//    _genNS( atString );
//    _genChar( ')' );
//}


// codifica un SWValue o un SWExpression,
- (void)_genValue:(SWValue*)value forKey:(NSString *)key
{
    SWValueType type = value.valueType;

    if ( type == SWValueTypeObject )
    {
        [self _genObject:value.valueAsObject forKey:key];
        return;
    }

    [self _genPropertyForKey:key withBody: ^
    {
        if ( isStore ) _genNS( [value getValueSourceString] );
        else _genNS( [value getSourceString] );
    }];
}


- (void)_genString:(NSString *)str forKey:(NSString *)key
{
    [self _genPropertyForKey:key withBody: ^
    {
        _genChar( '"' );
        //_genNS( str );   // TO DO: atencio falla si conte cometes
        [self _genScapedString:str];
        _genChar( '"' );
    }];
}

- (void)_genStringsArray:(NSArray*)array forKey:(NSString *)key
{
    [self _genPropertyForKey:key withBody: ^
    {
        _genChar( '[' );
        int indx = 0;
        for ( NSString *str in array )
        {
            if ( indx++ > 0 ) _genChar( ',' );
            if ( indx%8 == 0 )
            {
                _genNewLine;
                _genChars( "    ", 4 );
            }
            else
            {
                if ( indx>1) _genChar( ' ' );
            }
            _genChar( '"' );
            //_genNS( str );   // TO DO: atencio falla si conte cometes
            [self _genScapedString:str];
            _genChar( '"' );
        }
        _genChar( ']' );
    }];
}

- (void)_genInt:(int)value forKey:(NSString *)key
{    
    [self _genPropertyForKey:key withBody: ^
    {
        char buff[20];
        int len = sprintf( buff, "%d", value );
        _genChars( buff, len );
    }];
    
}

- (void)_genDouble:(double)value forKey:(NSString *)key
{    
    [self _genPropertyForKey:key withBody: ^
    {
        char buff[40];
        int len = sprintf( buff, "%1.15g", value );
        _genChars( buff, len );
    }];
}


//- (void)_genPoint:(CGPoint)value forKey:(NSString *)key
//{    
//    [self _genPropertyForKey:key withBody: ^
//    {
//        char buff[60];
//        //int len = sprintf( buff, "[%1.6g, %1.6g]", value.x, value.y );
//        int len = sprintf( buff, "SM.point(%1.6g, %1.6g)", value.x, value.y );
//        _genChars( buff, len );
//    }];
//}
//
//- (void)_genSize:(CGSize)value forKey:(NSString *)key
//{    
//    [self _genPropertyForKey:key withBody: ^
//    {
//        char buff[60];
//        //int len = sprintf( buff, "[%1.6g, %1.6g]", value.width, value.width );
//        int len = sprintf( buff, "SM.size(%1.6g, %1.6g)", value.width, value.width );
//        _genChars( buff, len );
//    }];
//}
//
//- (void)_genRect:(CGRect)value forKey:(NSString *)key
//{    
//    [self _genPropertyForKey:key withBody: ^
//    {
//        char buff[120];
//        //int len = sprintf( buff, "[%1.6g, %1.6g, %1.6g, %1.6g]", value.origin.x, value.origin.y, value.size.width, value.size.height );
//        int len = sprintf( buff, "SM.rect(%1.6g, %1.6g, %1.6g, %1.6g)", value.origin.x, value.origin.y, value.size.width, value.size.height );
//        _genChars( buff, len );
//    }];
//}


///////////////////////////////////////////////////////////////////////////////////////
#pragma mark SymbolicArchiver Public Methods
///////////////////////////////////////////////////////////////////////////////////////



//------------------------------------------------------------------------------------
+ (NSData*)archivedDataWithArrayOfObjects:(NSArray*)array forKey:(NSString *)key version:(NSInteger)version
{
    NSMutableData *data = [NSMutableData data];
    SymbolicArchiver *archiver = [[SymbolicArchiver alloc] initForWritingWithMutableData:data version:version];
    [archiver encodeCollectionOfObjects:array forKey:key];
    [archiver finishEncoding];
    
//#define logData
#ifdef logData
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog( @"ArchivedData:\n\n%@", dataStr );
#endif
    
    
    return data;
}

//------------------------------------------------------------------------------------
- (id)initForWritingWithMutableData:(NSMutableData *)dta version:(int)vers
{
    return [self initForWritingWithMutableData:dta metaData:nil version:vers];
}


- (id)initForWritingWithMutableData:(NSMutableData *)dta metaData:(NSDictionary*)metaData version:(int)vers
{
    if ( (self = [super init]) )
    {
        // treballem amb coreFoundation
        data = (__bridge CFMutableDataRef)dta;
        
        // si no diem el contrari isStore es NO
        isStore = NO ;
        
        // si ens han passat null en creem una
        if ( data == NULL )
        {
            data = CFDataCreateMutable( NULL, 0 );
            CFDataSetLength( data, DATA_INITIAL_LENGTH );
        }
        
        // en cas contrari simplement la retenim
        else
        {
            CFRetain( data );
        }
        
        // per defecte generem amb UTF8
        stringEncoding = kCFStringEncodingUTF8;
        
        // establim els punters i les coleccions de treball
        p = CFDataGetMutableBytePtr( data );
        max = p + CFDataGetLength( data );
        
        // creem el array per la pila de objectes
        stack = CFArrayCreateMutable( NULL, 0, &kCFTypeArrayCallBacks );
        
        _SObjects *rootSObs = [[_SObjects alloc] initWithIdent:@"Project"];
        push( rootSObs );
        


        // generem un comentari per el encoding
        _genChars( "# %encoding ", 12 );
        const unsigned char *cStr ;
        int len = _getCStringFromEncoding_outCString(stringEncoding, &cStr);
        _genChars( cStr, len );
        _genNewLine;
        
        // generem un comentari per la versio
        _genChars( "# %version ", 11 );
        char buff[20];
        int versLen = sprintf( buff, "%d", vers );
        _genChars( buff, versLen );
        _genNewLine;
        
        // generem comentaris per la metadata
        if ( metaData )
        {
            [metaData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
            {
                NSString *param = [NSString stringWithFormat:@"# %%%@ %@", key, obj];
                _genNS( param );
                _genNewLine;
            }];
        }
        
        // separem la resta amb un newLine
        _genNewLine;
        
    }
    return self;
}

//------------------------------------------------------------------------------------
- (void)setIsStore:(BOOL)value
{
    isStore = value ;
}

//------------------------------------------------------------------------------------
- (void)dealloc
{
    //NSLog( @"Symbolic Coder dealloc" );
    if ( data ) CFRelease(data);
    if ( stack ) CFRelease( stack );
//    [super dealloc];
}

//------------------------------------------------------------------------------------
- (void)finishEncoding
{
    [self _genPendingObjects];

    // retalla data per ajustarse a la realitat codificada
    UInt8* begin = CFDataGetMutableBytePtr( data );
    CFDataSetLength( data, p-begin );
}

//------------------------------------------------------------------------------------
- (NSData *)archivedData
{
    return (__bridge id)data;
}

//------------------------------------------------------------------------------------
- (void)encodeObject:(id<SymbolicCoding>)object forKey:(NSString*)key
{
    [self _genObject:object forKey:key];
}

//------------------------------------------------------------------------------------
- (void)encodeCollectionOfObjects:(NSArray*)collection forKey:(NSString*)key
{
    [self _genCollection:collection forKey:key];
}

////------------------------------------------------------------------------------------
//- (void)encodeExpression:(SWExpression*)expr forKey:(NSString *)key
//{
//    [self _genExpression:expr forKey:key];
//}

//------------------------------------------------------------------------------------
- (void)encodeValue:(SWValue*)value forKey:(NSString*)key
{
//    if ([value isKindOfClass:[SWExpression class]])
//        [self _genExpression:(id)value forKey:key];
//    else 
        [self _genValue:value forKey:key];
}

//------------------------------------------------------------------------------------
- (void)encodeInt:(int)value forKey:(NSString *)key
{
    [self _genInt:value forKey:key];
}

//------------------------------------------------------------------------------------
- (void)encodeDouble:(double)value forKey:(NSString *)key
{
    [self _genDouble:value forKey:key];
}

//------------------------------------------------------------------------------------
- (void)encodeString:(NSString *)str forKey:(NSString *)key
{
    [self _genString:str forKey:key];
}

//------------------------------------------------------------------------------------
- (void)encodeStringsArray:(NSArray *)array forKey:(NSString *)key
{
    [self _genStringsArray:array forKey:key];
}

@end



///////////////////////////////////////////////////////////////////////////////////////
#pragma mark Unarchiver Helper ObjectProperty
///////////////////////////////////////////////////////////////////////////////////////




typedef __unsafe_unretained const NSString * _ObjectPropertyKind;

//static _ObjectPropertyKind ObjectPropertyKindUnknown = @"Unknown";
static _ObjectPropertyKind ObjectPropertyKindExpression = @"Expression";       // el 'object' es una SWExpression
static _ObjectPropertyKind ObjectPropertyKindSWCollection = @"SWCollection";   // el 'object' es un array de strings
static _ObjectPropertyKind ObjectPropertyKindSWObject = @"SWObject";           // el 'object' es un objecte
//static _ObjectPropertyKind ObjectPropertyKindSWAbsoluteTime = @"SWAbsoluteTime";           // el 'object' es un absolute time

@interface _ObjectProperty : NSObject
{
    @public
    _ObjectPropertyKind kind;
    id object;
}
@end

@implementation _ObjectProperty

-(id)initWithObject:(id)theObject ofKind:(_ObjectPropertyKind)theKind
{
    self = [super init];
    if ( self )
    {
        object = theObject;
        kind = theKind;
    }
    return self;
}

@end



///////////////////////////////////////////////////////////////////////////////////////
#pragma mark Unarchiver Helper Object
///////////////////////////////////////////////////////////////////////////////////////


@interface _ObjectInfo : NSObject
{
    Class class;
    id<SymbolicCoding> object;
    CFMutableDictionaryRef properties;  // {CFString, _ObjectProperty}
}
@end

@implementation _ObjectInfo


- (id)initWithClass:(Class)theClass
{
    self = [super init];
    if ( self )
    {
        class = theClass;
        properties = CFDictionaryCreateMutable( NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks );
    }
    return self;
}


- (void)addProperty:(id)value withKind:(_ObjectPropertyKind)kind forKey:(NSString*)key
{
    _ObjectProperty *property = [[_ObjectProperty alloc] initWithObject:value ofKind:kind];
    CFDictionaryAddValue( properties, (__bridge CFTypeRef)key, (__bridge CFTypeRef)property );
}


//- (_ObjectProperty*)propertyForKeyV:(NSString*)key
//{
//    __unsafe_unretained _ObjectProperty *property = NULL;
//    property = (__bridge _ObjectProperty *)(CFDictionaryGetValue( properties, (__bridge CFTypeRef)key ));
//    return property;
//}


- (_ObjectProperty*)propertyForKey:(NSString*)key
{
    __unsafe_unretained _ObjectProperty *property = NULL;
    property = (__bridge _ObjectProperty *)(CFDictionaryGetValue( properties, (__bridge CFTypeRef)key ));
    
    if ( property == NULL )
    {
        if ( [object respondsToSelector:@selector(replacementKeyForKey:)] )
        {
            key = [object replacementKeyForKey:key];
            if ( key != nil )
            {
                property = [self propertyForKey:key];  // tornem a provar recursivament
            }
        }
    }
    
    return property;
}


//- (id)propertyWithKind:(_ObjectPropertyKind)kind forKey:(NSString*)key
//{
//    __unsafe_unretained _ObjectProperty *property = NULL;
//    property = (__bridge _ObjectProperty *)(CFDictionaryGetValue( properties, (__bridge CFTypeRef)key ));
//    
//    if ( property && property->kind == kind )
//    {
//        return property->object;
//    }
//    
//    return nil;
//}

-(Class)objectClass
{
    return class;
}

- (id<SymbolicCoding>)object
{
    return object;
}

- (void)setObject:(id<SymbolicCoding>)obj
{
//    [obj retain];
//    [object release];
    object = obj;
}

- (id<SymbolicCoding>)allocUninitializedObject
{
//    if ( object ) [object release];
    object = nil;
    object = [class alloc];  // s'ha de coneixer l'objecte abans de cridar init
    return object;
}


- (void)dealloc
{
    if (properties) CFRelease(properties);
//    [object release];
//    [super dealloc];
}
@end




@implementation SymbolicUnarchiver


///////////////////////////////////////////////////////////////////////////////////////
#pragma mark SymbolicUnarchiver Private Methods
///////////////////////////////////////////////////////////////////////////////////////


// A partir de la informacio continguda a errInfo genera una string amb
// la descripcio de l'error.



- (BOOL)_resultWithError:(UInt8)error detail:(NSString*)detailStr
{
    if ( errCode || infoStr ) return NO;
    //[infoStr release];
    infoStr = nil;
    
    errCode = error;

    if ( errCode == 0 ) return YES;

    NSString *errStr = nil;
    NSString *dtlStr = nil;
        
    switch ( errCode )
    {
        case SymbolicUnarchiverErrorExpressionError :
            errStr = @"SymbolicUnarchiverErrorParsingExpression";
            dtlStr = detailStr;
            break;
            
        case SymbolicUnarchiverErrorExtraChars :
            errStr = @"SymbolicUnarchiverErrorExtraChars";
            break;

        case SymbolicUnarchiverErrorUnknownEncoding :
            errStr = @"SymbolicUnarchiverErrorUnknownEncoding";
            break;
            
        case SymbolicUnarchiverErrorUnsupportedEncoding :
            errStr = @"SymbolicUnarchiverErrorUnsupportedEncoding";
            break;

        case SymbolicUnarchiverErrorExpectedTokenAfterDot :
            errStr = @"SymbolicUnarchiverErrorExpectedTokenAfterDot";
            break;

        case SymbolicUnarchiverErrorExpectedToken :
            errStr = @"SymbolicUnarchiverErrorExpectedToken";
            break;

        case SymbolicUnarchiverErrorExpectedAsignOper :
            errStr = @"SymbolicUnarchiverErrorExpectedAsignOper";
            break;

        case SymbolicUnarchiverErrorExpectedDotOper :
            errStr = @"SymbolicUnarchiverErrorExpectedDotOper";
            break;

        case SymbolicUnarchiverErrorExpectedNewMethodCall :
            errStr = @"SymbolicUnarchiverErrorExpectedNewMethodCall";
            break;

        case SymbolicUnarchiverErrorExpectedOpenBracket :
            errStr = @"SymbolicUnarchiverErrorExpectedOpenBracket";
            break;

        case SymbolicUnarchiverErrorExpectedTokenOrCloseBracket :
            errStr = @"SymbolicUnarchiverErrorExpectedTokenOrCloseBracket";
            break;
            
        case SymbolicUnarchiverErrorUnknownClass :
            errStr = @"SymbolicUnarchiverErrorUnknownClass";
            dtlStr = detailStr;
            break;
            
        case SymbolicUnarchiverErrorInvalidClass:
            errStr = @"SymbolicUnarchiverErrorInvalidClass";
            dtlStr = detailStr;
            break;
        
        case SymbolicUnarchiverErrorUnknownSymbol:
            errStr = @"SymbolicUnarchiverErrorUnknownSymbol";
            dtlStr = detailStr;
            break;
        
        case SymbolicUnarchiverErrorDuplicatedSymbol:
            errStr = @"SymbolicUnarchiverErrorDuplicatedSymbol";
            dtlStr = detailStr;
            break;
            
        case SymbolicUnarchiverErrorObjectNotFoundForSymbol:
            errStr = @"SymbolicUnarchiverErrorObjectNotFoundForSymbol";
            dtlStr = detailStr;
            break;
            
        case SymbolicUnarchiverErrorObjectWrongTypeAssignedToValue:
            errStr = @"SymbolicUnarchiverErrorObjectWrongTypeAssignedToValue";
            dtlStr = detailStr;
            break;
            
        case SymbolicUnarchiverErrorNonConstantExpressionForValue:
            errStr = @"SymbolicUnarchiverErrorNonConstantExpressionForValue";
            dtlStr = detailStr;
            break;
            
        case SymbolicUnarchiverErrorCommitExpressionsError:
            errStr = @"SymbolicUnarchiverErrorCommitExpressionsError";
            dtlStr = detailStr;
            break;
            
        case SymbolicUnarchiverErrorCustomObjectError:
            errStr = @"SymbolicUnarchiverErrorCustomObjectError";
            dtlStr = detailStr;
            break;
            
        default :
            errStr = @"SymbolicUnarchiverUnspecifiedError";
            break;
    }
        
    errStr = NSLocalizedString( errStr, nil );

    
    if ( dtlStr )
    {
        infoStr = [NSString stringWithFormat:@"[Line %04d]\n%@:\n%@", _line, errStr, dtlStr];
    }
    else
    {
        if ( c > cErr ) cErr = c;
        

        int eflen = 0;
        while ( eflen<cErr-beg && eflen<40 )
        {
            if (*(cErr-eflen) == '\r' || *(cErr-eflen) == '\n')
            {
                eflen--;
                break;
            }
            eflen++;
        }
        
        CFStringRef preStr = NULL;
        if ( eflen > 0 )
        {
            preStr = CFStringCreateWithBytesNoCopy( NULL, cErr-eflen, eflen, stringEncoding, false, kCFAllocatorNull );
            if ( preStr == NULL ) preStr = CFStringCreateWithBytesNoCopy( NULL, cErr-eflen+1, eflen, kCFStringEncodingWindowsLatin1, false, kCFAllocatorNull );
        }
        
        eflen = 0;
        while ( eflen<end-cErr && eflen<40 )
        {
            if (cErr[eflen] == '\r' || cErr[eflen] == '\n') break;
            eflen++;
        }
        
        CFStringRef postStr = NULL;
        if ( eflen > 0 )
        {
            // creem una string de longitud màxima 40 posicions a partir del lloc del error
            postStr = CFStringCreateWithBytesNoCopy( NULL, cErr, eflen, stringEncoding, false, kCFAllocatorNull );
            // si falla la codificació asumim WindowsLatin que no falla, i al menys mostrem alguna cosa
            if ( postStr == NULL ) postStr = CFStringCreateWithBytesNoCopy( NULL, cErr, eflen, kCFStringEncodingWindowsLatin1, false, kCFAllocatorNull );
        }
        
        NSString *errTxt = nil;
        if ( preStr )
        {
            errTxt = [NSString stringWithFormat:@"%@:\n'%@'", errStr, preStr];
            CFRelease( preStr );
            preStr = NULL;
        }
        else errTxt = errStr;
        
        if ( postStr )
        {
            NSString *format = NSLocalizedString(@"SymbolicUnarchiverPre%@Post%@", nil);
            errTxt = [NSString stringWithFormat:format, errTxt, postStr];
            CFRelease( postStr );
            postStr = NULL;
        }

        infoStr = [NSString stringWithFormat:@"[Line %04d]\n%@", _line, errTxt];
    }

    return NO;
}



//-------------------------------------------------------------------------------------------
- (BOOL)_parseSingleStatement
{
    const unsigned char *cstr;
    size_t len;
    if ( [self parseToken:&cstr length:&len] )
    {
        CFStringRef symbol = CFStringCreateWithBytesNoCopy(NULL, cstr, len, kCFStringEncodingASCII, // tokens son ASCII
                false, kCFAllocatorNull);
        _skip;
        
        //NSLog( @"symbol:%@", symbol );
        // propietat
        if ( _parseChar( '.' ) )
        {
            _skip;
            if ( [self parseToken:&cstr length:&len] )
            {
                CFStringRef property = CFStringCreateWithBytesNoCopy(NULL, cstr, len, kCFStringEncodingASCII, // tokens son ASCII
                    false, kCFAllocatorNull);
                    
                // aqui tinc simbol + property
                _skip;
                if ( _parseChar( '=' ) )
                {
                    // aqui afegim una propietat
                    _skip;
                    if ( [self parseConcreteToken:"SWCollection" length:12] )
                    {
                        _skip;
                        if ( _parseChar( '.' ) )
                        {
                            _skip;
                            if ( [self parseConcreteToken:"new" length:3] )
                            {
                                _skip
                                if ( _parseChar( '(' ) )
                                {
                                    NSMutableArray *items = [[NSMutableArray alloc] init];
                                    
                                    while ( YES )
                                    {
                                        _skip;
                                        if ( [self parseToken:&cstr length:&len] )
                                        {
                                            CFStringRef item = CFStringCreateWithBytesNoCopy(NULL, cstr, len, kCFStringEncodingASCII, // tokens son ASCII
                                            false, kCFAllocatorNull);
                                            
                                            [items addObject:(__bridge id)item];
                                            CFRelease( item );
                                        
                                            _skip
                                            if ( _parseChar( ',' ) ) continue;
                                        }
                                        break;
                                    }
                                    
                                    _skip;
                                    if ( _parseChar( ')' ) )
                                    {
                                        // busquem el objectInfo al diccionari de objectInfos, i hi afegim el array de items per aquesta propietat
                                        __unsafe_unretained _ObjectInfo *objectInfo = (__bridge id)CFDictionaryGetValue( objectInfos, symbol );
                                        
                                        if ( objectInfo )
                                        {
                                            // afegim un array de strings
                                            [objectInfo addProperty:items withKind:ObjectPropertyKindSWCollection forKey:(__bridge id)property];
                                            CFRelease( symbol );
                                            CFRelease( property );
                                            return YES;
                                        }
                                        else [self _resultWithError:SymbolicUnarchiverErrorUnknownSymbol detail:(__bridge id)(symbol)];
                                    }
                                    else [self _resultWithError:SymbolicUnarchiverErrorExpectedTokenOrCloseBracket detail:nil];
                                }
                                else [self _resultWithError:SymbolicUnarchiverErrorExpectedOpenBracket detail:nil];
                            }
                            else [self _resultWithError:SymbolicUnarchiverErrorExpectedNewMethodCall detail:nil];
                        }
                        else [self _resultWithError:SymbolicUnarchiverErrorExpectedDotOper detail:nil];
                    }
                    
                    
                    else if ( [self parseConcreteToken:"SWObject" length:8] )
                    {
                        _skip;
                        if ( _parseChar( '.' ) )
                        {
                            _skip;
                            if ( [self parseConcreteToken:"new" length:3] )
                            {
                                _skip
                                if ( _parseChar( '(' ) )
                                {
                                    CFStringRef item;
                                    
                                    _skip;
                                    if ( [self parseToken:&cstr length:&len] )
                                    {
                                        item = CFStringCreateWithBytesNoCopy(NULL, cstr, len, kCFStringEncodingASCII, // tokens son ASCII
                                            false, kCFAllocatorNull);
                                    }
                                    else
                                    {
                                        item = CFRetain( CFSTR("") );
                                    }
                                    
                                    _skip;
                                    if ( _parseChar( ')' ) )
                                    {
                                        // busquem el objectInfo al diccionari de objectInfos, i hi afegim el item  per aquesta propietat
                                        __unsafe_unretained _ObjectInfo *objectInfo = (__bridge id)CFDictionaryGetValue( objectInfos, symbol );
                                        if ( objectInfo )
                                        {
                                            [objectInfo addProperty:(__bridge id)item withKind:ObjectPropertyKindSWObject forKey:(__bridge id)property]; // afegim una string
                                            CFRelease( item );
                                            CFRelease( symbol );
                                            CFRelease( property );
                                            return YES;
                                        }
                                        else [self _resultWithError:SymbolicUnarchiverErrorUnknownSymbol detail:(__bridge id)(symbol)];
                                    }
                                    else [self _resultWithError:SymbolicUnarchiverErrorExpectedTokenOrCloseBracket detail:nil];
                                    CFRelease( item );
                                }
                                else [self _resultWithError:SymbolicUnarchiverErrorExpectedOpenBracket detail:nil];
                            }
                            else [self _resultWithError:SymbolicUnarchiverErrorExpectedNewMethodCall detail:nil];
                        }
                        else [self _resultWithError:SymbolicUnarchiverErrorExpectedDotOper detail:nil];
                    }

                    
                    else
                    {
                        int usedLength = 0;
                        NSError *error = nil;
                        int builderPreLine = builder.line;
                        SWExpression *expr = [builder newExpressionFromBytes:c maxLength:end-c stringEncoding:stringEncoding usedLength:&usedLength doubleQuoted:NO outError:&error];
                        
                        if ( expr )
                        {
                            // incrementem les linees que pot haver utilitzat la expressio
                            _line += (builder.line-builderPreLine);
                            
                            // busquem el objectInfo al diccionari de objectInfos, i hi afegim una expressio per aquesta propietat
                            c += usedLength;
                            __unsafe_unretained _ObjectInfo *objectInfo = (__bridge id)CFDictionaryGetValue( objectInfos, symbol );
                            
                            
                            if ( objectInfo )
                            {
                                [objectInfo addProperty:expr withKind:ObjectPropertyKindExpression forKey:(__bridge id)property];  // afegim una expressio
//                            [expr release];
                                CFRelease( symbol );
                                CFRelease( property );
                                return YES;
                            }
                            else [self _resultWithError:SymbolicUnarchiverErrorUnknownSymbol detail:(__bridge NSString *)(symbol)];
                        }
                        else [self _resultWithError:SymbolicUnarchiverErrorExpressionError detail:[error localizedDescription]];
                    }
                }
                else [self _resultWithError:SymbolicUnarchiverErrorExpectedAsignOper detail:nil];
                CFRelease( property );
            }
            else [self _resultWithError:SymbolicUnarchiverErrorExpectedTokenAfterDot detail:nil];
        }
        
        // objecte directe
        else
        {
            // aqui tinc simbol
            _skip;
            if ( _parseChar( '=' ) )
            {
                _skip;
                if ( [self parseToken:&cstr length:&len] )
                {
                    // aqui creem un objecte
                    CFStringRef classStr = CFStringCreateWithBytesNoCopy(NULL, cstr, len, kCFStringEncodingASCII, // tokens son ASCII
                        false, kCFAllocatorNull);
                    _skip;
                    if ( classStr && _parseChar( '.' ) )
                    {
                        _skip;
                        if ( [self parseConcreteToken:"new" length:3] )
                        {
                            // ok, tenim el simbol i el tipus
                            Class theClass = NSClassFromString( (__bridge id)classStr);
                            
//                            if ( theClass )
//                            {
                                if ([theClass conformsToProtocol:@protocol(SymbolicCoding)])
                                {
                                    // creem un _ObjectInfo amb la clase que hem trobat i l'afegim al diccionary de objectInfos
                                    _ObjectInfo *objectInfo = [[_ObjectInfo alloc] initWithClass:theClass];
                                    CFRelease( classStr );
                                    
                                    Boolean present = CFDictionaryGetValueIfPresent( objectInfos, symbol, NULL);
                                    if ( !present )
                                    {
                                        CFDictionaryAddValue( objectInfos, symbol, (__bridge CFTypeRef)objectInfo );
                                        CFRelease( symbol );
                                        return YES;
                                    }
                                    else
                                    {
                                        NSString *detail = [NSString stringWithFormat:@"'%@'", symbol];
                                        [self _resultWithError:SymbolicUnarchiverErrorDuplicatedSymbol detail:detail];
                                    
                                    }
                                    //CFRelease( symbol );
                                    //                            [objectInfo release];
                                    //return YES;
                                }
                                else
                                {
                                    NSString *detail = [NSString stringWithFormat:@"'%@'", classStr];
                                    [self _resultWithError:SymbolicUnarchiverErrorInvalidClass detail:detail];
                                }
//                            }
//                            else
//                            {
//                                NSString *detail = [NSString stringWithFormat:@"'%@'", classStr];
//                                [self _resultWithError:SymbolicUnarchiverErrorUnknownClass expression:detail];
//                            }
                        }
                        else [self _resultWithError:SymbolicUnarchiverErrorExpectedNewMethodCall detail:nil];
                    }
                    else [self _resultWithError:SymbolicUnarchiverErrorExpectedDotOper detail:nil];
                    CFRelease( classStr );
                }
                else [self _resultWithError:SymbolicUnarchiverErrorExpectedToken detail:nil];
            }
            else [self _resultWithError:SymbolicUnarchiverErrorExpectedAsignOper detail:nil];
        }
        CFRelease( symbol );
    }
    
    return NO;
}





////-------------------------------------------------------------------------------------------
//// parseja un  possible comentari (fins a final de linea)
//- (BOOL)_parseRestCommentV
//{
//    _skipSpTab;
//    if ( [self parseConcreteToken:"%encoding" length:9] )
//    {
//        _skipSpTab;
//        const unsigned char *cstr = c;
//        size_t len;
//        if ( [self skipToAnyCharIn:" \t\r\n" outStr:&cstr length:&len] )
//        {
//            stringEncoding = _getEncodingFromCString_len(cstr, len);
//        }
//            
//        if ( stringEncoding == kCFStringEncodingInvalidId )
//        {
//            [self _resultWithError:SymbolicUnarchiverErrorUnknownEncoding detail:nil];
//            return NO;
//        }
//    }
//        
//    [self skipToAnyCharIn:"\r\n"];
//    return YES;
//}




// parseja un  possible comentari (fins a final de linea)
- (BOOL)_parseRestComment
{
    _skipSpTab;
    
    if ( _parseChar('%') )
    {
        const unsigned char *cstr = c;
        size_t len;
        if ( [self parseConcreteToken:"encoding" length:8] )
        {
            _skipSpTab;
            if ( [self skipToAnyCharIn:" \t\r\n" outStr:&cstr length:&len] )
            {
                stringEncoding = _getEncodingFromCString_len(cstr, len);
            }
            
            if ( stringEncoding == kCFStringEncodingInvalidId )
            {
                [self _resultWithError:SymbolicUnarchiverErrorUnknownEncoding detail:nil];
                return NO;
            }
            
            if ( stringEncoding != kCFStringEncodingUTF8 )
            {
                [self _resultWithError:SymbolicUnarchiverErrorUnsupportedEncoding detail:nil];
                return NO;
            }
        }
    
        else if ( [self parseToken:&cstr length:&len] )
        {
            NSString *metaKey = CFBridgingRelease(CFStringCreateWithBytes(NULL, cstr, len, stringEncoding, false )) ;
            
            _skipSpTab;
            if ( [self skipToAnyCharIn:" \t\r\n" outStr:&cstr length:&len] )
            {
                NSString *metaValue = CFBridgingRelease(CFStringCreateWithBytes(NULL, cstr, len, stringEncoding, false )) ;
                
                if ( [metaKey isEqualToString:@"version"] )
                {
                    version = [metaValue integerValue];
                }
                else
                {
                    if ( metaData == nil ) metaData = [[NSMutableDictionary alloc] init];
                    [metaData setObject:metaValue forKey:metaKey];
                }
            }
        }
    }
        
    [self skipToAnyCharIn:"\r\n"];
    return YES;
}



//-------------------------------------------------------------------------------------------
// parseja un  possible comentari (fins a final de linea)
- (BOOL)_parseComment
{
    if ( _parseChar( '#' ) )
    {
        return YES;
    }
    return NO;
}



//-------------------------------------------------------------------------------------------
// parseja un statement incluint possible comentari
- (BOOL)_parseStatement
{
    if ( [self _parseComment] )
    {
        _skipSpTab;
        if ( [self _parseRestComment] )
        {
            return YES;
        }
    }

    else if ( [self _parseSingleStatement] )
    {
        _skipSpTab;
        //if ( _parseChar( ';' ) || ((_parseChar( '\n' ) || _parseChar( '\r' )) && ++line) )
        if ( _parseChar( ';' ) || _parseChar( '\r' ) || ( _parseChar( '\n' ) && (_line+=1) ) )
        {
            return YES;
        }
    }
    
    return NO;
}


//-------------------------------------------------------------------------------------------
// parseja el cos
- (BOOL)_parseBody
{
    while ( YES )
    {
        _skip;
        if ( [self _parseStatement] ) continue;
        break;
    }
    return YES;
}


//-------------------------------------------------------------------------------------------
// parseja tot
- (BOOL)_parseAll
{
    _skip;
    if ( [self _parseBody] )
    {
        // ens assegurem que som al final
        _skip
        if ( c == end ) return YES;
        [self _resultWithError:SymbolicUnarchiverErrorExtraChars detail:nil];
    }
    return NO;
}


//------------------------------------------------------------------------------------
- (id<SymbolicCoding>)_unarchivedObjectForObjectInfo:(_ObjectInfo *)objectInfo 
        identifier:(NSString*)objIdent parentObject:(id<SymbolicCoding>)theParent
{
    id<SymbolicCoding>object = [objectInfo allocUninitializedObject];
    NSString *ident = [objIdent copy];
    
    if ( [object conformsToProtocol:@protocol(ValueHolder)] )
    {
        if ( [object respondsToSelector:@selector(setGlobalIdentifier:)] )
        {
            [builder addLocalSymbol:ident withHolder:(id)object];
        }
    }
    
    (void)[object initWithSymbolicCoder:self identifier:ident parentObject:theParent];
    return object;
}


//------------------------------------------------------------------------------------
- (BOOL)_retrievedObject:(id<SymbolicCoding>)object forObjectInfo:(_ObjectInfo *)objectInfo
        identifier:(NSString*)objIdent parentObject:(id<SymbolicCoding>)theParent
{
    NSString *ident = [objIdent copy];
    [object retrieveWithSymbolicCoder:self identifier:ident parentObject:theParent];
    return YES;
}


//------------------------------------------------------------------------------------
- (void)_initializedObjectForObjectInfo:(_ObjectInfo *)objectInfo
        identifier:(NSString*)objIdent parentObject:(id<SymbolicCoding>)theParent
{
    id<SymbolicCoding>object = [objectInfo object];
    NSString *ident = [objIdent copy];
    
    (void)[object initWithSymbolicCoder:self identifier:ident parentObject:theParent];
}



- (id)_lazyPropertyForObjectInfo:(_ObjectInfo*)objectInfo withKind:(_ObjectPropertyKind)kind forKey:(NSString*)key
{

    _ObjectProperty *property = [objectInfo propertyForKey:key];
    
    if ( property == nil )
        return nil;
    
    if ( property->kind != kind )
    {
        NSString *detail = [self _getWrongTypeAssignementDetailForObjectInfo:objectInfo
            withPropertyKey:key expectedKind:kind];
        [self _resultWithError:SymbolicUnarchiverErrorObjectWrongTypeAssignedToValue detail:detail];
        return nil;
    }

    return property->object;
}


- (id)_strictPropertyForObjectInfo:(_ObjectInfo*)objectInfo withKind:(_ObjectPropertyKind)kind forKey:(NSString*)key
{
    _ObjectProperty *property = [objectInfo propertyForKey:key];
    
    if ( property == nil || property->kind != kind )
    {
        NSString *detail = [self _getWrongTypeAssignementDetailForObjectInfo:objectInfo
            withPropertyKey:key expectedKind:kind];
        [self _resultWithError:SymbolicUnarchiverErrorObjectWrongTypeAssignedToValue detail:detail];
        return nil;
    }

    return property->object;
}



//------------------------------------------------------------------------------------
- (id<SymbolicCoding>)_objectForKey:(NSString *)key
{
    id<SymbolicCoding> object = nil;
    _ObjectInfo *objectInfo = top();
    NSString *objIdent = [self _strictPropertyForObjectInfo:objectInfo withKind:ObjectPropertyKindSWObject forKey:key];
    if ( objIdent )
    {
        object = [self _objectForObjectInfo:objectInfo withPropertyKey:key objIdent:objIdent];
    }
    return object;
}


//------------------------------------------------------------------------------------
- (BOOL)_retrieveObject:(id<SymbolicCoding>)object forKey:(NSString *)key
{
    BOOL result = NO;
    _ObjectInfo *objectInfo = top();
    NSString *objIdent = [self _strictPropertyForObjectInfo:objectInfo withKind:ObjectPropertyKindSWObject forKey:key];
    if ( objIdent )
    {
        result = [self _retrieveObject:object forObjectInfo:objectInfo withPropertyKey:key objIdent:objIdent];
    }
    return result;
}


////------------------------------------------------------------------------------------
//- (BOOL)_retrieveObject:(id<SymbolicCoding>)object forKey:(NSString *)key
//{
//    [object retrieveWithSymbolicCoder:self identifier:nil parentObject:nil];
//    return YES;
//}


//------------------------------------------------------------------------------------
- (id<SymbolicCoding>)_objectForObjectInfo:(_ObjectInfo *)objectInfo withPropertyKey:key objIdent:(NSString*)objIdent
{
    id<SymbolicCoding>theObject = nil;
    id<SymbolicCoding>theParent = [objectInfo object];
    
    __unsafe_unretained _ObjectInfo *objInfo = (__bridge id)CFDictionaryGetValue( objectInfos, (__bridge CFTypeRef)objIdent );
    if ( objInfo )
    {
        push( objInfo );
        theObject = [self _unarchivedObjectForObjectInfo:objInfo identifier:objIdent parentObject:theParent];
        pop();
    }
    else if ( objIdent.length > 0 )  // no ha trobat el objIdent, pero si era @"" vol dir descodificacio de objecte nil
    {
        NSString *detail = [self _getObjectNotFoundDetailForObjectInfo:objectInfo withPropertyKey:key ident:objIdent];
        [self _resultWithError:SymbolicUnarchiverErrorObjectNotFoundForSymbol detail:detail];
    }

    return theObject;
}


//------------------------------------------------------------------------------------
- (BOOL)_retrieveObject:(id<SymbolicCoding>)theObject forObjectInfo:(_ObjectInfo *)objectInfo withPropertyKey:key objIdent:(NSString*)objIdent
{
    BOOL result = NO;
    id<SymbolicCoding>theParent = [objectInfo object];
    
    __unsafe_unretained _ObjectInfo *objInfo = (__bridge id)CFDictionaryGetValue( objectInfos, (__bridge CFTypeRef)objIdent );
    if ( objInfo )
    {
        push( objInfo );
        result = [self _retrievedObject:theObject forObjectInfo:objInfo identifier:objIdent parentObject:theParent];
        pop();
    }
    else if ( objIdent.length > 0 )  // no ha trobat el objIdent, pero si era @"" vol dir descodificacio de objecte nil
    {
        NSString *detail = [self _getObjectNotFoundDetailForObjectInfo:objectInfo withPropertyKey:key ident:objIdent];
        [self _resultWithError:SymbolicUnarchiverErrorObjectNotFoundForSymbol detail:detail];
    }
    return result;
}


// ####################

//------------------------------------------------------------------------------------
- (void)_initExistingObject:(id<SymbolicCoding>)object forKey:(NSString *)key
{
    _ObjectInfo *objectInfo = top();
    NSString *objIdent = [self _strictPropertyForObjectInfo:objectInfo withKind:ObjectPropertyKindSWObject forKey:key];
    [self _initExistingObject:object forObjectInfo:objectInfo withPropertyKey:key objIdent:objIdent];
}


//------------------------------------------------------------------------------------
- (void)_initExistingObject:(id<SymbolicCoding>)object forObjectInfo:(_ObjectInfo *)objectInfo withPropertyKey:key objIdent:(NSString*)objIdent
{
    id<SymbolicCoding>theParent = [objectInfo object];
    
    __unsafe_unretained _ObjectInfo *objInfo = (__bridge id)CFDictionaryGetValue( objectInfos, (__bridge CFTypeRef)objIdent );
    if ( objInfo )
    {
        [objInfo setObject:object];
        push( objInfo );
        [self _initializedObjectForObjectInfo:objInfo identifier:objIdent parentObject:theParent];
        pop();
    }
    else
    {
        NSString *detail = [self _getObjectNotFoundDetailForObjectInfo:objectInfo withPropertyKey:key ident:objIdent];
        [self _resultWithError:SymbolicUnarchiverErrorObjectNotFoundForSymbol detail:detail];
    }
}


//------------------------------------------------------------------------------------
- (void)_initExistingCollection:(NSArray *)theObjects forKey:(NSString *)key withKeys:(NSArray*)theKeys
{
    //BOOL result = NO;
    NSAssert( theObjects.count == theKeys.count, @"InitExistingCollection counts han de ser iguals");
    
    _ObjectInfo *objectInfo = top();
    
    NSArray *items = [self _lazyPropertyForObjectInfo:objectInfo withKind:ObjectPropertyKindSWCollection forKey:key];
    
    id<SymbolicCoding>theParent = [objectInfo object];

    //NSInteger itemsCount = items.count;
    NSInteger collCount = theObjects.count;
//    if ( itemsCount == collCount )
//    {
    
        for ( NSInteger i=0; i<collCount; i++)
        {
        
//            NSString *objIdent = [items objectAtIndex:i];
//        
//            NSString *theIdent = objIdent;
//            NSInteger objIndex = [theKeys indexOfObject:theIdent];
//            
//            while ( objIndex == NSNotFound && theIdent != nil)
//            {
//                if ( [theParent respondsToSelector:@selector(replacementKeyForKey:)] )
//                {
//                    theIdent = [theParent replacementKeyForKey:theIdent];
//                    objIndex = [theKeys indexOfObject:theIdent];
//                }
//                else break;
//            }
//            
//            if ( objIndex == NSNotFound )
//                continue;
//            
//            id<SymbolicCoding>theObject = [theObjects objectAtIndex:objIndex];


            id<SymbolicCoding>theObject = [theObjects objectAtIndex:i];
            NSString *theIdent = [theKeys objectAtIndex:i];
    
        
            NSString *objIdent = theIdent;
            NSInteger itmIndex = [items indexOfObject:objIdent];
            
            while ( itmIndex == NSNotFound && objIdent != nil)
            {
                if ( [theParent respondsToSelector:@selector(replacementKeyForKey:)] )
                {
                    objIdent = [theParent replacementKeyForKey:objIdent];
                    //itmIndex = [theKeys indexOfObject:theIdent];
                    itmIndex = [items indexOfObject:objIdent];
                }
                else break;
            }
            
            if ( itmIndex == NSNotFound )
                continue;
        
            __unsafe_unretained _ObjectInfo *objInfo = (__bridge id)CFDictionaryGetValue( objectInfos, (__bridge CFTypeRef)objIdent );
        
            if ( objInfo )
            {
                [objInfo setObject:theObject];
                push( objInfo );
                //result = [self _retrievedObject:theObject forObjectInfo:objInfo identifier:objIdent parentObject:theParent];
                [self _initializedObjectForObjectInfo:objInfo identifier:objIdent parentObject:theParent];
                pop();
            }
            else
            {
                NSString *detail = [self _getObjectNotFoundDetailForObjectInfo:objectInfo withPropertyKey:key ident:objIdent];
                [self _resultWithError:SymbolicUnarchiverErrorObjectNotFoundForSymbol detail:detail];
            }
        }
    // }
    //return result;
}





// #####################################

////------------------------------------------------------------------------------------
//- (void)_initExistingObjectN:(id<SymbolicCoding>)object forKey:(NSString*)key
//{
//    _ObjectInfo *objectInfo = top();
//    //NSString *objIdent = key; // se suposa que es una string TO DO: filtrar
//    
//    [self _initExistingObjectN:object forObjectInfo:objectInfo withPropertyKey:key /*objIdent:objIdent*/];
//}
//
//
////------------------------------------------------------------------------------------
//- (void)_initExistingObjectN:(id<SymbolicCoding>)object forObjectInfo:(_ObjectInfo *)objectInfo withPropertyKey:key //objIdent:(NSString*)objIdent
//{
//    id<SymbolicCoding>theParent = [objectInfo object];
//    
//    NSString *objIdent = key;
//    if ( [theParent respondsToSelector:@selector(replacementKeyForKey:)] )
//    {
//        NSString *actualKey = [theParent replacementKeyForKey:key];
//        if ( actualKey != nil )
//        {
//            objIdent = actualKey;
//        }
//    }
//    
//    __unsafe_unretained _ObjectInfo *objInfo = (__bridge id)CFDictionaryGetValue( objectInfos, (__bridge CFTypeRef)objIdent );
//    if ( objInfo )
//    {
//        [objInfo setObject:object];
//        push( objInfo );
//        [self _initializedObjectForObjectInfo:objInfo identifier:objIdent parentObject:theParent];
//        pop();
//    }
//    else
//    {
//        NSString *detail = [self _getObjectNotFoundDetailForObjectInfo:objectInfo withPropertyKey:key ident:objIdent];
//        [self _resultWithError:SymbolicUnarchiverErrorObjectNotFoundForSymbol detail:detail];
//    }
//}


- (NSString*)_getObjectNotFoundDetailForObjectInfo:(_ObjectInfo *)objectInfo withPropertyKey:key ident:(NSString*)objIdent
{
    NSString *objectInfoIdent = [self _getIdentifierForObjectInfo:objectInfo withPropertyKey:key];
    NSString *format = NSLocalizedString(@"SymbolicUnarchiverSym%@Used%@", nil);
    NSString *result = [NSString stringWithFormat:format, objIdent, objectInfoIdent];
    return result;
}

- (NSString*)_getWrongTypeAssignementDetailForObjectInfo:(_ObjectInfo *)objectInfo withPropertyKey:(NSString*)key expectedKind:(_ObjectPropertyKind)kind
{
    NSString *objectInfoIdent = [self _getIdentifierForObjectInfo:objectInfo withPropertyKey:key];
    NSString *format = NSLocalizedString(@"SymbolicUnarchiverWrong%@Kind%@", nil);
    NSString *result = [NSString stringWithFormat:format, objectInfoIdent, kind];
    return result;
}


//------------------------------------------------------------------------------------
- (NSMutableArray*)_collectionForKey:(NSString *)key
{
    NSMutableArray *theObjects = [NSMutableArray array];
    
    _ObjectInfo *objectInfo = top();
    
    //NSArray *items = [self _strictPropertyForObjectInfo:objectInfo withKind:ObjectPropertyKindSWCollection forKey:key];
    NSArray *items = [self _lazyPropertyForObjectInfo:objectInfo withKind:ObjectPropertyKindSWCollection forKey:key];
    
    id<SymbolicCoding>theParent = [objectInfo object];
    
    for ( NSString *objIdent in items )
    {
        __unsafe_unretained _ObjectInfo *objInfo = (__bridge id)CFDictionaryGetValue( objectInfos, (__bridge CFTypeRef)objIdent );
        
        if ( objInfo )
        {
            push( objInfo );
        
            id<SymbolicCoding>theObject = [self _unarchivedObjectForObjectInfo:objInfo identifier:objIdent parentObject:theParent];
        
            [theObjects addObject:theObject];
            pop();
        }
        else
        {
            NSString *detail = [self _getObjectNotFoundDetailForObjectInfo:objectInfo withPropertyKey:key ident:objIdent];
            [self _resultWithError:SymbolicUnarchiverErrorObjectNotFoundForSymbol detail:detail];
        }
    }
    return theObjects;
}



- (SWValue*)_decodeValueForKey:(NSString*)key
{
    _ObjectInfo *objectInfo = top();
    
    _ObjectProperty *property = [objectInfo propertyForKey:key];
    
    if ( property == nil )
        return nil;
    
    if ( property->kind == ObjectPropertyKindExpression )
    {
        SWExpression *expr = property->object;
        if ( expr.kind != ExpressionKindConst )
        {
            NSString *objectIdent = [self _getIdentifierForObjectInfo:objectInfo withPropertyKey:key];
            NSString *detailStr = [NSString stringWithFormat:@"\n%@ = %@", objectIdent, [expr getSourceString] ];
            [self _resultWithError:SymbolicUnarchiverErrorNonConstantExpressionForValue detail:detailStr];
        }

        SWValue *value = [[SWValue alloc] initWithValue:expr];
        id<ValueHolder> theParent = (id)[objectInfo object];
        [value setHolder:theParent];
        return value;
    }

    // cas que el SWValue es va codificar com a objecte
    
    if ( property->kind == ObjectPropertyKindSWObject )
    {
        NSString *objIdent = property->object;
        id object = [self _objectForObjectInfo:objectInfo withPropertyKey:key objIdent:objIdent];
        SWValue *value = [[SWValue alloc] initWithObject:object];
        id<ValueHolder> theParent = (id)[objectInfo object];
        [value setHolder:theParent];
        return value;
    }
        
    // cas ni l'un ni l'altre
    
    NSString *detail = [self _getWrongTypeAssignementDetailForObjectInfo:objectInfo
            withPropertyKey:key expectedKind:ObjectPropertyKindExpression];
    [self _resultWithError:SymbolicUnarchiverErrorObjectWrongTypeAssignedToValue detail:detail];

    return nil;
}



//------------------------------------------------------------------------------------
- (BOOL)_retrieveValue:(SWValue*)value forKey:(NSString*)key
{
    _ObjectInfo *objectInfo = top();
    
    _ObjectProperty *property = [objectInfo propertyForKey:key];
    
    if ( property == nil )
        return NO;
    
    if ( property->kind == ObjectPropertyKindExpression )
    {
        SWExpression *expr = property->object;
        if ( expr.kind != ExpressionKindConst )
        {
            NSString *objectIdent = [self _getIdentifierForObjectInfo:objectInfo withPropertyKey:key];
            NSString *detailStr = [NSString stringWithFormat:@"\n%@ = %@", objectIdent, [expr getSourceString] ];
            [self _resultWithError:SymbolicUnarchiverErrorNonConstantExpressionForValue detail:detailStr];
        }
        
        [value evalWithValue:expr];
        return YES;
    }

    // cas que el SWValue es va codificar com a objecte
    if ( property->kind == ObjectPropertyKindSWObject )
    {
        NSString *objIdent = property->object;
        id object = [self _objectForObjectInfo:objectInfo withPropertyKey:key objIdent:objIdent];
        [value evalWithObject:object];
        return YES;
    }
        
    // cas ni l'un ni l'altre
    NSString *detail = [self _getWrongTypeAssignementDetailForObjectInfo:objectInfo
            withPropertyKey:key expectedKind:ObjectPropertyKindExpression];
    [self _resultWithError:SymbolicUnarchiverErrorObjectWrongTypeAssignedToValue detail:detail];

    return NO;
}


//------------------------------------------------------------------------------------
- (BOOL)_retrieveCollection:(NSArray *)theObjects forKey:(NSString *)key
{
    BOOL result = NO;
    _ObjectInfo *objectInfo = top();
    
    NSArray *items = [self _lazyPropertyForObjectInfo:objectInfo withKind:ObjectPropertyKindSWCollection forKey:key];
    
    id<SymbolicCoding>theParent = [objectInfo object];
    
    NSInteger itemsCount = items.count;
    NSInteger collCount = theObjects.count;
    
    if ( itemsCount == collCount )
    {
    
        for ( NSInteger i=0; i<collCount; i++)
        {
            NSString *objIdent = [items objectAtIndex:i];
            id<SymbolicCoding>theObject = [theObjects objectAtIndex:i];
        
            __unsafe_unretained _ObjectInfo *objInfo = (__bridge id)CFDictionaryGetValue( objectInfos, (__bridge CFTypeRef)objIdent );
        
            if ( objInfo )
            {
                push( objInfo );
                result = [self _retrievedObject:theObject forObjectInfo:objInfo identifier:objIdent parentObject:theParent];
                pop();
            }
            else
            {
                NSString *detail = [self _getObjectNotFoundDetailForObjectInfo:objectInfo withPropertyKey:key ident:objIdent];
                [self _resultWithError:SymbolicUnarchiverErrorObjectNotFoundForSymbol detail:detail];
            }
        }
    }
    return result;
}




////------------------------------------------------------------------------------------
//- (BOOL)_retrieveCollection:(NSArray *)theObjects forKey:(NSString *)key
//{
//    for ( id<SymbolicCoding>object in theObjects )
//    {
//        [object retrieveWithSymbolicCoder:self identifier:nil parentObject:nil];
//    }
//    
//    return YES;
//}



//------------------------------------------------------------------------------------
- (SWExpression*)_registeredExpressionForKey:(NSString *)key
{
    _ObjectInfo *objectInfo = top();
//    SWExpression *expr = [objectInfo propertyWithKind:ObjectPropertyKindExpression forKey:key];  // se suposa que es una expressio TO DO: filtrar
//    
//    if ( expr == nil )
//    {
//        NSString *detail = [self _getWrongTypeAssignementDetailForObjectInfo:objectInfo
//            withPropertyKey:key expectedKind:ObjectPropertyKindExpression];
//        [self _resultWithError:SymbolicUnarchiverErrorObjectWrongTypeAssignedToValue expression:detail];
//        return nil;
//    }
    
    SWExpression *expr = [self _lazyPropertyForObjectInfo:objectInfo withKind:ObjectPropertyKindExpression forKey:key];
    
    if ( expr )
    {
        id<ValueHolder> theParent = (id)[objectInfo object];
        [expr setHolder:theParent];
    
        [builder registerExpressionForCommit:expr];
    }
    return expr;
}

//------------------------------------------------------------------------------------
- (int)_intForKey:(NSString *)key
{
    _ObjectInfo *objectInfo = top();
    SWExpression *expr = [self _lazyPropertyForObjectInfo:objectInfo withKind:ObjectPropertyKindExpression forKey:key];
    int value = [expr valueAsDouble];
    return value;
}



///////////////////////////////////////////////////////////////////////////////////////
#pragma mark SymbolicUnarchiver Public Methods
///////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------------
+ (NSArray*)unarchivedObjectsWithData:(NSData*)data
    forKey:(NSString *)key
    builder:(RpnBuilder *)builder
    parentObject:(id)parent
    version:(NSInteger)version
    outError:(NSError**)outError

{
    SymbolicUnarchiver *unarchiver = [[SymbolicUnarchiver alloc] initWithRpnBuilder:builder parentObject:parent];
    
    BOOL succeed = [unarchiver prepareForReadingWithData:data outError:outError];
    
    if ( /*NO &&*/ version != [unarchiver version] )
    {
        NSDictionary *info = nil;
        NSString *errMsg = @"Incompatible Version";
        info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
        *outError = [NSError errorWithDomain:@"com.SweetWilliam.HmiPad" code:0 userInfo:info];
        return nil;
    }
    
    if (!succeed)
    {
        return nil;
    }
    
    NSArray *items = [unarchiver decodeCollectionOfObjectsForKey:key];
    succeed = [unarchiver finishDecodingOutError:outError ignoreMissingSymbols:YES];
    
    if (!succeed)
    {
        return nil;
    }
    
    return items;
}


- (id)rootObject
{
    id root = nil;
    if ( stack )
    {
        int count = CFArrayGetCount(stack);
        if ( count > 0 )
        {
            __unsafe_unretained _ObjectInfo *objInfo = (__bridge id)CFArrayGetValueAtIndex(stack, count-1);
            root = objInfo.object;
        }
    }
    return root;
}


//------------------------------------------------------------------------------------
- (id)initWithRpnBuilder:(RpnBuilder *)buildr parentObject:(id<SymbolicCoding>)root
{
    self = [super init];
    if ( self )
    {
//        builder = [buildr retain];
//        parent = [root retain];
        builder = buildr;
        parent = root;
    }
    return self;
}


//------------------------------------------------------------------------------------
- (void)dealloc
{
    if ( objectInfos ) CFRelease( objectInfos );
    if ( stack ) CFRelease( stack );
//    [builder release];
//    [parent release];
//    [super dealloc];
}


//------------------------------------------------------------------------------------
- (BOOL)prepareForReadingWithData:(NSData *)dta outError:(NSError**)outError
{
    // convertim el arxiu a utf8 si ens ve en utf16
    BOOL isUTF8 = NO;
    data = dta;
    if ( dataContainsUtf16( (__bridge CFDataRef)dta ) )
    {
        data = (__bridge_transfer NSData*)create8bitRepresentationOfData( (__bridge CFDataRef)dta );
//        [dta release];
        isUTF8 = YES;
    }
    
    // de moment no tenim metaData
    metaData = nil;
    
//    // asumim WindowsLatin1 per defecte, el parser pot determinar que es un altre
//    stringEncoding = kCFStringEncodingWindowsLatin1;
//    if ( isUTF8 ) stringEncoding = kCFStringEncodingUTF8;
    
    // asumim UTF8 per defecte el parser pot determinar que es un altre
    stringEncoding = kCFStringEncodingUTF8;
    
    // inicialitzem els punters a les dades
    source = (const unsigned char *)[data bytes];
    beg = (unsigned char *)source;
    c = beg;
    cErr = c;
    end = c + [data length];
    
    // ens carreguem el infoStr i el posem a nil
    // qualsevol infoStr que es genera a la clase es autoreleased
    if ( infoStr ) infoStr = nil;
    errCode = 0;
    _line = 1;
    
    // creem el dictionari d'objectes
    if ( objectInfos ) CFRelease( objectInfos );
    objectInfos = CFDictionaryCreateMutable( NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks );

    // creem el array per la pila de objectes
    if ( stack ) CFRelease( stack );
    stack = CFArrayCreateMutable( NULL, 0, &kCFTypeArrayCallBacks );
        
    Class parentClass = [parent class];
    _ObjectInfo *rootObjectInfo = [[_ObjectInfo alloc] initWithClass:parentClass];
    [rootObjectInfo setObject:parent];
    CFDictionaryAddValue( objectInfos, @"Project", (__bridge CFTypeRef)rootObjectInfo );
    
    push( rootObjectInfo );
//    [rootObjectInfo release];

    // cridem parseAll
    BOOL success = NO;
    if ( [self _parseAll] )
    {
        success = YES;
    }
    
    if ( success == NO && outError )
    {
        NSDictionary *info = [NSDictionary dictionaryWithObject:infoStr forKey:NSLocalizedDescriptionKey];
        *outError = [NSError errorWithDomain:@"com.SweetWilliam.HmiPad" code:0 userInfo:info];
    }
    
    return success;
}


////------------------------------------------------------------------------------------
//- (BOOL)finishDecodingOutErrorV:(NSError**)error
//{
//    // aqui comitar expressions
//    return [builder commitExpressionsOutError:error];
//}

//------------------------------------------------------------------------------------
- (BOOL)finishDecodingOutError:(NSError**)outError ignoreMissingSymbols:(BOOL)ignore
{
//    if ( infoStr )
//    {
//        if ( outError )
//        {
//            NSDictionary *info = [NSDictionary dictionaryWithObject:infoStr forKey:NSLocalizedDescriptionKey];
//            err = [NSError errorWithDomain:@"com.SweetWilliam.HmiPad" code:0 userInfo:info];
//        }
//        return NO;
//    }
    
    BOOL success = ( infoStr == nil );
    
    // si no hi ha un error previ aqui comitar expressions
    if ( success )
    {
        NSError *err = nil;
        [builder commitExpressionsByConvertingLocalSymbolsToGlobal];
        success = [builder finishCommitOutError:&err ignoreMissingSymbols:ignore];
        
        if ( !success )
            [self _resultWithError:SymbolicUnarchiverErrorCommitExpressionsError detail:[err localizedDescription]];
    }
    
    // generem un error si cal
    if ( success == NO )
    {
        if ( outError )
        {
            NSDictionary *info = [NSDictionary dictionaryWithObject:infoStr forKey:NSLocalizedDescriptionKey];
            *outError = [NSError errorWithDomain:@"com.SweetWilliam.HmiPad" code:0 userInfo:info];
        }
    
    }
    
    return success;
}


//------------------------------------------------------------------------------------
- (UInt8)errorCode
{
    return errCode;
}

- (NSString*)errorString
{
    return infoStr;
}

//------------------------------------------------------------------------------------
- (int)version
{
    return version;
}

//------------------------------------------------------------------------------------
- (NSDictionary *)metaData
{
    return metaData;
}

//------------------------------------------------------------------------------------
- (RpnBuilder *)builder
{
    return builder;
}

//------------------------------------------------------------------------------------
- (void)setErrorWithString:(NSString*)errorString
{
    [self _resultWithError:SymbolicUnarchiverErrorCustomObjectError detail:errorString];
}


//------------------------------------------------------------------------------------
- (id)decodeObjectForKey:(NSString *)key
{
    return [self _objectForKey:key];
}


- (void)decodeExistingObject:(id<SymbolicCoding>)object forKey:(NSString*)key
{
    [self _initExistingObject:object forKey:key];
}

- (void)decodeExistingCollection:(NSArray*)array forKey:(NSString*)key withObjectKeys:(NSArray*)keys
{
    [self _initExistingCollection:array forKey:key withKeys:keys];
}


- (BOOL)retrieveForObject:(id<SymbolicCoding>)object forKey:(NSString *)key
{
    return [self _retrieveObject:object forKey:key];
}



//------------------------------------------------------------------------------------
- (NSMutableArray *)decodeCollectionOfObjectsForKey:(NSString *)key
{
    return [self _collectionForKey:key];
}

- (BOOL)retrieveForCollectionOfObjects:(NSArray*)array forKey:(NSString*)key
{
    return [self _retrieveCollection:array forKey:key];
}


- (NSString *)_getIdentifierForObjectInfo:(_ObjectInfo *)objectInfo withPropertyKey:(NSString*)propertyKey
{
    __block NSString *objectIdent = nil;
    [(__bridge NSDictionary*)objectInfos enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {
        if ( obj == objectInfo )
        {
            objectIdent = key;
            *stop = YES;
        }
    }];

    if ( objectIdent && propertyKey )
    {
        objectIdent = [NSString stringWithFormat:@"%@.%@", objectIdent, propertyKey];
    }
    return objectIdent;
}


//------------------------------------------------------------------------------------
- (SWValue*)decodeValueForKey:(NSString*)key
{
    SWValue *value = [self _decodeValueForKey:key];
    return value;
}

//------------------------------------------------------------------------------------
- (BOOL)retrieveForValue:(SWValue*)value forKey:(NSString*)key
{
    return [self _retrieveValue:value forKey:key];
}


//------------------------------------------------------------------------------------
- (SWExpression*)decodeExpressionForKey:(NSString *)key
{
    SWExpression *expr = [self _registeredExpressionForKey:key];
    return expr;
}

//------------------------------------------------------------------------------------
- (int)decodeIntForKey:(NSString *)key
{
    _ObjectInfo *objectInfo = top();
    SWExpression *expr = [self _lazyPropertyForObjectInfo:objectInfo withKind:ObjectPropertyKindExpression forKey:key];
    int value = [expr valueAsDouble];
    return value;
}

//------------------------------------------------------------------------------------
- (double)decodeDoubleForKey:(NSString *)key
{
    _ObjectInfo *objectInfo = top();
    SWExpression *expr = [self _lazyPropertyForObjectInfo:objectInfo withKind:ObjectPropertyKindExpression forKey:key];
    double value = [expr valueAsDouble];
    return value;
}

//------------------------------------------------------------------------------------
- (NSString *)decodeStringForKey:(NSString *)key
{
    _ObjectInfo *objectInfo = top();
    SWExpression *expr = [self _lazyPropertyForObjectInfo:objectInfo withKind:ObjectPropertyKindExpression forKey:key];
    NSString *value = [expr valueAsStringWithFormat:nil];
    return value;
}

//------------------------------------------------------------------------------------
- (NSArray *)decodeStringsArrayForKey:(NSString *)key
{
    _ObjectInfo *objectInfo = top();
    SWExpression *expr = [self _lazyPropertyForObjectInfo:objectInfo withKind:ObjectPropertyKindExpression forKey:key];
    NSArray *value = [expr valueAsArray];
    return value;
}

@end



