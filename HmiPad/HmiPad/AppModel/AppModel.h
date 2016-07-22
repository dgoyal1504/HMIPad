//
//  AppModel.h
//  HMiPad
//
//  Created by Joan on 08/11/12.
//  Copyright 2012 SweetWilliam, S.L. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "AppModelCommon.h"
#import "AppModelCategories.h"


#define UseCloudKit true
#if UseCloudKit
@import CloudKit;
#endif

@class AppModelFilesEx;
@class AppModelFilePaths;
@class AppModelFileServer;
@class AppModelDocument;
@class AppModelSource;
@class AppModelRecipeSheet;
@class AppModelDatabase;
@class AppModelImage;
@class AppModelActivationCodes;
@class AppModelDownloadExamples;



@interface AppModel : NSObject // <ExpressionHolder>
{
    // cua serial
//	dispatch_queue_t _dQueue;
//    const char *_queueKey ; // key for the dispatch queue
    void *_queueContext ; // context for the dispatch queue
}


// propietats
@property (nonatomic, readonly) dispatch_queue_t dQueue;
@property (nonatomic, readonly) const char *queueKey;

// propietats
@property (nonatomic, readonly) AppModelFilesEx *files;
@property (nonatomic, readonly) AppModelFilePaths *filePaths;
@property (nonatomic, readonly) AppModelFileServer *fileServer;
@property (nonatomic, readonly) AppModelDocument *fileDocument;
@property (nonatomic, readonly) AppModelSource *fileSource;
@property (nonatomic, readonly) AppModelRecipeSheet *amRecipeSheet;
@property (nonatomic, readonly) AppModelDatabase *amDatabase;
@property (nonatomic, readonly) AppModelImage *amImage;
@property (nonatomic, readonly) AppModelActivationCodes *amActivationCodes;
@property (nonatomic, readonly) AppModelDownloadExamples *amDownloadExamples;


// Directories
- (BOOL)projectDirectoryExists ;
- (BOOL)maybeCreateAuxiliarDirectories ;
- (BOOL)createApplicationSupportDirectory;
- (BOOL)createFilesDirectory;
- (BOOL)copyFileTemplates;
- (BOOL)deleteFileTemplates;

// Auxiliars per normalitzar noms de projectes
- (NSString*)shrinkProjectName:(NSString *)longName forCategory:(FileCategory)category;
- (NSString*)expandProjectName:(NSString *)shortName forCategory:(FileCategory)category;


// variable per indicar que un OEM no s'ha portat bé (per exemple si no ha pagat)
@property (nonatomic, readonly) BOOL badOEM ;
- (void) setBadOEM ;

// company logo
- (void)companyLogoEnable:(BOOL)enable ;
- (void)companyLogoFileTouch ;
- (void)resetcompanyLogo;
- (void)selectcompanyLogo;
- (void)makeFinalLogoFromScaledTemporaryLogo ;


// cloudKit
#if UseCloudKit
- (void)resetCkContainer;
- (CKDatabase *)ckDatabase;
- (CKContainer*)ckContainer;
#endif

@end


extern AppModel *filesModel(void) ;
extern void filesModel_release(void) ;









