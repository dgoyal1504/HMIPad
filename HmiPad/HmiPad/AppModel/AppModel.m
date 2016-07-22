//
//  AppModel.m
//  HMiPad
//
//  Created by Joan on 08/11/12.
//  Copyright 2012 SweetWilliam, S.L. All rights reserved.
//

#import "AppModel.h"

#import "SWDatabaseManager.h"

#import "AppModelFilePaths.h"
#import "AppModelFilesEx.h"
#import "AppModelFileServer.h"
#import "AppModelDocument.h"
#import "AppModelSource.h"
#import "AppModelRecipeSheet.h"
#import "AppModelDatabase.h"
#import "AppModelImage.h"
#import "AppModelActivationCodes.h"
#import "AppModelDownloadExamples.h"

#pragma mark AppFilesModel

@interface AppModel()<AppModelFilePathsDelegate>
{
    CKContainer *_container;
    CKDatabase *_database;
    
//    CKContainer *_examplesContainer;
//    CKDatabase *_examplesDatabase;
}
@end

@implementation AppModel
{
}


#pragma mark private/template


//------------------------------------------------------------------------------------
+ (NSArray *)_fileTemplates
{
    NSArray *templates = [[NSArray alloc] initWithObjects:
    
    #if HMiPadDev
        @"Example-StarterProject",
        @"Example-ControlsSuite",
        @"Example-TimeAndFormulas",
        @"Example-CommsDemo",
        @"Example-MultiLanguage",
        @"Example-Multitouch",
        @"Example-VerificationText",
        @"Example-PageTransition",
        @"Example-IndicatorScale",
        @"Example-TextColorAndSize",
        @"Example-Encrypt",
        @"Example-PdfViewer",
        @"Example-Scanner",
        @"Example-Chart",
        @"Example-Promotional",
    #endif
    
        nil ] ;
    return templates ;
}

//------------------------------------------------------------------------------------
+ (NSArray *)_assetFileTemplates
{
    NSArray *templates = [[NSArray alloc] initWithObjects:
    
    #if HMiPadDev
        @"example-pdf_01.pdf",
        @"example-pdf_02.pdf",
        @"example-pdf_03.pdf",
        @"example-pdf_04.pdf",
        @"example-pdf_05.pdf",
        @"example-pdf_06.pdf",
        @"example-background1.jpg",
        @"example-background2.jpg",
        @"example-background3.jpg",
        @"example-PLL_Blau_FDre_Off.png",
        @"example-PLL_Blau_FEsq_Off.png",
    #endif
        nil ] ;

    return templates ;
}



//------------------------------------------------------------------------------------
- (BOOL)projectDirectoryExists
{
    BOOL result = YES;
    NSFileManager *fileManager = [NSFileManager defaultManager] ;
    
    // comprobem la existencia del directori de projectes
    result = result && [fileManager fileExistsAtPath:[_filePaths filesRootDirectoryForCategory:kFileCategorySourceFile]] ;

    return result  ;
}


//------------------------------------------------------------------------------------
- (BOOL)maybeCreateAuxiliarDirectories
{
    NSFileManager *fileManager = [NSFileManager defaultManager] ;
    BOOL result = YES ;
    
   // si el directori de database existeix el deixa tranquil, si no el crea
    NSString *databaseFilesRootDirectory = [_filePaths filesRootDirectoryForCategory:kFileCategoryDatabase];
    if (  result && [fileManager fileExistsAtPath:databaseFilesRootDirectory] == NO )
    {
        NSError *error=nil;
        result = [fileManager createDirectoryAtPath:databaseFilesRootDirectory withIntermediateDirectories:YES attributes:nil error:&error] ;
        NSLog( @"error: %@", error);
    }

    if ( !HMiPadDev )
        return YES;
    
    // si el directori de recipes existeix el deixa tranquil, si no el crea
    NSString *recipesRootDirectory = [_filePaths filesRootDirectoryForCategory:kFileCategoryRecipe];
    if (  result && [fileManager fileExistsAtPath:recipesRootDirectory] == NO )
    {
        result = [fileManager createDirectoryAtPath:recipesRootDirectory withIntermediateDirectories:YES attributes:nil error:NULL] ;
    }
    
    // si el directori de assets existeix el deixa tranquil, si no el crea
    NSString *assetFilesRootDirectory = [_filePaths filesRootDirectoryForCategory:kFileCategoryAssetFile];
    if (  result && [fileManager fileExistsAtPath:assetFilesRootDirectory] == NO )
    {
        result = [fileManager createDirectoryAtPath:assetFilesRootDirectory withIntermediateDirectories:YES attributes:nil error:NULL] ;
    }
    
    // torna NO si alguna cosa ha fallat
    return result ;
}

//------------------------------------------------------------------------------------
- (BOOL)createApplicationSupportDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager] ;
    
    // si el directori base existeix s'el carrega completament i en crea un de nou
    if ( [fileManager fileExistsAtPath:[_filePaths internalFilesDirectory]] ) [fileManager removeItemAtPath:[_filePaths internalFilesDirectory] error:NULL] ;
    BOOL result = [fileManager createDirectoryAtPath:[_filePaths internalFilesDirectory] withIntermediateDirectories:YES attributes:nil error:NULL] ;
    
    // torna NO si alguna cosa ha fallat
    return result ;
}

//------------------------------------------------------------------------------------
- (BOOL)createFilesDirectory
{
    BOOL result = YES;
    NSString *filesRootDirectory = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager] ;
    
//    if ( HMiPadDev )
    {
        // si el directori de sources existeix s'el carrega completament i en crea un de nou
        filesRootDirectory = [_filePaths filesRootDirectoryForCategory:kFileCategorySourceFile];
        if ( [fileManager fileExistsAtPath:filesRootDirectory] ) [fileManager removeItemAtPath:filesRootDirectory error:NULL] ;
        result = result && [fileManager createDirectoryAtPath:filesRootDirectory withIntermediateDirectories:YES attributes:nil error:NULL] ;
    }
    
    // si el directori de redeemed existeix s'el carrega completament i en crea un de nou
//    filesRootDirectory = [self filesRootDirectoryForCategory:kFileCategoryRedeemedSourceFile];
//    if ( [fileManager fileExistsAtPath:filesRootDirectory] ) [fileManager removeItemAtPath:filesRootDirectory error:NULL] ;
//    result = result && [fileManager createDirectoryAtPath:filesRootDirectory withIntermediateDirectories:YES attributes:nil error:NULL] ;
    
    // provem de crear els directoris auxiliars
    result = result && [self maybeCreateAuxiliarDirectories] ;
    
    // torna NO si alguna cosa ha fallat
    return result ;
}



////------------------------------------------------------------------------------------
//// Creates a writable copy of the bundled default files in the application Documents directory.
//- (BOOL)copyFileTemplatesV
//{
//    if ( !HMiPadDev )
//        return YES;
//    
//    // determinem quin es el directori origen
//    NSString *resourcesDirectory = [[NSBundle mainBundle] resourcePath] ;
//    NSArray *fileTemplates;
//    FileCategory fileCategory;
//    
//    // iterem per les dues categores de fitxers que hem de copiar
//    BOOL success = YES ;
//    for ( int i=0 ; i<2 ; i++ )
//    {
//        if ( i == 0 )
//        {
//            // fitxers que s'han de copiar i a on
//            fileTemplates = [[self class] _fileTemplates] ;
//            fileCategory = kFileCategorySourceFile;
//        }
//        
//        if ( i == 1 )
//        {
//            // fitxers que s'han de copiar i a on
//            fileTemplates = [[self class] _assetFileTemplates] ;
//            fileCategory = kFileCategoryAssetFile ;
//        }
//    
//        // per cada fitxer comprobem primer si hi es a desti i si no el copiem de resources (pre 1.4.5)
//        // per cada fitxer copiem de resources a files (post 1.4.5)
//        for ( NSString *file in fileTemplates )
//        {            
//            NSError *error = nil;
//            NSString *resourceFile = [resourcesDirectory stringByAppendingPathComponent:file];
//            
//            if ( NO == [_files copyToTemporaryForFileFullPath:resourceFile error:&error] )
//            {
//                NSLog(@"Failed to copy writable template file '%@', error: '%@'.", resourceFile, [error localizedDescription]);
//                //success = NO;   <-- comentem fora aixo per evitar errors al primer launch
//            }
//            
//            else if ( NO == [_files moveFromTemporaryToCategory:fileCategory forFile:file addCopy:NO error:&error] )
//            {
//                NSLog(@"Failed to create writable template file '%@', error: '%@'.", file, [error localizedDescription]);
//                //success = NO;   <-- comentem fora aixo per evitar errors al primer launch
//            }
//        }
//    }
//    if ( success )
//    {
//        [_files notifyFileListingChangeForCategory:kFileCategorySourceFile];   // crec que no cal
//        [_files notifyFileListingChangeForCategory:kFileCategoryAssetFile];    // crec que no cal
//    }
//    return success ;
//}



//------------------------------------------------------------------------------------
// Creates a writable copy of the bundled default files in the application Documents directory.
- (BOOL)copyFileTemplates
{
    if ( !HMiPadDev )
        return YES;
    
    // determinem quin es el directori origen
    NSString *resourcesDirectory = [[NSBundle mainBundle] resourcePath] ;
    NSArray *fileTemplates;
    FileCategory fileCategory;
    
    // iterem per les dues categores de fitxers que hem de copiar
    BOOL success = YES ;
    for ( int i=0 ; i<2 ; i++ )
    {
        if ( i == 0 )
        {
            // fitxers que s'han de copiar i a on
            fileTemplates = [[self class] _fileTemplates] ;
            fileCategory = kFileCategorySourceFile;
        }
        
        if ( i == 1 )
        {
            // fitxers que s'han de copiar i a on
            fileTemplates = [[self class] _assetFileTemplates] ;
            fileCategory = kFileCategoryAssetFile ;
        }
    
        // per cada fitxer comprobem primer si hi es a desti i si no el copiem de resources (pre 1.4.5)
        // per cada fitxer copiem de resources a files (post 1.4.5)
        for ( NSString *file in fileTemplates )
        {            
            NSError *error = nil;
            NSString *resourceFile = [resourcesDirectory stringByAppendingPathComponent:file];
            if ( NO == [_files copyToTemporaryForFileFullPath:resourceFile error:&error] )
            {
                NSLog(@"Failed to copy writable template file '%@', error: '%@'.", resourceFile, [error localizedDescription]);
                //success = NO;   <-- comentem fora aixo per evitar errors al primer launch
            }
            else if ( NO == [_files moveFromTemporaryToCategory:fileCategory forFile:file addCopy:NO error:&error] )
            {
                NSLog(@"Failed to create writable template file '%@', error: '%@'.", file, [error localizedDescription]);
                //success = NO;   <-- comentem fora aixo per evitar errors al primer launch
            }
        }
    }
    if ( success )
    {
        [_files notifyFileListingChangeForCategory:kFileCategorySourceFile];   // crec que no cal
        [_files notifyFileListingChangeForCategory:kFileCategoryAssetFile];    // crec que no cal
    }
    return success ;
}

//------------------------------------------------------------------------------------
- (BOOL)deleteFileTemplates
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *fileTemplates ;
    NSString *filesDirectory ;
    
    // iterem per les dues categores de fitxers que hem de esborrar
    BOOL success = YES ;
    for ( int i=0 ; i<2 ; i++ )
    { 
        if ( i == 0 )
        {
            // fitxers que s'han de esborrar i a on
            fileTemplates = [[self class] _fileTemplates] ;
            //filesDirectory = [self _filesRootDirectory] ;
            filesDirectory = [_filePaths filesRootDirectoryForCategory:kFileCategorySourceFile];
        }
        
        if ( i == 1 )
        {
            // fitxers que s'han de esborrar i a on
            fileTemplates = [[self class] _assetFileTemplates] ;  // &&&
            //filesDirectory = [self _documentFilesRootDirectory] ;
            filesDirectory = [_filePaths filesRootDirectoryForCategory:kFileCategoryAssetFile];
        }
    
        // per cada fitxer comprobem primer si hi es a desti i l'esborrem
        for ( NSString *file in fileTemplates )
        {
            NSString *writableFile = [filesDirectory stringByAppendingPathComponent:file];
            if ( [fileManager fileExistsAtPath:writableFile] )
            {
                [fileManager removeItemAtPath:writableFile error:nil] ;
            }
        }
    }
    
    if ( success )
    {
        [_files notifyFileListingChangeForCategory:kFileCategorySourceFile];
        [_files notifyFileListingChangeForCategory:kFileCategoryAssetFile];
    }
    return success ;
}


- (NSString*)shrinkProjectName:(NSString *)longName forCategory:(FileCategory)category
{
    if ( category != kFileCategorySourceFile )
        return longName;
    
    NSString *shortName = longName;
    if ( [[longName pathExtension] caseInsensitiveCompare:SWFileExtensionWrapp] == NSOrderedSame)
        shortName = [longName stringByDeletingPathExtension];
    
    return shortName;
}


- (NSString*)expandProjectName:(NSString *)shortName forCategory:(FileCategory)category
{
    if ( category != kFileCategorySourceFile )
        return shortName;
    
    NSString *longName = shortName;
    if ( [shortName pathExtension].length == 0 )
        longName = [shortName stringByAppendingPathExtension:SWFileExtensionWrapp];
    
    return longName;
}




#pragma mark - Database context

- (void)dataBaseContextDidOpenDatabaseNotification:(NSNotification*)note
{
    [_files resetMDArrayForCategory:kFileCategoryDatabase];
    [_files refreshMDArrayForCategory:kFileCategoryDatabase];
}


#pragma mark Company Logo

////------------------------------------------------------------------
//- (NSString *)companyLogoFilePath
//{
//	NSString *rootPath = [self _internalFilesDirectory] ;
//    NSString *filePath = [rootPath stringByAppendingPathComponent:@"CompanyLogo.png"] ;
//    return filePath ;
//}
//
////------------------------------------------------------------------
//// temporary logo, s'utilitza per amagatzemar el logo abans d'escalar a definitiu
//// aqui es on el httpserver posa el fitxer
//- (NSString*)temporaryLogoFilePath
//{
//	NSString *rootPath = [self _temporaryFilesDirectory] ;
//    NSString *filePath = [rootPath stringByAppendingPathComponent:@"CompanyLogo.png"] ;
//    return filePath ;
//}

//------------------------------------------------------------------
- (void)companyLogoEnable:(BOOL)enable
{
	// do stuff
}

//------------------------------------------------------------------
- (void)companyLogoFileTouch
{
//    ModelNotificationCenter *mnc = [ModelNotificationCenter defaultCenter] ;
//    [mnc postNotificationName:kCompanyLogoFileTouchedNotification object:nil] ;
}


//------------------------------------------------------------------
- (UIImage*)scaledLogoFromImage:(UIImage*)image
{
    if ( image == nil ) return nil ;
    
    UIImage *logoImage ;
    
    BOOL respondsToScale = NO ;
    if ( [image respondsToSelector:@selector(scale)] ) respondsToScale = YES ;

	CGSize size ; // = [image size] ;
    if ( respondsToScale && (size = [image size]).height != 40 )
    {
        CGFloat imageScale = [image scale] ;
        CGFloat scale = size.height*imageScale/40.0f ;
        logoImage = [[UIImage alloc] initWithCGImage:[image CGImage] scale:scale orientation:UIImageOrientationUp] ;
    }
    else
    {
    	logoImage = image ;
    }
    return logoImage ;
}


//------------------------------------------------------------------
- (void)resetcompanyLogo
{
	// copiar el logo de SweetWilliam dels resources al CompanyLogo
    // atenció: el logo ha de ser correcte i tenir 40 punts de alzada en 72dpi (o 80 i escala 2.0 (@2x)), o 40 en 144dpi 
    
    UIImage *image = [UIImage imageNamed:@"CompanyLogo.png_u"] ;

    NSString *dest = [_filePaths companyLogoFilePath] ;
    UIImage *logoImage = [self scaledLogoFromImage:image] ;
    NSData *imageData = UIImagePNGRepresentation(logoImage) ;
    NSLog1( @"\n%@,\n%@,\n%@", image, dest, logoImage ) ;
    [imageData writeToFile:dest atomically:NO] ;
}


- (void)selectcompanyLogo
{

}


//------------------------------------------------------------------
- (void)makeFinalLogoFromScaledTemporaryLogo
{
	NSString *origin = [_filePaths temporaryLogoFilePath] ;
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:origin] ;
    UIImage *logoImage = [self scaledLogoFromImage:image] ;
    
    NSString *dest = [_filePaths companyLogoFilePath] ;
    NSData *imageData = UIImagePNGRepresentation(logoImage) ;
    [imageData writeToFile:dest atomically:NO] ;

}



//////////////////////////////////////////////////////////////////////////////////////
#pragma mark Mal comportament de OEM
//////////////////////////////////////////////////////////////////////////////////////
//------------------------------------------------------------------------------------
- (BOOL)badOEM
{
#if OEM || Integrator
    return [defaults() badOEM] ;
#else
    return NO;
#endif
}

//------------------------------------------------------------------------------------
- (void)setBadOEM
{
#if OEM || Integrator
    [defaults() setBadOEM:YES] ;  // un cop es dolent, ho es. Nomes s'arregla tornant a instalar l'aplicacio
    [self pageNodesTouch] ;
    [self clausureSourceElementsComunicationObjects] ;
    [sourceElements release] ;
    sourceElements = nil ;
#endif
}


#pragma mark - cloudKit

#if UseCloudKit


- (void)resetCkContainer
{
    _container = nil;
}

- (CKContainer *)ckContainer
{
    if ( _container == nil )
    {
        //_container = [CKContainer defaultContainer];
        _container = [CKContainer containerWithIdentifier:@"iCloud.com.sweetwilliam.HMIPadCloudContainer"];
    //    _container = [CKContainer containerWithIdentifier:@"iCloud.com.sweetwilliam.tolotic"];
        //_container = [CKContainer containerWithIdentifier:@"iCloud.com.sweetwilliam.HMIPad"];
    }
    return _container;
}


- (CKDatabase *)ckDatabase
{
    if ( _database == nil )
        _database = [[self ckContainer] publicCloudDatabase];
    
    return _database;
}




#endif


#pragma mark AppModelFilePathsDelegate

- (void)filePathsDidFireITunesFileSharingDirectoryWatcher:(AppModelFilePaths *)filePaths
{
    [_files notifyFileListingChangeForCategory:kExtFileCategoryITunes];
}

- (void)filePathsDidFireDatabaseDirectoryWatcher:(AppModelFilePaths *)filePaths
{
    [_files notifyFileListingChangeForCategory:kFileCategoryDatabase];
}



#pragma mark Metodes del AppFilesModel

//------------------------------------------------------------------------------------
- (id)init
{
    self = [super init] ;
    if (self)
    {
        NSLog1(@"Model: init") ;
        
        _queueKey = "SWAppModelQueue";
        _queueContext = (void*)_queueKey;
        _dQueue = dispatch_queue_create( _queueKey, NULL );
        dispatch_queue_set_specific( _dQueue, _queueKey, _queueContext, NULL);
        
//        SWImageManager *imageManager = [SWImageManager defaultManager];
//        [imageManager setDispatchQueue:_dQueue key:_queueKey];
        
       // SWDatabaseManager *databaseManager = [SWDatabaseManager defaultManager];
       // [databaseManager setDispatchQueue:_dQueue key:_queueKey];
        
        _filePaths = [[AppModelFilePaths alloc] init];
        _filePaths.delegate = self;
        
        _files = [[AppModelFilesEx alloc] initWithLocalFilesModel:self];
        
        _fileServer = [[AppModelFileServer alloc] init];
        
        _fileDocument = [[AppModelDocument alloc] initWithLocalFilesModel:self];
        
        _fileSource = [[AppModelSource alloc] initWithLocalFilesModel:self];
        
        _amRecipeSheet = [[AppModelRecipeSheet alloc] initWithLocalFilesModel:self];
        
        _amDatabase = [[AppModelDatabase alloc] initWithLocalFilesModel:self];
        
        _amImage = [[AppModelImage alloc] initWithLocalFilesModel:self];
        
        _amActivationCodes = [[AppModelActivationCodes alloc] initWithLocalFilesModel:self];
        
        _amDownloadExamples = [[AppModelDownloadExamples alloc] initWithLocalFilesModel:self];
        
        
//        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//        [nc addObserver:self selector:@selector(dataBaseContextDidOpenDatabaseNotification:) name:SWDatabaseContextDidOpenDatabaseNotification object:nil];
        
//        _observers = CFBridgingRelease(CFArrayCreateMutable(NULL, 0, NULL));
//        _pendingFileListingNotifications = [[NSMutableIndexSet alloc] init];
//        _pendingFileListingWillNotifications = [[NSMutableIndexSet alloc] init];
    }
    return self;
}



//-----------------------------------------------------------------------------------
- (void)dealloc
{   
    NSLog1(@"Model dealloc") ;
//    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//    [nc removeObserver:self];
    _dQueue = nil;
}

@end

#pragma mark Acces a AppFilesModel

//-------------------------------------------------------------------------------------------- 
static __strong AppModel *_appFilesModel = nil ;

AppModel *filesModel(void)
{
    if ( _appFilesModel == nil ) _appFilesModel = [[AppModel alloc] init] ;
    return _appFilesModel ;
}


//-------------------------------------------------------------------------------------------- 
void filesModel_release(void)
{
    _appFilesModel = nil ;
}



//#pragma mark Acces a AppFilesModel
//
////-------------------------------------------------------------------------------------------- 
//static AppFilesModel *_appFilesModel = nil ;
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


