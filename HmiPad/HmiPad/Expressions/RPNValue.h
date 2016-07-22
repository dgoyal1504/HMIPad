//
//  RPNValue.h
//  HmiPad_110323
//
//  Created by Joan on 24/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


//#import <Foundation/Foundation.h>
#import "QuickCoder.h"
#import "SWFormatUtils.h"

#import "SWValueTypes.h"

////------------------------------------------------------------------------------------------
//// tipus d'objectes primitius
//typedef enum 
//{
//    SWValueTypeError    = 0,
//    SWValueTypeNumber,
//    SWValueTypeString,
//    SWValueTypeArray,
//    SWValueTypeClassSelector,
//    //RPNVaTypeClass,
//    //RPNVaTypeObj,
//} SWValueType ;


#if __cplusplus

/*
////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Wrap
////////////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------------------
// clase per encapsular objectes amb suport per release/retain
template <class T, class J > class Wrap
{
    public:
        T o ;    
    
    private:
        UInt32 retainCount ;
    
    public:
    
        Wrap():retainCount(1),o() 
        {}
        
       // Wrap( const T &x ):retainCount(1),o(x) 
       // {}
        
        Wrap( const double x ):retainCount(1),o(x) 
        {}
        
        Wrap( const J &x ):retainCount(1),o(x) 
        {}
        
        Wrap( CFStringRef x ):retainCount(1),o(x) 
        {}
        
        Wrap( CFArrayRef x ):retainCount(1),o(x) 
        {}
        
        ~Wrap() 
        {}
    
        const void release()
        {
            if ( ! --retainCount ) delete this ;
        }
        
        const Wrap *retain()
        {
            ++retainCount ;
            return this ;
        }
} ;
*/

////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark RPNValue
////////////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------------------
class RPNValue ;

//------------------------------------------------------------------------------------------
// tipus per empaquetar la clase
//typedef Wrap<RPNValue,RPNValue> RPNValueWrap ;


//-------------------------------------------------------------------------------------------
// estructures i arrays per accedir a metodes i clases per index
typedef void (RPNValue::*RPNMethod)(const int msl, const unsigned int count, const RPNValue *args) ;


//------------------------------------------------------------------------------------------
typedef struct
{
    CFStringRef name ;
    RPNMethod method ;
    void *cfunct ;
} RPNMethodsStruct ;


//------------------------------------------------------------------------------------------
typedef struct
{
    CFStringRef name ;
    const RPNMethodsStruct *methods ;
    int methodCount ;
} RPNClassesStruct ;

extern const int RPNClassesCount ;
extern const RPNClassesStruct RPNClasses[] ;



//------------------------------------------------------------------------------------------
// tipus d'objecte en la clase

typedef enum 
{
    RPNClSelGenericClass    = 0,   // selector especial per metodes de qualsevol clase
    RPNClSelRootClass       = 1,   // selector especial per funcions
} RPNClassSelectors ;


//------------------------------------------------------------------------------------------
// tipus d'error en el objecte quan SWValueType > 0
typedef enum 
{
    //RPNVaErrorNotInitialized  = 0,
    RPNVaErrorWrongType = 0,
    RPNVaErrorCodedWrongType,
    RPNVaErrorWrongTypeForMethod,
    RPNVaErrorArrayBounds,
    RPNVaErrorStringBounds,
    RPNVaErrorHashBounds,
    RPNVaErrorNumArguments,
    RPNVaErrorArgumentsType,
    
    RPNVaErrorBitNumArguments,
    RPNVaErrorBitArgumentsType,
    
    RPNVaErrorStringNumArguments,
    RPNVaErrorStringArgumentsType,
    
    RPNVaErrorArrayNumArguments,
    RPNVaErrorArrayArgumentsType,
    
    RPNVaErrorHashArgumentsTypeError,
    RPNVaErrorHashOddNumItems,
    RPNVaErrorHashItemsTypeError,
    RPNVaErrorHashNumArguments,
    
    RPNVaErrorEnumerableItemsTypeError,
    RPNVaErrorEnumerableNumItems,
    
    RPNVaErrorCount,

} RPNValueErrCode ;


//enum
//{
//    RPNVaFlagChanging = 1 << 0,
//};
//typedef UInt16 RPNValueStatusFlags;

typedef union
{
    struct
    {
        UInt16 changing:1;
    };
    UInt16 all;
}
RPNValueStatusFlags;

//------------------------------------------------------------------------------------------
// definicio de la clase
class RPNValue
{
    public:
        SWValueType typ;
        RPNValueStatusFlags status;  // no es codifica, utilitzat durant la evaluacio
        union
        {
            double d ;
            UInt32 sel ;
            RPNValueErrCode err ;
            CFTypeRef obj ;
        };
        
    public:
        // constructors
        RPNValue() ;
        RPNValue( const double num ) ;
        RPNValue( const double *nums, const int count ) ;    // construeix un rpnvalue amb un array de numeros
        RPNValue( CFStringRef *cStrs, const int count ) ;    // construeix un rpnValue amb un array de strings
        RPNValue( const UInt32 slct ) ;
        RPNValue( const CFStringRef str ) ;
        RPNValue( const CGPoint &point ) ;
        RPNValue( const CGSize &size ) ;
        RPNValue( const CGRect &rect ) ;
        RPNValue( const SWValueRange &range );
        //RPNValue( const CFTypeRef obj ) ;
        RPNValue( const RPNValue &rhs ) ;
    
        // destructor
        ~RPNValue() ;    
        
        // asignement operator (operator chaining not suported)
        void operator=( const double num ) ;
        void operator=( const UInt32 slct  ) ;
        void operator=( const CFStringRef str ) ;
        void operator=( const CGPoint &point ) ;
        void operator=( const CGSize &size ) ;
        void operator=( const CGRect &rect ) ;
        void operator=( const SWValueRange &range );
        //void operator=( const CFTypeRef obj ) ;
        void operator=(const RPNValue &rhs) ;
        
        // equal, unequal, less than, greater than operator
        bool operator==( const RPNValue &rhs ) const;
        bool operator!=( const RPNValue &rhs ) const;
        bool operator>( const RPNValue &rhs ) const;
        bool operator<( const RPNValue &rhs ) const;
        unsigned long hashCode() const;
    
        // encoding decoding
        void decode( QuickUnarchiver *decoder ) ;
        //void retrieve( QuickUnarchiver *decoder ) ;
        void encode( QuickArchiver *encoder ) const ;
    
        // enumeration (static)
        static int selectorForClass(NSString *className);
        static int selectorForMethod_inClassWithSelector(NSString *methodName, int clsSel);
        static void enumerateClassesUsingBlock( void (^block)(NSString *className) );
        static void enumerateRootMethodsUsingBlock( void (^block)(NSString *methodName) );
        static void enumerateMethodsForClassSelector_usingBlock( int clsSel, void (^block)(NSString *name) );
        //static void enumerateMethodsForClassName_usingBlock( NSString *className, void (^block)(NSString *methodName) );
        
        // isError
        inline bool isError() { return ( typ == SWValueTypeError ) ; }
        
        // clear
        void clear() ;
    
        // no Source
        //void noSource();
        
        // arrays
        const int arrayCount() const ;
        const RPNValue &valueAtIndex(int indx) const ;
    
        // hash
        const int hashCount() const;
        const void getHashKeysAndValues( const RPNValue **keys, const RPNValue **values);
        const RPNValue *getHashValueForKey( const RPNValue &key );
  
    public: // metodes utilitzats per el RPNInterpreter
    
        // indirection
        void getElement( const unsigned int count, const RPNValue *args ) ;   // operador [ ] per indireccio
        void arrayMake( const unsigned int count, const RPNValue *args ) ;
        void hashMake( const unsigned int count, const RPNValue *args );   // count es el numero d'arguments es a dir el doble que el numero de keys
    
        void hashLog();
    
        inline void callFunct( const int csl, const int msl, const unsigned int count, const RPNValue *args )
        {
            const RPNMethodsStruct &methodsStruct = RPNClasses[csl].methods[msl] ;
            const RPNMethod f = methodsStruct.method ;
            (this->*f)(msl,count,args) ;
        }
    
        // unary
        void minus() ;
        void opnot() ;    // !
        void opcompl() ;  // ~
    
        // range
        void range( const RPNValue &rhs ) ;   // ..
    
        // arith
        void add( const RPNValue &rhs ) ;
        void sub( const RPNValue &rhs ) ;
        void times( const RPNValue &rhs ) ;
        void div( const RPNValue &rhs ) ;
        void mod( const RPNValue &rhs ) ;
        
        // compare
        void lt( const RPNValue &rhs ) ;
        void le( const RPNValue &rhs ) ;
        void eq( const RPNValue &rhs ) ;
        void ne( const RPNValue &rhs ) ;
        void ge( const RPNValue &rhs ) ;
        void gt( const RPNValue &rhs ) ;
        
        // logical
        void opor( const RPNValue &rhs ) ;
        void opand( const RPNValue &rhs ) ;
        void opbitor( const RPNValue &rhs ) ;
        void opbitxor( const RPNValue &rhs ) ;
        void opbitand( const RPNValue &rhs ) ;
        
        // tern
        void tern( const RPNValue &rhs1, const RPNValue &rhs2 ) ;
        
        // if
        bool jeq() ;
        
        // comma list
        BOOL commaList( const unsigned int count, const RPNValue *args ); 
        
        // altres
        void to_s( const int msl, const unsigned int count, const RPNValue *args ) ;
        void to_f( const int msl, const unsigned int count, const RPNValue *args ) ;
        void to_i( const int msl, const unsigned int count, const RPNValue *args ) ;
        void rabs( const int msl, const unsigned int count, const RPNValue *args ) ;
        void rround( const int msl, const unsigned int count, const RPNValue *args ) ;
        void rfloor( const int msl, const unsigned int count, const RPNValue *args ) ;
        void rceil( const int msl, const unsigned int count, const RPNValue *args ) ;
        //void to_a( const int msl, const unsigned int count, const RPNValue *args ) ;
        void chr( const int msl, const unsigned int count, const RPNValue *args ) ;
        void fetch( const int msl, const unsigned int count, const RPNValue *args ) ;
        void length( const int msl, const unsigned int count, const RPNValue *args ) ;
        void split( const int msl, const unsigned int count, const RPNValue *args ) ;
        void join( const int msl, const unsigned int count, const RPNValue *args ) ;
        void array_min( const int msl, const unsigned int count, const RPNValue *args ) ;
        void array_max( const int msl, const unsigned int count, const RPNValue *args ) ;
        void arrayminmax( const int msl, const unsigned int count, const RPNValue *args ) ;  // not implemented
        void keys( const int msl, const unsigned int count, const RPNValue *args ) ;
        void values( const int msl, const unsigned int count, const RPNValue *args ) ;
    
        // ranges
        void range_begin( const int msl, const unsigned int count, const RPNValue *args ) ;
        void range_end( const int msl, const unsigned int count, const RPNValue *args ) ;
        
        // rects, points i sizes
        void rect_origin( const int msl, const unsigned int count, const RPNValue *args ) ;
        void rect_size( const int msl, const unsigned int count, const RPNValue *args ) ;
        void point_x( const int msl, const unsigned int count, const RPNValue *args ) ;
        void point_y( const int msl, const unsigned int count, const RPNValue *args ) ;
        void size_width( const int msl, const unsigned int count, const RPNValue *args ) ;
        void size_height( const int msl, const unsigned int count, const RPNValue *args ) ;
    
        // temps/hora
        void timeFormatter( const int msl, const unsigned int count, const RPNValue *args );
        void year( const int msl, const unsigned int count, const RPNValue *args );
        void month( const int msl, const unsigned int count, const RPNValue *args );
        void day( const int msl, const unsigned int count, const RPNValue *args );
        void wday( const int msl, const unsigned int count, const RPNValue *args );
        void yday( const int msl, const unsigned int count, const RPNValue *args );
        void week( const int msl, const unsigned int count, const RPNValue *args );
        void hour( const int msl, const unsigned int count, const RPNValue *args );
        void min( const int msl, const unsigned int count, const RPNValue *args );
        void sec( const int msl, const unsigned int count, const RPNValue *args );
        
        // funcions generals
        void format( const int msl, const unsigned int count, const RPNValue *args ) ;
        void rand( const int msl, const unsigned int count, const RPNValue *args ) ;
        
        // Math
        void mathPi( const int msl, const unsigned int count, const RPNValue *args ) ;  // PI
        void math1( const int msl, const unsigned int count, const RPNValue *args ) ;  // math 1 argument
        void math2( const int msl, const unsigned int count, const RPNValue *args ) ;  // math 2 arguments
        
        // SM
        void smLookup( const int msl, const unsigned int count, const RPNValue *args ) ;
        void smError( const int msl, const unsigned int count, const RPNValue *args ) ;
        void smColor( const int msl, const unsigned int count, const RPNValue *args ) ;
        void smRect( const int msl, const unsigned int count, const RPNValue *args ) ;
        void smPoint( const int msl, const unsigned int count, const RPNValue *args ) ;
        void smSize( const int msl, const unsigned int count, const RPNValue *args ) ;
        void smDeviceId( const int msl, const unsigned int count, const RPNValue *args ) ;
        void smAllFonts( const int msl, const unsigned int count, const RPNValue *args );
        void smAllColors( const int msl, const unsigned int count, const RPNValue *args );
        void smEncrypt( const int msl, const unsigned int count, const RPNValue *args );
        void smDecrypt( const int msl, const unsigned int count, const RPNValue *args );
        void smMkTime( const int msl, const unsigned int count, const RPNValue *args );
        
        // selector
        /*
        inline void execute( RPNMethod0 method, const RPNValue *args )
        {
            //const RPNValue &arg1 = args[0] ;
            (this->*method)() ;
        }
        */
        
        
    private:  // metodes privats
        //void inline clear() ;
        
        void setError( RPNValueErrCode er ) ;
        inline void releaseObj() ;
        inline void setTypeError() ;
        inline void setTypeMError() ;
        inline void setNumArgumentsError() ;
        inline void setArgumentsTypeError() ;
    
        inline void setNumber( double num ) ;
        inline void setAbsoluteTime( double num ) ;
        inline void setSelector( const UInt32 slct ) ;
        inline void setStructBytes_length_withType( const void* bytes, UInt32 length, SWValueType newType ) ;
        void setObject_withType( CFTypeRef newObj, UInt16 newType ) ;
        CFStringRef createStringWithFormatFromInlineBuffer( CFStringInlineBuffer *inlineBuffer, const CFIndex indx, CFIndex *outIndx ) const ;
} ;



//------------------------------------------------------------------------------------------
// Crea una CFString a partir de un rpnValue, en principi utilitzable com a source de una expressio,
// aplicant el format especificat d'acord amb la especificacio de sprintfStringCreate per els tipus compatibles.
// Si format es nil crea una representacio adequada del valor, en principi utilitzable com a source de una expressio
// per a tots els tipus.
// Si el rpnVal es un array crea una representacio (recursiva) de un array en la que a cada element se li aplica format
extern CFStringRef createSourceStringForRpnValue_withFormat( const RPNValue &rpnVal, CFStringRef format );

// Crea una string representativa del valor d'acord amb l'espeficicacio de sprintf per els tipus compatibles.
// aquesta es la funcio utilitzada per la funcio format, i to_s. Si format es NULL torna una string que representa
// el valor pero no necesariament parsejable
extern CFStringRef createStringForRpnValue_withFormat( const RPNValue &rpnVal, CFStringRef format ) ;

// Crea una string representativa del valor amb un format llegible per el usuari
extern CFStringRef createPrintableStringForRpnValue( const RPNValue &rpnVal );

// Crea i torna un array de strings amb createStringForRpnValue_withFormat, sempre torna un array.
extern CFArrayRef createStringsArrayForRpnValue_withFormat( const RPNValue &rpnValue, CFStringRef format );

// Crea i torna un CFData amb doubles a partir del contingut de rpnValue, sempre torna un CFdata
extern CFDataRef createDataWithDoublesForRpnValue( const RPNValue &rpnValue );

// igu
extern double valueAsAbsoluteTimeForRpnValue( const RPNValue &rpnVal );
extern double valueAsDoubleForRpnValue( const RPNValue &rpnVal ) ;
extern CGPoint valueAsCGPointForRpnValue( const RPNValue &rpnVal ) ;
extern CGSize valueAsCGSizeForRpnValue( const RPNValue &rpnVal ) ;
extern CGRect valueAsCGRectForRpnValue( const RPNValue &rpnVal ) ;
extern SWValueRange valueAsSWValueRangeForRpnValue( const RPNValue &rpnVal );

#endif

/*
//------------------------------------------------------------------------------------
static inline int valuesCountForRpnValue( const RPNValue &rpnVal )
{
    return rpnVal.arrayCount() ;
}

//------------------------------------------------------------------------------------
static inline const RPNValue & valueAtIndex_forRpnValue( const int indx, const RPNValue &rpnVal ) 
{
    int count = rpnVal.arrayCount() ;
    if ( indx >= 0 && indx < count ) return rpnVal.valueAtIndex(indx) ;
    return NULL ;
}
*/
