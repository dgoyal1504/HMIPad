//
//  SWSystemTable.m
//  HmiPad
//
//  Created by Joan on 31/08/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWSystemTable.h"
#import "RpnBuilder.h"
#import "SWValueProtocols.h"

@implementation SWSystemTable

- (id)initForUsingWithBuilder:(RpnBuilder *)builder
{
    self = [super init];
    if (self)
    {
        [builder setSystemTable:[self symbolTable]];
    }
    return self;
}


- (CFDictionaryRef)symbolTable
{
    if ( _symbolTable == nil )
    {
        _symbolTable = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, NULL);
    }
    
    return _symbolTable ;
}


- (void)symbolTableAddObject:(id<ValueHolder>)holder forKey:(NSString*)key
{
    if ( _symbolTable == nil )
    {
        _symbolTable = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, NULL);
    }
    
    CFDictionarySetValue( _symbolTable, (__bridge const void *)(key), (__bridge const void *)(holder) );
}

- (void)dealloc
{
    if ( _symbolTable ) CFRelease( _symbolTable ) ;
}


//#pragma mark protocol QuickCoder
//
//- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
//{
//    self = [super init];
//    return self ;
//}
//
//- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
//{
//}
//
//
//#pragma mark protocol SymbolicCoder
//
//- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(id<SymbolicCoding>)parent
//{
//    self = [super init];
//    return self;
//}
//
//    
//- (void)encodeWithSymbolicCoder:(SymbolicArchiver *)encoder
//{
//}


@end
