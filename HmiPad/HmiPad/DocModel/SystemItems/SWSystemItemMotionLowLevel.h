//
//  SWSystemItemMotion.h
//  HmiPad
//
//  Created by Joan Martin on 9/4/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWSystemItem.h"

#import <CoreMotion/CoreMotion.h>

@class SWValue;

@interface SWSystemItemMotionLowLevel : SWSystemItem

// accelerometre
@property (nonatomic, readonly) SWValue *ax;
@property (nonatomic, readonly) SWValue *ay;
@property (nonatomic, readonly) SWValue *az;

// giroscopi
@property (nonatomic, readonly) SWValue *gx;
@property (nonatomic, readonly) SWValue *gy;
@property (nonatomic, readonly) SWValue *gz;

// flags de disponibilitat
@property (nonatomic, readonly) SWValue *availabilityFlags;



@end
