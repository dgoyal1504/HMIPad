//
//  SWRestApiSessions.m
//  HmiPad
//
//  Created by joan on 09/05/15.
//  Copyright (c) 2015 SweetWilliam, SL. All rights reserved.
//

#import "SWRestApiSessions.h"



@interface SWRestApiSessions()<NSURLSessionDelegate>
{
    __weak SWDocumentModel *_docModel;
    NSMapTable *_sessionsDict;
}
@end

@implementation SWRestApiSessions

- (id)initInDocumentModel:(SWDocumentModel*)docModel
{
    self = [super init];
    {
        _docModel = docModel;
    }
    return self;
}



- (NSURLSession *)restSessionWithBaseUrl:(NSString*)baseUrl
{
    NSURLSession *restSession = [self sessionForKey:baseUrl];
    if ( restSession == nil )
    {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        restSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
        
        [self addSession:restSession withKey:baseUrl];
    }

    return restSession;
}



# pragma mark - Private

- (NSMapTable*)_sessionsDict
{
    if ( _sessionsDict == nil )
        _sessionsDict = [[NSMapTable alloc] initWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory capacity:0];
    
    return _sessionsDict;
}

@end



# pragma mark - Public

@implementation SWRestApiSessions(subclassingHooks)

- (NSURLSession*)sessionForKey:(NSString*)key;
{
    NSURLSession *restSession = [_sessionsDict objectForKey:key];
    return restSession;
}


- (void)addSession:(NSURLSession*)restSession withKey:(NSString*)key
{
    if ( restSession == nil || key == nil )
        return;
    
    [[self _sessionsDict] setObject:restSession forKey:key];
}


- (void)removeSessionWithKey:(NSString*)key
{
    if ( key == nil )
        return;
    
    [_sessionsDict removeObjectForKey:key];
}



@end