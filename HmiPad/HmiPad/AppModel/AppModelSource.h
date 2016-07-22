//
//  AppModelSource.h
//  HmiPad
//
//  Created by Joan Lluch on 31/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//


#import "AppModel.h"

@class AppModelSource;

@protocol AppModelSourceObserver<NSObject>

@optional
- (void)appsFileModelSourcesDidChange:(AppModelSource*)filesSource;

@end


@interface AppModelSource : NSObject
{
    __weak AppModel *_filesModel;
    NSMutableArray *_observers; // List of observers
//    dispatch_queue_t _dQueue;
//    const char *_queueKey ; // key for the dispatch queue
//    void *_queueContext ; // context for the dispatch queue
    NSArray *_projectSources; // array amb els noms dels fitxers sources
}

- (void)addObserver:(id<AppModelSourceObserver>)observer;
- (void)removeObserver:(id<AppModelSourceObserver>)observer;

- (id)initWithLocalFilesModel:(AppModel*)filesModel;
//- (void)setDispatchQueue:(dispatch_queue_t)dQueue key:(const char *)key;  // <-- call on initialization

- (NSArray*)getProjectSources; // torna un array amb els sources
- (void)setProjectSources:(NSArray*)newSources; // se li passen NSStrings amb els noms dels fitxers
- (NSString*)exclusiveProjectSource;

#define SWDefaultSourceFlagValue 3
- (void)projectSource:(NSString*)source setFlag:(NSInteger)flag;
- (NSInteger)projectSourceGetFlag:(NSString*)source;

@end
