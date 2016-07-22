//
//  AppModelDocument.h
//  HmiPad
//
//  Created by Joan Lluch on 31/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

//#import "AppModel.h"

#import "AppModel.h"
#import "FileMD.h"

@class AppModelDocument;
@class SWDocument;

@protocol AppModelDocumentObserver<NSObject>

@optional

// current document
- (void)appFilesModelCurrentDocumentChange:(AppModelDocument*)filesDocument;
- (void)appFilesModelCurrentDocumentNameChange:(AppModelDocument*)filesDocument;

- (void)appFilesModelCurrentDocumentFileMDWillChange:(AppModelDocument*)filesDocument;
- (void)appFilesModelCurrentDocumentFileMDDidChange:(AppModelDocument*)filesDocument;

- (void)appFilesModel:(AppModelDocument*)filesDocument document:(SWDocument*)document didSaveWithSuccess:(BOOL)success;
- (void)appFilesModel:(AppModelDocument*)filesDocument document:(SWDocument*)document didCloseWithSuccess:(BOOL)success;

- (void)appFilesModel:(AppModelDocument*)filesDocument willOpenDocumentName:(NSString*)name;
- (void)appFilesModel:(AppModelDocument*)filesDocument document:(SWDocument*)document didOpenWithError:(NSError*)error;

@end




@interface AppModelDocument : NSObject
{
    __weak AppModel *_filesModel;
    NSMutableArray *_observers; // List of observers
//    dispatch_queue_t _dQueue;
//    const char *_queueKey ; // key for the dispatch queue
//    void *_queueContext ; // context for the dispatch queue
}

- (void)addObserver:(id<AppModelDocumentObserver>)observer;
- (void)removeObserver:(id<AppModelDocumentObserver>)observer;

- (id)initWithLocalFilesModel:(AppModel*)filesModel;
//- (void)setDispatchQueue:(dispatch_queue_t)dQueue key:(const char *)key;  // <-- call on initialization

@property (nonatomic, readonly) SWDocument *currentDocument;
@property (nonatomic, readonly) FileMD *currentDocumentFileMD;

- (NSString*)currentDocumentShortName;
- (BOOL)projectUserEnabled;

- (NSInteger)currentDocumentFileMDIndex;
- (void)resetCurrentDocumentFileMD;
- (void)refreshCurrentDocumentFileMD;

- (void)addNewEmptyDocument;
- (NSString*)defaultNameForNewProject;

//- (void)openDocument;
- (void)openDocumentWithCompletion:(void (^)(BOOL success))completion;
- (void)closeDocumentWithCompletion:(void (^)(BOOL success))completion;
- (void)saveDocumentWithCompletion:(void (^)(BOOL success))completion;
//- (void)setUnsavedChangesForStoredValues;
- (void)duplicateProject;

@end
