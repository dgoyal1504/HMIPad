//
//  PlcDevice.h
//  ScadaMobile_091014
//
//  Created by Joan on 15/10/09.
//  Copyright 2009 SweetWilliam, S.L.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QuickCoder.h"

@class PlcTagElement ;

///////////////////////////////////////////////////////////////////////////////////
#pragma mark PlcDevice
///////////////////////////////////////////////////////////////////////////////////

//--------------------------------------------------------------------------------------
// tipus per suportar opcions o informacio adicional del plcTag
//
//--------------------------------------------------------------------------------------
// Contingut de la propietat options per diferents protocols
// Indica si l'element esta swaped respecte l'estandard en el cuart hex per el protocol modbus
enum PlcModbusDeviceOptions
{
    kPlcModbusByteSwapType          = 1 << 0,  // intercanviem bits si es 1
    kPlcModbusWordSwapType          = 1 << 1,  // intercanviem words si es 1
    kPlcModbusStringByteSwapType    = 1 << 2,  // intercanviem bits si es 1
    kPlcModbusRtuFlag               = 1 << 3,   // mode rtu si es 1
    kPlcModbusCommandSizeLimitMask  = 0xff<<8   // expressat en words
} ;

enum PlcEIPDeviceOptions
{
    kPlcEIPSlotNumberMask       = 0x3f,    // 0011 1111  numero de slot per ControlLogix (max 63)
    kPlcEIPConnected            = 1 << 6   // utilitzem "connected" messaging si es 1
} ;

enum PlcS7DeviceOptions
{
    kPlcS7SlotNumberMask       = 0x1f,    // 0001 1111  numero de slot per S7 (max 31)
    kPlcS7RackNumber           = 7 << 5,  // 1110 0000 numero de rack per S7 (max 7)
} ;

enum PlcMelsecDeviceOptions
{
    kPlcMelsecFrameTypeMask        = 0x05,    // 0000 0111  tipus de frame
    kPlcMelsec1EFrames             = 0 << 0,  // comunicacions utilitzant 1E frames si es 0
    kPlcMelsec3EFrames             = 1 << 0,  // comunicacions utilitzant 3E frames si es 1
};

//--------------------------------------------------------------------------------------
@interface PlcDevice : NSObject<QuickCoding>
{
    @public
    UInt16 plcProtocol ;
    UInt16 validationCode ;  // no es codifica
    
	// adreces del notification provider
    UInt16 tpLocalPort ;
    UInt16 tpRemotePort ;
    NSString *tpLocalHost ;
    NSString *tpRemoteHost ;
    
	// adreces per access directe
    UInt16 localPort ;
    UInt16 remotePort ;
    NSString *localHost ;
    NSString *remoteHost ;
    
    // altres
    UInt16 pollRate ;   // en mili segons
    UInt16 validationTagId ;
    CFStringEncoding stringEncoding ;

    UInt16 options ; // Opcions per protocols (veure mes amunt) de swap i RTU en Modbus. Slot number en E/IP
    BOOL sslEnabled ;
    BOOL isDefault ;
    BOOL altIsFirst ; // no es codifica
    
    @protected   
    //PlcTagElement *validationTag ; // no es codifica
    

}

+ (UInt16)encriptCode:(UInt16)code ;

- (void)setTPLocalHost:(NSString*)value ;
- (void)setTPRemoteHost:(NSString*)value ;

- (void)setLocalHost:(NSString*)value ;
- (void)setRemoteHost:(NSString*)value ;
- (void)setValidationTagId:(UInt16)vaId ;

- (void)setStringEncoding:(CFStringEncoding)encoding ;
- (void)setPollRate:(UInt16)value ;

- (BOOL)usesTagProvider ;
- (UInt16)plcProtocol ;
- (UInt16)defaultPort ;

- (UInt16)efDefaultPort ;

- (NSString *)efLocalHost ;
- (NSString *)efRemoteHost ;

- (UInt16)efLocalPort ;
- (UInt16)efRemotePort ;

- (Class)protocolClass ;
- (PlcTagElement *)validationTag ;
- (UInt32)defaultValidationTagId;

- (id)newDevice;  // torna una *nova* copia d'ell mateix o subclase (sobregravar per afegir mes propietats)

- (NSString *)protocolStr ;

- (NSString *)tpLocalHostStr ;
- (NSString *)tpRemoteHostStr ;

- (NSString *)localHostStr ;
- (NSString *)remoteHostStr ;
- (NSString *)sslEnabledStr ;

- (NSString *)descriptionStr ;
- (NSString *)uniqueStr ;
- (NSString *)stringEncodingStr ;

@end


