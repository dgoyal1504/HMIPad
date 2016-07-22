//
//  SWSystemItemMotion.h
//  HmiPad
//
//  Created by Joan Martin on 9/4/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWSystemItem.h"

#import <CoreMotion/CoreMotion.h>

/**
 * Aquesta classe utilitza CMDeviceMotions, un servei sols disponible per a devices amb acceleròmetre i giroscopi. 
 * Per tant, és funcional sols amb iPhones >= 4, iPods >= 4 i iPads >= 2.
 */
@class SWValue;

@interface SWSystemItemMotion : SWSystemItem

@property (nonatomic, readonly) SWValue *gravity;
@property (nonatomic, readonly) SWValue *userAcceleration;
@property (nonatomic, readonly) SWValue *accelerometerAvailable;

@property (nonatomic, readonly) SWValue *attitude;
@property (nonatomic, readonly) SWValue *rotationRate;
@property (nonatomic, readonly) SWValue *gyroscopeAvailable;

@property (nonatomic, readonly) SWValue *magneticField;
@property (nonatomic, readonly) SWValue *magnetomerAvailable;

@end
