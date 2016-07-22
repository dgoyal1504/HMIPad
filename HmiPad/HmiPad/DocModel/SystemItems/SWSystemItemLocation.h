//
//  SWSystemItemLocation.h
//  HmiPad
//
//  Created by Joan Martin on 9/3/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWSystemItem.h"

#import <CoreLocation/CoreLocation.h>

@interface SWSystemItemLocation : SWSystemItem <CLLocationManagerDelegate>

@property (nonatomic,readonly) SWValue *latitude;
@property (nonatomic,readonly) SWValue *longitude;
@property (nonatomic,readonly) SWValue *altitude;
@property (nonatomic,readonly) SWValue *horizontalAccuracy;
@property (nonatomic,readonly) SWValue *verticalAccuracy;
@property (nonatomic,readonly) SWValue *speed;
@property (nonatomic,readonly) SWValue *course;

@property (nonatomic,readonly) SWValue *magneticNorth;
@property (nonatomic,readonly) SWValue *trueNorth;
@property (nonatomic,readonly) SWValue *headingAccuracy;

@end
