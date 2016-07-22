//
//  SWSystemItemLocation.m
//  HmiPad
//
//  Created by Joan Martin on 9/3/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWSystemItemLocation.h"
#import "SWPropertyDescriptor.h"

struct
{
    unsigned int longitude:1;
    unsigned int latitude:1;
    unsigned int altitude:1;
    unsigned int speed:1;
    unsigned int course:1;
    unsigned int verticalAccuracy:1;
    unsigned int horizontalAccuracy:1;
} _locationUpdatesActive;

struct
{
    unsigned int magneticNorth:1;
    unsigned int trueNorth:1;
    unsigned int headingAccuracy:1;
} _headingUpdatesActive;

static CLLocationManager *_locationManager = nil;

@implementation SWSystemItemLocation
{
    BOOL _isUpdatingLocation;
    BOOL _isUpdatingHeading;
}

static SWObjectDescription *_objectDescription = nil;

+ (SWObjectDescription *)objectDescription
{
    if ( _objectDescription == nil )
        _objectDescription = [[SWObjectDescription alloc] initWithObjectClass:[self class]];
    
    return _objectDescription;
}

+ (NSString*)defaultIdentifier
{
    return @"$Location";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"SYSTEM GPS & HEADING", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
    
            [SWPropertyDescriptor propertyDescriptorWithName:@"latitude" type:SWTypeDouble
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"longitude" type:SWTypeDouble
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"altitude" type:SWTypeDouble
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"horizontalAccuracy" type:SWTypeDouble
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"verticalAccuracy" type:SWTypeDouble
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"speed" type:SWTypeDouble
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"course" type:SWTypeDouble
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"magneticNorth" type:SWTypeDouble
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"trueNorth" type:SWTypeDouble
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"headingAccuracy" type:SWTypeDouble
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
            
            nil];
}

//- (id)initInDocument:(SWDocumentModel *)docModel
//{
//    self = [super initInDocument:docModel];
//    if (self)
//    {
//    
//    }
//    return self;
//}
//
//- (id)initForAddingToSystemTable:(SWSystemTable *)systemTable
//{
//    self = [super initForAddingToSystemTable:systemTable];
//    if (self)
//    {
//        
//    }
//    return self;
//}
//
//- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
//{
//    self = [super initWithQuickCoder:decoder];
//    if (self)
//    {
//    
//    }
//    return self;
//}
//
//- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString *)ident parentObject:(id<SymbolicCoding>)parent
//{
//    self = [super initWithSymbolicCoder:decoder identifier:ident parentObject:parent];
//    if (self)
//    {
//        
//    }
//    return self;
//}

- (void)dealloc
{
   // [self _disableUpdates];
    
    _locationManager.delegate = nil;
    _locationManager = nil;
}

#pragma mark Properties

- (SWValue*)latitude
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

- (SWValue*)longitude
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}

- (SWValue*)altitude
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 2];
}

- (SWValue*)horizontalAccuracy
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 3];
}

- (SWValue*)verticalAccuracy
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 4];
}

- (SWValue*)speed
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 5];
}

- (SWValue*)course
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 6];
}

- (SWValue*)magneticNorth
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 7];
}

- (SWValue*)trueNorth
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 8];
}

- (SWValue*)accuracy
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 9];
}

#pragma mark Private Methods

- (CLLocationManager*)locationManager
{
    if (!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    
    return _locationManager;
}

- (BOOL)_shouldBeActiveLocationUpdates
{
    BOOL active = NO;
    
    if (_locationUpdatesActive.latitude ||
        _locationUpdatesActive.longitude ||
        _locationUpdatesActive.altitude ||
        _locationUpdatesActive.speed ||
        _locationUpdatesActive.course ||
        _locationUpdatesActive.horizontalAccuracy ||
        _locationUpdatesActive.verticalAccuracy)
        active = YES;
    
    return active;
}

- (BOOL)_shouldBeActiveHeadingUpdates
{
    BOOL active = NO;
    
    if (_headingUpdatesActive.magneticNorth ||
        _headingUpdatesActive.trueNorth ||
        _headingUpdatesActive.headingAccuracy)
        active = YES;
    
    return active;
}


- (void)_maybeStartObservingLocation
{
    if ( ![self _shouldBeActiveLocationUpdates] ) return;
    if ( !_isUpdatingLocation )
    {
        CLLocationManager *manager = [self locationManager];
        [manager startUpdatingLocation];
        _isUpdatingLocation = YES;
    }
}


- (void)_maybeStopObservingLocation
{
    if ( [self _shouldBeActiveLocationUpdates] ) return;
    if ( _isUpdatingLocation )
    {
        [_locationManager stopUpdatingLocation];
        _isUpdatingLocation = NO;
    }
}


- (void)_maybeStartObservingHeading
{
    if ( ![self _shouldBeActiveHeadingUpdates] ) return;
    if ( !_isUpdatingHeading )
    {
        CLLocationManager *manager = [self locationManager];
        [manager startUpdatingHeading];
        _isUpdatingHeading = YES;
    }
}


- (void)_maybeStopObservingHeading
{
    if ( [self _shouldBeActiveHeadingUpdates] ) return;
    if ( _isUpdatingHeading )
    {
        [_locationManager stopUpdatingHeading];
        _isUpdatingHeading = NO;
    }
}


#pragma mark Protocol Value Holder

- (void)valuePerformRetain:(SWValue *)value
{
    if (_locationUpdatesActive.latitude == 0 && value == self.latitude) _locationUpdatesActive.latitude = 1;
    if (_locationUpdatesActive.longitude == 0 && value == self.longitude) _locationUpdatesActive.longitude = 1;
    if (_locationUpdatesActive.altitude == 0 && value == self.altitude) _locationUpdatesActive.altitude = 1;
    if (_locationUpdatesActive.speed == 0 && value == self.speed) _locationUpdatesActive.speed = 1;
    if (_locationUpdatesActive.course == 0 && value == self.course) _locationUpdatesActive.course = 1;
    if (_locationUpdatesActive.horizontalAccuracy == 0 && value == self.horizontalAccuracy) _locationUpdatesActive.horizontalAccuracy = 1;
    if (_locationUpdatesActive.verticalAccuracy == 0 && value == self.verticalAccuracy) _locationUpdatesActive.verticalAccuracy = 1;
    
    [self _maybeStartObservingLocation];
    
    if (_headingUpdatesActive.magneticNorth == 0 && value == self.magneticNorth) _headingUpdatesActive.magneticNorth = 1;
    if (_headingUpdatesActive.trueNorth == 0 && value == self.trueNorth) _headingUpdatesActive.trueNorth = 1;
    if (_headingUpdatesActive.headingAccuracy == 0 && value == self.headingAccuracy) _headingUpdatesActive.headingAccuracy = 1;

    [self _maybeStartObservingHeading];
    
}

- (void)valuePerformRelease:(SWValue*)value
{
    if (_locationUpdatesActive.latitude == 1 && value == self.latitude) _locationUpdatesActive.latitude = 0;
    if (_locationUpdatesActive.longitude == 1 && value == self.longitude) _locationUpdatesActive.longitude = 0;
    if (_locationUpdatesActive.altitude == 1 && value == self.altitude) _locationUpdatesActive.altitude = 0;
    if (_locationUpdatesActive.speed == 1 && value == self.speed) _locationUpdatesActive.speed = 0;
    if (_locationUpdatesActive.course == 1 && value == self.course) _locationUpdatesActive.course = 0;
    if (_locationUpdatesActive.horizontalAccuracy == 1 && value == self.horizontalAccuracy) _locationUpdatesActive.horizontalAccuracy = 0;
    if (_locationUpdatesActive.verticalAccuracy == 1 && value == self.verticalAccuracy) _locationUpdatesActive.verticalAccuracy = 0;
    
    [self _maybeStopObservingLocation];
    
    if (_headingUpdatesActive.magneticNorth == 1 && value == self.magneticNorth) _headingUpdatesActive.magneticNorth = 0;
    if (_headingUpdatesActive.trueNorth == 1 && value == self.trueNorth) _headingUpdatesActive.trueNorth = 0;
    if (_headingUpdatesActive.headingAccuracy == 1 && value == self.headingAccuracy) _headingUpdatesActive.headingAccuracy = 0;
    
    [self _maybeStopObservingHeading];
}

#pragma mark Protocol CLLocationManagerDelegate

// DEPRECATED
//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
//{
//    CLLocationCoordinate2D coordinate = newLocation.coordinate;
//    
//    [self.latitude evalWithDouble:coordinate.latitude];
//    [self.longitude evalWithDouble:coordinate.longitude];
//    [self.altitude evalWithDouble:newLocation.altitude];
//    [self.horizontalAccuracy evalWithDouble:newLocation.horizontalAccuracy];
//    [self.verticalAccuracy evalWithDouble:newLocation.verticalAccuracy];
//    [self.speed evalWithDouble:newLocation.speed];
//    [self.course evalWithDouble:newLocation.course];
//}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = locations.lastObject;
    CLLocationCoordinate2D coordinate = newLocation.coordinate;
    
    [self.latitude evalWithDouble:coordinate.latitude];
    [self.longitude evalWithDouble:coordinate.longitude];
    [self.altitude evalWithDouble:newLocation.altitude];
    [self.horizontalAccuracy evalWithDouble:newLocation.horizontalAccuracy];
    [self.verticalAccuracy evalWithDouble:newLocation.verticalAccuracy];
    [self.speed evalWithDouble:newLocation.speed];
    [self.course evalWithDouble:newLocation.course];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    [self.magneticNorth evalWithDouble:newHeading.magneticHeading];
    [self.trueNorth evalWithDouble:newHeading.trueHeading];
    [self.accuracy evalWithDouble:newHeading.headingAccuracy];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // TODO!
}


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    // TODO!
}


- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    // TODO!
}


- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    // TODO!
}


- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    // TODO!
}


- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    // TODO!
}


- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    // TODO!
}


- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    // TODO!
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    // TODO!
}

@end
