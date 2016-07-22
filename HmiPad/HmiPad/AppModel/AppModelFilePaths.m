//
//  AppModelFilePaths.m
//  HmiPad
//
//  Created by Joan Lluch on 13/04/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "AppModelFilePaths.h"
#import "AppModelCommon.h"

#import "DirectoryWatcher.h"


static NSString *SWFileAssetsDir = @"assets";
static NSString *SWFileWrappSymbolic = @"symbolic";
static NSString *SWFileBundledDir = @"";


@interface AppModelFilePaths()<DirectoryWatcherDelegate>
{
    // instance vars dels fitxers
    NSString *_internalFilesDirectory ;
    NSString *_documentsDirectoryPath ;
    NSString *_cacheDirectoryPath;
    DirectoryWatcher *_dirWatcher;
    DirectoryWatcher *_databaseWatcher;
}
@end


@implementation AppModelFilePaths
{
    BOOL _isChangingDir;
}

- (NSString *)documentsDirectoryPath
{
    if ( _documentsDirectoryPath == nil )
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSURL *url = [fm URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        _documentsDirectoryPath = [url path];
        _dirWatcher = [DirectoryWatcher watchFolderWithPath:_documentsDirectoryPath delegate:self];
    }
    return _documentsDirectoryPath ;
}

- (NSString*)originPathForFilename:(NSString*)fileName forCategory:(FileCategory)category
{
    NSString *fullPath = [self fileFullPathForFileName:fileName forCategory:category];
    if ( fileFullPathIsWrappedSource(fullPath))
    {
        fullPath = [fullPath stringByAppendingPathComponent:SWFileWrappSymbolic];
    }
    return fullPath;
}

#pragma mark Directoris (private)


- (NSString *)internalFilesDirectory
{
    if ( _internalFilesDirectory == nil )
    {
        NSFileManager *fm = [[NSFileManager alloc] init];
        NSURL *internalURL = [fm URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        _internalFilesDirectory = [internalURL path] ;
    }
    return _internalFilesDirectory ;
}

- (NSString *)_temporaryFilesDirectory
{
    return NSTemporaryDirectory();
}


static NSString *FilesInRootTmpRelPath = @"/";
static NSString *SourceFilesRelPath = @"/projects/";
static NSString *RecipeFilesRelPath = @"/recipefiles/";
static NSString *AssetFilesRelPath = @"/assets/";      // ATENCIO ha de coincidir amb SWFileAssetsDir
static NSString *BundledFilesRelPath = @"/";           // ATENCIO ha de coincidir amb SWFileBundledDir
static NSString *DatabaseFilesRelPath = @"/databases/";
//QWE static NSString *RedeemedSourceFilesRelPath = @"/redeemed/";
static NSString *ITunesFilesRelPath = @"/";


- (NSString *)_filesRelPathForCategory:(FileCategory)category
{
    NSString *relPath = nil ;
    if ( category == kFileCategorySourceFile /*|| category == kFileCategoryRedeemedSourceFile*/ ) relPath = SourceFilesRelPath ;
    else if ( category == kFileCategoryRecipe ) relPath = RecipeFilesRelPath ;
    else if ( category == kFileCategoryAssetFile ) relPath = AssetFilesRelPath ;
    else if ( category == kFileCategoryDatabase ) relPath = DatabaseFilesRelPath;
    
    else if ( category == kFileCategoryEmbeddedAssetFile ) relPath = AssetFilesRelPath ;
    
    else if ( category == kFileCategoryTemporarySourceFile) relPath = SourceFilesRelPath; //RedeemedSourceFilesRelPath;
    else if ( category == kFileCategoryTemporaryBundledFile) relPath = BundledFilesRelPath;
    else if ( category == kFileCategoryTemporaryEmbedeedAssetFile) relPath = AssetFilesRelPath; //nou;
    
    else if ( category == kFileCategoryRemoteSourceFile ) relPath = FilesInRootTmpRelPath;
    else if ( category == kFileCategoryRemoteAssetFile) relPath = FilesInRootTmpRelPath;
    
    else if ( category == kExtFileCategoryITunes ) relPath = ITunesFilesRelPath ;
    return relPath ;
}




/* 
 ------ ESTRUCTURA FITXERS ------  ( REVISAR !! )
 
 -> ApplicationFolder
        |
        |-> [...] (other folders)
        |-> Documents (user editable folder)
        |       |
        |       |-> Projects (symbolic projects, for importing/exporting)
        |       |-> Pictures (user images, for importing/exporting)
        |               |
        |               |-> Folder1 (user defined folders)
        |               |-> Folder2 
        |               |-> Folder3
        |               |-> ...
        |
        |-> Library
        |       |
        |       |-> Application Support
        |               |
        |               |-> com.sweetwilliamsl.HmiPad
        |                       |
        |                       |-> Projects (binary projects, for execution)
        |                       |-> Assets (project images)
        |                               |
        |                               |-> Wallpapers
        |                               |-> ItemPictures
        |                                       |
        |                                       |-> Folder1
        |                                       |-> Folder2
        |                                       |-> Folder3
        |                                       |-> ...
        |
        |-> Cache
                |
                |-> com.sweetwilliamsl.HmiPad
                        |
                        |
                        |-> DefaultManagedImageContext_cache
                                |
                                |-> ScreenShots
                                |-> Images
 
*/


- (NSString*)filesRootDirectoryForCategory:(FileCategory)category
{
    NSString *rootDir = nil ;
    
    switch ( category )
    {
        case kFileCategorySourceFile:
        //case kFileCategoryRedeemedSourceFile:
        case kFileCategoryRecipe:
        case kFileCategoryAssetFile:
        case kFileCategoryDatabase:
        {
            NSString *basePath = [self internalFilesDirectory];
            NSString *relPath = [self _filesRelPathForCategory:category];
            rootDir = [basePath stringByAppendingString:relPath];
            break;
        }
        
        case kFileCategoryRemoteSourceFile:    // <- en aquest cas interpretem arxius apunt per pujar a cloud kit
        case kFileCategoryRemoteAssetFile:     // <- en aquest cas interpretem arxius apunt per pujar a cloud kit
        case kFileCategoryTemporarySourceFile:
        {
            NSString *basePath = [self _temporaryFilesDirectory];
            NSString *relPath = [self _filesRelPathForCategory:category];
            rootDir = [basePath stringByAppendingString:relPath];
            break;
        }
        
        case kFileCategoryEmbeddedAssetFile:
        case kFileCategoryTemporaryBundledFile:
        case kFileCategoryTemporaryEmbedeedAssetFile:
        {
            // no suportat
            break;
        }
    
        case kExtFileCategoryITunes:
        {
            NSString *basePath = [self documentsDirectoryPath];
            NSString *relPath = [self _filesRelPathForCategory:category];
            rootDir = [basePath stringByAppendingString:relPath];
            break;
        }
        
        case kExtFileCategoryMainBundle:
        {
            rootDir = [[NSBundle mainBundle] resourcePath];
            break;
        }
    
        default:
            break;
    
    
    }
    return rootDir;
}


- (NSString *)fileFullPathForAssetWithFileName:(NSString*)fileName
{
    NSString *fullPath = [self fileFullPathForFileName:fileName forCategory:kFileCategoryAssetFile];
    return fullPath;
}



- (NSString *)fileFullPathForAssetWithFileName:(NSString*)fileName embeddedInProjectName:(NSString*)projectName
{    
    return [self fileFullPathForAssetWithFileName:fileName embeddedInProjectName:projectName temporaryStorage:NO];
}



- (NSString *)fileFullPathForAssetWithFileName:(NSString*)fileName embeddedInProjectName:(NSString*)projectName temporaryStorage:(BOOL)temporary
{
    NSAssert(projectName!=nil, @"Necesito un nom de projecte");
    if ( fileName == nil || [fileName length] == 0 ) return nil ;
    
    FileCategory projectCategory = temporary?kFileCategoryTemporarySourceFile:kFileCategorySourceFile;
    NSString *projectFullPath = [self fileFullPathForFileName:projectName forCategory:projectCategory];
        
    NSString *assetsPath = [projectFullPath stringByAppendingPathComponent:SWFileAssetsDir];
    NSString *fullPath = [assetsPath stringByAppendingPathComponent:fileName];
    return fullPath;
}


- (NSString *)fileFullPathForFileWithFileName:(NSString*)fileName bundledInProjectName:(NSString*)projectName temporaryStorage:(BOOL)temporary
{
    NSAssert(projectName!=nil, @"Necesito un nom de projecte");
    if ( fileName == nil || [fileName length] == 0 ) return nil ;
    
    FileCategory projectCategory = temporary?kFileCategoryTemporarySourceFile:kFileCategorySourceFile;
    NSString *projectFullPath = [self fileFullPathForFileName:projectName forCategory:projectCategory];
    
    NSString *bundledPath = [projectFullPath stringByAppendingPathComponent:SWFileBundledDir];
    NSString *fullPath = [bundledPath stringByAppendingPathComponent:fileName];
    return fullPath;
}


- (NSString *)databasesPath
{
    NSString *path = [self filesRootDirectoryForCategory:kFileCategoryDatabase] ;
    
#define WatchDatabases 0
#if WatchDatabases
    if ( _databaseWatcher == nil )
        _databaseWatcher = [DirectoryWatcher watchFolderWithPath:path delegate:self];
#endif
    return path;
}

- (NSString *)assetsPath
{
    return [self filesRootDirectoryForCategory:kFileCategoryAssetFile] ;
}

- (NSString*)embeddedAssetsPathForProjectName:(NSString*)projectName
{
    FileCategory projectCategory = kFileCategorySourceFile;
    NSString *projectFullPath = [self fileFullPathForFileName:projectName forCategory:projectCategory];
        
    NSString *embeededPath = [projectFullPath stringByAppendingPathComponent:SWFileAssetsDir];
    return embeededPath;
}

- (NSString *)fileFullPathForFileName:(NSString*)fileName forCategory:(FileCategory)category
{
    if ( fileName == nil || [fileName length] == 0 ) return nil ;
    NSString *path = [self filesRootDirectoryForCategory:category] ;
    return [path stringByAppendingPathComponent:fileName] ;
}


- (NSString*)temporaryFilePathForFileName:(NSString*)fileName
{
	NSString *rootPath = [self _temporaryFilesDirectory];
    NSString *filePath = [rootPath stringByAppendingPathComponent:fileName] ;
    return filePath ;
}


- (NSString *)userAccountsFilePath
{
//    NSString *rootPath = [self _userAccountsRootDirectory] ;
    NSString *rootPath = [self internalFilesDirectory];
    NSString *filePath = [rootPath stringByAppendingPathComponent:@"useraccounts.swq"];
    return filePath ;
}

- (NSString *)userAccountsFilePathCrypt
{
//    NSString *rootPath = [self _userAccountsRootDirectory] ;
    NSString *rootPath = [self internalFilesDirectory];
    NSString *filePath = [rootPath stringByAppendingPathComponent:@"useraccountsc.swq"];
    return filePath ;
}

- (NSString *)userAccountsFilePathCryptCK
{
//    NSString *rootPath = [self _userAccountsRootDirectory] ;
    NSString *rootPath = [self internalFilesDirectory];
    NSString *filePath = [rootPath stringByAppendingPathComponent:@"useraccountscck.swq"];
    return filePath ;
}



#pragma mark Company Logo

- (NSString *)companyLogoFilePath
{
	NSString *rootPath = [self internalFilesDirectory] ;
    NSString *filePath = [rootPath stringByAppendingPathComponent:@"CompanyLogo.png"] ;
    return filePath ;
}

// temporary logo, s'utilitza per amagatzemar el logo abans d'escalar a definitiu
// aqui es on el httpserver posa el fitxer
- (NSString*)temporaryLogoFilePath
{
	NSString *rootPath = [self _temporaryFilesDirectory] ;
    NSString *filePath = [rootPath stringByAppendingPathComponent:@"CompanyLogo.png"] ;
    return filePath ;
}

#pragma mark Viewer



- (NSString *)fullAssetPathForName:(NSString*)fileName inDocumentName:(NSString *)documentName
{
    NSString *fullPath = nil;
    if ( documentName )
    {
        fullPath = [self fileFullPathForAssetWithFileName:fileName embeddedInProjectName:documentName];
    }
    else
    {
        fullPath = [self fileFullPathForAssetWithFileName:fileName];
    }
    return fullPath;
}


- (NSString*)fullViewerUrlPathForTextUrl:(NSString*)textUrl inDocumentName:(NSString *)documentName
{
    NSString *fullPath = nil;
    if ( textUrl )
    {
        NSRange range1, range2, range3 ;
        NSStringCompareOptions options = NSCaseInsensitiveSearch | NSAnchoredSearch ;
        range1 = [textUrl rangeOfString:@"http://" options:options];
        range2 = [textUrl rangeOfString:@"https://" options:options];
        range3 = [textUrl rangeOfString:@"system://" options:options];
    
        if ( range1.length || range2.length )
        {
            fullPath = textUrl; // we ignore the category if it is web content
        }
        
        else if ( range3.length )
        {
            NSString *rest = [textUrl stringByReplacingCharactersInRange:range3 withString:@""];
            fullPath = [self fileFullPathForFileName:rest forCategory:kExtFileCategoryMainBundle] ;
        }
        
        else
        {
            fullPath = [self fullAssetPathForName:textUrl inDocumentName:documentName];
//            if ( documentName )
//            {
//                fullPath = [self fileFullPathForAssetWithFileName:textUrl embeddedInProjectName:documentName];
//            }
//            else
//            {
//                //fullPath = [self fileFullPathForFileName:textUrl forCategory:kFileCategoryAssetFile];
//                fullPath = [self fileFullPathForAssetWithFileName:textUrl];
//            }
        }
    }
    return fullPath ;
}

//- (NSString*)fullPlayerUrlPathForTextUrl:(NSString*)textUrl forCategory:(FileCategory)category
//{
//    NSString *fullPath = nil ;
//    if ( textUrl )
//    {
//        NSRange range1 ;
//        NSStringCompareOptions options = NSCaseInsensitiveSearch | NSAnchoredSearch ;
//        range1 = [textUrl rangeOfString:@"ipod-library://" options:options] ;
//    
//        if ( range1.length ) fullPath = textUrl ;
//        else fullPath = [self fullViewerUrlPathForTextUrl:textUrl /*forCategory:category*/] ;
//    }
//    return fullPath ;
//}


- (NSString*)fullPlayerUrlPathForTextUrl:(NSString*)textUrl inDocumentName:(NSString*)documentName
{
    NSString *fullPath = nil ;
    if ( textUrl )
    {
        NSRange range1 ;
        NSStringCompareOptions options = NSCaseInsensitiveSearch | NSAnchoredSearch ;
        range1 = [textUrl rangeOfString:@"ipod-library://" options:options] ;
    
        if ( range1.length )
        {
            fullPath = textUrl ;
        }
        else
        {
            fullPath = [self fullViewerUrlPathForTextUrl:textUrl inDocumentName:documentName] ;
        }
    }
    return fullPath ;
}


- (NSString *)fullRecipeSheetUrlPathForTextUrl:(NSString*)textUrl inDocumentName:(NSString*)documentName
{
    NSString *fullPath = nil ;
    if ( textUrl )
    {
        NSRange range1 ;
        NSStringCompareOptions options = NSCaseInsensitiveSearch | NSAnchoredSearch ;
        range1 = [textUrl rangeOfString:@"databases://" options:options] ;
    
        if ( range1.length )
        {
            NSString *rest = [textUrl stringByReplacingCharactersInRange:range1 withString:@""];
            fullPath = [self fileFullPathForFileName:rest forCategory:kFileCategoryDatabase] ;
        }
        else
        {
            fullPath = [self fullAssetPathForName:textUrl inDocumentName:documentName];
        }
    }
    return fullPath ;
}


//@end


#pragma mark - FilePathsWhatcher

//@interface AppModelFilePaths(FilePathsWatcher)<DirectoryWatcherDelegate>
//@end
//
//
//@implementation AppModelFilePaths(FilePathsWatcher)

- (void)delayedDirectoryDidChange:(DirectoryWatcher*)watcher
{
    if ( watcher == _dirWatcher )
    {
        if ( [_delegate respondsToSelector:@selector(filePathsDidFireITunesFileSharingDirectoryWatcher:)] )
            [_delegate filePathsDidFireITunesFileSharingDirectoryWatcher:self];
    }
    
    if ( watcher == _databaseWatcher )
    {
        if ( [_delegate respondsToSelector:@selector(filePathsDidFireDatabaseDirectoryWatcher:)] )
            [_delegate filePathsDidFireDatabaseDirectoryWatcher:self];
    }
}


- (void)directoryDidChange:(DirectoryWatcher *)folderWatcher
{
    // Hack! se suposa que els fitxers s'hauran carregat despres de 1.2 segons si no el usuari sempre pot refrescar.
    [NSThread cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayedDirectoryDidChange:) object:nil];
    [self performSelector:@selector(delayedDirectoryDidChange:) withObject:folderWatcher afterDelay:1.2];
}

@end