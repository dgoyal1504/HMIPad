//
//  SWSystemItemMotion.m
//  HmiPad
//
//  Created by Joan Martin on 9/4/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWSystemItemMotion.h"

#import "SWPropertyDescriptor.h"

struct
{
    unsigned int attitude:1;
    unsigned int gravity:1;
    unsigned int userAcceleration:1;
    unsigned int rotationRate:1;
    unsigned int magneticField:1;
} _active;


static NSOperationQueue *_operationQueue = nil;
static CMMotionManager *_motionManager = nil;

@implementation SWSystemItemMotion
{
    BOOL _isDeviceMotionActive;
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
    return @"$Motion";
}
 
+ (NSString*)localizedName
{
    return NSLocalizedString(@"SYSTEM MOTION", nil);
}

//+ (NSArray*)propertyDescriptionsV
//{
//    NSArray *array3d_1 = @[[SWValue valueWithDouble:0.0],[SWValue valueWithDouble:0.0],[SWValue valueWithDouble:0.0]];
//    NSArray *array3d_2 = @[[SWValue valueWithDouble:0.0],[SWValue valueWithDouble:0.0],[SWValue valueWithDouble:0.0]];
//    NSArray *array3d_3 = @[[SWValue valueWithDouble:0.0],[SWValue valueWithDouble:0.0],[SWValue valueWithDouble:0.0]];
//    NSArray *array3d_4 = @[[SWValue valueWithDouble:0.0],[SWValue valueWithDouble:0.0],[SWValue valueWithDouble:0.0]];
//    NSArray *array3d_5 = @[[SWValue valueWithDouble:0.0],[SWValue valueWithDouble:0.0],[SWValue valueWithDouble:0.0]];
//    
//    return [NSArray arrayWithObjects:
//            [SWPropertyDescriptor propertyDescriptorWithName:@"gravity" type:SWTypeDouble
//                                                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithArray:array3d_1]],
//            
//            [SWPropertyDescriptor propertyDescriptorWithName:@"userAcceleration" type:SWTypeDouble
//                                                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithArray:array3d_2]],
//            
//            [SWPropertyDescriptor propertyDescriptorWithName:@"accelerometerAvailable" type:SWTypeBool
//                                                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
//            
//            [SWPropertyDescriptor propertyDescriptorWithName:@"attitude" type:SWTypeDouble
//                                                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithArray:array3d_3]],
//            
//            [SWPropertyDescriptor propertyDescriptorWithName:@"rotationRate" type:SWTypeDouble
//                                                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithArray:array3d_4]],
//            
//            [SWPropertyDescriptor propertyDescriptorWithName:@"gyroscopeAvailable" type:SWTypeBool
//                                                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
//            
//            [SWPropertyDescriptor propertyDescriptorWithName:@"magneticField" type:SWTypeDouble
//                                                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithArray:array3d_5]],
//            
//            [SWPropertyDescriptor propertyDescriptorWithName:@"magnetomerAvailable" type:SWTypeBool
//                                                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
//            
//            nil];
//}


+ (NSArray*)propertyDescriptions
{    
    double arrayZero[3] = {0.0, 0.0, 0.0};
    
    
    return [NSArray arrayWithObjects:
    
            [SWPropertyDescriptor propertyDescriptorWithName:@"accelerometerAvailable" type:SWTypeBool
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"gravity" type:SWTypeDouble
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDoubles:arrayZero count:3]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"userAcceleration" type:SWTypeDouble
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDoubles:arrayZero count:3]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"gyroscopeAvailable" type:SWTypeBool
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"rotationRate" type:SWTypeDouble
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDoubles:arrayZero count:3]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"magnetomerAvailable" type:SWTypeBool
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"magneticField" type:SWTypeDouble
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDoubles:arrayZero count:3]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"attitude" type:SWTypeDouble
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDoubles:arrayZero count:3]],
            
            nil];
}


- (void)dealloc
{
    //[_motionManager stopDeviceMotionUpdates];
    //_motionManager = nil;
}

#pragma mark Properties

- (SWValue*)accelerometerAvailable
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

- (SWValue*)gravity
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}

- (SWValue*)userAcceleration
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 2];
}

- (SWValue*)gyroscopeAvailable
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 3];
}

- (SWValue*)rotationRate
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 4];
}


- (SWValue*)magnetomerAvailable
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 5];
}


- (SWValue*)magneticField
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 6];
}

- (SWValue*)attitude
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 7];
}

#pragma mark Private Methods

- (CMMotionManager*)motionManager
{
    if (!_motionManager)
    {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = 0.2; // <---------------- Cada 0.1 segons es farà el refresh
    }
    
    return _motionManager;
}

- (NSOperationQueue*)operationQueue
{
    if (!_operationQueue)
        _operationQueue = [[NSOperationQueue alloc] init];
    
    return _operationQueue;
}

- (BOOL)_shouldBeMotionDeviceActive
{
    return (_active.attitude || _active.gravity || _active.userAcceleration || _active.rotationRate || _active.magneticField);
}


- (void)_maybeStartObservingMotionUpdates
{
    if ( ! [self _shouldBeMotionDeviceActive] ) return;
    if ( !_isDeviceMotionActive )
    {
        _isDeviceMotionActive = YES;
        CMMotionManager *motionManager = [self motionManager];
        
        // La documentacio recomana no utilitzar la main queue per els updates, pero nosaltres necesitem enviarlos
        // directament als values que s'executen en el tread principal. Una alternativa seria augmentar la velocitat de
        // updates i promitjar els valors de manera que als values nomes hi passem valors filtrats
        //
        //  NSOperationQueue *operationQueue = [self operationQueue];    // <<- passar aixo al metode
        //
        //  dispatch_async(dispatch_get_main_queue(), ^{                 // <<-- utilitzar aixo en el handler
        //      // aqui filtrar els valor de motion i nomes passar els filtrats (menys sovint)
        //      [self _updateValuesFromDeviceMotion:motion];
        //  });
        
        NSOperationQueue *operationQueue = [NSOperationQueue mainQueue];
        [motionManager startDeviceMotionUpdatesToQueue:operationQueue withHandler:^(CMDeviceMotion *motion, NSError *error)
        {
            if (!error)
            {
                [self _updateValuesFromDeviceMotion:motion];
            }
            else
            {
                NSLog(@"[ak38df] Error in device motion lectures");
                // TODO: invalidar les expressions!
            }
        }];
        
        
        //NSLog( @"START DEVICE MOTION USER OBSERV");
    }
}


- (void)_maybeStopObservingMotionUpdates
{
    if ( [self _shouldBeMotionDeviceActive] ) return;
    if ( _isDeviceMotionActive )
    {
        _isDeviceMotionActive = NO;
        CMMotionManager *motionManager = [self motionManager];
        [motionManager stopDeviceMotionUpdates];
        _motionManager = nil;
        
        //NSLog( @"STOP DEVICE MOTION USER OBSERV");
    }
}


//- (void)_updateValuesFromDeviceMotionV:(CMDeviceMotion*)motion
//{
//    CMAcceleration gravity = motion.gravity;
//    SWValue *gravityValue = self.gravity;
//    [gravityValue evalWithArray:@[@(gravity.x),@(gravity.y),@(gravity.z)]];
//        
//    CMAcceleration userAcceleration = motion.userAcceleration;
//    SWValue *userAccelerationValue = self.userAcceleration;
//    [userAccelerationValue evalWithArray:@[@(userAcceleration.x),@(userAcceleration.y),@(userAcceleration.z)]];
//    
//    CMAttitude *attitude = motion.attitude;
//    SWValue *attitudeValue = self.attitude;
//    [attitudeValue evalWithArray:@[@(attitude.roll),@(attitude.pitch),@(attitude.yaw)]];
//    
//    CMRotationRate rotationRate = motion.rotationRate;
//    SWValue *rotationRateValue = self.rotationRate;
//    [rotationRateValue evalWithArray:@[@(rotationRate.x),@(rotationRate.y),@(rotationRate.z)]];
//    
//    CMCalibratedMagneticField calibratedMagneticField = motion.magneticField;
//    CMMagneticField magneticField = calibratedMagneticField.field;
////    CMMagneticFieldCalibrationAccuracy accuracy = calibratedMagneticField.accuracy; // <-------- Si volem, podem crear una value amb aquest paràmetre
//    SWValue *magneticFieldValue = self.magneticField;
//    [magneticFieldValue evalWithArray:@[@(magneticField.x),@(magneticField.y),@(magneticField.z)]];
//}


- (void)_updateValuesFromDeviceMotion:(CMDeviceMotion*)motion
{
    if ( _active.gravity )
    {
        CMAcceleration gravity = motion.gravity;
        double dgravity[3] = {gravity.x,gravity.y,gravity.z};
        [self.gravity evalWithDoubles:dgravity count:3];
    }
    
    if ( _active.userAcceleration )
    {
        CMAcceleration userAcceleration = motion.userAcceleration;
        double dacceleration[3] = {userAcceleration.x,userAcceleration.y,userAcceleration.z};
        [self.userAcceleration evalWithDoubles:dacceleration count:3];
    }
    
    if ( _active.attitude )
    {
        CMAttitude *attitude = motion.attitude;
        double dattitude[3] = {attitude.roll,attitude.pitch,attitude.yaw};
        [self.attitude evalWithDoubles:dattitude count:3];
    }
    
    if ( _active.rotationRate )
    {
        CMRotationRate rotationRate = motion.rotationRate;
        double drotationRate[3] = {rotationRate.x,rotationRate.y,rotationRate.z};
        [self.rotationRate evalWithDoubles:drotationRate count:3];
    }
    
    if ( _active.magneticField )
    {
        CMCalibratedMagneticField calibratedMagneticField = motion.magneticField;
        CMMagneticField magneticField = calibratedMagneticField.field;
        double dmagneticField[3] = {magneticField.x,magneticField.y,magneticField.z};
        [self.magneticField evalWithDoubles:dmagneticField count:3];
    }
    
//    CMMagneticFieldCalibrationAccuracy accuracy = calibratedMagneticField.accuracy; // <-------- Si volem, podem crear una value amb aquest paràmetre

}





#pragma mark Protocol Value Holder

- (void)valuePerformRetain:(SWValue *)value
{    
    if (value == self.accelerometerAvailable)
    {
        [self.accelerometerAvailable evalWithDouble:[[self motionManager] isAccelerometerAvailable]];
    }
    else if (value == self.gyroscopeAvailable)
    {
        [self.gyroscopeAvailable evalWithDouble:[[self motionManager] isGyroAvailable]];
    }
    else if (value == self.magnetomerAvailable)
    {
        [self.magnetomerAvailable evalWithDouble:[[self motionManager] isMagnetometerAvailable]];
    }
    else
    {
        if (_active.gravity == 0 && value == self.gravity) _active.gravity = 1;
        if (_active.userAcceleration == 0 && value == self.userAcceleration) _active.userAcceleration = 1;
        if (_active.attitude == 0 && value == self.attitude) _active.attitude = 1;
        if (_active.rotationRate == 0 && value == self.rotationRate) _active.rotationRate = 1;
        if (_active.magneticField == 0 && value == self.magneticField) _active.magneticField = 1;
        
        //[self _refreshManagerUpdatesState];
        [self _maybeStartObservingMotionUpdates];
    }
}

- (void)valuePerformRelease:(SWValue*)value
{
    if (value == self.accelerometerAvailable)
    {
        // Nothing to do
    }
    else if (value == self.gyroscopeAvailable)
    {
        // Nothing to do
    }
    else if (value == self.magnetomerAvailable)
    {
        // Nothing to do
    }
    else
    {
        if (_active.gravity == 1 && value == self.gravity) _active.gravity = 0;
        if (_active.userAcceleration == 1 && value == self.userAcceleration) _active.userAcceleration = 0;
        if (_active.attitude == 1 && value == self.attitude) _active.attitude = 0;
        if (_active.rotationRate == 1 && value == self.rotationRate) _active.rotationRate = 0;
        if (_active.magneticField == 1 && value == self.magneticField) _active.magneticField = 0;
        
        //[self _refreshManagerUpdatesState];
        [self _maybeStopObservingMotionUpdates];
    }
}

@end
