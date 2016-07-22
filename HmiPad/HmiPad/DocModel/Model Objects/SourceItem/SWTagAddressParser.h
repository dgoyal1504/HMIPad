//
//  SWTagAddressParser.h
//  HmiPad
//
//  Created by Joan on 22/08/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "PrimitiveParser.h"
#import "PlcObjectCommonTypes.h"
#import "PlcTagElement.h"

@interface SWTagAddressParser : PrimitiveParser
{
    ProtocolType plcProtocol;
    VarType varType;
    char inputStr[256];
    UInt8 eipTag[256];
    int eipTagLen;
    BOOL eipIndexAcc;
}

- (id)initWithString:(NSString*)addressAsString protocol:(ProtocolType)protocol varType:(VarType)vaType;
- (BOOL)parse;

@property (nonatomic,readonly) AreaCode area;
@property (nonatomic,readonly) UInt16 leadingCode;
@property (nonatomic,readonly) UInt32 addr;
@property (nonatomic,readonly) UInt16 bit;
@property (nonatomic,readonly) UInt16 btOffset;
@property (nonatomic,readonly) NSData *eipTagData;
@property (nonatomic,readonly) UInt16 errNum;
@property (nonatomic,readonly) UInt8 prOptions;
@property (nonatomic,readonly) BOOL hasIndex;

@end;
