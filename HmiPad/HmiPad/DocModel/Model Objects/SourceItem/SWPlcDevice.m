//
//  SWPlcDevice.m
//  HmiPad
//
//  Created by Joan on 22/08/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWPlcDevice.h"
#import "SWSourceItem.h"
#import "Pair.h"

@implementation SWPlcDevice
{
    //NSUndoManager *_undoManager;
}

//@synthesize sourceItem = _sourceItem;

const static Pair encodingPairs[]  = 
{
    { @"UTF-8", kCFStringEncodingUTF8 },
    { @"MacRoman", kCFStringEncodingMacRoman },
    { @"WindowsLatin1", kCFStringEncodingWindowsLatin1 },
    { @"Cyrillic/Mac", kCFStringEncodingMacCyrillic },
    { @"Cyrillic/Win", kCFStringEncodingWindowsCyrillic },
    { @"Cyrillic/ISO", kCFStringEncodingISOLatinCyrillic },
    { @"Japanese/Mac", kCFStringEncodingMacJapanese },
    { @"Japanese/Win", kCFStringEncodingDOSJapanese },
    { @"Japanese/JIS", kCFStringEncodingShiftJIS_X0213 },
    { @"Chinese/Mac", kCFStringEncodingMacChineseSimp },
    { @"Chinese/Win", kCFStringEncodingDOSChineseSimplif },
    { @"Chinese/GB2312", kCFStringEncodingGB_2312_80 },
};
const int encodingPairsCount = sizeof(encodingPairs)/sizeof(Pair);

const static Pair protocolPairs[]  = 
{
    { @"eip/native", kProtocolTypeEIP },
    { @"eip/pccc", kProtocolTypeEIP_PCCC },
    { @"modbus/tcp", kProtocolTypeModbus },
    { @"modbus/rtu", kProtocolTypeModbus+1 },
    { @"fins/tcp", kProtocolTypeOmronFins },
    { @"siemens/iso_tcp", kProtocolTypeSiemensISO_TCP },
    { @"opto22/native", kProtocolTypeOptoForth },
    { @"melsec/1E", kProtocolTypeMelsec },
};
const int protocolPairsCount = sizeof(protocolPairs)/sizeof(Pair);


static NSArray *arrayFromPairs( Pair pairs[], int count )
{
    NSString *cArray[count];
    for ( int i=0; i<count; i++ ) cArray[i] = (__bridge NSString*)pairs[i].ptr;
    NSArray *array = [[NSArray alloc] initWithObjects:cArray count:count];
    return array;
}

@dynamic protocolAsString;
@dynamic encodingAsString;


#pragma mark - Class methods

+ (NSArray*)stringEncodingsArray
{
    return arrayFromPairs( encodingPairs, encodingPairsCount );
}

//+ (UInt32)protocolTypeForString:(NSString*)text
//{
//    return PairNumberForString( protocolPairs, protocolPairsCount, text );
//}

+ (NSArray*)protocolTypesArray
{
    return arrayFromPairs( protocolPairs, protocolPairsCount );
}

+ (BOOL)isValidValidationTagString:(NSString *)text forProtocol:(UInt16)protocol outErrorString:(NSString**)errorString
{
    BOOL valid = ( _validationTagIdFromString_protocol(text, protocol) >= 0 );
    if ( !valid )
    {
        if ( errorString ) *errorString = NSLocalizedStringFromTable(@"kPlcTagErrWrongValidationTag", @"PlcObject", nil);
        return NO;
    }
    return valid;
}


#pragma mark - Public properties & methods

- (NSString*)encodingAsString
{
    return PairStringForNumber( encodingPairs, encodingPairsCount, stringEncoding );
}


- (void)setEncodingAsString:(NSString*)text
{
    stringEncoding = PairNumberForString( encodingPairs, encodingPairsCount, text );
}


- (NSString*)protocolAsString
{
    UInt32 protocol = plcProtocol;
    if ( protocol == kProtocolTypeModbus && (options & kPlcModbusRtuFlag) ) protocol += 1;
    return PairStringForNumber( protocolPairs, protocolPairsCount, protocol );
}


- (void)setProtocolAsString:(NSString*)text
{
    UInt32 protocol = PairNumberForString( protocolPairs, protocolPairsCount, text );
    
    if (protocol == kProtocolTypeModbus)
        options &= ~kPlcModbusRtuFlag;  // flag a 0
    
    if (protocol == kProtocolTypeModbus+1)
        protocol -= 1, options |= kPlcModbusRtuFlag;  // flag a 1
    
    plcProtocol = protocol;
    
    [self normalize];
}


- (NSString*)validationTagAsString
{
    return [self _stringFromValidationTagId];
}


- (void)setValidationTagAsString:(NSString *)text
{
    int vaId = _validationTagIdFromString_protocol(text,plcProtocol);
    if ( vaId < 0 ) vaId = 0;
    else validationTagId = vaId;
}

- (void)_getHost:(NSString**)host andPort:(UInt16*)port fromString:(NSString*)string
{
    NSArray *split = [string componentsSeparatedByString:@":"];
    NSInteger count = split.count;
    
    if ( count >= 1 ) *host = split[0];
    else *host = @"";
    
    if ( count == 2 ) *port = [split[1] integerValue];
    else *port = [self defaultPort];
}


- (NSString*)localHostExtAsString
{
    NSString * str = [NSString stringWithFormat:@"%@:%d", localHost, localPort];
    return str;
}


- (void)setLocalHostExtAsString:(NSString *)localHostExtAsString
{
    NSString *host;
    UInt16 port;
    
    [self _getHost:&host andPort:&port fromString:localHostExtAsString];

    [self setLocalHost:host];
    localPort = port;
}


- (NSString*)remoteHostExtAsString
{
    NSString *str = [NSString stringWithFormat:@"%@:%d", remoteHost, remotePort];
    return str;
}


- (void)setRemoteHostExtAsString:(NSString *)remoteHostExtAsString
{
    NSString *host;
    UInt16 port;
    
    [self _getHost:&host andPort:&port fromString:remoteHostExtAsString];

    [self setRemoteHost:host];
    remotePort = port;
}


#pragma mark - Private

static int _validationTagIdFromString_protocol(NSString* text, UInt32 plcProtocol)
{
    if ( text.length == 0 )
        return 0;

    char cstr[21];
    BOOL done = [text getCString:cstr maxLength:sizeof(cstr) encoding:NSASCIIStringEncoding];
    
    if ( !done )
        return -1;

    int vaId = -1 ;
    UInt16 protocol = plcProtocol & kProtocolTypeProtocolMask;
    
    char *ptr = (char*)cstr ;
    
    if ( protocol == kProtocolTypeEIP)
    {
        if ( !strcasecmp(cstr,"smvalidationtag"))   // case insensitive
            return 0;
    }
    
    else if ( protocol == kProtocolTypeOptoForth)
    {
        if ( !strcmp(cstr,"SMValidationTag"))   // case sensitive
            return 0;
    }
    
    else if ( protocol == kProtocolTypeModbus )
    {
        return 0;
    }
    
    else if ( protocol == kProtocolTypeEIP_PCCC )
    {
        if ( *ptr == 'n' || *ptr == 'N' )
        {
            ptr++ ;
            char *endptr ;
            long unsigned int result = strtoul( ptr, &endptr, 10 ) ;
            if ( result ) vaId = result<<8 ;
            else vaId = 7<<8 ;
            
            ptr = endptr ;
            if ( *ptr == ':' )
            {
                ptr++ ;
                result = strtoul( ptr, &endptr, 10 ) ;
                vaId = vaId | (result&0xff) ;
            }
        }
    }
    
    else if ( protocol == kProtocolTypeOmronFins )
    {
        if ( *ptr == 'd' || *ptr == 'D' )
        {
            ptr++ ;
            char *endptr ;
            long unsigned int result = strtoul( ptr, &endptr, 10 ) ;
            if ( result ) vaId = result ;
            else vaId = 19998 ;
        }
    }
    
    else if ( protocol == kProtocolTypeSiemensISO_TCP )
    {
        if ( (*ptr == 'm' || *ptr == 'M') /*&& len>2*/ && (*(ptr+1) == 'w' || *(ptr+1) == 'W'))
        {
            ptr+=2 ;
            char *endptr ;
            long unsigned int result = strtoul( ptr, &endptr, 10 ) ;
            if ( result ) vaId = result ;
            else vaId = 998 ;
        }
    }
    
    return vaId;
}

- (NSString*)_stringFromValidationTagId
{
    NSString *result = nil;
    UInt16 protocol = plcProtocol & kProtocolTypeProtocolMask;
    UInt16 vaId = validationTagId;
    if ( validationTagId == 0 ) vaId = [self defaultValidationTagId];
    switch ( protocol )
    {
        case kProtocolTypeOmronFins :
            result = [NSString stringWithFormat:@"D%d", vaId];
            break ;
            
        default :
        case kProtocolTypeModbus :
            result = [NSString stringWithFormat:@"-"];
            break ;
                
        case kProtocolTypeEIP :
            result = [NSString stringWithFormat:@"smvalidationtag"];
            break ;
            
        case kProtocolTypeOptoForth:
            result = [NSString stringWithFormat:@"SMValidationTag"]; // case insensitive protocol
            break ;
            
        case kProtocolTypeEIP_PCCC:
            result = [NSString stringWithFormat:@"N%d:%d", (vaId>>8)&0xff, vaId&0xff];
            break ;
            
        case kProtocolTypeSiemensISO_TCP:
            result = [NSString stringWithFormat:@"MW%d", vaId];
            break ;
            
        case kProtocolTypeMelsec :
            result = [NSString stringWithFormat:@"D%d", vaId];
            break;
    }
    
    return result;
}


// Posa els atributs per defecte
- (void)normalize
{

#if SMMOD
    // per la versio nomes modbus, qualsevol altre protocol no esta suportat
    if (plcProtocol != kProtocolTypeModbus)
    {
        _plcDevice->plcProtocol = kProtocolTypeNone;
    }
#endif

    // actualitzem el encoding
    //plcDevice->stringEncoding = stringEncoding;
    
    // actualitzem el poll rate
    if ( pollRate == 0xffff ) pollRate = 2000;
    
    // en aquesta aplicacio no suportem isDefault
    isDefault = NO;  
    
    // considerem que volem passar per el Notification Provider si al menys la ip o host s'han especificat
    if ( tpLocalHost != nil || tpRemoteHost != nil )
    {
    	plcProtocol |= kProtocolTypeTagProvider;
        
	    // si no hi ha res en les adresses de host hi posem la string vuida (per fer donar l'error de PLC address not provided al omronfinsobject)
        if ( tpRemoteHost == nil ) tpRemoteHost = @"";
    	if ( tpLocalHost == nil ) tpLocalHost = @"";
        
    	// si algun port del Notification Provider es zero posa l'altre
    	if ( tpLocalPort == 0 ) tpLocalPort = tpRemotePort;
    	if ( tpRemotePort == 0 ) tpRemotePort = tpLocalPort;    
        
        // si encara n'hi ha algun que es zero posem el de defecte segons protocol
    	if ( tpLocalPort == 0 )
    	{
        	UInt16 port = [self efDefaultPort];
        	tpLocalPort = port;
        	tpRemotePort = port;
   		 }
    }
    
    // si algun port es zero posa l'altre
    if ( localPort == 0 ) localPort = remotePort;
    if ( remotePort == 0 ) remotePort = localPort;
    
    // si encara n'hi ha algun que es zero posem el de defecte segons protocol
    if ( localPort == 0 )
    {
        UInt16 port = [self defaultPort];
        localPort = port;
        remotePort = port;
    }
    
    // si no hi ha res en les adresses de host hi posem la string vuida (per fer donar l'error de PLC address not provided al omronfinsobject)
    if (remoteHost == nil) remoteHost = @"";
    if (localHost == nil) localHost = @"";
}

#pragma mark - QuickCoding

//- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
//{
//    self = [super initWithQuickCoder:decoder];
//    if (self)
//    {
//        _sourceItem = [decoder decodeObject];
//    }
//    return self;
//}
//
//- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
//{
//    [super encodeWithQuickCoder:encoder];
//    [encoder encodeObject:_sourceItem];
//}


#pragma mark - QuickCoding

#pragma mark - SymbolicCoding

- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(SWSourceItem*)parent
{
    self = [super init];
    if (self) 
    {
        [self setProtocolAsString:[decoder decodeStringForKey:@"protocol"]];

        localPort = [decoder decodeIntForKey:@"local_port"];
        remotePort = [decoder decodeIntForKey:@"remote_port"];
        localHost = [decoder decodeStringForKey:@"local_host"];
        remoteHost = [decoder decodeStringForKey:@"remote_host"];

        pollRate = [decoder decodeIntForKey:@"poll_rate"];
        validationTagId = [decoder decodeIntForKey:@"validation_tag_id"];
        options = [decoder decodeIntForKey:@"options"];
        [self setEncodingAsString:[decoder decodeStringForKey:@"encoding"]];
        
//        _sourceItem = parent;
    }
    return self;
}

- (void)encodeWithSymbolicCoder:(SymbolicArchiver *)encoder 
{
    [encoder encodeString:[self protocolAsString] forKey:@"protocol"];
/*
    [encoder encodeInt:localPort forKey:@"local_port"];
    [encoder encodeInt:remotePort forKey:@"remote_port"];
    [encoder encodeString:localHost forKey:@"local_host"];
    [encoder encodeString:remoteHost forKey:@"remote_host"];
*/
    [encoder encodeInt:pollRate forKey:@"poll_rate"];
    [encoder encodeInt:validationTagId forKey:@"validation_tag_id"];
    [encoder encodeInt:options forKey:@"options"];
    [encoder encodeString:[self encodingAsString] forKey:@"encoding"];
}

#pragma mark - Prviate Methods


//- (NSUndoManager*)undoManager
//{
//    if (!_undoManager)
//        _undoManager = [(id)_sourceItem.docModel undoManager];
//    
//    return _undoManager;
//}
//
//- (void)notifyChanges
//{
//    [_sourceItem _plcDeviceChangeNotify];
//}

#pragma mark - Public Methods

//- (void)setLocalPort:(UInt16)value
//{
//    NSUndoManager *undoManager = [self undoManager];
//    [[undoManager prepareWithInvocationTarget:self] setLocalPort:localPort];
//    [undoManager setActionName:NSLocalizedString(@"Change Local Port", nil)];
//    
//    self->localPort = value;
//    
//    [self notifyChanges];
//}
//
//- (void)setRemotePort:(UInt16)value
//{
//    NSUndoManager *undoManager = [self undoManager];
//    [[undoManager prepareWithInvocationTarget:self] setRemotePort:remotePort];
//    [undoManager setActionName:NSLocalizedString(@"Change Remote Port", nil)];
//    
//    self->remotePort = value;
//    
//    [self notifyChanges];
//}

#pragma mark - Overriden methods

//- (void)setTPLocalHost:(NSString*)value
//{
//    NSUndoManager *undoManager = [self undoManager];
//    [[undoManager prepareWithInvocationTarget:self] setTPLocalHost:self.tpLocalHostStr];
//    [undoManager setActionName:NSLocalizedString(@"Change TP LocalHost", nil)];
//    
//    [super setTPLocalHost:value];
//    
//    [self notifyChanges];
//}
//
//- (void)setTPRemoteHost:(NSString*)value
//{
//    NSUndoManager *undoManager = [self undoManager];
//    [[undoManager prepareWithInvocationTarget:self] setTPRemoteHost:self.tpRemoteHostStr];
//    [undoManager setActionName:NSLocalizedString(@"Change TP Remote Host", nil)];
//    
//    [super setTPRemoteHost:value];
//    
//    [self notifyChanges];
//}
//
//- (void)setLocalHost:(NSString*)value
//{
//    NSUndoManager *undoManager = [self undoManager];
//    [[undoManager prepareWithInvocationTarget:self] setLocalHost:localHost];
//    [undoManager setActionName:NSLocalizedString(@"Change Local Host", nil)];
//    
//    [super setLocalHost:value];
//    
//    [self notifyChanges];
//}
//
//- (void)setRemoteHost:(NSString*)value
//{
//    NSUndoManager *undoManager = [self undoManager];
//    [[undoManager prepareWithInvocationTarget:self] setRemoteHost:remoteHost];
//    [undoManager setActionName:NSLocalizedString(@"Change Remote Host", nil)];
//    
//    [super setRemoteHost:value];
//    
//    [self notifyChanges];
//}
//
//- (void)setValidationTagId:(UInt16)vaId
//{
//    NSUndoManager *undoManager = [self undoManager];
//    [[undoManager prepareWithInvocationTarget:self] setValidationTagId:validationTagId];
//    [undoManager setActionName:NSLocalizedString(@"Change Validation Tag", nil)];
//    
//    [super setValidationTagId:vaId];
//    
//    [self notifyChanges];
//}
//
//- (void)setPollRate:(UInt16)value
//{
//    NSUndoManager *undoManager = [self undoManager];
//    [[undoManager prepareWithInvocationTarget:self] setPollRate:pollRate];
//    [undoManager setActionName:NSLocalizedString(@"Change Poll Rate", nil)];
//    
//    [super setPollRate:value];
//    
//    [self notifyChanges];
//}

@end

