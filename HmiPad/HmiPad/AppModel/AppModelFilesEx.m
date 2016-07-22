//
//  AppIServerModel.m
//  HmiPad
//
//  Created by Joan on 09/03/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "AppModelFilesEx.h"

#import "AppModelFilePaths.h"
#import "AppModelDocument.h"

#import "AppUsersModel.h"
#import "SWAppCloudKitUser.h"
#import "UserDefaults.h"

#import "HMiPadServerAPIClient.h"

#import "SWDocument.h"
#import "SWDocumentModel.h"
#import "SWModelTypes.h"

#import "NSData+SWCrypto.h"
#import "SKProduct+priceString.h"

#import "DDData.h"



#pragma mark AppFilesModel

@interface AppModelFilesEx()  //<SKProductsRequestDelegate,SKPaymentTransactionObserver>
@end

@implementation AppModelFilesEx
{
    NSMutableIndexSet *_waitingRemoteFileListingQuery;
//    BOOL _waitingProductListing;
//    BOOL _isObservingTransactions;
//    BOOL _isPreparingReceipt;
    NSString *_currentUploadPath;
    NSString *_currentDownloadPath;
    NSString *_processingProduct;
    NSString *_updatingProduct;
}



#pragma mark complete error



//- (NSError*)_completeErrorWithLocalizedDescription:(NSString*)message title:(NSString*)title
//{
//    NSDictionary *userInfo = @{NSLocalizedDescriptionKey:message};
//    NSError *error = [[NSError alloc] initWithDomain:@"my" code:0 userInfo:userInfo];
//    return [self _completeErrorWithError:error title:title];
//}


//- (NSError*)_completeErrorWithError:(NSError*)error title:(NSString*)title
//{
//    if ( title != nil && error != nil )
//    {
//        NSString *message = [error localizedDescription];
//        NSString *ok = NSLocalizedString( @"Ok", nil );
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:ok, nil];
//        [alert show];
//    }
//    return error;
//}

//
//- (NSError*)_completeErrorFromResponse:(NSHTTPURLResponse *)response json:(id)JSON withError:(NSError*)error title:(NSString*)title
//{
//    NSInteger statusCode = [response statusCode];
//    BOOL errorResponse = statusCode > 0 && (statusCode < 200 || statusCode >= 300);
//
//    if ( errorResponse )
//    {
//        NSDictionary *jsonDict = JSON;
//        
//        BOOL first = YES;
//        NSMutableString *errStr = [NSMutableString string];
//        for ( NSString *key in jsonDict )
//        {
//            if ( !first ) first = NO, [errStr appendString:@"\n"];
//            [errStr appendFormat:@"%@: %@\n", key, [jsonDict objectForKey:key]];
//        }
//        
//        if ( errStr.length > 0 )
//        {
//            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:errStr};
//            error = [NSError errorWithDomain:@"HMiPad" code:0 userInfo:userInfo];
//        }
//        
//        if ( title != nil )
//        {
//            NSString *message = [error localizedDescription];
//            NSString *ok = NSLocalizedString( @"Ok", nil );
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:ok, nil];
//            [alert show];
//        }
//    }
//    return error;
//}



//- (NSError*)_completeErrorFromResponse:(NSHTTPURLResponse *)response json:(id)JSON withError:(NSError*)error title:(NSString*)title
//{
//    return [self _completeErrorFromResponse:response json:JSON withError:error title:title message:nil];
//}


//- (NSError*)_completeErrorFromResponse:(NSHTTPURLResponse *)response json:(id)JSON withError:(NSError*)error title:(NSString*)title message:(NSString*)message
//{
//    NSInteger statusCode = [response statusCode];
//    BOOL errorResponse = statusCode > 0 && (statusCode < 200 || statusCode >= 300);
//
//    if ( errorResponse )
//    {
//        NSDictionary *jsonDict = JSON;
//        
//        BOOL first = YES;
//        NSMutableString *errStr = [NSMutableString string];
//        for ( NSString *key in jsonDict )
//        {
//            if ( !first ) first = NO, [errStr appendString:@"\n"];
//            [errStr appendFormat:@"%@: %@\n", key, [jsonDict objectForKey:key]];
//        }
//        
//        if ( errStr.length > 0 || message.length > 0)
//        {
//            NSString *descr = errStr;
//            NSString *reason = @"";
//            if ( message.length > 0 )
//            {
//                descr = message;
//                reason = errStr;
//            }
//        
//            NSDictionary *userInfo = @
//            {
//                NSLocalizedDescriptionKey:descr,
//                NSLocalizedFailureReasonErrorKey:errStr,
//            };
//            
//            error = [NSError errorWithDomain:@"HMiPad" code:0 userInfo:userInfo];
//        }
//        
//        if ( title != nil )
//        {
//            NSString *descr = [error localizedDescription];
//            NSString *ok = NSLocalizedString( @"Ok", nil );
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:descr delegate:nil cancelButtonTitle:nil otherButtonTitles:ok, nil];
//            [alert show];
//        }
//    }
//    
//    NSLog1( @"completeErrorFromResponse Error:%@", error);
//    return error;
//}





#pragma mark notify

- (BOOL)_notifyRemoteFileListingWillChangeForCategory:(FileCategory)category
{
    if ( [_waitingRemoteFileListingQuery containsIndex:category] )
        return YES;
    
    [_waitingRemoteFileListingQuery addIndex:category];
    for ( id<AppFilesModelObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:willChangeRemoteListingForCategory:)])
        {
            [observer appFilesModel:self willChangeRemoteListingForCategory:category];
        }
    }
    
    return NO;
}


- (void)_notifyRemoteFileListingDidChangeForCategory:(FileCategory)category withError:(NSError*)error
{
    [_waitingRemoteFileListingQuery removeIndex:category];
    for ( id<AppFilesModelObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:didChangeRemoteListingForCategory:withError:)])
        {
            [observer appFilesModel:self didChangeRemoteListingForCategory:category withError:error];
        }
    }
}

- (void)_notifyBeginGroupUploadForCategory:(FileCategory)category
{
    _updatingProject = YES;
    for ( id<AppFilesModelObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:beginGroupUploadForCategory:)] )
        {
            [observer appFilesModel:self beginGroupUploadForCategory:category];
        }
    }
}


- (void)_notifyWillUploadFile:(NSString*)fileName category:(FileCategory)category
{
    for ( id<AppFilesModelObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:willUploadFile:forCategory:)] )
        {
            [observer appFilesModel:self willUploadFile:fileName forCategory:category];
        }
    }
}


- (void)_notifyDidUploadFile:(NSString*)fileName category:(FileCategory)category withError:(NSError*)error
{
    for ( id<AppFilesModelObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:didUploadFile:forCategory:withError:)] )
        {
            [observer appFilesModel:self didUploadFile:fileName forCategory:category withError:error];
        }
    }
}



- (void)_notifyGroupUploadProgressStep:(NSInteger)step stepCount:(NSInteger)stepCount category:(FileCategory)category
{
    _groupUploadStep = step;
    for ( id<AppFilesModelObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:groupUploadProgressStep:stepCount:category:)] )
        {
            [observer appFilesModel:self groupUploadProgressStep:step stepCount:stepCount category:category];
        }
    }
}

- (void)_notifyFileUploadProgressBytesRead:(long long)bytesRead totalBytesExpected:(long long)total category:(FileCategory)category
{
    for ( id<AppFilesModelObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:fileUploadProgressBytesRead:totalBytesExpected:category:)] )
        {
            [observer appFilesModel:self fileUploadProgressBytesRead:bytesRead totalBytesExpected:total category:category];
        }
    }
}

- (void)_notifyFileUploadProgress:(double)progress fileName:(NSString*)fileName category:(FileCategory)category
{
    for ( id<AppFilesModelObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:fileUploadProgress:fileName:category:)] )
        {
            [observer appFilesModel:self fileUploadProgress:progress fileName:fileName category:category];
        }
    }
}

- (void)_notifyEndGroupUpload:(BOOL)finished userCanceled:(BOOL)canceled category:(FileCategory)category
{
    _updatingProject = NO;
    _groupUploadStep = -1;
    for ( id<AppFilesModelObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:endGroupUploadForCategory:finished:userCanceled:)] )
        {
            [observer appFilesModel:self endGroupUploadForCategory:category finished:finished userCanceled:canceled];
        }
    }
}



- (void)_notifyWillRedeemCode:(NSString*)code
{
    _redeemStep = 0;
    for ( id<AppFilesModelObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:willRedemCode:)])
        {
            [observer appFilesModel:self willRedemCode:code];
        }
    }
}

- (void)_notifyDidRedeemCode:(NSString*)code withError:(NSError*)error
{
    _redeemStep = -1;
    for ( id<AppFilesModelObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:didRedemCode:withError:)])
        {
            [observer appFilesModel:self didRedemCode:code withError:error];
        }
    }
}



- (void)_notifyBeginGroupDownloadForCategory:(FileCategory)category
{
    _downloadingProject = YES;
    for ( id<AppFilesModelObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:beginGroupDownloadForCategory:)] )
        {
            [observer appFilesModel:self beginGroupDownloadForCategory:category];
        }
    }
}



- (void)_notifyWillDownloadFile:(NSString*)fileName category:(FileCategory)category
{
    for ( id<AppFilesModelObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:willDownloadFile:forCategory:)] )
        {
            [observer appFilesModel:self willDownloadFile:fileName forCategory:category];
        }
    }
}

- (void)_notifyDidDownloadFile:(NSString*)fileName category:(FileCategory)category withError:(NSError*)error
{
    for ( id<AppFilesModelObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:didDownloadFile:forCategory:withError:)] )
        {
            [observer appFilesModel:self didDownloadFile:fileName forCategory:category withError:error];
        }
    }
}



- (void)_notifyGroupDownloadProgressStep:(NSInteger)step stepCount:(NSInteger)stepCount category:(FileCategory)category
{
    _redeemStep = 1;
    _groupDownloadStep = step;
    for ( id<AppFilesModelObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:groupDownloadProgressStep:stepCount:category:)] )
        {
            [observer appFilesModel:self groupDownloadProgressStep:step stepCount:stepCount category:category];
        }
    }
}


- (void)_notifyFileDownloadProgressBytesRead:(long long)bytesRead totalBytesExpected:(long long)total category:(FileCategory)category
{
    for ( id<AppFilesModelObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:fileDownloadProgressBytesRead:totalBytesExpected:category:)] )
        {
            [observer appFilesModel:self fileDownloadProgressBytesRead:bytesRead totalBytesExpected:total category:category];
        }
    }
}



- (void)_notifyEndGroupDownload:(BOOL)finished userCanceled:(BOOL)canceled category:(FileCategory)category
{
    _downloadingProject = NO;
    _groupDownloadStep = -1;
    _redeemStep = -1;
    for ( id<AppFilesModelObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:endGroupDownloadForCategory:finished:userCanceled:)] )
        {
            [observer appFilesModel:self endGroupDownloadForCategory:category finished:finished userCanceled:canceled];
        }
    }
}





- (void)_notifyWillSetFilesToProject
{

}


- (void)_notifyDidSetFilesToProjectWithError:(NSError*)error
{

}








- (void)_notifyWillDeleteRemoteFile:(NSString*)fileName forCategory:(FileCategory)category
{
    _updatingProject = YES;
    for ( id<AppFilesModelObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:willDeleteRemoteFile:forCategory:)] )
        {
            [observer appFilesModel:self willDeleteRemoteFile:fileName forCategory:category];
        }
    }
}

- (void)_notifyDidDeleteRemoteFile:(NSString*)fileName forCategory:(FileCategory)category withError:(NSError*)error
{
    _updatingProject = NO;
    for ( id<AppFilesModelObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:didDeleteRemoteFile:forCategory:withError:)] )
        {
            [observer appFilesModel:self didDeleteRemoteFile:fileName forCategory:category withError:error];
        }
    }
}

- (void)_notifyDidGetRemoteFileMD:(FileMD*)fileMD forCategory:(FileCategory)category withError:(NSError*)error
{
    for ( id<AppFilesModelObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:didGetRemoteFileMD:forCategory:withError:)])
        {
            [observer appFilesModel:self didGetRemoteFileMD:fileMD forCategory:category withError:error];
        }
    }
}





#pragma mark - Model observation

- (void)addObserver:(id<AppFilesModelObserver>)observer
{
    [super addObserver:observer];
}

- (void)removeObserver:(id<AppFilesModelObserver>)observer
{
    [super removeObserver:observer];
}


#pragma mark File Paths (Private)

- ( NSArray*__strong*)_primitiveMDFilesArrayRefForCategory:(FileCategory)category
{
    if ( category == kFileCategoryRemoteSourceFile ) return &_remoteSourceFilesArray ;
    else if ( category == kFileCategoryRemoteAssetFile ) return &_remoteAssetsFilesArray ;
    else if ( category == kFileCategoryRemoteActivationCode ) return &_remoteActivationCodesArray ;
    else if ( category == kFileCategoryRemoteRedemption ) return &_remoteRedemptionsArray;
    
    return [super _primitiveMDFilesArrayRefForCategory:category];
}



#pragma mark listing


- (NSArray*)filesMDArrayForCategory:(FileCategory)category
{
    NSArray *__strong*files = [self _primitiveMDFilesArrayRefForCategory:category];

    if ( *files == nil )
    {
        if ( category == kFileCategoryRemoteSourceFile ||
            category == kFileCategoryRemoteAssetFile ||
            category == kFileCategoryRemoteActivationCode ||
            category == kFileCategoryRemoteRedemption )
        {
            [self _listRemoteFilesForCategory:category];
        }
        else
        {
            return [super filesMDArrayForCategory:category];
        }
    }
    
    NSArray *result = *files;
    if ( result == nil )
    {
        result = [NSArray array];
    }

    return result;
}


- (void)refreshMDArrayForCategory:(FileCategory)category
{
    if ( category == kFileCategoryRemoteSourceFile ||
        category == kFileCategoryRemoteAssetFile ||
        category == kFileCategoryRemoteActivationCode ||
        category == kFileCategoryRemoteRedemption )
    {
        [self _listRemoteFilesForCategory:category];
    }
    else
    {
        [super refreshMDArrayForCategory:category];
    }
}

- (void)resetMDArrayForCategory:(FileCategory)category
{
    [super resetMDArrayForCategory:category];
}


- (void)deleteFileWithFileMD:(FileMD*)fileMD forCategory:(FileCategory)category
{
    if ( category == kFileCategoryRemoteSourceFile ||
        category == kFileCategoryRemoteAssetFile ||
        category == kFileCategoryRemoteActivationCode ||
        category == kFileCategoryRemoteRedemption )
    {
        [self _deleteRemoteFileWithFileMD:fileMD withCategory:category];
    }
    else
    {
       // [super deleteFileWithFileMD:fileMD forCategory:category];
        [self deleteFileWithFileName:fileMD.fileName forCategory:category error:nil];
    }
}

- (void)setFileSortingOption:(FileSortingOption)option forCategory:(FileCategory)category
{
    FileSortingOption currentOption = [self fileSortingOptionForCategory:category];
    if ( option != currentOption )
    {
        UserDefaults *userDefaults = defaults();
        
        if ( category == kFileCategoryRemoteSourceFile ) [userDefaults setRemoteSourceFileSortingOptions:option];
        else if ( category == kFileCategoryRemoteAssetFile ) [userDefaults setRemoteAssetFileSortingOptions:option];
        else if ( category == kFileCategoryRemoteActivationCode ) [userDefaults setRemoteActivationCodeSortingOptions:option];
        else if ( category == kFileCategoryRemoteRedemption ) [userDefaults setRemoteRedemptionSortingOptions:option];
        else
        {
            [super setFileSortingOption:option forCategory:category];
            return;
        }
        
        [self _sortFilesForCategory:category];
        [self _notifyRemoteFileListingDidChangeForCategory:category withError:nil];
    }

}


- (FileSortingOption)fileSortingOptionForCategory:(FileCategory)category
{
    UserDefaults *userDefaults = defaults();
    FileSortingOption option = kFileSortingOptionAny;
    
    if ( category == kFileCategoryRemoteSourceFile ) option = [userDefaults remoteSourceFileSortingOptions];
    else if ( category == kFileCategoryRemoteAssetFile ) option = [userDefaults remoteAssetFileSortingOptions];
    else if ( category == kFileCategoryRemoteActivationCode ) option = [userDefaults remoteActivationCodeSortingOptions];
    else if ( category == kFileCategoryRemoteRedemption ) option = [userDefaults remoteRedemptionSortingOptions];
    
    else if ( category == kExtFileCategoryITunes ) option = [userDefaults iTunesFileSortingOptions];
    else return [super fileSortingOptionForCategory:category];
    
    return option;

}




#pragma mark Integrators Service

#pragma mark no ck
#if !UseCloudKit
- (void)uploadProject
{
    UserProfile *profile = [usersModel() currentUserProfile];
    
    SWDocument *document = [_filesModel.fileDocument currentDocument];
    
    // propietats especials per posar en projectes en el nuvol (i per tant HMI VIew)
    SWDocumentModel *docModel = document.docModel;
    [docModel setOwnerID:profile.userId];    // <- el owner
    [docModel selectProjectUser:nil];        // <- cap usuari de projecte
    
    // propietats del projecte que el servidor necesita coneixer
    NSArray *files = [docModel fileList];
    NSString *uuid = [docModel uuid];
    
    NSData *symbolicData = [document getSymbolicData];
    NSString *projectName = [document getFileName];
    
    NSData *thumbnailData = UIImagePNGRepresentation(docModel.thumbnailImage);
    
    [self _uploadProjectWithName:projectName data:symbolicData thumbnailData:thumbnailData fileSize:symbolicData.length UUID:uuid files:files profile:profile];
}


- (void)downloadRemoteFileMDs:(NSArray*)fileMDs forCategory:(FileCategory)category
{
    NSAssert(category == kFileCategoryRemoteSourceFile || category == kFileCategoryRemoteAssetFile, @"mala peca al teler");
    UserProfile *profile = [usersModel() currentUserProfile];
    [self _downloadRemoteFileMDs:fileMDs forCategory:category profile:profile];
}

- (void)uploadRemoteFileMDs:(NSArray*)fileMDs forCategory:(FileCategory)category
{
    NSAssert(category == kFileCategoryAssetFile, @"mala peca al teler");
    UserProfile *profile = [usersModel() currentUserProfile];
    [self _uploadAssets:fileMDs profile:profile];
}

- (void)getRemoteFileMDForFileWithUUID:(NSString*)uuid forCategory:(FileCategory)category
{
    if ( category == kFileCategoryRemoteSourceFile || category == kFileCategoryRemoteAssetFile || category == kFileCategoryRemoteActivationCode)
    {
        [self _getRemoteFileMDOfFileUUID:uuid forCategory:category];
        return;
    }
    
    NSAssert( YES, @"mala peca al teler");
}

#endif
#pragma mark endif

#pragma mark ck
#if UseCloudKit
- (void)uploadProject
{
    UserProfile *profile = [cloudKitUser() currentUserProfile];
    
    SWDocument *document = [_filesModel.fileDocument currentDocument];
    
    // propietats especials per posar en projectes en el nuvol (i per tant HMI VIew)
    SWDocumentModel *docModel = document.docModel;
    [docModel setOwnerID:profile.userId];    // <- el owner
    [docModel selectProjectUser:nil];        // <- cap usuari de projecte
    
    // propietats del projecte que el servidor necesita coneixer
    NSArray *files = [docModel fileList];
    NSString *uuid = [docModel uuid];
    
    NSData *symbolicData = [document getSymbolicData];
    NSString *projectName = [document getFileName];
    
    NSData *thumbnailData = UIImagePNGRepresentation(docModel.thumbnailImage);
    
    [self _uploadProjectWithName_ck:projectName data:symbolicData thumbnailData:thumbnailData fileSize:symbolicData.length UUID:uuid files:files profile:profile];
}


- (void)downloadRemoteFileMDs:(NSArray*)fileMDs forCategory:(FileCategory)category
{
    NSAssert(category == kFileCategoryRemoteSourceFile || category == kFileCategoryRemoteAssetFile, @"mala peca al teler");
    UserProfile *profile = [cloudKitUser() currentUserProfile];
    NSString *userID = profile.token;
    [self _downloadRemoteFileMDs_ck:fileMDs forCategory:category userID:(NSString*)userID];
}

- (void)uploadRemoteFileMDs:(NSArray*)fileMDs forCategory:(FileCategory)category
{
    NSAssert(category == kFileCategoryAssetFile, @"mala peca al teler");
    UserProfile *profile = [cloudKitUser() currentUserProfile];
    [self _uploadAssets_ck:fileMDs profile:profile];
}

- (void)getRemoteFileMDForFileWithUUID:(NSString*)uuid forCategory:(FileCategory)category
{
    if ( category == kFileCategoryRemoteSourceFile || category == kFileCategoryRemoteAssetFile )
    {
        NSString *ownerId = [cloudKitUser() currentUserUUID];
        [self _getRemoteFileMDOfFileUUID_ck:uuid ownerId:ownerId forCategory:category];
        return;
    }
    
    if ( category == kFileCategoryRemoteActivationCode )
    {
        [self _getRemoteFileMDOfActivationUUID_ck:uuid completion:nil];
        return;
    }
    
    NSAssert( YES, @"mala peca al teler");
}



#endif
#pragma mark endif



- (void)cancelUpload
{
#pragma warning - to do
    // TO DO !!
   // [self _cancelUpload];
}






#pragma mark Redemptions

//
//- (void)redeemActivationCodeMDV:(FileMD*)activationMD
//{
//    UserProfile *profile = [usersModel() currentUserProfile];
//    //[self _redeemActivationCodeMD:activationMD forProfile:profile];
//    
//    NSString *activationCode = activationMD.accessCode;
//    NSString *projectId = [activationMD project];
//    UInt32 owner = activationMD.userId;
//    
//    [self _redeemActivationCode:activationCode projectId:projectId ownerId:owner forProfile:profile];
//}

#pragma mark no ck
#if !UseCloudKit

- (void)redeemActivationCodeMD:(FileMD*)activationMD
{
    UserProfile *profile = [usersModel() currentUserProfile];
    
    NSString *activationCode = activationMD.accessCode;
    NSString *projectID = [activationMD project];
    NSString *productSKU = activationMD.productSKU;
    UInt32 owner = activationMD.userId;
    if ( [SKProduct isQProduct:productSKU] )
    {
        // per activacions locals el owner ha de ser el mateix que el usuari
        if ( profile.userId != owner )
        {
            NSString *title = NSLocalizedString( @"Redemption Error", nil);
            NSString *message = NSLocalizedString( @"Attempt to redeem an activation code with the wrong user. Local redemptions are only allowed for the user that activated the project", nil);
            _errorWithLocalizedDescription_title(message, title);
        }
        
        else
        {
            // pujem el projecte dummy per el cas de que no hi sigui
//            char *bytes = "empty";
//            NSData *data = [NSData dataWithBytes:&bytes length:strlen(bytes)];
            NSData *data = nil;
            [self _primitiveUploadProjectWithFileName:@"Project" uuid:projectID fileData:data thumbnailData:nil fileSize:0 profile:profile
            completion:^(BOOL success, NSString *tprojectID)
            {
                if (success )
                {
                    // fem la redempcio local
                    [self _redeemActivationCode:activationCode projectId:projectID ownerId:0 forProfile:profile];  // <-- redemptio local
                }
            }];
        }
    }
    else
    {
        // fem la redempcio completa
        [self _redeemActivationCode:activationCode projectId:projectID ownerId:owner forProfile:profile];
    }
}


- (void)updateRedeemedProjectWithProjectID:(NSString*)projectId ownerID:(UInt32)projectOwner
{
    UserProfile *profile = [usersModel() currentUserProfile];
    [self _getRedeemedRemoteProjectWithProjectID:projectId withOwnerID:projectOwner forProfile:profile /*redeemed:YES*/];
}


- (void)validateProjectWithProjectID:(NSString*)projectId ownerID:(UInt32)projectOwner completion:(void(^)(BOOL,BOOL))block
{
    UserProfile *profile = [usersModel() currentUserProfile];
    if ( projectOwner == 0 ) projectOwner = profile.userId;
    [self _validateProjectID:projectId withOwnerID:projectOwner forProfile:profile completion:block];
}

#endif
#pragma mark endif

#pragma mark ck
#if UseCloudKit


- (void)redeemActivationCodeMD:(FileMD*)activationMD
{
    UserProfile *profile = [cloudKitUser() currentUserProfile];
    
//    NSString *activationCode = activationMD.accessCode;
//    NSString *projectID = [activationMD project];
    NSString *productSKU = activationMD.productSKU;
//    NSString *owner = activationMD.ownerId;
    if ( [SKProduct isQProduct:productSKU] )
    {
//        // per activacions locals el owner ha de ser el mateix que el usuari
//        if ( [profile.token isEqualToString:owner] )
//        {
//            NSString *title = NSLocalizedString( @"Redemption Error", nil);
//            NSString *message = NSLocalizedString( @"Attempt to redeem an activation code with the wrong user. Local redemptions are only allowed for the user that activated the project", nil);
//            _errorWithLocalizedDescription_title(message, title);
//        }
//        
//        else
//        {
//            // pujem el projecte dummy per el cas de que no hi sigui
//            NSData *data = nil;
//            [self _primitiveUploadProjectWithFileName:@"Project" uuid:projectID fileData:data thumbnailData:nil fileSize:0 profile:profile
//            completion:^(BOOL success, NSString *tprojectID)
//            {
//                if (success )
//                {
//                    // fem la redempcio local
//                    [self _redeemActivationCode:activationCode projectId:projectID ownerId:0 forProfile:profile];  // <-- redemptio local
//                }
//            }];
//        }
    }
    else
    {
        // fem la redempcio completa
   //     [self _redeemActivationCode_ck:activationCode projectId:projectID ownerId:owner forProfile:profile];
        
        [self _redeemActivationCodeMD:activationMD forProfile:profile];
    }
}


- (void)updateRedeemedProjectWithProjectID:(NSString*)targetProjectID
{
    UserProfile *profile = [cloudKitUser() currentUserProfile];
    
    if ( profile.isLocal )
    {
        return;
    }
    
    if ( _updatingProject )
    {
        return;
    }
    
    _updatingProject = YES;
    
    [self _searchValidatedProjectID:targetProjectID completion:^(BOOL done, NSString *theProjectOwner)
    {
        _updatingProject = NO;
        if ( theProjectOwner.length > 0 )
        {
            [self _getRedeemedRemoteProjectWithProjectID_ck:targetProjectID withOwnerID:theProjectOwner];
        }
    }];
}


- (void)_searchValidatedProjectID:(NSString*)targetProjectID completion:(void(^)(BOOL done, NSString *theProjectOwner))completion
{
    // per tobar buscar el project owner    -> buscar les redemptions amb aquest deviceID, buscar les activacions relacionades, comparar amb el project id fins que es trobi (o no)
    
    NSString *thisDeviceID = [cloudKitUser() identifierForApp];

    [self _listRemoteFilesForCategory:kFileCategoryRemoteRedemption completion:^(NSArray *fileMDs)
    {
        // busquem una redemption amb aquest device id.
        if ( fileMDs == nil )
        {
            completion( NO, nil );
            return;
        }
        
        NSMutableArray *activationIDs = [NSMutableArray array];
        
        for ( FileMD *redemptionMD in fileMDs )
        {
            if ( [redemptionMD.deviceIdentifier isEqualToString:thisDeviceID] )
            {
                NSString *activation = redemptionMD.accessCode;
                [activationIDs addObject:activation];
            }
        }

        [self _searchActivationIDs:activationIDs withProjectID:targetProjectID completion:completion];
    }];
}


- (void)_searchActivationIDs:(NSArray*)activations withProjectID:(NSString*)targetProjectID completion:(void(^)(BOOL done, NSString *theProjectOwner))completion
{
    NSInteger activationsCount = activations.count;
    if ( activationsCount == 0 )
    {
        // no s'ha trobat
        NSString *title = NSLocalizedString(@"Update Error", nil );
        NSString *format = NSLocalizedString(@"Could not find a suitable activation for project with identifier: %@", nil );
        NSString *message = [NSString stringWithFormat:format, targetProjectID];
        _errorWithLocalizedDescription_title(message, title);
        if ( completion ) completion( YES, nil );
        return;
    }
    
    NSString *activationID = activations.firstObject;
    [self _getRemoteFileMDOfActivationUUID_ck:activationID completion:^(FileMD *activationMD)
    {
        NSString *projectID = activationMD.identifier;
        if ( [projectID isEqualToString:targetProjectID] )
        {
            // ok l'hem trobat, passem el owner id
            NSString *ownerID = activationMD.ownerId;
            if ( completion ) completion( YES, ownerID );
        }
        else
        {
            // seguim buscant
            NSArray *restArray = [activations subarrayWithRange:NSMakeRange(1, activationsCount-1)];
            [self _searchActivationIDs:restArray withProjectID:targetProjectID completion:completion];
        }
    }];
}



- (void)validateProjectWithProjectID:(NSString*)projectID completion:(void(^)(BOOL done, BOOL result))block
{
    if ( HMiPadDev )
    {
        block( YES, NO );
        return;
    }

// per validar   -> buscar les redemptions amb aquest deviceID, buscar les activacions relacionades, comparar amb el project id fins que es trobi (o no). Si hi ha error donem per bo, si no hi ha error donem per bo només si s'ha trobat.

    UserProfile *profile = [cloudKitUser() currentUserProfile];

    if ( profile.isLocal )
    {
        block( NO, NO );
        return;
    }


    [self _searchValidatedProjectID:projectID completion:^(BOOL done, NSString *theProjectOwner)
    {
        BOOL result = (theProjectOwner.length > 0);
        block( done, result );
    }];
}



#endif
#pragma mark endif



#pragma mark no ck
#if !UseCloudKit
- (void)downloadRemoteProjectMD:(FileMD*)projectMD
{
    UserProfile *profile = [usersModel() currentUserProfile];
    if ( projectMD.userId == profile.userId )
    {
        [self _getFileListAndDownloadProjectForProjectMD:projectMD forProfile:profile embedded:NO redeemed:NO];
    }
    else
    {
        _errorWithLocalizedDescription_title(@"ss", @"ay");
    }
}



- (void)cancelDownload
{
    [self _cancelDownload];
}


#endif
#pragma mark endif

#pragma mark ck
#if UseCloudKit

- (void)downloadRemoteProjectMD:(FileMD*)projectMD
{
    UserProfile *profile = [cloudKitUser() currentUserProfile];
    NSString *userID = profile.token;
    [self _downloadProjectForProjectMD_ck:projectMD userID:userID embedded:NO redeemed:NO];
}


- (void)downloadEmbeddedRemoteProjectMD:(FileMD *)projectMD
{
    UserProfile *profile = [cloudKitUser() currentUserProfile];
    NSString *userID = profile.token;
    [self _downloadProjectForProjectMD_ck:projectMD userID:userID embedded:YES redeemed:NO];
}


- (void)cancelDownload
{
    // do nothing or TO DO
}


#endif
#pragma mark endif


//- (void)validateActivation:(NSString*)activationCode forProjectID:(NSString*)projectId
//    withOwnerID:(UInt32)projectOwner completion:(void(^)(BOOL))block
//{
//    UserProfile *profile = [usersModel() currentUserProfile];
//    if ( projectOwner == 0 ) projectOwner = profile.userId;
//    [self _validateActivation:activationCode forProjectID:projectId withOwnerID:projectOwner forProfile:profile completion:block];
//}






//- (void)_finalActivationWithUserId:(NSInteger)userId activationToken:(NSString*)token
//{
//    // aqui confirmar amb el servidor la redemption
//    NSLog1( @"FinalActivationWithUserId:%d token:%@", userId, token);
//}


//1. Set Device-UUID header to a unique string in the HTTPClient. (Perhaps add a setter here.) 
//2. POST to access_codes/<access_code>/redeem/ to claim the code. 
//3. POST/PUT/DELETE to access_codes/<access_code>/projects/ and access_codes/<access_code>/files/  to configure these. (Parameter is array of URLs of "files" or "projects")



//"url": "http://sw.noumenal.co.uk/access_codes/863a5284-7f8b-46d2-9b81-e53d26bcd47f/", 
//            "access_code": "863a5284-7f8b-46d2-9b81-e53d26bcd47f", 
//            "owner": "http://sw.noumenal.co.uk/users/36/", 
//            "created": "2013-02-27T09:19:05.799Z", 
//            "max_projects": 1, 
//            "max_redemptions": 1, 
//            "redemptions": [], 
//            "projects": [], 
//            "files": []
//





#pragma mark HMiPad Server Files


- (FileMD*)_newFileMDFromFileDict:(NSDictionary*)fileDict //category:(FileCategory)category
{
    FileMD *fileMD = [[FileMD alloc] init];
    
    fileMD.fileName = _dict_objectForKey(fileDict,@"name");;
    fileMD.identifier = _dict_objectForKey(fileDict,@"identifier");
    //fileMD.updated = [fileDict objectForKey:@"updated"];
    
    CFAbsoluteTime epoch = [_dict_objectForKey(fileDict,@"updated") doubleValue];
    //fileMD.updated = [[NSDate dateWithTimeIntervalSince1970:epoch] description];
    fileMD.date = [NSDate dateWithTimeIntervalSince1970:epoch];
    
    fileMD.location = _dict_objectForKey(fileDict,@"location");
    fileMD.remoteUrl = _dict_objectForKey(fileDict,@"url");
    
    NSString *fileOwnerURL = _dict_objectForKey(fileDict,@"owner");
    NSString *lastPath = [fileOwnerURL lastPathComponent];
    fileMD.userId = (UInt32)[lastPath integerValue];
    id fileSize = _dict_objectForKey(fileDict,@"file_size");
    fileMD.fileSize = [fileSize respondsToSelector:@selector(longLongValue)]?[fileSize longLongValue]:0;
    
    return fileMD;
}


- (FileMD*)_newActivationCodeFileMDFromFileDict:(NSDictionary*)fileDict //category:(FileCategory)category
{
    FileMD *fileMD = [[FileMD alloc] init];
    
    fileMD.fileName = _dict_objectForKey(fileDict,@"label");
    fileMD.identifier = _dict_objectForKey(fileDict,@"project_identifier");
    
    NSString *fileOwnerURL = _dict_objectForKey(fileDict,@"owner");
    NSString *lastPath = [fileOwnerURL lastPathComponent];
    fileMD.userId = (UInt32)[lastPath integerValue];
    
    // specific for access_codes
    
    CFAbsoluteTime epoch = [_dict_objectForKey(fileDict,@"created") doubleValue];
    //fileMD.created = [[NSDate dateWithTimeIntervalSince1970:epoch] description];
    fileMD.date = [NSDate dateWithTimeIntervalSince1970:epoch];
    
    fileMD.accessCode = _dict_objectForKey(fileDict,@"access_code");
    fileMD.maxProjects = [_dict_objectForKey(fileDict,@"max_projects") integerValue];
    fileMD.maxRedemptions = [_dict_objectForKey(fileDict,@"max_redemptions") integerValue];
    fileMD.redemptions = _dict_objectForKey(fileDict,@"redemptions");
    
    fileMD.productSKU = _dict_objectForKey(fileDict, @"product_sku");
    fileMD.productInfo = _dict_objectForKey(fileDict, @"product_info");
    
    NSArray *projects = _dict_objectForKey(fileDict,@"projects");
    NSMutableArray *projectIds = [NSMutableArray array];
    for ( NSString *project in projects )
    {
        NSString *projectID = [project lastPathComponent];
        [projectIds addObject:projectID];
    }
    
    if ( projects == nil )
    {
        NSString *projectID = _dict_objectForKey(fileDict,@"project_identifier");
        if ( projectID ) [projectIds addObject:projectID];
    }
    
    fileMD.projects = projectIds;
    
    //NSArray *files = _dict_objectForKey(fileDict,@"files");
    NSArray *files = _dict_objectForKey(fileDict,@"file_list");
    NSMutableArray *fileIds = [NSMutableArray array];
    for ( NSString *file in files )
    {
        NSString *fileID = [file lastPathComponent];
        [fileIds addObject:fileID];
    }
    fileMD.files = fileIds;
    
    return fileMD;
}





- (FileMD*)_newRedemptionFileMDFromFileDict:(NSDictionary*)fileDict
{
    FileMD *fileMD = [[FileMD alloc] init];
    
    fileMD.fileName = _dict_objectForKey(fileDict,@"label");
    
    NSString *identifierURL = _dict_objectForKey(fileDict,@"url");
    fileMD.identifier = [identifierURL lastPathComponent];
    
    NSString *fileEndUserURL = _dict_objectForKey(fileDict,@"end_user");
    NSString *lastPath = [fileEndUserURL lastPathComponent];
    fileMD.userId = [lastPath intValue];
    
    CFAbsoluteTime epoch = [_dict_objectForKey(fileDict,@"redeemed") doubleValue];
    fileMD.date = [NSDate dateWithTimeIntervalSince1970:epoch];
    
    NSString *accessCodeURL = _dict_objectForKey(fileDict,@"access_code");
    fileMD.accessCode = [accessCodeURL lastPathComponent];
    
    fileMD.deviceIdentifier = _dict_objectForKey(fileDict, @"device_uuid");
    
    return fileMD;
}





#pragma mark no ck
#if !UseCloudKit
- (void)_listRemoteFilesForCategory:(FileCategory)category
{
    UserProfile *profile = [usersModel() currentUserProfile];
    if ( profile.isLocal )
        return;
    
    BOOL waiting = [self _notifyRemoteFileListingWillChangeForCategory:category];
    if ( waiting )
        return;
    
    NSString *typeString = nil;
    if ( category == kFileCategoryRemoteSourceFile ) typeString = @"projects";
    else if ( category == kFileCategoryRemoteAssetFile ) typeString = @"files";
    else if ( category == kFileCategoryRemoteActivationCode ) typeString = @"access_codes";
    else if ( category == kFileCategoryRemoteRedemption ) typeString = @"redemptions";
    
    HMiPadServerAPIClient *client = [HMiPadServerAPIClient sharedClient];
    
    
//    NSString *path = [NSString stringWithFormat:@"users/%ld/%@/", profile.userId, typeString];
    NSString *path = [NSString stringWithFormat:@"%@/", typeString];
    
    NSDictionary *parameters = nil;
    
    NSURLRequest *trequest = [client requestWithMethod:@"GET" path:path token:profile.token parameters:parameters ];
    LogRequest;
    LogBody;
    
    [client enqueueRequest:trequest
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        LogSuccess;
        
        NSDictionary *responseDict = JSON;
        //NSArray *responseArray = JSON;
        
        //NSArray *responseArray = [responseDict objectForKey:typeString];
        NSArray *responseArray = _dict_objectForKey(responseDict, typeString);
        
        NSMutableArray *array = [NSMutableArray array];
        
      
        for ( NSDictionary *fileDict in responseArray )
        {
            FileMD *fileMD;
            if (category == kFileCategoryRemoteActivationCode)
                fileMD = [self _newActivationCodeFileMDFromFileDict:fileDict];
            
            else if (category == kFileCategoryRemoteRedemption)
                fileMD = [self _newRedemptionFileMDFromFileDict:fileDict];
            
            else
                fileMD = [self _newFileMDFromFileDict:fileDict];
            [array addObject:fileMD];
        }
        
        NSArray *__strong*files = [self _primitiveMDFilesArrayRefForCategory:category];
        *files = array;
        
        [self _sortFilesForCategory:category];
        [self _notifyRemoteFileListingDidChangeForCategory:category withError:nil];
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        LogFailure;
        NSArray *__strong*files = [self _primitiveMDFilesArrayRefForCategory:category];
        *files = [NSArray array];
        
        //NSString *title = NSLocalizedString(@"Remote Listing Error", nil );
        error = _completeErrorFromResponse_json_withError_title(response,JSON,error,nil);
        [self _notifyRemoteFileListingDidChangeForCategory:category withError:error];  //posar error
    }];
}



- (void)_deleteRemoteFileWithFileMD:(FileMD*)fileMD withCategory:(FileCategory)category
{
    NSString *fileName = fileMD.fileName;
    [self _notifyWillDeleteRemoteFile:fileName forCategory:category];

    NSString *typeString = nil;
    if ( category == kFileCategoryRemoteSourceFile ) typeString = @"projects";
    else if ( category == kFileCategoryRemoteAssetFile ) typeString = @"files";
    //else if ( category == kFileCategoryRemoteActivationCode ) typeString = @"access_codes";
    else if ( category == kFileCategoryRemoteRedemption ) typeString = @"redemptions";
    
    
    UserProfile *profile = [usersModel() currentUserProfile];
    
//    NSString *uuid = nil;
//    if ( category == kFileCategoryRemoteAssetFile )
//    {
//        uuid = [fileMD.fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    }
    
    NSString *uuid = fileMD.identifier;
    
    HMiPadServerAPIClient *client = [HMiPadServerAPIClient sharedClient];
    
    NSString *path = nil;
    if ( category == kFileCategoryRemoteRedemption )
    {
        path = [NSString stringWithFormat:@"%@/%@/", typeString, uuid];
    }
    else
    {
        path = [NSString stringWithFormat:@"%@/%u/%@/", typeString, (unsigned int)profile.userId, uuid];
    }
    NSDictionary *parameters = nil;
    
    NSURLRequest *trequest = [client requestWithMethod:@"DELETE" path:path token:profile.token parameters:parameters ];
    LogRequest;
    LogBody;

    [client enqueueRequest:trequest
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        LogSuccess;
        [self _notifyDidDeleteRemoteFile:fileName forCategory:category withError:nil];
        [self _listRemoteFilesForCategory:category];
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        LogFailure;
        NSString *title = NSLocalizedString(@"Delete Asset Error", nil );
        error = _completeErrorFromResponse_json_withError_title(response,JSON,error,title);
        [self _notifyDidDeleteRemoteFile:fileName forCategory:category withError:error];
    }];
}


- (void)_getRemoteFileMDOfFileUUID:(NSString*)uuid forCategory:(FileCategory)category
{
    //NSLog1( @"getRemoteFileMD uuid: %@", uuid );
    //[self _notifyWillUploadFile:fileName forCategory:inCategory];
    
    //UserProfile *profile = [usersModel() currentUserProfile];
    
    NSString *typeString = nil;
    if ( category == kFileCategoryRemoteSourceFile ) typeString = @"projects";
    else if ( category == kFileCategoryRemoteAssetFile ) typeString = @"files";
    else if ( category == kFileCategoryRemoteActivationCode ) typeString = @"access_codes";
    else if ( category == kFileCategoryRemoteRedemption ) typeString = @"redemptions";

    HMiPadServerAPIClient *client = [HMiPadServerAPIClient sharedClient];
    
    NSString *path = nil;
    //NSString *profileToken = nil;
    
    UserProfile *profile = [usersModel() currentUserProfile];
    if ( category == kFileCategoryRemoteActivationCode || category == kFileCategoryRemoteRedemption )
    {
        path = [NSString stringWithFormat:@"%@/%@/", typeString, uuid];
    }
    else
    {
       // UserProfile *profile = [usersModel() currentUserProfile];
        path = [NSString stringWithFormat:@"%@/%u/%@/", typeString, (unsigned int)profile.userId, uuid];
       // profileToken = profile.token;
    }

    //NSLog1( @"getRemoteFileMD path %@", path );
    
    NSDictionary *parameters = nil;
    NSURLRequest *trequest = [client requestWithMethod:@"GET" path:path token:profile.token parameters:parameters];
    LogRequest;
    LogBody;

    [client enqueueRequest:trequest
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        LogSuccess;
        
        NSDictionary *fileDict = JSON;
        FileMD *fileMD = nil;
        
        if (category == kFileCategoryRemoteActivationCode)
            fileMD = [self _newActivationCodeFileMDFromFileDict:fileDict];
        else
            fileMD = [self _newFileMDFromFileDict:fileDict];
    
        [self _notifyDidGetRemoteFileMD:fileMD forCategory:category withError:nil];
    }
    
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        LogFailure;
        error = _completeErrorFromResponse_json_withError_title(response,JSON,error,nil);
        
        [self _notifyDidGetRemoteFileMD:nil forCategory:category withError:error];
    }];
}



- (void)_redeemActivationCode:(NSString*)activationCode projectId:(NSString*)projectId ownerId:(UInt32)ownerId forProfile:(UserProfile*)profile
{
    UIDevice *thisDevice = [UIDevice currentDevice];
    
//    NSString *deviceID = [[thisDevice identifierForVendor] UUIDString];
    NSString *deviceID = [usersModel() identifierForApp];
    
//#warning aqui posar el nom del dispositiu
    NSString *label = [thisDevice name];
    
    NSLog1( @"Redeem activation code:%@  device:%@", activationCode, deviceID );
    
    [self _notifyWillRedeemCode:activationCode];

    HMiPadServerAPIClient *client = [HMiPadServerAPIClient sharedClient];
    
    //UserProfile *profile = [usersModel() currentUserProfile];
    NSString *path = [NSString stringWithFormat:@"access_codes/%@/redeem/",activationCode ];
    
    NSDictionary *parameters = @
    {
        @"label":label
    };
        
    NSURLRequest *trequest = [client requestWithMethod:@"PUT" path:path token:profile.token deviceId:deviceID parameters:parameters];
    LogRequest;
    LogBody;
    
    [client enqueueRequest:trequest
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        LogSuccess;
        
        //NSDictionary *responseDict = JSON;

        [self _notifyDidRedeemCode:activationCode withError:nil];
        
        if ( ownerId == 0 ) // activacio local
        {
            [self _notifyBeginGroupDownloadForCategory:kFileCategorySourceFile];
            [self _notifyEndGroupDownload:YES userCanceled:NO category:kFileCategorySourceFile];
            [self refreshMDArrayForCategory:kFileCategoryRemoteActivationCode];
        }
        else // si ens especifiquen un id iniciem ara el download
        {
            [self _getRedeemedRemoteProjectWithProjectID:projectId withOwnerID:ownerId forProfile:profile /*redeemed:YES*/];
        }
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        LogFailure;
        
        NSString *title = NSLocalizedString(@"Activation Processing Error", nil );
        //error = [self _completeErrorFromResponse:response json:JSON withError:error title:title];
        error = _completeErrorFromResponse_json_withError_title(response, JSON, error, title);
        NSLog1(@"%@", error);
        
        [self _notifyDidRedeemCode:activationCode withError:error];
    }];
}

- (void)_getRedeemedRemoteProjectWithProjectID:(NSString*)projectId withOwnerID:(UInt32)projectOwner forProfile:(UserProfile*)profile //redeemed:(BOOL)redeemed
{
//    NSString *deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *deviceID = [usersModel() identifierForApp];
    
    HMiPadServerAPIClient *client = [HMiPadServerAPIClient sharedClient];
    
    NSString *path = [NSString stringWithFormat:@"projects/%u/%@/end_user_info/", (unsigned int)projectOwner, projectId];
       
    NSDictionary *parameters = nil;
    NSURLRequest *trequest = [client requestWithMethod:@"GET" path:path token:profile.token deviceId:deviceID parameters:parameters];
    LogRequest;
    LogBody;

    [client enqueueRequest:trequest
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        LogSuccess;
        
        NSDictionary *fileDict = JSON;
        FileMD *projectMD = [self _newFileMDFromFileDict:fileDict];
        //[self _notifyDidGetRemoteFileMD:projectMD forCategory:kFileCategoryRedeemedSourceFile withError:nil];
        [self _notifyDidGetRemoteFileMD:projectMD forCategory:kFileCategorySourceFile withError:nil];
        
        [self _getFileListAndDownloadProjectForProjectMD:projectMD forProfile:profile embedded:YES redeemed:YES];
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        LogFailure;
        
        //NSString *title = NSLocalizedString(@"Get Asset Error", nil );
        error = _completeErrorFromResponse_json_withError_title(response,JSON,error,nil);
        //[self _notifyDidGetRemoteFileMD:nil forCategory:kFileCategoryRedeemedSourceFile withError:error];
        [self _notifyDidGetRemoteFileMD:nil forCategory:kFileCategorySourceFile withError:error];
    }];
}



- (void)_validateProjectID:(NSString*)projectId withOwnerID:(UInt32)projectOwner forProfile:(UserProfile*)profile completion:(void(^)(BOOL,BOOL))block
{
//    NSString *deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *deviceID = [usersModel() identifierForApp];
    
    HMiPadServerAPIClient *client = [HMiPadServerAPIClient sharedClient];
    
    if ( HMiPadDev )
        projectId = [@"*" stringByAppendingString:projectId];
    
    NSString *path = [NSString stringWithFormat:@"projects/%u/%@/end_user_info/", (unsigned int)projectOwner, projectId];
       
    NSDictionary *parameters = nil;
    NSURLRequest *trequest = [client requestWithMethod:@"GET" path:path token:profile.token deviceId:deviceID parameters:parameters];
    LogRequest;
    LogBody;

    [client enqueueRequest:trequest
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        LogSuccess;
        if ( block ) block(YES,YES);
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        LogFailure;
        BOOL done = (response.statusCode > 0);
        if ( block ) block(done,NO);
    }];
}



- (void)_getFileListAndDownloadProjectForProjectMD:(FileMD*)projectMD forProfile:(UserProfile*)profile embedded:(BOOL)embedded redeemed:(BOOL)redeemed
{
    NSString *identifier = projectMD.identifier;
    UInt32 projectOwner = projectMD.userId;
    NSLog1( @"getRedeemedFileListProject uuid: %@", projectMD.identifier );
    //[self _notifyWillUploadFile:fileName forCategory:inCategory];


    HMiPadServerAPIClient *client = [HMiPadServerAPIClient sharedClient];
    
    NSString *path = [NSString stringWithFormat:@"projects/%u/%@/files/", (unsigned int)projectOwner, identifier];
    NSLog1( @"getRedeemedRemoteFileMD path %@", path );
    
//    NSString *deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *deviceID = [usersModel() identifierForApp];
    
    NSDictionary *parameters = nil;
    NSURLRequest *trequest = [client requestWithMethod:@"GET" path:path token:profile.token deviceId:deviceID parameters:parameters];
    LogRequest;
    LogBody;
    
    [client enqueueRequest:trequest
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        LogSuccess;
        
        NSDictionary *fileDict = JSON;
        NSArray *files = [fileDict objectForKey:@"file_list"];
        NSMutableSet *unmatchedFiles = [NSMutableSet setWithArray:files];
        
        NSArray *fileObjects = [fileDict objectForKey:@"matched_files"];
        NSMutableArray *assetMDs = [NSMutableArray array];
        for ( NSDictionary *fileObjDict in fileObjects )
        {
            FileMD *assetMD = [self _newFileMDFromFileDict:fileObjDict];
            NSString *fileIdent = assetMD.identifier;
            [unmatchedFiles removeObject:fileIdent];
            
            [assetMDs addObject:assetMD];
        }
        
        NSLog1( @"UnmatchedFiles: %@", unmatchedFiles );
        
        [self _downloadProjectWithMD:projectMD remoteAssetsMDs:assetMDs profile:profile embedded:embedded redeemed:redeemed];
    
        //[self _notifyDidGetRemoteFileMD:fileMD forCategory:category withError:nil];
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        LogFailure;
        
        //NSString *title = NSLocalizedString(@"Get Asset Error", nil );
        error = _completeErrorFromResponse_json_withError_title(response,JSON,error,nil);
        //[self _notifyDidGetRemoteFileMD:nil forCategory:kFileCategoryRedeemedSourceFile withError:error];
        [self _notifyDidGetRemoteFileMD:nil forCategory:kFileCategorySourceFile withError:error];
    }];

}



#endif
#pragma mark endif


#pragma mark ck
#if UseCloudKit

- (FileMD*)_newFileMDFromCKRecord:(CKRecord*)record //category:(FileCategory)category
{
    FileMD *fileMD = [[FileMD alloc] init];
    
    fileMD.fileName = record[@"name"];
    fileMD.identifier = record[@"identifier"];
    fileMD.files = record[@"assets"];  // tornara nil si no es un projecte
    
    fileMD.date = record.modificationDate;
    
    fileMD.location = nil;
    fileMD.remoteUrl = nil;
    
    fileMD.userId = 0;
    
    CKRecord *ownerRecord = record[@"owner"];
    CKRecordID *ownerRecordID = ownerRecord.recordID;
    fileMD.ownerId = ownerRecordID.recordName;
    
    fileMD.fileSize = [record[@"fileSize"] longLongValue];
    
    return fileMD;
}



- (FileMD*)_newActivationCodeFileMDFromCKRecord:(CKRecord*)record
{
    FileMD *fileMD = [[FileMD alloc] init];
    
    fileMD.fileName = record[@"name"];
    fileMD.identifier = record[@"projectIdentifier"];
    
    fileMD.userId = 0;
    
    CKRecord *ownerRecord = record[@"owner"];
    CKRecordID *ownerRecordID = ownerRecord.recordID;
    fileMD.ownerId = ownerRecordID.recordName;
    
    // specific for access_codes
    
    fileMD.date = record.modificationDate;
    
    fileMD.accessCode = record[@"identifier"];
    fileMD.maxProjects = 1;
    fileMD.maxRedemptions = [record[@"maxRedemptions"] integerValue];
    fileMD.redemptions = nil;
    
    fileMD.productSKU = record[@"productSKU"];
    fileMD.productInfo = record[@"productInfo"];
    
    fileMD.projects = @[record[@"projectIdentifier"]];
    fileMD.files = @[];
    
    return fileMD;
}


- (FileMD*)_newRedemptionFileMDFromCKRecord:(CKRecord*)record
{
    FileMD *fileMD = [[FileMD alloc] init];
    
    fileMD.deviceIdentifier = record[@"deviceIdentifier"];
    fileMD.fileName = record[@"deviceName"];
    
    fileMD.userId = 0;
    
    CKRecord *ownerRecord = record[@"endUser"];
    CKRecordID *ownerRecordID = ownerRecord.recordID;
    fileMD.ownerId = ownerRecordID.recordName;
    
//    CKRecord *accessCodeRecord = record[@"parentActivation"];
//    CKRecordID *accessCodeRecordID = accessCodeRecord.recordID;
    fileMD.accessCode = record[@"parentActivation"];
    
    //fileMD.identifier = record[@"identifier"];
    
    fileMD.date = record.modificationDate;
    
    
    
    CKRecordID *recordID = record.recordID;
    fileMD.identifier = recordID.recordName;
    
    return fileMD;
}




- (void)_listRemoteFilesForCategory:(FileCategory)category
{
    [self _listRemoteFilesForCategory:category completion:nil];
}



- (void)_listRemoteFilesForCategory:(FileCategory)category completion:(void(^)(NSArray *fileMDs))completion
{
    UserProfile *profile = [cloudKitUser() currentUserProfile];
    if ( profile.isLocal )
    {
        if (completion) completion( nil );
        return;
    }
    
    BOOL waiting = [self _notifyRemoteFileListingWillChangeForCategory:category];
    if ( waiting )
        return;
    
    NSString *recordType = nil;
    if ( category == kFileCategoryRemoteSourceFile ) recordType = @"Projects";
    else if ( category == kFileCategoryRemoteAssetFile ) recordType = @"Assets";
    else if ( category == kFileCategoryRemoteActivationCode ) recordType = @"Activations";
    else if ( category == kFileCategoryRemoteRedemption ) recordType = @"Redemptions";
    
    NSString *ownerKey = @"owner";
    if (category == kFileCategoryRemoteRedemption ) ownerKey = @"endUser";
    
    NSArray *desiredKeys = nil;
    if ( category == kFileCategoryRemoteSourceFile )
    {
        desiredKeys = @[@"name",@"identifier",@"owner",@"fileSize",@"assets"];
    }
    if ( category == kFileCategoryRemoteAssetFile )
    {
        desiredKeys = @[@"name",@"identifier",@"owner",@"fileSize"];
    }
    
    // owner
    NSString *ownerIdentifier = profile.token;
    CKRecordID *ownerRecordId = [[CKRecordID alloc] initWithRecordName:ownerIdentifier];
    CKReference *owner = [[CKReference alloc] initWithRecordID:ownerRecordId action:CKReferenceActionDeleteSelf];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", ownerKey, owner];     // busquem les que son d'aquest owner o endUser
    CKQuery *query = [[CKQuery alloc] initWithRecordType:recordType predicate:predicate];
    CKQueryOperation *queryOperation = [[CKQueryOperation alloc] initWithQuery:query];
    
    queryOperation.desiredKeys = desiredKeys;
    
    void (^queryFinishBlock)(NSArray *, NSError *) = ^(NSArray *results, NSError *queryCompletionError)
    {
        if ( queryCompletionError == nil )
        {
            NSMutableArray *array = [NSMutableArray array];
            for ( CKRecord *record in results )
            {
                FileMD *fileMD;
                if (category == kFileCategoryRemoteActivationCode)
                    fileMD = [self _newActivationCodeFileMDFromCKRecord:record];
                else if (category == kFileCategoryRemoteRedemption)
                    fileMD = [self _newRedemptionFileMDFromCKRecord:record];
                else
                    fileMD = [self _newFileMDFromCKRecord:record];
    
                [array addObject:fileMD];
            }
            
            void (^finishBlock)(BOOL) = ^(BOOL success)
            {
                NSArray *__strong*files = [self _primitiveMDFilesArrayRefForCategory:category];
                *files = array;

                [self _sortFilesForCategory:category];
                [self _notifyRemoteFileListingDidChangeForCategory:category withError:nil];
                if ( completion ) completion( array );   // array pot ser buit
            };
                    
            if ( category == kFileCategoryRemoteActivationCode )
            {
                [self _setupRemoteRedemptions:array index:0 completion:finishBlock];
            }
            //else
            {
                finishBlock( YES );
            }
        }
        else
        {
            NSArray *__strong*files = [self _primitiveMDFilesArrayRefForCategory:category];
            *files = [NSArray array];
        
            //NSString *title = NSLocalizedString(@"Upload Error", nil );
            NSString *format = NSLocalizedString(@"Could not fetch data from iCloud. Reason: %@", nil );
            NSString *message = [NSString stringWithFormat:format, queryCompletionError];
            NSError *error = _errorWithLocalizedDescription_title(message, nil);
            [self _notifyRemoteFileListingDidChangeForCategory:category withError:error];  //posar error
            if ( completion ) completion( nil );  // nil vol dir error
        }
    };
    
    [self _performLongQueryOperation:queryOperation queryFinishBlock:queryFinishBlock];
}




- (void)_setupRemoteRedemptions:(NSArray *)activationMDs index:(NSInteger)index completion:(void(^)(BOOL))completion
{
    if ( index >= activationMDs.count )
    {
        completion( YES );
        return;
    }
                        
    FileMD *activationMD = [activationMDs objectAtIndex:index];
    [self _countRemoteRedemptionsForActivationMD:activationMD completion:^(NSArray *redemptions)
    {
        activationMD.redemptions = redemptions;
        [self _setupRemoteRedemptions:activationMDs index:index+1 completion:completion];
    }];
};


- (void)_countRemoteRedemptionsForActivationMD:(FileMD*)activationMD completion:(void(^)(NSArray* array))completion
{
    UserProfile *profile = [cloudKitUser() currentUserProfile];
    if ( profile.isLocal )
    {
        completion( nil );
        return;
    }
    
    NSString *recordType = @"Redemptions";
    NSArray *desiredKeys = @[@"identifier"];
    
    // parentActivation
//    NSString *parentAcIdentifier = activationMD.accessCode;
//    CKRecordID *parentAcRecordId = [[CKRecordID alloc] initWithRecordName:parentAcIdentifier];
//    CKReference *parentActivation = [[CKReference alloc] initWithRecordID:parentAcRecordId action:CKReferenceActionDeleteSelf];
    
    NSString *parentActivation = activationMD.accessCode;

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"parentActivation", parentActivation];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:recordType predicate:predicate];
    CKQueryOperation *queryOperation = [[CKQueryOperation alloc] initWithQuery:query];
    
    queryOperation.desiredKeys = desiredKeys;
 
    void (^queryFinishBlock)(NSArray *, NSError *) = ^(NSArray *results, NSError *queryCompletionError)
    {
        if ( queryCompletionError == nil )
        {
            NSMutableArray *array = [NSMutableArray array];
            for ( CKRecord *record in results )
            {
                FileMD *fileMD = [self _newRedemptionFileMDFromCKRecord:record];
                [array addObject:fileMD];
            }

            completion( array );
        }
        else
        {
            completion ( @[] );
        }
    };
    
    [self _performLongQueryOperation:queryOperation queryFinishBlock:queryFinishBlock];
}





- (void)_deleteRemoteFileWithFileMD:(FileMD*)fileMD withCategory:(FileCategory)category
{
    NSString *fileName = fileMD.fileName;
    
    UserProfile *profile = [cloudKitUser() currentUserProfile];
    
    NSString *uuid = fileMD.identifier;
    NSString *ownerIdentifier = profile.token;
    
    NSString *recordName = nil;
    if ( category == kFileCategoryRemoteSourceFile || category == kFileCategoryRemoteAssetFile )
    {
        recordName = [NSString stringWithFormat:@"%@@%@", uuid, ownerIdentifier];
    }
    else if ( category == kFileCategoryRemoteActivationCode )
    {
        // nor!
    }
    else if ( category == kFileCategoryRemoteRedemption )
    {
        recordName = uuid;
    }
    
    if ( recordName == nil )
        return;
    
    CKRecordID *recordId = [[CKRecordID alloc] initWithRecordName:recordName];
    //CKRecord *theRecord = [[CKRecord alloc] initWithRecordType:recordType recordID:recordId];
    
    [self _notifyWillDeleteRemoteFile:fileName forCategory:category];
    
    CKModifyRecordsOperation *modifyOperation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:nil recordIDsToDelete:@[recordId]];
    
    [modifyOperation setPerRecordCompletionBlock:^(CKRecord *record, NSError *recordCompletionError)
    {
        //final per record
        NSLog(@"%@ ERR %@", NSStringFromSelector(_cmd), recordCompletionError);
    }];
        
    [modifyOperation setModifyRecordsCompletionBlock:^(NSArray /* CKRecord */ *savedRecords,
        NSArray /* CKRecordID */ *deletedRecordIDs, NSError *operationError)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if ( operationError == nil )
            {
                [self _notifyDidDeleteRemoteFile:fileName forCategory:category withError:nil];
                [self _listRemoteFilesForCategory:category];
            }
            else
            {
                NSString *title = NSLocalizedString(@"Delete File Error", nil );
                NSString *message = NSLocalizedString(@"Could not delete iCloud file", nil );
                NSError *error = _completeErrorFromCloudKitError_message_title(operationError, message, title);
                [self _notifyDidDeleteRemoteFile:fileName forCategory:category withError:error];
            }
        });
    }];
    
    [[_filesModel ckDatabase] addOperation:modifyOperation];
}


- (void)_getRemoteFileMDOfFileUUID_ck:(NSString*)uuid ownerId:(NSString*)ownerId forCategory:(FileCategory)category
{
//    UserProfile *profile = [cloudKitUser() currentUserProfile];
//    NSString *ownerIdentifier = profile.token;
    
    NSString *ownerIdentifier = ownerId;
    
    NSString *recordName = [NSString stringWithFormat:@"%@@%@", uuid, ownerIdentifier];
    
    if ( recordName == nil )
    {
        return;
    }
    
    CKRecordID *recordId = [[CKRecordID alloc] initWithRecordName:recordName];
    
    NSArray *desiredKeys = @[@"name",@"identifier",@"owner",@"fileSize"];
    
    CKFetchRecordsOperation *fetchOperation = [[CKFetchRecordsOperation alloc] initWithRecordIDs:@[recordId]];
    fetchOperation.desiredKeys = desiredKeys;
    
    [fetchOperation setPerRecordCompletionBlock:^(CKRecord *record, CKRecordID* recordID, NSError *recordCompletionError)
    {
        //final per record
        NSLog(@"%@ ERR %@", NSStringFromSelector(_cmd), recordCompletionError);
    }];

    [fetchOperation setFetchRecordsCompletionBlock:^(NSDictionary *recordsByRecordID, NSError *operationError)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            FileMD *fileMD = nil;
            if ( operationError == nil )
            {
                NSArray *records = recordsByRecordID.allValues;
                CKRecord *record = records.firstObject;
                fileMD = [self _newFileMDFromCKRecord:record];
                [self _notifyDidGetRemoteFileMD:fileMD forCategory:category withError:nil];
            }
            else
            {
                NSString *message = NSLocalizedString( @"Could not retrieve data from iCloud", nil);
                NSError *error = _completeErrorFromCloudKitError_message_title(operationError, message, nil);
                [self _notifyDidGetRemoteFileMD:nil forCategory:category withError:error];
            }
        });
    }];

    [[_filesModel ckDatabase] addOperation:fetchOperation];
}


- (void)_getRemoteFileMDOfActivationUUID_ck:(NSString*)uuid completion:(void(^)(FileMD *fileMD))completion
{
    NSString *recordType = @"Activations";
    NSArray *desiredKeys = nil;

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"identifier", uuid];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:recordType predicate:predicate];
    CKQueryOperation *queryOperation = [[CKQueryOperation alloc] initWithQuery:query];
    
    queryOperation.desiredKeys = desiredKeys;
 
    void (^queryFinishBlock)(NSArray *, NSError *) = ^(NSArray *results, NSError *queryCompletionError)
    {
        FileMD *fileMD = nil;
        NSError *error = nil;
        if ( queryCompletionError != nil )
        {
            NSString *title = NSLocalizedString(@"Activation Error", nil );
            NSString *message = NSLocalizedString( @"Could not retrieve data from iCloud", nil);
            error = _completeErrorFromCloudKitError_message_title(queryCompletionError, message, title);
        }
        else
        {
            CKRecord *record = results.firstObject;
            if ( record == nil )
            {
                NSString *title = NSLocalizedString(@"Activation Error", nil );
                NSString *message = NSLocalizedString(@"Activation code was not found on the server", nil );
                error = _errorWithLocalizedDescription_title(message, title);
            }
            else
            {
                fileMD = [self _newActivationCodeFileMDFromCKRecord:record];
                
            }
        }

        [self _notifyDidGetRemoteFileMD:fileMD forCategory:kFileCategoryRemoteActivationCode withError:error];
        if ( completion ) completion(fileMD);
    };
    
    [self _performLongQueryOperation:queryOperation queryFinishBlock:queryFinishBlock];
}



- (void)_redeemActivationCodeMD:(FileMD*)activationMD forProfile:(UserProfile*)profile
{
    NSString *accessCode = activationMD.accessCode;
    NSString *activationOwnerId = activationMD.ownerId;
    NSString *projectId = activationMD.identifier;
    NSInteger maxRedemptions = activationMD.maxRedemptions;
    
    [self _notifyWillRedeemCode:accessCode];
    
    // 1 - busca les redemptions amb aquest activation code

    [self _searchRedemptionsForActivationCodeMD:activationMD completion:^(NSError *searchError, NSArray *redemptions)
    {
        if ( searchError != nil )
        {
            [self _notifyDidRedeemCode:accessCode withError:searchError];
            return;
        }
        
        // 2 determina la redemptio amb aquest device id i user id
    
        FileMD *foundRedemptionMD = nil;
        NSString *deviceID = [cloudKitUser() identifierForApp];
        NSString *endUserID = [cloudKitUser() currentUserUUID];

        for ( FileMD *redemptionMD in redemptions )
        {
            if ( [redemptionMD.deviceIdentifier isEqualToString:deviceID] && [redemptionMD.ownerId isEqualToString:endUserID] )
            {
                foundRedemptionMD = redemptionMD;
                break;
            }
        }
    
        //   si existeix, ok baixar projecte
        if ( foundRedemptionMD != nil )
        {
            [self _notifyDidRedeemCode:accessCode withError:nil];
            [self _getRedeemedRemoteProjectWithProjectID_ck:projectId withOwnerID:activationOwnerId];
        }
        
        // si no existeix, l'haurem de crear
        else
        {
            // primer mirem si en tenim disponibles
            
            if ( redemptions.count >= maxRedemptions )
            // no en queda cap
            {
                NSString *title = NSLocalizedString(@"Redemption Error", nil);
                NSString *format = NSLocalizedString(@"\nNo more redemptions are allowed for the provided activation code.\n\nYou can unlock additional redemptions by deleting unused ones", nil);
                NSString *message = [NSString stringWithFormat:format, nil];
                NSError *error = _errorWithLocalizedDescription_title(message, title);
                [self _notifyDidRedeemCode:accessCode withError:error];
            }
            
            else
            // en queden, en creem una de nova i baixem projecte
            {
                FileMD *redemptionMD = [[FileMD alloc] init];
                redemptionMD.deviceIdentifier = deviceID;
                redemptionMD.fileName = [[UIDevice currentDevice] name]; // device name
                redemptionMD.ownerId = endUserID;
                redemptionMD.accessCode = accessCode;
                [self _postRedeemtionWithRedemptionMD_ck:redemptionMD completion:^(NSError *createRedemtionError)
                {
                    [self _notifyDidRedeemCode:accessCode withError:createRedemtionError];
                    if ( createRedemtionError == nil  )
                    {
                        // baixem el projecte si hem creat la activacio
                        [self _getRedeemedRemoteProjectWithProjectID_ck:projectId withOwnerID:activationOwnerId];
                    }
                }];
            }
        }
    }];


}




- (void)_searchRedemptionsForActivationCodeMD:(FileMD*)activationMD completion:(void (^)(NSError *error, NSArray *redemptions ))completion
{

    if ( activationMD == nil )
    {
        completion( nil, nil );   // no error but no redemptions
        return;
    }

    NSString *recordType = @"Redemptions";
    NSArray *desiredKeys = nil;
    
    // activation
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"parentActivation", activationMD.accessCode];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:recordType predicate:predicate];
    CKQueryOperation *queryOperation = [[CKQueryOperation alloc] initWithQuery:query];
    
    queryOperation.desiredKeys = desiredKeys;

    void (^queryFinishBlock)(NSArray*, NSError*) = ^(NSArray *results, NSError *queryOperationError)
    {
        if ( queryOperationError == nil )
        {
            NSMutableArray *array = [NSMutableArray array];
            for ( CKRecord *ckRecord in results )
            {
                FileMD *redemptionMD = [self _newRedemptionFileMDFromCKRecord:ckRecord];
                [array addObject:redemptionMD];
            }
            completion( nil, array );  // no error, pass array of redemptions
        }
        else
        {
            NSString *title = NSLocalizedString(@"Redemption Error", nil);
            NSString *format = NSLocalizedString(@"Could not access redemptions database", nil);
            NSString *message = [NSString stringWithFormat:format, nil];
            NSError * error = _completeErrorFromCloudKitError_message_title(queryOperationError, message, title);
            completion( error, nil);   // error, and no redemptions
        }
    };

    [self _performLongQueryOperation:queryOperation queryFinishBlock:queryFinishBlock];
}



- (void)_postRedeemtionWithRedemptionMD_ck:(FileMD*)redemptionMD completion:(void(^)(NSError *error))completion
{
    
    NSString *recordType = @"Redemptions";
    CKRecord *record = [[CKRecord alloc] initWithRecordType:recordType];
    
    // device id
    record[@"deviceIdentifier"] = redemptionMD.deviceIdentifier;

    // device name
    record[@"deviceName"] = redemptionMD.fileName;
    
    // end user
    NSString *endUserId  = redemptionMD.ownerId;
    CKRecordID *ownerRecordId = [[CKRecordID alloc] initWithRecordName:endUserId];
    CKReference *endUser = [[CKReference alloc] initWithRecordID:ownerRecordId action:CKReferenceActionDeleteSelf];
    [record setObject:endUser forKey:@"endUser"];
    
    // parent activation
    record[@"parentActivation"] = redemptionMD.accessCode;
    
    // touch date
    record[@"touchDate"] = [NSDate dateWithTimeIntervalSinceNow:0];
    
    
    CKModifyRecordsOperation *modifyOperation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:@[record] recordIDsToDelete:nil];
    
    [modifyOperation setSavePolicy:CKRecordSaveChangedKeys];
    
    
    [modifyOperation setModifyRecordsCompletionBlock:^(NSArray /* CKRecord */ *savedRecords,
        NSArray /* CKRecordID */ *deletedRecordIDs, NSError *operationError)
    {
        //final end
        
        //NSLog( @"final end: %@", operationError );
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if ( operationError != nil )
            {
                NSString *title = NSLocalizedString(@"Redemption Error", nil );
                NSString *message = NSLocalizedString(@"Could not create Redemption", nil );
                NSError *error = _completeErrorFromCloudKitError_message_title(operationError, message, title);
                NSLog1(@"%@", error);
                completion( error );
            }
            else
            {
                completion( nil );
            }
        });
    }];
    
    [[_filesModel ckDatabase] addOperation:modifyOperation];
}





- (void)_getRedeemedRemoteProjectWithProjectID_ck:(NSString*)projectId withOwnerID:(NSString*)projectOwner
{
    NSString *recordName = [NSString stringWithFormat:@"%@@%@", projectId, projectOwner];
    CKRecordID *projectRecordID = [[CKRecordID alloc] initWithRecordName:recordName];

    CKFetchRecordsOperation *fetchOperation = [[CKFetchRecordsOperation alloc] initWithRecordIDs:@[projectRecordID]];
    NSArray *desiredKeys = @[@"name",@"owner",@"identifier",@"assets",@"fileSize"];
    
    //FileMD *projectMD = [[FileMD alloc] init];
    __block FileMD *projectMD = nil;
    
    fetchOperation.desiredKeys = desiredKeys;
    [fetchOperation setPerRecordCompletionBlock:^(CKRecord *record, CKRecordID *recordID, NSError *perRecordError)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if ( perRecordError != nil )
            {
                //NSLog( @"perRecordError:%@", perRecordError );
            }
            else
            {
                projectMD = [self _newFileMDFromCKRecord:record];
            }
        });
    }];
    
    [fetchOperation setFetchRecordsCompletionBlock:^(NSDictionary *recordsByRecordID, NSError *operationError)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            NSError *error = nil;
            if ( operationError != nil )
            {
                NSString *title = NSLocalizedString(@"Download Error", nil );
                NSString *message = NSLocalizedString(@"Could not download project data from iCloud", nil );
                error = _completeErrorFromCloudKitError_message_title(operationError, message, title);
            }
            else
            {
                if ( projectMD == nil )
                {
                    NSString *title = NSLocalizedString(@"Download Error", nil );
                    NSString *message = NSLocalizedString(@"Project was not found on the server", nil );
                    error = _errorWithLocalizedDescription_title(message, title);
                }
                else
                {
                    [self _downloadProjectForProjectMD_ck:projectMD userID:projectOwner embedded:YES redeemed:YES];
                }
            }
            
            [self _notifyDidGetRemoteFileMD:projectMD forCategory:kFileCategorySourceFile withError:error];
        });
    }];
    [[_filesModel ckDatabase] addOperation:fetchOperation];
}



- (void)_performLongQueryOperation:(CKQueryOperation *)queryOperation queryFinishBlock:(void (^)(NSArray *, NSError *))queryFinishBlock
{
    NSMutableArray *results = [NSMutableArray array];
    [self _performLongQueryOperation:queryOperation pastResults:results queryFinishBlock:queryFinishBlock];
}


- (void)_performLongQueryOperation:(CKQueryOperation *)queryOperation pastResults:(NSMutableArray*)results queryFinishBlock:(void (^)(NSArray *, NSError *))queryFinishBlock
{
    [queryOperation setRecordFetchedBlock:^(CKRecord *ckRecord)
    {
        [results addObject:ckRecord];
    }];
    
    [queryOperation setQueryCompletionBlock:^(CKQueryCursor *cursor, NSError *queryCompletionError)
    {
        if ( cursor != nil )
        {
            CKQueryOperation *moreQuery = [[CKQueryOperation alloc] initWithCursor:cursor];
            [self _performLongQueryOperation:moreQuery pastResults:results queryFinishBlock:queryFinishBlock];
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^
        {
            queryFinishBlock( results, queryCompletionError );
        });
    
    }];
    
    [[_filesModel ckDatabase] addOperation:queryOperation];
};



#endif
#pragma mark endif



#pragma mark download


#pragma mark no ck
#if !UseCloudKit

- (void)_downloadRemoteFileMDs:(NSArray*)fileMDs forCategory:(FileCategory)fileCategory profile:(UserProfile*)profile
{
    [self _notifyBeginGroupDownloadForCategory:fileCategory];
    [self _notifyGroupDownloadProgressStep:0 stepCount:fileMDs.count category:fileCategory];
    
    [self _download:fileMDs category:fileCategory projectName:nil profile:profile index:0 redeemed:NO];
}



- (void)_cancelDownload
{
    if ( _currentDownloadPath )
    {
        HMiPadServerAPIClient *client = [HMiPadServerAPIClient sharedClient];
        [client cancelAllHTTPOperationsWithMethod:@"GET" path:_currentDownloadPath];
        _currentDownloadPath = nil;
        [self _download:nil category:kFileCategoryUnknown projectName:nil profile:nil index:NSNotFound redeemed:NO];
    }
}


- (void)_primitiveDownloadWithFileMD:(FileMD*)fileMD category:(FileCategory)category projectName:(NSString*)projectName profile:(UserProfile*)profile redeemed:(BOOL)redeemed completion:(void(^)(BOOL))block
{
//    NSString *deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *deviceID = [usersModel() identifierForApp];
    
    NSString *fileName = fileMD.fileName;
    
    [self _notifyWillDownloadFile:fileName category:category];

    HMiPadServerAPIClient *client = [HMiPadServerAPIClient sharedClient];
    
    NSString *typeString = nil;
    if ( category == kFileCategoryRemoteSourceFile /*|| category == kFileCategoryRemoteGroupRedeemedSourceFile*/ ||
        category == kFileCategoryRemoteGroupSourceFile) typeString = @"projects";
    
    else if ( category == kFileCategoryRemoteAssetFile /*|| category == kFileCategoryRemoteGroupRedeemedAssetFile*/ ||
        category == kFileCategoryRemoteGroupAssetFile) typeString = @"files";
    
    NSString *path = [NSString stringWithFormat:@"%@/%u/%@/download/", typeString, (unsigned int)fileMD.userId, fileMD.identifier ];
    
    //NSString *path = [NSString stringWithFormat:@"media/%@", location];
    NSLog1( @"Downloading file \"%@\" at path %@", fileName, path );
    
    _currentDownloadPath = path;
    NSDictionary *parameters = nil;
    NSMutableURLRequest *trequest = [client requestWithMethod:@"GET" path:path token:profile.token
        deviceId:deviceID parameters:parameters];
    
    LogRequest;
    LogBody;
    
    [trequest setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    
    BOOL shouldEncrypt = redeemed && (category == kFileCategoryRemoteGroupSourceFile);
    NSString *outFilePath = [_filesModel.filePaths temporaryFilePathForFileName:fileName];
    
    [client enqueueRequestForDownload:trequest outputFilePath:shouldEncrypt?nil:outFilePath
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data)
    {
        id JSON = nil;
        (void)JSON;
        LogSuccess;
        
        NSError *error = nil;
        BOOL success = YES;
        if ( shouldEncrypt )
        {
            data = [data encrypt];
            
            success = [data writeToFile:outFilePath options:NSDataWritingAtomic error:&error];
        }
        
        if ( success )
        {
            FileCategory destCategory = kFileCategoryUnknown;
            if ( category == kFileCategoryRemoteAssetFile ) destCategory = kFileCategoryAssetFile;
        
            else if ( category == kFileCategoryRemoteSourceFile ) destCategory = kFileCategorySourceFile;
        
            else if ( category == kFileCategoryRemoteGroupSourceFile) destCategory = kFileCategoryTemporarySourceFile;
        
            else if ( category == kFileCategoryRemoteGroupAssetFile) destCategory = kFileCategoryTemporaryEmbedeedAssetFile;
        
            [self moveFromTemporaryToCategory:destCategory forFile:fileName projectName:projectName isEncrypted:shouldEncrypt addCopy:NO error:&error];
            [self _notifyDidDownloadFile:fileName category:category withError:error];
        }
        
        if ( block ) block(error==nil);
    }
    
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
    {
        id JSON = nil;
        LogFailure;
        
        NSString *title = NSLocalizedString(@"Download Error", nil );
        NSString *message = NSLocalizedString(@"Could not download file from the integrators service", nil );
        //error = [self _completeErrorFromResponse:response json:JSON withError:error title:title message:message];
        error = _completeErrorFromResponse_json_withError_title_message(response, JSON, error, title, message);
        [self _notifyDidDownloadFile:fileName category:category withError:error];
        if ( block ) block(NO);

    }
    
    downProgress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
    {
        [self _notifyFileDownloadProgressBytesRead:totalBytesRead totalBytesExpected:totalBytesExpectedToRead category:category];
    }];
}





- (void)_download:(NSArray*)fileMDs category:(FileCategory)fileCategory projectName:(NSString*)projectName profile:(UserProfile*)profile index:(NSInteger)index redeemed:(BOOL)redeemed
{
    NSInteger count = fileMDs.count;
    
    if (count > 0 )
        [self _notifyGroupDownloadProgressStep:index==NSNotFound?0:index stepCount:count category:fileCategory];
    
    if ( index < count )
    {
        FileMD *fileMD = [fileMDs objectAtIndex:index];
        [self _primitiveDownloadWithFileMD:fileMD category:fileCategory projectName:projectName profile:profile redeemed:redeemed
        completion:^(BOOL success)
        {
            [self _download:fileMDs category:fileCategory projectName:projectName profile:profile index:(success?index+1:NSNotFound) redeemed:redeemed];
        }];
    }
    else // inclueix NSNotfound
    {
        BOOL success = (index==count);
        if ( success )
        {
            if ( fileCategory == kFileCategoryRemoteGroupSourceFile || fileCategory == kFileCategoryRemoteGroupAssetFile )
            {
                NSError *error = nil;
                if ( redeemed )
                {
                    //[self moveToProjectsForTemporaryProject:projectName error:&error];
                    // aqui close
                    [self moveToRedemmedProjectsForTemporaryProject:projectName error:&error];
                }
                else
                {
                    [self moveToProjectsForTemporaryProject:projectName error:&error]; 
                }
            }
        }
    
        [self _notifyEndGroupDownload:success userCanceled:(_currentDownloadPath==nil) category:fileCategory];
        _currentDownloadPath = nil;
    }
}

- (void)_downloadProjectWithMD:(FileMD*)projectMD remoteAssetsMDs:(NSArray*)assetsMDs profile:(UserProfile*)profile embedded:(BOOL)embedded redeemed:(BOOL)redeemed
{
   // [self _notifyGroupDownloadProgressStep:0 stepCount:fileMDs.count category:fileCategory];
   
    FileCategory sourceCategory = embedded?kFileCategoryRemoteGroupSourceFile:kFileCategoryRemoteSourceFile;
    FileCategory assetCategory = embedded?kFileCategoryRemoteGroupAssetFile:kFileCategoryRemoteAssetFile;
        
//    FileCategory sourceCategory = kFileCategoryRemoteGroupSourceFile;
//    FileCategory assetCategory = kFileCategoryRemoteGroupAssetFile;
    
    [self _notifyBeginGroupDownloadForCategory:sourceCategory];
    
    NSString *projectName = projectMD.fileName;
    
    // baixem el projecte
    [self _primitiveDownloadWithFileMD:projectMD category:sourceCategory projectName:projectName profile:profile redeemed:redeemed
    completion:^(BOOL success)
    {
        //NSArray *assetsMDs = nil; //xx;
        [self _download:assetsMDs category:assetCategory projectName:projectName profile:profile index:(success?0:NSNotFound) redeemed:redeemed];
    }];
}



#endif
#pragma mark endif


#pragma mark ck
#if UseCloudKit


- (void)_downloadProjectForProjectMD_ck:(FileMD*)projectMD userID:(NSString*)userID embedded:(BOOL)embedded redeemed:(BOOL)redeemed
{
    FileCategory sourceCategory = embedded?kFileCategoryRemoteGroupSourceFile:kFileCategoryRemoteSourceFile;
    FileCategory assetCategory = embedded?kFileCategoryRemoteGroupAssetFile:kFileCategoryRemoteAssetFile;
    
    [self _notifyBeginGroupDownloadForCategory:sourceCategory];
    
    NSString *projectName = projectMD.fileName;
    NSArray *files = projectMD.files;

    [self _primitiveDownloadWithFileMDs_ck:@[projectMD] category:sourceCategory projectName:projectName userID:userID redeemed:redeemed
    completion:^(BOOL success0)
    {
        [self _notifyEndGroupDownload:success0 userCanceled:NO category:sourceCategory];
        
        if ( success0 )
        {
            NSMutableArray *theAssets = [NSMutableArray array];
            for ( NSString *fileId in files )
            {
                FileMD *fileMD = [[FileMD alloc] init];
                fileMD.identifier = fileId;
                
                NSData *data = [NSData dataWithHexString:fileId];
                NSString *fileName = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                fileMD.fileName = fileName;
                
                [theAssets addObject:fileMD];
            }
            
            [self _notifyBeginGroupDownloadForCategory:assetCategory];
            [self _download_de_cop_ck:theAssets category:assetCategory projectName:projectName userID:(NSString*)userID redeemed:redeemed
            completion:^(BOOL success1)
            {
                NSError *unError = nil;
                [self _moveToFinalWithProjectName:projectName redeemed:redeemed outError:&unError];
                [self _notifyEndGroupDownload:success1 userCanceled:NO category:assetCategory];
            }];
        }
    }];

}


- (void)_downloadRemoteFileMDs_ck:(NSArray*)fileMDs forCategory:(FileCategory)fileCategory userID:(NSString*)userID
{
    [self _notifyBeginGroupDownloadForCategory:fileCategory];
    [self _notifyGroupDownloadProgressStep:0 stepCount:fileMDs.count category:fileCategory];
    
    [self _download_de_cop_ck:fileMDs category:fileCategory projectName:nil userID:userID redeemed:NO
    completion:^(BOOL success)
    {
        if ( fileCategory == kFileCategoryRemoteSourceFile || fileCategory == kFileCategoryRemoteGroupSourceFile )
        {
            for ( FileMD *projectMD in fileMDs )
            {
                NSString *projectName = projectMD.fileName;
                NSError *unError = nil;
                [self _moveToFinalWithProjectName:projectName redeemed:NO outError:&unError];
            }
        }
    
        [self _notifyEndGroupDownload:success userCanceled:(_currentDownloadPath==nil) category:fileCategory];
        _currentDownloadPath = nil;
    }];
}


- (void)_download_de_cop_ck:(NSArray*)fileMDs category:(FileCategory)fileCategory projectName:(NSString*)projectName userID:(NSString*)userID
    redeemed:(BOOL)redeemed completion:(void(^)(BOOL))completion
{
    NSInteger count = fileMDs.count;
    
    if ( count > 0 )
    {
        [self _notifyGroupDownloadProgressStep:1 stepCount:count+1 category:fileCategory];

        [self _primitiveDownloadWithFileMDs_ck:fileMDs category:fileCategory projectName:projectName userID:userID redeemed:redeemed
        completion:^(BOOL success)
        {
            completion( success );
        }];
    }
    else
    {
        completion( YES );
    }
}


- (BOOL)_moveToFinalWithProjectName:(NSString*)projectName redeemed:(BOOL)redeemed outError:(NSError**)outError
{
    BOOL success = NO;
    if ( redeemed )
    {
        //[self moveToProjectsForTemporaryProject:projectName error:&error];
        // aqui close
        success = [self moveToRedemmedProjectsForTemporaryProject:projectName error:outError];
    }
    else
    {
        success = [self moveToProjectsForTemporaryProject:projectName error:outError];
    }
    return success;
}



- (void)_primitiveDownloadWithFileMDs_ck:(NSArray*)fileMDs category:(FileCategory)category projectName:(NSString*)projectName userID:(NSString*)userID redeemed:(BOOL)redeemed completion:(void(^)(BOOL))block
{
//    NSString *deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
//    NSString *deviceID = [usersModel() identifierForApp];
    
    NSMutableArray *recordIds = [NSMutableArray array];
    
    for ( FileMD *fileMD in fileMDs )
    {
        NSString *uuid = fileMD.identifier;
        NSString *ownerIdentifier = userID;
    
        NSString *fileName = fileMD.fileName;
        [self _notifyWillDownloadFile:fileName category:category];
        
        // record id
        NSString *recordName = [NSString stringWithFormat:@"%@@%@", uuid, ownerIdentifier];
        CKRecordID *recordId = [[CKRecordID alloc] initWithRecordName:recordName];
        
        [recordIds addObject:recordId];
    }
    
    NSArray *desiredKeys = @[@"name", @"theFile", @"thumbnail"];
    
    CKFetchRecordsOperation *fetchOperation = [[CKFetchRecordsOperation alloc] initWithRecordIDs:recordIds];
    fetchOperation.desiredKeys = desiredKeys;
    
    [fetchOperation setPerRecordProgressBlock:^(CKRecordID *recordID, double progress)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
                //progress per record
            //NSLog( @"progress per record: %g", progress );
            NSInteger index = [recordIds indexOfObject:recordID];
            FileMD *fileMD = nil;
            if ( index<fileMDs.count) fileMD = [fileMDs objectAtIndex:index];
    
            //NSLog( @"File:%@, Index:%ld", fileMD.fileName, (long)index );
            
        
            long long totalBytesExpectedToRead = 1000;
            long long totalBytesRead = progress*1000;
            [self _notifyFileDownloadProgressBytesRead:totalBytesRead totalBytesExpected:totalBytesExpectedToRead category:category];
        });
    }];
    
    
    [fetchOperation setPerRecordCompletionBlock:^(CKRecord *record, CKRecordID *recordID, NSError *perRecordError)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            NSString *fileName = [record objectForKey:@"name"];
            
            CKAsset *ckAsset = [record objectForKey:@"theFile"];
            NSString *filePath = [ckAsset.fileURL path];
            
            CKAsset *ckThumbAsset = [record objectForKey:@"thumbnail"];
            NSString *thumbFilePath = [ckThumbAsset.fileURL path];

            if ( perRecordError == nil )
            {
                BOOL isSourceCategory = (category == kFileCategoryRemoteGroupSourceFile || category == kFileCategoryRemoteSourceFile);
            
                BOOL shouldEncrypt = redeemed && isSourceCategory;
            
                NSError *error = nil;
                BOOL success = YES;
                if ( shouldEncrypt )
                {
                    NSData *data = [NSData dataWithContentsOfFile:filePath];
                    data = [data encrypt];
                
                    NSString *outFilePath = [_filesModel.filePaths temporaryFilePathForFileName:fileName];
                    success = [data writeToFile:outFilePath options:NSDataWritingAtomic error:&error];
                }
                else
                {
                    [self copyToTemporaryForFileFullPath:filePath destinationFile:fileName error:&error];
                }
                
                if ( success )
                {
                    FileCategory destCategory = kFileCategoryUnknown;
                    if ( category == kFileCategoryRemoteAssetFile ) destCategory = kFileCategoryAssetFile;
        
//                    else if ( category == kFileCategoryRemoteSourceFile ) destCategory = kFileCategorySourceFile;
//                    else if ( category == kFileCategoryRemoteGroupSourceFile) destCategory = kFileCategoryTemporarySourceFile;
                    
                    else if ( isSourceCategory ) destCategory = kFileCategoryTemporarySourceFile;
        
                    else if ( category == kFileCategoryRemoteGroupAssetFile) destCategory = kFileCategoryTemporaryEmbedeedAssetFile;
        
                    [self moveFromTemporaryToCategory:destCategory forFile:fileName projectName:projectName isEncrypted:shouldEncrypt addCopy:NO error:&error];
                    
                    if ( thumbFilePath && isSourceCategory )
                    {
                        [self copyToTemporaryForFileFullPath:thumbFilePath destinationFile:SWFileKeyWrappThumbnail error:&error];
                        [self moveFromTemporaryToCategory:kFileCategoryTemporaryBundledFile forFile:SWFileKeyWrappThumbnail projectName:fileName isEncrypted:NO addCopy:NO error:&error];
                    }
                    
                    [self _notifyDidDownloadFile:fileName category:category withError:error];
                }
                
                if ( error )
                {
                    NSString *title = NSLocalizedString(@"Download Error", nil );
                    NSString *message = NSLocalizedString(@"Could not save file downloaded from iCloud", nil );
                    _errorWithLocalizedDescription_title(message, title);
                }
            }
            else
            {
               // [self _notifyDidDownloadFile:fileName category:category withError:error];
            }
            
        });
    }];
    
    
    [fetchOperation setFetchRecordsCompletionBlock:^(NSDictionary *recordsByRecordID, NSError *operationError)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            BOOL success = (operationError == nil );
            if ( operationError == nil )
            {
                // ok
            }
            else
            {
                NSString *title = NSLocalizedString(@"Download Error", nil );
                NSString *message = NSLocalizedString(@"Could not download file from iCloud", nil );
                NSError *error = _completeErrorFromCloudKitError_message_title(operationError, message, title);
                (void)error;
            }
        
            if ( block ) block(success);
        });
    }];
    
    [[_filesModel ckDatabase] addOperation:fetchOperation];
}


#endif
#pragma mark endif




#pragma mark upload





#pragma mark no ck
#if !UseCloudKit
- (void)_uploadProjectWithName:(NSString*)projectName data:(NSData*)symbolicData thumbnailData:(NSData*)thumbnailData fileSize:(long long)fileSize UUID:(NSString*)uuid files:(NSArray*)files profile:(UserProfile*)profile
{
    [self _notifyBeginGroupUploadForCategory:kFileCategorySourceFile];    
    [self _notifyGroupUploadProgressStep:0 stepCount:2+files.count category:kFileCategorySourceFile];
    
    // enviem el document
    [self _primitiveUploadProjectWithFileName:projectName uuid:uuid fileData:symbolicData
    thumbnailData:thumbnailData fileSize:fileSize profile:profile
    completion:^(BOOL success, NSString *projectUUID)
    {
        NSArray *assetMDs = [self _getFileMDsArrayForFileList:files forCategory:kFileCategoryAssetFile];
        
        // enviem els arxius associats
        [self _upload:assetMDs index:(success?0:NSNotFound) uuid:projectUUID profile:profile];
    }];
}


- (void)_uploadAssets:(NSArray*)fileMDs profile:(UserProfile*)profile
{
    [self _notifyBeginGroupUploadForCategory:kFileCategoryAssetFile];
    [self _notifyGroupUploadProgressStep:0 stepCount:fileMDs.count category:kFileCategoryAssetFile];
    
    [self _upload:fileMDs index:0 uuid:nil profile:profile];
}


- (void)_upload:(NSArray*)fileMDs index:(NSInteger)index uuid:(NSString*)uuid profile:(UserProfile*)profile
{
    NSInteger count = fileMDs.count;
    int addSteps = (uuid != nil)?2:0;

    [self _notifyGroupUploadProgressStep:index==NSNotFound?0:addSteps+index stepCount:addSteps+count category:kFileCategoryAssetFile];
    
    if ( index < count )
    {
        // process next file
        FileMD *fileMD = [fileMDs objectAtIndex:index];
        [self _primitiveUploadAssetWithFileMD:fileMD profile:profile
        completion:^(BOOL success)
        {
            [self _upload:fileMDs index:(success?index+1:NSNotFound) uuid:uuid profile:profile];
        }];
    }
    else
    {
        // finished
        void (^finishBlock)(BOOL) = ^(BOOL success)
        {
            [self _notifyEndGroupUpload:success userCanceled:(_currentUploadPath==nil) category:kFileCategoryAssetFile];
            _currentUploadPath = nil;
            [self _listRemoteFilesForCategory:kFileCategoryRemoteSourceFile];
            [self _listRemoteFilesForCategory:kFileCategoryRemoteAssetFile];
        };
        
        BOOL successSoFar = (index==count);
        if ( successSoFar && uuid!=nil )
        {
            [self _setFileListing:fileMDs toProjectWithUuid:uuid completion:finishBlock];
        }
        else
        {
            finishBlock(successSoFar);
        }
    }
}


- (void)_cancelUpload
{
    if ( _currentUploadPath )
    {
        HMiPadServerAPIClient *client = [HMiPadServerAPIClient sharedClient];
        [client cancelAllHTTPOperationsWithMethod:@"PUT" path:_currentUploadPath];
        _currentUploadPath = nil;
        [self _upload:nil index:NSNotFound uuid:nil profile:nil];
    }
}



- (void)_primitiveUploadProjectWithFileName:(NSString*)fileName uuid:(NSString*)uuid
        fileData:(NSData*)fileData thumbnailData:(NSData*)thumbnailData fileSize:(long long)fileSize profile:(UserProfile*)profile completion:(void(^)(BOOL,NSString*))block
{

    //NSAssert( outCategory == kFileCategoryRemoteSourceFile, @"cucut remote source file");
    
    FileCategory inCategory = kFileCategorySourceFile;
    //FileCategory outCategory = kFileCategoryRemoteSourceFile;

    NSLog1( @"fileName: %@", fileName );
    [self _notifyWillUploadFile:fileName category:inCategory];
    
    //UserProfile *profile = [usersModel() currentUserProfile];

    HMiPadServerAPIClient *client = [HMiPadServerAPIClient sharedClient];
    
    NSString *path = [NSString stringWithFormat:@"projects/%u/%@/", (unsigned int)profile.userId, uuid];
    _currentUploadPath = path;
    NSLog1( @"Upload Project path: %@", path );
    NSLog1( @"token: %@", profile.token );
    NSDictionary *parameters = @
    {
        @"name":fileName,
        @"file_size":[NSString stringWithFormat:@"%lld", fileSize],
    };
    
    NSURLRequest *trequest = [client multipartFormRequestWithMethod:@"PUT" path:path token:profile.token parameters:parameters
    constructingBodyWithBlock: ^(id <AFMultipartFormData> formData)
    {
        if ( fileData )
        {
            [formData appendPartWithFileData:fileData name:@"location" fileName:fileName mimeType:@"application/octet-stream"];
        }
        
        if ( thumbnailData )
        {
            [formData appendPartWithFileData:thumbnailData name:@"thumbnail" fileName:@"thumbnail.png" mimeType:@"application/octet-stream"];
        }
    }];
    
    LogRequest;
    // NO LogBody;
    
    [client enqueueRequest:trequest
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        LogSuccess;
        
        NSDictionary *dict = JSON;
        NSString *fileURLName = [dict objectForKey:@"url"];
        NSString *projectUUID = [fileURLName lastPathComponent];
        
        [self _notifyDidUploadFile:fileName category:inCategory withError:nil];
        if ( block ) block(YES,projectUUID);
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        LogFailure;
        
        NSString *title = NSLocalizedString(@"Upload Project Error", nil );
        error = _completeErrorFromResponse_json_withError_title(response,JSON,error,title);
        [self _notifyDidUploadFile:fileName category:inCategory withError:error];
        if ( block ) block(NO,0);
    }
    upProgress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
    {
        [self _notifyFileUploadProgressBytesRead:totalBytesWritten totalBytesExpected:totalBytesExpectedToWrite category:inCategory];
    }];
}


- (void)_setFileListing:(NSArray*)fileMDs toProjectWithUuid:(NSString*)uuid completion:(void(^)(BOOL))block
{

//    FileCategory inCategory = kFileCategorySourceFile;
//    NSLog1( @"fileName: %@", fileName );

    [self _notifyWillSetFilesToProject];
    
    UserProfile *profile = [usersModel() currentUserProfile];

    HMiPadServerAPIClient *client = [HMiPadServerAPIClient sharedClient];
    
    NSString *path = [NSString stringWithFormat:@"projects/%u/%@/files/", (unsigned int)profile.userId, uuid];
    NSLog1( @"path:%@", path );
    
    NSMutableArray *fileIds = [NSMutableArray array];
    
    for ( FileMD *fileMD in fileMDs )
    {
//        NSString *fileName = fileMD.fileName;
//        [fileIds addObject:fileName];
        
        [fileIds addObject:fileMD.identifier];
    }
    
    NSDictionary *parameters = @
    {
        @"file_list": fileIds,
    };
    
        
    NSMutableURLRequest *trequest = [client requestWithMethod:@"PUT" path:path token:profile.token parameters:parameters];
    
//    NSData *body = trequest.HTTPBody;
//    NSString *bodyString = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
//    NSLog1( @"body: %@", bodyString );
    
    LogRequest;
    LogBody;
    
    [client enqueueRequest:trequest
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        LogSuccess;
        
        [self _notifyDidSetFilesToProjectWithError:nil];
        if ( block ) block(YES);
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        LogFailure;
    
        NSString *title = NSLocalizedString(@"Updating Project Assets Error", nil );
        error = _completeErrorFromResponse_json_withError_title(response,JSON,error,title);
        [self _notifyDidSetFilesToProjectWithError:error];
        if ( block ) block(NO);
    }];
}



- (void)_primitiveUploadAssetWithFileMD:(FileMD*)fileMD profile:(UserProfile*)profile completion:(void(^)(BOOL))block
{
    FileCategory inCategory = kFileCategoryAssetFile;

    NSString *fileName = fileMD.fileName;
//    NSString *originPath = [self fileFullPathForFileName:fileName forCategory:inCategory];
//    
//    // si la extensio del origen es wrap potser hem modificar el origen desde el interior del directori
//    if ( [self fileFullPathIsWrappedSource:originPath])
//    {
//        originPath = [originPath stringByAppendingPathComponent:SWFileKeyWrappSymbolic];
//    }
    
    NSString *originPath = [_filesModel.filePaths originPathForFilename:fileName forCategory:kFileCategoryAssetFile];
    
    NSData *fileData = [NSData dataWithContentsOfFile:originPath];
    //NSString *uuid = [fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *uuid = fileMD.identifier;
    // ^ -- utilitzem el nom escapat com a identificador
    
    NSLog1( @"fileName: %@", fileName );
    [self _notifyWillUploadFile:fileName category:inCategory];
    
    //UserProfile *profile = [usersModel() currentUserProfile];

    HMiPadServerAPIClient *client = [HMiPadServerAPIClient sharedClient];
    
    NSString *path = [NSString stringWithFormat:@"files/%u/%@/", (unsigned int)profile.userId, uuid];
    _currentUploadPath = path;
    
    NSDictionary *parameters = @
    {
        @"name":fileName,
        @"file_size":[NSString stringWithFormat:@"%lld", fileMD.fileSize],
    };
    
    NSURLRequest *trequest = [client multipartFormRequestWithMethod:@"PUT" path:path token:profile.token parameters:parameters
    constructingBodyWithBlock: ^(id <AFMultipartFormData> formData)
    {
        [formData appendPartWithFileData:fileData name:@"location" fileName:fileName mimeType:@"application/octet-stream"];
    }];
    
    LogRequest;
    // NO LogBody;
    
    [client enqueueRequest:trequest
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        LogSuccess;
        
        [self _notifyDidUploadFile:fileName category:inCategory withError:nil];
        if ( block ) block(YES);
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        LogFailure;
        
        NSString *title = NSLocalizedString(@"Upload Asset Error", nil );
        error = _completeErrorFromResponse_json_withError_title(response,JSON,error,title);
        [self _notifyDidUploadFile:fileName category:inCategory withError:error];
        if ( block ) block(NO);
    }
    upProgress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
    {
        [self _notifyFileUploadProgressBytesRead:totalBytesWritten totalBytesExpected:totalBytesExpectedToWrite category:inCategory];
    }];
    
}



#endif
#pragma mark endif

#pragma mark ck
#if UseCloudKit

- (void)_uploadAssets_ck:(NSArray*)fileMDs profile:(UserProfile*)profile
{
    [self _upload_de_cop_ck:fileMDs category:kFileCategoryAssetFile profile:profile completion:^(BOOL success)
    {
        [self _listRemoteFilesForCategory:kFileCategoryRemoteSourceFile];
        [self _listRemoteFilesForCategory:kFileCategoryRemoteAssetFile];
    }];
}

#endif
#pragma mark endif




#pragma mark - Migration
#pragma mark -


- (void)_notifyMigrationFileListingWillChangeForCategory:(FileCategory)category
{
    for ( id<AppFilesModelMigrationObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:willChangeMigrationListingForCategory:)])
        {
            [observer appFilesModel:self willChangeMigrationListingForCategory:category];
        }
    }
}


- (void)_notifyMigrationRemoteFileListingDidChangeForCategory:(FileCategory)category withError:(NSError*)error
{
    for ( id<AppFilesModelMigrationObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:didChangeMigrationListingForCategory:withError:)])
        {
            [observer appFilesModel:self didChangeMigrationListingForCategory:category withError:error];
        }
    }
}


- (void)_notifyBeginMigrationGroupDownloadForCategory:(FileCategory)category
{
    for ( id<AppFilesModelMigrationObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:beginMigrationGroupDownloadForCategory:)])
        {
            [observer appFilesModel:self beginMigrationGroupDownloadForCategory:category];
        }
    }
}

- (void)_notifyWillDownloadMigrationFile:(NSString*)fileName category:(FileCategory)category
{
    for ( id<AppFilesModelMigrationObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:willDownloadMigrationFile:forCategory:)] )
        {
            [observer appFilesModel:self willDownloadMigrationFile:fileName forCategory:category];
        }
    }
}

- (void)_notifyMigrationFileDownloadProgress:(double)progress fileName:(NSString*)fileName category:(FileCategory)category
{
    for ( id<AppFilesModelMigrationObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:migrationFileDownloadProgress:fileName:category:)] )
        {
            [observer appFilesModel:self migrationFileDownloadProgress:progress fileName:fileName category:category];
        }
    }
}

- (void)_notifyDidDownloadMigrationFile:(NSString*)fileName category:(FileCategory)category withError:(NSError*)error
{
    for ( id<AppFilesModelMigrationObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:didDownloadMigrationFile:forCategory:withError:)] )
        {
            [observer appFilesModel:self didDownloadMigrationFile:fileName forCategory:category withError:error];
        }
    }
}


- (void)_notifyEndMigrationGroupDownload:(BOOL)finished userCanceled:(BOOL)canceled category:(FileCategory)category
{
    for ( id<AppFilesModelMigrationObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:endMigrationGroupDownloadForCategory:finished:userCanceled:)] )
        {
            [observer appFilesModel:self endMigrationGroupDownloadForCategory:category finished:finished userCanceled:canceled];
        }
    }
}


#pragma mark CloudKit migration


- (void)migrateCategories:(NSArray*)categories isProfile:(UserProfile*)isProfile ckProfile:(UserProfile*)ckProfile completion:(void(^)(BOOL))completion
{
    NSNumber *categoryN = [categories firstObject];
    if ( categoryN == nil )
    {
        [usersModel() setMigratedForProfile:isProfile completion:^(BOOL done)
        {
            [cloudKitUser() setMigratedForProfile:ckProfile completion:completion];
        }];
        return;
    }
    
    FileCategory category = [categoryN intValue];
    //NSLog( @"category to migrate %d", category );
    [self _migrateCategory:category isProfile:isProfile ckProfile:ckProfile completion:^(BOOL success)
    {
        if ( success == NO )
        {
            completion( NO );
            return;
        }
        
        NSArray *restCategories = [categories subarrayWithRange:NSMakeRange(1, categories.count-1)];
        [self migrateCategories:restCategories isProfile:isProfile ckProfile:ckProfile completion:completion];
    }];

}



- (void)_migrateCategory:(FileCategory)category isProfile:(UserProfile*)isProfile ckProfile:(UserProfile*)ckProfile completion:(void(^)(BOOL))completion
{
    [self _listRemoteIntegratorServerFilesForCategory:category profile:isProfile
    completion:^(NSArray *list, NSError *error)
    {
        //NSLog( @"category after listing %d", category );
        if ( error != nil )
        {
            completion( NO );
            return;
        }
        
        if ( category == kFileCategoryRemoteSourceFile || category == kFileCategoryRemoteAssetFile )
        {
            [self _migrateFileMDs:list inCategory:category isProfile:isProfile ckProfile:ckProfile index:0 completion:completion];
        }
        
        else if ( category == kFileCategoryRemoteActivationCode )
        {
            [self _migrateActivationMDs:list profile:ckProfile completion:completion];
        }
        
        else if ( category == kFileCategoryRemoteRedemption )
        {
            [self _migrateRedemptionMDs:list profile:ckProfile completion:completion];
        }
        
    }];
}


- (void)_migrateFileMDs:(NSArray*)fileMDs inCategory:(FileCategory)category
    isProfile:(UserProfile*)isProfile ckProfile:(UserProfile*)ckProfile index:(NSInteger)index completion:(void(^)(BOOL))completion
{

    //NSLog( @"category before download listing %d", category );
    [self _notifyBeginMigrationGroupDownloadForCategory:category];
    [self _downloadIntegratorServerFilesWithFileMDs:fileMDs category:category profile:isProfile index:0
    completion:^(BOOL success0)
    {
    
        //NSLog( @"category after download listing %d", category );
        [self _notifyEndMigrationGroupDownload:success0 userCanceled:NO category:category];
        if ( success0 == NO )
        {
            completion( NO );
            return;
        }
        
        [self _notifyBeginGroupUploadForCategory:category];
        [self _primitiveUploadFilesWithFileMDs_ck:fileMDs inCategory:category thumbnailData:nil profile:ckProfile
        completion:^(BOOL success)
        {
            [self _notifyEndGroupUpload:success userCanceled:NO category:category];
            completion( success );
        }];
    }];
    
    
// TREURE
    
//    [self _primitiveUploadFilesWithFileMDs_ck:fileMDs inCategory:category thumbnailData:nil profile:ckProfile completion:completion];
    
}






- (void)_listRemoteIntegratorServerFilesForCategory:(FileCategory)category
    profile:(UserProfile*)profile completion:(void(^)(NSArray *list, NSError *error))completion
{
    if ( completion == nil )
        return;

    if ( profile.isLocal )
    {
        NSString *message = @"No remote user is active";
        NSString *title = @"Integrator server file listing";
        NSError *error = _errorWithLocalizedDescription_title(message, title);
        completion( nil, error );
        return;
    }
    
    [self _notifyMigrationFileListingWillChangeForCategory:category];
    
    NSString *typeString = nil;
    if ( category == kFileCategoryRemoteSourceFile ) typeString = @"projects";
    else if ( category == kFileCategoryRemoteAssetFile ) typeString = @"files";
    else if ( category == kFileCategoryRemoteActivationCode ) typeString = @"access_codes";
    else if ( category == kFileCategoryRemoteRedemption ) typeString = @"redemptions";
    
    HMiPadServerAPIClient *client = [HMiPadServerAPIClient sharedClient];
    
    
//    NSString *path = [NSString stringWithFormat:@"users/%ld/%@/", profile.userId, typeString];
    NSString *path = [NSString stringWithFormat:@"%@/", typeString];
    
    NSDictionary *parameters = nil;
    
    NSURLRequest *trequest = [client requestWithMethod:@"GET" path:path token:profile.token parameters:parameters ];
    LogRequest;
    LogBody;
    
    [client enqueueRequest:trequest
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        LogSuccess;
        
        NSDictionary *responseDict = JSON;
        //NSArray *responseArray = JSON;
        
        //NSArray *responseArray = [responseDict objectForKey:typeString];
        NSArray *responseArray = _dict_objectForKey(responseDict, typeString);
        
        NSMutableArray *array = [NSMutableArray array];
      
        for ( NSDictionary *fileDict in responseArray )
        {
            FileMD *fileMD;
            if (category == kFileCategoryRemoteActivationCode)
                fileMD = [self _newActivationCodeFileMDFromFileDict:fileDict];
            
            else if (category == kFileCategoryRemoteRedemption)
                fileMD = [self _newRedemptionFileMDFromFileDict:fileDict];
            
            else
                fileMD = [self _newFileMDFromFileDict:fileDict];
            [array addObject:fileMD];
        }
        
        [self _notifyMigrationRemoteFileListingDidChangeForCategory:category withError:nil];
        
        completion( array, nil );
        
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        LogFailure;
        
        NSString *title = NSLocalizedString(@"Remote Listing Error", nil );
        error = _completeErrorFromResponse_json_withError_title(response,JSON,error,title);
        [self _notifyMigrationRemoteFileListingDidChangeForCategory:category withError:error];
        
        completion( nil, error );
    }];
}


//- (void)migrateFileMDs:(NSArray*)fileMDs inCategory:(FileCategory)category
//    isProfile:(UserProfile*)isProfile ckProfile:(UserProfile*)ckProfile completion:(void(^)(BOOL))completion
//{
//   [self _migrateFileMDs:fileMDs inCategory:category isProfile:isProfile ckProfile:ckProfile index:0 completion:completion];
//}


- (void)_primitiveDownloadIntegratorServerFileWithFileMD:(FileMD*)fileMD category:(FileCategory)category profile:(UserProfile*)profile completion:(void(^)(BOOL))completion
{
    if ( completion == nil )
        return;
    
    NSString *fileName = fileMD.fileName;
    NSString *storageName = [NSString stringWithFormat:@"%@@%d", fileMD.identifier, fileMD.userId];
    NSString *outFilePath = [_filesModel.filePaths fileFullPathForFileName:storageName forCategory:category];
    
    // si ja hi es no fem res
    NSFileManager *fm = [NSFileManager defaultManager];
    if ( [fm fileExistsAtPath:outFilePath] )
    {
        dispatch_async(dispatch_get_main_queue(), ^
        // ^- ja estem en el main pero aixi evitem acumulacio de cridades recursives a la pila
        {
            completion( YES );
        });
        return;
    }

    NSString *typeString = nil;
    if ( category == kFileCategoryRemoteSourceFile ) typeString = @"projects";
    else if ( category == kFileCategoryRemoteAssetFile ) typeString = @"files";
    else NSAssert(NO, @"no se suporten altres categories" );
    
    [self _notifyWillDownloadMigrationFile:fileName category:category];

    HMiPadServerAPIClient *client = [HMiPadServerAPIClient sharedClient];
    
    NSString *path = [NSString stringWithFormat:@"%@/%u/%@/download/", typeString, (unsigned int)fileMD.userId, fileMD.identifier ];
    
    //NSString *path = [NSString stringWithFormat:@"media/%@", location];
    NSLog1( @"Downloading file \"%@\" at path %@", fileName, path );
    
    _currentDownloadPath = path;
    NSDictionary *parameters = nil;
    NSMutableURLRequest *trequest = [client requestWithMethod:@"GET" path:path token:profile.token parameters:parameters];
    
    LogRequest;
    LogBody;
    
    [trequest setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    
    
    [client enqueueRequestForDownload:trequest outputFilePath:outFilePath
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data)
    {
        id JSON = nil;
        (void)JSON;
        LogSuccess;
        
        NSError *error = nil;
        BOOL success = YES;
//        BOOL success = [data writeToFile:outFilePath options:NSDataWritingAtomic error:&error];
//        
//        if ( success == NO )
//        {
//            NSString *title = NSLocalizedString(@"Download Error", nil );
//            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Could not save '%@' to temporary storage", nil ), fileName];
//            //error = [self _completeErrorFromResponse:response json:JSON withError:error title:title message:message];
//            error = _errorWithLocalizedDescription_title(message, title);
//        }
        
        [self _notifyDidDownloadFile:fileMD.fileName category:category withError:error];
        completion( success );
    }
    
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
    {
        id JSON = nil;
        LogFailure;
                // ens carreguem el fitxer ( que pot tenir una cosa com {"detail":"Not Found"} )
        [[NSFileManager defaultManager] removeItemAtPath:outFilePath error:nil];
        
        NSString *title = NSLocalizedString(@"Download Error", nil );
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Could not download '%@' from the integrators service", nil ), fileName];
        
        //error = [self _completeErrorFromResponse:response json:JSON withError:error title:title message:message];
        error = _completeErrorFromResponse_json_withError_title_message(response, JSON, error, title, message);
        [self _notifyDidDownloadFile:fileMD.fileName category:category withError:error];
        completion( NO );
    }
    
    downProgress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
    {
        double progress = (double)totalBytesRead/(double)totalBytesExpectedToRead;
        [self _notifyMigrationFileDownloadProgress:progress fileName:fileName category:category];
    }];
}



//- (void)_migrateFileMDs1:(NSArray*)fileMDs inCategory:(FileCategory)category
//    isProfile:(UserProfile*)isProfile ckProfile:(UserProfile*)ckProfile index:(NSInteger)index completion:(void(^)(BOOL))completion
//{
//    NSInteger count = fileMDs.count;
//    
//    [self _notifyGroupUploadProgressStep:index stepCount:count category:category];
//    
//    if ( index >= count )
//    {
//        completion( YES );
//        return;
//    }
//    
//    FileMD *fileMD = [fileMDs objectAtIndex:index];
//    [self _downloadIntegratorServerFileWithFileMD:fileMD category:category profile:isProfile
//    completion:^(BOOL success0)
//    {
//        if ( success0 == NO )
//        {
//            // saltem aquest
//            [self _migrateFileMDs:fileMDs inCategory:category isProfile:isProfile ckProfile:ckProfile index:index+1 completion:completion];
//            return;
//        }
//            
//        [self _primitiveUploadFilesWithFileMDs_ck:@[fileMD] inCategory:category thumbnailData:nil profile:ckProfile
//        completion:^(BOOL success1)
//        {
//            if ( success1 == NO )
//            {
//                completion( NO );
//                return;
//            }
//            [self _migrateFileMDs:fileMDs inCategory:category isProfile:isProfile ckProfile:ckProfile index:index+1 completion:completion];
//        }];
//    }];
//}







- (void)_downloadIntegratorServerFilesWithFileMDs:(NSArray*)fileMDs category:(FileCategory)category
    profile:(UserProfile*)isProfile index:(NSInteger)index completion:(void(^)(BOOL))completion
{
    NSInteger count = fileMDs.count;
    
    if ( index >= count )
    {
        completion( YES );
        return;
    }
    
    FileMD *fileMD = [fileMDs objectAtIndex:index];
    [self _primitiveDownloadIntegratorServerFileWithFileMD:fileMD category:category profile:isProfile
    completion:^(BOOL success0)
    {
        if ( success0 == NO )
        {
            // res, seguim
        }
        
        //NSLog( @"downloaded: %@", fileMD.fileName );
        
        [self _downloadIntegratorServerFilesWithFileMDs:fileMDs category:category profile:isProfile index:index+1 completion:completion];
    }];
}




#pragma mark - CloudKit
#pragma mark -


#pragma mark ck
#if UseCloudKit

#pragma mark upload


- (void)_uploadProjectWithName_ck:(NSString*)projectName data:(NSData*)symbolicData thumbnailData:(NSData*)thumbnailData fileSize:(long long)fileSize UUID:(NSString*)uuid files:(NSArray*)files profile:(UserProfile*)profile
{
    [self _notifyBeginGroupUploadForCategory:kFileCategorySourceFile];    
    [self _notifyGroupUploadProgressStep:0 stepCount:1+files.count category:kFileCategorySourceFile];
    
    NSArray *assetMDs = [self _getFileMDsArrayForFileList:files forCategory:kFileCategoryAssetFile];
    
    // creem un arxiu temporal
    NSString *tmpFileFullPath = [_filesModel.filePaths fileFullPathForFileName:projectName forCategory:kFileCategoryRemoteSourceFile];
    [symbolicData writeToFile:tmpFileFullPath atomically:YES];
    
    FileMD *projectMD = [[FileMD alloc] init];
    projectMD.identifier = uuid;
    projectMD.fileName = projectName;
    projectMD.files = files;
    projectMD.fileSize = fileSize;
    projectMD.userId = 0;
    
    [self _primitiveUploadFilesWithFileMDs_ck:@[projectMD] inCategory:kFileCategoryRemoteSourceFile
    thumbnailData:thumbnailData profile:profile
    completion:^(BOOL success0)
    {
                // enviem els arxius associats
//        [self _upload_ck:assetMDs index:(success?0:NSNotFound) profile:profile];
        [self _notifyEndGroupUpload:success0 userCanceled:NO category:kFileCategorySourceFile];
        if ( success0 )
        {
            [self _upload_de_cop_ck:assetMDs category:kFileCategoryAssetFile profile:profile
            completion:^(BOOL success1)
            {
                [self _listRemoteFilesForCategory:kFileCategoryRemoteSourceFile];
                [self _listRemoteFilesForCategory:kFileCategoryRemoteAssetFile];
            }];
        }
    }];
}



//- (void)_upload_ckNO:(NSArray*)fileMDs index:(NSInteger)index uuid:(NSString*)uuid profile:(UserProfile*)profile
//{
//    NSInteger count = fileMDs.count;
//
//    [self _notifyGroupUploadProgressStep:index==NSNotFound?0:index stepCount:count category:kFileCategoryAssetFile];
//    
//    if ( index < count )
//    {
//        // process next file
//        FileMD *fileMD = [fileMDs objectAtIndex:index];
//        [self _primitiveUploadAssetWithFileMD_ck:fileMD profile:profile
//        completion:^(BOOL success)
//        {
//            [self _upload_ck:fileMDs index:(success?index+1:NSNotFound) uuid:uuid profile:profile];
//        }];
//    }
//    else
//    {
//        // finished
//        void (^finishBlock)(BOOL) = ^(BOOL success)
//        {
//            [self _notifyEndGroupUpload:success userCanceled:(_currentUploadPath==nil) category:kFileCategoryAssetFile];
//            _currentUploadPath = nil;
//            [self _listRemoteFilesForCategory:kFileCategoryRemoteSourceFile];
//            [self _listRemoteFilesForCategory:kFileCategoryRemoteAssetFile];
//        };
//        
//        BOOL successSoFar = (index==count);
//        finishBlock(successSoFar);
//    }
//}




//- (void)_upload_ck:(NSArray*)fileMDs index:(NSInteger)index profile:(UserProfile*)profile
//{
//    NSInteger count = fileMDs.count;
//    
//    [self _notifyGroupUploadProgressStep:index+1 stepCount:count+1 category:kFileCategoryAssetFile];
//
//    if ( index < count )
//    {
//        // process next file
//        FileMD *fileMD = [fileMDs objectAtIndex:index];
//        [self _primitiveUploadFilesWithFileMDs_ck:@[fileMD] inCategory:kFileCategoryAssetFile thumbnailData:nil profile:profile
//        completion:^(BOOL success)
//        {
//            [self _upload_ck:fileMDs index:(success?index+1:NSNotFound) profile:profile];
//        }];
//    }
//    else
//    {
//        BOOL success = index == count;
//        
//        // finished
//        [self _notifyEndGroupUpload:success userCanceled:_currentUploadPath==nil category:kFileCategoryAssetFile];
//        _currentUploadPath = nil;
//        [self _listRemoteFilesForCategory:kFileCategoryRemoteSourceFile];
//        [self _listRemoteFilesForCategory:kFileCategoryRemoteAssetFile];
//    }
//}



//- (void)_upload_ck:(NSArray*)fileMDs index:(NSInteger)index profile:(UserProfile*)profile
//{
//    NSInteger count = fileMDs.count;
//    
//    [self _notifyGroupUploadProgressStep:index+1 stepCount:count+1 category:kFileCategoryAssetFile];
//
//    if ( index >= count )
//    {
//        BOOL success = index == count;
//        
//        // finished
//        [self _notifyEndGroupUpload:success userCanceled:_currentUploadPath==nil category:kFileCategoryAssetFile];
//        _currentUploadPath = nil;
//        [self _listRemoteFilesForCategory:kFileCategoryRemoteSourceFile];
//        [self _listRemoteFilesForCategory:kFileCategoryRemoteAssetFile];
//        return;
//    }
//
//    // process next file
//    FileMD *fileMD = [fileMDs objectAtIndex:index];
//    [self _primitiveUploadFilesWithFileMDs_ck:@[fileMD] inCategory:kFileCategoryAssetFile thumbnailData:nil profile:profile
//    completion:^(BOOL success)
//    {
//        [self _upload_ck:fileMDs index:(success?index+1:NSNotFound) profile:profile];
//    }];
//}


- (void)_primitiveUploadFilesWithFileMDs_ck:(NSArray*)fileMDs inCategory:(FileCategory)inCategory
        thumbnailData:(NSData*)thumbnailData profile:(UserProfile*)profile completion:(void(^)(BOOL))completion
{
    NSMutableArray *records = [NSMutableArray array];
    NSFileManager *fm = [NSFileManager defaultManager];

    for ( FileMD *fileMD in fileMDs )
    {
        NSString *fileName = fileMD.fileName;
        NSString *uuid = fileMD.identifier;
        long long fileSize = fileMD.fileSize;
    
//        NSLog( @"-----" );
//        NSLog( @"fileName: %@", fileName );

        // file ( migration)
        NSString *storageName = fileName;
        if ( inCategory == kFileCategoryRemoteSourceFile || inCategory == kFileCategoryRemoteAssetFile )
            if ( fileMD.userId != 0 )  // <-- vol dir que ve d'un
                storageName = [NSString stringWithFormat:@"%@@%d", uuid, fileMD.userId];
        
        NSString *fullPath = [_filesModel.filePaths fileFullPathForFileName:storageName forCategory:inCategory];
        
        if ( ![fm fileExistsAtPath:fullPath] )
            continue;
        
        NSString *recordType = nil;
        if ( inCategory == kFileCategoryRemoteSourceFile || inCategory == kFileCategorySourceFile) recordType = @"Projects";
        else if ( inCategory == kFileCategoryRemoteAssetFile || inCategory == kFileCategoryAssetFile ) recordType = @"Assets";
    
        NSString *ownerIdentifier = profile.token;
        
        // record id
        NSString *recordName = [NSString stringWithFormat:@"%@@%@", uuid, ownerIdentifier];
        CKRecordID *recordId = [[CKRecordID alloc] initWithRecordName:recordName];
        CKRecord *record = [[CKRecord alloc] initWithRecordType:recordType recordID:recordId];
        
//      CKRecordID *useriii = [projectRecord creatorUserRecordID];
//      NSLog( @"useriii: %@", useriii.recordName );
    
        // owner
        CKRecordID *ownerRecordId = [[CKRecordID alloc] initWithRecordName:ownerIdentifier];
        CKReference *owner = [[CKReference alloc] initWithRecordID:ownerRecordId action:CKReferenceActionDeleteSelf];
        [record setObject:owner forKey:@"owner"];
        
        // file name
        [record setObject:fileName forKey:@"name"];
        
        // file id
        [record setObject:uuid forKey:@"identifier"];
        
        // assets list
        if ( inCategory == kFileCategoryRemoteSourceFile )
        {
            NSMutableArray *fileIds = [NSMutableArray array];
            for ( NSString *file in fileMD.files )
            {
                NSData *data = [file dataUsingEncoding:NSUTF8StringEncoding];
                NSString *identifier = [data hexStringValue];
                [fileIds addObject:identifier];
            }
            [record setObject:fileIds forKey:@"assets"];
        }
        
        // file
        CKAsset *asset = [[CKAsset alloc] initWithFileURL:[NSURL fileURLWithPath:fullPath]];
        [record setObject:asset forKey:@"theFile"];
        
        // thumbnail
        if ( thumbnailData )
        {
            NSString *thumbFilePath = [_filesModel.filePaths temporaryFilePathForFileName:SWFileKeyWrappThumbnail];
            [thumbnailData writeToFile:thumbFilePath atomically:NO];
            CKAsset *thumbAsset = [[CKAsset alloc] initWithFileURL:[NSURL fileURLWithPath:thumbFilePath]];
            [record setObject:thumbAsset forKey:@"thumbnail"];
        }
    
        // file size
        [record setObject:@(fileSize) forKey:@"fileSize"];
        
        // touchDate
        [record setObject:[NSDate dateWithTimeIntervalSinceNow:0] forKey:@"touchDate"];
        
        // add the record
        [records addObject:record];
    }

    [self _performModifyOperationWithRecords:records inCategory:inCategory completion:completion];
}


- (void)_migrateActivationMDs:(NSArray*)fileMDs profile:(UserProfile*)profile completion:(void(^)(BOOL))completion
{
    NSMutableArray *records = [NSMutableArray array];
    FileCategory inCategory = kFileCategoryRemoteActivationCode;
    
    for ( FileMD *fileMD in fileMDs )
    {
        NSString *name = fileMD.fileName;
        NSString *identifier = fileMD.accessCode;
        
        NSString *ownerIdentifier = profile.token;
        
        NSString *recordType = @"Activations";
        
        // posem un record id especific per evitar duplicitats
        //NSString *recordName = [NSString stringWithFormat:@"%@@%@", identifier, ownerIdentifier];
        NSString *recordName = [NSString stringWithFormat:@"%@@%@", identifier, @"_migratedA"];
        CKRecordID *recordId = [[CKRecordID alloc] initWithRecordName:recordName];
        CKRecord *record = [[CKRecord alloc] initWithRecordType:recordType recordID:recordId];
        
        //CKRecord *record = [[CKRecord alloc] initWithRecordType:recordType];
    
        // owner
        CKRecordID *ownerRecordId = [[CKRecordID alloc] initWithRecordName:ownerIdentifier];
        CKReference *owner = [[CKReference alloc] initWithRecordID:ownerRecordId action:CKReferenceActionDeleteSelf];
        [record setObject:owner forKey:@"owner"];
        
        // name
        [record setObject:name forKey:@"name"];
        
        // identifier
        [record setObject:identifier forKey:@"identifier"];
        
        // max redemptions
        [record setObject:@(fileMD.maxRedemptions) forKey:@"maxRedemptions"];
        
        // project identifier
        [record setObject:fileMD.project forKey:@"projectIdentifier"];
        
        // product
        [record setObject:fileMD.productInfo forKey:@"productInfo"];
        [record setObject:fileMD.productSKU forKey:@"productSKU"];
        
        // touchDate
        [record setObject:[NSDate dateWithTimeIntervalSinceNow:0] forKey:@"touchDate"];
    
        [records addObject:record];
    }
    
    [self _performModifyOperationWithRecords:records inCategory:inCategory completion:completion];
    
}

- (void)_migrateRedemptionMDs:(NSArray*)fileMDs profile:(UserProfile*)profile completion:(void(^)(BOOL))completion
{
    NSMutableArray *records = [NSMutableArray array];
    FileCategory inCategory = kFileCategoryRemoteRedemption;
    
    for ( FileMD *fileMD in fileMDs )
    {
        NSString *identifier = fileMD.identifier;
        
        NSString *endUserIdentifier = profile.token;
        
        NSString *recordType = @"Redemptions";
        
        // record id
        //NSString *recordName = [NSString stringWithFormat:@"%@@%@", identifier, ownerIdentifier];
        NSString *recordName = [NSString stringWithFormat:@"%@@%@", identifier, @"_migratedR"];
        CKRecordID *recordId = [[CKRecordID alloc] initWithRecordName:recordName];
        CKRecord *record = [[CKRecord alloc] initWithRecordType:recordType recordID:recordId];
        
        //CKRecord *record = [[CKRecord alloc] initWithRecordType:recordType];
    
        // endUser
        CKRecordID *ownerRecordId = [[CKRecordID alloc] initWithRecordName:endUserIdentifier];
        CKReference *endUser = [[CKReference alloc] initWithRecordID:ownerRecordId action:CKReferenceActionDeleteSelf];
        [record setObject:endUser forKey:@"endUser"];
        
        // activation
//        CKRecordID *activationId = [[CKRecordID alloc] initWithRecordName:fileMD.accessCode];
//        CKReference *activation = [[CKReference alloc] initWithRecordID:activationId action:CKReferenceActionDeleteSelf];
        
        NSString *activation = fileMD.accessCode;
        [record setObject:activation forKey:@"parentActivation"];
        
        // identifier
        [record setObject:identifier forKey:@"identifier"];
        
        // device
        [record setObject:fileMD.deviceIdentifier forKey:@"deviceIdentifier"];
        [record setObject:fileMD.fileName forKey:@"deviceName"];
        
        // touchDate
        [record setObject:[NSDate dateWithTimeIntervalSinceNow:0] forKey:@"touchDate"];
    
        [records addObject:record];
    }
    
    [self _performModifyOperationWithRecords:records inCategory:inCategory completion:completion];
}

- (void)_performModifyOperationWithRecords:(NSArray*)records inCategory:(FileCategory)inCategory completion:(void(^)(BOOL))completion
{
    //NSLog( @"category before modify some records %d", inCategory );
    if ( records.count == 0 )
    {
    
        //NSLog( @"category after modify (no) records %d", inCategory );
        if (completion) completion( YES );
        return;
    }

    CKModifyRecordsOperation *modifyOperation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:records recordIDsToDelete:nil];
        
//    [modifyOperation setSavePolicy:CKRecordSaveChangedKeys];
    [modifyOperation setSavePolicy:CKRecordSaveAllKeys];
//    [modifyOperation setSavePolicy:CKRecordSaveIfServerRecordUnchanged];
    
    [modifyOperation setPerRecordProgressBlock:^(CKRecord *record, double progress)
    {
        //progress per record
        //NSLog( @"progress per record: %g", progress );
        
        
        NSString *fileName = [record objectForKey:@"name"];
    
        NSInteger count = records.count;
        NSInteger index = [records indexOfObjectIdenticalTo:record];
        //NSLog( @"File:%@, Index:%ld", fileName, (long)index );
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if ( progress == 0 )
            {
                [self _notifyWillUploadFile:fileName category:inCategory];
            }
            
            [self _notifyFileUploadProgress:progress fileName:fileName category:inCategory];
            
            if ( progress == 1 )
            {
                [self _notifyDidUploadFile:fileName category:inCategory withError:nil];
                [self _notifyGroupUploadProgressStep:index+1 stepCount:count+1 category:inCategory];
            }
        });
        
    }];
        
    [modifyOperation setPerRecordCompletionBlock:^(CKRecord *record, NSError *recordCompletionError)
    {
        //final per record
        //NSLog( @"completion per record: %@", [record objectForKey:@"name"] );
        //NSLog(@"%@ ERR %@", NSStringFromSelector(_cmd), recordCompletionError);
    }];
        
    [modifyOperation setModifyRecordsCompletionBlock:^(NSArray /* CKRecord */ *savedRecords,
        NSArray /* CKRecordID */ *deletedRecordIDs, NSError *operationError)
    {
        //final end
        
        //NSLog( @"final end: %@", operationError );
        dispatch_async(dispatch_get_main_queue(), ^
        {
            BOOL success = (operationError == nil);
            
            if ( success == NO )
            {
                NSString *title = NSLocalizedString(@"Upload Error", nil );
                NSString *message = NSLocalizedString(@"Could not upload to iCloud", nil );
                _completeErrorFromCloudKitError_message_title(operationError, message, title);
            }
            
            //NSLog( @"category after modify records %d", inCategory );
            if ( completion ) completion(success);
        });
    }];

    [[_filesModel ckDatabase] addOperation:modifyOperation];
}


- (void)_upload_de_cop_ck:(NSArray*)fileMDs category:(FileCategory)fileCategory profile:(UserProfile*)profile completion:(void(^)(BOOL))completion
{
    NSInteger count = fileMDs.count;
    
    if ( count > 0 )
    {
        [self _notifyBeginGroupUploadForCategory:fileCategory];
        [self _notifyGroupUploadProgressStep:0 stepCount:count category:fileCategory];
    
        [self _primitiveUploadFilesWithFileMDs_ck:fileMDs inCategory:fileCategory thumbnailData:nil profile:profile
        completion:^(BOOL success)
        {
            // finished
            [self _notifyEndGroupUpload:success userCanceled:NO category:fileCategory];
            _currentUploadPath = nil;
            completion( success );
        }];
    }
    else
    {
        completion( YES );
    }
}






#pragma mark move projects

#endif
#pragma mark endif



#pragma mark - Metodes del AppFilesModel
#pragma mark -

- (id)initWithLocalFilesModel:(AppModel *)filesModel
{
    self = [super initWithLocalFilesModel:filesModel] ;
    if (self)
    {
        _waitingRemoteFileListingQuery = [[NSMutableIndexSet alloc] init];
//        _pendingManager = [[SWPendingManager alloc] init];
        _groupUploadStep = -1;
        _groupDownloadStep = -1;
        _redeemStep = -1;
    }
    return self;
}


- (void)dealloc
{
    NSLog1( @"AppFilesModel dealloc");
}

@end


//#pragma mark Acces a AppFilesModel
//
////-------------------------------------------------------------------------------------------- 
//static __strong AppFilesModel *_appFilesModel = nil ;
//
//AppFilesModel *filesModel(void)
//{
//    if ( _appFilesModel == nil ) _appFilesModel = [[AppFilesModel alloc] init] ;
//    return _appFilesModel ;
//}
//
//
////-------------------------------------------------------------------------------------------- 
//void filesModel_release(void)
//{
//    _appFilesModel = nil ;
//}


