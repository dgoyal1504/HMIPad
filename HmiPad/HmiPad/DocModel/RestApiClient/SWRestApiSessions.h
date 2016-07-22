//
//  SWRestApiSessions.h
//  HmiPad
//
//  Created by joan on 09/05/15.
//  Copyright (c) 2015 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>


@class SWDocumentModel;

@interface SWRestApiSessions : NSObject

- (id)initInDocumentModel:(SWDocumentModel*)docModel;

@property( nonatomic, readonly) SWDocumentModel *docModel;
- (NSURLSession *)restSessionWithBaseUrl:(NSString*)baseUrl;

@end


@interface SWRestApiSessions(subclassingHooks)

- (NSURLSession*)sessionForKey:(NSString*)key;
- (void)addSession:(NSURLSession*)restSession withKey:(NSString*)key;
- (void)removeSessionWithKey:(NSString*)key;

@end