//
//  FileMD.m
//  HmiPad
//
//  Created by Joan Lluch on 13/04/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "FileMD.h"
#import "AppModelCommon.h"
#import "DDData.h"


@implementation FileMD

- (NSString*)fileDateString
{
    static NSDateFormatter *dateFormatter = nil;
    if ( dateFormatter == nil )
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    }
    
    NSDate *laterDate = [self laterDate];
    
    NSString *dateStr = [dateFormatter stringFromDate:laterDate];
    
    // alternatiu...
    //NSString *dateStr = [NSDateFormatter localizedStringFromDate:laterDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    
    return dateStr ;
}

- (NSDate*)laterDate
{
    NSDate *laterDate = _date;
    if ( _dateBin != nil )
        laterDate = [_date laterDate:_dateBin];
    
    return laterDate;
}

- (NSString*)fileSizeString
{
    NSString *result = nil;
    NSString *fileSizeStr = fileSizeStrForSizeValue( _fileSize );
    if ( _fileSizeBin == 0 )
    {
        result = fileSizeStr ;
    }
    else
    {
        NSString *fileSizeBinStr = fileSizeStrForSizeValue( _fileSizeBin );
        result = [NSString stringWithFormat:@"%@ - %@", fileSizeStr, fileSizeBinStr];
    }
    return result;
}

- (UIImage*)thumbnailImage
{
    if ( [_image isKindOfClass:[UIImage class]] )
        return _image;
        
    return nil;
}

- (NSString*)imageFullPath
{
    if ( [_image isKindOfClass:[NSString class]] )
        return _image;
        
    return nil;
}


- (NSString*)project
{
    NSString *projectID = [_projects lastObject];
    return projectID;
}

- (NSInteger)pendingRedemptions
{
    NSInteger used = [_redemptions count];
    NSInteger pending = _maxRedemptions-used;
    return pending;
}

@end


@implementation FileMD(updating)

+ (FileMD*)updatedFileMD:(FileMD*)fileMD forFileURL:(NSURL*)fUrl_ forCategory:(FileCategory)category
{
    NSURL *fUrl = [fUrl_ URLByStandardizingPath];

    NSNumber *fileIsDirectory = nil;
    [fUrl getResourceValue:&fileIsDirectory forKey:NSURLIsDirectoryKey error:nil];
    BOOL isDirectory = [fileIsDirectory boolValue];
        
    if ( isDirectory && category != kFileCategorySourceFile /*&& category != kFileCategoryRedeemedSourceFile*/ )
    {
        // saltem els directoris que no son source
        return nil;
    }
    
    if ( fileMD == nil )
        fileMD = [[FileMD alloc] init];
    
    fileMD.isDirectory = isDirectory;
    
    NSString *fullPath = [fUrl path];
    NSString *fileName = [fUrl lastPathComponent];
    fileMD.fullPath = fullPath;
    fileMD.fileName = fileName;
    
    // aqui crear el identificador
    if ( category == kFileCategoryAssetFile )
    {
        NSData *data = [fileName dataUsingEncoding:NSUTF8StringEncoding];
        NSString *identifier = [data hexStringValue];
        fileMD.identifier = identifier;
    }
    
    if ( (category == kFileCategorySourceFile /*|| category == kFileCategoryRedeemedSourceFile*/) &&
        [[fUrl pathExtension] isEqualToString:SWFileExtensionWrapp] )
    {
        // part binaria
        
        NSDate *binFileDate = nil;
        NSNumber *binarySize = nil;
        
        NSURL *binaryUrl = [fUrl URLByAppendingPathComponent:SWFileKeyWrappBinary];
        [binaryUrl getResourceValue:&binarySize forKey:NSURLFileSizeKey error:nil];
        fileMD.fileSizeBin = [binarySize unsignedLongLongValue];
        [binaryUrl getResourceValue:&binFileDate forKey:NSURLContentModificationDateKey error:nil];
        fileMD.dateBin = binFileDate;
        
        // part simbolica
        
        NSDate *symbolicFileDate = nil;
        NSNumber *symbolicSize = nil;
        
        NSString *symbolicPathComponent = HMiPadDev?SWFileKeyWrappSymbolic:SWFileKeyWrappEncryptedSymbolic;
        
        NSURL *simbolicUrl = [fUrl URLByAppendingPathComponent:symbolicPathComponent];
        [simbolicUrl getResourceValue:&symbolicSize forKey:NSURLFileSizeKey error:nil];
        fileMD.fileSize = [symbolicSize unsignedLongLongValue];
        [simbolicUrl getResourceValue:&symbolicFileDate forKey:NSURLContentModificationDateKey error:nil];
        fileMD.date = symbolicFileDate;
        
        NSURL *thumbnailUrl = [fUrl URLByAppendingPathComponent:SWFileKeyWrappThumbnail];
        NSString *thumbnailFullPath = [thumbnailUrl path];
        fileMD.image = thumbnailFullPath;
    }
    
    else
    {
        NSDate *fileDate = nil;
        [fUrl getResourceValue:&fileDate forKey:NSURLContentModificationDateKey error:nil];
        fileMD.date = fileDate;
    
        NSNumber *fileSize = nil;
        [fUrl getResourceValue:&fileSize forKey:NSURLFileSizeKey error:nil];
        fileMD.fileSize = [fileSize unsignedLongLongValue];

        if ( fileExtensionIsImage(fileName) )
        {
            fileMD.image = fullPath;
        }
        else fileMD.image = nil;  // <-- No suportat per RedeemedAssets
    }

    return fileMD;
}

@end

