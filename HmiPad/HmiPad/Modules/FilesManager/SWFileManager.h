//
//  SWFileManager.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/3/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 
 ------ ESTRUCTURA DOCUMENTS ------
 
 -> ApplicationFolder
        |
        |-> [...] (other folders)
        |-> Documents (user editable folder)
        |       |
        |       |-> Projects (symbolic projects, for importing/exporting)
        |       |-> Pictures (user images)
        |               |
        |               |-> Folder1 (user defined folders)
        |               |-> Folder2 
        |               |-> Folder3
        |               |-> ...
        |
        |-> Library
        |       |
        |       |-> com.sweetwilliamsl.HmiPad
        |               |
        |               |-> Projects (binary projects, for execution)
        |               |-> Pictures (system pictures)
        |                       |
        |                       |-> Wallpapers
        |                       |-> ItemPictures
        |                               |
        |                               |-> Foler1
        |                               |-> Foler2
        |                               |-> Foler3
        |                               |-> ...
        |
        |-> Cache
                |
                |-> com.sweetwilliamsl.HmiPad
                        |
                        |->Projects
                                |
                                |-> <Identifier>
                                        |
                                        |-> ScreenShots
                                        |-> Images
 
*/

//typedef enum {
//    SWRootDirectoryDocuments,
//    SWRootDirectoryLibrary,
//    SWRootDirectoryCache,
//} SWRootDirectory;
//
//typedef enum {
//    SWDocumentCacheDirectoryRoot,
//    SWDocumentCacheDirectoryScreenShots,
//    SWDocumentCacheDirectoryImages,
//} SWDocumentCacheDirectory;
//
//@interface SWFileManager : NSObject
//
//+ (SWFileManager*)defaultManager;
//
//- (NSURL*)urlForRootDirectory:(SWRootDirectory)rootDirectory;
//- (NSURL*)urlForDocumentCacheDirectory:(SWDocumentCacheDirectory)docDir documentIdentifier:(NSString*)identifier;
//
//@end
//
//
//// --- Category for DocumentMolder Folder Manipulation --- //
//
//#warning a deprecar
//
//#import "SWDocumentModel.h"
//
//@interface SWDocumentModel (FileManager)
//
//- (NSURL*)urlForDocumentCacheDirectory:(SWDocumentCacheDirectory)directory;
//
//@end
