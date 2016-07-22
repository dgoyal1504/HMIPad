//
//  SWPlcTag.h
//  HmiPad
//
//  Created by Joan on 22/08/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//


#import "PlcTagElement.h"
#import "SymbolicCoder.h"


@interface SWPlcTag : PlcTagElement <SymbolicCoding>

//@property (nonatomic,readonly) NSString *addressAsString;
//@property (nonatomic,readonly) NSString *tagTypeAsString;

// class
//+ (NSArray*)tagTypesArray;
+ (BOOL)isValidType:(NSString*)text forProtocol:(ProtocolType)protocol outErrString:(NSString**)errorString;
+ (BOOL)isValidAddress:(NSString*)addrString withType:(NSString*)typeString forProtocol:(ProtocolType)protocol outErrString:(NSString**)errorString;

// init
- (id)initAsDefaultForProtocol:(ProtocolType)protocol;


// type
//- (NSString*)tagTypeAsString;
//- (void)setTypeAsString:(NSString*)text structSize:(NSInteger)strSize;

// size
//- (NSInteger)structTypeSize;   // torna -1 si no es rellevant per presentacio a l'usuari
- (NSInteger)collectionCount;
//- (NSInteger)arraySize;
//- (void)setArraySize:(NSInteger)count;

// address
//- (NSString*)addressAsString;
//- (void)setAddressAsString:(NSString*)addrStr;

// other
- (NSString*)defaultFormatString;

- (void)setAddresAsString:(NSString*)addrString typeString:(NSString*)typeString;
- (NSString*)typeAsString;
- (NSString*)addressAsString;

@end
