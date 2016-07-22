//
//  AppModelCommon.h
//  HmiPad
//
//  Created by Joan on 05/05/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEGUG_REQUESTS 0

#if DEGUG_REQUESTS
    #define NSLog1(args...) NSLog(args)
#else
    #define NSLog1(...) {}
#endif

#define LogSuccess NSLog1( @"%@ SUCCESS\nJson: %@", NSStringFromSelector(_cmd), JSON)
#define LogFailure NSLog1( @"%@ FAILURE\n(%d) Json: %@", NSStringFromSelector(_cmd), response.statusCode, JSON)
#define LogRequest NSLog1( @"%@ REQUEST\n%@ %@ \nHeaders: %@", NSStringFromSelector(_cmd), trequest.HTTPMethod, trequest.URL, trequest.allHTTPHeaderFields)

#if DEGUG_REQUESTS
#define LogBody {  \
    NSData *body = trequest.HTTPBody;  \
    NSString *bodyString = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];  \
    NSLog( @"Body: %@", bodyString ); }

#else
#define LogBody {}
#endif


#pragma mark - File extensions

extern NSString *SWFileTypeBinary;
extern NSString *SWFileTypeSymbolic;
extern NSString *SWFileExtensionBinary;
extern NSString *SWFileExtensionSymbolic;

extern NSString *SWFileTypeWrappBinary;
extern NSString *SWFileTypeWrappSaveSymbolic;
extern NSString *SWFileTypeWrappSaveThumbnail;
extern NSString *SWFileExtensionWrapp;

extern NSString *SWFileTypeWrappValuesBinary;
extern NSString *SWFileTypeWrappValuesSymbolic;
extern NSString *SWFileKeyWrappValuesEncryptedSymbolic;

extern NSString *SWFileKeyWrappBinary;
extern NSString *SWFileKeyWrappSymbolic;
extern NSString *SWFileKeyWrappEncryptedSymbolic;

extern NSString *SWFileKeyWrappValuesBinary;
extern NSString *SWFileKeyWrappValuesSymbolic;
extern NSString *SWFileKeyWrappThumbnail;

extern NSString *SWFileExtensionActivationCode;

#pragma mark - Dictionary access

extern id _dict_objectForKey(NSDictionary* fileDict, NSString* key);

#pragma mark - Errors

extern NSError *_errorWithLocalizedDescription_title( NSString *message, NSString *title);
extern void _errorWithLocalizedDescription_title_resultBlock( NSString *message, NSString *title, void (^result)(NSError *error) );

extern NSError *_completeErrorWithError_title( NSError *error, NSString *title);
extern NSError *_completeErrorFromResponse_json_withError_title_message( NSHTTPURLResponse *response, id JSON, NSError *error,NSString *title, NSString *message);

extern NSError *_completeErrorFromResponse_json_withError_title( NSHTTPURLResponse *response, id JSON, NSError *error, NSString *title );

extern NSError *_completeErrorFromCloudKitError_message_title( NSError* operationError, NSString *message, NSString *title);

#pragma mark - Files

extern NSString *fileSizeStrForSizeValue(unsigned long long size );
extern BOOL fileExtensionIsProject(NSString *file);
extern BOOL fileExtensionIsImage(NSString *file);
extern BOOL fileExtensionIsActivationCode(NSString *file);
extern BOOL fileFullPathIsWrappedSource(NSString *fullPath);




