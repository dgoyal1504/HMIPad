//
//  SWFileRepresentation.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/12/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWFileRepresentation : NSObject

- (id)initWithFileName:(NSString*)filename url:(NSURL*)url;

@property (strong, nonatomic) NSString *filename;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSMetadataItem *metadataItem;

- (void)moveToiCloudWithCompletion:(void (^)(BOOL success))completion;
- (void)moveToLocalStorageWithCompletion:(void (^)(BOOL success))completion;

@property (readonly) BOOL isFileIniCloud;

- (void)deleteFile;

@end
