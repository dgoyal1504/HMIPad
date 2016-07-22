//
//  PlcModel.h
//  ScadaMobile_090816
//
//  Created by Joan on 22/08/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QuickCoder.h"
#import "PlcObjectCommonTypes.h"

@class PlcCommsObject ;

////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Constants i flags per la propietat area.areaCode
////////////////////////////////////////////////////////////////////////////////////////

//--------------------------------------------------------------------------------------   
// Omron/Fins Access Unit Mask.
//
enum FinsMemoryAccessUnit
{
    kFinsMemoryBitAccess = 0x00,    // 0000 0000
    kFinsMemoryWordAccess = 0x80    // 1000 0000
} ;

//--------------------------------------------------------------------------------------   
enum MemoryAreaCode
{
    // sense protocol conegut
    kUnknownAccess = kProtocolTypeNone,  // cap protocol (==0)
    
    // Omron Fins (els area codes en aquest cas coincideixen amb els que s'envien a la trama)
    // (La implementacio del protocol els ha de combinar amb el FinsMemoryAccessUnit per tenir l'area completa, 
    // excepte en el cas de kTCFlagAccess que te access per bytes)
    kCIOAccess0 = kProtocolTypeOmronFins | 0x00,    // legacy
    kTCAccess0 = kProtocolTypeOmronFins | 0x01,     // legacy    
    kTCAccess = kProtocolTypeOmronFins | 0x89,      // adresses a partir de 0x8000 son contadors, access al Present Value
    kTCFlagAccess = kProtocolTypeOmronFins | 0x09,  // adresses a partir de 0x8000 son contadors, access al Completion Flag
    kDMAccess = kProtocolTypeOmronFins | 0x02,
    kCIOAccess = kProtocolTypeOmronFins | 0x30,
    kWAccess = kProtocolTypeOmronFins | 0x31,
    kHRAccess = kProtocolTypeOmronFins | 0x32,
    kARAccess = kProtocolTypeOmronFins | 0x33,
    kEMCurrentAccess = kProtocolTypeOmronFins | 0x18,
    kEM0Access = kProtocolTypeOmronFins | 0x20,
    kEM1Access = kProtocolTypeOmronFins | 0x21,
    kEM2Access = kProtocolTypeOmronFins | 0x22,
    kEM3Access = kProtocolTypeOmronFins | 0x23,
    kNumberAccess = kProtocolTypeOmronFins | 0x7f,
    
    // Melsec
    kMelsecFlagBITFlag = 0x80,                                              // Arees amb adressa numerada per bits
    
    kMelsecXAccess = kProtocolTypeMelsec | 0x01 | kMelsecFlagBITFlag,       // Input (bit)
    kMelsecYAccess = kProtocolTypeMelsec | 0x02 | kMelsecFlagBITFlag,       // Output (bit)
    kMelsecMAccess = kProtocolTypeMelsec | 0x03 | kMelsecFlagBITFlag,       // Internal Relay  (bit)
    kMelsecLAccess = kProtocolTypeMelsec | 0x04 | kMelsecFlagBITFlag,       // Latch Relay  (bit)
    kMelsecFAccess = kProtocolTypeMelsec | 0x05 | kMelsecFlagBITFlag,       // Anuntiator (bit)
    kMelsecVAccess = kProtocolTypeMelsec | 0x06 | kMelsecFlagBITFlag,       // Edge Relay (bit)
    kMelsecSAccess = kProtocolTypeMelsec | 0x07 | kMelsecFlagBITFlag,       // Step Relay (bit)
    kMelsecBAccess = kProtocolTypeMelsec | 0x08 | kMelsecFlagBITFlag,       // Link Relay (bit)
    
    kMelsecDAccess = kProtocolTypeMelsec | 0x0A,                            // Data Register (word)
    kMelsecWAccess = kProtocolTypeMelsec | 0x0B,                            // Link Register (word)
    
    kMelsecTSAccess = kProtocolTypeMelsec | 0x0C | kMelsecFlagBITFlag,      // Timer Contact (bit)
    kMelsecTCAccess = kProtocolTypeMelsec | 0x0D | kMelsecFlagBITFlag,      // Timer Coil (bit)
    kMelsecTNAccess = kProtocolTypeMelsec | 0x0E,                           // Timer Current Value (word)
    
    kMelsecSSAccess = kProtocolTypeMelsec | 0x0F | kMelsecFlagBITFlag,      // Retentive Timer Contact (bit)
    kMelsecSCAccess = kProtocolTypeMelsec | 0x10 | kMelsecFlagBITFlag,      // Retentive Timer Coil (bit)
    kMelsecSNAccess = kProtocolTypeMelsec | 0x11,                           // Retentive Timer Current Value (word)
    
    kMelsecCSAccess = kProtocolTypeMelsec | 0x12 | kMelsecFlagBITFlag,      // Counter Contact (bit)
    kMelsecCCAccess = kProtocolTypeMelsec | 0x13 | kMelsecFlagBITFlag,      // Counter Timer Coil (bit)
    kMelsecCNAccess = kProtocolTypeMelsec | 0x14,                           // Counter Current Value (word)
    
    kMelsecRAccess  = kProtocolTypeMelsec | 0x15,                           // File Register (word)

    
//    kMelsecXAccess = kProtocolTypeMelsec | 0x9C,         // Input (bit)
//    kMelsecYAccess = kProtocolTypeMelsec | 0x9D,         // Output (bit)
//    kMelsecMAccess = kProtocolTypeMelsec | 0x90,         // Internal Relay  (bit)
//    kMelsecLAccess = kProtocolTypeMelsec | 0x92,         // Latch Relay  (bit)
//    kMelsecFAccess = kProtocolTypeMelsec | 0x93,         // Anuntiator (bit)
//    kMelsecVAccess = kProtocolTypeMelsec | 0x94,         // Edge Relay (bit)
//    kMelsecSAccess = kProtocolTypeMelsec | 0x98,         // Step Relay (bit)
//    kMelsecBAccess = kProtocolTypeMelsec | 0xA0,         // Link Relay (bit)
//    
//    kMelsecDAccess = kProtocolTypeMelsec | 0xA8,         // Data Register (word)
//    kMelsecWAccess = kProtocolTypeMelsec | 0xB4,         // Link Register (word)
//    
//    kMelsecTSAccess = kProtocolTypeMelsec | 0xC1,        // Timer Contact (bit)
//    kMelsecTCAccess = kProtocolTypeMelsec | 0xC0,        // Timer Coil (bit)
//    kMelsecTNAccess = kProtocolTypeMelsec | 0xC2,        // Timer Current Value (word)
//    
//    kMelsecSSAccess = kProtocolTypeMelsec | 0xC7,        // Retentive Timer Contact (bit)
//    kMelsecSCAccess = kProtocolTypeMelsec | 0xC6,        // Retentive Timer Coil (bit)
//    kMelsecSNAccess = kProtocolTypeMelsec | 0xC8,        // Retentive Timer Current Value (word)
//    
//    kMelsecCSAccess = kProtocolTypeMelsec | 0xC4,        // Counter Contact (bit)
//    kMelsecCCAccess = kProtocolTypeMelsec | 0xC3,        // Counter Timer Coil (bit)
//    kMelsecCNAccess = kProtocolTypeMelsec | 0xC5,        // Counter Current Value (word)
//    
//    kMelsecRAccess  = kProtocolTypeMelsec | 0xAF,        // File Register (word)
    
    
    // Modbus
    kModbIAccess =  kProtocolTypeModbus | 0x30,         // Discrete inputs (read only)
    kModbCAccess =  kProtocolTypeModbus | 0x31,         // Coils
    kModbIRAccess =  kProtocolTypeModbus | 0x02,        // Input registers (read only)
    kModbHRAccess =  kProtocolTypeModbus | 0x18,        // Holding registers
    
    // EIP
    kEIPAccess =  kProtocolTypeEIP | 0x18,       // any symbolic access
    
    // Opto22 Forth
    kOPTOAccess         = kProtocolTypeOptoForth | 0x18,     // any symbolic access
    kOPTOTableAccess    = kProtocolTypeOptoForth | 0x19,     // any table symbolic access
    kOPTOSAccess        = kProtocolTypeOptoForth | 0x1A,     // opto string symbolic access
    kOPTOSTableAccess   = kProtocolTypeOptoForth | 0x1B,     // opto table string symbolic access
    kOPTOPAccess        = kProtocolTypeOptoForth | 0x1C,     // opto point symbolic access
    kOPTOChartStatusAccess   = kProtocolTypeOptoForth | 0x20,     // opto chart access (to read)
    kOPTOChartStartAccess    = kProtocolTypeOptoForth | 0x21,     // opto chart access (to start)
    kOPTOChartStopAccess     = kProtocolTypeOptoForth | 0x22,     // opto chart access (to stop)
    kOPTOTimerStartAccess    = kProtocolTypeOptoForth | 0x30,     // opto timer access ( to start)
    kOPTOTimerStopAccess     = kProtocolTypeOptoForth | 0x31,     // opto timer access ( to stop)
    kOPTOTimerPauseAccess    = kProtocolTypeOptoForth | 0x32,     // opto timer access ( to pause)
    kOPTOTimerContinueAccess = kProtocolTypeOptoForth | 0x33,     // opto timer access ( to continue)
    
    // EIP_PCCC (els area codes en aquest cas coincideixen amb els que s'envien a la trama)
    kEIP_PCCCOAccess =  kProtocolTypeEIP_PCCC | 0x8b,       // Outputs
    kEIP_PCCCIAccess =  kProtocolTypeEIP_PCCC | 0x8c,       // Inputs
    kEIP_PCCCSAccess =  kProtocolTypeEIP_PCCC | 0x84,       // Status
    kEIP_PCCCBAccess =  kProtocolTypeEIP_PCCC | 0x85,       // Binary
    kEIP_PCCCTAccess =  kProtocolTypeEIP_PCCC | 0x86,       // Timers
    kEIP_PCCCCAccess =  kProtocolTypeEIP_PCCC | 0x87,       // Counters
    kEIP_PCCCRAccess =  kProtocolTypeEIP_PCCC | 0x88,       // Control (R)
    kEIP_PCCCNAccess =  kProtocolTypeEIP_PCCC | 0x89,       // Integers
    kEIP_PCCCFAccess =  kProtocolTypeEIP_PCCC | 0x8A,       // Floating Point
    kEIP_PCCCSTAccess =  kProtocolTypeEIP_PCCC | 0x8D,      // String
    //kEIP_PCCCAscciAccess =  kProtocolTypeEIP_PCCC | 0x8E,   // ASCII
    //kEIP_PCCCBcdAccess =  kProtocolTypeEIP_PCCC | 0x8F,     // BCD
    //kEIP_PCCCLAccess =  kProtocolTypeEIP_PCCC | 0x80,     // Long Integers  // error de tag
    kEIP_PCCCDLSAccess =  kProtocolTypeEIP_PCCC | 0xA5,      // Data Log Status
    
    // Siemens S7 ISO_TCP (els area codes en aquest cas coincideixen amb els que s'envien a la trama)
    kS7SysInfoAccess = kProtocolTypeSiemensISO_TCP | 0x3,	// System info of 200 family
    kS7SysFlagsAccess = kProtocolTypeSiemensISO_TCP | 0x5,	// System flags of 200 family
    kS7AnaInAccess = kProtocolTypeSiemensISO_TCP | 0x6,     // analog inputs of 200 family
    kS7AnaOutAccess = kProtocolTypeSiemensISO_TCP | 0x7,    // analog outputs of 200 family
    kS7PAccess = kProtocolTypeSiemensISO_TCP | 0x80,        // direct peripheral access
    kS7InputsAccess = kProtocolTypeSiemensISO_TCP | 0x81,   // inputs (E)
    kS7OutputsAccess = kProtocolTypeSiemensISO_TCP | 0x82,  // outputs (A)
    kS7FlagsAccess = kProtocolTypeSiemensISO_TCP | 0x83,    // flags (M)
    kS7DBAccess = kProtocolTypeSiemensISO_TCP | 0x84,       // data blocks (DB)
    kS7DIAccess = kProtocolTypeSiemensISO_TCP | 0x85,       // instance data blocks
    kS7LocalAccess = kProtocolTypeSiemensISO_TCP | 0x86,    // not tested
    kS7VAccess = kProtocolTypeSiemensISO_TCP | 0x87,        // don't know what it is
    kS7CounterAccess = kProtocolTypeSiemensISO_TCP | 28,    // S7 counters (Z)
    kS7TimerAccess = kProtocolTypeSiemensISO_TCP | 29,      // S7 timers (T)
    kS7Counter200Access = kProtocolTypeSiemensISO_TCP | 30,	// IEC counters (200 family)
    kS7Timer200Access = kProtocolTypeSiemensISO_TCP | 31,	// IEC timers (200 family)
    
    
} ;

//--------------------------------------------------------------------------------------
// Valors en area.areaCode
//
//  0000 0000 00000000
//            ||||||||   indica el area code (segons protocol)
//       ||||            indica el protocol, es un ProtocolType
//

//--------------------------------------------------------------------------------------
// Mascares per extreure el protocol i el area
//
enum AreaCodeMasks
{
    protocolTypeMask = 0x0f00,
    areaCodeTypeMask = 0x00ff
} ;

#define melsecBitDevice(areaCode) (((areaCode)&protocolTypeMask)==kProtocolTypeMelsec && ((areaCode)&kMelsecFlagBITFlag))

////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Constants i flags per la propietat area.rawSize, area.subRawSize i varType.siz
////////////////////////////////////////////////////////////////////////////////////////

//--------------------------------------------------------------------------------------
// Constants per la mida, la mida s'expressa en bits, cualsevol mida arbitraria es possible
// en area.rawSize pero varType esta limitat a 32 bits.
//
enum PlcTagBitSize
{
    kBitSizeUnknown             = 0, 
    kBitSizeBit                 = 1,    //  1 bit
    kBitSizeChar                = 8,    //  8 bits
    kBitSizeShort               = 16,   // 16 bits
    kBitSizeLongInt             = 32,   // 32 bits
    
    kBitSizeSixByte             = 48,   // 48 bits
    //kBitSizeLongLongInt         = 64, // 64 bits
    
    kBitSizeCharString          = 32*8,      // 32 bytes per defecte
    kBitSizePCCCString          = (2+82)*8, // 2 bytes per la longitud i 82 bytes per els caracters
    kBitSizeEIPString           = (4+82+2)*8, // 4 bytes per la longitud i 82 bytes per els caracters + 2 pad bytes
    kBitSizeS7String            = (1+1+254)*8, // 1 bytes per la longitud total, 1 byte per la longitud i 254 bytes (max) per els caracters
    
    kBitSizeOptoPoint           = 31*8
} ;

////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Constants i flags per la propietat varType.stru
////////////////////////////////////////////////////////////////////////////////////////

//--------------------------------------------------------------------------------------
// Constants per el tipus de estructura (varType.stru)
//
enum PlcTagStructType
{
    kStructTypeNone             = 0,
    kStructTypeCharString       = 1,   // string de caracters, cadena de caracters de longitud arbitraria per protocols que no suporten strings
    kStructTypePCCCString       = 2,   // PCCC string (tambe utilitzada com a string generica de longitud fixa en protocols que no suporten strings)
    kStructTypeEIPString        = 3,   // EIP string
    kStructTypeS7String         = 4,   // S7 string, String tipus S7 per protocols que no suporten strings
} ;



////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Constants de conveniencia per la propietat area
////////////////////////////////////////////////////////////////////////////////////////

//--------------------------------------------------------------------------------------
// Convencions utilitzades segons protocol (propietat area)
/*
FINS

areaCode. Identifica el protocol i l'area segons enum MemoryAreaCode
rawSize. Mida basica en bits dels elements accedits en el area (sempre 16 excepte per completion flag de T/C que es 8)
subRawSize. 1 si accedim el bit (D0.0, W0.0, 0.0)

MELSEC

areaCode. Identifica el protocol i l'area segons enum MemoryAreaCode
rawSize. Mida basica en bits dels elements accedits en el area (sempre 16)
subRawSize. 1 si accedim el bit (D0.0, W0.0, 0.0) o si estem en un area de bits (M3)

MODBUS

areaCode. Identifica el protocol i l'area segons enum MemoryAreaCode
rawSize. Mida basica en bits dels elements accedits en el area (1 per I0, 1 per C0, 16 per HR0, 16 per IR0)
subRawSize. 1 si accedim el bit (HR0.0, IR0.0)

EIP_PCCC

areaCode. Identifica el protocol i l'area segons enum MemoryAreaCode
rawSize. Mida basica en bits dels elements accedits en el area (16 per N7:0, 16 per N7:0/0, 16 per B3:0.0, 32 per F8:0, 48 per T4:0, 672 per STx:0)
subRawSize. 1 si accedim el bit (N7:0/0, B3:0/0, T4:0.en), 16 si accedim a un element de temporitzador o contador (T4:0.acc) en aquest cas btOffset indica quin element

EIP

areaCode. Sempre kEIPAccess
rawSize. Mida basica en bits dels elements accedits per nom (8 per BOOL, 8 per SINT, 16 per INT, 32 per DINT, 32 per REAL, 32 per array de BOOL)
subRawSize. 1 si accedim el bit (intValue.0, dIntValue.0, boolArray[0])

OPTO22

areaCode. kAreaCodeOPTO excepte per el access de Points (estructures de 31 bytes)
rawSize. Mida basica dels elements, sempre 32
subRawSize. 1 si accedim el bit (SweetInteger.0, SweetInteger.1). 32 si accedim a un element de Point (Temperature.max) en aquest cas btOffset indica la posicio. Adicionalment subRawSize pot ser 1 amb un btOffset no zero, en aquest cas agafem el bit al offset indicat per btOffset (input.state)

SIEMENS ISO_TCP

areaCode. Identifica el protocol i l'area segons enum MemoryAreaCode
rawSize. Mida basica en bits dels elements accedits en el area (generalment 8)
subRawSize. 1 si accedim el bit (DB3.DBD4.0, IB2)

*/


//--------------------------------------------------------------------------------------
// sense protocol conegut
//
static const AreaCode kAreaCodeUnknown = { kUnknownAccess, kBitSizeBit, kBitSizeUnknown } ;  // cap protocol (==0)

//--------------------------------------------------------------------------------------
// Generic (sense un protocol particular, pero amb informacio rellevant per tags locals)
//
//static const AreaCode kAreaCodeGenericString =  { kUnknownAccess, kBitSizeEIPString, kBitSizeUnknown } ;

//--------------------------------------------------------------------------------------
// Omron Fins (els area codes en aquest cas coincideixen amb els que s'envien a la trama)
// (en aquest cas s'han de combinar amb el FinsMemoryAccessUnit per tenir l'area completa)
//
//static const AreaCode kAreaCodeCIO0         = { kCIOAccess0, kBitSizeShort, kBitSizeUnknown } ;   // legacy
static const AreaCode kAreaCodeTC           = { kTCAccess, kBitSizeShort, kBitSizeUnknown } ;
static const AreaCode kAreaCodeTCFlag       = { kTCFlagAccess, kBitSizeChar, kBitSizeUnknown } ;
static const AreaCode kAreaCodeDM           = { kDMAccess, kBitSizeShort, kBitSizeUnknown } ;
static const AreaCode kAreaCodeCIO          = { kCIOAccess, kBitSizeShort, kBitSizeUnknown } ;
static const AreaCode kAreaCodeW            = { kWAccess, kBitSizeShort, kBitSizeUnknown } ;
static const AreaCode kAreaCodeHR           = { kHRAccess, kBitSizeShort, kBitSizeUnknown } ;
static const AreaCode kAreaCodeAR           = { kARAccess, kBitSizeShort, kBitSizeUnknown } ;
static const AreaCode kAreaCodeEMCurrent    = { kEMCurrentAccess, kBitSizeShort, kBitSizeUnknown } ;
static const AreaCode kAreaCodeEM0          = { kEM0Access, kBitSizeShort, kBitSizeUnknown } ;
static const AreaCode kAreaCodeEM1          = { kEM1Access, kBitSizeShort, kBitSizeUnknown } ;
static const AreaCode kAreaCodeEM2          = { kEM2Access, kBitSizeShort, kBitSizeUnknown } ;
static const AreaCode kAreaCodeEM3          = { kEM3Access, kBitSizeShort, kBitSizeUnknown } ;
static const AreaCode kAreaCodeNumber       = { kNumberAccess, kBitSizeShort, kBitSizeUnknown } ;

//--------------------------------------------------------------------------------------
// Melsec (els area codes en aquest cas coincideixen amb els que s'envien a la trama)
//
static const AreaCode kAreaCodeMelsecX           = { kMelsecXAccess, kBitSizeShort, kBitSizeUnknown } ;
static const AreaCode kAreaCodeMelsecY           = { kMelsecYAccess, kBitSizeShort, kBitSizeUnknown } ;
static const AreaCode kAreaCodeMelsecM           = { kMelsecMAccess, kBitSizeShort, kBitSizeUnknown } ;
static const AreaCode kAreaCodeMelsecL           = { kMelsecLAccess, kBitSizeShort, kBitSizeUnknown } ;
static const AreaCode kAreaCodeMelsecF           = { kMelsecFAccess, kBitSizeShort, kBitSizeUnknown } ;
static const AreaCode kAreaCodeMelsecV           = { kMelsecVAccess, kBitSizeShort, kBitSizeUnknown } ;
static const AreaCode kAreaCodeMelsecS           = { kMelsecSAccess, kBitSizeShort, kBitSizeUnknown } ;
static const AreaCode kAreaCodeMelsecB           = { kMelsecBAccess, kBitSizeShort, kBitSizeUnknown } ;

static const AreaCode kAreaCodeMelsecD           = { kMelsecDAccess, kBitSizeShort, kBitSizeUnknown } ;
static const AreaCode kAreaCodeMelsecW           = { kMelsecWAccess, kBitSizeShort, kBitSizeUnknown } ;

static const AreaCode kAreaCodeMelsecTS          = { kMelsecTSAccess, kBitSizeShort, kBitSizeUnknown } ;
static const AreaCode kAreaCodeMelsecTC          = { kMelsecTCAccess, kBitSizeShort, kBitSizeUnknown } ;
static const AreaCode kAreaCodeMelsecTN          = { kMelsecTNAccess, kBitSizeShort, kBitSizeUnknown } ;

static const AreaCode kAreaCodeMelsecSS          = { kMelsecSSAccess, kBitSizeShort, kBitSizeUnknown } ;
static const AreaCode kAreaCodeMelsecSC          = { kMelsecSCAccess, kBitSizeShort, kBitSizeUnknown } ;
static const AreaCode kAreaCodeMelsecSN          = { kMelsecSNAccess, kBitSizeShort, kBitSizeUnknown } ;

static const AreaCode kAreaCodeMelsecCS          = { kMelsecCSAccess, kBitSizeShort, kBitSizeUnknown } ;
static const AreaCode kAreaCodeMelsecCC          = { kMelsecCCAccess, kBitSizeShort, kBitSizeUnknown } ;
static const AreaCode kAreaCodeMelsecCN          = { kMelsecCNAccess, kBitSizeShort, kBitSizeUnknown } ;

static const AreaCode kAreaCodeMelsecR           = { kMelsecRAccess, kBitSizeShort, kBitSizeUnknown } ;

//--------------------------------------------------------------------------------------
// Modbus
//
static const AreaCode kAreaCodeModbI        = { kModbIAccess, kBitSizeBit, kBitSizeUnknown } ;           // Discrete inputs (read only)
static const AreaCode kAreaCodeModbC        = { kModbCAccess, kBitSizeBit, kBitSizeUnknown } ;           // Coils
static const AreaCode kAreaCodeModbIR       = { kModbIRAccess, kBitSizeShort, kBitSizeUnknown } ;        // Input registers (read only)
static const AreaCode kAreaCodeModbHR       = { kModbHRAccess, kBitSizeShort, kBitSizeUnknown } ;        // Holding registers

//--------------------------------------------------------------------------------------
// EIP
// En aquest protocol els elements s'accedeixen per nom+index. Basicament creem algunes estructures de 
// conveniencia per als casos tipics, pero areaCode.rawSize s'ha d'actualitzar d'acord amb la longitud
// de la variable en cada cas. 
static const AreaCode kAreaCodeEIP          = { kEIPAccess, kBitSizeUnknown, kBitSizeUnknown } ;        // qualsevol acces simbolic
static const AreaCode kAreaCodeEIPByteBool  = { kEIPAccess, kBitSizeChar, kBitSizeUnknown } ;           // bools de 1 byte
static const AreaCode kAreaCodeEIPBoolArray = { kEIPAccess, kBitSizeLongInt, kBitSizeBit } ;            // bools de 1 bit en "bool array"
static const AreaCode kAreaCodeEIPString    = { kEIPAccess, kBitSizeEIPString, kBitSizeUnknown } ;      // EIP string

//--------------------------------------------------------------------------------------
// OptoForth
// En aquest protocol els elements s'accedeixen per nom+index.
//
static const AreaCode kAreaCodeOPTO             = { kOPTOAccess, kBitSizeLongInt, kBitSizeUnknown } ;        // qualsevol acces simbolic
static const AreaCode kAreaCodeOPTOTable        = { kOPTOTableAccess, kBitSizeLongInt, kBitSizeUnknown } ;   // qualsevol acces a taula simbolic
static const AreaCode kAreaCodeOPTOString       = { kOPTOSAccess, kBitSizeLongInt, kBitSizeUnknown } ;       // OPTO string
static const AreaCode kAreaCodeOPTOStringTable  = { kOPTOSTableAccess, kBitSizeLongInt, kBitSizeUnknown } ;  // OPTO string table
static const AreaCode kAreaCodeOPTOPoint        = { kOPTOPAccess, kBitSizeOptoPoint, kBitSizeUnknown } ;                  // OPTO point
static const AreaCode kAreaCodeOPTOChartStatus  = { kOPTOChartStatusAccess, kBitSizeLongInt, kBitSizeUnknown } ;  // OPTO chart status
static const AreaCode kAreaCodeOPTOChartStart   = { kOPTOChartStartAccess, kBitSizeLongInt, kBitSizeUnknown } ;  // OPTO chart start
static const AreaCode kAreaCodeOPTOChartStop    = { kOPTOChartStopAccess, kBitSizeLongInt, kBitSizeUnknown } ;  // OPTO chart stop
static const AreaCode kAreaCodeOPTOTimerStart   = { kOPTOTimerStartAccess, kBitSizeLongInt, kBitSizeUnknown } ; // OPTO timer start access
static const AreaCode kAreaCodeOPTOTimerStop    = { kOPTOTimerStopAccess, kBitSizeLongInt, kBitSizeUnknown } ; // OPTO timer stop access
static const AreaCode kAreaCodeOPTOTimerPause   = { kOPTOTimerPauseAccess, kBitSizeLongInt, kBitSizeUnknown } ; // OPTO timer pause access
static const AreaCode kAreaCodeOPTOTimerContinue= { kOPTOTimerContinueAccess, kBitSizeLongInt, kBitSizeUnknown } ; // OPTO continue timer access

//--------------------------------------------------------------------------------------
// EIP_PCCC (els area codes en aquest cas coincideixen amb els que s'envien a la trama)
//
static const AreaCode kAreaCodeEIP_PCCCO    = { kEIP_PCCCOAccess, kBitSizeShort, kBitSizeUnknown } ;    // Outputs
static const AreaCode kAreaCodeEIP_PCCCI    = { kEIP_PCCCIAccess, kBitSizeShort, kBitSizeUnknown } ;    // Inputs
static const AreaCode kAreaCodeEIP_PCCCS    = { kEIP_PCCCSAccess, kBitSizeShort, kBitSizeUnknown } ;    // Status
static const AreaCode kAreaCodeEIP_PCCCB    = { kEIP_PCCCBAccess, kBitSizeShort, kBitSizeUnknown } ;    // Binary
static const AreaCode kAreaCodeEIP_PCCCT    = { kEIP_PCCCTAccess, kBitSizeSixByte, kBitSizeShort } ;    // Timers
static const AreaCode kAreaCodeEIP_PCCCC    = { kEIP_PCCCCAccess, kBitSizeSixByte, kBitSizeShort } ;    // Counters
static const AreaCode kAreaCodeEIP_PCCCR    = { kEIP_PCCCRAccess, kBitSizeShort, kBitSizeUnknown } ;    // Control (R)
static const AreaCode kAreaCodeEIP_PCCCN    = { kEIP_PCCCNAccess, kBitSizeShort, kBitSizeUnknown } ;    // Integers
static const AreaCode kAreaCodeEIP_PCCCF    = { kEIP_PCCCFAccess, kBitSizeLongInt, kBitSizeUnknown } ;      // Floating Point
static const AreaCode kAreaCodeEIP_PCCCST   = { kEIP_PCCCSTAccess, kBitSizePCCCString, kBitSizeUnknown } ; // String

//static const AreaCode kAreaCodeEIP_PCCCDLS  = { kEIP_PCCCDLSAccess, kBitSizePCCCString, kBitSizeUnknown } ;
static const AreaCode kAreaCodeEIP_PCCCDLS  = { kEIP_PCCCDLSAccess, kBitSizeSixByte, kBitSizeShort } ;

//--------------------------------------------------------------------------------------
// Siemens s7 ISO_TCP (els area codes en aquest cas coincideixen amb els que s'envien a la trama)
//
static const AreaCode kAreaCodeS7SysInfo    = { kS7SysInfoAccess, kBitSizeChar, kBitSizeUnknown } ;   
static const AreaCode kAreaCodeS7SysFlags   = { kS7SysFlagsAccess, kBitSizeChar, kBitSizeUnknown } ;  // SFB0 (SMB0)
static const AreaCode kAreaCodeS7AnaIn      = { kS7AnaInAccess, kBitSizeShort, kBitSizeUnknown } ;    // AIW0 (AEW0)
static const AreaCode kAreaCodeS7AnaOut     = { kS7AnaOutAccess, kBitSizeShort, kBitSizeUnknown } ;   // AQW0 (AAW0)
static const AreaCode kAreaCodeS7P          = { kS7PAccess, kBitSizeChar, kBitSizeUnknown } ;        // PIW4 (PEW4)
static const AreaCode kAreaCodeS7Inputs     = { kS7InputsAccess, kBitSizeChar, kBitSizeUnknown } ;   // IB2 (EB2)
static const AreaCode kAreaCodeS7Outputs    = { kS7OutputsAccess, kBitSizeChar, kBitSizeUnknown } ;   // QD8 (AD8)
static const AreaCode kAreaCodeS7Flags      = { kS7FlagsAccess, kBitSizeChar, kBitSizeUnknown } ;   // FW4  (MW4)
static const AreaCode kAreaCodeS7DB         = { kS7DBAccess, kBitSizeChar, kBitSizeUnknown } ;      // DB3.DBD4, VW1234 
static const AreaCode kAreaCodeS7DI         = { kS7DIAccess, kBitSizeChar, kBitSizeUnknown } ;
static const AreaCode kAreaCodeS7Local      = { kS7LocalAccess, kBitSizeChar, kBitSizeUnknown } ;
static const AreaCode kAreaCodeS7V          = { kS7VAccess, kBitSizeChar, kBitSizeUnknown } ;
static const AreaCode kAreaCodeS7Counter    = { kS7CounterAccess, kBitSizeShort, kBitSizeUnknown } ;   // C2 (Z2)
static const AreaCode kAreaCodeS7Timer      = { kS7TimerAccess, kBitSizeShort, kBitSizeUnknown } ;     // T2 (T2)
static const AreaCode kAreaCodeS7Counter200 = { kS7Counter200Access, kBitSizeShort, kBitSizeUnknown } ;  // C2 (Z2)
static const AreaCode kAreaCodeS7Timer200   = { kS7Timer200Access, kBitSizeShort, kBitSizeUnknown } ;   // T2 (T2)


////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Constants i mascares per la propietat varType
////////////////////////////////////////////////////////////////////////////////////////

//--------------------------------------------------------------------------------------
// detall del valors en la propietat varType.sto
//
//  0000 0000 (.sto)
//
//          |            indica que és unsigned
//         |             indica que és bcd o bool
//        |              indica float
//       |               indica tipus estructurat (el domain type ha de ser kDomainTypeArray, area.structAccess indica el tipus)
//    ||                 indiquen el domain type, es un PlcTagElementDomainType

//--------------------------------------------------------------------------------------   
// valors en la propietat varType.sto (storage types)
//
enum PlcTagElementStorageType
{
    kStorageDefault         = 0,
    kStorageUnsigned        = 1 << 0,
    kStorageBcd             = 1 << 1,  // també s'utilitza per els bool
    kStorageFloat           = 1 << 2,
    kStorageStruct          = 1 << 3,
} ;

//--------------------------------------------------------------------------------------   
// valors en la propietat varType.sto (domain types)
//
enum PlcTagElementDomainType
{
    kDomainTypeScalar       = 0 << 4,
    kDomainTypeCFArray      = 1 << 4,  // es referix a un array que conte elements amb longitud variable
    kDomainTypeAlarm        = 2 << 4,
    kDomainTypeArray        = 3 << 4,
} ;

typedef enum PlcTagElementDomainType PlcTagElementDomainType ;

//--------------------------------------------------------------------------------------
// mascares per varType.sto
//
enum PlcTagElementsMasks
{
    kStorageTypeMask    = 0x0f,   //0000 1111
    kDomainMask         = 0x30    //0011 0000
} ;


////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Definicio de la estructura VarType
////////////////////////////////////////////////////////////////////////////////////////

//--------------------------------------------------------------------------------------
struct VarType
{
    UInt16 siz;     // mida principal dels elements expressada en bits, es un PlcTagBitSize
    UInt8 sto;      // identifica el tipus de storage, es una combinacio de PlcTagElementStorageType i PlcTagElementDomainType
    UInt8 stru;     // identifica el tipus de estructura segons PlcTagStructType
} ;

typedef struct VarType VarType ;



////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Constants de conveniencia per la propietat varType
////////////////////////////////////////////////////////////////////////////////////////

static const VarType kUnknownVarType            = { kBitSizeUnknown, kStorageDefault } ;

// signed types
static const VarType kBitVarType                = { kBitSizeBit, kStorageDefault, kStructTypeNone } ;
static const VarType kByteVarType               = { kBitSizeChar, kStorageDefault, kStructTypeNone } ;
static const VarType kShortIntVarType           = { kBitSizeShort, kStorageDefault, kStructTypeNone } ;
static const VarType kLongIntVarType            = { kBitSizeLongInt, kStorageDefault, kStructTypeNone } ;

// char types
static const VarType kCharVarType               = { kBitSizeChar, kStorageUnsigned, kStructTypeNone } ;

// unsigned types
static const VarType kUnsignedShortIntVarType   = { kBitSizeShort, kStorageUnsigned, kStructTypeNone } ;
static const VarType kUnsignedLongIntVarType    = { kBitSizeLongInt, kStorageUnsigned, kStructTypeNone } ;

// bool types
static const VarType kBoolVarType               = { kBitSizeBit, kStorageBcd, kStructTypeNone } ;

// bcd types
static const VarType kShortBcdVarType           = { kBitSizeShort, kStorageBcd | kStorageUnsigned, kStructTypeNone } ;
static const VarType kLongBcdVarType            = { kBitSizeLongInt, kStorageBcd | kStorageUnsigned, kStructTypeNone } ;

// float types
static const VarType kFloatVarType              = { kBitSizeLongInt, kStorageFloat, kStructTypeNone } ;

// string types
//static const VarType kGStringVarType          = { kBitSizeGString, kDomainTypeArray | kStorageStruct, kStructTypeGString } ;
static const VarType kCharStringVarType         = { kBitSizeCharString, kDomainTypeArray | kStorageStruct, kStructTypeCharString } ;
static const VarType kPCCCStringVarType         = { kBitSizePCCCString, kDomainTypeArray | kStorageStruct, kStructTypePCCCString } ;
static const VarType kEIPStringVarType          = { kBitSizeEIPString, kDomainTypeArray | kStorageStruct, kStructTypeEIPString } ;
static const VarType kS7StringVarType           = { kBitSizeS7String, kDomainTypeArray | kStorageStruct, kStructTypeS7String } ;
static const VarType kOPTOStringVarType         = { kBitSizeLongInt, kDomainTypeCFArray | kStorageStruct, kStructTypeNone } ;

#define boolVarType(varType) ( ((varType).sto & kStorageBcd) && !((varType).sto & kStorageUnsigned) )
#define charVarType(varType) ( ((varType).sto & kStorageUnsigned) && ((varType).siz == kBitSizeChar) )



////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Constants i mascares per la propietat errNum
////////////////////////////////////////////////////////////////////////////////////////

//--------------------------------------------------------------------------------------
// Tipus per indicar errors en PlcTag. 
// 0 indica que no hi ha error
// < 64 indica errors detectats durant la comunicacio o que poden solucionarse
// > 64 indica errors permanents en el tag, detectats durant el parseig
//
enum PlcTagErrNum
{
    kPlcTagErrNone = 0,
    
    // Atencio, els protocols defineixen errors adicionals
    
    kPlcTagErrMalformedBcdTag = 40,  // inferior a 40 reservat per els protocols
    kPlcTagErrUnknownStringEncoding,   // no s'utilitza
    kPlcTagErrTagProviderError,
    
    kPlcTagErrLiteVersionTagLimit = 65,  // superior a 64 errors permanents
    kPlcTagErrTypeNotSupported,
    kPlcTagErrAreaNotSupported,
    kPlcTagErrArrayTypeNotSupported,
    kPlcTagErrSizeNotSupported,
    kPlcTagErrInvalidArrayAccess,
    kPlcTagErrZeroArrayLength,
    
    
    kPlcTagErrIntersectsValidationTag,
    kPlcTagScalingError,
    kPlcTagInvalidCharacterInFormatString,
    
} ;

//typedef enum PlcTagErrNum PlcTagErrNum ;

////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Constants i mascares per la propietat prOptions
////////////////////////////////////////////////////////////////////////////////////////

enum S7Options
{
    kPlcTagS7English = 1 << 0,
};


////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Altres Constants mascares i tipus
////////////////////////////////////////////////////////////////////////////////////////

//--------------------------------------------------------------------------------------
// amagatzematge de un valor raw
//
typedef union 
{
    UInt32 longValue ;  // pot contenir implicitament un float (32 bits)
    CFMutableDataRef dataValue ;
} TagRawValue ;

//--------------------------------------------------------------------------------------
// amagatzematge de un valor eng
//
/*
typedef union 
{
    CFMutableDataRef arrayData ;
} TagEngValue ;
*/
    
//--------------------------------------------------------------------------------------
// escalat per valors eng
//
typedef struct
{
    float rmin ;  // raw min
    float rmax ;  // raw max
    float emin ;  // engineering min
    float emax ;  // engineering max
} Scale ;  // son floats pero els calculs es fan en doubles

//--------------------------------------------------------------------------------------
// limits per valors eng
//
typedef struct
{
    float emin ;  // engineering min
    float emax ;  // engineering max
} Bounds ;  // son floats pero els calculs es fan en doubles
   


////////////////////////////////////////////////////////////////////////////////////////
#pragma mark PlcTagElement
////////////////////////////////////////////////////////////////////////////////////////

//--------------------------------------------------------------------------------------
// Nota sobre Multithreading.
//
// La clase PlcTagElement esta pensada per ser utilitzada en combinacio amb PlcCommsObject.
// Donat que PlcCommsObject s'executa asincronament en una cua serie, s'han d'adoptar algunes
// precaucions per evitar corrupció de dades o altres problemes.
// En particular:
// - inicialitzar completament el objecte abans de passarlo per primera vegada a PlcCommsObject.
// - no cridar o modificar a posteriori cap metode o propietat de inicialitzacio.
// - no utilitzar mai la mateixa instancia amb diferents instancies de PlcCommsObject.
// - respectar en tot moment els patrons de cridada definits a la clase PlcCommsObject.
// - mai modificar o accedir a un PlcTagElement excepte de la manera descrita a PlcCommsObject.
//

//--------------------------------------------------------------------------------------
// Nota sobre arrays
//
// El PlcTagElement suporta l'amagatzematge d'arrays d'una dimensio de qualsevol tipus incluit strings, 
// o assenyala una condicio d'alarma
//
// Els arrays s'assenyalen amb kDomainTypeArray. Els elements dels arrays s'amagatzemen en unitats 'raw' de la longitud
// especificada a varType.siz coincidint amb la longitud real al PLC. 
// Els valors s'amagatzemen al camp dataValue de les propietats value i writeValue. 
// Per determinar el nombre d'elements d'un array es divideix el nombre de bytes amagatzemats per varType.siz.
// En el cas de estructures els bytes s'amagatzemen respectant els offsets. Per conveniencia, els bytes s'amagatzemen en
// la endianess nativa del ARM i X86, es a dir 'litte endian', i la classe fa tot tipus d'asumcions de que la endianness es sempre aquesta
// amb independencia de la endianness del PLC. La implementacio dels protocols es responsable de tenir en compte aquest aspecte.
//
// Els arrays es poden assenyalar amb kDomainTypeCFArray. En aquest cas el array s'amagatzema en un CFArray que conte un buffer de bytes
// a cada posicio. En contraposició a kDomainTypeArray en que el buffer es únic. Els arrays creats amb kDomainTypeCFArray permeten
// doncs tenir un nombre variable de bytes a cada posició. El nombre d'elements coincideix amb el count del CFArray. Per compatibilitat
// amb la majoria de metodes que s'utilitzen durant la optimitzacio de requests es manté la mateixa semantica respecte a varType.siz
// en relacio al numero de bytes /teoricament/ amagatzemats. Per exemple, el metode addrSizeOfVar torna varType.siz i
// el metode addrSizeOfTag torna varType.siz*count. El nombre de bytes realment amagatzemats en una posicio es determina amb addSizeOfVarAtIndex

//--------------------------------------------------------------------------------------
// Nota sobre estructures i strings
//
// Les estructures (strings) s'amagatzemen com arrays d'un element, es a dir tenen l'indicador kDomainTypeArray i utilitzen el camp dataValue
// de les propietats value i writeValue. La longitud en bytes coincideix amb la del PLC per el mateix tipus (PlcTagStructType).
// Per arrays de varis elements tenim una longitud total en bytes que es un multiple de la longitud
// d'un element individual. En el cas de kDomainTypeCFArray les estructures s'amagatzemem per separat en cada posicio tal com es descriu
// en la nota anterior.

//--------------------------------------------------------------------------------------
// Nota sobre la propietat btAddr
// 
// La propietat btAddr indica el comencament en el PLC de un determinat element,
// expressat en nombre de bits des del origen del areaCode, per exemple
// en modbus, HR2 sera a la btAddr 16, HR2.1 sera a la btAddr 17 etc. la mida en el areaInfo
// de AreaCode indica la unitat d'acces, en aquest cas seria 16.
//
// Per els protocols simbolics com EIP i OPTO la btAddr indica el offset dintre del tag referit per nom,
// en casos escalars es 0, pero en arrays indica la posicio inicial.


//-------------------------------------------------------------------------------------- 
@interface PlcTagElement : NSObject<QuickCoding> 
{
    @public
    AreaCode area ;         // area (conte el protocol, el area segons el protocol y la mida d'acces)
    VarType varType ;       // tipus de variable
    UInt16 leadingCode ;    // amagatzema el numero d'esclau per protocol modbus, o el file number per EIP/PCCC
    UInt16 btOffset ;       // adressa (offset) expressat en bits per subelements si area.subRawSize >= 8 
    Scale scale ;           // escalat per les unitats de enginyeria
    Bounds bounds ;         // limits d'enginyeria per valors de escritura
    
    @public
    UInt32 btAddr ;         // adressa (principal) expresada en bits, en el cas de tags simbolic correspon a un index en el simbol
    NSData *eipTag ;        // especifica el tag en format de Extended Symbolic segment o 'request path string' de AB
    UInt8 errNum ;          // per posar-hi un codi d'error associat al tag ( 0 es no error, >64 es permanent)
    UInt8 prOptions;        // flags per posar suportar opcions de visualitzacio, no intervenen en la mecanica d'execucio
    unsigned int hasIndex:1;          // especifica que un Tag Simbolic es indexat i permet discrimar el cas de btAddr == 0
    
    @private
    unsigned int alarmValue:1;         // valor de alarma (no es codifica)
    UInt8 flags ;           // flags per suportar condicions o estats del tag ( no es codifica )
        //BOOL alarmValue ;           // valor de alarma (no es codifica)
    CFAbsoluteTime timeStamp ;  // temps en el moment d'agafar un tag (no es codifica )
    TagRawValue value ;         // (es codifica la longitud per crearlo si cal)
    
    @public         // <--- PROVISIONAL
    TagRawValue writeValue ;    // (no es codifica)
    __unsafe_unretained id item ;                   // (__unsafe_unretained) (no es codifica)
}


- (BOOL)isSingleScalar ;



//-------------------------------------------------------------------------------------- 
#pragma mark INICIALITZACIO, Metodes i propietats per inicialitzar la classe
// Els seguents metodes i propietats inicialitzen les instancies i s'han cridar 
// avans d'utilitzar l'objecte en un PlcCommObject

// Estableix la addresa i bit del tag (adrecament regular)
- (void)setAddr:(UInt32)adr withBit:(UInt8)bt ;

// Estableix el EiPTag (addrecament simbolic)
- (void)setEipTag:(NSData*)data ;

// Estableix el tipus de domini de la variable
// Atencio que nomes kDomainTypeScalar i kDomainTypeAlarm esta actualment suportat
- (void)setVarDomainType:(UInt16)type ;

// Prepara un array encapsulat en un CFDataRef que conte dades de tipus 
// type amb longitud count. Count es fa servir com una pista per indicar el que
// volem: si passem un numero >0 sempre es creara un array ; si passem 0 i el tipus
// es no estructurat s'amatzemara com escalar simple, si el tipus es estructurat tindra longitud 1
- (void)prepareCollectionForVarType:(VarType)type domain:(UInt16)domain ofLength:(int)count ;

// Estableix la hora de la ultima lectura. Per defecte agafa la hora de referencia 1-01-2001 00:00:00 GMT
- (void)setTimeStamp:(CFAbsoluteTime)time ;

// torna un nou PlcTag que es copia d'aquest (torna el mateix tipus) (sobregravar per afegir mes propietats)
- (id)newTag ;

// propietat per amagatzemar un objecte (__unsafe_unretained) que en conte una instancia
@property (nonatomic, assign) id item ;

// les seguents iVars publiques es consideren tambe valors a inicialitzar
//
//    AreaCode area ;         // area (conte el protocol, el area segons el protocol y la mida d'acces)
//    VarType varType ;       // tipus de variable
//    UInt16 leadingCode ;    // amagatzema el numero d'esclau per protocol modbus, o el file number per EIP/PCCC
//    UInt16 btOffset ;       // adressa (offset) expressat en bits per subelements quan area.subRawSize >= 8
//    Scale scale ;           // escalat per les unitats de enginyeria
//    Bounds bounds ;         // limits d'enginyeria per valors de escritura


//-------------------------------------------------------------------------------------- 
#pragma mark PROPIETATS, Access a propietats i d'altres
// Els seguents metodes es segur cridarlos en qualsevol moment des de qualsevol thread
// amb la condicio de que no es modifiquen les propietats de Inicialitzacio

// Tipus elemental de la variable amagatzemada. A diferencia d'accedir
// directament a la iVar torna el mateix valor tant si es tracta de arrays o no.  
- (VarType)varType ;

// Torna el tipus de domini de la variable
- (UInt16)varDomainType ;

// Metodes de la propietat eipTag
- (NSData *)eipTag ;
- (BOOL)hasIndex;

// Torna una string amb una descripció de l'area i el tipus
- (NSString *)createAddressAndTypeString ;   // Segueig la regla de 'create'
- (NSString *)addressAndTypeString ;
- (NSString*)tagName ;
- (NSString*)typeString;

// indica que llegim/escribim tipus numeric
- (BOOL)isNumeric ;

// indica que llegim/escribim tipus string
- (BOOL)isString ;

// Torna un NSString informatiu del errNum
- (NSString*)infoStringForErrNum:(UInt8)errN ;

// es tambe segur accedir a qualsevol de les iVar de inicialitzacio com area, varType, ...


//-------------------------------------------------------------------------------------- 
#pragma mark LECTURA, Access als valors de enginyeria per valors llegits
// Aquests metodes estan pensats per ser cridats al rebre finsDidCompleteRead i abans
// de cridar readRegisteredTagElements o readTagElementsInArray. 
// Permeten agafar les dades rellevants que han tornat del PLC per ser amagatzemades 
// en el model de la aplicacio.
// No es segur cridar aquests metodes en altres moments, especialment si el objecte de
// comunicacio te una lectura pendent de la mateixa instancia.

// Numero de error, 0 vol dir no error
- (UInt8)errNum ;

// Torna el timeStamp de la variable. L'ultim cop que ha canviat
- (CFAbsoluteTime)timeStamp ;

// Torna el numero de elements amagatzemat a la clase des del punt de vista d'unitats
// d'enginyeria. Torna 1 encara que no s'hagi preparat un array
- (int)collectionCount ;

// Access a valors d'enginyeria
- (double)engValueAtIndex:(int)indx ;
- (CFDataRef)engValuesDataCreate ;  // torna un array C de doubles encapsulat en un CFData
- (CFStringRef)engStringAtIndexCreate:(int)indx encoding:(CFStringEncoding)encoding;
- (CFArrayRef)engStringsArrayCreateWithEncoding:(CFStringEncoding)encoding;


//-------------------------------------------------------------------------------------- 
#pragma mark ESCRITURA, Escritura de valors d'enginyeria
// Atencio, nomes es segur cridar aquests metodes si no hi ha cap operacio d'escritura en curs 
// de la mateixa instancia, es a dir inicialment o despres de rebre finsDidCompleteWrite 
// i avans d'enviar writeTagElementsInArray. Per modificacio segura dels valors per
// escritura utilitzar els metodes equivalents de PlcCommsObject.

// Estableixen valors de enginyeria numerics per escritura
// El valor -0.0 per a tags escalars te el significat especial de 
// no modificar la dada actual i activar a canvi un flag intern 
- (void)setEngWValue:(double)newValue atIndex:(int)indx;
- (void)setEngWValues:(CFDataRef)theValuesData maxCount:(int)maxCount ;

// Estableixen strings per escritura
- (void)setEngWString:(CFStringRef)str encoding:(CFStringEncoding)encoding atIndex:(int)indx;
- (void)setEngWStrings:(CFArrayRef)texts encoding:(CFStringEncoding)encoding maxCount:(int)count;


//-------------------------------------------------------------------------------------- 
#pragma mark ESCRITURA/LECTURA IMPLICITA, Escritura/Lectura implicita del tag sense PLC
// El seguent metode es pot utilitzar per simular una escritura seguida de lectura de PLC sense
// intervencio real de PLC. Nomes es segur utilitzarla si el objecte no s'utilitza en un PlcCommObject 

// mou directament el valor de escritura al de lectura
- (void)makeImplicitReadValue ;

@end


//---------------------------------------------------------------------------
@interface PlcTagElement(PlcProtocolInterface)

// Access als valors raw de lectura (utilitzat per els protocols)

// Estableix una variable raw.
- (void)setRawValue:(const UInt32)newValue ;   // a eliminar, utilitzar la seguent amb index 0
- (void)setRawValue:(const UInt32)newValue atIndex:(const NSUInteger)indx;
- (void)setRawValueBytes:(const void*)newValuePtr length:(const NSUInteger)length atOffset:(const NSUInteger)offset atIndex:(const NSUInteger)indx;

// a cridar *en lloc de* l'anterior quan no tenim un valor fiable
- (void)setCommError:(UInt8)err ;

// Llegeix una variable de tipus escalar.
//- (UInt32)rawValue;

// Access a la variable 'raw' escalar amagatzemada per escritura
//- (UInt32)rawWValue ;
- (UInt32)rawWValueAtIndex:(const NSUInteger)indx ;
- (const UInt8*)rawWValueBytesAtIndex:(const NSUInteger)indx;
- (UInt32)addSizeOfWVarAtIndex:(const NSUInteger)indx;  // per kDomainTypeCFArray torna la longitud real del element

// es refereixen a la mida en bits de la variable amagatzemada, no ampliada si es tracta d'un array
- (UInt32)addrSizeOfVar ; // element individual
- (UInt32)addrSizeOfTag ; // total

// torna un *nou* array de PlcTagElements a partir dels elements (de longitud varSize.siz) que te aquest
- (NSArray *)newArrayOfTags;
@end

//---------------------------------------------------------------------------
@interface PlcTagElement(PlcCommsInterface)

// Torna YES si el tag ha canviat en l'ultima lectura
- (BOOL)gatherUpdatedValue ;

// Marca que volem forcar la senyal de canvi, es a dir gatherUpdatedValue tornara YES despres de la proxima lectura .
- (void)setForceReportChange ;

@end

//---------------------------------------------------------------------------
@interface PlcTagElement(RawAccessInterface)

// access a btAddr a partir de addressa i bit
- (UInt32)addr ;
- (UInt8)bit ;

// Es refereixen a la mida en bits de variable amagatzemada ampliada per la mida raw
- (UInt32)rawAddrBegin ;  // comencament
- (UInt32)rawAddrLength ; // total

@end




























