//
//  SWQuickDocument.m
//  HmiPad
//
//  Created by Lluch Joan on 16/07/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <dispatch/dispatch.h>
#import "SWQuickDocument.h"

#define SAVING_INTERVAL 10.0

@implementation SWQuickDocument
{
    __weak NSTimer *_saveTimer;
	dispatch_queue_t _dQueue;
    const char *_queueKey ; // key for the dispatch queue
    void *_queueContext ; // context for the dispatch queue
    CFMutableDictionaryRef _changeCounters;
    
}

@synthesize fileURL = _fileURL;
@synthesize undoManager = _undoManager;
@synthesize documentState = _documentState;


#pragma mark init/dealloc

- (id)initWithFileURL:(NSURL *)url
{    
    self = [super init];
    if (self) 
    {
        _fileURL = url;
        _undoManager = [[NSUndoManager alloc] init];
        _documentState = UIDocumentStateClosed;
        _changeCounters = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, NULL);

        NSArray *fileTypes = [self savingFileTypes];
        for ( NSString *fileType in fileTypes )
        {
            [self _resetChangeCounterForFileType:fileType];
        }
        
        //NSString *fileType = [self fileTypeForURL:url];
        
        // si l'obrim amb el savingFileType, no quedara res pendent
        // si l'obrim amb un tipus diferent el savingFileType quedara pendent de guardar
        NSString *fileType = [self savingFileType];
        [self _incrementChangeCountForFileType:fileType];  // el document no esta obert pero en aquest moment el podem guardar
    }
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // IOS6 if ( _dQueue ) dispatch_release( _dQueue );
    _dQueue = nil;
    if ( _changeCounters ) CFRelease( _changeCounters );
}

#pragma mark private functions


static NSURL *_fileURLWithURL_forFileType(NSURL* url, NSString* type)
{
    NSArray *components = [type componentsSeparatedByString:@"."];
    if ( [components count] > 1 )
    {
        NSString *extension = [components lastObject];
        NSURL *fileURL = [[url URLByDeletingPathExtension] URLByAppendingPathExtension:extension];
        return fileURL;
    }
    return url;
}

static NSURL *_fileWrapURLWithURL_forKey(NSURL* url, NSString* key)
{
    NSURL *fileURL = [url URLByAppendingPathComponent:key];
    return fileURL;
}



static NSError *_getErrorWithMessage(NSString *message)
{
    NSDictionary *info = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:@"com.SweetWilliam.HmiPad" code:0 userInfo:info];
    return error;
}

#pragma mark autosaving


- (NSArray*)_changeCounterKeys
{
    NSDictionary *dict = (__bridge NSDictionary*)_changeCounters;
    NSArray *keys = [dict allKeys];
    return keys;
}


- (void)_resetChangeCounterForFileType:(NSString*)fileType
{
    CFDictionarySetValue(_changeCounters, (CFTypeRef)fileType, 0);  // si no hi es el crea
}

- (void)_incrementChangeCountForFileType:(NSString*)fileType
{
    const void *changeCount = CFDictionaryGetValue(_changeCounters, (CFTypeRef)fileType);

    // si no hi era tornara null i per tant el creem amb count == 1
    CFDictionarySetValue(_changeCounters, (CFTypeRef)fileType, (void*)((unsigned long)changeCount+1));
}

- (void)_setHasChangedForFileType:(NSString*)fileType
{
    CFDictionarySetValue(_changeCounters, (CFTypeRef)fileType, (void*)(unsigned long)(1<<31));
}

- (BOOL)_hasChangedForFileType:(NSString*)fileType
{
    const void *changeCount = CFDictionaryGetValue(_changeCounters, (CFTypeRef)fileType);
    return (unsigned long)changeCount >= (unsigned long)(1<<31);
}


// to do: millora, es podria separar els contadors dels tipus proporcionats a savingFileTypes dels que s'han afegit
// amb setHasUnsavedChangesForType, per evitar guardar innecesariament aquests ultims un cop ja s'ha fet una vegada.
- (void)_incrementChangeCounters
{
    CFIndex counterCount = CFDictionaryGetCount(_changeCounters);
    CFTypeRef changeKeys[counterCount];
    const void* changeCounts[counterCount];
    CFDictionaryGetKeysAndValues(_changeCounters, changeKeys, changeCounts);
    for ( CFIndex i=0; i<counterCount ; i++ )
    {
        CFDictionarySetValue(_changeCounters, changeKeys[i], (void*)((unsigned long)changeCounts[i]+1));
    }
}


- (unsigned long)_changeCountForFileType:(NSString*)fileType
{
    const void *value = NULL;
 
    // si hi ha el valor el tornem directament
    if ( CFDictionaryGetValueIfPresent(_changeCounters, (CFTypeRef)fileType, &value) )
    {
        return (unsigned long)value;
    }
    
    // en cas contrari busquem si hi ha algun altre tipus amb canvis pendents,
    CFIndex counterCount = CFDictionaryGetCount(_changeCounters);
    const void* changeCounts[counterCount];
    CFDictionaryGetKeysAndValues(_changeCounters, NULL, changeCounts);
    for ( CFIndex i=0; i<counterCount ; i++ )
    {
        if ( (unsigned long)changeCounts[i] != 0 )
        {
            CFDictionarySetValue(_changeCounters, (CFTypeRef)fileType, (void*)1);
            return 1;
        }
    }

    return 0;
}

- (void)undoCheckPointNotification:(NSNotification*)note
{
    if ( [_undoManager canUndo] || [_undoManager canRedo] )
    {
        [self _updateChangeCount];
        [self changeCheckpointNotification];
    }
}





//- (void)saveTimeFiredV:(NSTimer*)timer
//{
//    _saveTimer = nil;
//    
//    NSString *fileType = [self savingFileType];
//    [self _saveToURL:_fileURL withType:fileType forSaveOperation:UIDocumentSaveForOverwriting completionHandler:nil];
//}




- (void)_updateChangeCount
{
    [self _incrementChangeCounters];  // els incrementem tots
    
    NSString *fileType = [self savingFileType];
    if ( [self _changeCountForFileType:fileType] > 5 )   // pero nomes guardem el savingFileType
    {
        [self _performScheduledSaving];
    }
    else
    {
        if ( _saveTimer == nil )
            _saveTimer = [NSTimer scheduledTimerWithTimeInterval:1e100 target:self selector:@selector(_performScheduledSaving) userInfo:nil repeats:YES];
        
        [_saveTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:SAVING_INTERVAL]];
    }
}


- (void)_performScheduledSaving
{
    [_saveTimer invalidate];
    _saveTimer = nil;
    
    NSString *fileType = [self savingFileType];
    [self _saveToURL:_fileURL withType:fileType forSaveOperation:UIDocumentSaveForOverwriting completionHandler:nil];
}



#pragma mark queue


- (void)setDispatchQueue:(dispatch_queue_t)dQueue key:(const char *)key
{
    _queueKey = key;
    _queueContext = dispatch_queue_get_specific(dQueue, key);   // having this will allow queue detection in the future
    _dQueue = dQueue;
}


- (dispatch_queue_t)dQueue
{
    if ( _dQueue == NULL )
    {
        //_dQueue = dispatch_queue_create("SWQuickDocumentQueue", NULL);
        
        _queueKey = "SWQuickDocumentQueue";
        _queueContext = (void*)_queueKey;
        
        _dQueue = dispatch_queue_create( _queueKey, NULL );
        dispatch_queue_set_specific( _dQueue, _queueKey, _queueContext, NULL);
    }
        
    return _dQueue;
}


#pragma mark private methods

//// versio sincrona
//- (void)_openWithCompletionHandler_SYNC:(void (^)(BOOL success))completionHandler
//{
//    BOOL success = NO;
//    __block NSData *docData = nil;
//    
//    NSString *fileType = [self fileTypeForURL:_fileURL];
//    NSURL *actualURL = _fileURL; //fileURLWithURL_forFileType(_fileURL, fileType);
//    
//    dispatch_sync( self.dQueue, ^
//    {
//        docData = [NSData dataWithContentsOfURL:actualURL];
//    });
//    
//    if ( docData )
//    {
//        success = [self loadFromContents:docData ofType:fileType error:nil];
//    }
//    
//    _documentState = (success?UIDocumentStateNormal:UIDocumentStateClosed);
//    
//    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//    [nc removeObserver:self];
//    [nc addObserver:self selector:@selector(undoCheckPointNotification:) name:NSUndoManagerCheckpointNotification object:nil];
//    [self _resetChangeCounterForFileType:fileType];
//    
//    if ( completionHandler ) completionHandler( success );
//}


// versio asincrona
//- (void)_openFromURLV:(NSURL*)url withCompletionHandler:(void (^)(BOOL success))completionHandler
//{
//    //NSURL *actualURL = url; //fileURLWithURL_forFileType(_fileURL, fileType);
//    
//    dispatch_async( self.dQueue, ^
//    {
//        NSURL *actualURL = url;
//        NSData *docData = [NSData dataWithContentsOfURL:actualURL];
//        
//        dispatch_async(dispatch_get_main_queue(), ^
//        {
//            BOOL success = NO;
//            NSString *fileType = nil;
//            NSError *error = nil;
//            if ( docData )
//            {
//                fileType = [self fileTypeForURL:actualURL];
//                success = [self loadFromContents:docData ofType:fileType error:&error];
//            }
//            else
//            {
//                NSString *format = NSLocalizedString(@"Could not open \"%@\"", nil);
//                NSString *msg = [NSString stringWithFormat:format, [actualURL lastPathComponent]];
//                error = _getErrorWithMessage( msg );
//            }
//            _documentState = (success?UIDocumentStateNormal:UIDocumentStateClosed);
//    
//            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//            [nc removeObserver:self];
//            
//            if ( success )
//            {
//                [nc addObserver:self selector:@selector(undoCheckPointNotification:) name:NSUndoManagerCheckpointNotification object:nil];
//                [self _resetChangeCounterForFileType:fileType];
//            }
//            else
//            {
//                [self handleError:error userInteractionPermitted:YES];
//            }
//    
//            if ( completionHandler ) completionHandler( success );
//        });
//    });
//}

- (void)_openFromURL:(NSURL*)url withCompletionHandler:(void (^)(BOOL success))completionHandler
{
    //NSURL *actualURL = url; //fileURLWithURL_forFileType(_fileURL, fileType);
    
    dispatch_async( self.dQueue, ^
    {
        NSURL *actualURL = url;
        NSError *err = nil;
        id docContent = [self _doLoadDocContentFromUrl:actualURL outErr:&err];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            BOOL success = NO;
            NSString *fileType = nil;
            NSError *error = nil;
            if ( docContent )
            {
                fileType = [self fileTypeForURL:actualURL];
                success = [self loadFromContents:docContent ofType:fileType error:&error];
            }
            else
            {
                error = err;
            }
            _documentState = (success?UIDocumentStateNormal:UIDocumentStateClosed);
    
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc removeObserver:self];
            
            if ( success )
            {
                // observem nomes els canvis d'aquest undoManager
                [nc addObserver:self selector:@selector(undoCheckPointNotification:) name:NSUndoManagerCheckpointNotification object:_undoManager];

                // si l'hem obert amb el savingFileType, no quedara res pendent
                // si l'hem obert amb un tipus diferent el savingFileType quedara pendent de guardar
                if ( ![self _hasChangedForFileType:fileType] )
                {
                    [self _resetChangeCounterForFileType:fileType];
                }
            }
            else
            {
                [self handleError:error userInteractionPermitted:YES];
            }
    
            if ( completionHandler ) completionHandler( success );
        });
    });
}



//static NSString *_correctedPathForDroppingFullFilePath(NSString *destFilePath)
//{
//    NSFileManager *fileManager = [NSFileManager defaultManager];
// 
//    NSString *destDir = [destFilePath stringByDeletingLastPathComponent];
//    NSString *destFile = [destFilePath lastPathComponent];
//    NSString *extension = [destFile pathExtension];
//    NSString *noExtension = [destFile stringByDeletingPathExtension];
//    NSString *destFile0 = destFile;
//    NSArray *contents = [fileManager contentsOfDirectoryAtPath:destDir error:nil];
//    for ( int i=1; [contents containsObject:destFile0] ; i++ )
//    {
//        destFile0 = [noExtension stringByAppendingFormat:@"-%d", i ];
//        destFile0 = [destFile0 stringByAppendingPathExtension:extension];
//    }
//    NSString *newFilePath = [destDir stringByAppendingPathComponent:destFile0];
//    return newFilePath;
//}


- (void)_saveToURL:(NSURL *)url withType:(NSString*)fileType forSaveOperation:(UIDocumentSaveOperation)saveOperation completionHandler:(void (^)(BOOL success))completionHandler
{
    //NSData *docContent = nil;
    if ( saveOperation != UIDocumentSaveForCreating && [self _changeCountForFileType:fileType] == 0 )
    {
        if ( completionHandler ) completionHandler(YES);
        return;
    }
    
    NSError *error = nil;
    
    id docContent = [self contentsForType:fileType error:&error];
    
    if ( docContent )
    {
        dispatch_async( self.dQueue, ^
        {
            NSError *error1 = nil;
            NSString *theFileType = fileType;
//            NSURL *correctedUrl = url;
//            
//            if ( saveOperation == UIDocumentSaveForCreating )
//            {
//                NSString *path = url.path;
//                NSString *fullPath = _correctedPathForDroppingFullFilePath(path);
//                if ( ![path isEqualToString:fullPath] )
//                {
//                    correctedUrl = [[NSURL alloc] initFileURLWithPath:fullPath];
//                }
//            }
            
            BOOL success = [self _doSaveDocContent:docContent toUrl:url withType:fileType outErr:&error1];

            dispatch_async( dispatch_get_main_queue(), ^
            {
                if ( success )
                {
                    [self _resetChangeCounterForFileType:theFileType];
                    [self saveCheckPointForType:theFileType];
                }
                else
                {
                    _documentState = UIDocumentStateSavingError;
                    [self handleError:error1 userInteractionPermitted:YES];
                }
                
                if ( completionHandler ) completionHandler(success);
            });
        });
    }
    else
    {
        [self handleError:error userInteractionPermitted:YES];
        if ( completionHandler ) completionHandler(NO);
    }
}




//- (void)_closeWithTypeV:(NSString*)fileType completionHandler:(void (^)(BOOL success))completionHandler
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [_saveTimer invalidate];
//    _saveTimer = nil;
//    
//    if ( [self _changeCountForFileType:fileType] == 0 )
//    {
//        if ( completionHandler ) completionHandler(YES);
//        return;
//    }
//    
//    NSError *error = nil;
//    NSData *docData = [self contentsForType:fileType error:&error];
//    
//    __block BOOL success = NO;
//    if ( docData )
//    {
//        NSURL *actualURL = _fileURLWithURL_forFileType(_fileURL, fileType);
//        dispatch_sync( self.dQueue, ^
//        {
//            success = [docData writeToURL:actualURL atomically:YES];
//        });
//    }
//
//    _documentState = (success?UIDocumentStateClosed:UIDocumentStateSavingError);
//    
//    if ( success )
//    {
//        [self _resetChangeCounterForFileType:fileType];
//    }
//    else
//    {
//        [self handleError:error userInteractionPermitted:YES];
//    }
//    
//    if ( completionHandler ) completionHandler( success );
//}





- (void)_closeWithType:(NSString*)fileType completionHandler:(void (^)(BOOL success))completionHandler
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_saveTimer invalidate];
    _saveTimer = nil;

    if ( [self _changeCountForFileType:fileType] == 0 )
    {
        if ( completionHandler ) completionHandler(YES);
        return;
    }
    
    __block NSError *error = nil;
    id docContent = [self contentsForType:fileType error:&error];
    
    __block BOOL success = NO;
    if ( docContent )
    {
        //NSURL *actualURL = _fileURLWithURL_forFileType(_fileURL, fileType);
        NSURL *theURL = _fileURL;
        dispatch_sync( self.dQueue, ^
        {
            success = [self _doSaveDocContent:docContent toUrl:theURL withType:fileType outErr:&error];
        });
    }

    _documentState = (success?UIDocumentStateClosed:UIDocumentStateSavingError);
    
    if ( success )
    {
        [self _resetChangeCounterForFileType:fileType];
        [self saveCheckPointForType:fileType];
    }
    else
    {
        [self handleError:error userInteractionPermitted:YES];
    }
    
    if ( completionHandler ) completionHandler( success );
}



//- (void)_closeWithFileTypes:(NSArray*)fileTypes nextIndex:(NSInteger)index completionHandler:(void (^)(BOOL success))completionHandler
//{
//    NSInteger count = fileTypes.count;
//    if ( index < count )
//    {
//        NSString *fileType = [fileTypes objectAtIndex:index];
//        [self _closeWithType:fileType completionHandler:^(BOOL success)
//        {
//            NSInteger next = success ? index+1 : NSNotFound;
//            [self _closeWithFileTypes:fileTypes nextIndex:next completionHandler:completionHandler];
//        }];
//    }
//    
//    else
//    {
//        if (completionHandler) completionHandler(index==count);
//    }
//}


//- (void)_saveWithFileTypes:(NSArray*)fileTypes nextIndex:(NSInteger)index completionHandler:(void (^)(BOOL success))completionHandler
//{
//    NSInteger count = fileTypes.count;
//    if ( index < count )
//    {
//        NSString *fileType = [fileTypes objectAtIndex:index];
//        [self _saveToURL:_fileURL withType:fileType forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success)
//        {
//            NSInteger next = success ? index+1 : NSNotFound;
//            [self _saveWithFileTypes:fileTypes nextIndex:next completionHandler:completionHandler];
//        }];
//    }
//    
//    else
//    {
//        if (completionHandler) completionHandler(index==count);
//    }
//}


- (void)_saveWithFileTypes:(NSArray*)fileTypes completionHandler:(void (^)(BOOL success))completionHandler
{
    NSInteger count = fileTypes.count;
    __block BOOL allSuccess = YES;
    __block NSInteger doneCount = 0;
    
    for ( NSInteger index=0; index<count; index++ )
    {
        NSString *fileType = [fileTypes objectAtIndex:index];
        [self _saveToURL:_fileURL withType:fileType forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success)
        {
            allSuccess = allSuccess && success;
            doneCount += 1;
            if ( doneCount == count )
            {
                if ( completionHandler ) completionHandler( allSuccess );
            }
        }];
    }
    
    if ( count == 0 )
    {
        if ( completionHandler ) completionHandler( YES );
    }
}



- (void)_closeWithFileTypes:(NSArray*)fileTypes completionHandler:(void (^)(BOOL success))completionHandler
{
    NSInteger count = fileTypes.count;
    __block BOOL allSuccess = YES;
    __block NSInteger doneCount = 0;
    
    for ( NSInteger index=0; index < count; index++ )
    {
        NSString *fileType = [fileTypes objectAtIndex:index];
        [self _closeWithType:fileType completionHandler:^(BOOL success)
        {
            allSuccess = allSuccess && success;
            doneCount += 1;
            if ( doneCount == count )
            {
                if ( completionHandler ) completionHandler( allSuccess );
            }
        }];
    }
    
    if ( count == 0 )
    {
        if ( completionHandler ) completionHandler( YES );
    }

}



- (BOOL)_doSaveDocContent:(id)docContent toUrl:(NSURL*)theURL withType:(NSString*)fileType outErr:(NSError**)error
{
    __block BOOL success = YES;
    
    NSURL *actualURL = _fileURLWithURL_forFileType(theURL, fileType);
    if ( [docContent isKindOfClass:[NSData class]] )
    {
        NSData *docData = docContent;
        success = [docData writeToURL:actualURL atomically:YES];
        if ( success == NO && error )
        {
            NSString *format = NSLocalizedString(@"Could not save \"%@\"", nil);
            NSString *msg = [NSString stringWithFormat:format, [actualURL lastPathComponent]];
            *error = _getErrorWithMessage( msg );
        }
    }
    else if ( [docContent isKindOfClass:[NSFileWrapper class]] )
    {
        NSFileWrapper *contentWrapp = docContent;
//        [contentWrapp writeToURL:actualURL options:NSFileWrapperWritingAtomic originalContentsURL:nil error:error];

        NSFileManager *fm = [NSFileManager defaultManager];
        if ( ![fm fileExistsAtPath:[actualURL path]] )
        {
            success = [fm createDirectoryAtURL:actualURL withIntermediateDirectories:YES attributes:nil error:error];
        }

        if ( success )
        {
            NSDictionary *wrappers = [contentWrapp fileWrappers];
            [wrappers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
            {
                NSString *wrappKey = key;
                NSFileWrapper *fileWrapp = obj;
                NSURL *fileWrapURL = _fileWrapURLWithURL_forKey(actualURL, wrappKey);
                BOOL done = [fileWrapp writeToURL:fileWrapURL options:NSFileWrapperWritingAtomic originalContentsURL:nil error:error];
                if ( !done ) success = NO;
            }];
        }
    }
    return success;
}


- (id)_doLoadDocContentFromUrl:(NSURL*)actualURL outErr:(NSError**)error
{
    id docContent = nil;

    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    NSString *path = [actualURL path];
    [fm fileExistsAtPath:path isDirectory:&isDirectory];
    
    if ( isDirectory )
    {
        docContent = [[NSFileWrapper alloc] initWithURL:actualURL
            options:NSFileWrapperReadingImmediate|NSFileWrapperReadingWithoutMapping error:error];
    }
    else
    {
        docContent = [NSData dataWithContentsOfURL:actualURL options:NSDataReadingUncached error:error];
    }

    return docContent;
}




#pragma mark public methods

- (void)openWithCompletionHandler:(void (^)(BOOL success))completionHandler
{
    [self _openFromURL:_fileURL withCompletionHandler:completionHandler];
}

- (void)openFromURL:(NSURL*)url withCompletionHandler:(void (^)(BOOL success))completionHandler
{
    [self _openFromURL:url withCompletionHandler:completionHandler];
}


- (void)saveForSaveOperation:(UIDocumentSaveOperation)saveOperation completionHandler:(void (^)(BOOL success))completionHandler
{
    NSArray *savingFileTypes = [self _changeCounterKeys];
    [self _saveWithFileTypes:savingFileTypes completionHandler:completionHandler];
    
}

- (void)closeWithCompletionHandler:(void (^)(BOOL success))completionHandler
{    
    NSArray *savingFileTypes = [self _changeCounterKeys];
    [self _closeWithFileTypes:savingFileTypes completionHandler:completionHandler];
}


- (void)saveToURL:(NSURL *)url withType:(NSString*)fileType forSaveOperation:(UIDocumentSaveOperation)saveOperation completionHandler:(void (^)(BOOL success))completionHandler
{
    [self _saveToURL:url withType:fileType forSaveOperation:saveOperation completionHandler:completionHandler];
}

//- (void)forceSaveToURL:(NSURL *)url withType:(NSString*)fileType forSaveOperation:(UIDocumentSaveOperation)saveOperation
//    completionHandler:(void (^)(BOOL success))completionHandler
//{
//    [self _incrementChangeCountForFileType:fileType];
//    [self _saveToURL:url withType:fileType forSaveOperation:saveOperation completionHandler:completionHandler];
//}

- (void)closeWithType:(NSString*)fileType completionHandler:(void (^)(BOOL success))completionHandler
{
    [self _closeWithType:fileType completionHandler:completionHandler];
}



//- (void)trackChangesForType:(NSString*)fileType
- (void)setHasUnsavedChangesForType:(NSString*)fileType
{
    [self _setHasChangedForFileType:fileType];
}


- (void)updateChangeCount
{
    [self _updateChangeCount];
}


//- (NSURL*)fileURLForSavingFileType
//{
//    NSString *fileType = [self savingFileType];
//    NSURL *url = _fileURLWithURL_forFileType( _fileURL, fileType );
//    return url;
//}

#pragma mark to override




- (NSString*)localizedName
{
    NSString *lastPath = [_fileURL lastPathComponent];
    return [lastPath stringByDeletingPathExtension];
}


- (id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    return nil;
}


- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    return NO;
}

- (NSString*)savingFileType;
{
    return [self fileTypeForURL:_fileURL];
}

- (NSString*)fileTypeForURL:(NSURL*)url;
{
    return nil;
}

- (NSArray*)savingFileTypes
{
    return @[[self savingFileType]];
}

- (void)handleError:(NSError *)error userInteractionPermitted:(BOOL)userInteractionPermitted
{
    return;
}

- (void)changeCheckpointNotification
{
    return;
}

- (void)saveCheckPointForType:(NSString *)fileType
{
    return;
}

@end
