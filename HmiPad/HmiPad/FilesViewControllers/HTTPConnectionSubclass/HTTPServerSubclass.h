//
//  HTTPServerSubclass.h
//  ScadaMobile_100704b
//
//  Created by Joan on 08/07/10.
//  Copyright 2010 SweetWilliam, S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPServer.h"

@class Reachability ;



//----------------------------------------------------------------------------------------
/*
@protocol HTTPServerSubclassOwner<NSObject>

- (void)httpServerSubclassReachabilityError:(NSError *)error ;
- (void)netServiceDidPublish:(NSNetService *)ns ;
- (void)netService:(NSNetService *)ns didNotPublish:(NSDictionary *)errorDict ;

@end
*/

//----------------------------------------------------------------------------------------
@interface HTTPServerSubclass : HTTPServer
{
    //id<HTTPServerSubclassOwner> theOwner ; //weak
    Reachability *reachability ; // weak (shared reachability)
    BOOL isStarted ;
}

@property (nonatomic,readonly) BOOL isStarted ;
//- (id) initWithOwner:(id<HTTPServerSubclassOwner>)owner reachability:(Reachability*)aReach;
//- (void)netServiceDidPublish:(NSNetService *)ns;
//- (void)netService:(NSNetService *)ns didNotPublish:(NSDictionary *)errorDict;

@end


extern NSString *kHTTPServerReachabilityErrorNotification ;
extern NSString *kHTTPServerServiceDidPublishNotification ;
extern NSString *kHTTPServerServiceDidNotPublishNotification ;
extern NSString *kHTTPServerDidExecuteStartNotification ;
extern NSString *kHTTPServerDidStopNotification ;

