//
//  SWSystemItmemSystem.h
//  HmiPad
//
//  Created by Joan on 31/08/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWSystemItem.h"


enum SWCommStateValues
{
    kCommStateLinked = 0,
    kCommStateStop = 1,
    kCommStatePartialLink = 2,
    kCommStateError = 3,
};

//------------------------------------------------------------------------------------
enum CommRouteValues
{
    kCommRouteNoRemote = 0,
    kCommRouteAllLocalNoRemote = 1,
    kCommRouteSomeRemote = 2,
    kCommRouteAllRemote = 3,
};


@interface SWSystemItemSystem : SWSystemItem

@property (nonatomic,readonly) SWValue *pulse1Expression;
@property (nonatomic,readonly) SWValue *pulse10Expression;
@property (nonatomic,readonly) SWValue *pulse30Expression;
@property (nonatomic,readonly) SWValue *pulse60Expression;
@property (nonatomic,readonly) SWValue *dateTimeExpression;
@property (nonatomic,readonly) SWValue *absoluteTimeExpression;
@property (nonatomic,readonly) SWValue *commStateExpression;
@property (nonatomic,readonly) SWValue *commRouteExpression;
@property (nonatomic,readonly) SWValue *networkNameExpression;
@property (nonatomic,readonly) SWValue *networkBSSIDExpression;
@property (nonatomic,readonly) SWValue *currentUserAccessLevelExpression;
@property (nonatomic,readonly) SWValue *currentUserNameExpression;
@property (nonatomic,readonly) SWValue *interfaceOrientationExpression;
@property (nonatomic,readonly) SWValue *interfaceIdiomExpression;

@property (nonatomic,readonly) SWValue *pulseOnceExpression;
//@property (nonatomic,readonly) SWValue *connectedNetworkExpression;

- (void)updateInterfaceIdiomIfNeeded; // <- explicit rather than observing

@end
