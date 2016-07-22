//
//  AppModelFilePaths.h
//  HmiPad
//
//  Created by Joan Lluch on 13/04/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//


#import "AppModel.h"

@class AppModelFilePaths;

@protocol AppModelFilePathsDelegate<NSObject>

@optional
- (void)filePathsDidFireITunesFileSharingDirectoryWatcher:(AppModelFilePaths*)filePaths;
- (void)filePathsDidFireDatabaseDirectoryWatcher:(AppModelFilePaths*)filePaths;

@end



@interface AppModelFilePaths : NSObject

@property (nonatomic,weak) id<AppModelFilePathsDelegate>delegate;

- (NSString *)documentsDirectoryPath;
- (NSString *)internalFilesDirectory;

- (NSString *)filesRootDirectoryForCategory:(FileCategory)category ;
- (NSString *)fileFullPathForFileName:(NSString*)fileName forCategory:(FileCategory)category ;
- (NSString *)originPathForFilename:(NSString*)fileName forCategory:(FileCategory)category;

- (NSString *)fileFullPathForAssetWithFileName:(NSString*)fileName;
- (NSString *)fileFullPathForAssetWithFileName:(NSString*)fileName embeddedInProjectName:(NSString*)projectName;
- (NSString *)fileFullPathForAssetWithFileName:(NSString*)fileName embeddedInProjectName:(NSString*)projectName temporaryStorage:(BOOL)temporary;
- (NSString *)fileFullPathForFileWithFileName:(NSString*)fileName bundledInProjectName:(NSString*)projectName temporaryStorage:(BOOL)temporary;

- (NSString *)databasesPath;
- (NSString *)assetsPath;
- (NSString *)embeddedAssetsPathForProjectName:(NSString*)projectName;

- (NSString *)temporaryFilePathForFileName:(NSString*)fileName;
- (NSString *)userAccountsFilePath;
- (NSString *)userAccountsFilePathCrypt;
- (NSString *)userAccountsFilePathCryptCK;

- (NSString *)companyLogoFilePath;
- (NSString *)temporaryLogoFilePath;

//- (NSString*)fullViewerUrlPathForTextUrl:(NSString*)textUrl; //forCategory:(FileCategory)category;

- (NSString *)fullAssetPathForName:(NSString*)fileName inDocumentName:(NSString *)documentName;
- (NSString *)fullViewerUrlPathForTextUrl:(NSString*)textUrl inDocumentName:(NSString*)documentName; //forCategory:(FileCategory)category;
- (NSString *)fullPlayerUrlPathForTextUrl:(NSString*)textUrl inDocumentName:(NSString*)documentName;
- (NSString *)fullRecipeSheetUrlPathForTextUrl:(NSString*)textUrl inDocumentName:(NSString*)documentName;

@end
