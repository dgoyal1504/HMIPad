//
//  HMiPadServerAPIClient.m
//  SweetWilliamAPIClient
//
//  Created by Carlton Gibson on 21/11/2012.
//  Copyright (c) 2012 Noumenal Software Ltd. All rights reserved.
//

#import "HMiPadServerAPIClient.h"
#import "AFJSONRequestOperation.h"




// =====================================================================
// TREURE TREURE TREURE

//@implementation NSURLRequest(AllowAllCerts)
//+ (BOOL) allowsAnyHTTPSCertificateForHost:(NSString *) host {
//   return YES;
//}
//@end





@implementation HMiPadServerAPIClient

//static NSString * const kHMiPadServerAPIBaseURLString = @"http://127.0.0.1:8000/";
//static NSString * const kHMiPadServerAPIBaseURLString = @"https://sw.noumenal.co.uk/";
//static NSString * const kHMiPadServerAPIBaseURLString = @"https://ec2-75-101-244-192.compute-1.amazonaws.com/";
static NSString * const kHMiPadServerAPIBaseURLString = @"https://hmipad.sweetwilliamsl.com";

#pragma mark singleton

+ (HMiPadServerAPIClient *)sharedClient {
    static HMiPadServerAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[HMiPadServerAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kHMiPadServerAPIBaseURLString]];
    });

    return _sharedClient;
}

#pragma mark init

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }

    [self setParameterEncoding:AFJSONParameterEncoding];   // <-- JUST ADDED THIS !!
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];

    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setDefaultHeader:@"X-Requested-With" value:@"XMLHttpRequest"];
    
    //[self setDefaultSSLPinningMode:AFSSLPinningModePublicKey];
    self.defaultSSLPinningMode = AFSSLPinningModePublicKey;
    
    return self;
}

//- (void)setToken:(NSString *)token
//{
//    if (![_token isEqualToString:token]) {
//        _token = token;
//        [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Token %@", _token]];
//    }
//}


//- (void)enqueueRequestWithMethod:(NSString*)method
//        path:(NSString *)path
//        token:(NSString*)token
//        parameters:(NSDictionary *)parameters
//        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
//{
//    [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Token %@", token]];
//	NSURLRequest *request = [self requestWithMethod:method path:path parameters:parameters];
//	AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
//    [self enqueueHTTPRequestOperation:operation];
//}


//
//
// [request setValue:[NSString stringWithFormat:@"%@", deviceID] forHTTPHeaderField:@"Device-UUID"];
//
//

#pragma mark request





- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path
        token:(NSString*)token parameters:(NSDictionary *)parameters
{
    NSMutableURLRequest *request = [self requestWithMethod:method path:path token:token deviceId:nil parameters:parameters];
    return request;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path
        token:(NSString*)token locationEnabled:(NSString*)locationEnabled parameters:(NSDictionary *)parameters
{
    NSMutableURLRequest *request = [self requestWithMethod:method path:path parameters:parameters];
    if ( token ) [request setValue:[NSString stringWithFormat:@"Token %@", token] forHTTPHeaderField:@"Authorization"];
    if ( locationEnabled ) [request setValue:[NSString stringWithFormat:@"%@", locationEnabled] forHTTPHeaderField:@"Location-Enabled"];
    return request;
}


- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path
        token:(NSString*)token deviceId:(NSString*)deviceID parameters:(NSDictionary *)parameters
{
    NSMutableURLRequest *request = [self requestWithMethod:method path:path parameters:parameters];
    if ( token ) [request setValue:[NSString stringWithFormat:@"Token %@", token] forHTTPHeaderField:@"Authorization"];
    if ( deviceID ) [request setValue:[NSString stringWithFormat:@"%@", deviceID] forHTTPHeaderField:@"Device-UUID"];
    return request;
}


- (NSMutableURLRequest *)multipartFormRequestWithMethod:(NSString *)method path:(NSString *)path
        token:(NSString*)token parameters:(NSDictionary *)parameters
        constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
{
    NSMutableURLRequest *request = [self multipartFormRequestWithMethod:method path:path parameters:parameters constructingBodyWithBlock:block];
    if ( token ) [request setValue:[NSString stringWithFormat:@"Token %@", token] forHTTPHeaderField:@"Authorization"];
    return request;
}


# pragma mark enqueue

- (void)enqueueRequest:(NSURLRequest*)request
        success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
        failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [self enqueueRequest:request success:success failure:failure upProgress:nil];
}


//- (void)enqueueRequest:(NSURLRequest*)request
//        success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
//        failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
//        upProgress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))upProgress
//{    
//    [self enqueueRequest:request outputFilePath:nil success:success failure:failure upProgress:upProgress downProgress:nil];
//}


- (void)enqueueRequest:(NSURLRequest*)request
        success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
        failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
        upProgress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))upProgress
{    

    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:success failure:failure];

#ifdef _AFNETWORKING_PIN_SSL_CERTIFICATES_
    operation.SSLPinningMode = self.defaultSSLPinningMode;
#endif

    if ( upProgress ) [operation setUploadProgressBlock:upProgress];

    [self enqueueHTTPRequestOperation:operation];
}

//- (void)enqueueRequest:(NSURLRequest*)request
//        outputFilePath:(NSString*)outputFilePath
//        success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
//        failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
//        downProgress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))downProgress
//{
//    [self enqueueRequest:request outputFilePath:outputFilePath success:success failure:failure upProgress:nil downProgress:downProgress];
//}



//- (void)enqueueRequest:(NSURLRequest*)request outputFilePath:(NSString*)outputFilePath
//        success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
//        failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
//        upProgress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))upProgress
//        downProgress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))downProgress
//{
//    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:success failure:failure];
//
//#ifdef _AFNETWORKING_PIN_SSL_CERTIFICATES_
//    operation.SSLPinningMode = self.defaultSSLPinningMode;
//#endif
//
//    if ( upProgress ) [operation setUploadProgressBlock:upProgress];
//    if ( downProgress ) [operation setDownloadProgressBlock:downProgress];
//    if ( outputFilePath ) [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:outputFilePath append:NO]];
//
//    [self enqueueHTTPRequestOperation:operation];
//}


- (void)enqueueRequestForDownload:(NSURLRequest*)request outputFilePath:(NSString*)outputFilePath
        success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data))success
        failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
        downProgress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))downProgress
{

    AFHTTPRequestOperation *rOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
#ifdef _AFNETWORKING_PIN_SSL_CERTIFICATES_
    rOperation.SSLPinningMode = self.defaultSSLPinningMode;
#endif
    
    [rOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSData *responseData)
    {
        if (success) success(operation.request, operation.response, responseData);
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        if (failure) failure(operation.request, operation.response, error);
    }];

    if ( downProgress ) [rOperation setDownloadProgressBlock:downProgress];
    if ( outputFilePath ) [rOperation setOutputStream:[NSOutputStream outputStreamToFileAtPath:outputFilePath append:NO]];
    [self enqueueHTTPRequestOperation:rOperation];
}














@end
