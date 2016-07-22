//
//  SWImageManager.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/3/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SWManagedImage.h"

typedef enum {
    SWImageManagerSavingOptionNone           = 0,
    SWImageManagerSavingOptionCreation       = 1 << 0,
    SWImageManagerSavingOptionModification   = 1 << 1,
    SWImageManagerSavingOptionDeletion       = 1 << 2,
    SWImageManagerSavingOptionAutomatic      = 1 << 3
} SWImageManagerSavingOptions;


typedef enum {
    SWImageManagerProcessingOptionsNone                 = 0,
    SWImageManagerProcessingOptionsOffLineRendering     = 1 << 0,
    SWImageManagerProcessingOptionsPriorityImage        = 1 << 1,
} SWImageManagerProcessingOptions;



@interface SWImageManager : NSObject 


// Get the default manager calling this method.
+ (SWImageManager*)defaultManager;

// Default initializer. Context will save into the given path.
// A cache directory will be created at the directory the context is saved
- (id)initForSavingAtFilePath:(NSString*)savingPath;

// Set an external serial dispatch queue just after initialization to handle all the asynchronous operations,
// the queue must have a context data already set with the dispatch_queue_set_specific, you must provide the key.
- (void)setDispatchQueue:(dispatch_queue_t)cQueue key:(const char *)key;

// This method returns synchronously the image at the given path.
// It also manages a cache and returns previously resized images,
// but it does not attemp to create an image that is not found
- (UIImage*)imageAtPath:(NSString*)path;

// This method finds or creates a new UIImage based on the descriptor
// and returns it as the parameter of the completion block.
// The completion block may be executed asynchronously if the image
// was not previously cached or is new.
- (void)getImageWithDescriptor:(SWImageDescriptor*)descriptor completionBlock:(void (^)(UIImage* image))completionBlock;

// This method performs a synchronous save of the ManagedImageContext state.
// Must be called on application termination or before the context is no longer used.
// Otherwise the context is automatically saved at regular intervals
- (void)save;

// metode primitiu, simplement crea un descriptor i crida getImageWithDescriptor
- (void)getImageWithOriginalPath:(NSString*)imagePath size:(CGSize)size contentMode:(UIViewContentMode)contentMode
    completionBlock:(void (^)(UIImage* image))completionBlock;

- (void)getImageWithOriginalPath:(NSString*)imagePath size:(CGSize)size
    contentMode:(UIViewContentMode)contentMode contentScale:(CGFloat)scale completionBlock:(void (^)(UIImage* image))completionBlock;

- (void)getAnimatedImageAtBasePath:(NSString*)basePath withOriginalNames:(NSArray*)names duration:(NSTimeInterval)duration size:(CGSize)size
    contentMode:(UIViewContentMode)contentMode contentScale:(CGFloat)scale completionBlock:(void (^)(UIImage* image))completionBlock;

- (void)purgeImagesWithOriginalPath:(NSString*)imagePath;
- (void)clearCache;

// Metodes de conveniencia per fabricar i obtenir imatges a partir del contingut de un CALayer
// Les imatges originals les genera a partir del layer.
// El rendering del layer es fa en un trhead secundari pero en acabar tenim la oportunitat de cancelar
// el procesament de la imatge tornant YES en el cancelBlock, en aquest cas el completion block no es crida.
- (void)makeThumbnailImageFromView:(UIView*)view uuid:(NSString*)uuid size:(CGSize)size radius:(CGFloat)radius
    contentMode:(UIViewContentMode)contentMode options:(SWImageManagerProcessingOptions)processingOptions
    cancelBlock:(BOOL (^)(void))cancelBlock
    completionBlock:(void (^)(UIImage* image))completionBlock;

- (void)getThumbnailImageWithUuid:(NSString*)uuid completionBlock:(void (^)(UIImage* image))completionBlock;

// Metode de conveniencia per obtenir asincronament una imatge del disc sense involucrar la cache de la clase
- (void)getAsynchronousImageAtPath:(NSString*)path completionBlock:(void (^)(UIImage* image))completionBlock;


@end
