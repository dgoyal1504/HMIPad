//
//  SWFileRepresentation.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/12/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import "SWFileRepresentation.h"
#import "NSFileManager+Directories.h"

@interface SWFileRepresentation (Private)

- (void)_moveFileToiCloudWithCompletion:(void (^)(BOOL success))completion;
- (void)_moveFileToLocalWithCompletion:(void (^)(BOOL success))completion;

@end

@implementation SWFileRepresentation

@synthesize filename = _filename;
@synthesize url = _url;
@synthesize metadataItem = _metadataItem;
@dynamic isFileIniCloud;

- (id)initWithFileName:(NSString *)filename url:(NSURL *)url
{
    self = [super init];
    if (self) {
        _filename = filename;
        _url = url;
    }
    return self;
}

#pragma mark - Properties

- (BOOL)isFileIniCloud
{
    return [[NSFileManager defaultManager] isUbiquitousItemAtURL:_url];
}

#pragma mark - Main Methods

- (void)moveToiCloudWithCompletion:(void (^)(BOOL success))completion
{
    
    [self _moveFileToiCloudWithCompletion:completion];
}

- (void)moveToLocalStorageWithCompletion:(void (^)(BOOL success))completion
{
    [self _moveFileToLocalWithCompletion:completion];
}

- (void)deleteFile
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        [fileCoordinator coordinateWritingItemAtURL:_url 
                                            options:NSFileCoordinatorWritingForDeleting 
                                              error:nil 
                                         byAccessor:^(NSURL *writingURL) {
                                             NSFileManager *fileManager = [[NSFileManager alloc] init];
                                             [fileManager removeItemAtURL:writingURL error:nil];
                                         }];
    });
}

- (void)prepareFileContentWithCompletion:(void (^)(BOOL succeess))completion
{
    completion(YES);
}

@end

@implementation SWFileRepresentation (Private)

- (void)_moveFileToiCloudWithCompletion:(void (^)(BOOL success))completion
{    
    if (self.isFileIniCloud) {
        NSLog(@"Current file already in iCloud.");
        return;
    }
    
    NSURL *sourceURL = _url;
    NSURL *destinationURL = [[[NSFileManager defaultManager] iCloudDocumentsDirectoryURL] URLByAppendingPathComponent:_filename];
    
    dispatch_queue_t q_default;
    q_default = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(q_default, ^{
        NSFileManager *fileManager = [[NSFileManager alloc] init]; 
        NSError *error = nil;
        BOOL success = [fileManager setUbiquitous:YES itemAtURL:sourceURL destinationURL:destinationURL error:&error];
        
        dispatch_queue_t q_main = dispatch_get_main_queue();
        dispatch_async(q_main, ^{
            if (success) {
                _url = destinationURL;
                
                NSLog(@"File moved to iCloud: %@", _filename);
            } else {
                NSLog(@"Couldn't move file to iCloud: %@", _filename);
            }
            
            if (completion) {
                completion(success);
            }
        });
    });
}

- (void)_moveFileToLocalWithCompletion:(void (^)(BOOL success))completion
{    
    if (!self.isFileIniCloud) {
        NSLog(@"Current file already in LocalStorage.");
        return;
    }
    
    NSURL *sourceURL = _url;
    NSURL *destinationURL = [[[NSFileManager defaultManager] localDocumentsDirectoryURL] URLByAppendingPathComponent:_filename];
    
    dispatch_queue_t q_default;
    q_default = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(q_default, ^{
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSError *error = nil;
        BOOL success = [fileManager setUbiquitous:NO itemAtURL:sourceURL destinationURL:destinationURL error:&error];
        
        dispatch_queue_t q_main;
        q_main = dispatch_get_main_queue();
        dispatch_async(q_main, ^{
            if (success) {
                _url = destinationURL;
                
                NSLog(@"File moved to local storage: %@", _filename);
            } else {
                NSLog(@"Could'nt move file to local storage: %@", _filename);
            }
            
            if (completion) {
                completion(success);
            }
        });
    });
}

@end