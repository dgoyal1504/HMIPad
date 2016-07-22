//
//  AppFilesModel+DownloadExamples.m
//  HmiPad
//
//  Created by Joan Lluch on 08/11/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "AppModelDownloadExamples.h"

#import "AppModelFilePaths.h"
#import "AppModelFilesEx.h"


#define DownloadServer "http://downloads.sweetwilliamsl.com/examples/"
#define DownloadJsonFile "Examples.txt"
#define DownloadPlistFile "ExamplesMenu.plist"

#define DownloadKeyVersion "version"
#define DownloadKeyProjects "projects"
#define DownloadKeyAssets "assets"


@interface AppModelDownloadExamples()
- (void)_notifyExamplesListingDidChangeWithError:(NSError*)error;
@end


#if !UseCloudKit


@implementation AppModelDownloadExamples(grn)

#pragma mark private

- (void)_getExamplesListing
{
    NSString *fileListName = @ DownloadPlistFile;
    [self _primitiveDownloadExample:fileListName saveToTmp:NO completion:^(BOOL success, NSData *data, NSError *error)
    {
        NSDictionary *plist = nil;
        if ( success )
        {
            plist = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainers format:NULL error:&error];
            success = (plist != nil);
        }
        
        if ( success )
        {
            _examplesListing = plist;
            [self _notifyExamplesListingDidChangeWithError:nil];
        }
        else
        {
            NSString *title = NSLocalizedString(@"Templates Listing", nil);
            error = _completeErrorWithError_title( error, title);
            [self _notifyExamplesListingDidChangeWithError:error];
        }
    }];
}


//- (void)_getExampleFileNamed:(NSString*)exampleFileName
//{
//    [_filesModel.files _notifyBeginGroupDownloadForCategory:kFileCategorySourceFile];
//    [self _download:@[exampleFileName] project:nil category:kFileCategorySourceFile index:0 completion:nil];
//}


- (void)_downloadExampleFileNamedV:(NSString*)projectName bundledNames:(NSArray*)bundled assetNames:(NSArray*)assets
{
    if ( projectName.length == 0 )
        return;

    FileCategory sourceCategory = kFileCategorySourceFile;
    FileCategory assetCategory = kFileCategoryAssetFile;
    
    [_filesModel.files _notifyBeginGroupDownloadForCategory:sourceCategory];
    [self _download:@[projectName] project:nil category:sourceCategory index:0 completion:^(BOOL success)
    {
        if ( success )
        {
            [_filesModel.files _notifyBeginGroupDownloadForCategory:assetCategory];
            [self _download:assets project:nil category:assetCategory index:0 completion:nil];
        }
    }];
}


- (void)_downloadExampleFileNamed:(NSString*)projectName bundledNames:(NSArray*)bundled assetNames:(NSArray*)assets
{
    if ( projectName.length == 0 )
        return;

//    FileCategory sourceCategory = kFileCategorySourceFile;
//    FileCategory assetCategory = kFileCategoryAssetFile;
    
    
    FileCategory sourceCategory = kFileCategoryTemporarySourceFile;
    FileCategory bundledCategory = kFileCategoryTemporaryBundledFile;
    FileCategory assetCategory = kFileCategoryAssetFile;
    
    [_filesModel.files _notifyBeginGroupDownloadForCategory:sourceCategory];
    [self _download:@[projectName] project:nil category:sourceCategory index:0 completion:^(BOOL success0)
    {
        if ( success0 )
        {
            [_filesModel.files _notifyBeginGroupDownloadForCategory:bundledCategory];
            [self _download:bundled project:projectName category:bundledCategory index:0 completion:^(BOOL success1)
            {
                if ( success1 )
                {
                    [_filesModel.files _notifyBeginGroupDownloadForCategory:assetCategory];
                    [self _download:assets project:nil category:assetCategory index:0 completion:^(BOOL success2)
                    {
                        if ( success2)
                        {
                            BOOL success = [_filesModel.files moveToProjectsForTemporaryProject:projectName error:nil];
                            (void)success;
                        }
                    }];
                }
            }];
        }
    }];
}





- (void)_fetchExamples
{
    NSString *fileListName = @ DownloadJsonFile;
    [self _primitiveDownloadExample:fileListName saveToTmp:NO completion:^(BOOL success, NSData *data, NSError *error)
    {
        if ( success )
        {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            success = (error == nil);
            if ( success )
            {
                NSArray *projects = _dict_objectForKey(json, @ DownloadKeyProjects );
                NSLog1( @"Downloading Projects %@", projects );
                
                if ( projects.count )
                {
                    for ( NSArray *projectWrap in projects )
                    {
                        NSString *project = [projectWrap firstObject];
                        if ( project )
                        {
                            [_filesModel.files _notifyBeginGroupDownloadForCategory:kFileCategorySourceFile];
                            [self _download:@[project] project:nil category:kFileCategorySourceFile index:0 completion:nil];
                        
                            NSRange assetsRange =  NSMakeRange(1, projectWrap.count-1);
                            NSArray *assets = [projectWrap objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:assetsRange]];
                            
                            if ( assets.count )
                            {
                                [_filesModel.files _notifyBeginGroupDownloadForCategory:kFileCategoryAssetFile];
                                [self _download:assets project:nil category:kFileCategoryAssetFile index:0 completion:nil];
                            }
                        }
                    }
                }
                
                NSArray *assets = _dict_objectForKey(json, @ DownloadKeyAssets );
                NSLog1( @"Downloading Assets %@", assets );
                
                if ( assets.count )
                {
                    [_filesModel.files _notifyBeginGroupDownloadForCategory:kFileCategoryAssetFile];
                    [self _download:assets project:nil category:kFileCategoryAssetFile index:0 completion:nil];
                }
            }
        }
        
        if ( success == NO )
        {
            _completeErrorWithError_title(error, NSLocalizedString(@"Download Error", nil));
        }
        
    }];
}


- (void)_download:(NSArray*)files project:(NSString*)projectName category:(FileCategory)category index:(NSInteger)index completion:(void(^)(BOOL))block
{
    NSInteger count = files.count;
    
    [_filesModel.files _notifyGroupDownloadProgressStep:index==NSNotFound?0:index stepCount:count category:category];

    if ( index < count )
    {
        NSString *fileName = [files objectAtIndex:index];
        [self _primitiveDownloadExample:fileName saveToTmp:YES completion:^(BOOL success, NSData *data, NSError *error)
        {
            if ( success )
            {
                NSString *lastPathComponent = [fileName lastPathComponent];
                success = [_filesModel.files moveFromTemporaryToCategory:category forFile:lastPathComponent projectName:projectName isEncrypted:NO addCopy:NO error:&error];
            }
            
            _completeErrorWithError_title(error, NSLocalizedString(@"Download Error", nil));
            [self _download:files project:projectName category:category index:(success?index+1:NSNotFound) completion:block];
        }];
    }
    
    else // inclueix NSNotfond
    {
        BOOL success = (index==count);
        
        [_filesModel.files _notifyEndGroupDownload:success userCanceled:NO category:category];
        
        if ( block )
            block( success );
    }
}


- (void)_primitiveDownloadExample:(NSString*)fileName saveToTmp:(BOOL)wantsSave completion:(void(^)(BOOL, NSData*,NSError*))block
{
    dispatch_async( _filesModel.dQueue, ^
    {
        NSString *server = @ DownloadServer;
        NSString *urlString = [server stringByAppendingPathComponent:fileName];
    
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    
        NSError *error = nil;
        NSHTTPURLResponse *response;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
        NSInteger statusCode = response.statusCode;
        //BOOL errorResponse = statusCode > 0 && (statusCode < 200 || statusCode >= 300);
        BOOL errorResponse = (statusCode != 200) ;
        BOOL done = (data != nil && !errorResponse );
        
        if ( !done  )
        {
            NSString *message = nil;
            if ( error == nil )
            {
                NSString *format = NSLocalizedString(@"Unable to download file \"%@\". Server returned status code: %d", nil);
                message = [NSString stringWithFormat:format,fileName,statusCode];
            }
            else
            {
                NSString *format = NSLocalizedString(@"Unable to download file \"%@\". Server returned: \"%@\"", nil);
                message = [NSString stringWithFormat:format,fileName,error.localizedDescription];
            }
            error = _errorWithLocalizedDescription_title(message, nil);
        }
        
        if ( done && wantsSave )
        {
            NSString *lastPathComponent = [fileName lastPathComponent];
            NSString *tmpFullPath = [_filesModel.filePaths temporaryFilePathForFileName:lastPathComponent];
            done = [data writeToFile:tmpFullPath options:NSDataWritingAtomic error:&error];
        }
        
        if ( done ) error = nil;
        if ( !done || wantsSave ) data = nil;
    
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (block)
                block( done, data, error );
        });

    });
}


- (void)_downloadThumbnailImageForExampleNamed:(NSString*)fileName completion:(void (^)(UIImage* image))block
{
    UIImage *image = [UIImage imageNamed:@"181-hammer.png"];
    block( image );
}

@end




#else  // using CloudKit


#pragma mark - With CloudKit

@interface AppModelDownloadExamples()
{
    CKDatabase *_database;
    CKContainer *_container;
}
@end


@implementation AppModelDownloadExamples(CloudKit)

#pragma mark private


- (CKContainer *)ckContainer
{
    if ( _container == nil )
    {
        //_container = [CKContainer defaultContainer]
        _container = [CKContainer containerWithIdentifier:@"iCloud.com.sweetwilliam.HMIPadExamplesCloudContainer"];
    }
    return _container;
}


- (CKDatabase *)ckDatabase
{
    if ( _database == nil )
        _database = [[self ckContainer] publicCloudDatabase];
    
    return _database;
}


- (void)_getExamplesListing
{
    NSString *fileListName = @ DownloadPlistFile;
    [self _primitiveDownloadMetaData:fileListName completion:^(BOOL success, NSData *data, NSError *error)
    {
        NSDictionary *plist = nil;
        if ( success )
        {
            plist = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainers format:NULL error:&error];
            success = (plist != nil);
        }
    
        if ( success )
        {
            _examplesListing = plist;
            [self _notifyExamplesListingDidChangeWithError:nil];
        }
        else
        {
            NSString *title = NSLocalizedString(@"Templates Listing", nil);
            error = _completeErrorWithError_title( error, title);
            [self _notifyExamplesListingDidChangeWithError:error];
        }
    }];
}



- (void)_downloadExampleFileNamed:(NSString*)projectName bundledNames:(NSArray*)bundled assetNames:(NSArray*)assets
{
    if ( projectName.length == 0 )
        return;

    FileCategory sourceCategory = kFileCategoryTemporarySourceFile;
    FileCategory assetCategory = kFileCategoryAssetFile;
    
    [_filesModel.files _notifyBeginGroupDownloadForCategory:sourceCategory];
    [self _download:@[projectName] project:nil category:sourceCategory index:0 completion:^(BOOL success0)
    {
        [_filesModel.files _notifyEndGroupDownload:success0 userCanceled:NO category:sourceCategory];
        if ( success0 )
        {
            [_filesModel.files _notifyBeginGroupDownloadForCategory:assetCategory];
            [self _download:assets project:nil category:assetCategory index:0 completion:^(BOOL success2)
            {
                [_filesModel.files _notifyEndGroupDownload:success2 userCanceled:NO category:assetCategory];
                if ( success2)
                {
                    BOOL success = [_filesModel.files moveToProjectsForTemporaryProject:projectName error:nil];
                    (void)success;
                }
            }];
        }
    }];
}



- (void)_download:(NSArray*)files project:(NSString*)projectName category:(FileCategory)category index:(NSInteger)index completion:(void(^)(BOOL))block
{
    NSInteger count = files.count;
    
    if ( count > 0 )
        [_filesModel.files _notifyGroupDownloadProgressStep:index==NSNotFound?0:index stepCount:count category:category];

    if ( index < count )
    {
        NSString *fileName = [files objectAtIndex:index];
        [_filesModel.files _notifyWillDownloadFile:fileName category:category];
        [self _downloadPrimitive:fileName category:category completion:^(BOOL success, NSError *error)
        {
            _completeErrorWithError_title(error, NSLocalizedString(@"Download Error", nil));
            [_filesModel.files _notifyDidDownloadFile:fileName category:category withError:error];
            [self _download:files project:projectName category:category index:(success?index+1:NSNotFound) completion:block];
        }];
    }
    
    else // inclueix NSNotfond
    {
        BOOL success = (index==count);
        if ( block )
            block( success );
    }
}



- (void)_downloadPrimitive:(NSString*)fileName category:(FileCategory)category completion:(void(^)(BOOL,NSError*))block
{
    if ( category == kFileCategoryTemporarySourceFile )
    {
        [self _primitiveDownloadProject:fileName completion:block];
    }
    else if ( category == kFileCategoryAssetFile )
    {
        [self _primitiveDownloadAsset:fileName completion:block];
    }
}



- (void)_primitiveDownloadProject:(NSString*)project completion:(void(^)(BOOL,NSError*))block
{
    NSString *recordType = @"HmipadExamples";
    NSString *attribute = @"projectName";
 
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", attribute, project];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:recordType predicate:predicate];
    CKQueryOperation *queryOperation = [[CKQueryOperation alloc] initWithQuery:query];
 
    NSMutableArray *results = [NSMutableArray array];
 
    [queryOperation setRecordFetchedBlock:^(CKRecord *ckRecord)
    {
        [results addObject:ckRecord];
    }];
    
    [queryOperation setQueryCompletionBlock:^(CKQueryCursor *quetyCursor, NSError *error)
    {
        NSError *theError = error;
        NSLog( @"QueryOperationError: %@", theError );
        BOOL success = theError == nil;
        
        if ( success )
        {
            AppModelFiles *modelFiles = _filesModel.files;
            CKRecord *record = results.firstObject;
            
            NSString *projectName = record[attribute];  // hauria de ser el mateix que project
            CKAsset *projectFile = record[@"projectFile"];
            NSString *projectFilePath = projectFile.fileURL.path;
            
            success = [modelFiles copyToTemporaryForFileFullPath:projectFilePath destinationFile:projectName error:&theError];
            success = success && [modelFiles moveFromTemporaryToCategory:kFileCategoryTemporarySourceFile forFile:projectName projectName:nil
                isEncrypted:NO addCopy:NO error:&theError];
            
            if ( success )
            {
//                NSData *thumbData = record[@"thumbnail"];
//                
//                NSString *tmpFullPath = [_filesModel.filePaths temporaryFilePathForFileName:SWFileKeyWrappThumbnail];
//                success = [thumbData writeToFile:tmpFullPath options:NSDataWritingAtomic error:&theError];
                
                
                CKAsset *thumbnailFile = record[@"thumbnail"];
                NSString *thumbnailFilePath = thumbnailFile.fileURL.path;
                success = [modelFiles copyToTemporaryForFileFullPath:thumbnailFilePath destinationFile:SWFileKeyWrappThumbnail error:&theError];
                
                success = success && [modelFiles moveFromTemporaryToCategory:kFileCategoryTemporaryBundledFile forFile:SWFileKeyWrappThumbnail projectName:projectName
                        isEncrypted:NO addCopy:NO error:&theError];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (block)
                block( success, theError );
        });
    }];
 
    [[self ckDatabase] addOperation:queryOperation];
}



//- (void)_primitiveDownloadMetaDataV:(NSString*)identifier completion:(void(^)(BOOL, NSData*, NSError*))block
//{
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"atr01_identifier", identifier];
//    [self _primitiveDownloadDataAttributeWithRecordType:@"HmipadExamplesMetadata" predicate:predicate attributeName:@"atr02_propertyList"
//    completion:^(BOOL success, NSData *data, NSError *theError)
//    {
//        dispatch_async(dispatch_get_main_queue(), ^
//        {
//            if (block)
//                block( success, data, theError );
//        });
//    }];
//}


- (void)_primitiveDownloadMetaData:(NSString*)identifier completion:(void(^)(BOOL, NSData*, NSError*))block
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"identifier", identifier];
    [self _primitiveDownloadAssetAttributeWithRecordType:@"HmipadExamplesMetadata" predicate:predicate attributeName:@"propertyListFile"
    completion:^(BOOL success, NSURL *url, NSError *theError)
    {
        NSData *data = nil;
        if ( success )
        {
            data = [NSData dataWithContentsOfURL:url options:0 error:&theError];
            success = (data != nil);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (block)
                block( success, data, theError );
        });
    }];
}


- (void)_primitiveDownloadAsset:(NSString*)fileName completion:(void(^)(BOOL, NSError*))block
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"assetName", fileName];
    [self _primitiveDownloadAssetAttributeWithRecordType:@"HmipadExampleAssets" predicate:predicate attributeName:@"assetFile"
    completion:^(BOOL success, NSURL *url, NSError *error)
    {
        NSError *theError = error;
        if ( success )
        {
            AppModelFiles *modelFiles = _filesModel.files;
            NSString *assetFilePath = url.path;
            success = [modelFiles copyToTemporaryForFileFullPath:assetFilePath destinationFile:fileName error:&theError];
            success = success && [modelFiles moveFromTemporaryToCategory:kFileCategoryAssetFile forFile:fileName projectName:nil
                isEncrypted:NO addCopy:NO error:&theError];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (block)
                block( success, theError );
        });
    }];
}


- (void)_downloadThumbnailImageForExampleNamedV:(NSString*)fileName completion:(void (^)(UIImage* image))block
{
    UIImage *image = [UIImage imageNamed:@"181-hammer.png"];
    block( image );
}


//- (void)_downloadThumbnailImageForExampleNamed:(NSString*)fileName completion:(void (^)(UIImage* image))block
//{
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"projectName", fileName];
//    [self _primitiveDownloadDataAttributeWithRecordType:@"HmipadExamples" predicate:predicate attributeName:@"atr05_thumbnail"
//    completion:^(BOOL success, NSData *data, NSError *error)
//    {
//        UIImage *image = nil;
//        if ( success )
//        {
//            CGFloat scale = [[UIScreen mainScreen] scale];
//            image = [UIImage imageWithData:data scale:scale];
//        }
//    
//        dispatch_async(dispatch_get_main_queue(), ^
//        {
//            if (block)
//                block( image );
//        });
//    }];
//}


- (void)_downloadThumbnailImageForExampleNamed:(NSString*)fileName completion:(void (^)(UIImage* image))block
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"projectName", fileName];
    
    [self _primitiveDownloadAssetAttributeWithRecordType:@"HmipadExamples" predicate:predicate attributeName:@"thumbnail"
    completion:^(BOOL success, NSURL *url, NSError *theError)
    {
        UIImage *image = nil;
        if ( success )
        {
            NSData *data = [NSData dataWithContentsOfURL:url];
            if ( data )
            {
                CGFloat scale = [[UIScreen mainScreen] scale];
                image = [UIImage imageWithData:data scale:scale];
            }
        }
        
        // si hi havia error la imatge sera nil
    
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (block)
                block( image );
        });
    }];
}


#pragma mark - primitives returning on background thread

- (void)_primitiveDownloadAssetAttributeWithRecordType:(NSString*)recordType predicate:(NSPredicate*)predicate
    attributeName:(NSString*)attributeName completion:(void(^)(BOOL success, NSURL *url, NSError *theError))block
{
    CKQuery *query = [[CKQuery alloc] initWithRecordType:recordType predicate:predicate];
    CKQueryOperation *queryOperation = [[CKQueryOperation alloc] initWithQuery:query];
    queryOperation.desiredKeys = @[attributeName];
 
    NSMutableArray *results = [NSMutableArray array];
 
    [queryOperation setRecordFetchedBlock:^(CKRecord *ckRecord)
    {
        [results addObject:ckRecord];
    }];
    
    [queryOperation setQueryCompletionBlock:^(CKQueryCursor *quetyCursor, NSError *error)
    {
        NSError *theError = error;
        NSURL *fileUrl = nil;
        NSLog( @"QueryOperationError: %@", theError );
        BOOL success = theError == nil;
        
        if ( success )
        {
            CKRecord *record = results.firstObject;
            CKAsset *assetFile = record[attributeName];
            fileUrl = assetFile.fileURL;
            success = (fileUrl != nil);
            if ( success == NO )
            {
                //NSString *title = NSLocalizedString(@"File not found", nil);
                NSString *message = NSLocalizedString(@"Could not retrieve file from iCloud", nil);
                theError = _errorWithLocalizedDescription_title(message, nil);
            }
        }
        
        block( success, fileUrl, theError );
    }];
 
    [[self ckDatabase] addOperation:queryOperation];
}



- (void)_primitiveDownloadDataAttributeWithRecordType:(NSString*)recordType predicate:(NSPredicate*)predicate
    attributeName:(NSString*)attributeName completion:(void(^)(BOOL, NSData*, NSError*))block
{
    CKQuery *query = [[CKQuery alloc] initWithRecordType:recordType predicate:predicate];
    CKQueryOperation *queryOperation = [[CKQueryOperation alloc] initWithQuery:query];
    queryOperation.desiredKeys = @[attributeName];
 
    NSMutableArray *results = [NSMutableArray array];
 
    [queryOperation setRecordFetchedBlock:^(CKRecord *ckRecord)
    {
        [results addObject:ckRecord];
    }];
    
    [queryOperation setQueryCompletionBlock:^(CKQueryCursor *quetyCursor, NSError *error)
    {
        NSError *theError = error;
        NSLog( @"QueryOperationError: %@", theError );
        
        BOOL success = theError == nil;
        NSData *data = nil;
        if ( success )
        {
            CKRecord *record = results.firstObject;
            data = record[attributeName];
            success = data != nil;
            if ( success == NO )
            {
                //NSString *title = NSLocalizedString(@"Data not found", nil);
                NSString *message = NSLocalizedString(@"Could not retrieve record data from iCloud", nil);
                theError = _errorWithLocalizedDescription_title(message, nil);
            }
        }
        
        block( success, data, theError );
    }];
 
    [[self ckDatabase] addOperation:queryOperation];
}






@end

#endif



@implementation AppModelDownloadExamples

- (id)initWithLocalFilesModel:(AppModel*)filesModel
{
    self = [super init];
    if ( self )
    {
        _filesModel = filesModel;
        _observers = CFBridgingRelease(CFArrayCreateMutable(NULL, 0, NULL));
    }
    return self;
}


#pragma mark - observer notifications

- (void)_notifyExamplesListingWillChange
{
    for ( id<AppModelDownloadExamplesObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModelWillReceiveExamplesListing:)])
        {
            [observer appFilesModelWillReceiveExamplesListing:self];
        }
    }
}


- (void)_notifyExamplesListingDidChangeWithError:(NSError*)error
{
    for ( id<AppModelDownloadExamplesObserver>observer in _observers )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:didReceiveExamplesListingWithError:)])
        {
            [observer appFilesModel:self didReceiveExamplesListingWithError:error];
        }
    }
}

#pragma mark - File Document observation

- (void)addObserver:(id<AppModelDownloadExamplesObserver>)observer
{
    [_observers addObject:observer];
}

- (void)removeObserver:(id<AppModelDownloadExamplesObserver>)observer
{
    [_observers removeObjectIdenticalTo:observer];
}


#pragma mark - public methods

- (void)downloadRemoteExamples
{
   // [self _fetchExamples];
}


- (NSDictionary*)getExamplesListing
{
    if ( _examplesListing == nil)
    {
        [self _getExamplesListing];
    }
    
    NSDictionary *result = _examplesListing;
    if ( result == nil )
    {
        result = [NSDictionary dictionary];
    }
    
    return result;
}


- (void)resetExamplesListing
{
    _examplesListing = nil;
}


//- (void)downloadExampleNamed:(NSString*)fileName
//{
//    [self _getExampleFileNamed:fileName];
//}


- (void)downloadExampleNamed:(NSString*)fileName withBundled:(NSArray*)bundled assets:(NSArray*)assets
{
    [self _downloadExampleFileNamed:fileName bundledNames:bundled assetNames:assets];
}




- (void)downloadThumbnailImageForExampleNamed:(NSString*)fileName completion:(void (^)(UIImage* image))block
{
    [self _downloadThumbnailImageForExampleNamed:fileName completion:block];
}

@end



