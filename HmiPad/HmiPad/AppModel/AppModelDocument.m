//
//  AppModel+Document.m
//  HmiPad
//
//  Created by Joan Lluch on 31/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//
#import "AppModelDocument.h"

#import "AppModelFilePaths.h"
#import "AppModelFilesEx.h"
#import "AppModelSource.h"

#import "SWDocument.h"
#import "SWDocumentModel.h"


@implementation AppModelDocument
{
    BOOL _currentDocumentFileMDNeedsReload;
    FileMD *_currentDocumentFileMD;
}


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


//- (void)setDispatchQueue:(dispatch_queue_t)dQueue key:(const char *)key
//{
//    _queueKey = key;
//    _queueContext = dispatch_queue_get_specific(dQueue, key);
//    _dQueue = dQueue;
//}

- (void)_notifyDocumentFileMDWillChange
{
    NSArray *observersCopy = [_observers copy];
    for ( id<AppModelDocumentObserver>observer in observersCopy )
    {
        if ( [observer respondsToSelector:@selector(appFilesModelCurrentDocumentFileMDWillChange:)])
        {
            [observer appFilesModelCurrentDocumentFileMDWillChange:self];
        }
    }
}

- (void)_notifyDocumentFileMDDidChange
{
    NSArray *observersCopy = [_observers copy];
    for ( id<AppModelDocumentObserver>observer in observersCopy )
    {
        if ( [observer respondsToSelector:@selector(appFilesModelCurrentDocumentFileMDDidChange:)])
        {
            [observer appFilesModelCurrentDocumentFileMDDidChange:self];
        }
    }
}


- (void)_notifyDocumentChange
{
    NSArray *observersCopy = [_observers copy];
    for ( id<AppModelDocumentObserver>observer in observersCopy )
    {
        if ( [observer respondsToSelector:@selector(appFilesModelCurrentDocumentChange:)])
        {
            [observer appFilesModelCurrentDocumentChange:self];
        }
    }
}


- (void)_notifyDocumentNameChange
{
    NSArray *observersCopy = [_observers copy];
    for ( id<AppModelDocumentObserver>observer in observersCopy )
    {
        if ( [observer respondsToSelector:@selector(appFilesModelCurrentDocumentNameChange:)])
        {
            [observer appFilesModelCurrentDocumentNameChange:self];
        }
    }
}


- (void)_notifyDocumentWillOpenWithName:(NSString*)name
{
    NSArray *observersCopy = [_observers copy];
    for ( id<AppModelDocumentObserver>observer in observersCopy )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:willOpenDocumentName:)])
        {
            [observer appFilesModel:self willOpenDocumentName:name];
        }
    }
}


- (void)_notifyDocument:(SWDocument*)document didOpenWithError:(NSError*)error
{
    NSArray *observersCopy = [_observers copy];
    for ( id<AppModelDocumentObserver>observer in observersCopy )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:document:didOpenWithError:)])
        {
            [observer appFilesModel:self document:document didOpenWithError:error];
        }
    }
}

- (void)_notifyDocument:(SWDocument*)document saveWithSuccess:(BOOL)success
{
    NSArray *observersCopy = [_observers copy];
    for ( id<AppModelDocumentObserver>observer in observersCopy )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:document:didSaveWithSuccess:)])
        {
            [observer appFilesModel:self document:document didSaveWithSuccess:success];
        }
    }
}

- (void)_notifyDocument:(SWDocument*)document closeWithSuccess:(BOOL)success
{
    NSArray *observersCopy = [_observers copy];
    for ( id<AppModelDocumentObserver>observer in observersCopy )
    {
        if ( [observer respondsToSelector:@selector(appFilesModel:document:didCloseWithSuccess:)])
        {
            [observer appFilesModel:self document:document didCloseWithSuccess:success];
        }
    }
}


#pragma mark - File Document observation

- (void)addObserver:(id<AppModelDocumentObserver>)observer
{
    [_observers addObject:observer];
}

- (void)removeObserver:(id<AppModelDocumentObserver>)observer
{
    [_observers removeObjectIdenticalTo:observer];
}


#pragma mark - Methods

//- (SWDocument *)currentDocument
//{
//    return _currentDocument;
//}



- (NSString*)currentDocumentShortName
{
    return [_currentDocument getName];
}

- (BOOL)projectUserEnabled
{
    SWProjectUser *prjUsr = [_currentDocument.docModel selectedProjectUser];
    return prjUsr != nil ;
}


- (NSString*)defaultNameForNewProject
{
    return @"NewProject.hmipad";
}


- (void)addNewEmptyDocument
{
    NSString *fileName = [self defaultNameForNewProject];
    NSString *creationPath = [_filesModel.filePaths fileFullPathForFileName:fileName forCategory:kFileCategoryTemporarySourceFile];
    NSURL *fileUrl = [[NSURL alloc] initFileURLWithPath:creationPath];
    
    SWDocument *document = [[SWDocument alloc] initWithFileURL:fileUrl];
    [document setDispatchQueue:_filesModel.dQueue key:_filesModel.queueKey];
    
    [document saveForCreatingWithSavingType:SWDocumentSavingTypeSymbolic completionHandler:^(BOOL success)
    {
        if ( success )
        {
            [_filesModel.files moveToProjectsForTemporaryProject:fileName error:nil];
        }
    }];
}



//- (void)openDocumentWithCompletionVVVV:(void (^)(BOOL success))completion
//{
//    NSString *fileName = [_filesModel.fileSource exclusiveProjectSource];
//    [_filesModel.fileSource projectSource:fileName setFlag:0];   // << posem 0 per detectar crash al obrir un arxiu, si s'obra correctament tornem a posar 1
//    
//    [self _notifyDocumentWillOpenWithName:fileName];
//    
//    if ( fileName == nil )
//    {
//        [self _notifyDocument:nil didOpenWithError:nil];
//        return;
//    }
//    
//    SWDocument *document = [[SWDocument alloc] initWithFileName:fileName];
//    [document setDispatchQueue:_filesModel.dQueue key:_filesModel.queueKey];
//
//    [document openWithCompletionHandler:^(BOOL success)
//    {
//        NSError *error = nil;
//        if ( success == NO )
//        {
//            error = document.lastError;
//        }
//        
//        [self _setCurrentDocument:success?document:nil];
//        // ^ pot posar _currentDocument a nil 
//        
//        if ( success && _currentDocument==nil )
//        {
//            NSString *message = NSLocalizedString(@"Project file was not found in projects directory", nil);
//            error = _errorWithLocalizedDescription_title(message, nil);
//            success = NO;
//        }
//        
//        [self _notifyDocument:document didOpenWithError:error];
//
//        if ( success == NO )
//            [_filesModel.fileSource setProjectSources:nil];
//        else
//            [_filesModel.fileSource projectSource:fileName setFlag:1];  // ha obert correctament, posem 1
//        
//        if ( completion ) completion( success );
//    }];
//}


- (void)openDocumentWithCompletion:(void (^)(BOOL success))completion
{
    NSString *fileName = [_filesModel.fileSource exclusiveProjectSource];
    
    NSInteger flag = [_filesModel.fileSource projectSourceGetFlag:fileName];
    if ( flag > 0 ) flag = flag-1;
    
    [_filesModel.fileSource projectSource:fileName setFlag:flag];   // << decrementem el flag per detectar crash al obrir un arxiu, si s'obra correctament tornem a posar 3
    
    [self _notifyDocumentWillOpenWithName:fileName];
    
    if ( fileName == nil )
    {
        [self _notifyDocument:nil didOpenWithError:nil];
        return;
    }
    
    SWDocument *document = [[SWDocument alloc] initWithFileName:fileName];
    [document setDispatchQueue:_filesModel.dQueue key:_filesModel.queueKey];

    [document openWithCompletionHandler:^(BOOL success)
    {
        NSError *error = nil;
        if ( success == NO )
        {
            error = document.lastError;
        }
        
        [self _setCurrentDocument:success?document:nil];
        // ^ pot posar _currentDocument a nil 
        
        if ( success && _currentDocument==nil )
        {
            NSString *message = NSLocalizedString(@"Project file was not found in projects directory", nil);
            error = _errorWithLocalizedDescription_title(message, nil);
            success = NO;
        }
        
        [self _notifyDocument:document didOpenWithError:error];

        if ( success == NO )
            [_filesModel.fileSource setProjectSources:nil];
        else
            [_filesModel.fileSource projectSource:fileName setFlag:SWDefaultSourceFlagValue];  // ha obert correctament, posem 1
        
        if ( completion ) completion( success );
    }];
}


- (void)saveDocumentWithCompletion:(void (^)(BOOL success))completion
{
    SWDocument *document = _currentDocument;
    
//    [document saveForSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success)
//    {
//        [self _notifyDocument:document saveWithSuccess:success];
//        [document setHasUnsavedChangesForSavingType:SWDocumentSavingTypeValuesBinary];
//        [document setHasUnsavedChangesForSavingType:SWDocumentSavingTypeValuesSymbolic];
//        if ( completion ) completion( success );
//    }];
    
    [document saveWithCompletion:^(BOOL success)
    {
        [self _notifyDocument:document saveWithSuccess:success];
        if ( completion ) completion( success );
    }];
}




//- (void)setUnsavedChangesForStoredValues
//{
//    SWDocument *document = _currentDocument;
//    
//    [document setHasUnsavedChangesForSavingType:SWDocumentSavingTypeValuesBinary];
//    [document setHasUnsavedChangesForSavingType:SWDocumentSavingTypeValuesSymbolic];
//}


- (void)closeDocumentWithCompletion:(void (^)(BOOL success))completion
{
    SWDocument *document = _currentDocument;
    SWDocumentModel *docModel = document.docModel;
    
#warning // ATENCIO: mogut aqui per tenir actualitzat el model al obrir, no es correcte perque si falla el guardar quedara desconectat, encara que el switch continui on, a més no va perque el delegat de la desconexio es crida igualment despres d'haver guardat
    [docModel clausureSources];
    [docModel dismissProjectUserLogin];
    
    [document closeWithCompletionHandler:^(BOOL success)
    {
        [self _notifyDocument:document closeWithSuccess:success];
        [self _setCurrentDocument:nil];
        if (completion) completion( success );
    }];
}


- (void)duplicateProject
{
    SWDocument *document = _currentDocument;
    SWDocumentModel *docModel = document.docModel;
    
    if ( docModel == nil )
        return;
    
    //NSArray *files = [docModel fileList];
    NSString *tmpUuid = [docModel uuid];
    
    docModel.uuid = nil;
    NSData *symbolicData = [document getSymbolicData];
    docModel.uuid = tmpUuid;


    NSString *fileName = [document getFileName];
    
    NSString *extension = [fileName pathExtension];
    NSString *noExtensionName = [fileName stringByDeletingPathExtension];
    NSString *newFileName = [[noExtensionName stringByAppendingString:@"_copy"] stringByAppendingPathExtension:extension];
    
    NSError *error = nil;
    NSString *tmpFilePath = [_filesModel.filePaths temporaryFilePathForFileName:newFileName];
    BOOL success = [symbolicData writeToFile:tmpFilePath options:NSDataWritingAtomic error:&error];
    (void)success;
    
    [_filesModel.files moveFromTemporaryToCategory:kFileCategoryTemporarySourceFile forFile:newFileName addCopy:NO error:&error];
    [_filesModel.files moveToProjectsForTemporaryProject:newFileName error:&error];
}




- (FileMD*)currentDocumentFileMD
{
    FileCategory category = kFileCategorySourceFile;

    [_filesModel.files filesMDArrayForCategory:category];
    
    if ( _currentDocumentFileMDNeedsReload )
    {
        if ( _currentDocumentFileMD )
        {
            NSURL *url = [NSURL fileURLWithPath:_currentDocumentFileMD.fullPath] ;
//            [self _updateFileMD:_currentDocumentFileMD forFileURL:url forCategory:kFileCategorySourceFile];
            [FileMD updatedFileMD:_currentDocumentFileMD forFileURL:url forCategory:kFileCategorySourceFile];
        }
        _currentDocumentFileMDNeedsReload = NO;
    }
    
    SWDocument *currentDocument = _currentDocument;
    _currentDocumentFileMD.image = currentDocument.docModel.thumbnailImage;
    return _currentDocumentFileMD;
}


- (NSInteger)currentDocumentFileMDIndex
{
    FileMD *current = [self currentDocumentFileMD];
    NSArray *documents = [_filesModel.files filesMDArrayForCategory:kFileCategorySourceFile];
    NSInteger index = [documents indexOfObject:current];
    return index;
}


- (void)resetCurrentDocumentFileMD
{
    _currentDocumentFileMDNeedsReload = YES;
}


- (void)refreshCurrentDocumentFileMD
{
    _currentDocumentFileMDNeedsReload = NO;
    [self _getCurrentDocumentFileMD];
}



- (void)_getCurrentDocumentFileMD
{
    NSArray *filesMDArray = [_filesModel.files filesMDArrayForCategory:kFileCategorySourceFile lazy:NO];
    
    FileMD *currentDocumentFileMD = nil;
    SWDocument *currentDocument = _currentDocument;
    
    _currentDocumentFileMD.isDisabled = NO;
    //_currentDocumentFileMD.image = nil;
    _currentDocumentFileMD.identifier = nil;
    
    if ( currentDocument )
    {
        SWDocumentModel *docModel = currentDocument.docModel;
        NSURL *documentURL = [currentDocument fileURL];
        NSString *documentName = [documentURL lastPathComponent];
        NSString *documentUuid = docModel.uuid;
        
        for ( FileMD *fileMD in filesMDArray )
        {
            NSString *fileName = fileMD.fileName;
            if ( [documentName isEqualToString:fileName] )
            {
                fileMD.isDisabled = YES;
                fileMD.identifier = documentUuid;  // en el cas de sources el fileMD del document actual conte el identificador
                fileMD.image = currentDocument.docModel.thumbnailImage;
                currentDocumentFileMD = fileMD;
                break;
            }
        }
    }
        
    if ( filesMDArray != nil && currentDocumentFileMD == nil )
    {
        // Evitem el estat inconsistent de la aplicacio resetejant el document en cas que no es trobi el seu arxiu
        _currentDocument = nil;
    }
    
    _currentDocumentFileMD = currentDocumentFileMD;
}


//- (void)_setCurrentDocumentV:(SWDocument *)document
//{
//    //FileCategory category = kFileCategorySourceFile; // QWE
//    [_filesModel.files resetMDArrayForCategory:kFileCategorySourceFile];
//    [_filesModel.files resetMDArrayForCategory:kFileCategoryEmbeddedAssetFile];
//    
//    _currentDocument = document;   // el actual
//    [self _notifyDocumentChange];   // <-- primer notifiquem el canvi de document
//    [_filesModel.files refreshMDArrayForCategory:kFileCategorySourceFile];
//}


//- (void)_setCurrentDocumentV:(SWDocument *)document
//{
//    [_filesModel.files resetMDArrayForCategory:kFileCategoryEmbeddedAssetFile];
//    
//    _currentDocument = document;   // el actual
//    
//    [self _notifyDocumentChange];   // <-- primer notifiquem el canvi de document
//    
//    _currentDocumentFileMDNeedsReload = YES;
//    [_filesModel.files updateMDArrayForCategory:kFileCategorySourceFile];
//}


- (void)_setCurrentDocument:(SWDocument *)document
{

    [self _notifyDocumentFileMDWillChange];

    [_filesModel.files resetMDArrayForCategory:kFileCategoryEmbeddedAssetFile];
    
    _currentDocument = document;   // el actual
    [self _notifyDocumentChange];   // <-- primer notifiquem el canvi de document
    
    [self refreshCurrentDocumentFileMD];
    
    [self _notifyDocumentFileMDDidChange];
}



@end
