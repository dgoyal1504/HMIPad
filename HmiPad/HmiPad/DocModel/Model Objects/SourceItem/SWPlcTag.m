//
//  SWPlcTag.m
//  HmiPad
//
//  Created by Joan on 22/08/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWPlcTag.h"
#import "SWTagAddressParser.h"
#import "SWTagTypeParser.h"
#import "SWSourceItem.h"
#import "SWSourceNode.h"

@implementation SWPlcTag

//struct VarTypePair
//{
//    void *string;
//    const VarType * const varType;
//};
//typedef const struct VarTypePair VarTypePair;
//
//const static VarTypePair varTypePairs[]  = 
//{
//    { @"BOOL", &kBoolVarType },
//    { @"CHAR", &kCharVarType },
//    { @"SINT", &kByteVarType },
//    { @"INT", &kShortIntVarType },
//    { @"DINT", &kLongIntVarType },
//    { @"REAL", &kFloatVarType },
//    { @"UINT", &kUnsignedShortIntVarType },
//    { @"UDINT", &kUnsignedLongIntVarType },
//    { @"UINT_BCD", &kShortBcdVarType },
//    { @"UDINT_BCD", &kLongBcdVarType },
//    { @"CHAR_STRING", &kCharStringVarType },
//    { @"STRING", NULL },
//};
//const int varTypePairsCount = sizeof(varTypePairs)/sizeof(VarTypePair);
//
//static NSString* stringForVarType( VarTypePair pairs[], int count, const VarType varType)
//{
//    if ( varType.stru == kStructTypeCharString ) return @"CHARSTRING";
//    if ( varType.stru != kStructTypeNone ) return @"STRING";
//    for ( int i=0; i<count; i++ )
//    {
//        if (    pairs[i].varType && 
//                pairs[i].varType->siz == varType.siz && 
//                pairs[i].varType->sto == (varType.sto&kStorageTypeMask) )
//        {
//            return (__bridge NSString*)pairs[i].string;
//        }
//    }
//    return @"";
//}
//
//static const VarType * const varTypeForString( VarTypePair pairs[], int count, NSString *string )
//{
//    for ( int i=0; i<count; i++ )
//        if ( [(__bridge NSString*)pairs[i].string isEqualToString:string]  ) return pairs[i].varType;
//    return NULL;
//}
//
//static NSArray *arrayFromVarTypePairs( VarTypePair pairs[], int count )
//{
//    NSString *cArray[count];
//    for ( int i=0; i<count; i++ ) cArray[i] = (__bridge NSString*)pairs[i].string;
//    NSArray *array = [[NSArray alloc] initWithObjects:cArray count:count];
//    return array;
//}
//
//+ (NSArray*)tagTypesArray
//{
//    return arrayFromVarTypePairs( varTypePairs, varTypePairsCount );
//}


#pragma mark - SymbolicCoding

-(id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString*)ident parentObject:(SWSourceNode*)parent
{
    SWSourceItem *sourceItem = parent.sourceItem;
    ProtocolType plcProtocol = sourceItem.protocol;
    self = [self initAsDefaultForProtocol:plcProtocol];
    if (self) 
    {
        if ( plcProtocol == kProtocolTypeModbus )
            leadingCode = [decoder decodeIntForKey:@"slave_id"];

        [self setAddresAsString:[decoder decodeStringForKey:@"address"] typeString:[decoder decodeStringForKey:@"type"]];
        
        scale.rmin = [decoder decodeDoubleForKey:@"scale_rmin"];
        scale.rmax = [decoder decodeDoubleForKey:@"scale_rmax"];
        scale.emin = [decoder decodeDoubleForKey:@"scale_emin"];
        scale.emax = [decoder decodeDoubleForKey:@"scale_emax"];
    }
    return self;
}


-(void)encodeWithSymbolicCoder:(SymbolicArchiver *)encoder 
{
    [encoder encodeString:[self addressAsString] forKey:@"address"];
    [encoder encodeString:[self typeAsString] forKey:@"type"];
    
    ProtocolType plcProtocol = (area.areaCode&protocolTypeMask);

    if ( plcProtocol == kProtocolTypeModbus )
        [encoder encodeInt:leadingCode forKey:@"slave_id"];
    
    [encoder encodeDouble:scale.rmin forKey:@"scale_rmin"];
    [encoder encodeDouble:scale.rmax forKey:@"scale_rmax"];
    [encoder encodeDouble:scale.emin forKey:@"scale_emin"];
    [encoder encodeDouble:scale.emax forKey:@"scale_emax"];
}



#pragma mark - Methods

- (id)initAsDefaultForProtocol:(ProtocolType)protocol
{
    self = [super init];
    if ( self )
    {
        switch ( (int)protocol )
        {
            case kProtocolTypeOmronFins:
            
                // DM0
                area = kAreaCodeDM;
                varType = kShortIntVarType;
                
                       // varType = kFloatVarType;
                       // [self setAddr:4 withBit:0];        // DM4 per proves, a eliminar !!
                
                break;
                
            case kProtocolTypeModbus:
            
                // HR0
                area = kAreaCodeModbHR;
                leadingCode = 1;
                varType = kShortIntVarType;
                break;
                
            case kProtocolTypeEIP_PCCC:
            
                // N7:0
                area = kAreaCodeEIP_PCCCN;
                leadingCode = 7;  // file number
                varType = kShortIntVarType;
                break;
            
            case kProtocolTypeEIP :
            {
                // mytag
                char eipDefTag[] = "XXmytag";
                int len = strlen(eipDefTag);
                //int size = sizeof(eipDefTag);
                eipDefTag[0] = 0x91;
                eipDefTag[1] = (UInt8)(len-2);   // longitud de "myTag"
                NSData *data = [NSData dataWithBytes:eipDefTag length:len+1];    // inclueix el '\0'
                [self setEipTag:data];
                area = kAreaCodeEIP;
                area.rawSize = kBitSizeShort;
                varType = kShortIntVarType;
                break;
            }
            
            case kProtocolTypeSiemensISO_TCP:
            
                // MW0
                area = kAreaCodeS7Flags;
                varType = kShortIntVarType;
                break;
                
            case kProtocolTypeOptoForth:
            {
                // myTag
                char optoDefTag[] = "mytag" ;    // case insensitive protocol
                int len = strlen(optoDefTag);
                NSData *data = [NSData dataWithBytes:optoDefTag length:len+1];
                [self setEipTag:data];
                area = kAreaCodeOPTO;
                area.rawSize = kBitSizeLongInt;
                varType = kLongIntVarType;
                break;
            }
            
            case kProtocolTypeMelsec:
        
                // D0
                area = kAreaCodeMelsecD;
                varType = kShortIntVarType;
                break;
            
            default:
                return nil;
                break;
        }
    }
    return self;
}


- (NSString*)defaultFormatString
{
    switch ( varType.sto & kStorageTypeMask )
    {
        case kStorageFloat :
            return @"%g";
            break;
    
        case kStorageStruct :
            return nil;
            break;
            
        default :
            return @"%1.15g";
            //if ( scale.rmin == scale.emin && scale.rmax == scale.emax ) return @"%1.0f";
            //return @"%g";
    }
}


- (void)dealloc
{
   // NSLog( @"SWPlcTag dealloc");
}

#pragma mark type


//- (NSString*)tagTypeAsString
//{
//    return stringForVarType( varTypePairs, varTypePairsCount, varType );
//}
//
//
//// 1
//- (void)setTypeAsString:(NSString*)text structSize:(NSInteger)size
//{
//    VarType theType;
//    const VarType *type = varTypeForString( varTypePairs, varTypePairsCount, text );
//    
//    // el tipus string depen del protocol
//    
//    ProtocolType protocol = (area.areaCode&protocolTypeMask);
//    if ( type == NULL )
//    {
//        switch ( (int)protocol )
//        {            
//            case kProtocolTypeEIP :
//                theType = kEIPStringVarType;
//                break;
//            
//            case kProtocolTypeSiemensISO_TCP:
//                theType = kS7StringVarType;
//                break;
//                
//            case kProtocolTypeOptoForth:
//                theType = kOPTOStringVarType;
//                break;
//                
//            default:
//                theType = kPCCCStringVarType;
//                break;
//        }
//        //varType.stru = theType.stru;
//    }
//    else
//    {
//        theType = *type;
//    }
//    
//    varType.stru = theType.stru;
//    
//    // alguns tipus de strings tenen el compte el size
//    if ( size > 0 ) switch ( theType.stru )
//    {
//        default :
//            break;
//                
//        case kStructTypeCharString :
//            theType.siz = size*8;
//            break;
//            
//        case kStructTypeS7String :
//            theType.siz = (2+size)*8;
//            break;
//    }
//    
//
//    if ( protocol == kProtocolTypeEIP )
//    {
//        if ( boolVarType(theType) )
//        {
//            if ( !boolVarType(varType) )
//            {
//                // TO DO
//            }
//        }
//        else
//        {
//          area.rawSize = theType.siz;
//        }
//    }
//        
//    // si el varType era de domain array i ha canviat la mida de l'element hem de refer-lo
//    if ( ((varType.sto&kDomainMask) == kDomainTypeArray && varType.siz != theType.siz) ||
//         ((theType.sto&kDomainMask) == kDomainTypeArray) )
//    {
//        int count = [self collectionCount];
//        if ( count == 1 ) count = 0;  // volem forcar no array si es possible.
//        [self prepareCollectionForVarType:theType domain:kDomainTypeArray ofLength:count];
//    }
//    else
//    {
//        varType.siz = theType.siz;
//        varType.sto = (varType.sto & kDomainMask) | (theType.sto & kStorageTypeMask);
//        //if ( protocol == kProtocolTypeEIP ) area.rawSize = varType.siz;
//    }
//    
//}


- (NSString *)typeAsString
{
    NSString *typeString = [self typeString];
    return typeString;
}


//// 3
//- (void)setTypeAsString:(NSString *)typeString
//{
//    ProtocolType protocol = (area.areaCode&protocolTypeMask);
//    SWTagTypeParser *typeParser = [[SWTagTypeParser alloc] initWithString:typeString protocol:protocol];
//    [typeParser parse];
//    
//    varType = typeParser.varType;
//    
//    
//        
//    //UInt16 err = [addrParser errNum];
//    
//    // TO DO normalize
//
//    return;
//}


+ (BOOL)isValidType:(NSString*)text forProtocol:(ProtocolType)protocol outErrString:(NSString**)errorString
{
    SWTagTypeParser *typeParser = [[SWTagTypeParser alloc] initWithString:text protocol:protocol];
    if ( ![typeParser parse] )
    {
        //NSLog( @"TagAddressParser error %d", typeParser.errNum );
        if ( errorString ) *errorString = NSLocalizedStringFromTable(@"kPlcTagErrTypeNotSupported", @"PlcObject", nil);
                                                        // TO DO [self infoStringForErrNum:addrParser.errNum];
        return NO;
    }
    return YES;
}




#pragma mark size, address

//// 2
//- (void)setArraySize:(NSInteger)count
//{
//    //if ( count == 1 ) count = 0;  // volem forcar no array si es possible.
//    
//    ProtocolType protocol = (area.areaCode&protocolTypeMask);
//    if ( protocol == kProtocolTypeEIP )
//    {
//        if ( boolVarType(varType) )
//        {
//            if ( count > 0 )  // index en el tipus
//            {
//                area = kAreaCodeEIPBoolArray;
//                area.subRawSize = kBitSizeUnknown;   // el subRawSize no pot ser 1 en arrays
//                
//                if ( count%32 == 0 )
//                {
//                    btAddr = (btAddr/32)*32;
//                    //count = count/32;
//                }
//                else errNum = kPlcTagErrInvalidArrayAccess;
//            }
//            
//            else if ( hasIndex )   // index en el tag
//            {
//                area = kAreaCodeEIPBoolArray ; // el subRawSize sera 1
//            }
//            
//            else
//            {
//                area = kAreaCodeEIPByteBool;
//            }
//        }
//        else
//        {
//            area.rawSize = varType.siz;
//        }
//    }
//    
//    else if ( protocol == kProtocolTypeOptoForth )
//    {
//        if ( area.areaCode == kOPTOSAccess ) area = kAreaCodeOPTOStringTable;
//        else if ( area.areaCode == kOPTOAccess ) area = kAreaCodeOPTOTable;
//    }
//    
//    if ( count > 0 && area.subRawSize == 1 )
//    {
//        errNum = kPlcTagErrInvalidArrayAccess;
//        count = 0;
//    }
//    
//    UInt16 domain = (varType.sto & kDomainMask);
//    if ( domain == kDomainTypeScalar)
//        domain = kDomainTypeArray;
//    
//    [self prepareCollectionForVarType:varType domain:domain ofLength:count];
//}
//
//
//




- (void)setAddresAsString:(NSString*)addrString typeString:(NSString*)typeString
{
    if ( typeString == nil && addrString == nil )
        return;

    if (typeString == nil)
        typeString = [self typeAsString];
    
    if ( addrString == nil)
        addrString = [self addressAsString];
    
    // type
    ProtocolType plcProtocol = (area.areaCode&protocolTypeMask);
    SWTagTypeParser *typeParser = [[SWTagTypeParser alloc] initWithString:typeString protocol:plcProtocol];
    [typeParser parse];
    
    varType = typeParser.varType;
    BOOL hasArrCount = typeParser.hasArrCount;
    NSInteger arrayCount = typeParser.arrCount;
    
    // address
    SWTagAddressParser *addrParser = [[SWTagAddressParser alloc] initWithString:addrString protocol:plcProtocol varType:varType];
    [addrParser parse];
    
    area = addrParser.area;
    prOptions = addrParser.prOptions;

    if ( plcProtocol != kProtocolTypeModbus )
        leadingCode = addrParser.leadingCode;

    [self setAddr:addrParser.addr withBit:addrParser.bit];
    btOffset = addrParser.btOffset;

    [self setEipTag:addrParser.eipTagData];

    hasIndex = addrParser.hasIndex;
    
    [self _normalizeForProtocol:plcProtocol hasArrayCount:hasArrCount arrayCount:arrayCount];
}


// normalize

-(void)_normalizeForProtocol:(ProtocolType)plcProtocol hasArrayCount:(BOOL)hasArrCount arrayCount:(NSInteger)arrayCount
    /*hasIndex:(BOOL)eipIndexAcc*/ /*index:(NSInteger)eipIndex*/
{
//    if ( plcProtocol == kProtocolTypeModbus )
//    {
//        UInt16 adr = [self addr] ;
//        UInt16 bt = [self bit] ;
//        if ( adr > 0 ) adr-- ;
//        [self setAddr:adr withBit:bt] ;
//    }
    
    // ajusta la adressa de vectors i bits per EIP
    if ( plcProtocol == kProtocolTypeEIP )
    {
        UInt8 eipBit = [self bit];
        UInt32 eipIndex = [self addr];
        //if ( plcTag->varType == kBoolVarType )
        if ( boolVarType(varType) )
        {
            // asumim que es un boolArray tant si posem un index en el tag (boolArray[3]) com un nombre d'elements en el tipus (BOOL[3])
            if ( hasArrCount || hasIndex )
            {
                area = kAreaCodeEIPBoolArray ;  // el subRawSize sera 1 si el index esta en el tag
                eipBit = eipIndex%32 ;
                eipIndex = eipIndex/32 ;
                
                if ( hasArrCount )  // index en el tipus
                {
                    area.subRawSize = kBitSizeUnknown ;   // el subRawSize no pot ser 1 en arrays
                    if ( eipBit != 0 ) errNum = kPlcTagErrInvalidArrayAccess ;  // nomes suportem arrays alineats
                }
    
//                else if ( hasIndex )   // index en el tag
//                {
//                    area = kAreaCodeEIPBoolArray ; // el subRawSize sera 1
//                    eipBit = eipIndex%32 ;
//                    eipIndex = eipIndex/32 ;
//                }
            }
            else
            {
                area = kAreaCodeEIPByteBool ;
            }
        }
        
        else
        {
            area.rawSize = varType.siz ;
            if ( hasArrCount )  // si hi ha un index en el tipus assumim que es array
            {
                hasIndex = YES;
            }
        }
            
        [self setAddr:eipIndex withBit:eipBit] ;
    }
        
    
    if ( plcProtocol == kProtocolTypeOptoForth )
    {
        if ( hasArrCount )  // si hi ha un index en el tipus assumim que es array
        {
            if ( area.areaCode == kOPTOSAccess ) area = kAreaCodeOPTOStringTable;
            else if ( area.areaCode == kOPTOAccess) area = kAreaCodeOPTOTable;
            hasIndex = YES;
        }
    }
    
    UInt16 domain = (varType.sto & kDomainMask) ;
    
    
    // admetem arrays de bool amb subRawSize si tot esta alineat
    if ( area.subRawSize == 1 && hasArrCount && boolVarType(varType))
    {
        UInt8 bit = [self bit];
                
        if ( bit == 0 && arrayCount%area.rawSize == 0)  // el bit ha de ser alineat, i el numero d'elements tambe
            area.subRawSize = kBitSizeUnknown ;   // el subRawSize no pot ser 1 en arrays
        
        else
            errNum = kPlcTagErrInvalidArrayAccess ;  // nomes suportem arrays alineats
    }
    
    
    if ( hasArrCount ) // tipus que tenen arrayCount (especificacio [n] en el tipus) (necesiten un array)
                        // no fem comprovacio explicita que el numero d'element sigui alineat, s'ha de documentar que en cas de escritura
                        // es matxacaran els elements fins al rawSize
    {
        if ( area.subRawSize == 1 )
        {
            errNum = kPlcTagErrInvalidArrayAccess ;
        }
        else
        {
            if ( arrayCount == 0 )
            {
                errNum = kPlcTagErrZeroArrayLength ;
            }
            else
            {
                if ( charVarType(varType) )
                {
                    domain = kDomainTypeArray ;
                    varType = kCharStringVarType ;     // ho convertim en char string de la longitud especificada
                    varType.siz = arrayCount*8 ;       // la longitud en la estructura
                    arrayCount = 1 ;                   // array count sera ara 1  (una unica estructura)
                }
                
                else if ( domain == kDomainTypeCFArray )   // array de strings opto
                {
                    domain = kDomainTypeCFArray;
                    //[node setWriteAccess:10] ; // per ara no suportem que els arrays s'escriguin
                }
                    
                else // array escalar (no char) o de structs
                {
                    domain = kDomainTypeArray ;
                    //[node setWriteAccess:10] ; // per ara no suportem que els arrays s'escriguin
                }
                
                [self prepareCollectionForVarType:varType domain:domain ofLength:arrayCount] ;
            }
        }
    }
    else if ( domain == kDomainTypeArray || domain == kDomainTypeCFArray )  // tipus que necesiten array pero no tenen arrayCount (strings)
    {
        [self prepareCollectionForVarType:varType domain:domain ofLength:1] ;
    }
}


//- (NSInteger)arraySize
//{
//    NSInteger arraySize = [super collectionCount];
//    
//    UInt16 domain = (varType.sto & kDomainMask);
//    
//    if ( arraySize == 1 && (domain != kDomainTypeArray || (varType.sto & kStorageTypeMask) == kStorageStruct) )
//    {
//        arraySize = 0;
//    }
//    return arraySize;
//}


- (NSInteger)collectionCount
{
    return [super collectionCount];
}




//- (NSInteger)structTypeSize
//{
//    NSInteger size;
//    switch ( varType.stru )
//    {
//        default :
//            size = -1;
//            break;
//                
//        case kStructTypeCharString :
//            size = varType.siz/8;
//            break;
//            
//        case kStructTypeS7String :
//            size = varType.siz/8 - 2;
//            break;
//    }
//    return size;
//}





/*
- (NSString*)defaultFormatString
{
    switch ( varType.sto & kStorageTypeMask )
    {
        case kStorageStruct :
            return nil;
            break;
            
        default :
            return @"%1.15g";
    }
}
*/

#pragma mark address

- (NSString *)addressAsString
{
    NSString *addrStr = [self tagName]; 
    return addrStr;
}

//// 3
//- (void)setAddressAsString:(NSString*)addrStr
//{
//    ProtocolType protocol = (area.areaCode&protocolTypeMask);
//    SWTagAddressParser *addrParser = [[SWTagAddressParser alloc] initWithString:addrStr protocol:protocol varType:varType];
//    [addrParser parse];
//    
//    area = addrParser.area;
//    leadingCode = addrParser.leadingCode;
//    [self setAddr:addrParser.addr withBit:addrParser.bit];
//    btOffset = addrParser.btOffset;
//    [self setEipTag:addrParser.eipTagData];
//    hasIndex = addrParser.hasIndex;
//    
//    //UInt16 err = [addrParser errNum];
//    
//    // TO DO normalize
//
//    return;
//}
//

+ (BOOL)isValidAddress:(NSString*)addrString withType:(NSString*)typeString forProtocol:(ProtocolType)protocol outErrString:(NSString**)errorString
{
    VarType varType = kUnknownVarType;
    SWTagTypeParser *typeParser = [[SWTagTypeParser alloc] initWithString:typeString protocol:protocol];
    if ( [typeParser parse] )
        varType = typeParser.varType;

    SWTagAddressParser *addrParser = [[SWTagAddressParser alloc] initWithString:addrString protocol:protocol varType:varType];
    if ( ![addrParser parse] )
    {
        //NSLog( @"TagAddressParser error %d", addrParser.errNum );
        if ( errorString ) *errorString = NSLocalizedStringFromTable(@"kPlcTagErrAreaNotSupported", @"PlcObject", nil);
                                                        // TO DO [self infoStringForErrNum:addrParser.errNum];
        return NO;
    }
    return YES;
}


@end

