//
//  SWImageManager.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/3/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWImageManager.h"

//#import "NSFileManager+Directories.h"
//#import "SWFileManager.h"

#import "UIImage+Resize.h"
#import "UIImage+animatedGIF.h"
#import "CALayer+ScreenShot.h"

//#import "AppFilesModel.h"

#define VERSION 200
#define TOTAL_IMAGES_CACHED 150
#define PRIORITY_IMAGES_CACHED_HINT 50

@interface SWImageManager ()

@end


static NSString * const SW0Extension = @"sw0";
static NSString * const GifExtension = @"gif";
static NSString * const PngExtension = @"png";
static NSString * const JpegExtension = @"jpeg";




#pragma mark - Class Implementation

@implementation SWImageManager
{
    NSCache *_cache;
    NSMutableSet *_managedImages;
    NSInteger _changesCount;
    //__weak NSTimer *_saveTimer;
	dispatch_queue_t _cQueue;
    const char *_queueKey ; // key for the dispatch queue
    void *_queueContext ; // context for the dispatch queue
    NSString *_savingPath;
    NSString *_cacheFolderPath;
    SWImageManagerSavingOptions _savingOptions;
    dispatch_source_t _saveTimer;
}



+ (SWImageManager*)defaultManager
{
    static SWImageManager *instance = nil;

    if (!instance)
    {
        instance = [[SWImageManager alloc] initForSavingAtFilePath:nil];
    }
    
    return instance;
}

- (id)init
{
    return [self initForSavingAtFilePath:nil];
}

- (void)dealloc
{
    if ( _saveTimer ) dispatch_source_cancel( _saveTimer );
    //if ( _cQueue ) dispatch_release( _cQueue );
    _cQueue = nil;
}

- (id)initForSavingAtFilePath:(NSString*)savingPath;
{
    self = [super init];
    if (self)
    {
        if ( savingPath == nil )
        {
            NSString *cacheDir = [self _cacheDirectoryPath];
            savingPath = [cacheDir stringByAppendingPathComponent:@"DefaultManagedImageContext"];
        }
        _cache = [[NSCache alloc] init];
        //[_cache setCountLimit:10];
        _changesCount = 0;
        _savingPath = savingPath;
        _savingOptions = SWImageManagerSavingOptionAutomatic;
        _cacheFolderPath = [self _getCacheFolderPathForContextPath:savingPath];
        [self _createCacheFolder];
        _managedImages = [self _loadManagerFromPersistence];  // It is safe doing this here
    }
    return self;
}


- ( NSString*)_cacheDirectoryPath
{
    NSString *cacheDirectoryPath = nil ;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if ( [paths count] > 0 )
    {
        NSString *path = [paths objectAtIndex:0];
        cacheDirectoryPath = [path stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]];
    }
    return cacheDirectoryPath;
}


- (NSString *)_getCacheFolderPathForContextPath:(NSString*)contextPath
{
    NSString *cacheFolderPath = [[contextPath stringByDeletingPathExtension] stringByAppendingString:@"_cache"];
    return cacheFolderPath;
}


- (void)_createCacheFolder
{
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm createDirectoryAtPath:_cacheFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
}


#pragma mark Serial Queue



- (void)setDispatchQueue:(dispatch_queue_t)cQueue key:(const char *)key
{
    _queueKey = key;
    _queueContext = dispatch_queue_get_specific(cQueue, key);
    _cQueue = cQueue;
}


//static const char *s_cQueue= "SWImageManagerQueue";

- (dispatch_queue_t)cQueue
{
    if ( _cQueue == NULL )
    {

        
//        _cQueue = dispatch_queue_create( s_cQueue, NULL );
//        dispatch_queue_set_specific( _cQueue, s_cQueue, (void*)s_cQueue, NULL);

        _queueKey = "SWImageManagerQueue";
        _queueContext = (void*)_queueKey;
        
        _cQueue = dispatch_queue_create( _queueKey, NULL );
        dispatch_queue_set_specific( _cQueue, _queueKey, _queueContext, NULL);
    }
    return _cQueue;
}

- (void)dispatchBlockNow:(void (^)(void))block
{
//    if (dispatch_get_specific(s_cQueue) == s_cQueue) block();
//    else dispatch_sync( self.cQueue, block );

    if (dispatch_get_specific(_queueKey) == _queueContext) block();
    else dispatch_sync( self.cQueue, block );
}


#pragma mark Overriden Methods

- (NSString*)description
{
    __block NSString *descr = nil;
    [self dispatchBlockNow:^
    {
        descr = _managedImages.description;
    }];

    return descr;
}


#pragma mark Public Methods

- (UIImage*)imageAtPath:(NSString*)path
{
    __block UIImage *image = nil;
    [self dispatchBlockNow:^
    {
        image = [self _imageAtPath:path];
    }];
    return image;
}


//- (void)getImageWithDescriptorV:(SWImageDescriptor*)descriptor completionBlock:(void (^)(UIImage*))completionBlock
//{
//    dispatch_async(self.cQueue, ^
//    {
//        if ( descriptor )
//        {
//            [self _obtainImageFromDescription:descriptor withCompletionBlock:^(UIImage *image)
//            {
//                dispatch_async(dispatch_get_main_queue(), ^
//                {
//                    if ( completionBlock ) completionBlock( image );
//                });
//            }];
//        }
//        else
//        {
//            dispatch_async(dispatch_get_main_queue(), ^
//            {
//                if ( completionBlock ) completionBlock( nil );
//            });
//        }
//    });
//}



- (void)getImageWithDescriptor:(SWImageDescriptor*)descriptor completionBlock:(void (^)(UIImage*))completionBlock
{
    dispatch_async(self.cQueue, ^
    {
        UIImage *image = nil;
        if ( descriptor )
            image = [self _obtainImageFromDescription:descriptor];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if ( completionBlock ) completionBlock( image );
        });
    });
}


//- (void)getImageWithDescriptor:(SWImageDescriptor*)descriptor completionBlock:(void (^)(UIImage*))completionBlock
//{
//    dispatch_async(self.cQueue, ^
//    {
//        UIImage *image = nil;
//        
//        if ( descriptor )
//        {
//            NSArray *originalPaths = descriptor.originalPath;
//            if ( [originalPaths isKindOfClass:[NSArray class]] )
//            {
//                NSMutableArray *images = [NSMutableArray array];
//                for ( NSString *imagePath in originalPaths )
//                {
//                    SWImageDescriptor *subDescriptor = [[SWImageDescriptor alloc]
//                        initWithOriginalPath:imagePath size:descriptor.size contentMode:descriptor.contentMode contentScale:descriptor.scale];
//                    
//                    UIImage *subImage = [self _obtainImageFromDescription:subDescriptor];
//                    [images addObject:subImage];
//                }
//                image = [UIImage animatedImageWithImages:images duration:1.0];
//            }
//            else
//            {
//                image = [self _obtainImageFromDescription:descriptor];
//            }
//        }
//        
//        dispatch_async(dispatch_get_main_queue(), ^
//        {
//            if ( completionBlock ) completionBlock( image );
//        });
//    });
//}


- (void)save
{
    [self dispatchBlockNow:^
    {
        [self _save];
    }];
}


- (void)getImageWithOriginalPath:(NSString*)imagePath size:(CGSize)size contentMode:(UIViewContentMode)contentMode
    completionBlock:(void (^)(UIImage* image))completionBlock
{
    [self getImageWithOriginalPath:imagePath size:size contentMode:contentMode contentScale:0 completionBlock:completionBlock];
}


- (void)getImageWithOriginalPath:(NSString*)imagePath size:(CGSize)size
    contentMode:(UIViewContentMode)contentMode contentScale:(CGFloat)scale
    completionBlock:(void (^)(UIImage* image))completionBlock
{
    SWImageDescriptor *descriptor = nil;
    if ( imagePath )
    {
        // Per UIViewContentModeCenter no permetem scales inferiors a la pantalla, amb aixo solventem
        // el bug de CALayer:setContents: que falla per kCAGravityCenter si el contentScale es menor que la pantalla
        CGFloat screenScale = [[UIScreen mainScreen] scale];
        if ( contentMode == UIViewContentModeCenter && scale > 0 && scale < screenScale )
            scale = screenScale; //wwscale
    
        descriptor = [[SWImageDescriptor alloc] initWithOriginalPath:imagePath size:size contentMode:contentMode contentScale:scale];
    }
        
    [self getImageWithDescriptor:descriptor completionBlock:completionBlock];
}



- (void)getAnimatedImageAtBasePath:(NSString*)basePath withOriginalNames:(NSArray*)names duration:(NSTimeInterval)duration size:(CGSize)size
    contentMode:(UIViewContentMode)contentMode contentScale:(CGFloat)scale completionBlock:(void (^)(UIImage* image))completionBlock
{
    // Per UIViewContentModeCenter no permetem scales inferiors a la pantalla, amb aixo solventem
    // el bug de CALayer:setContents: que falla per kCAGravityCenter si el contentScale es menor que la pantalla
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    if ( contentMode == UIViewContentModeCenter && scale > 0 && scale < screenScale )
        scale = screenScale; //wwscale

    dispatch_async(self.cQueue, ^
    {
        UIImage *image = nil;
        NSMutableArray *images = [NSMutableArray array];

        for ( NSString *name in names )
        {
            NSString *imagePath = [basePath stringByAppendingPathComponent:name];
            SWImageDescriptor *descriptor = [[SWImageDescriptor alloc] initWithOriginalPath:imagePath
                size:size contentMode:contentMode contentScale:scale];
                    
            UIImage *subImage = [self _obtainImageFromDescription:descriptor];
            if ( subImage != nil )
                [images addObject:subImage];
        }

        image = [UIImage animatedImageWithImages:images duration:duration];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if ( completionBlock ) completionBlock( image );
        });
    });
}


- (void)purgeImagesWithOriginalPath:(NSString*)originalPath
{
    dispatch_async(self.cQueue, ^
    {
        [self _purgeManagedImagesWithOriginalPath:originalPath];
    });
}

- (void)clearCache;
{
    dispatch_async(self.cQueue, ^
    {
        [self _clearCache];
        [self _save];
    });
}


- (void)makeThumbnailImageFromView:(UIView*)view uuid:(NSString*)uuid size:(CGSize)size radius:(CGFloat)radius
    contentMode:(UIViewContentMode)contentMode options:(SWImageManagerProcessingOptions)processingOptions cancelBlock:(BOOL (^)(void))cancelBlock
    completionBlock:(void (^)(UIImage* image))completionBlock
    {

    __block UIView *theView = view;
    //CALayer *theLayer = theView.layer;
    
    {
        BOOL offlineRendering = ((processingOptions&SWImageManagerProcessingOptionsOffLineRendering) != 0);
        BOOL priorityImage = ((processingOptions&SWImageManagerProcessingOptionsPriorityImage) != 0);
    
        UIImage *contentImage = [theView resizedImageWithContentMode:contentMode bounds:size
            interpolationQuality:kCGInterpolationDefault radius:radius cropped:NO oflineRendering:offlineRendering];
        
        // http://stackoverflow.com/questions/18942037/blur-screen-with-ios-7s-snapshot-api
        
        __block BOOL mustCancel = NO;
        
        if ( cancelBlock )
        {
            //dispatch_sync(dispatch_get_main_queue(), ^
            {
                mustCancel = cancelBlock();
            }
            //);
        }
        
        if ( mustCancel )
            return;
        
        SWImageDescriptor *descriptor = [[SWImageDescriptor alloc] initWithOriginalImage:contentImage uuid:uuid];
        descriptor.hasPriority = priorityImage;
        [self getImageWithDescriptor:descriptor completionBlock:^(UIImage *image)
        {
            if ( completionBlock ) completionBlock(image);
            theView = nil;  // <-- amb aixo forcem que view sigui retinguda fins que acabem
        }];
    }
    //);
}


- (void)getThumbnailImageWithUuid:(NSString*)uuid completionBlock:(void (^)(UIImage* image))completionBlock
{
    SWImageDescriptor *descriptor = [[SWImageDescriptor alloc] initWithOriginalImage:nil uuid:uuid];
    [self getImageWithDescriptor:descriptor completionBlock:completionBlock];
}


- (void)getAsynchronousImageAtPath:(NSString*)originalPath completionBlock:(void (^)(UIImage* image))completionBlock
{
    dispatch_async(self.cQueue, ^
    {
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:originalPath];
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if ( completionBlock ) completionBlock( image );
        });
    });
}


#pragma mark Private Methods (Executed on the cQueue queue)

// purga imatges de disc, i la cache de memoria
- (void)_purgeManagedImagesWithOriginalPath:(NSString*)originalPath
{
    NSMutableArray *purgeable = [NSMutableArray array];
    for ( SWManagedImage *managedImage in _managedImages )
    {
        if ( [managedImage.originalPath isEqualToString:originalPath] )
            [purgeable addObject:managedImage];
    }
    
    for ( SWManagedImage *purgeableImage in purgeable)
    {
        [_cache removeObjectForKey:purgeableImage.path];
        [self _purgeManagedImage:purgeableImage];
    }
    
    [_cache removeObjectForKey:originalPath];
}


// purga imatges de disc, i la cache de memoria
- (void)_clearCache
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL done = [fm removeItemAtPath:_cacheFolderPath error:nil];
    if ( !done ) NSLog( @"error clearing cache: %@", error );
    
    
    [self _createCacheFolder];
    
//    NSDirectoryEnumerator* en = [fm enumeratorAtPath:_cacheFolderPath];    
//    NSError* err = nil;
//    BOOL res;
//
//    NSString* file;
//    while (file = [en nextObject])
//    {
//        res = [fm removeItemAtPath:[_cacheFolderPath stringByAppendingPathComponent:file] error:&err];
//        if (!res && err)
//        {
//            NSLog(@"oops: %@", err);
//        }
//    }

    [_cache removeAllObjects];
    [_managedImages removeAllObjects];
    _changesCount = 1;
}



// purga imatges de disc, no de la cache de memoria
- (void)_purgeOldManagedImages
{    
    if (_managedImages.count < TOTAL_IMAGES_CACHED)
        return;
    
    NSTimeInterval date = CFAbsoluteTimeGetCurrent();
    NSTimeInterval priorityDate = date;
    
    SWManagedImage *purgeableImage = nil;
    SWManagedImage *priorityPurgeableImage = nil;
    
    int count = 0;
    int priorityCount = 0;
    
    // determinem la imatge mes antiga i la imatge prioritaria mes antiga
    for ( SWManagedImage *mi in _managedImages )
    {
        NSTimeInterval accessDate = mi.accessDate;
        BOOL hasPriority = mi.hasPriority;
        
        if ( hasPriority )
        {
            priorityCount++;
            if (accessDate < priorityDate)
            {
                priorityDate = accessDate;
                priorityPurgeableImage = mi;
            }
        }
        else
        {
            count++;
            if (accessDate < date)
            {
                date = accessDate;
                purgeableImage = mi;
            }
        }
    }
    
    // si tenim masses imatges prioritaries pot ser n'hem d'elimimar alguna
    if ( priorityCount > PRIORITY_IMAGES_CACHED_HINT )
    {
        // en aquest cas eliminarem la imatge prioritaria si es mes vella que la normal
        if ( priorityDate < date )
            purgeableImage = priorityPurgeableImage;
    }
    
    //NSLog( @"purge image %@", purgeableImage.originalPath.lastPathComponent);
    [self _purgeManagedImage:purgeableImage];
}


// purga imatges de disc, no de la cache de memoria
- (void)_purgeManagedImage:(SWManagedImage*)purgeableImage
{
    NSString *imagePath = purgeableImage.path;
    
    //NSLog( @"PURGUE IMAGE:\nPath:%@\nOrig:%@", imagePath, managedImage.originalPath);
    
    //NSLog( @"Purgue Managed Image %@", purgeableImage.description);
    
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:imagePath error:nil];
    
    
    purgeableImage.path = nil;
    
    [_managedImages removeObject:purgeableImage];
    [self _maybeSaveContextForOption:SWImageManagerSavingOptionDeletion];
}



//// Atenció! Les imatges retornades per "initWithContentsOfFile:" són imatges no descomprimides (encara estan codificades en NSData dins de la mateixa instància de UIImage). El mètode "imageNamed:" per contra sí les descomprimeix. Això afecta els temps de dibuix.
//// Possible Solució ==> Crear una categoria de uiimage i afegir un mètode equivalent al "initWithContentsOfFile:" on es retorni la imatge ja descomprimida. Per més informació veure: (3ra resposta) http://stackoverflow.com/questions/1815476/cgimage-uiimage-lazily-loading-on-ui-thread-causes-stutter
//
//// tambe: http://stackoverflow.com/questions/5266272/non-lazy-image-loading-in-ios
//
//- (UIImage*)_imageAtPathV:(NSString*)path scale:(CGFloat)scale
//{
//    if ( path == nil )
//        return nil;
//    
//    // primer busquem a la cache en memoria
//    UIImage *image = [_cache objectForKey:path];
//    
//    if ( image )
//        return image;
//    
//    // sino busquem a la cache en disk
//
//    if ( scale == 0 )
//    {
//        // utilitzem la escala nativa de l'arxiu (ex @2x.png)
//        image = [[UIImage alloc] initWithContentsOfFile:path];
//    }
//    else
//    {
//        // utilitzem una scala explicita
//        NSData *imageData = [NSData dataWithContentsOfFile:path];
//        image = [UIImage imageWithData:imageData scale:scale];
//    }
//    
////    NSLog( @"Loaded Image Size %@", NSStringFromCGSize(image.size ));
////    NSLog( @"Loaded Image Scale %g", image.scale );
//
//    // si l'hem trobat l'anotem a la cache de memoria
//    if (image)
//        [_cache setObject:image forKey:path];
//    
//    return image;
//}


- (UIImage*)_imageAtPath:(NSString*)path
{
    return [self _imageAtPath:path scale:0];
}


// Atenció! Les imatges retornades per "initWithContentsOfFile:" són imatges no descomprimides (encara estan codificades en NSData dins de la mateixa instància de UIImage). El mètode "imageNamed:" per contra sí les descomprimeix. Això afecta els temps de dibuix.
// Possible Solució ==> Crear una categoria de uiimage i afegir un mètode equivalent al "initWithContentsOfFile:" on es retorni la imatge ja descomprimida. Per més informació veure: (3ra resposta) http://stackoverflow.com/questions/1815476/cgimage-uiimage-lazily-loading-on-ui-thread-causes-stutter

// tambe: http://stackoverflow.com/questions/5266272/non-lazy-image-loading-in-ios

- (UIImage*)_imageAtPath:(NSString*)path scale:(CGFloat)scale
{
    if ( path == nil )
        return nil;
    
    // primer busquem a la cache en memoria
    UIImage *image = [_cache objectForKey:path];
    
    if ( image )
        return image;
    
    // sino busquem a la cache en disk
    
    if ( scale == 0 )
    {
        scale = 1;
        NSString *lastPath = [path stringByDeletingPathExtension];
        if ([lastPath compare:@"@2x" options:NSAnchoredSearch|NSBackwardsSearch|NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            scale = 2;
        }
    }
    
    image = [self _loadImageAtPath:path scale:scale];
    
    
//    NSLog( @"Loaded Image Size %@", NSStringFromCGSize(image.size ));
//    NSLog( @"Loaded Image Scale %g", image.scale );

    // si l'hem trobat l'anotem a la cache de memoria
    if (image)
        [_cache setObject:image forKey:path];
    
    return image;
}





//- (UIImage *)_obtainImageFromDescriptionVV:(SWImageDescriptor*)descriptor
//{
//    //static int count = 0;
//
//    //SWManagedImage *managedImage = [self _getManagedImageWithDescription:descriptor];
//    
//    SWManagedImage *mi = [_managedImages member:descriptor];
//    SWManagedImage *managedImage = mi;
//    if ( !managedImage )
//    {
//        managedImage = [[SWManagedImage alloc] initWithDescriptor:descriptor];
//    }
//    else
//    {
//        //NSLog( @"\n\nLoad Managed Image %@\n\n", managedImage.description);
//    }
//    
//    UIImage *contentImage = descriptor.contentImage;
//
//
//    UIImage *originalImage = nil;
//    UIImage *image = nil;
//    //UIImage *contentImage = managedImage.contentImage;
//
//    if ( contentImage == nil )
//    {
//        // primer mirem si ja tenim una imatge per aquest managedImage
//        image = [self _imageAtPath:managedImage.path scale:managedImage.scale];
//        
//        if ( image )
//        {
//            managedImage.accessDate = CFAbsoluteTimeGetCurrent();
//            
//            [self _purgeOldManagedImages];
//            if ( mi == nil )
//            {
//                [_managedImages addObject:managedImage];
//                //NSLog( @"Save Managed Image %@, count: %d", managedImage.description, count++);
//            }
//            [self _maybeSaveContextForOption:SWImageManagerSavingOptionModification];
//            
//            return image;
//        }
//
//        originalImage = [self _imageAtPath:managedImage.originalPath];
//        //NSLog( @"originalImageSize : %@", NSStringFromCGSize(originalImage.size));
//    }
//    
//    // trobem aixo quan el descriptor es un uuid
//    else if ( contentImage == EmptyImage )
//    {
//        image = [self _imageAtPath:managedImage.path];
//        
//        if ( image )
//        {
//            managedImage.accessDate = CFAbsoluteTimeGetCurrent();
//
//            [self _purgeOldManagedImages];
//            if ( mi == nil )
//            {
//                [_managedImages addObject:managedImage];
//                //NSLog( @"Save Managed Image %@, count: %d", managedImage.description, count++);
//            }
//            [self _maybeSaveContextForOption:SWImageManagerSavingOptionModification];
//        }
//        
//        return image;
//    }
//    
//    // si ens passen una contentImage interpretem que es diferent de qualsevol anterior i per tant la processem
//    else
//    {
//        originalImage = contentImage;
//    }
//    
//    // a partir d'aqui intentem crear la imatge  amb la mida adequada a partir de la imatge original
//    BOOL succeed = NO;
//    NSString *path = managedImage.path;
//    NSString *thePath = path;
//    
//    CGSize size = managedImage.size;
//    if ( CGSizeEqualToSize(size, CGSizeZero) )
//    {
//        size = originalImage.size;
//    }
//    
//    // Obtenim la imatge a partir de la imatge original
//    image = [originalImage resizedImageWithContentMode:managedImage.contentMode
//        bounds:size contentScale:managedImage.scale interpolationQuality:INTERPOLATION_QUALITY cropped:YES];
//    
//    // Si tenim una imatge la guardem
//    if (image)
//    {
//        // Getting the data from the image
//        NSData *data = UIImagePNGRepresentation(image);
//            
//        // Getting a valid name to save the image
//        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
//        NSString *identifier = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
//        CFRelease(uuidRef);
//    
//        // Saving the image to the cache folder
//        thePath = [_cacheFolderPath stringByAppendingPathComponent:identifier];
//            
//        // add @2x if retina display
//        if (managedImage.scale == 2.0)
//            thePath = [thePath stringByAppendingString:@"@2x"];
//        
////        NSLog( @"Saved Image Size %@", NSStringFromCGSize(image.size ));
////        NSLog( @"Saved Image Scale %g", image.scale );
//        
//        // save to disk with extension
//        thePath = [thePath stringByAppendingPathExtension:PngExtension];
//        succeed = [data writeToFile:thePath atomically:YES];
//        
//        // save to memory cache
//        [_cache setObject:image forKey:thePath];
//    }
//    
//    if ( succeed )
//    {
//        NSTimeInterval now = CFAbsoluteTimeGetCurrent();
//        managedImage.creationDate = now;  // no es rellevant
//        managedImage.accessDate = now;
//
//        //NSLog( @"obtainManaged: %08x", (int)managedImage);
//        managedImage.path = thePath;
//        
//        [self _purgeOldManagedImages];
//        if ( mi == nil )
//        {
//            [_managedImages addObject:managedImage];
//            //NSLog( @"Save Managed Image %@, count: %d", managedImage.description, count++);
//        }
//        [self _maybeSaveContextForOption:SWImageManagerSavingOptionCreation];
//    }
//    
//    return image;
//}
//


- (UIImage *)_obtainImageFromDescription:(SWImageDescriptor*)descriptor
{
    SWManagedImage *mi = [_managedImages member:descriptor];
    SWManagedImage *managedImage = mi;
    if ( !managedImage )
    {
        managedImage = [[SWManagedImage alloc] initWithDescriptor:descriptor];
    }
    else
    {
        //NSLog( @"\n\nLoad Managed Image %@\n\n", managedImage.description);
    }
    
    UIImage *contentImage = descriptor.contentImage;
    UIImage *originalImage = nil;
    UIImage *image = nil;

    if ( contentImage == nil )
    {
        // primer mirem si ja tenim una imatge per aquest managedImage
        image = [self _imageAtPath:managedImage.path scale:managedImage.scale];
        
        if ( image )
        {
            managedImage.accessDate = CFAbsoluteTimeGetCurrent();
            
            [self _purgeOldManagedImages];
            if ( mi == nil )
            {
                [_managedImages addObject:managedImage];
                //NSLog( @"Save Managed Image %@, count: %d", managedImage.description, count++);
            }
            [self _maybeSaveContextForOption:SWImageManagerSavingOptionModification];
            
            return image;
        }

        originalImage = [self _imageAtPath:managedImage.originalPath];
        //NSLog( @"originalImageSize : %@", NSStringFromCGSize(originalImage.size));
    }
    
    // trobem aixo quan el descriptor es un uuid
    else if ( contentImage == EmptyImage )
    {
        image = [self _imageAtPath:managedImage.path];
        
        if ( image )
        {
            managedImage.accessDate = CFAbsoluteTimeGetCurrent();

            [self _purgeOldManagedImages];
            if ( mi == nil )
            {
                [_managedImages addObject:managedImage];
                //NSLog( @"Save Managed Image %@, count: %d", managedImage.description, count++);
            }
            [self _maybeSaveContextForOption:SWImageManagerSavingOptionModification];
        }
        
        return image;
    }
    
    // si ens passen una contentImage interpretem que es diferent de qualsevol anterior i per tant la processem
    else
    {
        originalImage = contentImage;
    }
    
    // a partir d'aqui intentem crear la imatge  amb la mida adequada a partir de la imatge original
    BOOL succeed = NO;
    NSString *path = managedImage.path;
    NSString *thePath = path;
    
    CGSize size = managedImage.size;
    if ( CGSizeEqualToSize(size, CGSizeZero) )
    {
        size = originalImage.size;
    }
    
    // si el original image es multiple (pot vernir de un git) obtenim una imatge de imatges
    NSArray *originalImages = originalImage.images;
    
    if ( originalImages != nil )
    {
        // obtenim la imatge animada a partir de la original
        NSInteger count = originalImages.count;
        NSMutableArray *resizedImages = [NSMutableArray array];
        for ( NSInteger i=0 ; i<count ; i++ )
        {
            UIImage *originalImg = [originalImages objectAtIndex:i];
            UIImage *resizedImg = [originalImg resizedImageWithContentMode:managedImage.contentMode
                bounds:size contentScale:managedImage.scale interpolationQuality:INTERPOLATION_QUALITY cropped:YES];
            [resizedImages addObject:resizedImg];
        }
        image = [UIImage animatedImageWithImages:resizedImages duration:originalImage.duration];
    }
    else
    {
        // Obtenim la imatge estatica a partir de la imatge original
        image = [originalImage resizedImageWithContentMode:managedImage.contentMode
            bounds:size contentScale:managedImage.scale interpolationQuality:INTERPOLATION_QUALITY cropped:YES];
    }
    
    // Si tenim una imatge la guardem
    if (image)
    {
        // Getting a valid name to save the image
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        NSString *identifier = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
        CFRelease(uuidRef);
    
        // Saving the image to the cache folder
        thePath = [_cacheFolderPath stringByAppendingPathComponent:identifier];
            
        // add @2x if retina display
        if (managedImage.scale == 2.0)
            thePath = [thePath stringByAppendingString:@"@2x"];
        
        // save to disk with extension
        succeed = [self _saveImage:image path:thePath resultingPath:&thePath];
        
        // save to memory cache
        [_cache setObject:image forKey:thePath];
    }
    
    if ( succeed )
    {
        NSTimeInterval now = CFAbsoluteTimeGetCurrent();
        managedImage.creationDate = now;  // no es rellevant
        managedImage.accessDate = now;

        //NSLog( @"obtainManaged: %08x", (int)managedImage);
        managedImage.path = thePath;
        
        [self _purgeOldManagedImages];
        if ( mi == nil )
        {
            [_managedImages addObject:managedImage];
            //NSLog( @"Save Managed Image %@, count: %d", managedImage.description, count++);
        }
        [self _maybeSaveContextForOption:SWImageManagerSavingOptionCreation];
    }
    
    return image;
}


- (void)_maybeSaveContextForOption:(SWImageManagerSavingOptions)stateOption
{
    if (_savingOptions & stateOption)
    {
        [self _save];
    }
    else if (_savingOptions & SWImageManagerSavingOptionAutomatic)
    {
        [self _contextDidChange];
    }
}

- (void)_contextDidChange
{
    _changesCount += 1;
    
    if (_changesCount > 10)
    {
        [self _save];
    }
    else
    {
        [self _startSaveTimer];
    }
}


- (void)_startSaveTimer
{
    if ( _saveTimer == NULL )
    {
        _saveTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.cQueue );
    
        //dispatch_source_t theSaveTimer = _saveTimer;
        __weak id theSelf = self ;  // evitem el retain cycle entre _saveTimer i self
        
        dispatch_source_set_event_handler( _saveTimer, 
        ^{
            [theSelf _save];
        });

        dispatch_source_set_cancel_handler( _saveTimer, 
        ^{
            //IOS6 dispatch_release( theSaveTimer );
        });
    
        dispatch_resume( _saveTimer );
    }
    
    dispatch_time_t tt = dispatch_time( DISPATCH_TIME_NOW, NSEC_PER_SEC*10 );   // comenca d'aqui a 10 segons
    dispatch_source_set_timer( _saveTimer, tt, DISPATCH_TIME_FOREVER, 0 );      // no repeteix mai
}


- (void)_stopSaveTimer
{
    if ( _saveTimer ) dispatch_source_cancel( _saveTimer ), _saveTimer = NULL ;
}


- (void)_save
{
    [self _stopSaveTimer];  // parem el temporitzador
    
    if ( _changesCount == 0 )   // already saved
        return;
    
    NSMutableData *data = [NSMutableData data];
    
    QuickArchiver *archiver = [[QuickArchiver alloc] initForWritingWithMutableData:data version:VERSION];
    [archiver encodeObject:_managedImages];
    [archiver finishEncoding];
    
    NSLog(@"[SWImageManager] Saving Image Context" );
    
    if ( data )
    {
        [data writeToFile:_savingPath atomically:YES];
    }
    
    _changesCount = 0;
}


- (NSMutableSet*)_loadManagerFromPersistence
{
    NSMutableSet *set = nil;
    
    NSData *data = [NSData dataWithContentsOfFile:_savingPath];
    
    if ( data )
    {
        QuickUnarchiver *unarchiver = [[QuickUnarchiver alloc] initForReadingWithData:data];
        
        if (VERSION == unarchiver.version)
        {
            set = [unarchiver decodeObject];
//            NSLog(@"VERSION CORRECT");
        }
        else
        {
//            NSLog(@"VERSION NOT GOOD");
        }
    }
    
    if (!set)
    {
        [self _clearCache];
        set = [NSMutableSet set];
    }

    return set;
}


- (BOOL)_saveImage:(UIImage*)image path:(NSString*)path resultingPath:(NSString**)resultPath
{
    NSData *data = nil;
    NSString *sPath = nil;
    NSArray *images = image.images;
    
    if ( images == nil )
    {
        sPath = [[path stringByDeletingPathExtension] stringByAppendingPathExtension:PngExtension];
        data = UIImagePNGRepresentation( image );
    }
    else
    {
        sPath = [[path stringByDeletingPathExtension] stringByAppendingPathExtension:SW0Extension];
    
        double duration = image.duration;
        NSInteger count = images.count;
    
        NSMutableData *mdata = [NSMutableData data];
    
        QuickArchiver *archiver = [[QuickArchiver alloc] initForWritingWithMutableData:mdata version:VERSION];
        {
            [archiver encodeDouble:duration];
            [archiver encodeInt:count];
            for ( NSInteger i=0 ; i<count ; i++ )
            {
                UIImage *singleImage = [images objectAtIndex:i];
                NSData *pngSingleData = UIImagePNGRepresentation( singleImage );
                [archiver encodeObject:pngSingleData];
            }
            [archiver finishEncoding];
            data = mdata;
        }
    }
    
    //NSLog(@"[SWImageManager] Saving Animated Image" );
    
    if ( data )
    {
        if ( resultPath ) *resultPath = sPath;
        return [data writeToFile:sPath atomically:YES];
    }
    
    return NO;
}


- (UIImage*)_loadImageAtPath:(NSString*)path scale:(CGFloat)scale
{
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    if ( data.length == 0 )
        return nil;
    
    NSString *pathExtension = [path pathExtension];
    
    if ( [pathExtension caseInsensitiveCompare:GifExtension] == NSOrderedSame )
    {
        // per els gif creem una imatge animada
        UIImage *image = [UIImage animatedImageWithAnimatedGIFData:data scale:scale];
        return image;
    }
    
    if ( [pathExtension caseInsensitiveCompare:SW0Extension] != NSOrderedSame )
    {
        // les imatges normals les creem directament del data
        UIImage *image = [UIImage imageWithData:data scale:scale];
        return image;
    }
    
    // a partir d'aqui es un arxiu amb extensio SW0Extension
    double duration = 0;
    NSInteger count = 0;
    NSMutableArray *images = [NSMutableArray array];
    
    QuickUnarchiver *unarchiver = [[QuickUnarchiver alloc] initForReadingWithData:data];
    {
        if (VERSION == unarchiver.version)
        {
            duration = [unarchiver decodeDouble];
            count = [unarchiver decodeInt];
            for ( NSInteger i=0 ; i<count ; i++ )
            {
                NSData *pngSingleData = [unarchiver decodeObject];
                UIImage *singleImage = [UIImage imageWithData:pngSingleData scale:scale];
                [images addObject:singleImage];
            }
        }
    }
    
    if ( images.count > 0 )
    {
        UIImage *image = [UIImage animatedImageWithImages:images duration:duration];
        return image;
    }
    
    return nil;
}



#pragma mark dispatch_queue_set_specific example (code not used)

static const char* s_myqueue = "myqueue";

static dispatch_queue_t my_queue()
{
    static dispatch_queue_t _q;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        _q = dispatch_queue_create(s_myqueue, 0);
        dispatch_queue_set_specific(_q, s_myqueue, (void*) s_myqueue, NULL);
    });
    
    return _q;
}

static int foo()
{
    double (^do_foo)(int a) = ^(int a)
    {
        return 3.0;
    };

    if (dispatch_get_specific(s_myqueue) == s_myqueue)
    {
        return do_foo(3);
    }
    
    __block int result;
    dispatch_sync(my_queue(), ^
    {
        result = do_foo(3);
    });
    return result;
}



@end
