//
//  NSFileManager+Directories.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/12/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import "NSFileManager+Directories.h"

@implementation NSFileManager (Directories)

//- (NSURL*)localDocumentsDirectoryURL
//{
//    static NSURL *localDocumentsDirectoryURL = nil;
//    if (localDocumentsDirectoryURL == nil) {
//        NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//        NSURL *documentsDirectory = [NSURL fileURLWithPath:documentsDirectoryPath];
//        
//        localDocumentsDirectoryURL = [documentsDirectory URLByAppendingPathComponent:@"localStorage" isDirectory:YES];
//        localDocumentsDirectoryURL = [documentsDirectory URLByAppendingPathComponent:@"" isDirectory:YES];   // JLZ - Temporal !
//        
//        NSError *error = nil;
//        BOOL succeed = [[NSFileManager defaultManager] createDirectoryAtURL:localDocumentsDirectoryURL withIntermediateDirectories:YES attributes:nil error:&error];
//        
//        if (!succeed || error) {
//            NSLog(@"[8fk234] Error creating localStorage directory: %@", error.localizedDescription);
//        }
//    }
//    return localDocumentsDirectoryURL;
//}
//
//- (NSURL*)iCloudDocumentsDirectoryURL
//{
//    static NSURL *iCloudDocumentsDirectoryURL = nil;
//    if (iCloudDocumentsDirectoryURL == nil) {
//        NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//        NSURL *documentsDirectory = [NSURL fileURLWithPath:documentsDirectoryPath];
//        
//        iCloudDocumentsDirectoryURL = [documentsDirectory URLByAppendingPathComponent:@"iCloud" isDirectory:YES];
//        
//        NSError *error = nil;
//        BOOL succeed = [[NSFileManager defaultManager] createDirectoryAtURL:iCloudDocumentsDirectoryURL withIntermediateDirectories:YES attributes:nil error:&error];
//        
//        if (!succeed || error) {
//            NSLog(@"[0alfkg] Error crerating iCloud directory: %@", error.localizedDescription);
//        }
//    }
//    
//    return iCloudDocumentsDirectoryURL;
//}
//
//- (NSURL*)applicationCacheDirectoryURL
//{
//    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
//    return [url URLByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier] isDirectory:YES];
//}
//
//- (NSURL*)pageScreenShotsDirectoryURL
//{
//    NSFileManager *fileManager = self;
//    
//    NSURL *url = [[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] objectAtIndex:0];
//    
//    NSURL *directory = [url URLByAppendingPathComponent:@"screenShots" isDirectory:YES];
//    
//    [fileManager createDirectoryAtURL:directory withIntermediateDirectories:YES attributes:nil error:nil];
//
//    return directory;
//}

@end
