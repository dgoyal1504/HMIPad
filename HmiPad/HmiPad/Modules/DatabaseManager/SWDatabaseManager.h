//
//  SWDatabaseManager.h
//  HmiPad
//
//  Created by Joan Lluch on 03/04/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SWDatabaseContext;
@class FMDatabase;

@interface SWDatabaseManager : NSObject

+ (SWDatabaseManager*)defaultManager;

//- (id)initForStoringAtBasePath:(NSString*)savingPath;
//- (void)setBasePath:(NSString*)basePath;

- (void)setDispatchQueue:(dispatch_queue_t)cQueue key:(const char *)key;

- (void)transactionWithContext:(SWDatabaseContext*)dbContext asyncBlock:(void (^)(FMDatabase *db, BOOL *rollback))block; //completion:(void (^)(BOOL success))completion;
- (void)transactionWithContext:(SWDatabaseContext*)dbContext nowBlock:(void (^)(FMDatabase *db, BOOL *rollback))block;
- (void)dispatchNowBlock:(void (^)(void))block;


@end
