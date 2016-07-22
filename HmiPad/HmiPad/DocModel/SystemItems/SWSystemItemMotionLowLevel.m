//
//  SWSystemItemMotion.m
//  HmiPad
//
//  Created by Joan Martin on 9/4/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWSystemItemMotionLowLevel.h"

#import "SWPropertyDescriptor.h"

typedef enum {
    SWMotionTypeNoneAvailable =     0,
    SWMotionTypeGyroscope =         1<<0,
    SWMotionTypeAccelerometer =     1<<1,
} SWMotionTypeFlags;

struct
{
    unsigned int availability:1;
    
    unsigned int ax:1;
    unsigned int ay:1;
    unsigned int az:1;
    
    unsigned int gx:1;
    unsigned int gy:1;
    unsigned int gz:1;

} _active;


static NSOperationQueue *_operationQueue = nil;
static CMMotionManager *_motionManager = nil;

@implementation SWSystemItemMotionLowLevel
{
    SWMotionTypeFlags _motionTypeFlags;
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
    return @"$MotionLowLevel";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"LOW LEVEL SYSTEM MOTION", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
            [SWPropertyDescriptor propertyDescriptorWithName:@"availabilityFlags" type:SWTypeBool
                                                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],

            [SWPropertyDescriptor propertyDescriptorWithName:@"ax" type:SWTypeDouble
                                                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"ay" type:SWTypeDouble
                                                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"az" type:SWTypeDouble
                                                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
            

            [SWPropertyDescriptor propertyDescriptorWithName:@"gx" type:SWTypeDouble
                                                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"gy" type:SWTypeDouble
                                                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"gz" type:SWTypeDouble
                                                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
            
            nil];
}


//#warning Atencio aquests inits fallen si hi ha expressions conectades perque el model pot no estar complert en aquest punt
//- (id)initInDocument:(SWDocumentModel *)docModel
//{
//    self = [super initInDocument:docModel];
//    if (self)
//    {
//        [self _updateAvailability];
//    }
//    return self;
//}
//
//- (id)initForAddingToSystemTable:(SWSystemTable *)systemTable
//{
//    self = [super initForAddingToSystemTable:systemTable];
//    if (self)
//    {
//        [self _updateAvailability];
//    }
//    return self;
//}
//
//- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
//{
//    self = [super initWithQuickCoder:decoder];
//    if (self)
//    {
//        [self _updateAvailability];
//    }
//    return self;
//}
//
//- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString *)ident parentObject:(id<SymbolicCoding>)parent
//{
//    self = [super initWithSymbolicCoder:decoder identifier:ident parentObject:parent];
//    if (self)
//    {
//        [self _updateAvailability];
//    }
//    return self;
//}

- (void)dealloc
{
    //[self _disableUpdates];
    [_motionManager stopGyroUpdates];
    [_motionManager stopAccelerometerUpdates];
    _motionManager = nil;
}

#pragma mark Properties

- (SWValue*)availabilityFlags
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

- (SWValue*)ax
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}

- (SWValue*)ay
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 2];
}

- (SWValue*)az
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 3];
}

- (SWValue*)gx
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 4];
}

- (SWValue*)gy
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 5];
}

- (SWValue*)gz
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 6];
}



#pragma mark Private Methods

- (CMMotionManager*)motionManager
{
    if (!_motionManager)
    {
        _motionManager = [[CMMotionManager alloc] init];
    }
    
    return _motionManager;
}

- (NSOperationQueue*)operationQueue
{
    if (!_operationQueue)
        _operationQueue = [[NSOperationQueue alloc] init];
    
    return _operationQueue;
}

//- (BOOL)_isActive
//{
//    BOOL active = NO;
//    
//    if (_active.x || _active.y || _active.z)
//        active = YES;
//    
//    return active;
//}
//
//- (void)_refreshManagerUpdatesState
//{
//    if ([self _motionAvailable])
//        [self _updatesActives:[self _isActive]];
//}
//
//- (void)_disableUpdates
//{
//    [self _updatesActives:NO];
//}

//- (void)_updatesActives:(BOOL)flag
//{
//    
//    CMMotionManager *motionManager = self.motionManager;
//
//    if (_motionType&SWMotionTypeAccelerometer)
//    {
//        if ( flag )
//        {
//            [motionManager startAccelerometerUpdatesToQueue:[self operationQueue]
//                                                           withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
//                                                               if (!error)
//                                                               {
//                                                                   CMAcceleration acceleration = accelerometerData.acceleration;
//                                                                   [self _updateValuesFromValuesX:acceleration.x Y:acceleration.y Z:acceleration.z];
//                                                               }
//                                                               else
//                                                               {
//                                                                   NSLog(@"[ikd921] Error en la lectura del accelerometre");
//                                                                   // S'ha d'invalidar els values
//                                                               }
//                                                           }];
//        }
//        else
//        {
//            [motionManager stopAccelerometerUpdates];
//        }
//                
//    }
//
//    if ( _motionType&SWMotionTypeGyroscope)
//    {
//        if ( flag )
//        {
//            [[self motionManager] startGyroUpdatesToQueue:[self operationQueue]
//                                                  withHandler:^(CMGyroData *gyroData, NSError *error) {
//                                                      if (!error)
//                                                      {
//                                                          CMRotationRate rate = gyroData.rotationRate;
//                                                          [self _updateValuesFromValuesX:rate.x Y:rate.y Z:rate.z];
//                                                      }
//                                                      else
//                                                      {
//                                                          NSLog(@"[ikd921] Error en la lectura del accelerometre");
//                                                      }
//                                                  }];
//        }
//        else
//        {
//            [motionManager stopGyroUpdates];
//        }
//    }
//}




- (void)_maybeStartUpdating
{
    CMMotionManager *motionManager = self.motionManager;
    _motionTypeFlags = [self _availableMotionTypes];
    
    if ( _active.availability )
    {
        [self _updateAvailability];
    }
    

    if (_motionTypeFlags&SWMotionTypeAccelerometer)
    {
        if ( _active.ax || _active.ay || _active.az )
        {
            [motionManager startAccelerometerUpdatesToQueue:[self operationQueue]
                                                           withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                                               if (!error)
                                                               {
                                                                   CMAcceleration acceleration = accelerometerData.acceleration;
                                                                   [self _updateAccelerometerValuesFromValuesX:acceleration.x Y:acceleration.y Z:acceleration.z];
                                                               }
                                                               else
                                                               {
                                                                   NSLog(@"[ikd921] Error en la lectura del accelerometre");
                                                                   // S'ha d'invalidar els values
                                                               }
                                                           }];
        }
    }

    if ( _motionTypeFlags&SWMotionTypeGyroscope)
    {
        if ( _active.gx || _active.gy || _active.gz )
        {
            [motionManager startGyroUpdatesToQueue:[self operationQueue]
                                                  withHandler:^(CMGyroData *gyroData, NSError *error) {
                                                      if (!error)
                                                      {
                                                          CMRotationRate rate = gyroData.rotationRate;
                                                          [self _updateGiroscopeValuesFromValuesX:rate.x Y:rate.y Z:rate.z];
                                                      }
                                                      else
                                                      {
                                                          NSLog(@"[ikd922] Error en la lectura del giroscopi");
                                                      }
                                                  }];
        }
    }
}


- (void)_maybeStopUpdating
{
    CMMotionManager *motionManager = self.motionManager;
    _motionTypeFlags = [self _availableMotionTypes];
    
    if ( !_active.availability )
    {
        [self _updateAvailability];
    }

    if (_motionTypeFlags&SWMotionTypeAccelerometer)
    {
        if ( !(_active.ax || _active.ay || _active.az) )
        {
            [motionManager stopAccelerometerUpdates];
        }
    }

    if ( _motionTypeFlags&SWMotionTypeGyroscope)
    {
        if ( !(_active.gx || _active.gy || _active.gz) )
        {
            [motionManager stopGyroUpdates];
        }
    }
}


- (SWMotionTypeFlags)_availableMotionTypes
{
    SWMotionTypeFlags motionTypes = SWMotionTypeNoneAvailable;
    CMMotionManager *motionManager = self.motionManager;
    
    if ([motionManager isGyroAvailable])
        motionTypes |= SWMotionTypeGyroscope;

    if ([motionManager isAccelerometerAvailable])
        motionTypes |= SWMotionTypeAccelerometer;
    
    return motionTypes;
}

- (void)_updateAccelerometerValuesFromValuesX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z
{
    dispatch_async(dispatch_get_main_queue(),
    ^{
        if ( _active.ax ) [self.ax evalWithDouble:x];
        if ( _active.ay ) [self.ay evalWithDouble:y];
        if ( _active.az ) [self.az evalWithDouble:z];
    });

}

- (void)_updateGiroscopeValuesFromValuesX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z
{
    dispatch_async(dispatch_get_main_queue(),
    ^{
        if ( _active.gx ) [self.gx evalWithDouble:x];
        if ( _active.gy ) [self.gy evalWithDouble:y];
        if ( _active.gz ) [self.gz evalWithDouble:z];
    });

}

- (void)_updateAvailability
{
    //_motionTypeFlags = [self _availableMotionTypes];
    [self.availabilityFlags evalWithDouble:_motionTypeFlags];
}
 
#pragma mark Protocol Value Holder

- (void)valuePerformRetain:(SWValue *)value
{
    if ( _active.availability == 0 && value == self.availabilityFlags ) _active.availability = 1;

    if (_active.ax == 0 && value == self.ax) _active.ax = 1;
    if (_active.ay == 0 && value == self.ay) _active.ay = 1;
    if (_active.az == 0 && value == self.az) _active.az = 1;
    
    if (_active.gx == 0 && value == self.gx) _active.gx = 1;
    if (_active.gy == 0 && value == self.gy) _active.gy = 1;
    if (_active.gz == 0 && value == self.gz) _active.gz = 1;
    
    [self _maybeStartUpdating];

//    if (value == self.x || value == self.y || value == self.z)
//        [self _refreshManagerUpdatesState];
}

- (void)valuePerformRelease:(SWValue*)value
{

    if ( _active.availability == 1 && value == self.availabilityFlags ) _active.availability = 0;

    if (_active.ax == 1 && value == self.ax) _active.ax = 0;
    if (_active.ay == 1 && value == self.ay) _active.ay = 0;
    if (_active.az == 1 && value == self.az) _active.az = 0;
    
    if (_active.gx == 1 && value == self.gx) _active.gx = 0;
    if (_active.gy == 1 && value == self.gy) _active.gy = 0;
    if (_active.gz == 1 && value == self.gz) _active.gz = 0;
    
    [self _maybeStopUpdating];
    
//    if (value == self.x || value == self.y || value == self.z)
//        [self _refreshManagerUpdatesState];
}

@end

