//
//  SWSystemItemSystem.m
//  HmiPad
//
//  Created by Joan on 31/08/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <SystemConfiguration/CaptiveNetwork.h>

#import "Reachability.h"

#import "SWSystemItemSystem.h"
#import "SWPropertyDescriptor.h"
#import "SWSourceItem.h"
#import "SWDocumentModel.h"
#import "UserDefaults.h"
#import "AppUsersModel.h"

static inline CFAbsoluteTime roundedAbsoluteTime()
{
    CFAbsoluteTime x = CFAbsoluteTimeGetCurrent();
    return 0.5*trunc(x*2);
}

@implementation SWSystemItemSystem
{
    struct
    {
        unsigned int pulseOnce:1;
        unsigned int pulse1:1;
        unsigned int pulse10:1;
        unsigned int pulse30:1;
        unsigned int pulse60:1;
        unsigned int dateTime:1;
        unsigned int absoluteTime:1;
        unsigned int commState:1;
        unsigned int commRoute:1;
        unsigned int networkName:1;
        unsigned int networkBSSID:1;
        unsigned int accessLevel:1;
        unsigned int userName:1;
        unsigned int interfaceOrientation:1;
        unsigned int interfaceIdiom:1;
    } _active;
    
    dispatch_source_t _pulse1Source;
    int _pulse1Count;
    CFDateFormatterRef _dateFormatter;
    
    BOOL _isObservingComms;
    Reachability *_reachability;
    BOOL _isObservingUsers;
    BOOL _isObservingOrientation;
    BOOL _isObservingIdiom;
}

static SWObjectDescription *_objectDescription = nil;

+ (SWObjectDescription *)objectDescription
{
    if(_objectDescription == nil) {
        _objectDescription = [[SWObjectDescription alloc] initWithObjectClass:[self class]];
    }
    return _objectDescription;
}

+ (NSString*)defaultIdentifier
{
    return @"$System";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"SYSTEM EXPRESSIONS", nil);
}

+ (NSArray*)propertyDescriptions
{
    SWDeviceInterfaceIdiom defaultIdiom = (HMiPadRun&&IS_IPHONE)?SWDeviceInterfaceIdiomPhone:SWDeviceInterfaceIdiomPad;
    
    int swIdiom = 0;
    if ( defaultIdiom == SWDeviceInterfaceIdiomPad ) swIdiom = 1;
    else if ( defaultIdiom == SWDeviceInterfaceIdiomPhone ) swIdiom = 2;
    
    return [NSArray arrayWithObjects:
    
            [SWPropertyDescriptor propertyDescriptorWithName:@"pulseOnce" type:SWTypeBool
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
    
            [SWPropertyDescriptor propertyDescriptorWithName:@"pulse1s" type:SWTypeBool
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
                
            [SWPropertyDescriptor propertyDescriptorWithName:@"pulse10s" type:SWTypeBool
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
                
            [SWPropertyDescriptor propertyDescriptorWithName:@"pulse30s" type:SWTypeBool
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
                
            [SWPropertyDescriptor propertyDescriptorWithName:@"pulse60s" type:SWTypeBool
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
                
//            [SWPropertyDescriptor propertyDescriptorWithName:@"$SMAckButton" type:SWTypeBool
//                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:0.0]],
                
            [SWPropertyDescriptor propertyDescriptorWithName:@"date" type:SWTypeString
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithString:@""]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"absoluteTime" type:SWTypeDouble
                propertyType:SWPropertyTypeNoEditableValue
                defaultValue:[SWValue valueWithAbsoluteTime:roundedAbsoluteTime()]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"commState" type:SWTypeInteger
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"commRoute" type:SWTypeInteger
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"networkName" type:SWTypeString
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithString:@""]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"networkBSSID" type:SWTypeString
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithString:@""]],

            [SWPropertyDescriptor propertyDescriptorWithName:@"currentUserAccessLevel" type:SWTypeInteger
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
//            
//            [SWPropertyDescriptor propertyDescriptorWithName:@"$SMActiveAlarmCount" type:SWTypeInteger
//                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:0.0]],
//                
//            [SWPropertyDescriptor propertyDescriptorWithName:@"$SMUnacknowledgedAlarmCount" type:SWTypeInteger
//                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:0.0]],
//                
//            [SWPropertyDescriptor propertyDescriptorWithName:@"$SMCurrentPageName" type:SWTypeString
//                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithString:@""]],
                
            [SWPropertyDescriptor propertyDescriptorWithName:@"currentUserName" type:SWTypeString
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithString:@""]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"interfaceOrientation" type:SWTypeInteger
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"interfaceIdiom" type:SWTypeInteger
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:swIdiom]],
            
            nil];
}

#pragma mark - Properties

- (SWValue*)pulseOnceExpression
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+0];
}

- (SWValue*)pulse1Expression
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+1];
}

- (SWValue*)pulse10Expression
{    
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+2];
}

- (SWValue*)pulse30Expression
{    
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+3];
}

- (SWValue*)pulse60Expression
{    
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+4];
}

//- (SWValue*)ackExpression
//{
//    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+4];
//}

- (SWValue*)dateTimeExpression
{    
    return  [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+5];
}

- (SWValue*)absoluteTimeExpression
{    
    return  [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+6];
}

- (SWValue*)commStateExpression
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+7];
}

- (SWValue*)commRouteExpression
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+8];
}

- (SWValue*)networkNameExpression
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+9];
}

- (SWValue*)networkBSSIDExpression
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+10];
}

- (SWValue*)currentUserAccessLevelExpression
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+11];
}

//- (SWValue*)activeAlarmCountExpression
//{
//    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+8];
//}
//
//- (SWValue*)unacknowledgedAlarmCountExpression
//{
//    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+9];
//}
//

- (SWValue*)currentUserNameExpression
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+12];
}

- (SWValue*)interfaceOrientationExpression
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+13];
}

- (SWValue*)interfaceIdiomExpression
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex+14];
}

#pragma mark - init, dealloc

- (void)_delayedNormalEnd:(id)dummy
{
    [self.pulseOnceExpression evalWithDouble:0.0];
}

- (void)_performPulseOnce
{
    [self.pulseOnceExpression evalWithDouble:1.0];
    [self performSelector:@selector(_delayedNormalEnd:) withObject:nil afterDelay:0.0];
}


- (void)_pulseOnceAfterInit
{
    // dispatchem el pulse once per asegurarnos que el graph d'expressions esta completament carregat
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self _performPulseOnce];
    }) ;

}

- (id)initInDocument:(SWDocumentModel *)docModel
{
    self = [super initInDocument:docModel];
    if ( self )
    {
        [self _pulseOnceAfterInit];
    }
    return self;
}


- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super initWithQuickCoder:decoder];
    if ( self )
    {
        [self _pulseOnceAfterInit];
    }
    return self;
}


- (id)initWithSymbolicCoder:(SymbolicUnarchiver *)decoder identifier:(NSString *)ident parentObject:(id<SymbolicCoding>)parent
{
    self = [super initWithSymbolicCoder:decoder identifier:ident parentObject:parent];
    if ( self )
    {
        [self _pulseOnceAfterInit];
    }
    return self;
}



- (void)dealloc
{
    //NSLog(@"SWSystemItemSystem dealloc");
    
    if(_pulse1Source)
        dispatch_source_cancel(_pulse1Source);
    
    if(_dateFormatter)
        CFRelease(_dateFormatter);
}

#pragma mark time/date Expressions

- (CFDateFormatterRef)_dateFormatter
{
    if(_dateFormatter == NULL)
    {
        _dateFormatter = CFDateFormatterCreate(NULL, NULL, kCFDateFormatterNoStyle, kCFDateFormatterNoStyle);
        //CFDateFormatterSetFormat(dateFormatter, CFSTR("yyyy-MM-dd HH:mm:ss ZZ"));
        CFDateFormatterSetFormat(_dateFormatter, CFSTR("yyyy-MM-dd HH:mm:ss"));
    }
    return _dateFormatter;
}

#pragma mark pulseExpressions


- (void)_evalPulseExpressionsIfNeeded
{
    _pulse1Count += 5; // decimes de segon
    
    // pulse 1
    if(_active.pulse1 && _pulse1Count%5 == 0) // cada 0.5 segons fa un canvi, es a dir el periode es 1
    {
        [self.pulse1Expression evalWithDouble:(_pulse1Count%10)!=0];
    }
    
    // pulse 10
    if(_active.pulse10 && _pulse1Count%50 == 0) // cada 5 segons fa un canvi, es a dir el periode es 10
    {
        [self.pulse10Expression evalWithDouble:(_pulse1Count%100)!=0];
    }

    // pulse 30
    if(_active.pulse30 && _pulse1Count%150 == 0) 
    {
        [self.pulse30Expression evalWithDouble:(_pulse1Count%300)!=0];
    }
    
    // pulse 60
    if(_active.pulse60 && _pulse1Count%300 == 0) 
    {
        [self.pulse60Expression evalWithDouble:(_pulse1Count%600)!=0];
    }
    
    // date/time
    if ( _active.dateTime || _active.absoluteTime )
    {
        if ( _pulse1Count%5 == 0 )
        {
            CFAbsoluteTime timeStamp = roundedAbsoluteTime();
            if( _active.absoluteTime )
            {
                [self.absoluteTimeExpression evalWithAbsoluteTime:timeStamp];
            }
            
            if( _active.dateTime && _pulse1Count%10 == 0 )
            {
                CFStringRef dateFormatedStr = CFDateFormatterCreateStringWithAbsoluteTime(NULL, [self _dateFormatter], timeStamp);
                [self.dateTimeExpression evalWithString:(__bridge NSString*)dateFormatedStr];
                CFRelease(dateFormatedStr);
            }
        }
    }
    
    
//    if(_active.dateTime && _pulse1Count%10 == 0)
//    {
//        CFAbsoluteTime timeStamp = roundedAbsoluteTime();
//        CFStringRef dateFormatedStr = CFDateFormatterCreateStringWithAbsoluteTime(NULL, [self _dateFormatter], timeStamp);
//        
//    
//        [self.dateTimeExpression evalWithString:(__bridge NSString*)dateFormatedStr];
//
//        CFRelease(dateFormatedStr);
//        //CFRelease(date);
//    }
//    
//    // absoluteTime
//    if(_active.absoluteTime && _pulse1Count%5 == 0)
//    {
//        CFAbsoluteTime timeStamp = roundedAbsoluteTime();
//        [self.absoluteTimeExpression evalWithAbsoluteTime:timeStamp+NSTimeIntervalSince1970];
//    }
}

- (void)_maybeStartPulse1Timer
{
//    NSLog(@"_active.pulse1 :%d", _active.pulse1);
//    NSLog(@"_active.pulse10 :%d", _active.pulse10);
//    NSLog(@"_active.pulse30 :%d", _active.pulse30);
//    NSLog(@"_active.pulse60 :%d", _active.pulse60);
//    NSLog(@"_active.pulse.dateTime :%d", _active.dateTime);
    
    if (!(_active.pulse1 || _active.pulse10 || _active.pulse30 || _active.pulse60 || _active.dateTime || _active.absoluteTime))
        return;
    
    if (_pulse1Source == NULL)
    {
        _pulse1Source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    
        //dispatch_source_t thePulse1Source = _pulse1Source;
        //__unsafe_unretained id theSelf = self;// evitem el retain cycle entre pulse1Source i el self, en el dealloc eliminem el pulse1Source
        __weak id theSelf = self;
        dispatch_source_set_event_handler(_pulse1Source,
        ^{
            @autoreleasepool {
                [theSelf _evalPulseExpressionsIfNeeded];
            }
        });

        dispatch_source_set_cancel_handler(_pulse1Source, 
        ^{
            //IOS6 dispatch_release(thePulse1Source);
            
        });
    
        dispatch_resume(_pulse1Source);
        dispatch_source_set_timer(_pulse1Source, DISPATCH_TIME_NOW, NSEC_PER_SEC/2, 0);      // 0.5 seg
        _pulse1Count = 0;
    }
}

- (void)_maybeStopPulse1Timer
{
    if (_active.pulse1 || _active.pulse10 || _active.pulse30 || _active.pulse60 || _active.dateTime || _active.absoluteTime)
        return;
    
    if (_pulse1Source)
    {
        dispatch_source_cancel(_pulse1Source);
        _pulse1Source = NULL;
    }
}

#pragma mark protocol ValueHolder

// Torna la expressio corresponent segons el id que es un NSString
- (SWValue *)valueWithSymbol:(NSString *)sym property:(NSString *)property
{
    if ( property == nil)
        return nil;
    
    SWValue *value = [super valueWithSymbol:sym property:property];
    return value;
}


- (void)valuePerformRetain:(SWValue *)value
{
    if(_active.pulse1 == 0 && value == self.pulse1Expression) _active.pulse1 = 1;
    if(_active.pulse10 == 0 && value == self.pulse10Expression) _active.pulse10 = 1;
    if(_active.pulse30 == 0 && value == self.pulse30Expression) _active.pulse30 = 1;
    if(_active.pulse60 == 0 && value == self.pulse60Expression) _active.pulse60 = 1;
    if(_active.dateTime == 0 && value == self.dateTimeExpression) _active.dateTime = 1;
    if(_active.absoluteTime == 0 && value == self.absoluteTimeExpression) _active.absoluteTime = 1;
    [self _maybeStartPulse1Timer];
    
    if(_active.commState == 0 && value == self.commStateExpression ) _active.commState = 1;
    if(_active.commRoute == 0 && value == self.commRouteExpression ) _active.commRoute = 1;
    [self _maybeStartObservingComms];
    
    if(_active.networkName == 0 && value == self.networkNameExpression) _active.networkName = 1;
    if(_active.networkBSSID == 0 && value == self.networkBSSIDExpression) _active.networkBSSID = 1;
    [self _maybeStartObservingNetwork];
    
    if(_active.accessLevel == 0 && value == self.currentUserAccessLevelExpression) _active.accessLevel = 1;
    if(_active.userName == 0 && value == self.currentUserNameExpression) _active.userName = 1;
    [self _maybeStartObservingCurrentUser];
    
    if(_active.interfaceOrientation == 0 && value == self.interfaceOrientationExpression) _active.interfaceOrientation = 1;
    [self _maybeStartObservingInterfaceOrientation];
    
    if(_active.interfaceIdiom == 0 && value == self.interfaceIdiomExpression) _active.interfaceIdiom = 1;
    [self _maybeStartObservingInterfaceIdiom];
}


- (void)valuePerformRelease:(SWValue *)value
{
    if(_active.pulse1 && value == self.pulse1Expression) _active.pulse1 = 0;
    if(_active.pulse10 && value == self.pulse10Expression) _active.pulse10 = 0;
    if(_active.pulse30 && value == self.pulse30Expression) _active.pulse30 = 0;
    if(_active.pulse60 && value == self.pulse60Expression) _active.pulse60 = 0;
    if(_active.dateTime && value == self.dateTimeExpression) _active.dateTime = 0;
    if(_active.absoluteTime && value == self.absoluteTimeExpression) _active.absoluteTime = 0;
    [self _maybeStopPulse1Timer];
    
    if(_active.commState && value == self.commStateExpression) _active.commState = 0;
    if(_active.commRoute && value == self.commStateExpression) _active.commRoute = 0;
    [self _maybeStopObservingComms];
    
    if(_active.networkName && value == self.networkNameExpression) _active.networkName = 0;
    if(_active.networkBSSID && value == self.networkBSSIDExpression) _active.networkBSSID = 0;
    [self _maybeStopObservingNetwork];
    
    if(_active.accessLevel && value == self.currentUserAccessLevelExpression) _active.accessLevel = 0;
    if(_active.userName && value == self.currentUserNameExpression) _active.userName = 0;
    [self _maybeStopObservingCurrentUser];
    
    if(_active.interfaceOrientation && value == self.interfaceOrientationExpression) _active.interfaceOrientation = 0;
    [self _maybeStopObservingInterfaceOrientation];
    
    if(_active.interfaceIdiom && value == self.interfaceIdiomExpression) _active.interfaceIdiom = 0;
    [self _maybeStopObservingInterfaceIdiom];
}



#pragma mark commState-commRoute

//------------------------------------------------------------------------------------
//- (int)_getCommunicationsState
//{
//    int commState ;
//    BOOL monitorState = [defaults() monitoringState] ;
//    NSArray *soElements = [self sourceElements] ;
//    int totalErrors = 0 ;
//    int totalStarted = 0 ;
//    int totalLinked = 0 ;
//    int totalPlcSources = 0 ;
//    int totalLocal = 0;
//    int totalRemote = 0;
//    //int totalSources = [soElements count] ;  
//    if ( monitorState ) for ( SourceElement *sourceElement in soElements )
//    {
//        PlcDevice *plcDevice = [sourceElement plcDevice] ;
//        if ( [plcDevice plcProtocol] != kProtocolTypeNone )
//        {
//            if ( [sourceElement error] ) totalErrors += 1 ;
//            if ( [sourceElement plcObjectStarted] ) totalStarted += 1 ;
//            if ( [sourceElement plcObjectLinked] ) totalLinked += 1 ;
//            int route = [sourceElement plcObjectRoute];
//            if ( route == 1 ) totalLocal += 1;
//            if ( route == 2 ) totalRemote += 1;
//            totalPlcSources += 1 ;
//        }
//    }
//
//    if ( ! monitorState ) commState = kCommStateStop ;
//    else if ( totalPlcSources > 0 && totalErrors == totalPlcSources /*totalStarted*/ ) commState = kCommStateError ;
//    else if ( totalLinked < totalStarted || totalErrors > 0 ) commState = kCommStatePartialLink ;
//    else commState = kCommStateLinked ;
//    
//    totalCommStarted = totalStarted ;
//    totalCommLinked = totalLinked ;
//    totalCommErrors = totalErrors ;
//    int route = 0;
//    if ( totalLocal>0 && totalLinked==totalLocal ) route = 1;
//    if ( totalRemote>0 ) route = 2;
//    if ( totalRemote>0 && totalLinked==totalRemote ) route = 3;
//    communicationsRoute = route;
//    
//    return commState ;
//}



//------------------------------------------------------------------------------------
- (void)_updateCommunicationExpressions
{
    NSArray *sourceItems = [_docModel sourceItems];

    int commState;
    int commRoute;
    int totalMonitor = 0;
    int totalErrors = 0;
    int totalStarted = 0;
    int totalLinked = 0;
    int totalPlcSources = 0;
    int totalLocal = 0;
    int totalRemote = 0;
    
    for ( SWSourceItem *sourceItem in sourceItems )
    {
        totalPlcSources += 1 ;
        BOOL monitorOn = sourceItem.monitorOn;
        if ( monitorOn )
        {
            totalMonitor +=1 ;
            if ( sourceItem.error ) totalErrors += 1;
            if ( sourceItem.plcObjectStarted) totalStarted += 1 ;
            if ( sourceItem.plcObjectLinked ) totalLinked += 1 ;
            int route = sourceItem.plcObjectRoute;
            if ( route == 1 ) totalLocal += 1;
            if ( route == 2 ) totalRemote += 1;
        }
    }

    if ( totalMonitor == 0 ) commState = kCommStateStop ;
    else if ( totalPlcSources > 0 && totalErrors == totalPlcSources ) commState = kCommStateError ;
    else if ( totalLinked < totalStarted || totalErrors > 0 ) commState = kCommStatePartialLink ;
    else commState = kCommStateLinked ;
    
    commRoute = kCommRouteNoRemote;
    if ( totalLocal>0 && totalLinked==totalLocal ) commRoute = kCommRouteAllLocalNoRemote;
    if ( totalRemote>0 ) commRoute = kCommRouteSomeRemote;
    if ( totalRemote>0 && totalLinked==totalRemote ) commRoute = kCommRouteAllRemote;
    
    /*if (_active.commState)*/ [self.commStateExpression evalWithDouble:(double)commState];
    /*if (_active.commRoute)*/ [self.commRouteExpression evalWithDouble:(double)commRoute];
}


- (void)_commStateChangeNotification:(NSNotification*)note
{
//    SWSourceItem *sourceItem = (id)note.object;
//    NSLog( @"comstate changed for source Item: %@", sourceItem );
    [self _updateCommunicationExpressions];
}


- (void)_maybeStartObservingComms
{
    if ( !(_active.commState || _active.commRoute) ) return;
    if ( !_isObservingComms )
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(_commStateChangeNotification:) name:kFinsStateDidChangeNotification object:nil];
        _isObservingComms = YES;
    }
    [self _updateCommunicationExpressions];
}

- (void)_maybeStopObservingComms
{
    if ( _active.commState || _active.commRoute ) return;
    if ( _isObservingComms )
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self name:kFinsStateDidChangeNotification object:nil];
        _isObservingComms = NO;
    }
}



#pragma mark connectedNetwork


- (void)_fetchSSID:(NSString**)bssid name:(NSString**)name
{
    NSArray *ifs = (id)CFBridgingRelease(CNCopySupportedInterfaces());
    //NSLog(@"Supported interfaces: %@", ifs);
    
    NSDictionary *infoDict = nil;
    //NSString *bssid = nil;
    
    for (NSString *ifnam in ifs)
    {
        infoDict = (id)CFBridgingRelease(CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam));
        if ( [ifnam isEqualToString:@"en0"] )
        {
            *bssid = [infoDict objectForKey:@"BSSID"];
            *name = [infoDict objectForKey:@"SSID"];
        }
    }
 }


- (void)_updateConnectedNetwork
{
// busquem els estats
    ReachabilityStatus status = [_reachability status] ;
    
    NSString *bssid = nil;
    NSString *name = @"";
    if ( status == kWiFiReachability )
    {
        [self _fetchSSID:&bssid name:&name];
    }
    else if ( status == kWWANReachability )
    {
        bssid = @"WAN";
  //      CTTelephonyNetworkInfo
  //      CTCarrier
    }
    else if ( status == kNoReachability )
    {
        bssid = @"NONE";
    }
    
    if ( bssid == nil )
    {
        bssid = @"UNKNOWN";
    }

    /*if (_active.networkName)*/ [self.networkNameExpression evalWithString:name];
    /*if (_active.networkBSSID)*/ [self.networkBSSIDExpression evalWithString:bssid];
}


- (void)_connectedNetworkChangeNotification:(NSNotification*)notification
{
    NSAssert( _reachability == [notification object], @"L'objecte reachabilitat no es el mateix?!" ) ;
    [self _updateConnectedNetwork];
}


- (void)_maybeStartObservingNetwork
{
    if ( !(_active.networkBSSID || _active.networkName) ) return;
    if ( _reachability == nil )
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(_connectedNetworkChangeNotification:) name:kReachabilityChangedNotification object:nil];
        _reachability = [Reachability sharedReachability];
    }
    [self _updateConnectedNetwork];
    
}


- (void)_maybeStopObservingNetwork
{
    if ( _active.networkBSSID || _active.networkName ) return;
    if ( _reachability )
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self name:kReachabilityChangedNotification object:nil];
        _reachability = nil;
    }
}




#pragma mark current user


- (void)_updateCurrentUserExpressions
{
    UserProfile *profile = [usersModel() currentUserProfile];
    /*if ( _active.accessLevel )*/ [self.currentUserAccessLevelExpression evalWithDouble:profile.level];
    /*if ( _active.userName )*/ [self.currentUserNameExpression evalWithString:profile.username];
}


- (void)_currentUserChangeNotification:(NSNotification*)note
{
    [self _updateCurrentUserExpressions];
}


- (void)_maybeStartObservingCurrentUser
{
    if ( !(_active.accessLevel || _active.userName) ) return;
    if ( !_isObservingUsers )
    {
        //NSLog( @"START CURRENT USER OBSERV");
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(_currentUserChangeNotification:) name:kCurrentUserDidChangeNotification object:nil];
        [self _updateCurrentUserExpressions];
        _isObservingUsers = YES;
    }
}


- (void)_maybeStopObservingCurrentUser
{
    if ( _active.accessLevel || _active.userName ) return;
    if ( _isObservingUsers )
    {
        //NSLog( @"STOP CURRENT USER OBSERV");
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self name:kCurrentUserDidChangeNotification object:nil];
        _isObservingUsers = NO;
    }
}


#pragma mark interface orientation


- (void)_updateInterfaceOrientationExpression
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    int swOrientation = 0;
    //[[UIDevice currentDevice] orientation];
    if ( UIInterfaceOrientationIsLandscape(orientation) ) swOrientation = 1;
    else if ( UIInterfaceOrientationIsPortrait(orientation) ) swOrientation = 2;
    /*if ( _active.interfaceOrientation )*/ [self.interfaceOrientationExpression evalWithDouble:swOrientation];
}


- (void)_interfaceOrientationChangeNotification:(NSNotification*)note
{
    [self _updateInterfaceOrientationExpression];
}


- (void)_maybeStartObservingInterfaceOrientation
{
    if ( !(_active.interfaceOrientation ) ) return;
    if ( !_isObservingOrientation )
    {
        //NSLog( @"START INTERFACE OBSERV");
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(_interfaceOrientationChangeNotification:)
            name:UIDeviceOrientationDidChangeNotification object:nil];
        [self _updateInterfaceOrientationExpression];
        _isObservingOrientation = YES;
    }
}


- (void)_maybeStopObservingInterfaceOrientation
{
    if ( _active.interfaceOrientation ) return;
    if ( _isObservingOrientation )
    {
        //NSLog( @"STOP INTERFACE OBSERV");
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
        _isObservingOrientation = NO;
    }
}


#pragma marc interface idiom

- (void)_updateInterfaceIdiomExpression
{
    SWDeviceInterfaceIdiom interfaceIdiom = [_docModel interfaceIdiom];
    int swIdiom = 0;
    if ( interfaceIdiom == SWDeviceInterfaceIdiomPad ) swIdiom = 1;
    else if ( interfaceIdiom == SWDeviceInterfaceIdiomPhone ) swIdiom = 2;
    [self.interfaceIdiomExpression evalWithDouble:swIdiom];
}

- (void)updateInterfaceIdiomIfNeeded
{
    if ( _isObservingIdiom )
        [self _updateInterfaceIdiomExpression];
}

- (void)_maybeStartObservingInterfaceIdiom
{
    if ( !(_active.interfaceIdiom ) ) return;
    if ( !_isObservingIdiom )
    {
        [self _updateInterfaceIdiomExpression];
        _isObservingIdiom = YES;
    }
}


- (void)_maybeStopObservingInterfaceIdiom
{
    if ( _active.interfaceIdiom ) return;
    if ( _isObservingIdiom )
    {
        _isObservingIdiom = NO;
    }
}




@end
