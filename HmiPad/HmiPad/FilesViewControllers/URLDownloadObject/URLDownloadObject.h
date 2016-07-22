//
//  URLDownloadObject.h
//  ScadaMobile
//
//  Created by Joan on 15/05/11.
//  Copyright 2011 SweetWilliam, S.L. All rights reserved.
//

#import <Foundation/Foundation.h>

@class URLDownloadObject;

@protocol URLDownloadObjectDelegate<NSObject>
- (void)URLDownloadObject:(URLDownloadObject*)sender redeemCode:(NSString*)code;
@end



//---------------------------------------------------------------------------------------------------
@interface URLDownloadObject : NSObject 
{
    NSMutableData *receivedData ;
    NSString *fileUrlPath ;
    NSURLAuthenticationChallenge *theChallenge ;
    NSURLConnection *theConnection ;
    BOOL isSource ;
    BOOL isActivationCode;
    NSString *activationCode;
    int operationType ;
    int fileCategory ;   // es en realitat del tipus FileCategory
    NSInteger sourceButtonIndex ;
    NSInteger activationCodeButtonIndex;
    int recipeButtonIndex ;
    NSInteger docsButtonIndex ;
    UInt32 schemaUserId;
    NSString *schemaUserName;
    NSString *schemaToken;
    __weak id<URLDownloadObjectDelegate> _delegate;
}

+ (void)downloadFileWithUrlName:(NSString*)file withFileCategory:(int)category;
+ (void)openFromExternalAppWithFileUrlName:(NSString*)file delegate:(id<URLDownloadObjectDelegate>)delegate;
+ (void)openFromExternalSchemeURL:(NSURL*)url;

@end

//extern NSString *URLDownloadObjectBegan ;
extern NSString *URLDownloadObjectEnded;
extern NSString *URLDownloadObjectRedeem;
extern NSString *URLDownloadObjectRedeemCodeKey;


/*
//---------------------------------------------------------------------------------------------------
@protocol URLDownloadObjectDelegate

@optional
- (void)urlDownloadObjectDidStartDownloading:(URLDownloadObject*)urlDownloadObject ;
- (BOOL)urlDownloadObjectDidEndDownloading:(URLDownloadObject*)urlDownloadObject ;

@end
*/