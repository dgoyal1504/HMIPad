//
//  QuickCoder.h
//  iPhoneDomusSwitch_090605
//
//  Created by Joan on 05/06/09.
//  Copyright 2009 SweetWilliam, S.L.. All rights reserved.
//

//#import <Foundation/Foundation.h>


// Classes per suportar encoding/decoding d'objectes. Estan altament optimitzades per 
// ser molt rápides. Supporten les coleccions básiques, i els objectes que conformen
// el QuickCodingProtocol. L'utilització és similar a NSCoding
//
// Suporta també dues versións de dades codificades, que comencen per "SQW1" ó "SQW0"
// la diferència entre elles es que SQW1 encapsula SQW0 amb un prefix de longitud
// constant que indica la longitud de SQW0. Aquesta caracteristica és util en combinació
// amb streams perque es pot coneixer la longitud de SQW0 disposant només de 
// la capsalera SQW1. Per defecte sempre codifica per SQW1 pero descodifica qualsevol
// de les dues.

///////////////////////////////////////////////////////////////////////////////////////
#pragma mark Decode Helper Functions
///////////////////////////////////////////////////////////////////////////////////////


extern BOOL dataContainsUtf16( CFDataRef data ) ;
extern CFDataRef create8bitRepresentationOfData( CFDataRef data ) ;



///////////////////////////////////////////////////////////////////////////////////////
#pragma mark QuickArchiver
///////////////////////////////////////////////////////////////////////////////////////

@interface QuickArchiver : NSObject 

{
    CFMutableDataRef data ;
    UInt8 *max ;
    UInt8 *p ;
    BOOL isStore ;
    CFMutableDictionaryRef classIds ; // diccionari de classes i indexos
    CFIndex classCount ;
    CFMutableDictionaryRef objectIds ; // diccionari de classes i indexos
    CFIndex objectCount ;
}

- (id)initForWritingWithMutableData:(NSMutableData *)dta version:(int)vers ;
- (void)setIsStore:(BOOL)value ;
- (void)finishEncoding;
- (NSData *)archivedData;
- (void)encodeObject:(id)object;
- (void)encodeInt:(int)value;
- (void)encodeFloat:(float)value;
- (void)encodeDouble:(double)value;
- (void)encodeBytes:(void*)bytes length:(size_t)length ;

//- (void)encodeValueOfObjCType:(const char *)valueType at:(const void *)address ;
//- (void)encodeDataObject:(NSData *)data ;
//- (void)encodeString:(NSString *)str ;
//- (void)encodeBool:(BOOL)bol;

//- (NSInteger)versionForClassName:(NSString *)className;



@end



///////////////////////////////////////////////////////////////////////////////////////
#pragma mark QuickUnarchiver
///////////////////////////////////////////////////////////////////////////////////////

#define SWQ1HEADER_LENGTH (4+sizeof(uint32_t))

@interface QuickUnarchiver : NSObject 

{
    CFDataRef data ;
    int version ;
    int swqVersion ;
    UInt8 *max ;
    UInt8 *p ;
    //BOOL isStore ;
    CFMutableArrayRef classIds ;
    CFIndex classCount ;
    CFMutableArrayRef objectIds ;
    CFIndex objectCount ;
    
}

+ (uint32_t)SWQ0LengthForSWQ1Data:(NSData*)dta ;

- (id)initForReadingWithData:(NSData *)dta ;
//- (void)finishDecoding;
//- (void)setIsStore:(BOOL)value ;
- (int)version ;
- (id)decodeObject ;
- (int)decodeInt;
- (float)decodeFloat;
- (double)decodeDouble;
- (void)decodeBytes:(void*)bytes length:(size_t)length ;
- (BOOL)retrieveForObject:(id)obj ;

//- (void)decodeValueOfObjCType:(const char *)valueType at:(void *)address ;
//- (NSData *)decodeDataObject ;
//- (NSString *)decodeString;
//- (BOOL)decodeBool;

//- (NSInteger)versionForClassName:(NSString *)className;



@end


///////////////////////////////////////////////////////////////////////////////////////
#pragma mark QuickCoding Protocol
///////////////////////////////////////////////////////////////////////////////////////

@protocol QuickCoding

-(id)initWithQuickCoder:(QuickUnarchiver *)decoder ;
-(void)encodeWithQuickCoder:(QuickArchiver *)encoder ;
@optional
-(void)retrieveWithQuickCoder:(QuickUnarchiver*)decoder ;
-(void)storeWithQuickCoder:(QuickArchiver *)encoder ;

@end

