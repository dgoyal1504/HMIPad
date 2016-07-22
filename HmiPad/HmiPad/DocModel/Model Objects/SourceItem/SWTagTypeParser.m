//
//  SWTagTypeParser.m
//  HmiPad
//
//  Created by Joan on 20/04/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWTagTypeParser.h"

@implementation SWTagTypeParser

- (id)initWithString:(NSString*)typeAsString protocol:(ProtocolType)protocol
{
    self = [super init];
    if ( self )
    {        
        BOOL valid = CFStringGetCString( (__bridge CFStringRef)typeAsString, inputStr, sizeof(inputStr), kCFStringEncodingASCII);
        c = (UInt8*)inputStr;
        if ( valid ) end = c + strlen(inputStr);
        else end = c;
        plcProtocol = protocol;
    }
    return self;
}

- (BOOL)parse
{
    if ( ! (c < end) ) return NO;
    
    BOOL done = NO;
    
    done = [self _parsePlcSymTypeWDimensions];
    
    if ( done ) 
    {
        if ( c != end )
        {
            _errNum = kPlcTagErrTypeNotSupported; //canviar
            done = NO;
        }
    }
    
    return done;
}


- (BOOL)_parsePlcSymTypeWDimensions
{
    if ( [self _parsePlcSymType] )
    {
        //PlcTagElementDomainType domain = (plcTag->varType&kDomainMask) ;
        _hasArrCount = NO ;
        _arrCount = 0 ;
        _skipSp ;
        if ( _parseChar( '[' ) )
        {
            _skipSp ;

            unsigned int indx = 0 ;
            if ( [self parseUInt:&indx] )
            {
                while ( 1 )
                {
                    _skipSp ;
                    if ( _parseChar( ',' ) )
                    {
                        _skipSp ;
                        if ( [self parseUInt:&indx] ) continue ;
                        else return NO ;
                    }
                    break ;
                }
    
                _skipSp ;
                if ( _parseChar( ']' ) )
                {
                    _hasArrCount = YES ;
                    _arrCount = indx ;
                    return YES ;
                }
            }
        }
        else 
        {
            return YES ;
        }
    }
    return NO ;
}


- (BOOL)_parsePlcSymType
{
    BOOL result = YES ;
    //_skipSp ;
    if ( _parseCString( "BOOL", 4 ) ) _varType = kBoolVarType ;
    else if ( _parseCString( "SINT", 4 ) ) _varType = kByteVarType ;
    else if ( _parseCString( "INT", 3 ) ) _varType = kShortIntVarType ;
    else if ( _parseCString( "DINT", 4 ) ) _varType = kLongIntVarType ;
    else if ( _parseCString( "REAL", 4 ) ) _varType = kFloatVarType ;
    else if ( _parseCString( "UINT_BCD", 8 ) ) _varType = kShortBcdVarType ;
    else if ( _parseCString( "UINT", 4 ) ) _varType = kUnsignedShortIntVarType ;
    else if ( _parseCString( "UDINT_BCD", 9 ) ) _varType = kLongBcdVarType ;
    else if ( _parseCString( "UDINT", 5 ) ) _varType = kUnsignedLongIntVarType ;
    else if ( _parseCString( "CHANNEL", 7 ) ) _varType = kUnsignedShortIntVarType ;
    else if ( _parseCString( "WORD", 4 ) ) _varType = kUnsignedShortIntVarType ;
    else if ( _parseCString( "DWORD", 5 ) ) _varType = kUnsignedLongIntVarType ;
    else result = NO ;
    
    if ( result == NO )
    {
        // mirem si es string
        if ( _parseCString( "STRING", 6 ) ) 
        {
            _skipSp ;
            unsigned int size ;
            if ( [self _parseSizeSpec:&size] )
            {
                _varType = kS7StringVarType ;   // posem S7 string
                _varType.siz = (2+size)*8 ;     // dos bytes mes la longitud
            }
            else
            { 
                // posem S7 string segons protocol o tentativament PCCC string (string generica)
                if ( plcProtocol == kProtocolTypeSiemensISO_TCP ) _varType = kS7StringVarType ;
                else if ( plcProtocol == kProtocolTypeEIP ) _varType = kEIPStringVarType ;
                else if ( plcProtocol == kProtocolTypeOptoForth) _varType = kOPTOStringVarType ;
                else _varType = kPCCCStringVarType ;
            }     
            result = YES ;
        }
        
        // mirem si es una string de char
        else if ( _parseCString( "CHAR", 4 ) ) 
        {
            _skipSp ;
            unsigned int size ;
            if ( [self _parseSizeSpec:&size] )
            {
                _varType = kCharStringVarType ;   // posem char string
                _varType.siz = size*8 ;  // la longitud
            }
            else
            { 
                // posem un char simple
                _varType = kCharVarType ;
            }
            result = YES ;
        }
    
        else
        // no s'ha trobat res conegut
        {
            _varType = kUnknownVarType ;
            _errNum = kPlcTagErrTypeNotSupported ;
//            const unsigned char *pcstr ;
//            size_t plen ;
//            if ( [self parseToken:&pcstr length:&plen] )
//            {
//                // do stuff ;
//                result = YES ;
//            }
        }
    }
    
    return result ;
}


- (BOOL)_parseSizeSpec:(unsigned int*)size ;
{
    const UInt8 *svsc = c ;
    if ( _parseChar('(') )
    {
        unsigned int siz ;
        _skipSp ;
        if ( [self parseUInt:&siz] )
        {
            _skipSp ;
            if ( _parseChar(')') )
            {
                if (size) *size = siz ;
                return YES ;
            }
        }
        c = svsc ;
    }
    return NO ;
}



@end
