//
//  SymbolicCoder.h
//  HmiPad
//
//  Created by Joan on 26/02/12.
//  Copyright (c) 2012 SweetWilliam, S.L.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrimitiveParser.h"
#import "SWValueTypes.h"

@protocol SymbolicCoding;
@class SWValue;
@class SWExpression;
@class RpnBuilder;

@interface SymbolicArchiver : NSObject
{
    CFMutableDataRef data;
    UInt8 *max;
    UInt8 *p;
    BOOL isStore;
    CFMutableArrayRef stack;
    CFStringEncoding stringEncoding;
}

// metode de conveniencia per codificar un array de objectes
+ (NSData*)archivedDataWithArrayOfObjects:(NSArray*)array forKey:(NSString *)key version:(NSInteger)version;

// Inicialitza un codificador. El resultat es un arxiu (NSMutableData) amb una
// representacio llegible per humans dels objectes codificats.
- (id)initForWritingWithMutableData:(NSMutableData *)dta version:(int)vers;
- (id)initForWritingWithMutableData:(NSMutableData *)dta metaData:(NSDictionary*)metaData version:(int)vers;

// indica que la codificacio es fa via retrieveWithSymbolicCoder
- (void)setIsStore:(BOOL)value;

// A cridar per completar la codificacio
- (void)finishEncoding;

// Access al arxiu codificat
- (NSData *)archivedData;

// A implementar dintre del metode encodeWithSymbolicCoder //

// Codifica un objecte que implementa el protocol SymbolicCoding.
// No serveix per altres clases
- (void)encodeObject:(id<SymbolicCoding>)object forKey:(NSString*)key;

// Codifica un array de objectes que implementen el protocol SymbolicCoding.
// No serveix per altres clases
- (void)encodeCollectionOfObjects:(NSArray*)collection forKey:(NSString*)key;

// Codifia una propietat SWValue o SWExpression
- (void)encodeValue:(SWValue*)value forKey:(NSString*)key;

// Codifica altres valors: int, double, NSString
- (void)encodeInt:(int)value forKey:(NSString *)key;
- (void)encodeDouble:(double)value forKey:(NSString *)key;
- (void)encodeString:(NSString *)str forKey:(NSString *)key;
- (void)encodeStringsArray:(NSArray*)array forKey:(NSString*)key;

@end


enum SymbolicUnarchiverErrorCode
{
    // cap error
    SymbolicUnarchiverErrorNone = 0,  // sempre zero
    
    // errors de parseig
    SymbolicUnarchiverErrorExpressionError,   // el subcode es un ExpressionErrorCode
    SymbolicUnarchiverErrorExtraChars,
    SymbolicUnarchiverErrorUnknownEncoding,
    SymbolicUnarchiverErrorUnsupportedEncoding,
    SymbolicUnarchiverErrorExpectedTokenAfterDot,
    SymbolicUnarchiverErrorExpectedToken,
    SymbolicUnarchiverErrorExpectedAsignOper,
    SymbolicUnarchiverErrorExpectedDotOper,
    SymbolicUnarchiverErrorExpectedNewMethodCall,
    SymbolicUnarchiverErrorExpectedOpenBracket,
    SymbolicUnarchiverErrorExpectedTokenOrCloseBracket,
    SymbolicUnarchiverErrorUnknownClass,
    SymbolicUnarchiverErrorUnknownSymbol,
    SymbolicUnarchiverErrorInvalidClass,
    SymbolicUnarchiverErrorDuplicatedSymbol,
    SymbolicUnarchiverErrorCustomObjectError,
    
    // errors de descodificacio
    SymbolicUnarchiverErrorObjectNotFoundForSymbol,
    SymbolicUnarchiverErrorObjectWrongTypeAssignedToValue,
    SymbolicUnarchiverErrorNonConstantExpressionForValue,
    SymbolicUnarchiverErrorCommitExpressionsError,
};

typedef enum SymbolicUnarchiverErrorCode SymbolicUnarchiverErrorCode;


@interface SymbolicUnarchiver : PrimitiveParser

{
    int version;
    UInt8 errCode; // codi d'error principal es un tipus SymbolicUnarchiverErrorCode
    UInt8 secErrCode;  // codi d'error secundari, es un tipus ExpressionErrorCode 
                        // si errCode conte SymbolicUnarchiverErrorExpressionError
    RpnBuilder *builder;
    id<SymbolicCoding> parent;
    
    CFMutableDictionaryRef objectInfos;  // conte parelles { symbol, objectInfo }
    CFIndex objectCount;
    
    CFStringEncoding stringEncoding;
    const unsigned char *source;
    const unsigned char *cErr;
    NSString *infoStr;
    CFMutableArrayRef stack;
    NSData *data;
    NSMutableDictionary *metaData;
}


// metode de conveniencia per descodificar un NSData previament codificat
+ (NSArray*)unarchivedObjectsWithData:(NSData*)data
    forKey:(NSString *)key
    builder:(RpnBuilder *)builder
    parentObject:(id)parent
    version:(NSInteger)version
    outError:(NSError**)error;

// torna el objecte a l'arrel de la codificacio
- (id)rootObject;

// Inicialitza un descodificador. El builder es necessari si hi ha expressions codificades
- (id)initWithRpnBuilder:(RpnBuilder*)buildr parentObject:(id<SymbolicCoding>)parent;

// A cridar just abans de iniciar la codificacio. Parseja el arxiu codificat i retorna possible errors.
// Si hi ha error, el resultat pot ser una decodificacio parcial 
- (BOOL)prepareForReadingWithData:(NSData *)dta outError:(NSError**)outErr;

// Commita les expressions que ha trobat durant la descodificacio
- (BOOL)finishDecodingOutError:(NSError**)error ignoreMissingSymbols:(BOOL)ignore;


// Determinacio d'errors
- (UInt8)errorCode;
- (NSString*)errorString;

// Torna el objecte passat a la inicialitzacio
- (RpnBuilder *)builder;

// No implementat !!
- (int)version;

// Torna un diccionary amb la metadata. Esta disponible despres de cridar prepareForReadingWithData
- (NSDictionary*)metaData;

// A implementar dintre del metode initWithSymbolicCoder //

// Decodifica un objecte, causa la inicialitzacio del objecte (initWithSymbolicCoder)
- (id)decodeObjectForKey:(NSString *)key;

// Decodifica un objecte, crida el inicialitzador del objecte (initWithSymbolicCoder) en el objecte que se li passa
// pero no en crea un de nou sino que utilitza el que se li passa
- (void)decodeExistingObject:(id<SymbolicCoding>)object forKey:(NSString*)key;
- (void)decodeExistingCollection:(NSArray*)array forKey:(NSString*)key withObjectKeys:(NSArray*)keys;


// Descodifica un array de objectes, causa la inicialitzador dels objectes del array
- (NSMutableArray *)decodeCollectionOfObjectsForKey:(NSString *)key;

// Descodifica una expressio
- (SWExpression*)decodeExpressionForKey:(NSString *)key;

// Descodifia una propietat SWValue
//- (SWValue*)decodeValueForKey:(NSString*)key withType:(SWValueType)type;  // DEPRECATED
- (SWValue*)decodeValueForKey:(NSString*)key;

// Descodificacio de valors: int, double, NSString
- (int)decodeIntForKey:(NSString *)key;
- (double)decodeDoubleForKey:(NSString *)key;
- (NSString *)decodeStringForKey:(NSString *)key;
- (NSArray *)decodeStringsArrayForKey:(NSString *)key;

// Permet avisar d'errors durant la inicialitzacio de un objecte (initWithSimbolicCoder)
- (void)setErrorWithString:(NSString*)errorString;

// Retrieve
- (BOOL)retrieveForObject:(id<SymbolicCoding>)object forKey:(NSString*)key;
- (BOOL)retrieveForCollectionOfObjects:(NSArray*)array forKey:(NSString*)key;
- (BOOL)retrieveForValue:(SWValue*)value forKey:(NSString*)key;
@end



///////////////////////////////////////////////////////////////////////////////////////
#pragma mark QuickCoding Protocol
///////////////////////////////////////////////////////////////////////////////////////

@protocol SymbolicCoding<NSObject/*ExpressionHolder*/>

@required
    // El decodificador crida aquest metode per inicialitzar un objecte codificat simbolicament. 
    // Ens passa el identificador amb el que es va codificar, i el objecte inmediat superior (pare) que ha
    // iniciat la descodificacio.
    - (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(id<SymbolicCoding>)parent;

    // El codificador crida aquest metode per demanar la codificacio de les propietats de un objecte.
    - (void)encodeWithSymbolicCoder:(SymbolicArchiver *)encoder;

@optional
    // Si un objecte per codificar adopta el seguent metode, el simbolic coder agafa el identificador retornat 
    // per codificar-lo. En aquest cas es responsabilitat del desarrollador assegurar que els identificadors son unics
    // per totes les instancies d'objectes codificats.
    // Si el metode no esta implementat el simbolic coder genera automaticament un identificador apropiat en base al 
    // identificador del pare del objecte codificat i el 'key' del objecte codificat en el pare .
    - (NSString *)symbolicIdentifier;

@optional
    // El decodificador crida aquest metode en el objecte -si implementat- per demanar un remplacament d'una 'key' que no
    // s'ha trobat en el arxiu original. Tornar nil si no hi ha remplacament o be una 'key' alternativa
    - (NSString *)replacementKeyForKey:(NSString*)key;

@optional
    - (void)retrieveWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(id<SymbolicCoding>)parent;
    - (void)storeWithSymbolicCoder:(SymbolicArchiver*)encoder;

@end
