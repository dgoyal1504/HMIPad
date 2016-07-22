//
//  SWRestApiClient.m
//  HmiPad
//
//  Created by joan on 09/05/15.
//  Copyright (c) 2015 SweetWilliam, SL. All rights reserved.
//

#import "SWRestApiTask.h"
#import "SWDocumentModel.h"
#import "SWRestApiSessions.h"

@interface SWRestApiTask()
{
    __weak SWDocumentModel *_docModel;
    NSURLSession *_urlSession;
    //NSURLSessionTask *_urlTask;
    NSURLRequest *_request;
    NSString *_baseUrl;
}
@end


@implementation SWRestApiTask


- (id)initInDocumentModel:(SWDocumentModel*)docModel
{
    self = [super init];
    if ( self )
    {
        _docModel = docModel;
    }
    return self;
}


//- (void)setBaseUrl:(NSString*)baseUrl
//{
//    _baseUrl = baseUrl;
//    _request = nil;
//    SWRestApiSessions *restSessions = _docModel.restSessions;
//    _urlSession = [restSessions restSessionWithBaseUrl:baseUrl];
//    
//    [_urlSession setSessionDescription:baseUrl];
//}




//- (void)setRestPath:(NSString *)restPath
//{
//    if ( restPath == _restPath || [restPath isEqualToString:_restPath] )
//        return ;
//    
//    _request = nil;
//    _restPath = restPath;
//}
//
//- (void)setHttpHeaders:(NSDictionary *)httpHeaders
//{
//    if ( httpHeaders == _httpHeaders || [httpHeaders isEqual:_httpHeaders] )
//        return ;
//
//    _request = nil;
//    _httpHeaders = httpHeaders;
//}
//
//- (void)setMethod:(NSString *)method
//{
//    if ( method == _method || [method isEqualToString:_method] )
//        return ;
//    
//    _request = nil;
//    _method = method;
//}
//
//- (void)setBody:(NSString *)body
//{
//    if ( body == _body || [body isEqualToString:_body] )
//        return ;
//    
//    _request = nil;
//    _body = body;
//}




- (void)performTask
{
    [[self _urlTask] resume];
}


- (void)reloadData
{
    _request = nil;
}


#pragma mark - Private

- (NSString *)_baseUrl
{
    NSString *baseUrl = [_dataSource baseUrlForRestApiTask:self];
    if ( ![baseUrl isEqualToString:_baseUrl] )
    {
        _baseUrl = baseUrl;
        _urlSession = nil;
    }
    return _baseUrl;
}

#define DEBUG 1

- (NSURLRequest*)_request
{
    if ( _request == nil )
    {
        NSString *baseUrl = [self _baseUrl];
        NSString *restPath = [_dataSource restPathForRestApiTask:self];
        NSDictionary *httpHeaders = [_dataSource httpHeadersForRestApiTask:self];
        NSString *body = [_dataSource bodyForRestApiTask:self];
        NSString *method = [_dataSource methodForRestApiTask:self];
    
        //NSString *urlString = [baseUrl stringByAppendingPathComponent:restPath];
        NSString *urlString = [baseUrl stringByAppendingString:restPath];
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        
        [httpHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
        {
            [request addValue:obj forHTTPHeaderField:key];
        }];
        
        [request setHTTPMethod:method];
        [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
        
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
        
        _request = request;
        
        if ( DEBUG )
        {
            NSLog( @"Url> %@", request.URL );
            NSLog( @"Scheme> %@", request.URL.scheme );
            NSLog( @"Host> %@", request.URL.host );
            NSLog( @"path> %@", request.URL.path );
            NSLog( @"Http headers> %@", request.allHTTPHeaderFields);
            NSLog( @"Method> %@", request.HTTPMethod );
            NSLog( @"Body> %@", [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding] );
        }
    }
    return _request;
}


- (NSURLSession *)_urlSession
{
    if ( _urlSession == nil )
    {
        NSString *baseUrl = [self _baseUrl];
        _urlSession = [_docModel.restSessions restSessionWithBaseUrl:baseUrl];
    
        [_urlSession setSessionDescription:baseUrl];
    }
    return _urlSession;
}


//- (NSURLSessionTask*)_urlTask
//{
//    if ( _urlTask == nil || _request == nil )
//    {
//        _urlTask = [[self _urlSession] dataTaskWithRequest:[self _request] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
//        {
//            NSInteger statusCode = 0;
//            id responseDictOrArray = @{};
//            if ( error == nil )
//            {
//                NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
//                statusCode = httpResp.statusCode;
//                
//                NSError *jsonError = nil;
//                id JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
//                if ( JSON != nil && jsonError == nil && ([JSON isKindOfClass:[NSDictionary class]] || [JSON isKindOfClass:[NSArray class]] ) )
//                {
//                    responseDictOrArray = JSON;
//                }
//            }
//            else
//            {
//                // handle error
//            }
//            
//            dispatch_async(dispatch_get_main_queue(), ^
//            {
//                if ( DEBUG )
//                {
//                    NSLog( @"REST API COMPLETED STATUS: %ld", (long)statusCode );
//                    NSLog( @"REST API COMPLETED RESULT: %@", responseDictOrArray );
//                }
//                [_delegate restApiTask:self didCompeteWithResult:responseDictOrArray statusCode:statusCode];
//            });
//        }];
//        
//    }
//    return _urlTask;
//}


- (NSURLSessionTask*)_urlTask
{
    NSURLSessionTask *urlTask;
        urlTask = [[self _urlSession] dataTaskWithRequest:[self _request] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
        {
            NSInteger statusCode = 0;
            id responseDictOrArray = @{};
            if ( error == nil )
            {
                NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
                statusCode = httpResp.statusCode;
                
                NSError *jsonError = nil;
                id JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                if ( JSON != nil && jsonError == nil && ([JSON isKindOfClass:[NSDictionary class]] || [JSON isKindOfClass:[NSArray class]] ) )
                {
                    responseDictOrArray = JSON;
                }
            }
            else
            {
                // handle error
            }
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                if ( DEBUG )
                {
                    NSLog( @"REST API COMPLETED STATUS: %ld", (long)statusCode );
                    NSLog( @"REST API COMPLETED ERROR: %@", error );
                    NSLog( @"REST API COMPLETED RESULT: %@", responseDictOrArray );
                }
                [_delegate restApiTask:self didCompeteWithResult:responseDictOrArray statusCode:statusCode];
            });
        }];
        
    
    return urlTask;

}



@end
