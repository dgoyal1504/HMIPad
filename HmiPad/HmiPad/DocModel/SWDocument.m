//
//  SWDocument.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/6/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import "SWDocument.h"
#import "SWDocumentModel.h"
#import "SWModelTypes.h"

#import "AppModelFilePaths.h"
#import "AppModelDocument.h"

#import "NSData+SWCrypto.h"

#pragma mark - SWDocument Class


@interface SWDocument()
{
   // QWE BOOL _isRedeemedType;
}
@end


@implementation SWDocument

@synthesize docModel = _docModel;
//@synthesize savingType = _savingType;
@synthesize lastError = _lastError;

- (id)initWithFileURL:(NSURL *)url
{    
    self = [super initWithFileURL:url];
    if (self) 
    {
//        _savingType = SWDocumentSavingTypeBinary;
    }
    return self;
}

-(void)dealloc
{
    NSLog( @"SWDocument dealloc" );
}


#pragma mark - Overriden SWDocument Methods


// obrir
- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    NSError *lastError = nil;
    
    SWDocumentModel *docModel = nil;
    
    if ( [contents isKindOfClass:[NSFileWrapper class]] )
    {
        //if ([typeName isEqualToString:SWFileTypeWrapp] )
        if ([typeName isEqualToString:SWFileTypeWrappBinary] )
        {
            NSFileWrapper *fileWrapp = contents;
            NSDictionary *wrappers = fileWrapp.fileWrappers;
            NSFileWrapper *binaryWrapp = [wrappers objectForKey:SWFileKeyWrappBinary];
            NSData *binaryData = [binaryWrapp regularFileContents];
            BOOL versionConflict = NO;
            if ( binaryData )
            {
                // obra binari si pot
                docModel = [self _decodeDocumentModelFromBinaryData:binaryData error:&lastError versionConflict:&versionConflict];
                if ( versionConflict )
                {
                    [self setHasUnsavedChangesForType:SWFileTypeWrappBinary];
                }
                else
                {
                    // obra valuesBinari si pot
                    if ( docModel )
                    {
                        NSFileWrapper *valuesBinaryWrapp = [wrappers objectForKey:SWFileKeyWrappValuesBinary];
                        NSData *valuesBinaryData = [valuesBinaryWrapp regularFileContents];
                    
                        if ( valuesBinaryData )
                        {
                            [self _retrieveDocumentModel:docModel fromBinaryData:valuesBinaryData error:&lastError versionConflict:&versionConflict];
                        }
                    }
                }
            }
            
            if ( !binaryData || versionConflict )
            {
                // obra simbolic
                
                NSString *fileWrapSymbolic = HMiPadDev?SWFileKeyWrappSymbolic:SWFileKeyWrappEncryptedSymbolic;
                NSFileWrapper *symbolicWrapp = [wrappers objectForKey:fileWrapSymbolic];
                NSData *symbolicData = [symbolicWrapp regularFileContents];
                
//                if ( fileWrapSymbolic == SWFileKeyWrappEncryptedSymbolic )
//                {
//                    symbolicData = [symbolicData decrypt];
//                }
                
                if ( symbolicData )
                {
                    docModel = [self _decodeDocumentModelFromSymbolicData:symbolicData error:&lastError];
                    if ( docModel )
                    {
                        [self setHasUnsavedChangesForType:SWFileTypeWrappBinary];
                    
                        // obra valuesSymbolic si pot
                        NSString *valuesWrapSymbolic = HMiPadDev?SWFileKeyWrappValuesSymbolic:SWFileKeyWrappValuesEncryptedSymbolic;
                        
                        NSFileWrapper *valuesSymbolicWrapp = [wrappers objectForKey:/*SWFileKeyWrappValuesSymbolic*/valuesWrapSymbolic];
                        NSData *valuesSymbolicData = [valuesSymbolicWrapp regularFileContents];
                    
                        if ( valuesSymbolicData )
                        {
                            [self _retrieveDocumentModel:docModel fromSymbolicData:valuesSymbolicData error:&lastError];
                        }
                    }
                }
            }
            
            if ( docModel )
            {
                // obra thumbnail si pot
                NSFileWrapper *thumbnailWrapp = [wrappers objectForKey:SWFileKeyWrappThumbnail];
                NSData *thumbnailData = [thumbnailWrapp regularFileContents];
                if ( thumbnailData )
                {
                    CGFloat scale = [[UIScreen mainScreen] scale];
                    UIImage *image = [UIImage imageWithData:thumbnailData scale:scale];
                    
                    //[docModel setThumbnailImage:image];
                    [docModel primitiveSetThumbnail:image];
                }
            }
            
//            if ( docModel )
//            {
//                // Aquests tipus els guardem sempre
//                [self setHasUnsavedChangesForType:SWFileTypeWrappValuesBinary];
//                [self setHasUnsavedChangesForType:SWFileTypeWrappValuesSymbolic];
//            }
        }
        else
        {
            NSString *message = NSLocalizedString( @"Unknown File Format", nil );
            NSDictionary *info = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
            lastError = [NSError errorWithDomain:@"com.SweetWilliam.HmiPad" code:0 userInfo:info];
        }
    }
    
    else if ( [contents isKindOfClass:[NSData class]] )
    {
        if ( HMiPadDev && [typeName isEqualToString:SWFileTypeBinary])
        {
            docModel = [self _decodeDocumentModelFromBinaryData:contents error:&lastError versionConflict:nil];
        }

        else if ( HMiPadDev && [typeName isEqualToString:SWFileTypeSymbolic] )
        {
            docModel = [self _decodeDocumentModelFromSymbolicData:contents error:&lastError];
        }
        
        else
        {
            NSString *message = NSLocalizedString( @"Unknown File Format", nil );
            NSDictionary *info = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
            lastError = [NSError errorWithDomain:@"com.SweetWilliam.HmiPad" code:0 userInfo:info];
        }
    }
    
    else
    {
        NSLog(@"[uj7211] WARNING: Unknown content class for type: %@", typeName);
        NSAssert( false, nil );
    }
    
    _docModel = docModel;
    _docModel.document = self;
    if ( outError ) *outError = lastError;
    
    return _docModel != nil;
}


// guardar, tancar
- (id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    NSLog(@"[SWDocument] Saving Document: %@ ofType: %@",self.localizedName, typeName);
    
    NSMutableDictionary *wrappers = [NSMutableDictionary dictionary];
    NSData *data = nil;
    
    if ( [typeName isEqualToString:SWFileTypeWrappBinary] )
    {
        NSData *binaryData = [self _binaryDataForDocumentModel:_docModel];
        NSFileWrapper *binaryWrapp = [[NSFileWrapper alloc] initRegularFileWithContents:binaryData];
        [wrappers setObject:binaryWrapp forKey:SWFileKeyWrappBinary];
        
        NSData *valuesBinaryData = [self _valuesBinaryDataForDocumentModel:_docModel];
        NSFileWrapper *valuesBinaryWrapp = [[NSFileWrapper alloc] initRegularFileWithContents:valuesBinaryData];
        [wrappers setObject:valuesBinaryWrapp forKey:SWFileKeyWrappValuesBinary];
    }
    
    else if ( [typeName isEqualToString:SWFileTypeWrappValuesBinary] )
    {
        NSData *valuesBinaryData = [self _valuesBinaryDataForDocumentModel:_docModel];
        NSFileWrapper *valuesBinaryWrapp = [[NSFileWrapper alloc] initRegularFileWithContents:valuesBinaryData];
        [wrappers setObject:valuesBinaryWrapp forKey:SWFileKeyWrappValuesBinary];
    }
    
    else if ( [typeName isEqualToString:SWFileTypeWrappSaveSymbolic] )
    {
        NSData *symbolicData = [self _symbolicDataForDocumentModel:_docModel];
        NSFileWrapper *symbolicWrapp = [[NSFileWrapper alloc] initRegularFileWithContents:symbolicData];
        NSString *fileWrapSymbolic = HMiPadDev?SWFileKeyWrappSymbolic:SWFileKeyWrappEncryptedSymbolic;
        [wrappers setObject:symbolicWrapp forKey:/*SWFileKeyWrappSymbolic*/fileWrapSymbolic];
        
        NSData *valuesSymbolicData = [self _valuesSymbolicDataForDocumentModel:_docModel];
        NSFileWrapper *valuesSymbolicWrapp = [[NSFileWrapper alloc] initRegularFileWithContents:valuesSymbolicData];
        NSString *valuesWrapSymbolic = HMiPadDev?SWFileKeyWrappValuesSymbolic:SWFileKeyWrappValuesEncryptedSymbolic;
        [wrappers setObject:valuesSymbolicWrapp forKey:/*SWFileKeyWrappValuesSymbolic*/valuesWrapSymbolic];
    }
    
    else if ( [typeName isEqualToString:SWFileTypeWrappValuesSymbolic] )
    {
        NSData *valuesSymbolicData = [self _valuesSymbolicDataForDocumentModel:_docModel];
        NSFileWrapper *valuesSymbolicWrapp = [[NSFileWrapper alloc] initRegularFileWithContents:valuesSymbolicData];
        NSString *valuesWrapSymbolic = HMiPadDev?SWFileKeyWrappValuesSymbolic:SWFileKeyWrappValuesEncryptedSymbolic;
        [wrappers setObject:valuesSymbolicWrapp forKey:/*SWFileKeyWrappValuesSymbolic*/valuesWrapSymbolic];
    }
    
    else if ( [typeName isEqualToString:SWFileTypeWrappSaveThumbnail] )
    {
        UIImage *image = _docModel.thumbnailImage;
        NSData *thumbnailData = UIImagePNGRepresentation(image);
        NSFileWrapper *thumbnailWrapp = [[NSFileWrapper alloc] initRegularFileWithContents:thumbnailData];
        [wrappers setObject:thumbnailWrapp forKey:SWFileKeyWrappThumbnail];
    }
    
    else if ([typeName isEqualToString:SWFileTypeBinary])
    {
        data = [self _binaryDataForDocumentModel:_docModel];
    } 
    
    else if ([typeName isEqualToString:SWFileTypeSymbolic])
    {
        data = [self _symbolicDataForDocumentModel:_docModel];
    }
    
    else
    {
        NSLog( @"[ldo294] WARNING: Unknown file type: %@",typeName );
        NSAssert( false, nil ); // mes val que peti i deixi tranquil el ultim guardat
    }
    
    if ( wrappers.count > 0 )
    {
        NSFileWrapper * fileWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:wrappers];
        return fileWrapper;
    }
    else
    {
        return data;
    }
}


- (void)handleError:(NSError *)error userInteractionPermitted:(BOOL)userInteractionPermitted
{
    _lastError = error;
    //NSLog( @"Document Handle Error:\n%@", error );
}


- (NSString*)savingFileType
{    
    return SWFileTypeWrappBinary;
}

#if HMiPadDev
- (NSArray*)savingFileTypes
{
    return @[
        SWFileTypeWrappBinary, SWFileTypeWrappValuesBinary,
        SWFileTypeWrappSaveSymbolic, SWFileTypeWrappValuesSymbolic,
        /*SWFileTypeWrappSaveThumbnail*/];
}

#elif HMiPadRun
- (NSArray*)savingFileTypes
{
    return @[
        SWFileTypeWrappBinary, SWFileTypeWrappValuesBinary,
        SWFileTypeWrappValuesSymbolic,
        /*SWFileTypeWrappSaveThumbnail*/];
}

#endif


- (NSString*)fileTypeForURL:(NSURL*)url
{
    NSString *extension = [[url pathExtension] lowercaseString];
    
    if ( [extension caseInsensitiveCompare:SWFileExtensionWrapp] == NSOrderedSame)
        //return SWFileTypeWrapp;
        return SWFileTypeWrappBinary;
    
    else if ( [extension caseInsensitiveCompare:SWFileExtensionBinary] == NSOrderedSame)
        return SWFileTypeBinary;
    
    else if ( [extension caseInsensitiveCompare:SWFileExtensionSymbolic] == NSOrderedSame)
        return SWFileTypeSymbolic;
    
    return [super fileTypeForURL:url];
}


// override per UIDocument
- (NSString*)fileType
{
    return [self fileTypeForURL:self.fileURL];
    
}


- (void)changeCheckpointNotification
{
    [_docModel changeCheckpointNotification];
}


- (void)saveCheckPointForType:(NSString *)fileType
{
    if ( [fileType isEqualToString:SWFileTypeWrappBinary] ||
        [fileType isEqualToString:SWFileTypeWrappSaveSymbolic] ||
        [fileType isEqualToString:SWFileTypeWrappSaveThumbnail] )
    {
    
        AppModelDocument *fileDocument = filesModel().fileDocument;
        if ( fileDocument.currentDocument == self )
            [fileDocument resetCurrentDocumentFileMD];
        
        [_docModel saveCheckpointNotification];
    }
}


#pragma mark - Public Methods

- (id)initWithFileName:(NSString*)fileName
{
    FileCategory category = kFileCategorySourceFile;
    NSString *fullPath = [filesModel().filePaths fileFullPathForFileName:fileName forCategory:category];
    NSURL *url = [NSURL fileURLWithPath:fullPath];
    
    self = [self initWithFileURL:url];
    return self;
}


- (NSData*)getSymbolicData
{
    NSData *symbolicData = [self _symbolicDataForDocumentModel:_docModel];
    return symbolicData;
}


- (NSString*)getFileName
{
    NSURL *theURL = self.fileURL;
    NSString *fileName = [theURL lastPathComponent];
    return fileName;
}


- (NSString*)getName
{
    NSURL *theURL = self.fileURL;
    NSString *fileName = [theURL lastPathComponent];
    NSString *name  = [fileName stringByDeletingPathExtension];
    return name;
}


- (void)openWithCompletionHandler:(void (^)(BOOL success))completion
{
    [super openWithCompletionHandler:^(BOOL success)
    {
        [self setHasUnsavedChangesForType:SWFileTypeWrappValuesBinary];
        [self setHasUnsavedChangesForType:SWFileTypeWrappValuesSymbolic];
        if ( completion ) completion( success );
    }];
}


- (void)saveWithCompletion:(void (^)(BOOL success))completion
{
    [self saveForSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success)
    {
        [self setHasUnsavedChangesForType:SWFileTypeWrappValuesBinary];
        [self setHasUnsavedChangesForType:SWFileTypeWrappValuesSymbolic];
        if ( completion ) completion( success );
    }];
}


- (void)closeWithCompletionHandler:(void (^)(BOOL success))completionHandler
{
    [super closeWithCompletionHandler:completionHandler];
}


- (void)saveForCreatingWithSavingType:(SWDocumentSavingType)savingType completionHandler:(void (^)(BOOL success))completionHandler
{
    NSURL *theURL = self.fileURL;
    NSString *fileSavingType = [self _fileSavingTypeForType:savingType];
    
    [self saveToURL:theURL withType:fileSavingType forSaveOperation:UIDocumentSaveForCreating completionHandler:completionHandler];
}


- (void)setHasUnsavedChangesForSavingType:(SWDocumentSavingType)savingType
{
    NSString *fileSavingType = [self _fileSavingTypeForType:savingType];
    [self setHasUnsavedChangesForType:fileSavingType];
}



#pragma mark - Private Methods

- (NSString*)_fileSavingTypeForType:(SWDocumentSavingType)savingType
{
    NSString *fileSavingType = nil;
    
    if ( savingType == SWDocumentSavingTypeBinary )
        fileSavingType = SWFileTypeWrappBinary;
    
    else if ( savingType == SWDocumentSavingTypeSymbolic )
        fileSavingType = SWFileTypeWrappSaveSymbolic;
    
    else if ( savingType == SWDocumentSavingTypeValuesBinary)
        fileSavingType = SWFileTypeWrappValuesBinary;
    
    else if ( savingType == SWDocumentSavingTypeValuesSymbolic)
        fileSavingType = SWFileTypeWrappValuesSymbolic;
    
    else if ( savingType == SWDocumentSavingTypeThumbnail)
        fileSavingType = SWFileTypeWrappSaveThumbnail;

    return fileSavingType;
}


- (NSError*)_getErrorWithMessage:(NSString*)message
{
    NSDictionary *info = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:@"com.SweetWilliam.HmiPad" code:0 userInfo:info];
    return error;
}


- (SWDocumentModel*)_decodeDocumentModelFromSymbolicData:(NSData*)data error:(NSError *__autoreleasing *)outError
{
    SWDocumentModel *documentModel = nil;
    
    if ( HMiPadRun )
    {
        data = [data decrypt];
    }

    if ( data )
    {
        RpnBuilder *builder = [[RpnBuilder alloc] init];
        SymbolicUnarchiver *unarchiver = [[SymbolicUnarchiver alloc] initWithRpnBuilder:builder parentObject:nil];
    
        BOOL succeed = [unarchiver prepareForReadingWithData:data outError:outError];
    
        if ( succeed )
        {
            BOOL versionPass = ([unarchiver version] <= SWVersion || SWIgnoreVersionOnSymbolicLoad);
            if ( !versionPass )
            {
                NSString *message = NSLocalizedString(@"This Project was created with a newer version of the app. Please update the app to the lastest.", nil);
                *outError = [self _getErrorWithMessage:message];
                succeed = NO;
            }
    
            if ( succeed )
            {
                documentModel = [unarchiver decodeObjectForKey:@"document"];
                succeed = [unarchiver finishDecodingOutError:outError ignoreMissingSymbols:NO];
            }
        
            if ( succeed )
            {
                // si en el metaData hi ha un project_id, aquest es el que agafem per bo
                NSDictionary *metaData = [unarchiver metaData];
                NSString *uuid = [metaData objectForKey:@"project_id"];
                if ( uuid )
                {
                    documentModel.uuid = uuid;   // overridem
                }
                else
                {
                    if ( HMiPadDev )
                        [self setHasUnsavedChangesForType:SWFileTypeWrappSaveSymbolic];
                }
            }
        
            if ( !succeed ) documentModel = nil;
        }
    
        // si hem descodificat sense errors pero el document es igualment nil, doncs el creem explicitament ara
        if ( succeed && documentModel == nil )
        {
            documentModel = [[SWDocumentModel alloc] init];
        }
    }
    
    return documentModel;
}


- (BOOL)_retrieveDocumentModel:(SWDocumentModel*)documentModel fromSymbolicData:(NSData*)data error:(NSError *__autoreleasing *)outError
{
    if ( HMiPadRun )
    {
        data = [data decrypt];
    }

    RpnBuilder *builder = documentModel.builder;
    SymbolicUnarchiver *unarchiver = [[SymbolicUnarchiver alloc] initWithRpnBuilder:builder parentObject:nil];
    
    BOOL succeed = [unarchiver prepareForReadingWithData:data outError:outError];
    succeed = succeed && ([unarchiver version] <= SWVersion || SWIgnoreVersionOnSymbolicLoad) ;
    succeed = succeed && [unarchiver retrieveForObject:documentModel forKey:@"document"];
    succeed = succeed && [unarchiver finishDecodingOutError:outError ignoreMissingSymbols:NO];
    
    return succeed;
}


- (SWDocumentModel*)_decodeDocumentModelFromBinaryData:(NSData*)data error:(NSError *__autoreleasing *)outError
    versionConflict:(BOOL*)outVersionConflict
{
    SWDocumentModel *documentModel = nil ;
    
    if ( HMiPadRun )
    {
        data = [data decrypt];
    }
    
    NSInteger docVersion = 0;

    if ( data )
    {
        QuickUnarchiver *unarchiver = [[QuickUnarchiver alloc] initForReadingWithData:data];
        docVersion = [unarchiver version];
    
        if ( docVersion == -1 )
        {
            documentModel = [[SWDocumentModel alloc] init];
        }
        else if (docVersion == SWVersion)
        {
            documentModel = [unarchiver decodeObject];
        }
    }
    
    if ( documentModel == nil )
    {
        if ( outError )
        {
            NSString *message = NSLocalizedString(@"Incompatible Document Version", nil);
            *outError = [self _getErrorWithMessage:message];
        }
        
        if ( outVersionConflict ) *outVersionConflict = YES;
    }
    
    return documentModel;
}


- (BOOL)_retrieveDocumentModel:(SWDocumentModel*)documentModel fromBinaryData:(NSData*)data error:(NSError *__autoreleasing *)outError
    versionConflict:(BOOL*)outVersionConflict
{
    if ( HMiPadRun )
    {
        data = [data decrypt];
    }
    
    QuickUnarchiver *unarchiver = [[QuickUnarchiver alloc] initForReadingWithData:data];
    
    BOOL result = NO;
    NSInteger docVersion = [unarchiver version];
    
    if (docVersion == SWVersion)
    {
        result = [unarchiver retrieveForObject:documentModel];
    }
    
    if ( result == NO )
    {
        if ( outError )
        {
            NSString *message = NSLocalizedString(@"Failed to retrieve retentive data", nil);
            *outError = [self _getErrorWithMessage:message];
        }
        
        if ( outVersionConflict )
        {
            *outVersionConflict = YES;
        }
    }
    
    return result;
}


- (NSData*)_binaryDataForDocumentModel:(SWDocumentModel*)documentModel
{
    NSMutableData *data = [NSMutableData data];
    int version = (documentModel == nil) ? -1 : SWVersion;
            
    QuickArchiver *archiver = [[QuickArchiver alloc] initForWritingWithMutableData:data version:version];
        
    [archiver encodeObject:documentModel];
    [archiver finishEncoding];
    
    if ( HMiPadRun )
    {
        return [data encrypt];
    }
    
    //return [data copy];
    return data;   // res de copy
}


- (NSData*)_valuesBinaryDataForDocumentModel:(SWDocumentModel*)documentModel
{
    NSMutableData *data = [NSMutableData data];
    int version = (documentModel == nil) ? -1 : SWVersion;
            
    QuickArchiver *archiver = [[QuickArchiver alloc] initForWritingWithMutableData:data version:version];
    [archiver setIsStore:YES];
        
    [archiver encodeObject:documentModel];
    [archiver finishEncoding];
    
    if ( HMiPadRun )
    {
        return [data encrypt];
    }
    
    //return [data copy];
    return data;   // res de copy
}


- (NSData*)_symbolicDataForDocumentModel:(SWDocumentModel*)documentModel
{
    NSMutableData *data = [NSMutableData data];
    int version = (documentModel == nil) ? -1 : SWVersion;
        
    //SymbolicArchiver *archiver = [[SymbolicArchiver alloc] initForWritingWithMutableData:data version:version];
    NSMutableDictionary *metaData = [NSMutableDictionary dictionary];
    
    NSString *uuid = documentModel.uuid;
    if ( uuid ) [metaData setObject:uuid forKey:@"project_id"];
    
    //[metaData setObject:[NSString stringWithFormat:@"%d", (unsigned int)documentModel.ownerID] forKey:@"owner_id"];
    
  
//    NSDictionary *metaData =
//    @{
//        @"project_id" : documentModel.uuid,
//            //@"owner_id" : [NSString stringWithFormat:@"%d", (unsigned int)documentModel.ownerID],
//    };
    
    
    SymbolicArchiver *archiver = [[SymbolicArchiver alloc] initForWritingWithMutableData:data metaData:metaData version:version];
    
    [archiver encodeObject:documentModel forKey:@"document"];
    [archiver finishEncoding];
    
    if ( HMiPadRun )
    {
        return [data encrypt];
    }
    
    //return [data copy];
    return data;    // res de copy
}


- (NSData*)_valuesSymbolicDataForDocumentModel:(SWDocumentModel*)documentModel
{
    NSMutableData *data = [NSMutableData data];
    int version = (documentModel == nil) ? -1 : SWVersion;
        
    SymbolicArchiver *archiver = [[SymbolicArchiver alloc] initForWritingWithMutableData:data version:version];
    [archiver setIsStore:YES];
    
    [archiver encodeObject:documentModel forKey:@"document"];
    [archiver finishEncoding];
    
    if ( HMiPadRun )
    {
        return [data encrypt];
    }
    
    //return [data copy];
    return data;    // res de copy
}

@end
