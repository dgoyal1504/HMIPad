//
//  AppModelImageManager.h
//  HmiPad
//
//  Created by Joan Lluch on 31/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "AppModel.h"

@class SWImageManager;

@interface AppModelImage : NSObject
{
    __weak AppModel *_filesModel;
    SWImageManager *_imageManager;
}

- (id)initWithLocalFilesModel:(AppModel*)filesModel;
//- (void)setDispatchQueue:(dispatch_queue_t)dQueue key:(const char *)key;  // <-- call on initialization

// Metodes de conveniencia per obtenir imatges a partir del seu nom.
// Les imatges originals les busca en la catche general
- (void)getOriginalImageWithName:(NSString*)imageName completionBlock:(void (^)(UIImage* image))completionBlock;
- (void)getImageWithName:(NSString*)imageName size:(CGSize)size contentMode:(UIViewContentMode)contentMode completionBlock:(void (^)(UIImage* image))completionBlock;

// Metodes de conveniencia per obtenir imatges a partir del seu nom.
// Les imatges originals les busca en un subdirectori del document
- (void)getOriginalImageWithName:(NSString*)imageName inDocumentName:(NSString*)documentName completionBlock:(void (^)(UIImage* image))completionBlock;

- (void)getImageWithName:(NSString*)imageName inDocumentName:(NSString*)documentName size:(CGSize)size
    contentMode:(UIViewContentMode)contentMode completionBlock:(void (^)(UIImage* image))completionBlock;


- (void)getOriginalImageWithName:(NSString*)imageName inDocumentName:(NSString*)documentName
    contentScale:(CGFloat)scale completionBlock:(void (^)(UIImage* image))completionBlock;

- (void)getImageWithName:(NSString*)imageName inDocumentName:(NSString*)documentName size:(CGSize)size
    contentMode:(UIViewContentMode)contentMode contentScale:(CGFloat)scale completionBlock:(void (^)(UIImage* image))completionBlock;


- (void)getAnimatedOriginalImageWithNames:(id)img duration:(NSTimeInterval)duration inDocumentName:(NSString*)documentName
    contentScale:(CGFloat)scale completionBlock:(void (^)(UIImage* image))completionBlock;

- (void)getAnimatedImageWithNames:(id)img duration:(NSTimeInterval)duration inDocumentName:(NSString*)documentName size:(CGSize)size
    contentMode:(UIViewContentMode)contentMode contentScale:(CGFloat)scale completionBlock:(void (^)(UIImage* image))completionBlock;

- (void)clearImageCache;
- (void)purgueImagesWithOriginalPath:(NSString*)path;

@end
