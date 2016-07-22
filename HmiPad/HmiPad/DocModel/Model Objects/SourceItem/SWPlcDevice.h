//
//  SWPlcDevice.h
//  HmiPad
//
//  Created by Joan on 22/08/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "PlcDevice.h"
#import "SymbolicCoder.h"

//@class SWSourceItem;

@interface SWPlcDevice : PlcDevice<SymbolicCoding>

@property (nonatomic,retain) NSString *protocolAsString;
@property (nonatomic,retain) NSString *encodingAsString;
@property (nonatomic,retain) NSString *validationTagAsString;

@property (nonatomic,retain) NSString *localHostExtAsString;
@property (nonatomic,retain) NSString *remoteHostExtAsString;

- (void)normalize;

+ (BOOL)isValidValidationTagString:(NSString *)text forProtocol:(UInt16)protocol outErrorString:(NSString**)errorString;

+ (NSArray*)stringEncodingsArray;
+ (NSArray*)protocolTypesArray;

//@property (nonatomic, weak) SWSourceItem *sourceItem;

//- (void)setLocalPort:(UInt16)value;
//- (void)setRemotePort:(UInt16)value;

@end

