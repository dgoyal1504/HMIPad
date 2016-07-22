//
//  AppModelFileServer.m
//  HmiPad
//
//  Created by Joan Lluch on 12/04/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "AppModelFileServer.h"
#import "HTTPServerSubclass.h"

@implementation AppModelFileServer


#pragma mark Metodes del HTTPServerSubclass

////------------------------------------------------------------------
//- (HTTPServerSubclass *)httpServer
//{
//    return _httpServer;
//}

//---------------------------------------------------------------------------------------------
- (void)startHttpServer:(NSError **)outError 
{
	if ( !_httpServer ) _httpServer = [[HTTPServerSubclass alloc] init] ;
    [_httpServer start:outError] ;
}

//---------------------------------------------------------------------------------------------
- (void)stopHttpServer
{
	if (!_httpServer ) return ;
    [_httpServer stop] ;
    _httpServer = nil ;
}

@end
