//
//  This class was created by Nonnus,
//  who graciously decided to share it with the CocoaHTTPServer community.
//
// Modified by Andrew E. Davidson andy@santacruzintegration.com on 12/29/08
// added the following:
// 1) formated generated HTML to make debugging and customization easier
// 2) add the ability to create new folders
// 3) add the ablity to delete files and folders
// 4) directory listings allow you to drill down and up file system
// 5) can upload files into sub directories
// 6) commented out NSLog1() debug statements
// 7) formated listing using table
// 8) formated the dates

#import <CFNetwork/CFNetwork.h>

#import "HTTPConnectionSubclass.h"
//#import "AsyncSocket.h"
#import "GCDAsyncSocket.h"
#import "HTTPServer.h"
//#import "HTTPResponse.h"
#import "HTTPFileResponse.h"
#import "HTTPDataResponse.h"
#import "HTTPMessage.h"

#import "AppModelFilePaths.h"
#import "AppModelFilesEx.h"
#import "AppModel.h"
#import "UserDefaults.h"

#define DEBUGING 0

#if DEBUGGING
    #define NSLog1(args...) NSLog(args)
#else
    #define NSLog1(...) {}
#endif

/////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark HTTPOctetStreamFileResponse
/////////////////////////////////////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------------------------
// implementa un HTTPFileResponse amb 'application/octet-stream' com a 'Content-type'
@interface HTTPOctetStreamFileResponse : HTTPFileResponse
@end

//-----------------------------------------------------------------------------------------------
@implementation HTTPOctetStreamFileResponse
- (NSDictionary *)httpHeaders
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"application/octet-stream" forKey:@"Content-Type"] ;
    return dictionary ;
}
@end



/////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark HTTPConnectionSubclass
/////////////////////////////////////////////////////////////////////////////////////////////////

@interface HTTPConnectionSubclass()


//- (HTTPDataResponse *)generateDirectoryListing:(NSString *)path wrapped:(BOOL)wrapped;
//- (HTTPDataResponse *)generateDirectoryListingWrapped:(BOOL)wrapped fullPath:(NSString*)fullPath relPath:(NSString*)relPath;
//- (void)endProcessPost;
//- (HTTPDataResponse *)doDelete:(NSString *)path;

@end


@implementation HTTPConnectionSubclass



//---------------------------------------------------------------------------------------------------
// indica el lloc d'on es busca un fitxer en una operacio de GET,
// tambe s'utilitza per determinar quina part del model s'ha de actualitzar (tant en GET com POST)
enum FileLocation
{
	kFileLocationNone,
    kFileLocationRoot,   // es un index.html
	kFileLocationResources,  // en els recursos, (elements de la pagina web)
    kFileLocationSources, // en library/preferences/files (els fiters csv de configuracio, download)
    kFileLocationRecipes, // en library/preferences/files/recipes (els fiters csv de configuracio, download)
    kFileLocationDocuments,  // en documents. (els fitxers de documents, download)
    kFileLocationDatabases,
    kFileLocationCompanyLogo  // en library/preferences/ (el logo de l'empresa)
} ;

typedef enum FileLocation FileLocation ;

//---------------------------------------------------------------------------------------------------
// indica el ultim tipus de contigut post (corrent) que hem rebut
enum PostContentKind
{
	kPostContentKindNone,
    kPostContentKindSource,
    kPostContentKindRecipe,
    kPostContentKindDocumentFile, 
    kPostContentKindDatabaseFile,
    kPostContentKindLogoSelection,
    kPostContentKindLogoData,
	kPostContentKindLogoFile,
} ;

typedef enum PostContentKind PostContentKind ;

//---------------------------------------------------------------------------------------------------
// indica el tipus de resposta que hem de donar al httprequest despres de un post
enum PostResponseKind
{
	kPostResponseKindNone,
    kPostResponseKindFile,
    kPostResponseKindRecipe,
    kPostResponseKindDocument,
    kPostResponseKindDatabase,
	kPostResponseKindLogo,
} ;

typedef enum PostResponseKind PostResponseKind ;

//---------------------------------------------------------------------------------------------------
static NSString* RootStr = @"/" ; 
static NSString* ResourcesStr = @"/resources/" ; 
static NSString* SourcesStr = @"/files/" ; 
static NSString* RecipesStr = @"/recipes/" ; 
static NSString* DatabasesStr = @"/databases/" ;
static NSString* LogoFileStr = @"/logofile/" ; 



//---------------------------------------------------------------------------------------------------
- (FileLocation)fileLocationForURLRelPath:(NSString*)relPath
{
	FileLocation theLocation ;
    if ( [relPath isEqualToString:RootStr] ) theLocation = kFileLocationRoot ;
    else if ( [relPath hasPrefix:ResourcesStr] ) theLocation = kFileLocationResources ;
    else if ( [relPath hasPrefix:SourcesStr] ) theLocation = kFileLocationSources ;
    else if ( [relPath hasPrefix:RecipesStr] ) theLocation = kFileLocationRecipes ;
    else if ( [relPath hasPrefix:DatabasesStr] ) theLocation = kFileLocationDatabases ;
    else if ( [relPath hasPrefix:LogoFileStr] ) theLocation = kFileLocationCompanyLogo ;
    else theLocation = kFileLocationDocuments ;

    return theLocation ;
}



//---------------------------------------------------------------------------------------------------
- (NSString *)localizedRelPath:(NSString *)relPath
{
    NSString *localizedRelPath = nil ;
    NSString *pathExtension = [relPath pathExtension] ;
    if ( [pathExtension isEqualToString:@"html"] )
    {
        NSString *lang = NSLocalizedString(@"DefaultLanguage", nil) ;
        if ( [lang isEqualToString:@"Spanish"] )
        {
            localizedRelPath = [[NSString alloc] initWithFormat:@"%@%@%@", [relPath stringByDeletingPathExtension], @"ES.", pathExtension] ;
        }
    }
    if ( localizedRelPath == nil )
    {
        localizedRelPath = relPath ;
    }
    return localizedRelPath ;
}


//---------------------------------------------------------------------------------------------------
- (NSString *)dirPathForFileLocation:(FileLocation)location
{
    NSString *dirPath = nil ;
    
    AppModelFilePaths *filePaths = filesModel().filePaths;
    
    switch ( location )
    {
    	case kFileLocationRoot :
	    	dirPath = [[NSBundle mainBundle] resourcePath] ;
            break ;
            
        case kFileLocationResources :
            dirPath = [[NSBundle mainBundle] resourcePath] ;
            break ;
        
        case kFileLocationSources :
        	dirPath = [filePaths filesRootDirectoryForCategory:kFileCategorySourceFile] ;
        	break ;
            
        case kFileLocationRecipes :
        	dirPath = [filePaths filesRootDirectoryForCategory:kFileCategoryRecipe] ;
        	break ;
        
        case kFileLocationDocuments :
        	dirPath = [filePaths filesRootDirectoryForCategory:kFileCategoryAssetFile] ;
            break ;
            
        case kFileLocationDatabases :
        	dirPath = [filePaths filesRootDirectoryForCategory:kFileCategoryDatabase] ;
            break ;
            
        case kFileLocationCompanyLogo :
        	break ;
            
        case kFileLocationNone :
            break ;
    }
    return dirPath ;
}


//---------------------------------------------------------------------------------------------------
- (NSString *)relPathForFileLocation:(FileLocation)location
{
    NSString *relPath = nil ;
    
    switch ( location )
    {
    	case kFileLocationRoot :
	    	relPath = RootStr ;
            break ;
            
        case kFileLocationResources :
            relPath = ResourcesStr ;
            break ;
        
        case kFileLocationSources :
        	relPath = SourcesStr ;
        	break ;
            
        case kFileLocationRecipes :
        	relPath = RecipesStr ;
        	break ;
        
        case kFileLocationDocuments :
            relPath = @"" ;
            break ;
            
        case kFileLocationDatabases:
            relPath = DatabasesStr;
            break;
            
        case kFileLocationCompanyLogo :
            relPath = LogoFileStr ;
        	break ;
            
        case kFileLocationNone :
            break ;
    }
    return relPath ;
}


//---------------------------------------------------------------------------------------------------
- (NSString *)domIdForFileLocation:(FileLocation)location
{
    NSString *domId = nil ;
    
    switch ( location )
    {
    	case kFileLocationRoot :
            break ;
            
        case kFileLocationResources :
            break ;
        
        case kFileLocationSources :
        	domId = @"sourceTable" ;
        	break ;
            
        case kFileLocationRecipes :
        	domId = @"recipeTable" ;
        	break ; 
        
        case kFileLocationDocuments :
            domId = @"docTable" ;
            break ;
            
        case kFileLocationDatabases :
            domId = @"databaseTable";
            break;
            
        case kFileLocationCompanyLogo :
        	break ;
            
        case kFileLocationNone :
            break ;
    }
    return domId ;
}




//---------------------------------------------------------------------------------------------------
- (NSString *)filePathForURLRelPath:(NSString*)relPath
{
	FileLocation location = [self fileLocationForURLRelPath:relPath] ;
    NSString *filePath = nil ;
    NSString *dirPath = nil ;
    NSString *fileName = nil ;//[relPath lastPathComponent];
    NSString *localizedRelPath ;
    
    
    AppModelFilePaths *filePaths = filesModel().filePaths;
    
    switch ( location )
    {
    	case kFileLocationRoot :
            dirPath = [[NSBundle mainBundle] resourcePath] ;
            localizedRelPath = [self localizedRelPath:HMiPadDev?@"index.html":@"indexR.html"] ;
            filePath = [dirPath stringByAppendingPathComponent:localizedRelPath] ;
            break ;
        
        case kFileLocationResources :
            dirPath = [[NSBundle mainBundle] resourcePath] ;
            localizedRelPath = [self localizedRelPath:relPath] ;
//            filePath = [dirPath stringByAppendingPathComponent:[localizedRelPath substringFromIndex:[ResourcesStr length]]] ;
            fileName = [localizedRelPath lastPathComponent];
            filePath = [dirPath stringByAppendingPathComponent:fileName];
            break ;
        
        case kFileLocationSources :
            fileName = [relPath lastPathComponent];
            filePath = [filePaths fileFullPathForFileName:fileName forCategory:kFileCategorySourceFile];
            
//            dirPath = [filesModel() filesRootDirectoryForCategory:kFileCategorySourceFile] ;
//            filePath = [dirPath stringByAppendingPathComponent:[relPath substringFromIndex:[SourcesStr length]]] ;
            break ;
            
        case kFileLocationRecipes :
        
            fileName = [relPath lastPathComponent];
            filePath = [filePaths fileFullPathForFileName:fileName forCategory:kFileCategoryRecipe];
//            dirPath = [filesModel() filesRootDirectoryForCategory:kFileCategoryRecipe] ;
//            filePath = [dirPath stringByAppendingPathComponent:[relPath substringFromIndex:[RecipesStr length]]] ;
            break ;
        
        case kFileLocationDocuments :
            fileName = [relPath lastPathComponent];
            filePath = [filePaths fileFullPathForFileName:fileName forCategory:kFileCategoryAssetFile];
//            dirPath = [filesModel() filesRootDirectoryForCategory:kFileCategoryAssetFile] ;
//            filePath = [dirPath stringByAppendingPathComponent:relPath] ;
            break ;
            
        case kFileLocationDatabases :
            fileName = [relPath lastPathComponent];
            filePath = [filePaths fileFullPathForFileName:fileName forCategory:kFileCategoryDatabase];
            break;
        
        case kFileLocationCompanyLogo :
            filePath = [filePaths companyLogoFilePath] ;  // prescindim totalment del nom proporcionat en index.html
            break ;
            
        case kFileLocationNone :
            break ;
    }
    return filePath ;
}




//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark HTML/JSON
//////////////////////////////////////////////////////////////////////////////////////////////////


//------------------------------------------------------------------------------------------------
- (HTTPDataResponse *)generateInteger:(int)value wrapped:(int)wrapped
{
	// preparem la resposta en un NSMutableString
    NSMutableString *html = [[NSMutableString alloc] init];
    
    // si ha d'estar encapsulat en HTML posa la capsalera
    if ( wrapped ) [html appendString:@"<html><body id='logo'>"];
    
    NSString *intStr = [[NSString alloc] initWithFormat:@"%d", value] ;
    [html appendString:intStr] ;
    
    // tanquem l'emboltori si cal
    if ( wrapped ) [html appendString:@"</body></html>"];
    
    // posem la resposta en un NSData
    NSData *browseData = [html dataUsingEncoding:NSUTF8StringEncoding];
    
    // emboliquem el NSData en un HTTPDataResponse i el tornem
    return [[HTTPDataResponse alloc] initWithData:browseData];
}



////------------------------------------------------------------------------------------------------
////- (void)generateFileListAsHtml:(NSMutableString*)html fullPath:(NSString*)filePath relPath:(NSString*)relPath
//- (void)generateFileListAsHtmlV:(NSMutableString*)html fileLocation:(FileLocation)location
//{
//    NSString *filePath = [self dirPathForFileLocation:location] ;
//    NSString *relPath = [self relPathForFileLocation:location] ;
//    NSString *domId = [self domIdForFileLocation:location] ;
//
//    // filtra possibles paths nuls
//    if ( filePath == nil ) return ;
//
//    // si no es un directori ( es a sir si no acaba en "/") elimina l'ultim ( es a dir determina el directory del fitxer)
//    if ( ! [filePath hasSuffix:@"/"] )
//    {
//		filePath = [filePath stringByDeletingLastPathComponent] ;
//	}
//    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];  // treure'l del cicle
//    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
//    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
//    // iterem per cada fitxer en el directori
//	//NSArray *array = [[NSFileManager defaultManager] directoryContentsAtPath:filePath];
//	
//    NSFileManager *fileManager = [NSFileManager defaultManager] ;
//    NSArray *array = [fileManager contentsOfDirectoryAtPath:filePath error:NULL];
//    
//    int countedFiles = 0 ;
//    for ( NSString *fname in array ) 
//    {
//        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init] ; 
//    	/********* BUG !!! *********
//        // there is a bug with directoryContentsAtPath on iPhone OS 2.2 (works fine in simulator)
//        // it returns an array with NSString object in it even if the directory does not contain any children
//        ************/
//		//BOOL bugWorkAround = [fname isEqualToString:@"(null)"];
//		//if ( fname && !bugWorkAround )
//        //{
//            NSString *fullPath = [filePath stringByAppendingPathComponent:fname] ;
//            NSDictionary *fileDict = [fileManager attributesOfItemAtPath:fullPath error:NULL];
//        
//            
//        
//            // saltem els directoris
//            if ([[fileDict objectForKey:NSFileType] isEqualToString: NSFileTypeDirectory])
//            {
//                if ( ![filesModel() fileFullPathIsWrappedSource:fullPath] )
//                {
//                    continue;
//                }
////                if ( location != kFileLocationSources || [[fname pathExtension] caseInsensitiveCompare:@"hmipad"] != NSOrderedSame )
////                {
////                    fname = [fname stringByAppendingString:@"/"];
////                    continue ;
////                }
//            }
//            
//            // row start
//            if ( tableRowIndex++ % 2 == 0 ) [html appendString:@"<tr class=\"even\">"];
//            else [html appendString:@"<tr class=\"odd\">"];
//	 
//            // row start and file name data
//            NSString *escapedFile = [fname stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
//            [html appendFormat:@"<td><a href=\"%@%@\">%@</a></td>", relPath, escapedFile, fname];
//            
//            // size
//            unsigned long long size = [[fileDict objectForKey:NSFileSize] longLongValue] ;
//            //[html appendFormat:@"<td>%@</td>", [filesModel() fileSizeStrForSizeValue:size]] ;
//            [html appendFormat:@"<td>%@</td>", fileSizeStrForSizeValue(size)] ;
//	
//            //date modified
//            NSDate *modDateObj = [fileDict objectForKey:NSFileModificationDate];
//            NSString *modDate = [dateFormatter stringFromDate:modDateObj];
//            [html appendFormat:@"<td>%@</td>", modDate];
//            
//            // delete button and row end
//            [html appendFormat:@"<td> <input type='button' onclick='deleteFileInList(\"%@%@\",\"%@\", \"%@\");' "
//                                "name='submitButton' id='submitButton' value='%@' /> </td>",
//                                relPath, escapedFile, fname, domId, NSLocalizedString( @"Delete", nil )];
//            // row end
//            [html appendString:@"</tr>"];
//            
//            // incrementem contador
//            countedFiles += 1 ;
//		//}
//        [pool release] ;
//	}
//    
//    // si el directori no conte elements creem una fila informativa buida
//    if ( countedFiles == 0 )
//    {
//        [html appendString:@"<tr class=\"odd\"><td>"] ;
//        [html appendString:NSLocalizedString(@"(No Files)", nil )] ;
//        //[html appendString:@"</td><td>-</td><td>-</td><td></td></tr>"] ;
//        [html appendString:@"</td></tr>"] ;
//    }
//    
//    [dateFormatter release] ;
//}



//------------------------------------------------------------------------------------------------
//- (void)generateFileListAsHtml:(NSMutableString*)html fullPath:(NSString*)filePath relPath:(NSString*)relPath
- (void)generateFileListAsHtml:(NSMutableString*)html fileLocation:(FileLocation)location
{
//    NSString *filePath = [self dirPathForFileLocation:location] ;
    NSString *relPath = [self relPathForFileLocation:location] ;
    NSString *domId = [self domIdForFileLocation:location] ;
    
    FileCategory category = [self fileCategoryForFileLocation:location];
    NSArray *fileMDs = [filesModel().files filesMDArrayForCategory:category];
    

    int countedFiles = 0 ;
    for ( FileMD *fileMD in fileMDs )
    {
//        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init] ;
        @autoreleasepool
        {

            NSString *fname = fileMD.fileName;
            NSString *dateString = fileMD.fileDateString;
            NSString *sizeString = fileMD.fileSizeString;
        
            // row start
            if ( tableRowIndex++ % 2 == 0 ) [html appendString:@"<tr class=\"even\">"];
            else [html appendString:@"<tr class=\"odd\">"];
	 
            // row start and file name data
            NSString *escapedFile = [fname stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            if ( fileMD.isDisabled )
            //<font color=\"009900\">%@</font>
                [html appendFormat:@"<td><b>%@</b> (%@)</td>", fname, NSLocalizedString(@"In use", nil)];
            else
                [html appendFormat:@"<td><a href=\"%@%@\">%@</a></td>", relPath, escapedFile, fname];
            
            // size
            [html appendFormat:@"<td>%@</td>", sizeString] ;
	
            //date modified
            [html appendFormat:@"<td>%@</td>", dateString];
            
            // delete button and row end
            if ( fileMD.isDisabled )
                [html appendString:@"<td></td>"];
            else
                [html appendFormat:@"<td> <input type='button' onclick='deleteFileInList(\"%@%@\",\"%@\", \"%@\");' "
                            "name='submitButton' id='submitButton' value='%@' /> </td>",
                            relPath, escapedFile, fname, domId, NSLocalizedString( @"Delete", nil )];
            
            // row end
            [html appendString:@"</tr>"];
            
            // incrementem contador
            countedFiles += 1 ;
        }
       // [pool release] ;
	}
    
    // si el directori no conte elements creem una fila informativa buida
    if ( countedFiles == 0 )
    {
        [html appendString:@"<tr class=\"odd\"><td>"] ;
        [html appendString:NSLocalizedString(@"(No Files)", nil )] ;
        //[html appendString:@"</td><td>-</td><td>-</td><td></td></tr>"] ;
        [html appendString:@"</td></tr>"] ;
    }
}




//------------------------------------------------------------------------------------------------
- (HTTPDataResponse *)generateDirectoryListingWrapped:(BOOL)wrapped fileLocation:(FileLocation)location
{    
    // preparem la resposta en un NSMutableString
    NSMutableString *html = [[NSMutableString alloc] init];
    
    // inicialitzem l'index de files
    tableRowIndex = 0 ;
    
    // si ha d'estar encapsulat en HTML posa la capsalera
    if ( wrapped )
    {
        NSString *wrapId = @"docTable" ;
        [html appendString:@"<html><body><table id='"];
        if ( location == kFileLocationSources ) wrapId = @"sourceTable" ;
        if ( location == kFileLocationRecipes ) wrapId = @"recipeTable" ;
        if ( location == kFileLocationDatabases ) wrapId = @"databaseTable" ;
        [html appendString:wrapId] ;
        [html appendString:@"'>"] ;
    }
    
    [self generateFileListAsHtml:html fileLocation:location] ;
    
    // tanquem l'emboltori si cal
    if ( wrapped ) [html appendString:@"</table></body></html>"];
    
    // posem la resposta en un NSData
    NSData *browseData = [html dataUsingEncoding:NSUTF8StringEncoding];
    
    // emboliquem el NSData en un HTTPDataResponse i el tornem
    return [[HTTPDataResponse alloc] initWithData:browseData];
}




//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Class Methods
//////////////////////////////////////////////////////////////////////////////////////////////////




//------------------------------------------------------------------------------------------------
- (id)initWithAsyncSocket:(GCDAsyncSocket *)newSocket configuration:(HTTPConfig *)aConfig;
{
    if ( (self = [super initWithAsyncSocket:newSocket configuration:aConfig]) )
    {
    }
    return self ;
}



/*

- (id)initWithAsyncSocket:(AsyncSocket *)newSocket forServer:(HTTPServer *)myServer
{
    if ( (self = [super initWithAsyncSocket:newSocket forServer:myServer]) )
    {
     //   NSArray *loopModes = [[NSArray alloc] initWithObjects:NSRunLoopCommonModes, nil] ;
     //   [asyncSocket setRunLoopModes:loopModes] ;
     //   [loopModes release] ;
    }
    return self ;
}
*/


//------------------------------------------------------------------------------------------------
- (void)setPostSeparatorDataLength:(NSUInteger)length
{
	if ( length == 0 )
    {
    	//[postSeparatorData release],
         postSeparatorData = nil ;
    }
    else
    {
		if ( postSeparatorData == nil ) postSeparatorData = [[NSMutableData alloc] initWithLength:length] ;
        else [postSeparatorData setLength:length] ;
    }
    
    postSeparatorBytes = [postSeparatorData mutableBytes] ;
    postSeparatorLength = length ;
}

//------------------------------------------------------------------------------------------------
- (void)setPostContentDispositionPart:(NSString*)value
{
	if ( postContentDispositionPart == value ) return ;
   // [postContentDispositionPart release] ;
   // postContentDispositionPart = [value retain] ;
    
    postContentDispositionPart = value;
}

//------------------------------------------------------------------------------------------------
- (void)setPostContent:(NSString*)value
{
	if ( postContent == value ) return ;
//    [postContent release] ;
//    postContent = [value retain] ;
    
    postContent = value;
}

//------------------------------------------------------------------------------------------------
- (void)setPostFileHandle:(NSFileHandle*)value
{
	if ( postFileHandle == value ) return ;
//    [postFileHandle release] ;
//    postFileHandle = [value retain] ;

    postFileHandle = value;
}

//------------------------------------------------------------------------------------------------
//- (void)setPostDestinationPath:(NSString*)value
//{
//	if ( postDestinationPath == value ) return ;
//    [postDestinationPath release] ;
//    postDestinationPath = [value retain] ;
//}


- (void)setPostFileName:(NSString*)value
{
    if ( postFileName == value ) return;
//    [postFileName release];
//    postFileName = [value retain];
    
    postFileName = value;
}



/*
//------------------------------------------------------------------------------------------------
- (void)setPostFileName:(NSString*)value
{
	if ( postFileName == value ) return ;
    [postFileName release] ;
    postFileName = [value retain] ;
}
*/

//------------------------------------------------------------------------------------------------
- (void)dealloc
{
//    [postSeparatorData release];
//    [postContentDispositionPart release];
//    [postContent release] ;
//    [postFileHandle release];
//    [postFileName release];
//    [super dealloc] ;
}


////------------------------------------------------------------------------------------------------
//- (void)touchWithLocation:(FileLocation)location
//{
//	switch ( location )
//    {
//		case kFileLocationSources:
//            [filesModel() filesArrayTouchForCategory:kFileCategorySourceFile] ;
//    		[defaults() setShouldParseFiles:YES] ;
//            break ;
//            
//        case kFileLocationRecipes:
//            [filesModel() filesArrayTouchForCategory:kFileCategoryRecipe] ;
//            break ;
//    
//	    case kFileLocationDocuments:
//            [filesModel() filesArrayTouchForCategory:kFileCategoryAssetFile] ;
//    		break ;
//            
//        case kFileLocationCompanyLogo:
//	    	[filesModel() companyLogoFileTouch] ;
//            break ;
//            
//        case kFileLocationNone:
//        case kFileLocationResources:
//        case kFileLocationRoot:
//            break ;
//    }
//}
//

//------------------------------------------------------------------------------------------------
- (FileCategory)fileCategoryForFileLocation:(FileLocation)location
{
	switch ( location )
    {
		case kFileLocationSources:
            return kFileCategorySourceFile ;
            break ;
            
        case kFileLocationRecipes:
            return kFileCategoryRecipe ;
            break ;
    
	    case kFileLocationDocuments:
            return kFileCategoryAssetFile ;
    		break ;
            
        case kFileLocationDatabases:
            return kFileCategoryDatabase;
            break;
            
        case kFileLocationCompanyLogo:
            break ;
            
        case kFileLocationResources:
            return kFileCategoryRecipe;
            break;
            
        case kFileLocationNone:
        case kFileLocationRoot:
            break ;
    }
    
    return kFileCategoryUnknown;
}




//---------------------------------------------------------------------------------------------------
// torna una resposta de fitxer amb el Content-Type per defecte
- (HTTPFileResponse *)fileResponse:(NSString *)relPath
{
    NSString *filePath = [self filePathForURLRelPath:relPath] ;
    if ( [[NSFileManager defaultManager] fileExistsAtPath:filePath] )
    {
        id obj = [[HTTPFileResponse alloc] initWithFilePath:filePath forConnection:self] ;
		return obj ;
    }
    return nil ;
}

////---------------------------------------------------------------------------------------------------
//// torna una resposta de fitxer amb un Content-Type de 'application/octet-stream' 
//- (HTTPOctetStreamFileResponse *)downloadFileResponseV:(NSString *)relPath
//{
//    NSString *filePath = [self filePathForURLRelPath:relPath] ;
//    if ( [[NSFileManager defaultManager] fileExistsAtPath:filePath] )
//    {
//        id obj = [[[HTTPOctetStreamFileResponse alloc] initWithFilePath:filePath forConnection:self] autorelease] ;
//		return obj ;
//    }
//    return nil ;
//}

//---------------------------------------------------------------------------------------------------
// torna una resposta de fitxer amb un Content-Type de 'application/octet-stream' 
- (HTTPOctetStreamFileResponse *)downloadFileResponse:(NSString *)relPath
{
    NSString *filePath = [self filePathForURLRelPath:relPath] ;
    if ( [[NSFileManager defaultManager] fileExistsAtPath:filePath] )
    {
        if ( fileFullPathIsWrappedSource(filePath) )
        {
            [filesModel().files copyToTemporaryForFileFullPath:filePath error:nil];
            filePath = [filesModel().filePaths temporaryFilePathForFileName:[filePath lastPathComponent]];
        }
    
        id obj = [[HTTPOctetStreamFileResponse alloc] initWithFilePath:filePath forConnection:self] ;
		return obj ;
    }
    return nil ;
}


//---------------------------------------------------------------------------------------------------
// torna una resposta per indicar que tot continua bé 
- (HTTPDataResponse *)doHello
{
    // posem la resposta en un NSData
    NSString *helloStr = [[NSString alloc] initWithFormat:@"%@", @"hello"] ;
    NSData *helloIt = [helloStr dataUsingEncoding:NSUTF8StringEncoding];
    
    // emboliquem el NSData en un HTTPDataResponse i el tornem
    return [[HTTPDataResponse alloc] initWithData:helloIt];
}


////---------------------------------------------------------------------------------------------------
//// esborra el fitxer en el path especificat i torna el directory listing on hi
//// havia el fitxer
//- (HTTPDataResponse *)doDeleteV:(NSString *)relPath
//{
//	NSError *error = nil;
//    NSString *filePath = [self filePathForURLRelPath:relPath] ;
//	NSFileManager *fileManager = [NSFileManager defaultManager];
//	BOOL removed = [fileManager removeItemAtPath:filePath error:&error];  //gestioerror
//	
//	if ( error || (removed == NO) ) 
//    {
//		// aed wip error handling
//	}
//    
//    // com que hem esborrat un fitxer poden haver canviat coses
//    FileLocation location = [self fileLocationForURLRelPath:relPath] ;
//    [self touchWithLocation:location] ;
//   
//    //return [self generateSourceListingWrapped:NO] ;
//    return [self generateDirectoryListingWrapped:NO fileLocation:location] ;
//}


//---------------------------------------------------------------------------------------------------
// esborra el fitxer en el path especificat i torna el directory listing on hi
// havia el fitxer
- (HTTPDataResponse *)doDelete:(NSString *)relPath 
{
    FileLocation location = [self fileLocationForURLRelPath:relPath] ;
    FileCategory category = [self fileCategoryForFileLocation:location];
    NSString *fileName = [relPath lastPathComponent];
    
    [filesModel().files deleteFileWithFileName:fileName forCategory:category error:nil];
    [filesModel().files resetMDArrayForCategory:category];  // <-- necesari perque el refresc es crida immediatament
   
    return [self generateDirectoryListingWrapped:NO fileLocation:location] ;
}


//---------------------------------------------------------------------------------------------------
// executa la accio de carregar patrons i torna el directory listing arrel
- (HTTPDataResponse *)doLoadTemplates 
{	
    [filesModel() copyFileTemplates] ;    
    
    // com que potencialment hem creat fitxers poden haver canviat els sources  // tot això seria molt millor gestionar-ho amb el model
    //[self touchWithLocation:kFileLocationSources] ;
    
    //return [self generateSourceListingWrapped:NO] ;
    
    return [self generateDirectoryListingWrapped:NO fileLocation:kFileLocationSources] ;
}



///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Overiden methods
///////////////////////////////////////////////////////////////////////////////////////////////////


//---------------------------------------------------------------------------------------------------
/**
 * Returns whether or not the server will accept POSTs.
 * That is, whether the server will accept uploaded data for the given URI.
**/
- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
   {
    //NSLog1(@"Suports Method:%@ Path:%@", method, path) ;
    
    if ( [method isEqualToString:@"POST"] ) return YES ;
    return [super supportsMethod:method atPath:path] ;
   }


//---------------------------------------------------------------------------------------------------
/**
 * This method is called to get a response for a request.
 * You may return any object that adopts the HTTPResponse protocol.
 * The HTTPServer comes with two such classes: HTTPFileResponse and HTTPDataResponse.
 * HTTPFileResponse is a wrapper for an NSFileHandle object, and is the preferred way to send a file response.
 * HTTPDataResponse is a wrapper for an NSData object, and may be used to send a custom response.
**/
//- (NSObject<HTTPResponse> *)httpResponseForURI:(NSString *)path
- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)uri
{
    NSLog1(@"HTTPConnectionSubclass httpResponseForMethod:%@ Path:%@",method, uri);
	
	//NSData *requestData = [(NSData *)CFHTTPMessageCopySerializedMessage(request) autorelease];
	NSData *requestData = [request messageData] ;
    
    
    if ( DEBUGING )
    {
        NSString *requestStr = [[NSString alloc] initWithData:requestData encoding:NSUTF8StringEncoding];
        NSLog(@"\n\n=== Request ====================\n%@================================\n\n", requestStr);
    }
 
    // continua amb el procesament normal
	NSURL *url = [[NSURL alloc] initWithString:uri] ;
	NSString *query = [url query] ;
    //NSString *basePath = [[server documentRoot] path] ;
    NSString *relPath = [url path] ;
    //NSString *filePath = [basePath stringByAppendingString:relPath] ;
   
    NSLog1( @"HTTPConnectionSubclass httpResponseForMethod URL query: %@", query ) ;
    //NSLog1( @"HTTPConnectionSubclass httpResponseForMethod URL basePath: %@", basePath ) ;
    NSLog1( @"HTTPConnectionSubclass httpResponseForMethod URL relPath: %@", relPath ) ;
    //NSLog1( @"HTTPConnectionSubclass httpResponseForMethod URL filePath: %@", filePath ) ;
    
    // si el métode és un POST en procesa el final
    if ( [method isEqualToString:@"POST"] )
    {
		//[self endProcessPost] ;
        switch ( postResponseKind )
        {
        	case kPostResponseKindFile :
		        //return [self generateSourceListingWrapped:YES]; // torna el llistat empaquetat
                return [self generateDirectoryListingWrapped:YES fileLocation:kFileLocationSources] ;
            	break ;
                
            case kPostResponseKindRecipe :
                return [self generateDirectoryListingWrapped:YES fileLocation:kFileLocationRecipes] ;
            	break ;
                
            case kPostResponseKindDocument :
                return [self generateDirectoryListingWrapped:YES fileLocation:kFileLocationDocuments] ;
            	break ;
                
            case kPostResponseKindDatabase :
                return [self generateDirectoryListingWrapped:YES fileLocation:kFileLocationDatabases] ;
            	break ;
            
            case kPostResponseKindLogo :
            	return [self generateInteger:[defaults() hiddenCompanyLogo] wrapped:YES] ;
            	break ;
        }
    }

    // si el path conté un query conegut es gestiona independentment
	if ( query ) 
    {
        NSRange range ;
           
		range = [query rangeOfString: @"action=hello"];       
        if ( range.length > 0 ) return [self doHello];  
        
        if ( HMiPadDev )
        {
            range = [query rangeOfString: @"action=updateTable_sourceTable"];
            if ( range.length > 0 ) return [self generateDirectoryListingWrapped:NO fileLocation:kFileLocationSources];// torna la part que interessa
        
            range = [query rangeOfString: @"action=updateTable_recipeTable"];
            if ( range.length > 0 ) return [self generateDirectoryListingWrapped:NO fileLocation:kFileLocationRecipes];// torna la part que interessa

            range = [query rangeOfString: @"action=updateTable_docTable"];
            if ( range.length > 0 ) return [self generateDirectoryListingWrapped:NO fileLocation:kFileLocationDocuments];// torna la part que interessa
        
            range = [query rangeOfString: @"action=updateLogo"];
            if ( range.length > 0 ) return [self generateInteger:[defaults() hiddenCompanyLogo] wrapped:NO]; // torna la part que interessa
            
            range = [query rangeOfString: @"action=loadTemplates"];
            if ( range.length > 0 ) return [self doLoadTemplates];
        }
        
		range = [query rangeOfString: @"action=updateTable_databaseTable"];
        if ( range.length > 0 ) return [self generateDirectoryListingWrapped:NO fileLocation:kFileLocationDatabases];// torna la part que interessa
        
		range = [query rangeOfString: @"action=delete"];
        if ( range.length > 0 ) return [self doDelete:relPath];
         
		range = [query rangeOfString: @"action=download"];       
        if ( range.length > 0 ) return [self downloadFileResponse:relPath] ; 
        
        // Si arriba aqui es que el query no es conegut, però continuem per si algú mes vol identificar-lo
    }

    // el directori arrel i els que comencen per /resources/ els redirecciona cap al bundle
    //NSString *resourcePath = [[NSBundle mainBundle] resourcePath] ;
    /*
    if ( [relPath isEqualToString:@"/"] )
    {
        filePath = [resourcePath stringByAppendingPathComponent:NSLocalizedString(@"index.html",nil)] ;
        return [self fileResponse:filePath] ; 
    }
    
    if ( [relPath hasPrefix:ResourcesStr] )
    {
        filePath = [resourcePath stringByAppendingPathComponent:[relPath substringFromIndex:[ResourcesStr length]]] ;
        return [self fileResponse:filePath] ; 
    }
    
    // el reste de requests els tracta com una peticio de fitxer per download
    return [self downloadFileResponse:filePath] ;*/
    
    
    // alguns requests els tracta com una peticio de fitxer per download
    FileLocation location = [self fileLocationForURLRelPath:relPath] ;
    if ( location == kFileLocationSources || location == kFileLocationDocuments || location == kFileLocationDatabases )
    {
	    return [self downloadFileResponse:relPath] ;
    }
    
    // el reste de requests els tracta com un fitxer (kFileLocationCompanyLogo, kFileLocationResources, kFileLocationRoot)
    return [self fileResponse:relPath] ;
    
}


//---------------------------------------------------------------------------------------------------
/**
 * This method is called after receiving all HTTP headers, but before reading any of the request body.
**/
- (void)prepareForBodyWithSize:(UInt64)contentLength
{
    //NSLog1( @"prepareForBodyWithSize:%i", contentLength ) ;
    
	postHeaderOK = NO ;
    postContentKind = kPostContentKindNone ;
    postResponseKind = kPostResponseKindNone ;
    postContentLenghtCounter = 0 ;
    postContentLength = contentLength ;
    displayCompanyLogo = NO ;
    resetCompanyLogo = NO ;
    selectCompanyLogo = NO ;
}


//---------------------------------------------------------------------------------------------------
/**
 * This method is called to handle data read from a POST.
 * The given data is part of the POST body.
**/
//- (void)processDataChunk:(NSData *)postDataChunk

- (void)processBodyData:(NSData *)postDataChunk
{
	// Override me to do something useful with a POST.
	// If the post is small, such as a simple form, you may want to simply append the data to the request.
	// If the post is big, such as a file upload, you may want to store the file to disk.
	// 
	// Remember: In order to support LARGE POST uploads, the data is read in chunks.
	// This prevents a 50 MB upload from being stored in RAM.
	// The size of the chunks are limited by the POST_CHUNKSIZE definition.
	// Therefore, this method may be called multiple times for the same POST request.
    
    // Suportem posts amb un maxim de 1 filtxer, sempre al final del post
    
    // Les dades de un POST que conté *unicament* un fitxer per upload vindran el el
    // format seguent:

    // -----------------------------7d01ecf406a6\x0D\x0A
    // Content-Disposition: form-data; name="file";filename="C:\Inetpub\wwwroot\Upload\pic.gif"\x0D\x0A
    // Content-Type: image/gif\x0D\x0A
    // \x0D\x0A
    // (binary content)\x0D\x0A
    // -----------------------------7d01ecf406a6--(fi de fitxer)
    
    // Les dades de un post amb multiple contingut pot ser: (els salts de linea corresponen a "\x0D\x0A")
    
    // -----------------------------7d01ecf406a6
    // Content-Disposition: form-data; name="input_check"
    // 
    // on
    // -----------------------------7d01ecf406a6
    // Content-Disposition: form-data; name="input_password"
    // 
    // mypassword
    // -----------------------------7d01ecf406a6
    // Content-Disposition: form-data; name="input_text"
    // 
    // mytext
    // -----------------------------7d01ecf406a6
    // Content-Disposition: form-data; name="input_hidden"
    //
    // myhiddenvalue
    // -----------------------------7d01ecf406a6
    // Content-Disposition: form-data; name="fileaaa";
    // filename="C:\Inetpub\wwwroot\Upload\pic.gif"
    // Content-Type: image/gif
    //
    // (binary content)
    // -----------------------------7d01ecf406a6--(fi de fitxer)
    
    // Les dades amb un simple check mark amb "selection" com a nom poden ser:
    
    // -----------------------------1025921153510616708590357944
    // Content-Disposition: form-data; name="selection"
    //
    // on
    // -----------------------------1025921153510616708590357944--(fi de fitxer)
    
    // mirar aqui per mes informacio: http://www.15seconds.com/Issue/001003.htm


    // codi insertat aqui per efectes de depuració
    if ( DEBUGING == YES )
    {
        NSUInteger chunkLength = [postDataChunk length] ;
        const Byte *chunkPtr = [postDataChunk bytes] ;
        NSString *perDebug = [[NSString alloc] initWithBytes:chunkPtr length:chunkLength encoding:NSUTF8StringEncoding];
        NSLog( @"%@", perDebug ) ;
    }

	// el chunklenght el necesitarem més endevant
    NSUInteger chunkLength = [postDataChunk length] ;
    
    
    
    // si estem processant un fitxer simplement escivim, el separador ja l'eliminarem al final
    if ( postHeaderOK && ( postFileHandle || resetCompanyLogo || selectCompanyLogo) )
    {
    
        // *** PROCESAMENT DEL CHUNK ***
        // si estem processant una part de un fitxer
        [postFileHandle writeData:postDataChunk] ; // si el resetCompanyLogo o el selectCompanyLogo esta activat no fara res
    }
    else
    {
        
    const Byte *chunkPtr = [postDataChunk bytes] ;
    dataStartIndex = 0 ;
        
    // iterem en el chunk per separar el header de les dades o el separator data
    for (int i = 0; i < chunkLength ; i++)
    {
    
        // *** PROCESAMENT DEL HEADER ***
    	// si estem buscan un header anem per aqui
    	
        if ( postHeaderOK == NO )
        {
            // busquem fins que trobem un separador
            int l = 2 ;
            if ( i < chunkLength-l && memcmp( chunkPtr+i, "\x0D\x0A", l ) == 0 )
			{
                // volem extreure les dades des de l'ultima vegada fins ara
                const Byte *partPtr = chunkPtr + dataStartIndex ;
                int partLength = i - dataStartIndex ;
                
                // actualitzem l'index per apuntar a la propera part del header
                dataStartIndex = i + l;
                i += l - 1; // increment degut al \x0D\x0A (compensat en -1 per l'increment del for) 
                
                // si encara no tenim el postSeparator data es que el deu haver trobat ara
                // les dades corresponen al sepadador
                if ( postSeparatorData == nil )
                {
                    [self setPostSeparatorDataLength:partLength+l] ;
                    memcpy( postSeparatorBytes, "\x0D\x0A", l ) ;
                    memcpy( postSeparatorBytes+l, partPtr, partLength ) ;
                    continue ;  // contimuem amb el chunk
                }
                    
                // Procesem la part del header que hem identificat
                if ( partLength > 0 )
                {
                    // només ens interessa la part "Content-Disposition"
                    const int len = 19 ; 
                    if ( memcmp( partPtr, "Content-Disposition", len ) == 0 )
                    {
                        NSString *part = [[NSString alloc] initWithBytes:partPtr length:partLength encoding:NSUTF8StringEncoding];
                        [self setPostContentDispositionPart:part] ;
    
                        //NSLog1( @"HTTPConnectionSubClass postContentDispositionPart: %@", postContentDispositionPart );
                    }
                        
                    // aqui hi aniria el procesament d'altres parts (per exemple per identificar el tipus de contingut)
                    else
                    {
                        NSString *aPart = [[NSString alloc] initWithBytes:partPtr length:partLength encoding:NSUTF8StringEncoding];
                        //NSLog1( @"HTTPConnectionSubClass unidentifiedPart: %@", aPart );
                        (void)aPart;
                    }
                    continue ; // continuem amb el chunk
				}
                
                // si la longitud es cero vol dir que s'ha acabat el header, per tant
                // a partir d'ara venen dades i pot ser haurem de buscar el postSeparatorData
                // les dades poden ser un fitxer o un texte
                postHeaderOK = YES ;
                
                
                // determinem el tipus de contingut a partir del camp "name" en el postContentDispositionPart
                postContentKind = kPostContentKindNone ;
                NSRange nRange = [postContentDispositionPart rangeOfString:@"name="] ;
                if ( nRange.location != NSNotFound )
                {
                	NSString *namePortion = [postContentDispositionPart substringFromIndex:(nRange.location+nRange.length+1)];
                    if ( [namePortion hasPrefix:@"sourcefile"] ) postContentKind = kPostContentKindSource ;
                    else if ( [namePortion hasPrefix:@"recipefile"] ) postContentKind = kPostContentKindRecipe ;
                    else if ( [namePortion hasPrefix:@"documentfile"] ) postContentKind = kPostContentKindDocumentFile ; 
                    else if ( [namePortion hasPrefix:@"databasefile"] ) postContentKind = kPostContentKindDatabaseFile ;
                	else if ( [namePortion hasPrefix:@"logoselection"] ) postContentKind = kPostContentKindLogoSelection ;
                    else if ( [namePortion hasPrefix:@"logodata"] ) postContentKind = kPostContentKindLogoData ;
                	else if ( [namePortion hasPrefix:@"logofile"] ) postContentKind = kPostContentKindLogoFile ;
                }
			} // fi de comparacio amb \x0D\x0A
		} // fi ( postHeaderOK == NO )
        
        
        // *** PROCESAMENT DEL CONTINGUT ***
        // postHeaderOK es YES, vol dir que hem de buscar el postSeparator data 
        
        else 
        {
        	// si el tipus es un dels fitxers creem el fitxer amb les dades que quedin fins el final del chunk, 
        	// dataStartIndex està ja apuntant a les dades
        	// el nom del fitxer estara en el camp "filename=" del postContentDispositionPart
            // si tenim el resetCompanyLogo no fem ni cas del fitxer
            if ( postContentKind == kPostContentKindSource ||
                    postContentKind == kPostContentKindRecipe ||
                    postContentKind == kPostContentKindDocumentFile || 
                    postContentKind == kPostContentKindDatabaseFile ||
                    postContentKind == kPostContentKindLogoFile)
            {
                NSRange fRange = [postContentDispositionPart rangeOfString:@"filename="] ;
                if ( resetCompanyLogo == NO && selectCompanyLogo == NO && fRange.location != NSNotFound )  // si tenim el resetCompanyLogo no fem cas del fitxer
                {
                    NSString *fullPath = nil ;
                    NSString *fPortion = [postContentDispositionPart substringFromIndex:(fRange.location+fRange.length+1)];
                    fPortion = [fPortion substringToIndex:([fPortion length]-1)] ; // això ha de contenir el fitxer especificat sense cometes
                    fPortion = [[fPortion componentsSeparatedByString:@"\\"] lastObject] ; // vigilem per possibles '\' de camins de windows

                    NSString *file = fPortion ; //[fPortion stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
                    if ( [file length] )
                    {
                    	// si es un fitxer determinem el lloc de guardar en funcio del postContentKind
                        fullPath = [filesModel().filePaths temporaryFilePathForFileName:file];
                    	if ( postContentKind == kPostContentKindSource )
                        {
                            //[self setPostDestinationPath:[filesModel() fileFullPathForFileName:file forCategory:kFileCategorySourceFile]];
                            [self setPostFileName:file];
                            postFileLocation = kFileLocationSources ;
                            postResponseKind = kPostResponseKindFile ;
                    	}
                        else if ( postContentKind == kPostContentKindRecipe )
                        {
                            //[self setPostDestinationPath:[filesModel() fileFullPathForFileName:file forCategory:kFileCategoryRecipe]];
                            [self setPostFileName:file];
                            postFileLocation = kFileLocationRecipes ;
                            postResponseKind = kPostResponseKindRecipe ;
                        }
                        else if ( postContentKind == kPostContentKindDocumentFile )
                        {
                            //[self setPostDestinationPath:[filesModel() fileFullPathForFileName:file forCategory:kFileCategoryAssetFile]];
                            [self setPostFileName:file];
                            postFileLocation = kFileLocationDocuments ;
                            postResponseKind = kPostResponseKindDocument ;
                        }
                        else if ( postContentKind == kPostContentKindDatabaseFile )
                        {
                            //[self setPostDestinationPath:[filesModel() fileFullPathForFileName:file forCategory:kFileCategoryAssetFile]];
                            [self setPostFileName:file];
                            postFileLocation = kFileLocationDatabases ;
                            postResponseKind = kPostResponseKindDatabase ;
                        }
                        else if ( postContentKind == kPostContentKindLogoFile )
                        {
                            fullPath = [filesModel().filePaths temporaryLogoFilePath] ;
                            postFileLocation = kFileLocationCompanyLogo ;
                            postResponseKind = kPostResponseKindLogo ;
                        }
                    }
                    if ( [fullPath length] )
                    {
                        NSRange fileDataRange = { dataStartIndex, chunkLength - dataStartIndex };
            
                        NSData *initialFileData = [postDataChunk subdataWithRange:fileDataRange] ;
                        BOOL done = [[NSFileManager defaultManager] createFileAtPath:fullPath contents:initialFileData attributes:nil];
                        (void)done ;
                        [self setPostFileHandle:[NSFileHandle fileHandleForUpdatingAtPath:fullPath]] ;
                        [postFileHandle seekToEndOfFile] ;

                        NSLog1( @"HTTPConnectionSubClass done:%d filename: %@", done, filename );
                        NSLog1( @"HTTPConnectionSubClass postFileHandle: %@", postFileHandle );
                    }
                }
                
                // sortim del cicle doncs ja hem processat la part que toca del fitxer
                // nomes suportem posts amb com a molt un fitxer al final.
                // la resta de chunks del fitxer es procesaran directament.
                break ;
            }
        
        	// si no és un fitxer busquem fins que trobem el separador
            int l = postSeparatorLength ;
            if ( i < chunkLength-l && memcmp( chunkPtr+i, postSeparatorBytes, l ) == 0 )
			{
                const Byte *partPtr = chunkPtr + dataStartIndex ;
                int partLength = i - dataStartIndex ;
                
                // com que hem tobat el separador ara ens interesara tornat a buscar un header
                // actualitzem l'index per apuntar a la propera part del header
                postHeaderOK = NO ;
                dataStartIndex = i + l + 2 ;
                i += l + 2 - 1;  // increment degut al separatorLength, i al \x0D\x0A que hi ha despres del separatorLengh
                
                // agafem el contingut del post
                NSString *content = [[NSString alloc] initWithBytes:partPtr length:partLength encoding:NSUTF8StringEncoding];
                //NSArray *contents = [content componentsSeparatedByString:@","] ;
                //NSUInteger contentsCount = [contents count] ;
                //[self setPostContent:content] ;
                //[content release] ;
                
                // fem el que toqui en funcio del tipus de contingut
                switch ( postContentKind )
                {
	                case kPostContentKindLogoSelection: // aquesta part pot no arribar mai, lo qual vol dir displayCompanyLogo = NO tal com esta inicialitzat
                    	displayCompanyLogo = ( [content isEqualToString:@"on"] ) ;   
                    	break ;
                        
                	case kPostContentKindLogoData:  // aquesta part ha d'arribar sempre despres de kPostContentKindLogoSelection
                        [defaults() setHiddenCompanyLogo: !displayCompanyLogo ] ;
                    	postResponseKind = kPostResponseKindLogo ;
                        postFileLocation = kFileLocationCompanyLogo ;
                        resetCompanyLogo = ( [content isEqualToString:@"reset"] ) ;
                        selectCompanyLogo = ( [content isEqualToString:@"select"] ) ;
                    	break ;
                }
                if ( DEBUGING == YES ) NSLog( @"Post Content:%@", content ) ;
        	}
        }
	} // end for
    } // end if
    
	// *** PROCESAMENT FINAL DE L'ULTIM CHUNK ***
    // determinem si aquest es l'ultim chunck, i si ho és i estem processant un fitxer, eliminem el separador del final
    
    postContentLenghtCounter += chunkLength ;
    if ( postContentLenghtCounter >= postContentLength )
    {
    	if ( postFileHandle )
		{
			//NSMutableData* separatorData = [NSMutableData dataWithBytes:"\x0D\x0A" length:2];
			//[separatorData appendData:postSeparatorData];
			int l = [postSeparatorData length];
			int count = 1;	//number of times the separator shows up at the end of file data
		
			unsigned long long i ;
			for ( i = [postFileHandle offsetInFile] - l; i > 0; i--)
			{
				[postFileHandle seekToFileOffset:i];
				if ([[postFileHandle readDataOfLength:l] isEqualToData:postSeparatorData])
				{
					[postFileHandle truncateFileAtOffset:i];
					i -= l;
					if (--count == 0) break;
				}
			}
            
            if ( postFileLocation == kFileLocationCompanyLogo )
            {
                // si era un logo, hem de posar-lo al lloc i mida adient
            	[filesModel() makeFinalLogoFromScaledTemporaryLogo] ;
            }
            else
            {
                //[filesModel() moveFromTemporaryForFileFullPath:postDestinationPath error:nil];
                FileCategory category = [self fileCategoryForFileLocation:postFileLocation];
                
                BOOL addCopy = (postFileLocation == kFileLocationSources);
                [filesModel().files moveFromTemporaryToCategory:category forFile:postFileName addCopy:addCopy error:nil];
                [filesModel().files resetMDArrayForCategory:category];  // <-- necesari perque el refresc es crida immediatament
                
                //[filesModel() moveFromTemporaryToCategory:category forFile:postFileName error:nil];
            }
		
			//NSLog1(@"NewFileUploaded");
			//[[NSNotificationCenter defaultCenter] postNotificationName:@"NewFileUploaded" object:nil];
		}
        else if ( resetCompanyLogo )
        {
        	// copiar el logo de SweetWilliam dels resources al CompanyLogo
            [filesModel() resetcompanyLogo] ;
        }
        
        else if ( selectCompanyLogo )
        {
            [filesModel() selectcompanyLogo];
        }
        
        
        // actualitzem el model
        //if ( postFileHandle || resetCompanyLogo )
        //{
        //  [self touchWithLocation:postFileLocation] ;
        //}
	
    	// era l'ultim chunk per tant resetejem les variables
	    [self setPostSeparatorDataLength:0] ;
    	[self setPostContentDispositionPart:nil] ;
        [self setPostContent:nil] ;
    	[self setPostFileHandle:nil] ;
        //[self setPostDestinationPath:nil];
        [self setPostFileName:nil];
    	postFileLocation = kFileLocationNone ;
    }
    
}

////---------------------------------------------------------------------------------------------------
///**
// * This method is called to handle data read from a POST.
// * The given data is part of the POST body.
//**/
////- (void)processDataChunk:(NSData *)postDataChunk
//
//- (void)processBodyDataVVV:(NSData *)postDataChunk
//{
//	// Override me to do something useful with a POST.
//	// If the post is small, such as a simple form, you may want to simply append the data to the request.
//	// If the post is big, such as a file upload, you may want to store the file to disk.
//	// 
//	// Remember: In order to support LARGE POST uploads, the data is read in chunks.
//	// This prevents a 50 MB upload from being stored in RAM.
//	// The size of the chunks are limited by the POST_CHUNKSIZE definition.
//	// Therefore, this method may be called multiple times for the same POST request.
//    
//    // Suportem posts amb un maxim de 1 filtxer, sempre al final del post
//    
//    // Les dades de un POST que conté *unicament* un fitxer per upload vindran el el
//    // format seguent:
//
//    // -----------------------------7d01ecf406a6\x0D\x0A
//    // Content-Disposition: form-data; name="file";filename="C:\Inetpub\wwwroot\Upload\pic.gif"\x0D\x0A
//    // Content-Type: image/gif\x0D\x0A
//    // \x0D\x0A
//    // (binary content)\x0D\x0A
//    // -----------------------------7d01ecf406a6--(fi de fitxer)
//    
//    // Les dades de un post amb multiple contingut pot ser: (els salts de linea corresponen a "\x0D\x0A")
//    
//    // -----------------------------7d01ecf406a6
//    // Content-Disposition: form-data; name="input_check"
//    // 
//    // on
//    // -----------------------------7d01ecf406a6
//    // Content-Disposition: form-data; name="input_password"
//    // 
//    // mypassword
//    // -----------------------------7d01ecf406a6
//    // Content-Disposition: form-data; name="input_text"
//    // 
//    // mytext
//    // -----------------------------7d01ecf406a6
//    // Content-Disposition: form-data; name="input_hidden"
//    //
//    // myhiddenvalue
//    // -----------------------------7d01ecf406a6
//    // Content-Disposition: form-data; name="fileaaa";
//    // filename="C:\Inetpub\wwwroot\Upload\pic.gif"
//    // Content-Type: image/gif
//    //
//    // (binary content)
//    // -----------------------------7d01ecf406a6--(fi de fitxer)
//    
//    // Les dades amb un simple check mark amb "selection" com a nom poden ser:
//    
//    // -----------------------------1025921153510616708590357944
//    // Content-Disposition: form-data; name="selection"
//    //
//    // on
//    // -----------------------------1025921153510616708590357944--(fi de fitxer)
//    
//    // mirar aqui per mes informacio: http://www.15seconds.com/Issue/001003.htm
//
//
//    // codi insertat aqui per efectes de depuració
//    if ( DEBUGING == YES )
//    {
//        NSUInteger chunkLength = [postDataChunk length] ;
//        const Byte *chunkPtr = [postDataChunk bytes] ;
//        NSString *perDebug = [[NSString alloc] initWithBytes:chunkPtr length:chunkLength encoding:NSUTF8StringEncoding];
//        NSLog( @"%@", perDebug ) ;
//        [perDebug release] ;
//    }
//
//	// el chunklenght el necesitarem més endevant
//    NSUInteger chunkLength = [postDataChunk length] ;
//    
//    
//    
//    // si estem processant un fitxer simplement escivim, el separador ja l'eliminarem al final
//    if ( postHeaderOK && ( postFileHandle || resetCompanyLogo || selectCompanyLogo) )
//    {
//    
//        // *** PROCESAMENT DEL CHUNK ***
//        // si estem processant una part de un fitxer
//        [postFileHandle writeData:postDataChunk] ; // si el resetCompanyLogo o el selectCompanyLogo esta activat no fara res
//    }
//    else
//    {
//        
//    const Byte *chunkPtr = [postDataChunk bytes] ;
//    dataStartIndex = 0 ;
//        
//    // iterem en el chunk per separar el header de les dades o el separator data
//    for (int i = 0; i < chunkLength ; i++)
//    {
//    
//        // *** PROCESAMENT DEL HEADER ***
//    	// si estem buscan un header anem per aqui
//    	
//        if ( postHeaderOK == NO )
//        {
//            // busquem fins que trobem un separador
//            int l = 2 ;
//            if ( i < chunkLength-l && memcmp( chunkPtr+i, "\x0D\x0A", l ) == 0 )
//			{
//                // volem extreure les dades des de l'ultima vegada fins ara
//                const Byte *partPtr = chunkPtr + dataStartIndex ;
//                int partLength = i - dataStartIndex ;
//                
//                // actualitzem l'index per apuntar a la propera part del header
//                dataStartIndex = i + l;
//                i += l - 1; // increment degut al \x0D\x0A (compensat en -1 per l'increment del for) 
//                
//                // si encara no tenim el postSeparator data es que el deu haver trobat ara
//                // les dades corresponen al sepadador
//                if ( postSeparatorData == nil )
//                {
//                    [self setPostSeparatorDataLength:partLength+l] ;
//                    memcpy( postSeparatorBytes, "\x0D\x0A", l ) ;
//                    memcpy( postSeparatorBytes+l, partPtr, partLength ) ;
//                    continue ;  // contimuem amb el chunk
//                }
//                    
//                // Procesem la part del header que hem identificat
//                if ( partLength > 0 )
//                {
//                    // només ens interessa la part "Content-Disposition"
//                    const int len = 19 ; 
//                    if ( memcmp( partPtr, "Content-Disposition", len ) == 0 )
//                    {
//                        NSString *part = [[NSString alloc] initWithBytes:partPtr length:partLength encoding:NSUTF8StringEncoding];
//                        [self setPostContentDispositionPart:part] ;
//                        [part release] ;
//                        //NSLog1( @"HTTPConnectionSubClass postContentDispositionPart: %@", postContentDispositionPart );
//                    }
//                        
//                    // aqui hi aniria el procesament d'altres parts (per exemple per identificar el tipus de contingut)
//                    else
//                    {
//                        NSString *aPart = [[NSString alloc] initWithBytes:partPtr length:partLength encoding:NSUTF8StringEncoding];
//                        //NSLog1( @"HTTPConnectionSubClass unidentifiedPart: %@", aPart );
//                        [aPart release] ;
//                    }
//                    continue ; // continuem amb el chunk
//				}
//                
//                // si la longitud es cero vol dir que s'ha acabat el header, per tant
//                // a partir d'ara venen dades i pot ser haurem de buscar el postSeparatorData
//                // les dades poden ser un fitxer o un texte
//                postHeaderOK = YES ;
//                
//                
//                // determinem el tipus de contingut a partir del camp "name" en el postContentDispositionPart
//                postContentKind = kPostContentKindNone ;
//                NSRange nRange = [postContentDispositionPart rangeOfString:@"name="] ;
//                if ( nRange.location != NSNotFound )
//                {
//                	NSString *namePortion = [postContentDispositionPart substringFromIndex:(nRange.location+nRange.length+1)];
//                    if ( [namePortion hasPrefix:@"sourcefile"] ) postContentKind = kPostContentKindSource ;
//                    else if ( [namePortion hasPrefix:@"recipefile"] ) postContentKind = kPostContentKindRecipe ;
//                    else if ( [namePortion hasPrefix:@"documentfile"] ) postContentKind = kPostContentKindDocumentFile ; 
//                	else if ( [namePortion hasPrefix:@"logoselection"] ) postContentKind = kPostContentKindLogoSelection ;
//                    else if ( [namePortion hasPrefix:@"logodata"] ) postContentKind = kPostContentKindLogoData ;
//                	else if ( [namePortion hasPrefix:@"logofile"] ) postContentKind = kPostContentKindLogoFile ;
//                }
//			} // fi de comparacio amb \x0D\x0A
//		} // fi ( postHeaderOK == NO )
//        
//        
//        // *** PROCESAMENT DEL CONTINGUT ***
//        // postHeaderOK es YES, vol dir que hem de buscar el postSeparator data 
//        
//        else 
//        {
//        	// si el tipus es un dels fitxers creem el fitxer amb les dades que quedin fins el final del chunk, 
//        	// dataStartIndex està ja apuntant a les dades
//        	// el nom del fitxer estara en el camp "filename=" del postContentDispositionPart
//            // si tenim el resetCompanyLogo no fem ni cas del fitxer
//            if ( postContentKind == kPostContentKindSource ||
//                    postContentKind == kPostContentKindRecipe ||
//                    postContentKind == kPostContentKindDocumentFile || 
//                    postContentKind == kPostContentKindLogoFile)
//            {
//                NSRange fRange = [postContentDispositionPart rangeOfString:@"filename="] ;
//                if ( resetCompanyLogo == NO && selectCompanyLogo == NO && fRange.location != NSNotFound )  // si tenim el resetCompanyLogo no fem cas del fitxer
//                {
//                    NSString *filename = nil ;
//                    NSString *fPortion = [postContentDispositionPart substringFromIndex:(fRange.location+fRange.length+1)];
//                    fPortion = [fPortion substringToIndex:([fPortion length]-1)] ; // això ha de contenir el fitxer especificat sense cometes
//                    fPortion = [[fPortion componentsSeparatedByString:@"\\"] lastObject] ; // vigilem per possibles '\' de camins de windows
//
//                    NSString *file = fPortion ; //[fPortion stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
//                    if ( [file length] )
//                    {
//                    	// si es un fitxer determinem el lloc de guardar en funcio del postContentKind
//                    	if ( postContentKind == kPostContentKindSource )
//                        {
//                            //filename = [[filesModel() filesRootDirectoryForCategory:kFileCategorySourceFile] stringByAppendingPathComponent:file] ;
//                            filename = [filesModel() fileFullPathForFileName:file forCategory:kFileCategorySourceFile];
//                            postFileLocation = kFileLocationSources ;
//                            postResponseKind = kPostResponseKindFile ;
//                    	}
//                        else if ( postContentKind == kPostContentKindRecipe )
//                        {
//                            //filename = [[filesModel() filesRootDirectoryForCategory:kFileCategoryRecipe] stringByAppendingPathComponent:file] ;
//                            filename = [filesModel() fileFullPathForFileName:file forCategory:kFileCategoryRecipe];
//                            postFileLocation = kFileLocationRecipes ;
//                            postResponseKind = kPostResponseKindRecipe ;
//                        }
//                        else if ( postContentKind == kPostContentKindDocumentFile )
//                        {
//                            //filename = [[filesModel() filesRootDirectoryForCategory:kFileCategoryAssetFile] stringByAppendingPathComponent:file] ;
//                            filename = [filesModel() fileFullPathForFileName:file forCategory:kFileCategoryAssetFile];
//                            postFileLocation = kFileLocationDocuments ;
//                            postResponseKind = kPostResponseKindDocument ;
//                        }
//                        else if ( postContentKind == kPostContentKindLogoFile )
//                        {
//                        	//filename = [filesModel() companyLogoFilePath] ;   ///////////
//                            filename = [filesModel() temporaryLogoFilePath] ;
//                            postFileLocation = kFileLocationCompanyLogo ;
//                            postResponseKind = kPostResponseKindLogo ;
//                        }
//                    }
//                    if ( [filename length] )
//                    {
//                        NSRange fileDataRange = { dataStartIndex, chunkLength - dataStartIndex };
//            
//                        NSData *initialFileData = [postDataChunk subdataWithRange:fileDataRange] ;
//                        BOOL done = [[NSFileManager defaultManager] createFileAtPath:filename contents:initialFileData attributes:nil];
//                        (void)done ;
//                        [self setPostFileHandle:[NSFileHandle fileHandleForUpdatingAtPath:filename]] ;
//                        [postFileHandle seekToEndOfFile] ;
//
//                        NSLog1( @"HTTPConnectionSubClass done:%d filename: %@", done, filename );
//                        NSLog1( @"HTTPConnectionSubClass postFileHandle: %@", postFileHandle );
//                    }
//                }
//                
//                // sortim del cicle doncs ja hem processat la part que toca del fitxer
//                // nomes suportem posts amb com a molt un fitxer al final.
//                // la resta de chunks del fitxer es procesaran directament.
//                break ;
//            }
//        
//        	// si no és un fitxer busquem fins que trobem el separador
//            int l = postSeparatorLength ;
//            if ( i < chunkLength-l && memcmp( chunkPtr+i, postSeparatorBytes, l ) == 0 )
//			{
//                const Byte *partPtr = chunkPtr + dataStartIndex ;
//                int partLength = i - dataStartIndex ;
//                
//                // com que hem tobat el separador ara ens interesara tornat a buscar un header
//                // actualitzem l'index per apuntar a la propera part del header
//                postHeaderOK = NO ;
//                dataStartIndex = i + l + 2 ;
//                i += l + 2 - 1;  // increment degut al separatorLength, i al \x0D\x0A que hi ha despres del separatorLengh
//                
//                // agafem el contingut del post
//                NSString *content = [[NSString alloc] initWithBytes:partPtr length:partLength encoding:NSUTF8StringEncoding];
//                //NSArray *contents = [content componentsSeparatedByString:@","] ;
//                //NSUInteger contentsCount = [contents count] ;
//                //[self setPostContent:content] ;
//                //[content release] ;
//                
//                // fem el que toqui en funcio del tipus de contingut
//                switch ( postContentKind )
//                {
//	                case kPostContentKindLogoSelection: // aquesta part pot no arribar mai, lo qual vol dir displayCompanyLogo = NO tal com esta inicialitzat
//                    	displayCompanyLogo = ( [content isEqualToString:@"on"] ) ;   
//                    	break ;
//                        
//                	case kPostContentKindLogoData:  // aquesta part ha d'arribar sempre despres de kPostContentKindLogoSelection
//                        [defaults() setHiddenCompanyLogo: !displayCompanyLogo ] ;
//                    	postResponseKind = kPostResponseKindLogo ;
//                        postFileLocation = kFileLocationCompanyLogo ;
//                        resetCompanyLogo = ( [content isEqualToString:@"reset"] ) ;
//                        selectCompanyLogo = ( [content isEqualToString:@"select"] ) ;
//                    	break ;
//                }
//                if ( DEBUGING == YES ) NSLog( @"Post Content:%@", content ) ;
//                [content release] ;
//        	}
//        }
//	} // end for
//    } // end if
//    
//	// *** PROCESAMENT FINAL DE L'ULTIM CHUNK ***
//    // determinem si aquest es l'ultim chunck, i si ho és i estem processant un fitxer, eliminem el separador del final
//    
//    postContentLenghtCounter += chunkLength ;
//    if ( postContentLenghtCounter >= postContentLength )
//    {
//    	if ( postFileHandle )
//		{
//			//NSMutableData* separatorData = [NSMutableData dataWithBytes:"\x0D\x0A" length:2];
//			//[separatorData appendData:postSeparatorData];
//			int l = [postSeparatorData length];
//			int count = 1;	//number of times the separator shows up at the end of file data
//		
//			unsigned long long i ;
//			for ( i = [postFileHandle offsetInFile] - l; i > 0; i--)
//			{
//				[postFileHandle seekToFileOffset:i];
//				if ([[postFileHandle readDataOfLength:l] isEqualToData:postSeparatorData])
//				{
//					[postFileHandle truncateFileAtOffset:i];
//					i -= l;
//					if (--count == 0) break;
//				}
//			}
//            
//            // si era un logo, hem de posar-lo al lloc i mida adient
//            if ( postFileLocation == kFileLocationCompanyLogo )
//            {
//            	[filesModel() makeFinalLogoFromScaledTemporaryLogo] ;
//            }
//            
//		
//			//NSLog1(@"NewFileUploaded");
//			//[[NSNotificationCenter defaultCenter] postNotificationName:@"NewFileUploaded" object:nil];
//		}
//        else if ( resetCompanyLogo )
//        {
//        	// copiar el logo de SweetWilliam dels resources al CompanyLogo
//            [filesModel() resetcompanyLogo] ;
//        }
//        
//        
//        // actualitzem el model
//        //if ( postFileHandle || resetCompanyLogo )
//        //{
//        	[self touchWithLocation:postFileLocation] ;
//        //}
//	
//    	// era l'ultim chunk per tant resetejem les variables
//	    [self setPostSeparatorDataLength:0] ;
//    	[self setPostContentDispositionPart:nil] ;
//        [self setPostContent:nil] ;
//    	[self setPostFileHandle:nil] ;
//    	postFileLocation = kFileLocationNone ;
//    }
//    
//}



@end



