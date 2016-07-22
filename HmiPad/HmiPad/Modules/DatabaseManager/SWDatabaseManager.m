//
//  SWDatabaseManager.m
//  HmiPad
//
//  Created by Joan Lluch on 03/04/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWDatabaseManager.h"

#import "SWDatabaseContext.h"
#import "FMDB.h"


@implementation SWDatabaseManager
{
	dispatch_queue_t _cQueue;
    const char *_queueKey ; // key for the dispatch queue
    void *_queueContext ; // context for the dispatch queue
    
    NSString *_storingPath;
}


+ (SWDatabaseManager*)defaultManager
{
    static SWDatabaseManager *instance = nil;
	static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        instance = [[SWDatabaseManager alloc] init];
    });
    
    return instance;
}

//- (id)init
//{
//    return [self initForStoringAtBasePath:nil];
//}

- (void)dealloc
{
    _cQueue = nil;
}


#pragma mark - Init

//- (id)initForStoringAtBasePath:(NSString*)basePath;
//{
//    self = [super init];
//    if (self)
//    {
//        if ( basePath == nil )
//        {
//            NSString *appSupportDir = [self _applicationSupportDir];
//            basePath = [appSupportDir stringByAppendingPathComponent:@"databases"];
//        }
//        _storingPath = basePath;
//    }
//    return self;
//}
//
//
//- (void)setBasePath:(NSString*)basePath
//{
//    _storingPath = basePath;
//}
//
//
//- ( NSString*)_applicationSupportDir
//{
//    NSFileManager *fm = [[NSFileManager alloc] init];
//    NSURL *internalURL = [fm URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
//    NSString *applicationSupportDir = [internalURL path] ;
//
//    return applicationSupportDir ;
//}


#pragma mark - Serial Queue

- (void)setDispatchQueue:(dispatch_queue_t)cQueue key:(const char *)key
{
    _queueKey = key;
    _queueContext = dispatch_queue_get_specific(cQueue, key);
    _cQueue = cQueue;
}


- (dispatch_queue_t)cQueue
{
    if ( _cQueue == NULL )
    {
        _queueKey = "SWDatabaseManagerQueue";
        _queueContext = (void*)_queueKey;
        
        _cQueue = dispatch_queue_create( _queueKey, NULL );
        dispatch_queue_set_specific( _cQueue, _queueKey, _queueContext, NULL);
    }
    return _cQueue;
}


#pragma mark - Methods

- (void)transactionWithContext:(SWDatabaseContext*)dbContext
    asyncBlock:(void (^)(FMDatabase *db, BOOL *rollback))block //completion:(void (^)(BOOL success))completion
{
    [self _transactionWithContext:dbContext deferred:YES now:NO block:block /*completion:completion*/];
}


- (void)transactionWithContext:(SWDatabaseContext*)dbContext nowBlock:(void (^)(FMDatabase *db, BOOL *rollback))block //completion:(void (^)(BOOL success))completion
{
    [self _transactionWithContext:dbContext deferred:YES now:YES block:block /*completion:completion*/];
}


- (void)dispatchNowBlock:(void (^)(void))block
{
    [self _dispatchBlockNow:block];
}


- (void)dispatchAsyncBlock:(void (^)(void))block
{
    dispatch_async( self.cQueue , block);
}


#pragma mark - Private

- (void)_dispatchBlockNow:(void (^)(void))block
{
    if ( dispatch_get_specific(_queueKey) == _queueContext ) block();
    else dispatch_sync( self.cQueue, block );
}


- (void)_transactionWithContext:(SWDatabaseContext*)dbContext deferred:(BOOL)useDeferred now:(BOOL)now
    block:(void (^)(FMDatabase *db, BOOL *rollback))block //completion:(void (^)(BOOL success))completion
{
    void (^perform)() = ^
    {
        FMDatabase *db = [dbContext database];
        
        if (useDeferred) [db beginDeferredTransaction];
        else [db beginTransaction];
        
        BOOL shouldRollback = NO;
        block( db, &shouldRollback );
        
        if (shouldRollback) [db rollback];
        else [db commit];
//        dispatch_async(dispatch_get_main_queue(), ^
//        {
//            if ( completion ) completion( !shouldRollback );  // a treure
//        });
    };

    if ( now ) [self _dispatchBlockNow:perform];
    else dispatch_async(self.cQueue, perform);
}



@end