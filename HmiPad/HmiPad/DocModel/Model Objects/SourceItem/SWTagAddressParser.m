//
//  SWTagAddressParser.m
//  HmiPad
//
//  Created by Joan on 22/08/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWTagAddressParser.h"



@implementation SWTagAddressParser

@synthesize area = _area;
@synthesize leadingCode = _leadingCode;
@synthesize addr = _addr;
@synthesize bit = _bit;
@synthesize btOffset = _btOffset;
@synthesize eipTagData = _eipTagData;
@synthesize errNum = _errNum;
@synthesize hasIndex = _hasIndex;

- (id)initWithString:(NSString*)addressAsString protocol:(ProtocolType)protocol varType:(VarType)vaType
{
    self = [super init];
    if ( self )
    {
        /*
        NSData *data = [addressAsString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:NO];
        c = [data bytes];  // data pot ser nil
        end = c + [data length];
        plcProtocol = protocol;
        varType = vaType;
        */
        
        BOOL valid = CFStringGetCString( (__bridge CFStringRef)addressAsString, inputStr, sizeof(inputStr), kCFStringEncodingASCII);
        c = (UInt8*)inputStr;
        if ( valid ) end = c + strlen(inputStr);
        else end = c;
        plcProtocol = protocol;
        varType = vaType;
    }
    return self;
}


- (BOOL)parse
{
    if ( ! (c < end) ) return NO;

    BOOL done = NO;
    if ( plcProtocol == kProtocolTypeEIP )
    {
        _area = kAreaCodeEIP;
        done = [self _parseNativeEIPSymLabel];
    }
    else if ( plcProtocol == kProtocolTypeOptoForth )
    {
        if ( varType.sto & kStorageStruct ) _area = kAreaCodeOPTOString;
        else _area = kAreaCodeOPTO;  // <-- encara pot canviar si es un point o una taula
        done = [self _parseNativeOptoForthSymLabel];
    }
    else
    {
        done = [self _parsePlcSymAddr];
    }
    
    if ( done ) 
    {
        if ( c != end )
        {
            _errNum = kPlcTagErrAreaNotSupported; //canviar
            done = NO;
        }
    }
    
    return done;
}

//-------------------------------------------------------------------------------------------
// parseja la adressa del simbol
- (BOOL)_parsePlcSymAddr
{
    if ( ! (c < end) ) return NO;
    ProtocolType theProtocol = plcProtocol;
    
    _area = kAreaCodeUnknown;
    _leadingCode = 0;
    _prOptions = 0;
    _errNum = kPlcTagErrNone;
    
    UInt16 addr = 0;
    BOOL finsCounter = NO;
    
    // protocol modbus
    if ( theProtocol == kProtocolTypeModbus ) 
    {
        if ( _parseCString( "IR", 2 ) ) _area = kAreaCodeModbIR;
        else if (  _parseCString( "HR", 2 ) ) _area = kAreaCodeModbHR;
        else switch ( toupper( *c++ ) )
        {
            case 'I': _area = kAreaCodeModbI; break;
            case 'C': _area = kAreaCodeModbC; break;
            //...
            default : c--; _errNum = kPlcTagErrAreaNotSupported; break;
        }
    }
        
    // protocol siemens
    if ( theProtocol == kProtocolTypeSiemensISO_TCP )
    {
        if ( _parseCString( "DB", 2 ) )   // DBn.DB
        {
            int db = 0;
            while ( c < end && *c >= '0' && *c <= '9' ) db = db*10 + (*c++ - '0');
            _leadingCode = db;
            _area = kAreaCodeS7DB;
            if ( c < end && *c == '.' )
            {
                c++;
                if ( _parseCString( "DB", 2 ) ) {}
                else _errNum = kPlcTagErrAreaNotSupported;
            }
        }
        
        else switch ( toupper( *c++ ) )
        {
            case 'M': _area = kAreaCodeS7Flags; break;
            case 'Q': _area = kAreaCodeS7Outputs; _prOptions = kPlcTagS7English; break;
            case 'A': _area = kAreaCodeS7Outputs; break;
            case 'I': _area = kAreaCodeS7Inputs; _prOptions = kPlcTagS7English; break;
            case 'E': _area = kAreaCodeS7Inputs; break;
            //...
            default : c--; _errNum = kPlcTagErrAreaNotSupported; break;
        }
        
        if ( _errNum == kPlcTagErrNone )
        {
            UInt16 adrLen = kBitSizeUnknown;
            switch ( toupper( *c++ ) )
            {
                default : c--; adrLen = kBitSizeBit; break;
                case 'B' : adrLen = kBitSizeChar; break;
                case 'W' : adrLen = kBitSizeShort; break;
                case 'D' : adrLen = kBitSizeLongInt; break;
                case 'X' : break; // any size
            }
            
            if ( adrLen != kBitSizeUnknown && adrLen != kBitSizeBit && varType.siz != adrLen )
            {
                _errNum = kPlcTagErrInvalidArrayAccess;
            }
        }
    }
    
    // protocol omronfins
    if ( theProtocol == kProtocolTypeOmronFins  )
    {
        if ( c < end && *c >= '0' && *c <= '9' ) // && !isLookup ) // plcTag->varType != kLookupVarType ) 
        {
            _area = kAreaCodeCIO;
        }
        else switch ( toupper( *c++ ) )
        {
            case 'W': _area = kAreaCodeW; break;
            case 'D':
                if ( c < end && toupper( *c ) == 'M' ) c++;
                _area = kAreaCodeDM;
                break;
            case 'T': 
                _area = kAreaCodeTC;
                if ( boolVarType(varType)) _area = kAreaCodeTCFlag;
                break;
            case 'C':
                if ( c < end && toupper( *c ) == 'I' )
                {
                    c++;
                    if ( c < end && toupper( *c ) == 'O' )
                    {
                        c++;
                        _area = kAreaCodeCIO;
                        break;
                    }
                    _errNum = kPlcTagErrAreaNotSupported; break;
                }
                _area = kAreaCodeTC;
                if ( boolVarType(varType)) _area = kAreaCodeTCFlag;
                finsCounter = YES; 
                break;  
            case 'H':
                if ( c < end && toupper( *c ) == 'R' ) c++;
                _area = kAreaCodeHR;
                break;
            case 'A':
                if ( c < end && toupper( *c ) == 'R' ) c++; 
                _area = kAreaCodeAR;
                break;
            case 'E':
                if ( c < end && toupper( *c ) == 'M' ) c++; 
                _area = kAreaCodeEMCurrent;
                break;
            //...
            default : c--; _errNum = kPlcTagErrAreaNotSupported; break;
        }
    }
    
    // protocol melsec
    if ( theProtocol == kProtocolTypeMelsec )
    {
        switch ( toupper( *c++ ) )
        {
            case 'X': _area = kAreaCodeMelsecX; break;
            case 'Y': _area = kAreaCodeMelsecY; break;
            case 'M': _area = kAreaCodeMelsecM; break;
            case 'L': _area = kAreaCodeMelsecL; break;
            case 'F': _area = kAreaCodeMelsecF; break;
            case 'V': _area = kAreaCodeMelsecV; break;
            //case 'S': plcTag->area = kAreaCodeMelsecS; break;
            case 'B': _area = kAreaCodeMelsecB; break;
            case 'D': _area = kAreaCodeMelsecD; break;
            case 'W': _area = kAreaCodeMelsecW; break;
                
            case 'T':
                if ( c < end ) switch ( toupper( *c ) )
                {
                    case 'S': _area = kAreaCodeMelsecTS; c++; break;
                    case 'C': _area = kAreaCodeMelsecTC; c++; break;
                    case 'N': _area = kAreaCodeMelsecTN; c++; break;
                    default : --c; break;
                }
                break;
                    
            case 'S':
                if ( c < end ) switch ( toupper( *c ) )
                {
                    case 'S': _area = kAreaCodeMelsecSS; c++; break;
                    case 'C': _area = kAreaCodeMelsecSC; c++; break;
                    case 'N': _area = kAreaCodeMelsecSN; c++; break;
                    default : _area = kAreaCodeMelsecS; break;
                }
                break;
                    
            case 'C':
                if ( c < end ) switch ( toupper( *c ) )
                {
                    case 'S': _area = kAreaCodeMelsecCS; c++; break;
                    case 'C': _area = kAreaCodeMelsecCC; c++; break;
                    case 'N': _area = kAreaCodeMelsecCN; c++; break;
                    default : c--; break;
                }
                break;
                
            default : c--; _errNum = kPlcTagErrAreaNotSupported; break;
        }
    }

    // protocol ethernet/IP PCCC
    if ( theProtocol == kProtocolTypeEIP_PCCC ) 
    {
        switch ( toupper( *c++ ) )
        {
            case 'O': _area = kAreaCodeEIP_PCCCO; addr = 0; break;
            case 'I': _area = kAreaCodeEIP_PCCCI; addr = 1; break;
            case 'S':
            { 
                if ( c < end && toupper( *c ) == 'T' ) 
                {
                    c++; 
                    _area = kAreaCodeEIP_PCCCST;
                    if ( varType.sto & kStorageStruct ) varType = kPCCCStringVarType;   // ATENCIO
                    break; 
                }
                _area = kAreaCodeEIP_PCCCS; addr = 2;
                break;
            }
            case 'B': _area = kAreaCodeEIP_PCCCB; addr = 3; break;
            case 'T': _area = kAreaCodeEIP_PCCCT; addr = 4; break;
            case 'C': _area = kAreaCodeEIP_PCCCC; addr = 5; break;
            //case 'R': plcTag->areaCode = kEIP_PCCCRAccess; addr = 6; break;
            case 'N': _area = kAreaCodeEIP_PCCCN; addr = 7; break;
            case 'F': _area = kAreaCodeEIP_PCCCF; addr = 8; break;
            //case 'L': plcTag->areaCode = kEIP_PCCCLAccess; break;
            //...
            
            
            case 'D' :
                if ( c < end && toupper( *c ) == 'L' )
                {
                    c++;
                    if ( c < end && toupper( *c ) == 'G' )
                    {
                        c++;
                        _area = kAreaCodeEIP_PCCCDLS; addr = 0;
                    }
                    else { c-=2; _errNum = kPlcTagErrAreaNotSupported; }
                }
                else { c--; _errNum = kPlcTagErrAreaNotSupported; }
                
                break;
            
            default : c--; _errNum = kPlcTagErrAreaNotSupported; break;
        }
    }
    
    if ( _errNum != kPlcTagErrNone )
    {
        return NO;
    }
    
    // addressa
    BOOL got_addr = NO;
    UInt16 element = 0;
    UInt8 bbit = 0;
    UInt32 btOffset = 0;
    UInt32 subRawSize = 0;
    if ( c < end && *c >= '0' && *c <= '9' )
    {
        addr = (*c++ - '0');
        while ( c < end && *c >= '0' && *c <= '9' ) addr = addr*10 + (*c++ - '0');
        if ( finsCounter ) addr += 0x8000;
        got_addr = YES;
    }
    else if ( theProtocol == kProtocolTypeEIP_PCCC )
    {
        got_addr = YES;
    }
    
    if ( got_addr == NO )
    {
        _errNum = kPlcTagErrAreaNotSupported;     // canviar
        return NO;
    }
    
    // opcions post addressa
    if ( theProtocol == kProtocolTypeEIP_PCCC )
    {
        if ( c < end && *c == ':' ) 
        {
            c++; 
            while ( c < end && *c >= '0' && *c <= '9' ) element = element*10 + (*c++ - '0');
        }
    }
        
    BOOL tim_count = (_area.areaCode == kEIP_PCCCTAccess || _area.areaCode == kEIP_PCCCCAccess);
    if ( tim_count )
    {
        subRawSize = 16;
        btOffset = 32;
        if ( c < end && (*c == '.') )
        {
            c++;
            if ( _parseCString( "pre", 3 ) ) btOffset = 16; // byteBit = 16;
            else if ( _parseCString( "acc", 3 ) ) btOffset = 32; //byteBit = 32;
        }
        else if ( c < end && (*c == '/') )
        {
            c++;
            subRawSize = 1;
            btOffset = 0; 
            bbit = 15;  // en per defecte
            if ( _parseCString( "en", 2 ) || _parseCString( "cu", 2 ) ) bbit = 15;
            else if ( _parseCString( "tt", 2 ) || _parseCString( "cd", 2 ) ) bbit = 14;
            else if ( _parseCString( "dn", 2 ) ) bbit = 13;
            else if ( _parseCString( "ov", 2 ) ) bbit = 12;
            else if ( _parseCString( "un", 2 ) ) bbit = 11;
            else if ( _parseCString( "ua", 2 ) ) bbit = 10;
        }
    }
    
    
    else if ( melsecBitDevice(_area.areaCode) )
    {
        subRawSize = 1;
        bbit = addr % _area.rawSize;
        addr = addr / _area.rawSize;
    }
        
    else if ( c < end && (*c == '.' || *c == '/') )
    {
        c++; 
        subRawSize = 1;
        while ( c < end && *c >= '0' && *c <= '9' ) bbit = bbit*10 + (*c++ - '0');            
    }

    if ( theProtocol == kProtocolTypeEIP_PCCC )
    {
        _leadingCode = addr;
        addr = element;
    }
    else if ( theProtocol == kProtocolTypeModbus )
    {
        _leadingCode = 1;  // per defecte slaveid es 1
        if ( addr > 0 ) addr--;  // ajustem la adressa de modbus
    }

    _addr = addr;
    _bit = bbit;
    _area.subRawSize = subRawSize;
    _btOffset = btOffset;
    return YES;
}


//-------------------------------------------------------------------------------------------
// parseja un label EIP natiu
- (BOOL)_parseNativeEIPSymLabel
{
    eipTagLen = 0;
    if ( [self _parsePlcSymLabelEx] )
    {
        //plcTag->areaCode = kEIPAccess;
        if ( eipTagLen > 0 )
        {
            _eipTagData = [NSData dataWithBytes:eipTag length:eipTagLen];
        }
        
//        // aumim que es un bool array si tenim index en el tipus
//        if ( boolVarType(varType) )
//        {
//            if ( eipIndexAcc )   // index en el tag: eip bool array
//            {
//                _area = kAreaCodeEIPBoolArray; // el subRawSize sera 1
//                _bit = _addr%32;
//                _addr = _addr/32;
//            }
//            else  // no index en el tag: byte bool
//            {
//                _area = kAreaCodeEIPByteBool;
//            }
//        }
//        else
        {
            _area.rawSize = varType.siz;
        }
        return YES;
    }
    return NO;
}

//-------------------------------------------------------------------------------------------
#define	HI(x)	(((x)>>8) & 0xff)
#define	LO(x)	((x) & 0xff)

//-------------------------------------------------------------------------------------------
#define _appendEipTokenBytes( begin, len )                  \
{                                                           \
    if ( eipTagLen >= 0 && eipTagLen+(len)+4 < 256)         \
    {                                                       \
        eipTag[eipTagLen++] = 0x91;                         \
        eipTag[eipTagLen++] = LO(len);                      \
        char *_beg=(char*)(begin);                          \
        char *_end=_beg+(len);                              \
        while ( _beg < _end ) eipTag[eipTagLen++]= /*tolower*/(*_beg++);     \
        if ( (len) % 2 ) eipTag[eipTagLen++] = 0x00;        \
    }                                                       \
}

//-------------------------------------------------------------------------------------------
#define _appendEipIndexValue(value)                         \
{                                                           \
    if ( eipTagLen >= 0 && eipTagLen+4 < 256)               \
    {                                                       \
        if ( value < 256 )                                  \
        {                                                   \
            eipTag[eipTagLen++] = 0x28;                     \
            eipTag[eipTagLen++] = LO(value);                \
        }                                                   \
        else                                                \
        {                                                   \
            eipTag[eipTagLen++] = 0x29;                     \
            eipTag[eipTagLen++] = 0x00;                     \
            eipTag[eipTagLen++] = LO(value);                \
            eipTag[eipTagLen++] = HI(value);                \
        }                                                   \
    }                                                       \
}


//-------------------------------------------------------------------------------------------
#define _appendEipIndexCentinel                             \
{                                                           \
    if ( eipTagLen >= 0 && eipTagLen+1 < 256)               \
    {                                                       \
        eipTag[eipTagLen++] = '\t' ;                        \
    }                                                       \
}


//-------------------------------------------------------------------------------------------
// parseja el label
- (BOOL)_parsePlcSymLabelEx
{
    const unsigned char *cbegin;
    size_t len;
    BOOL hasIndx = NO;
    _addr = 0;
    _bit = 0;
    eipIndexAcc = NO;
    if ( [self parseTokenWColon:&cbegin length:&len] )
    { 
        _appendEipTokenBytes( cbegin, len );
        //_skipSp;
        unsigned int value = 0;
        if ( _parseChar( '[' ) )
        {
            //_skipSp;
            if ( [self parseUInt:&value] )
            {
                while ( 1 )
                {
                    //_skipSp
                    if ( _parseChar( ',' ) )
                    {
                        _appendEipIndexValue( value );
                        //_skipSp;
                        if ( [self parseUInt:&value] ) continue;
                        else return NO;
                    }
                    break;
                }
                //_skipSp;
                if ( _parseChar( ']' ) )
                {
                    hasIndx = YES;
                    eipIndexAcc = YES;
                    _addr = value;
               //     eipBit |= (bitAddrByteAccessMask);  // de moment determinem que es vector, si resulta no ser de bools ja ho treurem a normalize
                }
                else return NO;
            }
            else return NO;
        }
        
        //_skipSp;
        if ( _parseChar( '.' ) )
        {
            //_skipSp;
            if ( [self parseUInt:&value] ) 
            {
                //eipBit |= (bitAddrAccessMask | (value%32));
                //plcTag->areaFlags.bitAccess = YES;
                _area.subRawSize = 1;
                _bit = value%32;
            }
            else 
            {
                if ( hasIndx ) _appendEipIndexValue( value );
                return [self _parsePlcSymLabelEx];
            }
        }

        //if ( hasIndx ) _appendEipIndexCentinel;
        if ( hasIndx ) _hasIndex = YES;
        return YES;
    }
    return NO;
}

//-------------------------------------------------------------------------------------------
// parseja un label EIP natiu
- (BOOL)_parseNativeOptoForthSymLabel
{
    eipTagLen = 0 ;
    if ( [self _parseNativeOptoForthSymLabelEx] )
    {
        if ( eipTagLen > 0 )
        {
            _eipTagData = [NSData dataWithBytes:eipTag length:eipTagLen];
        }
        return YES ;
    }
    return NO ;

}

//-------------------------------------------------------------------------------------------
#define _appendOptoForthTokenBytes( begin, len )            \
{                                                           \
    if ( eipTagLen >= 0 && eipTagLen < 256)                 \
    {                                                       \
        char *_beg=(char*)(begin) ;                         \
        char *_end=_beg+(len);                              \
        while ( _beg < _end ) eipTag[eipTagLen++]= *_beg++ /*tolower(*_beg++)*/ ;     \
    }                                                       \
}

//-------------------------------------------------------------------------------------------
// parseja el label
- (BOOL)_parseNativeOptoForthSymLabelEx
{
    const unsigned char *cbegin ;
    size_t len ;
    BOOL hasIndx = NO ;
    _addr = 0 ;
    _bit = 0 ;
    eipIndexAcc = NO ;
    if ( [self parseToken:&cbegin length:&len] )
    { 
        _appendOptoForthTokenBytes( cbegin, len ) ;
        //_skipSp ;
        unsigned int value = 0 ;
        if ( _parseChar( '[' ) )
        {
            //_skipSp ;
            if ( [self parseUInt:&value] )
            {
                //_skipSp ;
                if ( _parseChar( ']' ) )
                {
                    hasIndx = YES ;
                    eipIndexAcc = YES ;
                    _addr = value ;
                    if ( _area.areaCode == kOPTOSAccess ) _area = kAreaCodeOPTOStringTable;
                    else if ( _area.areaCode == kOPTOAccess) _area = kAreaCodeOPTOTable;
                }
                else return NO ;
            }
            else return NO ;
        }
        
        //_skipSp ;
        if ( _parseChar( '.' ) )
        {
            //_skipSp ;
            
            if ( [self parseToken:&cbegin length:&len] )
            {
                const int Offs_Enable = 4;
                const int Offs_StateLatchIval = 5;
                const int Offs_Feature1Ival = 7;
                const int Offs_Feature2Ival = 15;
                const int Offs_Feature3Ival = 23;
                _area = kAreaCodeOPTOPoint;
                if ( len==7 && 0==memcmp( cbegin, "enabled", len ) )
                {
                    _area.subRawSize = 8;
                    _btOffset = 8*Offs_Enable;
                }
//                else if ( len==7 && 0==memcmp( cbegin, "enabled", len ) )
//                {
//                    plcTag->area.subRawSize = 1;
//                    plcTag->btOffset = 8*Offs_Enable + 1;
//                }

                else if ( len==8 && 0==memcmp( cbegin, "on_latch", len ) )
                {
                    _area.subRawSize = 1;
                    _btOffset = 8*Offs_StateLatchIval + 0;
                }
                else if ( len==9 && 0==memcmp( cbegin, "off_latch", len ) )
                {
                    _area.subRawSize = 1;
                    _btOffset = 8*Offs_StateLatchIval + 1;
                }
                else if ( len==5 && 0==memcmp( cbegin, "state", len ) )
                {
                    _area.subRawSize = 1;
                    _btOffset = 8*Offs_StateLatchIval + 2;
                }
                else if ( (len==5 && 0==memcmp( cbegin, "value", len )) ||
                          (len==7 && 0==memcmp( cbegin, "counter", len )) )
                {
                    _area.subRawSize = 32;
                    _btOffset = 8*Offs_Feature1Ival;
                }
                else if ( len==3 && 0==memcmp( cbegin, "min", len ) )
                {
                    _area.subRawSize = 32;
                    _btOffset = 8*Offs_Feature2Ival;
                }
                else if ( len==3 && 0==memcmp( cbegin, "max", len ) )
                {
                    _area.subRawSize = 32;
                    _btOffset = 8*Offs_Feature3Ival;
                }
                else if ( len==12 && 0==memcmp( cbegin, "chart_status", len) )
                {
                    _area = kAreaCodeOPTOChartStatus;
                }
                else if ( len==11 && 0==memcmp( cbegin, "start_chart", len) )
                {
                    _area = kAreaCodeOPTOChartStart;
                }
                else if ( len==10 && 0==memcmp( cbegin, "stop_chart", len) )
                {
                    _area = kAreaCodeOPTOChartStop;
                }
                else if ( len==11 && 0==memcmp( cbegin, "start_timer", len) )
                {
                    _area = kAreaCodeOPTOTimerStart;
                }
                else if ( len==10 && 0==memcmp( cbegin, "stop_timer", len) )
                {
                    _area = kAreaCodeOPTOTimerStop;
                }
                else if ( len==11 && 0==memcmp( cbegin, "pause_timer", len) )
                {
                    _area = kAreaCodeOPTOTimerPause;
                }
                else if ( len==14 && 0==memcmp( cbegin, "continue_timer", len) )
                {
                    _area = kAreaCodeOPTOTimerContinue;
                }                
                else
                {
                    c -= len ;
                    return NO;
                }
            }
            
            
            else if ( [self parseUInt:&value] )
            {
                _area.subRawSize = 1 ;
                _bit = value%32 ;
            }
            else return NO;
        }

        //if ( hasIndx ) _appendEipIndexCentinel;
        if ( hasIndx ) _hasIndex = YES;
        return YES ;
    }
    return NO ;
}

@end

