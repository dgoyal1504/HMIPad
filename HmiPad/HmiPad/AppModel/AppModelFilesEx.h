//
//  AppIServerModel.h
//  HmiPad
//
//  Created by Joan on 09/03/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <StoreKit/StoreKit.h>

#import "AppModelFiles.h"


@class AppModelFilesEx;
@class SWPendingManager;
@class FileMD;

//enum
//{
//    // arxius i d'altres en el servidor
//    kFileCategoryRemoteSourceFile = 30,
//    kFileCategoryRemoteAssetFile,
//    kFileCategoryRemoteActivationCode,
//    kFileCategoryRemoteRedemption,
//    
//    // projectes i assets que s'estant baixant agrupats del servidor
//    kFileCategoryRemoteGroupSourceFile,
//    kFileCategoryRemoteGroupAssetFile,
//    
//    // projectes i assets que s'estant redimint del servidor
//    //kFileCategoryRemoteGroupRedeemedSourceFile,
//    //kFileCategoryRemoteGroupRedeemedAssetFile,
//        
//    
//} /*FileCategory*/ ;


@protocol AppFilesModelObserver<AppModelFilesObserver>

@optional

// remote files listing
- (void)appFilesModel:(AppModelFilesEx*)filesModel willChangeRemoteListingForCategory:(FileCategory)category;
- (void)appFilesModel:(AppModelFilesEx*)filesModel didChangeRemoteListingForCategory:(FileCategory)category withError:(NSError*)error;

// remote files upload
- (void)appFilesModel:(AppModelFilesEx*)filesModel beginGroupUploadForCategory:(FileCategory)category;
- (void)appFilesModel:(AppModelFilesEx*)filesModel willUploadFile:(NSString*)fileName forCategory:(FileCategory)category;
- (void)appFilesModel:(AppModelFilesEx*)filesModel didUploadFile:(NSString*)fileName forCategory:(FileCategory)category withError:(NSError*)error;
- (void)appFilesModel:(AppModelFilesEx*)filesModel endGroupUploadForCategory:(FileCategory)category finished:(BOOL)finished userCanceled:(BOOL)canceled;

// remote files upload progress
- (void)appFilesModel:(AppModelFilesEx*)filesModel groupUploadProgressStep:(NSInteger)step stepCount:(NSInteger)stepCount category:(FileCategory)category;
;
- (void)appFilesModel:(AppModelFilesEx*)filesModel fileUploadProgressBytesRead:(long long)bytesRead totalBytesExpected:(long long)totalBytesExpected category:(FileCategory)category;    // Deprecar
;

- (void)appFilesModel:(AppModelFilesEx*)filesModel fileUploadProgress:(double)progress fileName:(NSString*)fileName category:(FileCategory)category;

// redemptions
- (void)appFilesModel:(AppModelFilesEx*)filesModel willRedemCode:(NSString*)code;
- (void)appFilesModel:(AppModelFilesEx*)filesModel didRedemCode:(NSString*)code withError:(NSError*)error;

// remote files download
- (void)appFilesModel:(AppModelFilesEx*)filesModel beginGroupDownloadForCategory:(FileCategory)category;
- (void)appFilesModel:(AppModelFilesEx*)filesModel willDownloadFile:(NSString*)fileName forCategory:(FileCategory)category;
- (void)appFilesModel:(AppModelFilesEx*)filesModel didDownloadFile:(NSString*)fileName forCategory:(FileCategory)category withError:(NSError*)error;
- (void)appFilesModel:(AppModelFilesEx*)filesModel endGroupDownloadForCategory:(FileCategory)category finished:(BOOL)finished userCanceled:(BOOL)canceled;

// remote files download progress
- (void)appFilesModel:(AppModelFilesEx*)filesModel groupDownloadProgressStep:(NSInteger)step stepCount:(NSInteger)stepCount category:(FileCategory)category;
- (void)appFilesModel:(AppModelFilesEx*)filesModel fileDownloadProgressBytesRead:(long long)bytesRead totalBytesExpected:(long long)totalBytesExpected category:(FileCategory)category;

// remote files deletion
- (void)appFilesModel:(AppModelFilesEx*)filesModel willDeleteRemoteFile:(NSString*)fileName forCategory:(FileCategory)category;
- (void)appFilesModel:(AppModelFilesEx*)filesModel didDeleteRemoteFile:(NSString*)fileName forCategory:(FileCategory)category withError:(NSError*)error;

// remote file get info
- (void)appFilesModel:(AppModelFilesEx*)filesModel didGetRemoteFileMD:(FileMD*)fileMD forCategory:(FileCategory)category withError:(NSError*)error;

@end


@protocol AppFilesModelMigrationObserver<NSObject>
@optional
// remote files listing
- (void)appFilesModel:(AppModelFilesEx*)filesModel willChangeMigrationListingForCategory:(FileCategory)category;
- (void)appFilesModel:(AppModelFilesEx*)filesModel didChangeMigrationListingForCategory:(FileCategory)category withError:(NSError*)error;

- (void)appFilesModel:(AppModelFilesEx*)filesModel beginMigrationGroupDownloadForCategory:(FileCategory)category;

- (void)appFilesModel:(AppModelFilesEx*)filesModel willDownloadMigrationFile:(NSString*)fileName forCategory:(FileCategory)category;
- (void)appFilesModel:(AppModelFilesEx*)filesModel migrationFileDownloadProgress:(double)progress fileName:(NSString*)fileName category:(FileCategory)category;
- (void)appFilesModel:(AppModelFilesEx*)filesModel didDownloadMigrationFile:(NSString*)fileName forCategory:(FileCategory)category withError:(NSError*)error;

- (void)appFilesModel:(AppModelFilesEx*)filesModel endMigrationGroupDownloadForCategory:(FileCategory)category finished:(BOOL)finished userCanceled:(BOOL)canceled;
@end


//
//#pragma mark SKProduct category
//
//@interface SKProduct(priceString)
//
//+ (BOOL)isQProduct:(NSString*)productIdentifier;
//- (BOOL)isQProduct;
//@property (nonatomic,readonly) NSString *priceString;
//
//@end



#pragma mark Pending Products/Receipts persistence


@class UserProfile;


@interface AppModelFilesEx : AppModelFiles
{
    NSArray *_remoteSourceFilesArray;
    NSArray *_remoteAssetsFilesArray;
    NSArray *_remoteActivationCodesArray;
    NSArray *_remoteRedemptionsArray;
    
//    NSArray *_productsArray;
//    NSInteger _qProductsCount;
    
//    SWPendingManager *_pendingManager;
    
    
    FileSortingOption _remoteSourceFilesSortingOption;
    FileSortingOption _remoteAssetFilesSortingOption;

//    NSDictionary *_examplesListing;
}

@property (nonatomic, readonly) NSInteger groupUploadStep;   // <- 0 indica cap upload en proces.
@property (nonatomic, readonly) NSInteger redeemStep;  // <- 0 indica cap redeem en proces
@property (nonatomic, readonly) NSInteger groupDownloadStep;   // <- 0 indica cap download en proces.
@property (nonatomic, readonly) BOOL updatingProject;
@property (nonatomic, readonly) BOOL downloadingProject;


// Observers
- (void)addObserver:(id<AppFilesModelObserver>)observer;
- (void)removeObserver:(id<AppFilesModelObserver>)observer;

// File Listing
- (NSArray*)filesMDArrayForCategory:(FileCategory)category;    // torna un array de filesMD
- (void)refreshMDArrayForCategory:(FileCategory)category;
- (void)resetMDArrayForCategory:(FileCategory)category;
- (void)deleteFileWithFileMD:(FileMD*)fileMD forCategory:(FileCategory)category;
- (void)setFileSortingOption:(FileSortingOption)option forCategory:(FileCategory)category;
- (FileSortingOption)fileSortingOptionForCategory:(FileCategory)category;

// Integrators service
- (void)uploadProject;
- (void)cancelUpload;
- (void)getRemoteFileMDForFileWithUUID:(NSString*)uuid forCategory:(FileCategory)category;
- (void)downloadRemoteFileMDs:(NSArray*)fileMDs forCategory:(FileCategory)category;
- (void)uploadRemoteFileMDs:(NSArray*)fileMDs forCategory:(FileCategory)category;
- (void)downloadRemoteProjectMD:(FileMD*)projectMD; // << download(integrator)
- (void)downloadEmbeddedRemoteProjectMD:(FileMD*)projectMD; // << download(integrator)

// Redemptions
- (void)redeemActivationCodeMD:(FileMD*)activationMD;  // <<- activacio + download(redeemed)
//- (void)updateRedeemedProjectWithProjectID:(NSString*)projectId ownerID:(UInt32)projectOwner;   // << download(redeemed)
- (void)updateRedeemedProjectWithProjectID:(NSString*)projectId;
- (void)cancelDownload;
//- (void)validateProjectWithProjectID:(NSString*)projectId ownerID:(UInt32)projectOwner completion:(void(^)(BOOL done, BOOL result))block;
- (void)validateProjectWithProjectID:(NSString*)projectId completion:(void(^)(BOOL done, BOOL result))block;


@end


// iCloud conversion

@interface AppModelFilesEx()

//- (void)listRemoteIntegratorServerFilesForCategory:(FileCategory)category
//    profile:(UserProfile*)profile completion:(void(^)(NSArray *list, NSError *error))completion;
//
//- (void)migrateFileMDs:(NSArray*)fileMDs inCategory:(FileCategory)category
//    isProfile:(UserProfile*)isProfile ckProfile:(UserProfile*)ckProfile completion:(void(^)(BOOL))completion;

//- (void)migrateCategory:(FileCategory)category
//    isProfile:(UserProfile*)isProfile ckProfile:(UserProfile*)ckProfile completion:(void(^)(BOOL))completion;

- (void)migrateCategories:(NSArray*)categories isProfile:(UserProfile*)isProfile ckProfile:(UserProfile*)ckProfile completion:(void(^)(BOOL))completion;
@end



// Categories

@interface AppModelFilesEx()

- (void)_listRemoteFilesForCategory:(FileCategory)category;
//- (void)_primitiveUploadProjectWithFileName:(NSString*)fileName uuid:(NSString*)uuid
//        fileData:(NSData*)fileData thumbnailData:(NSData*)thumbnailData fileSize:(long long)fileSize profile:(UserProfile*)profile completion:(void(^)(BOOL,NSString*))block;


- (void)_notifyWillDownloadFile:(NSString*)fileName category:(FileCategory)category;
- (void)_notifyDidDownloadFile:(NSString*)fileName category:(FileCategory)category withError:(NSError*)error;
- (void)_notifyBeginGroupDownloadForCategory:(FileCategory)category;
- (void)_notifyGroupDownloadProgressStep:(NSInteger)step stepCount:(NSInteger)stepCount category:(FileCategory)category;
- (void)_notifyEndGroupDownload:(BOOL)finished userCanceled:(BOOL)canceled category:(FileCategory)category;

@end


