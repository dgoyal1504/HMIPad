//
//  SWSystemTable.h
//  HmiPad
//
//  Created by Joan on 31/08/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWValueProtocols.h"

//#import "QuickCoder.h"
//#import "SymbolicCoder.h"

@class RpnBuilder;

@interface SWSystemTable : NSObject /* <QuickCoding,SymbolicCoding> */
{
    CFMutableDictionaryRef _symbolTable ; // conte parelles CFStringRef, ExpressionHolder
}

- (id)initForUsingWithBuilder:(RpnBuilder *)builder;
- (CFDictionaryRef)symbolTable;
- (void)symbolTableAddObject:(id<ValueHolder>)holder forKey:(NSString*)key;

@end
