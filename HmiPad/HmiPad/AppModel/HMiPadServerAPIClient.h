//
//  HMiPadServerAPIClient.h
//  SweetWilliamAPIClient
//
//  Created by Carlton Gibson on 21/11/2012.
//  Copyright (c) 2012 Noumenal Software Ltd. All rights reserved.
//

#import "AFHTTPClient.h"

@interface HMiPadServerAPIClient : AFHTTPClient
+ (HMiPadServerAPIClient *)sharedClient;

//@property (nonatomic) NSString *token;

//- (void)enqueueRequestWithMethod:(NSString*)method
//        path:(NSString *)path
//        token:(NSString*)token
//        parameters:(NSDictionary *)parameters
//        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path
        token:(NSString*)token parameters:(NSDictionary *)parameters;

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path
        token:(NSString*)token deviceId:(NSString*)deviceID parameters:(NSDictionary *)parameters;

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path
        token:(NSString*)token locationEnabled:(NSString*)locationEnabled parameters:(NSDictionary *)parameters;

- (NSMutableURLRequest *)multipartFormRequestWithMethod:(NSString *)method path:(NSString *)path
        token:(NSString*)token parameters:(NSDictionary *)parameters
        constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block;

- (void)enqueueRequest:(NSURLRequest*)request
        success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
        failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

- (void)enqueueRequest:(NSURLRequest*)request
        success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
        failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
        upProgress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))upProgress;

//- (void)enqueueRequest:(NSURLRequest*)request outputFilePath:(NSString*)outputFilePath
//        success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
//        failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
//        downProgress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))downProgress;

- (void)enqueueRequestForDownload:(NSURLRequest*)request outputFilePath:(NSString*)outputFilePath
        success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data))success
        failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
        downProgress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))downProgress;


@end
