//
//  SWFileManager.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/3/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

//#import "SWFileManager.h"
//#import "NSFileManager+Directories.h"
//
//#define CACHE_PROJECTS @"Projects"
//#define CACHE_SCREENSHOTS @"ScreenShots"
//#define CACHE_IMAGES @"Images"
//
//@implementation SWFileManager
//
//+ (SWFileManager*)defaultManager
//{
//    static SWFileManager *instance = nil;
//    
//    if (!instance) {
//        instance = [[SWFileManager alloc] init];
//    }
//    return instance;
//}
//
//- (id)init
//{
//    self = [super init];
//    if (self) {
//        
//    }
//    return self;
//}
//
//- (NSURL*)urlForRootDirectory:(SWRootDirectory)rootDirectory
//{
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    
//    switch (rootDirectory) {
//        case SWRootDirectoryCache:
//            return [fileManager applicationCacheDirectoryURL];
//            break;
//            
//        case SWRootDirectoryDocuments:
//            break;
//            
//        case SWRootDirectoryLibrary:
//            break;
//            
//        default:
//            break;
//    }
//    
//    return nil;
//}
//
//
//- (NSURL*)urlForDocumentCacheDirectory:(SWDocumentCacheDirectory)docDir documentIdentifier:(NSString*)identifier
//{
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//        
//    NSURL *root = [[self urlForRootDirectory:SWRootDirectoryCache] URLByAppendingPathComponent:CACHE_PROJECTS isDirectory:YES];
//    root = [root URLByAppendingPathComponent:identifier isDirectory:YES];
//    [fileManager createDirectoryAtURL:root withIntermediateDirectories:YES attributes:nil error:nil];    
//    
//    NSURL *url = nil;
//    switch (docDir) 
//    {
//        case SWDocumentCacheDirectoryRoot:
//            url = root;
//            break;
//            
//        case SWDocumentCacheDirectoryScreenShots:
//            url = [root URLByAppendingPathComponent:CACHE_SCREENSHOTS isDirectory:YES];
//            break;
//            
//        case SWDocumentCacheDirectoryImages:
//            url = [root URLByAppendingPathComponent:CACHE_IMAGES isDirectory:YES];
//            break;
//            
//        default:
//            break;
//    }
//    
//    [fileManager createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:nil];
//    return url;
//}
//
//@end
//
//@implementation SWDocumentModel (FileManager)
//
//- (NSURL*)urlForDocumentCacheDirectory:(SWDocumentCacheDirectory)directory
//{    
//    return [[SWFileManager defaultManager] urlForDocumentCacheDirectory:directory documentIdentifier:self.uuid];
//}
//
//@end
