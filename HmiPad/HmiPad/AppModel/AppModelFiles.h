//
//  AppModelFiles.h
//  HmiPad
//
//  Created by Joan Lluch on 14/04/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//


#import "AppModel.h"
#import "FileMD.h"

@class AppModelFiles;

@protocol AppModelFilesObserver<NSObject>

@optional
- (void)appsFileModel:(AppModelFiles*)appModelFiles didChangeListingForCategory:(FileCategory)category;
- (void)appsFileModel:(AppModelFiles*)appModelFiles didUpdateFileAtFullPath:(NSString*)fullPath forCategory:(FileCategory)category;

@end

typedef enum : int
{
    kFileSortingOptionAny = 0,
    kFileSortingOptionDateDescending,
    kFileSortingOptionNameAscending
} FileSortingOption;

//typedef int FileSortingOption;


@interface AppModelFiles : NSObject
{
    __weak AppModel *_filesModel;
    NSMutableArray *_observers; // List of observers
//    dispatch_queue_t _dQueue;
//    const char *_queueKey ; // key for the dispatch queue
//    void *_queueContext ; // context for the dispatch queue
    
    // contenen FileMD
    NSArray *_sourceFilesArray;
    NSArray *_recipesArray;
    NSArray *_assetsFilesArray;
    NSArray *_databaseFilesArray;
    NSArray *_embeededAssetFilesArray;
    NSString *_projectForEmbeddedAssetFilesArray;
    
    NSArray *_iTunesFilesArray;
    NSArray *_iCloudFilesArray;

    FileSortingOption _sourceFilesSortingOption;
    FileSortingOption _recipesSortingOption;
    FileSortingOption _assetFilesSortingOption;
    
    FileSortingOption _iTunesSortingOption;
    FileSortingOption _iCloudSortingOption;
    
//    FileMD *_currentDocumentFileMD;
//    BOOL _currentDocumentFileMDNeedsReload;
}

//@property (nonatomic, weak) id<AppModelFilesDelegate> delegate;

- (id)initWithLocalFilesModel:(AppModel*)filesModel;
//- (void)setDispatchQueue:(dispatch_queue_t)dQueue key:(const char *)key;  // <-- call on initialization

- (void)addObserver:(id<AppModelFilesObserver>)observer;
- (void)removeObserver:(id<AppModelFilesObserver>)observer;

// File Listing
- (NSArray*)filesMDArrayForCategory:(FileCategory)category;    // torna un array de fileMD
- (NSArray*)filesMDArrayForCategory:(FileCategory)category lazy:(BOOL)lazyLoad;
- (NSArray*)assetsMDArrayEmbeddedInProjectName:(NSString*)projectName;    // torna un array de fileMD

//- (void)updateMDArrayForCategory:(FileCategory)category;   // soft refresh
- (void)refreshMDArrayForCategory:(FileCategory)category;  // hard refresh
- (void)resetMDArrayForCategory:(FileCategory)category;
- (void)deleteFileWithFileMD:(FileMD*)fileMD forCategory:(FileCategory)category;
- (void)setFileSortingOption:(FileSortingOption)option forCategory:(FileCategory)category;
- (FileSortingOption)fileSortingOptionForCategory:(FileCategory)category;

// Copy, Move, Duplicate, Delete, Rename
- (BOOL)renameFileWithFileName:(NSString*)oldName toFileName:(NSString*)newName forCategory:(FileCategory)category error:(NSError**)outError;
- (BOOL)duplicateFileWithFileName:(NSString*)fileName forCategory:(FileCategory)category error:(NSError**)outError;
- (BOOL)deleteFileWithFileName:(NSString*)fileName forCategory:(FileCategory)category error:(NSError**)outError;

- (BOOL)sendFileWithFileName:(NSString*)fileName withCategory:(FileCategory)inCategory
    toCategory:(FileCategory)outCategory outError:(NSError**)outError;

- (BOOL)embeedAssetsWithFileNames:(NSArray*)fileNames inProjectName:(NSString*)projectName;

- (BOOL)moveFromExternalFileFullPath:(NSString*)originPath toCategory:(FileCategory)category error:(NSError**)outError
    alwaysDeleteOriginal:(BOOL)alwaysDeleteOriginal;

- (BOOL)copyToTemporaryForFileFullPath:(NSString*)fullPath error:(NSError**)outError;
- (BOOL)copyToTemporaryForFileFullPath:(NSString*)fullPath destinationFile:(NSString*)destFile error:(NSError**)outError;
- (BOOL)moveFromTemporaryToCategory:(FileCategory)category forFile:(NSString*)file addCopy:(BOOL)addCopy error:(NSError**)outError;
- (BOOL)moveFromTemporaryToCategory:(FileCategory)category forFile:(NSString*)file projectName:(NSString*)projectName
    isEncrypted:(BOOL)isEncrypted addCopy:(BOOL)addCopy error:(NSError**)outError;
- (BOOL)moveToProjectsForTemporaryProject:(NSString*)projectName error:(NSError**)outError;
- (BOOL)moveToRedemmedProjectsForTemporaryProject:(NSString*)projectName error:(NSError**)outError;

@end

@interface AppModelFiles(Protected)

- (void)notifyFileListingChangeForCategory:(FileCategory)category;

- ( NSArray*__strong*)_primitiveMDFilesArrayRefForCategory:(FileCategory)category;
- (NSArray*)_getFileMDsArrayForFileList:(NSArray*)files forCategory:(FileCategory)category;
- (void)_sortFilesForCategory:(FileCategory)category;

@end
