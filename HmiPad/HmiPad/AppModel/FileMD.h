//
//  FileMD.h
//  HmiPad
//
//  Created by Joan Lluch on 13/04/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AppModelCategories.h"

@interface FileMD : NSObject

//@property (nonatomic) UInt32 projectId;
@property (nonatomic) UInt32 userId;
@property (nonatomic) NSString *ownerId;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) id image;   // pot ser un UIImage o un NSString
@property (nonatomic, strong) NSString *fullPath;   // pot ser un UIImage o un NSString
- (UIImage*)thumbnailImage;
- (NSString*)imageFullPath;
@property (nonatomic, strong) NSString *identifier;   // en el cas de codis d'activacio conte el identificador del projecte
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *remoteUrl;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *dateBin;
- (NSString*)fileDateString;
- (NSDate*)laterDate;
@property (nonatomic) unsigned long long fileSize;
@property (nonatomic) unsigned long long fileSizeBin;
- (NSString*)fileSizeString;
@property (nonatomic) BOOL isDirectory;
@property (nonatomic) BOOL isDisabled;

// per projectes
@property (nonatomic, strong) NSArray *files;

// per activation codes
@property (nonatomic, strong) NSString *accessCode;
@property (nonatomic, strong) NSString *productSKU;
@property (nonatomic, strong) NSString *productInfo;
@property (nonatomic, assign) NSInteger maxProjects;
@property (nonatomic, assign) NSInteger maxRedemptions;
@property (nonatomic, strong) NSArray *redemptions;
- (NSInteger)pendingRedemptions;
@property (nonatomic, strong) NSArray *projects;
- (NSString*)project;

// per redemptions
@property (nonatomic, strong) NSString *deviceIdentifier;

@end


@interface FileMD(updating)

+ (FileMD*)updatedFileMD:(FileMD*)fileMD forFileURL:(NSURL*)fUrl_ forCategory:(FileCategory)category;

@end


