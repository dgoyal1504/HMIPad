/*
 *  PlcObjectTypes.h
 *  ScadaMobile_091014
 *
 *  Created by Joan on 14/10/09.
 *  Copyright 2009 SweetWilliam, S.L.. All rights reserved.
 *
 */

//------------------------------------------------------------------------------------------------
// constants per tipus de protocol

enum ProtocolType
{
    kProtocolTypeNone = 0x0000,    // cap protocol (==0)
    kProtocolTypeOmronFins = 0x0100,
    kProtocolTypeModbus = 0x0200,
    kProtocolTypeEIP = 0x0300,
    kProtocolTypeEIP_PCCC = 0x0400,
    kProtocolTypeSiemensISO_TCP = 0x0500,
    kProtocolTypeOptoForth = 0x0600,
    kProtocolTypeMelsec = 0x0700,
    
    kProtocolTypeTagProvider = 0x8000,  // afegit als anteriors indica que s'ha de gestionar a traves del tag provider
    kProtocolTypeInTagProvider = 0x9000,  // afegit als anteriors indica que s'esta gestionant dins del tag provider
} ;

enum ProtocolTypeMasks
{
	kProtocolTypeProtocolMask = 0x0f00,
	kProtocolTypeTagProviderMask = 0xf000
} ;

typedef enum ProtocolType ProtocolType ;

//------------------------------------------------------------------------------------------------
// estructura per suportar un tipus de comanda a PLC (posibles valors definits a FinsRequest.h)
struct RequestCode
{
    UInt8 mrc ; // main request code (hi)
    UInt8 src ; // secondary request code (lo)
} ;

typedef struct RequestCode RequestCode ;


//--------------------------------------------------------------------------------------
// Conte dades rellevants de l'area del PLC on s'amagatzema una variable, independent dels
// tipus de variable que es poden amagatzemar en aquesta area (posibles valors definits a PlcTagElement)
struct AreaCode
{
    UInt16 areaCode;            // identifica el protocol i el area, es un MemoryAreaCode
    UInt16 rawSize;             // mida principal dels elements de l'area expressada en bits, es un PlcTagBitSize
    UInt16 subRawSize;          // mida individual dels elements que s'accedeixen per offset, pot ser 1 per access de bit, es un PlcTagBitSize
} ;

typedef struct AreaCode AreaCode ;



