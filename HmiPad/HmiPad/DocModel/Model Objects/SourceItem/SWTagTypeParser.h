//
//  SWTagTypeParser.h
//  HmiPad
//
//  Created by Joan on 20/04/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrimitiveParser.h"
#import "PlcObjectCommonTypes.h"
#import "PlcTagElement.h"

@interface SWTagTypeParser : PrimitiveParser
{
    ProtocolType plcProtocol;
    char inputStr[256];
}

- (id)initWithString:(NSString*)typeAsString protocol:(ProtocolType)protocol;
- (BOOL)parse;

@property (nonatomic,readonly) VarType varType;
@property (nonatomic,readonly) BOOL hasArrCount;
@property (nonatomic,readonly) NSInteger arrCount;
@property (nonatomic,readonly) UInt16 errNum;


@end
