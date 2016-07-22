//
//  Reachability.h
//  ScadaMobile_090714
//
//  Created by Joan on 15/07/09.
//  Copyright 2009 SweetWilliam, S.L.. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <SystemConfiguration/SystemConfiguration.h>
#import <SystemConfiguration/SCNetworkReachability.h>


// Tipus de reachabilitat. Son mutuament excluyents
typedef enum
{
    kNoReachability = 0,
    kWiFiReachability,
    kWWANReachability
} ReachabilityStatus ;


// Objecte Reachability
@interface Reachability : NSObject 

{
    SCNetworkReachabilityRef reachability ;
    ReachabilityStatus status ;
    ReachabilityStatus previousStatus ;
}

// acces a l'objecte unic compartit
+(Reachability *)sharedReachability ;

// utilitzar aquesta per determinar la reachabilitat actual
-(ReachabilityStatus)status ;

// utilitzar aquesta per determinar la reachabilitat que hi havia just abans d'un canvi
-(ReachabilityStatus)previousStatus ;


@end

// Envia una notificació amb aquest nom quan la reachabilitat canvia de status
// Les classes interesades s'han de subscriure
extern NSString *kReachabilityChangedNotification ;
