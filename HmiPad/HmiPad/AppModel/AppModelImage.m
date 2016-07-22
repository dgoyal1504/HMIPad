//
//  AppModel+ImageManager.m
//  HmiPad
//
//  Created by Joan Lluch on 31/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "AppModelImage.h"

#import "AppModelFilePaths.h"

#import "SWImageManager.h"

@implementation AppModelImage


- (id)initWithLocalFilesModel:(AppModel*)filesModel
{
    self = [super init];
    if ( self )
    {
        _filesModel = filesModel;
        _imageManager = [SWImageManager defaultManager];
        [_imageManager setDispatchQueue:_filesModel.dQueue key:_filesModel.queueKey];
    }
    return self;
}

//- (void)setDispatchQueue:(dispatch_queue_t)dQueue key:(const char *)key
//{
//    [_imageManager setDispatchQueue:dQueue key:key];
//}


// imatges en la catche general

- (void)getOriginalImageWithName:(NSString*)imageName completionBlock:(void (^)(UIImage* image))completionBlock
{
    //[self getOriginalImageWithName:imageName inDocumentName:nil completionBlock:completionBlock];
    [self getImageWithName:imageName inDocumentName:nil size:CGSizeZero contentMode:UIViewContentModeCenter completionBlock:completionBlock];
}


- (void)getImageWithName:(NSString*)imageName size:(CGSize)size
    contentMode:(UIViewContentMode)contentMode completionBlock:(void (^)(UIImage* image))completionBlock
{
    [self getImageWithName:imageName inDocumentName:nil size:size contentMode:contentMode completionBlock:completionBlock];
}

// imatges embegudes en un document

- (void)getOriginalImageWithName:(NSString*)imageName inDocumentName:(NSString*)documentName completionBlock:(void (^)(UIImage* image))completionBlock
{
    //[self getImageWithName:imageName inDocumentName:documentName size:CGSizeZero contentMode:UIViewContentModeCenter completionBlock:completionBlock];
    
    [self getImageWithName:imageName inDocumentName:documentName size:CGSizeZero
        contentMode:UIViewContentModeCenter contentScale:0 completionBlock:completionBlock];
}


- (void)getImageWithName:(NSString*)imageName inDocumentName:(NSString*)documentName size:(CGSize)size
    contentMode:(UIViewContentMode)contentMode completionBlock:(void (^)(UIImage* image))completionBlock
{
    [self getImageWithName:imageName inDocumentName:documentName size:size contentMode:contentMode
        contentScale:0 completionBlock:completionBlock];
}


- (void)getOriginalImageWithName:(NSString*)imageName inDocumentName:(NSString*)documentName
    contentScale:(CGFloat)scale completionBlock:(void (^)(UIImage* image))completionBlock
{
    [self getImageWithName:imageName inDocumentName:documentName size:CGSizeZero
        contentMode:UIViewContentModeCenter contentScale:scale completionBlock:completionBlock];
}


- (void)getImageWithName:(NSString*)imageName inDocumentName:(NSString*)documentName size:(CGSize)size
    contentMode:(UIViewContentMode)contentMode contentScale:(CGFloat)scale completionBlock:(void (^)(UIImage* image))completionBlock
{
    NSString *imagePath = nil;
    
    if ( documentName != nil )
        imagePath = [_filesModel.filePaths fileFullPathForAssetWithFileName:imageName embeddedInProjectName:documentName];
    else
        imagePath = [_filesModel.filePaths fileFullPathForAssetWithFileName:imageName];
    
    [_imageManager getImageWithOriginalPath:imagePath size:size contentMode:contentMode contentScale:scale completionBlock:completionBlock];
}


- (void)getAnimatedOriginalImageWithNames:(id)img duration:(NSTimeInterval)duration inDocumentName:(NSString*)documentName
    contentScale:(CGFloat)scale completionBlock:(void (^)(UIImage* image))completionBlock
{
    [self getAnimatedImageWithNames:img duration:duration inDocumentName:documentName size:CGSizeZero contentMode:UIViewContentModeCenter contentScale:scale completionBlock:completionBlock];
}


- (void)getAnimatedImageWithNames:(id)img duration:(NSTimeInterval)duration inDocumentName:(NSString*)documentName size:(CGSize)size
    contentMode:(UIViewContentMode)contentMode contentScale:(CGFloat)scale completionBlock:(void (^)(UIImage* image))completionBlock
{
    if ( [img isKindOfClass:[NSArray class]] )
    {
        NSString *basePath = nil;
        if ( documentName != nil)
            basePath = [_filesModel.filePaths embeddedAssetsPathForProjectName:documentName];
        else
            basePath = [_filesModel.filePaths assetsPath];

        [_imageManager getAnimatedImageAtBasePath:basePath withOriginalNames:img duration:duration size:size contentMode:contentMode contentScale:scale  completionBlock:completionBlock];
    }
    else
    {
        [self getImageWithName:img inDocumentName:documentName size:size contentMode:contentMode contentScale:scale completionBlock:completionBlock];
    }
}


- (void)clearImageCache
{
    [_imageManager clearCache];
}

- (void)purgueImagesWithOriginalPath:(NSString *)fullPath
{
    [_imageManager purgeImagesWithOriginalPath:fullPath];
}

@end
