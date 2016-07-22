//
//  AppFilesModelDownloadExamples.h
//  HmiPad
//
//  Created by Joan Lluch on 08/11/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "AppModel.h"

@class AppModelDownloadExamples;

@protocol AppModelDownloadExamplesObserver<NSObject>

@optional

// examples listing
- (void)appFilesModelWillReceiveExamplesListing:(AppModelDownloadExamples*)downloadExamples;
- (void)appFilesModel:(AppModelDownloadExamples*)downloadExamples didReceiveExamplesListingWithError:(NSError*)error;

@end



@interface AppModelDownloadExamples : NSObject
{
    __weak AppModel *_filesModel;
    NSMutableArray *_observers; // List of observers
//    dispatch_queue_t _dQueue;
//    const char *_queueKey ; // key for the dispatch queue
//    void *_queueContext ; // context for the dispatch queue
    NSDictionary *_examplesListing;
}

- (void)addObserver:(id<AppModelDownloadExamplesObserver>)observer;
- (void)removeObserver:(id<AppModelDownloadExamplesObserver>)observer;

- (id)initWithLocalFilesModel:(AppModel*)filesModel;

- (void)resetExamplesListing;
- (NSDictionary*)getExamplesListing;
//- (void)downloadExampleNamed:(NSString*)fileName withAssets:(NSArray*)assets;
- (void)downloadExampleNamed:(NSString*)fileName withBundled:(NSArray*)bundled assets:(NSArray*)assets;
- (void)downloadThumbnailImageForExampleNamed:(NSString*)fileName completion:(void (^)(UIImage* image))block;

- (void)downloadRemoteExamples;  // <-- not used but kept for reference

@end
