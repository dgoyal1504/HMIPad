//
//  AppModelFileServer.h
//  HmiPad
//
//  Created by Joan Lluch on 12/04/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//


#import "AppModel.h"

@class HTTPServerSubclass;

@interface AppModelFileServer:NSObject

@property (nonatomic, readonly) HTTPServerSubclass *httpServer ;
- (void)startHttpServer:(NSError **)outError ;
- (void)stopHttpServer;

@end
