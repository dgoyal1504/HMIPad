//
//  AppModelFiles.m
//  HmiPad
//
//  Created by Joan Lluch on 14/04/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "AppModelFiles.h"

#import "AppModelFilePaths.h"
#import "AppModelDocument.h"
#import "AppModelSource.h"
#import "AppModelDatabase.h"
#import "AppModelImage.h"

#import "UserDefaults.h"


@interface AppModelFiles()
@end


@implementation AppModelFiles
{
    NSMutableIndexSet *_pendingFileListingNotifications;
//    NSMutableIndexSet *_pendingFileListingWillNotifications;
}


- (id)initWithLocalFilesModel:(AppModel*)filesModel
{
    self = [super init];
    if ( self )
    {
        _filesModel = filesModel;
        _observers = CFBridgingRelease(CFArrayCreateMutable(NULL, 0, NULL));
        _pendingFileListingNotifications = [[NSMutableIndexSet alloc] init];
//        _pendingFileListingWillNotifications = [[NSMutableIndexSet alloc] init];
    }
    return self;
}


//- (void)setDispatchQueue:(dispatch_queue_t)dQueue key:(const char *)key
//{
//    _queueKey = key;
//    _queueContext = dispatch_queue_get_specific(dQueue, key);
//    _dQueue = dQueue;
//}


- (void)_notifyFileDeleteAtFullPath:(NSString*)fullFileName category:(FileCategory)category
{
    if ( category == kFileCategoryAssetFile || category == kFileCategoryEmbeddedAssetFile )
    {
        [_filesModel.amImage purgueImagesWithOriginalPath:fullFileName];
    }
}


- (void)_notifyFileUpdateWithFullPath:(NSString*)fullFileName category:(FileCategory)category
{
    if ( category == kFileCategoryAssetFile || category == kFileCategoryEmbeddedAssetFile )
    {
        [_filesModel.amImage purgueImagesWithOriginalPath:fullFileName];
    }
    
    for ( id<AppModelFilesObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appsFileModel:didUpdateFileAtFullPath:forCategory:)])
        {
            [observer appsFileModel:self didUpdateFileAtFullPath:fullFileName forCategory:category];
        }
    }
}


- (void)_notifyFileListingChangeForCategory:(FileCategory)category
{
    if ( category == kFileCategoryTemporarySourceFile || category == kFileCategoryTemporaryBundledFile || category == kFileCategoryTemporaryEmbedeedAssetFile  )
    {
        return;
    }

    if ( NO == [_pendingFileListingNotifications containsIndex:category])
    {
        // simplement ens carreguem el array amb lo qual si despres de la notificacio de canvi es necesita
        // es tornara a generar de seguida que una vista el requereixi
        // amb aixo optimitzem que si no s'arriba a demanar ni tant sols es regenera
        //[self resetMDArrayForCategory:category];
        
        [_pendingFileListingNotifications addIndex:category];
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [_pendingFileListingNotifications enumerateIndexesUsingBlock:^(NSUInteger idxCategory, BOOL *stop)
            {
                [self resetMDArrayForCategory:idxCategory];
            
                for ( id<AppModelFilesObserver>observer in _observers )
                {
                    if ( [observer respondsToSelector:@selector(appsFileModel:didChangeListingForCategory:)])
                        [observer appsFileModel:self didChangeListingForCategory:idxCategory];
                }
            }];
            [_pendingFileListingNotifications removeAllIndexes];
        });
    }
}


- (void)notifyFileListingChangeForCategory:(FileCategory)category
{
    [self _notifyFileListingChangeForCategory:category];
}


#pragma mark - File Document observation

- (void)addObserver:(id<AppModelFilesObserver>)observer
{
    [_observers addObject:observer];
}

- (void)removeObserver:(id<AppModelFilesObserver>)observer
{
    [_observers removeObjectIdenticalTo:observer];
}


#pragma mark File Paths (Private)

- ( NSArray*__strong*)_primitiveMDFilesArrayRefForCategory:(FileCategory)category
{
    if ( category == kFileCategorySourceFile ) return &_sourceFilesArray ;
    else if ( category == kFileCategoryRecipe ) return &_recipesArray ;
    else if ( category == kFileCategoryAssetFile ) return &_assetsFilesArray ;
    else if ( category == kFileCategoryDatabase ) return &_databaseFilesArray;
    
    //if ( category == kFileCategoryRedeemedSourceFile ) return &_redeemedSourceFilesArray ;
    else if ( category == kFileCategoryEmbeddedAssetFile ) return &_embeededAssetFilesArray ;
    
    else if ( category == kExtFileCategoryITunes ) return &_iTunesFilesArray ;
    
    NSAssert( false, @"Categoria no reconeguda a primitiveFilesArrayForCategory") ;
    return nil ;
}



#pragma mark Atributs

- (NSArray*)filesMDArrayForCategory:(FileCategory)category
{
    return [self filesMDArrayForCategory:category lazy:YES];
}


- (NSArray*)filesMDArrayForCategory:(FileCategory)category lazy:(BOOL)lazyLoad
{
    NSArray *__strong*files = [self _primitiveMDFilesArrayRefForCategory:category];

    if ( *files == nil && lazyLoad)
    {
        [self _listLocalFilesForCategory:category];
        [self _sortFilesForCategory:category];
    }
    
    return *files;
}


- (NSArray*)assetsMDArrayEmbeddedInProjectName:(NSString*)projectName
{
    FileCategory assetsCategory = kFileCategoryEmbeddedAssetFile;
    NSArray *__strong*files = [self _primitiveMDFilesArrayRefForCategory:assetsCategory];

    if ( *files == nil || ![_projectForEmbeddedAssetFilesArray isEqualToString:projectName] )
    {
        [self _listLocalFilesForAssetsEmbeddedInProject:projectName];
        _projectForEmbeddedAssetFilesArray = projectName;
    }
    
    return *files;
}




- (NSArray*)_getFileMDsArrayForFileList:(NSArray*)files forCategory:(FileCategory)category
{
    NSArray *allFileMDs = [self filesMDArrayForCategory:category];
    NSMutableArray *fileMDs = [NSMutableArray array];
    
    for ( NSString *file in files )
    {
        for ( FileMD *fileMD in allFileMDs )
        {
            NSString *fileMDFileName = fileMD.fileName;
            if ( NSOrderedSame == [fileMDFileName localizedStandardCompare:file] )
            {
                [fileMDs addObject:fileMD];
                break;
            }
        }
    }
    
    return fileMDs;
}


- (void)resetMDArrayForCategory:(FileCategory)category
{
    NSArray *__strong*files = [self _primitiveMDFilesArrayRefForCategory:category];
    *files = nil;
    
    if ( category == kFileCategoryEmbeddedAssetFile )
        _projectForEmbeddedAssetFilesArray = nil;
}


- (void)refreshMDArrayForCategory:(FileCategory)category
{
    [self _notifyFileListingChangeForCategory:category];
}



- (void)setFileSortingOption:(FileSortingOption)option forCategory:(FileCategory)category
{
    FileSortingOption currentOption = [self fileSortingOptionForCategory:category];
    if ( option != currentOption )
    {
        UserDefaults *userDefaults = defaults();
        if ( category == kFileCategorySourceFile ) [userDefaults setSourceFileSortingOptions:option];
        //else if ( category == kFileCategoryRedeemedSourceFile ) [userDefaults setRedeemedSourceFileSortingOptions:option];
        else if ( category == kFileCategoryRecipe ) [userDefaults setRecipeFileSortingOptions:option];
        else if ( category == kFileCategoryAssetFile ) [userDefaults setAssetFileSortingOptions:option];
        else if ( category == kFileCategoryDatabase ) [userDefaults setDatabaseFileSortingOptions:option];
        
//        else if ( category == kFileCategoryRemoteSourceFile ) [userDefaults setRemoteSourceFileSortingOptions:option];
//        else if ( category == kFileCategoryRemoteAssetFile ) [userDefaults setRemoteAssetFileSortingOptions:option];
//        else if ( category == kFileCategoryRemoteActivationCode ) [userDefaults setRemoteActivationCodeSortingOptions:option];
        
        else if ( category == kExtFileCategoryITunes ) [userDefaults setITunesFileSortingOptions:option];
        
        [self _notifyFileListingChangeForCategory:category];
    }
}


- (FileSortingOption)fileSortingOptionForCategory:(FileCategory)category
{
    UserDefaults *userDefaults = defaults();
    FileSortingOption option = kFileSortingOptionAny;
    
    if ( category == kFileCategorySourceFile ) option = [userDefaults sourceFileSortingOptions];
    //else if ( category == kFileCategoryRedeemedSourceFile ) option = [userDefaults redeemedSourceFileSortingOptions];
    else if ( category == kFileCategoryRecipe ) option = [userDefaults recipeFileSortingOptions];
    else if ( category == kFileCategoryAssetFile ) option = [userDefaults assetFileSortingOptions];
    else if ( category == kFileCategoryDatabase ) option = [userDefaults databaseFileSortingOptions];
    
//    if ( category == kFileCategoryRemoteSourceFile ) option = [userDefaults remoteSourceFileSortingOptions];
//    else if ( category == kFileCategoryRemoteAssetFile ) option = [userDefaults remoteAssetFileSortingOptions];
//    else if ( category == kFileCategoryRemoteActivationCode ) option = [userDefaults remoteActivationCodeSortingOptions];
    
    else if ( category == kExtFileCategoryITunes ) option = [userDefaults iTunesFileSortingOptions];
    return option;
}




//------------------------------------------------------------------------------------
- (NSString *)fileSizeStrForFileName:(NSString*)fileName forCategory:(FileCategory)category
{
    NSDictionary *fileAttibutes = [self _fileAttributesForFileName:fileName forCategory:category] ;
    NSNumber *nsSize = [fileAttibutes objectForKey:NSFileSize] ;
    return fileSizeStrForSizeValue([nsSize unsignedLongLongValue]) ;
}



//------------------------------------------------------------------------------------
- (NSString *)fileDateStrForFileName:(NSString*)fileName forCategory:(FileCategory)category
{
    NSDictionary *fileAttributes = [self _fileAttributesForFileName:fileName forCategory:category] ;
//    NSNumber *nsSize = [fileAttributes objectForKey:NSFileSize] ;
//    NSString *sizeStr = [self fileSizeStrForSizeValue:[nsSize unsignedLongLongValue]] ;
    
    NSDate *date = [fileAttributes objectForKey:NSFileModificationDate] ;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateStr = [dateFormatter stringFromDate:date] ;
    
    // alternatiu...
    //NSString *dateStr = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle] ;
    
    return dateStr ;
}



#pragma mark Atributs (Private)



- (FileMD*)_getFileMDForFileURL:(NSURL*)fUrl forCategory:(FileCategory)category
{
//    return [self _updateFileMD:nil forFileURL:fUrl forCategory:category];
    return [FileMD updatedFileMD:nil forFileURL:fUrl forCategory:category];
}



- (void)_listLocalFilesForAssetsEmbeddedInProject:(NSString*)projectName
{
    NSString *embeededPath = [_filesModel.filePaths embeddedAssetsPathForProjectName:projectName];
    
    FileCategory assetsCategory = kFileCategoryEmbeddedAssetFile;
    [self _localFilesArrayAtPath:embeededPath withCategory:assetsCategory];
}


- (void)_listLocalFilesForCategory:(FileCategory)category
{
    NSString *path = [_filesModel.filePaths filesRootDirectoryForCategory:category];
    
    [self _localFilesArrayAtPath:path withCategory:category];
}


//
//- (void)_localFilesArrayAtPathV:(NSString*)path withCategory:(FileCategory)category
//{
//    //NSString *path = [self filesRootDirectoryForCategory:category];
//    NSURL *pathURL = [NSURL fileURLWithPath:path];
//    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//        
//    //NSArray *farray = [fileManager contentsOfDirectoryAtPath:path error:NULL] ;
//   NSArray *fArray = [fileManager contentsOfDirectoryAtURL:pathURL
//        includingPropertiesForKeys:@[NSURLContentModificationDateKey,NSURLIsDirectoryKey,NSURLNameKey,NSURLFileSizeKey]
//        options:NSDirectoryEnumerationSkipsHiddenFiles
//        error:nil];
//    
//    BOOL shouldFindDocument = NO;
//    SWDocument *currentDocument = _fileDocument.currentDocument;
//    if (category == kFileCategorySourceFile)
//    {
//        _currentDocumentFileMD = nil;
//        _currentDocumentFileMDNeedsReload = NO;
//        if (currentDocument ) shouldFindDocument = YES ;
//    }
//    
//    NSURL *documentURL = nil;
//    NSString *documentName = nil;
//    NSString *documentUuid = nil;
//    
//    if ( shouldFindDocument )    // QWE
//    {
//        SWDocumentModel *docModel = currentDocument.docModel;
//        documentURL = [currentDocument fileURL];
//        documentName = [documentURL lastPathComponent];
//        documentUuid = docModel.uuid;
//    }
//    
//    //NSLog( @"documentURL %@", documentURL );
//    
//    NSMutableArray *filesMDArray = [NSMutableArray array];
//    for ( NSURL *fUrl_ in fArray )
//    {
//       // NSURL *fUrl = [fUrl_ URLByStandardizingPath];
//        NSURL *fUrl = fUrl_ ;
//    
//        FileMD *fileMD = [self _getFileMDForFileURL:fUrl forCategory:category];
//        if ( fileMD == nil )
//            continue;
//        
//        //NSLog( @"fileURL %@", fUrl );
//        
//        NSString *fileName = [fUrl lastPathComponent];
//        
//        if ( shouldFindDocument && [documentName isEqualToString:fileName] )
//        {
//            fileMD.isDisabled = YES;
//            fileMD.identifier = documentUuid;  // en el cas de sources el fileMD del document actual conte el identificador
//            _currentDocumentFileMD = fileMD;
//            _currentDocumentFileMD.image = currentDocument.docModel.thumbnailImage;
//        }
//        //else
//        {
//            [filesMDArray addObject:fileMD];
//        }
//    }
//    
//    if ( shouldFindDocument )
//    {
//        if ( _currentDocumentFileMD == nil )
//        {
//            // Evitem el estat inconsistent de la aplicacio resetejant el document en cas que no es trobi el seu arxiu
//            _fileDocument.currentDocument = nil;
//        }
//    }
//    
//    NSArray *__strong*files = [self _primitiveMDFilesArrayRefForCategory:category];
//    *files = filesMDArray;
//}


- (void)_localFilesArrayAtPath:(NSString*)path withCategory:(FileCategory)category
{
    //NSString *path = [self filesRootDirectoryForCategory:category];
    NSURL *pathURL = [NSURL fileURLWithPath:path];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error = nil;
        
    //NSArray *fArray = [fileManager contentsOfDirectoryAtPath:path error:&error] ;
    NSArray *fArray = [fileManager contentsOfDirectoryAtURL:pathURL
        includingPropertiesForKeys:@[NSURLContentModificationDateKey,NSURLIsDirectoryKey,NSURLNameKey,NSURLFileSizeKey]
        options:NSDirectoryEnumerationSkipsHiddenFiles
        error:&error];
    
    //NSLog( @"%@", error);
    
    //NSLog( @"documentURL %@", documentURL );
    
    NSMutableArray *filesMDArray = [NSMutableArray array];
    for ( NSURL *fUrl_ in fArray )
    {
       // NSURL *fUrl = [fUrl_ URLByStandardizingPath];
        NSURL *fUrl = fUrl_ ;
    
        FileMD *fileMD = [self _getFileMDForFileURL:fUrl forCategory:category];
        if ( fileMD == nil )
            continue;
        
        //NSLog( @"fileURL %@", fUrl );
        
        [filesMDArray addObject:fileMD];
    }
    
    NSArray *__strong*files = [self _primitiveMDFilesArrayRefForCategory:category];
    *files = filesMDArray;
    
    if (category == kFileCategorySourceFile)
    {
        [_filesModel.fileDocument refreshCurrentDocumentFileMD];
    }
    
    if (category == kFileCategoryDatabase)
    {
        [_filesModel.amDatabase refreshActiveDatabaseFileMDs];
    }
}



- (void)_sortFilesForCategory:(FileCategory)category;
{
    NSArray *__strong*files = [self _primitiveMDFilesArrayRefForCategory:category];
    
    if ( *files == nil )
        return;
    
    FileSortingOption sortingOption = [self fileSortingOptionForCategory:category];
    
    if ( sortingOption != kFileSortingOptionAny )
    {
        NSComparisonResult (^block)(FileMD*,FileMD*) = nil ;
    
        if ( sortingOption == kFileSortingOptionDateDescending )
        {
            block = ^NSComparisonResult(FileMD *fileMD1, FileMD *fileMD2)
            {
                // Descending:
                NSComparisonResult diff = [fileMD2.laterDate compare:fileMD1.laterDate]; // descending
                if ( diff == NSOrderedSame )
                {
                    NSString *name1 = fileMD1.fileName;
                    NSString *name2 = fileMD2.fileName;
                    diff = name1?[name1 localizedStandardCompare:name2]:name2?NSOrderedAscending:NSOrderedSame;
                }
                return diff;
            };
        }
    
        else if ( sortingOption == kFileSortingOptionNameAscending )
        {
            block = ^NSComparisonResult(FileMD *fileMD1, FileMD *fileMD2)
            {
                NSString *name1 = fileMD1.fileName;
                NSString *name2 = fileMD2.fileName;
                NSComparisonResult diff = name1?[name1 localizedStandardCompare:name2]:name2?NSOrderedAscending:NSOrderedSame; // Ascending
                if ( diff == NSOrderedSame ) diff = [fileMD2.laterDate compare:fileMD1.laterDate]; // descending
                return diff;
            };
        }
    
        *files = [*files sortedArrayUsingComparator:block];
    }
}


- (NSDictionary *)_fileAttributesForFileName:(NSString*)fileName forCategory:(FileCategory)category
{
    NSFileManager *fileManager = [NSFileManager defaultManager] ;
    NSString *fullPath = [_filesModel.filePaths fileFullPathForFileName:fileName forCategory:category] ;
    return [fileManager attributesOfItemAtPath:fullPath error:NULL];
}



#pragma mark Copiar, Moure, Borrar


- (BOOL)renameFileWithFileName:(NSString*)oldName toFileName:(NSString*)newName forCategory:(FileCategory)category error:(NSError**)outError
{
    NSError *error = nil;
    
    BOOL success = YES ;
    if ( category == kFileCategorySourceFile)
    {
        FileMD *fileMD = [_filesModel.fileDocument currentDocumentFileMD];
        NSString *docName = fileMD.fileName;
        if ( docName && NSOrderedSame == [docName caseInsensitiveCompare:oldName] )
        {
            success = NO;
            
            NSString *format = NSLocalizedString(@"Current project can not be renamed. Please close '%@' before attempting to rename it", nil);
            NSString *message = [NSString stringWithFormat:format, oldName];
            error = _errorWithLocalizedDescription_title(message, nil);
        }
    }
    
    if ( success )
    {
        NSString *oldFilePath = [_filesModel.filePaths fileFullPathForFileName:oldName forCategory:category] ;
        NSString *newFilePath = [_filesModel.filePaths fileFullPathForFileName:newName forCategory:category] ;

        NSFileManager *fileManager = [NSFileManager defaultManager];
        success = [fileManager moveItemAtPath:oldFilePath toPath:newFilePath error:&error];
        if ( success )
        {
            [self _notifyFileListingChangeForCategory:category];
            [self _notifyFileUpdateWithFullPath:newFilePath category:category];
        }
    }
    
    if ( !success )
    {
        NSString *title = NSLocalizedString(@"Error", nil);
        error = _completeErrorWithError_title(error, title);
        if ( outError )
            *outError = error;
    }
    
    return success;
}


- (BOOL)duplicateFileWithFileName:(NSString*)fileName forCategory:(FileCategory)category error:(NSError**)outError
{
    NSError *error = nil;
    NSString *fullPath = [_filesModel.filePaths fileFullPathForFileName:fileName forCategory:category] ;
//    NSString *extension = [fileName pathExtension];
//    NSString *noExtensionPath = [fullPath stringByDeletingPathExtension];
//    NSString *newFilePath = [[noExtensionPath stringByAppendingString:@"_copy"] stringByAppendingPathExtension:extension];
    
    NSString *newFilePath = _correctedPathFromPath_byAddingSuffix(fullPath, @"_copy");
    
    newFilePath = _correctedPathForDroppingFullFilePath(newFilePath);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager copyItemAtPath:fullPath toPath:newFilePath error:&error];
    if ( success ) [self _notifyFileListingChangeForCategory:category];
    
    if ( !success )
    {
        NSString *title = NSLocalizedString(@"Error", nil);
        error = _completeErrorWithError_title(error, title);
        if ( outError )
            *outError = error;
    }
    
    return success;
}


- (void)deleteFileWithFileMD:(FileMD *)fileMD forCategory:(FileCategory)category
{
    [self deleteFileWithFileName:fileMD.fileName forCategory:category error:nil];
}


- (BOOL)deleteFileWithFileName:(NSString*)fileName forCategory:(FileCategory)category error:(NSError**)outError
{
    BOOL success = YES ;
    NSError *error = nil;

    if ( category == kFileCategorySourceFile)
    {
        FileMD *fileMD = [_filesModel.fileDocument currentDocumentFileMD];
        NSString *docName = fileMD.fileName;
        if ( docName && NSOrderedSame == [docName caseInsensitiveCompare:fileName] )
        {
            success = NO;
            
            NSString *format = NSLocalizedString(@"Current project can not be deleted. Please close '%@' before attempting to delete it", nil);
            NSString *message = [NSString stringWithFormat:format, fileName];
            error = _errorWithLocalizedDescription_title(message, nil);
        }
    }

    NSString *fullFileName = nil;
    if ( success )
    {
        fullFileName = [_filesModel.filePaths fileFullPathForFileName:fileName forCategory:category];
        success = (fullFileName != nil);
    }
    
    if ( success )
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ( [fileManager fileExistsAtPath:fullFileName] )
            success = [fileManager removeItemAtPath:fullFileName error:nil];
        else
            success = NO;
    }
    
    if ( success )
    {
        [self _notifyFileListingChangeForCategory:category];
        [self _notifyFileDeleteAtFullPath:fullFileName category:category];
    }
    
    if ( !success )
    {
        if ( error == nil )
        {
            NSString *format = NSLocalizedString(@"Could not delete '%@'", nil);
            NSString *message = [NSString stringWithFormat:format, fileName];
            error = _errorWithLocalizedDescription_title(message, nil);
        }
        NSString *title = NSLocalizedString(@"Delete Error", nil);
        error = _completeErrorWithError_title(error, title);
        
        if ( outError )
            *outError = error;
    }
    return success ;
}


- (BOOL)embeedAssetsWithFileNames:(NSArray*)fileNames inProjectName:(NSString*)projectName
{
    BOOL success = YES;;
    NSError *error = nil;
    
    NSString *embeddedPath = [_filesModel.filePaths embeddedAssetsPathForProjectName:projectName];
    for ( NSString *fileName in fileNames )
    {
        NSString *assetPath = [_filesModel.filePaths fileFullPathForAssetWithFileName:fileName];
        NSString *destPath = [embeddedPath stringByAppendingPathComponent:fileName];

        success = [self _copyInternalFileFullPath:assetPath toInternalFileFullPath:destPath error:&error];
        if ( !success )
            break;
    }
    return success;
}


//------------------------------------------------------------------------------------
- (BOOL)sendFileWithFileName:(NSString*)fileName withCategory:(FileCategory)inCategory toCategory:(FileCategory)outCategory outError:(NSError**)outError
{
//    if ( outCategory == kFileCategoryRemoteSourceFile ||
//        outCategory == kFileCategoryRemoteAssetFile ||
//        outCategory == kFileCategoryRemoteActivationCode )
//    {
//        NSAssert( inCategory == kFileCategoryAssetFile, @"cucut ha de ser asset file");
//        NSAssert( outCategory == kFileCategoryRemoteAssetFile, @"cucut ha de ser remote asset file");
//        //[self _uploadFileWithFileName:fileName withCategory:inCategory toRemoteCategory:outCategory completion:nil];
//        [self _uploadFileWithFileName:fileName completion:nil];
//        return YES;
//    }


    NSString *inFullFileName = [_filesModel.filePaths fileFullPathForFileName:fileName forCategory:inCategory] ;
    NSString *outFullFileName = [_filesModel.filePaths fileFullPathForFileName:fileName forCategory:outCategory] ;
    
    BOOL success = NO ;
    if ( inFullFileName && outFullFileName )
    {
        BOOL inIsExtern = (inCategory == kExtFileCategoryITunes);
        BOOL outIsExtern = (outCategory == kExtFileCategoryITunes);
        
        if ( !inIsExtern && outIsExtern )
        {
            success = [self _copyFromInternalFileFullPath:inFullFileName toExternalFileFullPath:outFullFileName error:outError];
        }
        
        else if ( inIsExtern && !outIsExtern )
        {
            success = [self _moveFromExternalFileFullPath:inFullFileName toInternalFileFullPath:outFullFileName
                error:outError alwaysDeleteOriginal:NO isEncrypted:NO addCopy:NO];
        }
        
        else if ( !inIsExtern && !outIsExtern )
        {
            success = [self _moveInternalFileFullPath:inFullFileName toInternalFileFullPath:outFullFileName error:outError];
        }
        
        else
        {
            NSAssert( false, @"Enviament entre externs no esta suportat" );
        }
    }
    
    if ( success )
    {
        [self _notifyFileListingChangeForCategory:inCategory];
        [self _notifyFileListingChangeForCategory:outCategory];
        [self _notifyFileUpdateWithFullPath:outFullFileName category:outCategory];
    }
    return success ;
}


- (BOOL)moveFromTemporaryToCategory:(FileCategory)category forFile:(NSString*)file
    projectName:(NSString*)projectName isEncrypted:(BOOL)isEncrypted addCopy:(BOOL)addCopy error:(NSError**)outError
{
    NSString *fileName = [file lastPathComponent];
    NSString *tmpFilePath = [_filesModel.filePaths temporaryFilePathForFileName:fileName];
    NSString *destFullPath = nil;
    
    BOOL temporary = (category == kFileCategoryTemporarySourceFile || category == kFileCategoryTemporaryBundledFile || category == kFileCategoryTemporaryEmbedeedAssetFile);
    BOOL embedeed = (category == kFileCategoryEmbeddedAssetFile || category == kFileCategoryTemporaryEmbedeedAssetFile);
    BOOL bundled = (category == kFileCategoryTemporaryBundledFile);
    
    if ( embedeed )
    {
        destFullPath = [_filesModel.filePaths fileFullPathForAssetWithFileName:file embeddedInProjectName:projectName temporaryStorage:temporary];
    }
    else if ( bundled )
    {
        destFullPath = [_filesModel.filePaths fileFullPathForFileWithFileName:file bundledInProjectName:projectName temporaryStorage:temporary];
    }
    else
    {
        destFullPath = [_filesModel.filePaths fileFullPathForFileName:fileName forCategory:category];
    }
    
    // els moviments cap a una categoria temporal volem que destrueixin el fitxer que hi havia
    if ( temporary ) [self _removeItemAtFullPath:destFullPath error:outError];
    
    BOOL success = [self _moveFromExternalFileFullPath:tmpFilePath toInternalFileFullPath:destFullPath
        error:outError alwaysDeleteOriginal:YES isEncrypted:isEncrypted addCopy:addCopy];
    
    if ( success )
    {
        [self _notifyFileListingChangeForCategory:category];
        [self _notifyFileUpdateWithFullPath:destFullPath category:category];
    }
    return success;
}


//------------------------------------------------------------------------------------
- (BOOL)moveFromTemporaryToCategory:(FileCategory)category forFile:(NSString*)file addCopy:(BOOL)addCopy error:(NSError**)outError
{
    return [self moveFromTemporaryToCategory:category forFile:file projectName:nil isEncrypted:NO addCopy:addCopy error:outError];
}


//------------------------------------------------------------------------------------
- (BOOL)copyToTemporaryForFileFullPath:(NSString*)fullPath error:(NSError**)outError
{
    return [self copyToTemporaryForFileFullPath:fullPath destinationFile:fullPath error:outError];
}


- (BOOL)copyToTemporaryForFileFullPath:(NSString*)fullPath destinationFile:(NSString*)destFile error:(NSError**)outError
{
    NSString *tmpFilePath = [_filesModel.filePaths temporaryFilePathForFileName:[destFile lastPathComponent]];
    return [self _copyFromInternalFileFullPath:fullPath toExternalFileFullPath:tmpFilePath error:outError];
}


//------------------------------------------------------------------------------------
- (BOOL)moveFromExternalFileFullPath:(NSString*)originPath toCategory:(FileCategory)category error:(NSError**)outError
    alwaysDeleteOriginal:(BOOL)alwaysDeleteOriginal
{
    NSString *fileName = [originPath lastPathComponent];
    NSString *fileFullPath = [_filesModel.filePaths fileFullPathForFileName:fileName forCategory:category];
    BOOL success = [self _moveFromExternalFileFullPath:originPath toInternalFileFullPath:fileFullPath
        error:outError alwaysDeleteOriginal:alwaysDeleteOriginal isEncrypted:NO addCopy:NO];
    
    if ( success )
    {
        [self _notifyFileListingChangeForCategory:category];
        [self _notifyFileUpdateWithFullPath:fileFullPath category:category];
    }
    return success;
}


- (BOOL)moveToRedemmedProjectsForTemporaryProject:(NSString*)projectName error:(NSError**)outError
{
    return [self _moveToPlaceForTemporaryProject:projectName error:outError setOld:YES];
}


- (BOOL)moveToProjectsForTemporaryProject:(NSString*)projectName error:(NSError**)outError
{
    return [self _moveToPlaceForTemporaryProject:projectName error:outError setOld:NO];
}



//------------------------------------------------------------------------------------
- (BOOL)_moveToPlaceForTemporaryProject:(NSString*)projectName error:(NSError**)outError setOld:(BOOL)setOld
{
    BOOL success = YES;
    FileCategory destCategory = kFileCategorySourceFile;
    NSString *destFilePath = [_filesModel.filePaths fileFullPathForFileName:projectName forCategory:destCategory];
    
    if ( setOld )
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ( [fileManager fileExistsAtPath:destFilePath] )
        {
            FileMD *fileMD = [_filesModel.fileDocument currentDocumentFileMD];
            NSString *docName = fileMD.fileName;
            if ( docName && NSOrderedSame == [docName caseInsensitiveCompare:projectName] )
                [_filesModel.fileSource setProjectSources:nil];    // tanquem el document obert si es el mateix nom que el que movem
        
            // si el projecte ja hi era l'hi canviem el nom
            NSString *newFilePath = _correctedPathFromPath_byAddingSuffix(destFilePath, @"_old");
            newFilePath = _correctedPathForDroppingFullFilePath(newFilePath);
            success = [fileManager moveItemAtPath:destFilePath toPath:newFilePath error:outError];
        }
    }
    
    if ( success )
    {
        NSString *originPath = [_filesModel.filePaths fileFullPathForFileName:projectName forCategory:kFileCategoryTemporarySourceFile];

        destFilePath = _correctedPathForDroppingFullFilePath(destFilePath);
    
        success = [self _moveInternalFileFullPath:originPath toInternalFileFullPath:destFilePath error:outError];
        if ( success )
        {
            [self _notifyFileListingChangeForCategory:destCategory];
            [self _notifyFileUpdateWithFullPath:destFilePath category:destCategory];
        }
    }
        return success;
}


#pragma mark primitives per Copiar, Moure (Private)


static NSString *_correctedPathFromPath_byAddingSuffix(NSString *path, NSString *suffix)
{
    return [[[path stringByDeletingPathExtension] stringByAppendingString:suffix] stringByAppendingPathExtension:[path pathExtension]];
}


static NSString *_correctedPathForDroppingFullFilePath(NSString *destFilePath)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
 
    NSString *destDir = [destFilePath stringByDeletingLastPathComponent];
    NSString *destFile = [destFilePath lastPathComponent];
    NSString *extension = [destFile pathExtension];
    NSString *noExtension = [destFile stringByDeletingPathExtension];
    NSString *destFile0 = destFile;
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:destDir error:nil];
    for ( int i=1; [contents containsObject:destFile0] ; i++ )
    {
        destFile0 = [noExtension stringByAppendingFormat:@"-%d", i ];
        destFile0 = [destFile0 stringByAppendingPathExtension:extension];
    }
    NSString *newFilePath = [destDir stringByAppendingPathComponent:destFile0];
    return newFilePath;
}


- (BOOL)_dropItemAtPath:(NSString*)originPath toPath:(NSString*)destFilePath addCopy:(BOOL)addCopy error:(NSError**)outError
{
    BOOL success = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ( addCopy )
    {
        NSString *newFilePath = _correctedPathForDroppingFullFilePath(destFilePath);
        success = [fileManager copyItemAtPath:originPath toPath:newFilePath error:outError];
    }
    else
    {
        NSURL *orig = [NSURL fileURLWithPath:originPath];
        NSURL *dest = [NSURL fileURLWithPath:destFilePath];
        success = [fileManager replaceItemAtURL:dest withItemAtURL:orig backupItemName:nil
         options:NSFileManagerItemReplacementUsingNewMetadataOnly resultingItemURL:&dest error:outError];
    }
    return success;
}


- (BOOL)_moveFromExternalFileFullPath:(NSString*)originPath toInternalFileFullPath:(NSString*)destFilePath error:(NSError**)outError
    alwaysDeleteOriginal:(BOOL)alwaysDeleteOriginal isEncrypted:(BOOL)isEncrypted addCopy:(BOOL)addCopy
{
    BOOL success = NO ;
    if ( originPath && destFilePath )
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *destExtension = [destFilePath pathExtension];
        NSString *origExtension = [originPath pathExtension];
        NSString *binaryFilePath = nil;
        success = YES;
        
        // Si el origen es un directori sense extensio asummim que es del tipus wrap i modifiquem el desti amb extensio SWFileExtensionWrapp
        // Copiarem el directori tal qual
        BOOL originIsDirectory = NO;
        BOOL originExists = [fileManager fileExistsAtPath:originPath isDirectory:&originIsDirectory];
        if ( originExists && originIsDirectory && origExtension.length == 0 )    // <- origen es directory i no te extensio
        {
            //destFilePath = [destFilePath stringByAppendingPathExtension:SWFileExtensionWrapp];
            destFilePath = [[destFilePath stringByDeletingPathExtension] stringByAppendingPathExtension:SWFileExtensionWrapp];
            destFilePath = _correctedPathForDroppingFullFilePath(destFilePath); // <-- correccio del path del directori hmipad
        }
        
        // En cas contrari si la extensio del destinatari es wrap potser hem de crear un directori i modificar el
        // desti cap a l'interior del directori
        // Copiarem el origen a l'interior del wrap destinatari
        else if ( [destExtension caseInsensitiveCompare:SWFileExtensionWrapp] == NSOrderedSame)
        {
            destFilePath = _correctedPathForDroppingFullFilePath(destFilePath); // <-- correccio del path del directori hmipad
//            if ( ![fileManager fileExistsAtPath:destFilePath] )  // <--crec que no cal
//            {
//                success = [fileManager createDirectoryAtPath:destFilePath withIntermediateDirectories:YES attributes:nil error:outError];
//            }
            binaryFilePath = [destFilePath stringByAppendingPathComponent:SWFileKeyWrappBinary];
            destFilePath = [destFilePath stringByAppendingPathComponent:isEncrypted?SWFileKeyWrappEncryptedSymbolic:SWFileKeyWrappSymbolic];
        }
        
        // En altres casos simplement copiarem el origen cap al desti
        else
        {
        }
        
        if ( success )
        {
            if ( [fileManager fileExistsAtPath:destFilePath] )
            {
                success = [self _dropItemAtPath:originPath toPath:destFilePath addCopy:addCopy error:outError];
                if ( success )
                {
                    if ( [fileManager fileExistsAtPath:originPath] )
                        [fileManager removeItemAtPath:originPath error:outError];
                }
            }
            else
            {
                NSString *parentDir = [destFilePath stringByDeletingLastPathComponent];
                if ( ![fileManager fileExistsAtPath:parentDir] )
                {
                    // creem el directori pare si no hi era
                    success = [fileManager createDirectoryAtPath:parentDir withIntermediateDirectories:YES attributes:nil error:outError];
                }
                success = success && [fileManager moveItemAtPath:originPath toPath:destFilePath error:outError];
            }
        }
        
        // si hem mogut correctament i hi ha un binaryPath el eliminem
        if ( success )
        {
            if ( [fileManager fileExistsAtPath:binaryFilePath] )
            {
                [fileManager removeItemAtPath:binaryFilePath error:outError];
            }
        }
        
        // si no hi ha hagut exit pot ser que volguem igualment eliminar el original (amb exit s'elimina sempre)
        else if ( alwaysDeleteOriginal )
        {
            [fileManager removeItemAtPath:originPath error:nil];
        }
    }
    
    return success;
}



//------------------------------------------------------------------------------------
- (BOOL)_copyFromInternalFileFullPath:(NSString*)originPath toExternalFileFullPath:(NSString*)destFilePath error:(NSError**)outError
{
    BOOL success = NO ;
    if ( originPath && destFilePath )
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
    
        // si la extensio del origen es wrap potser hem modificar el origen desde el interior del directori
        if ( fileFullPathIsWrappedSource(originPath) )
        {
            originPath = [originPath stringByAppendingPathComponent:SWFileKeyWrappSymbolic];
        }
                
        if ( [fileManager fileExistsAtPath:originPath] && [fileManager fileExistsAtPath:destFilePath] )
        {
            // ens carreguem el fitxer de desti si cal
            success = /*success &&*/ [self _removeItemAtFullPath:destFilePath error:outError];
        }

        success = [fileManager copyItemAtPath:originPath toPath:destFilePath error:outError];
    }
    return success;
}


//------------------------------------------------------------------------------------
- (BOOL)_moveInternalFileFullPath:(NSString*)originPath toInternalFileFullPath:(NSString*)destFilePath error:(NSError**)outError
{
    BOOL success = NO ;
    if ( originPath && destFilePath )
    {
        success = YES;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ( [fileManager fileExistsAtPath:destFilePath] )
        {
            success = [self _dropItemAtPath:originPath toPath:destFilePath addCopy:NO error:outError];
            if ( success ) [fileManager removeItemAtPath:originPath error:outError];
        }
        else
        {
            NSString *parentDir = [destFilePath stringByDeletingLastPathComponent];
            if ( ![fileManager fileExistsAtPath:parentDir] )
            {
                // creem el directori pare si no hi era
                success = [fileManager createDirectoryAtPath:parentDir withIntermediateDirectories:YES attributes:nil error:outError];
            }
            success = success && [fileManager moveItemAtPath:originPath toPath:destFilePath error:outError];
        }
    }
    return success;
}


//------------------------------------------------------------------------------------
- (BOOL)_copyInternalFileFullPath:(NSString*)originPath toInternalFileFullPath:(NSString*)destFilePath error:(NSError**)outError
{
    BOOL success = NO ;
    if ( originPath && destFilePath )
    {
        success = YES;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *parentDir = [destFilePath stringByDeletingLastPathComponent];
        if ( ![fileManager fileExistsAtPath:parentDir] )
        {
            // creem el directori pare si no hi era
            success = [fileManager createDirectoryAtPath:parentDir withIntermediateDirectories:YES attributes:nil error:outError];
        }
        
        if ( success && [fileManager fileExistsAtPath:originPath] && [fileManager fileExistsAtPath:destFilePath] )
        {
            // ens carreguem el fitxer de desti si cal
            success = [self _removeItemAtFullPath:destFilePath error:outError];
        }
        
        success = success && [fileManager copyItemAtPath:originPath toPath:destFilePath error:outError];
    }
    return success;
}


//------------------------------------------------------------------------------------
- (BOOL)_removeItemAtFullPath:(NSString*)filePath error:(NSError**)outError
{
    BOOL success = YES ;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ( [fileManager fileExistsAtPath:filePath] )
    {
        success = [fileManager removeItemAtPath:filePath error:outError];
    }
    return success;
}


@end




