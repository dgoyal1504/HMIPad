//
//  SWValueTypes.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/4/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

//typedef UInt8 SWValueState;
//
//enum {
//    SWValueStateOk          = 0,
//    SWValueStateInvalid     = 1<<1, // indica que el valor pot ser erroni
//    SWValueStateCircular    = 1<<2, // indica que s'ha trobat una referencia circular
//};




enum
{
    SWValueTypeFlagRPNValueStruct = 1 << 8,
    SWValueTypeFlagRPNValueRetainable = 1 << 9,
    SWValueTypeFlagRPNValueCollection = 1 << 10,
} ;
typedef UInt16 SWValueTypeFlag;

enum
{
    SWValueTypeError =          0,
    //SWValueTypeNoSource =       1,
    SWValueTypeNumber =         1,
    SWValueTypeAbsoluteTime =   2,
    SWValueTypePoint =          3 | SWValueTypeFlagRPNValueRetainable | SWValueTypeFlagRPNValueStruct,
    SWValueTypeSize =           4 | SWValueTypeFlagRPNValueRetainable | SWValueTypeFlagRPNValueStruct,
    SWValueTypeRect =           5 | SWValueTypeFlagRPNValueRetainable | SWValueTypeFlagRPNValueStruct,
    SWValueTypeRange =          6 | SWValueTypeFlagRPNValueRetainable | SWValueTypeFlagRPNValueStruct,
    SWValueTypeString =         7 | SWValueTypeFlagRPNValueRetainable,
    SWValueTypeObject =         8 | SWValueTypeFlagRPNValueRetainable,
    SWValueTypeArray =          9 | SWValueTypeFlagRPNValueRetainable | SWValueTypeFlagRPNValueCollection,
    SWValueTypeHash =          10 | SWValueTypeFlagRPNValueRetainable | SWValueTypeFlagRPNValueCollection,
    SWValueTypeClassSelector = 11,
} ;
typedef UInt16 SWValueType;


struct SWValueRange
{
	double min ;
	double max ;
};
typedef struct SWValueRange SWValueRange;

static inline SWValueRange SWValueRangeMake(double min, double max)
{
  SWValueRange p = { min, max } ;
  return p;
}


#if __cplusplus
extern "C" {   // no volem que el compilador de c++ mutili els noms de les funcions !
#endif
    
extern NSString* NSStringFromSWValueType(SWValueType valueType);
extern NSString* NSLocalizedStringFromSWValueType(SWValueType valueType);
extern SWValueType SWValueTypeFromNSString(NSString* string);

#if __cplusplus
}
#endif
