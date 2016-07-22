//
//  SWRestApiClient.h
//  HmiPad
//
//  Created by joan on 09/05/15.
//  Copyright (c) 2015 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SWDocumentModel;
@class SWRestApiTask;


@protocol SWRestApiTaskDataSource<NSObject>

@required
- (NSString *)baseUrlForRestApiTask:(SWRestApiTask *)restApiTask;
- (NSString *)restPathForRestApiTask:(SWRestApiTask *)restApiTask;
- (NSDictionary *)httpHeadersForRestApiTask:(SWRestApiTask *)restApiTask;
- (NSString *)methodForRestApiTask:(SWRestApiTask *)restApiTask;
- (NSString *)bodyForRestApiTask:(SWRestApiTask *)restApiTask;

@end


@protocol SWRestApiTaskDelegate<NSObject>

@required
- (void)restApiTask:(SWRestApiTask *)restApiTask didCompeteWithResult:(id)responseDictOrArray statusCode:(NSInteger)statusCode;

@end


@interface SWRestApiTask : NSObject

- (id)initInDocumentModel:(SWDocumentModel*)docModel;
- (void)performTask;
- (void)reloadData;

@property(nonatomic, weak) id<SWRestApiTaskDelegate> delegate;
@property(nonatomic, weak) id<SWRestApiTaskDataSource> dataSource;

@end

