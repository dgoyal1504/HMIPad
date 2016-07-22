//
//  UIView+ScreenShot.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/26/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CALayer+ScreenShot.h"
#import "Drawing.h"

//@implementation UIView (ScreenShot)
//
//- (UIImage *)screenShotWithScale:(CGFloat)scale
//{
//    CGSize size = self.bounds.size;
//    size.width = size.width;
//    size.height = size.height;
//    UIGraphicsBeginImageContextWithOptions(size, self.opaque, scale);
//    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
//    
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    
//    UIGraphicsEndImageContext();
//    
//    return image;
//}
//
//
//
//- (UIImage *)screenShotWithTargetHeightV:(CGFloat)targetHeight
//{
//    CGSize size = self.bounds.size;
//    CGFloat contentScale = [[UIScreen mainScreen] scale];
//    
//    CGFloat targetScale = contentScale*targetHeight/size.height;
//
//    UIGraphicsBeginImageContextWithOptions(size, self.opaque, targetScale);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    [self.layer renderInContext:context];
//    
//    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
//    UIImage *image = [UIImage imageWithCGImage:newImageRef scale:contentScale orientation:UIImageOrientationUp];
//    CGImageRelease(newImageRef);
//    
////    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    
//    UIGraphicsEndImageContext();
//    
////    CGImageRef imageRef = image.CGImage;
////    CGSize cgSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
////    NSLog( @"CGimageSize:%@", NSStringFromCGSize(cgSize));
////    NSLog( @"imageSize:%@ imageScale:%g", NSStringFromCGSize(image.size), image.scale);
//    
//    return image;
//    
////    if (fabs(scale) < TOL)
////        return image;  
////    
////    if (fabs(scale-1) < TOL)
////        return image;
////    
////    CGSize newSize = CGSizeMake(image.size.width/scale, image.size.height/scale);
////    
////    return [image scaleToSize:newSize];
//    
//}
//
//
//
//
//- (UIImage *)screenShotWithTargetHeight:(CGFloat)targetHeight
//{
//    CGSize size = self.bounds.size;
//    CGFloat contentScale = [[UIScreen mainScreen] scale];
//    
//    CGFloat targetScale = contentScale*targetHeight/size.height;
//    CGSize targetSize;
//    targetSize.width = size.width*targetScale;
//    targetSize.height = size.height*targetScale;
//
//    //UIGraphicsBeginImageContextWithOptions(size, self.opaque, targetScale);
//    
//    CGColorSpaceRef genericColorSpace = CGColorSpaceCreateDeviceRGB();
//    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrderDefault;
//    
//    CGContextRef bitmapContext = CGBitmapContextCreate(NULL,
//                                                targetSize.width,
//                                                targetSize.height,
//                                                8, 
//                                                0, /*(4 * contextBounds.width),*/
//                                                genericColorSpace, 
//                                                bitmapInfo);
//    
//    CGContextTranslateCTM( bitmapContext, 0.0, targetSize.height ) ;
//    CGContextScaleCTM( bitmapContext, targetScale, -targetScale ) ;
//    
//    [self.layer renderInContext:bitmapContext];
//    
//    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmapContext);
//    UIImage *image = [UIImage imageWithCGImage:newImageRef scale:contentScale orientation:UIImageOrientationUp];
//    
//    CGContextRelease(bitmapContext);
//    CGImageRelease(newImageRef);
//    CGColorSpaceRelease(genericColorSpace);
//    
////    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    
////    CGImageRef imageRef = image.CGImage;
////    CGSize cgSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
////    NSLog( @"CGimageSize:%@", NSStringFromCGSize(cgSize));
////    NSLog( @"imageSize:%@ imageScale:%g", NSStringFromCGSize(image.size), image.scale);
//    
//    return image;
//}
//
//
//- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
//                                  bounds:(CGSize)bounds   // referit a punts (no pixels)
//                    interpolationQuality:(CGInterpolationQuality)quality
//                                  radius:(CGFloat)radius
//                                 cropped:(BOOL)cropped
//{
//
//    // determinem la mida del view i la seva escala
//    CGSize selfSize = self.bounds.size;
//    CGFloat contentScale = [[UIScreen mainScreen] scale];
//    
//    // determinem la mida final en funcio del content mode i els bounds que volem
//    CGSize imageSize = [self sizeWithContentMode:contentMode bounds:bounds];  // ho torna referit a punts
//    
//    // el contexte que crearem no te nocio d'escala, per tant ajustem la mida de la imatge per tenir la maxima resolucio
//    imageSize.width *= contentScale;
//    imageSize.height *= contentScale;
//    
//    // en principi la mida del contexte es bounds (ajustat per l'escala)
//    CGSize contextBounds;
//    contextBounds.width = bounds.width*contentScale;
//    contextBounds.height = bounds.height*contentScale;
//    
//    if ( cropped )
//    {
//        // ajustem el contexte perque no superi mai la mida maxima de l'imatge, volem que la imatge resizada no tingui artifactes al voltant
//        if ( contextBounds.width > imageSize.width ) contextBounds.width = imageSize.width;
//        if ( contextBounds.height > imageSize.height ) contextBounds.height = imageSize.height;
//    }
//    
//    // creem un contexte per el renderitzat
//    CGColorSpaceRef genericColorSpace = CGColorSpaceCreateDeviceRGB();
//    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrderDefault;
//    
//    CGContextRef bitmapContext = CGBitmapContextCreate(NULL,
//                                                contextBounds.width,
//                                                contextBounds.height,
//                                                8, 
//                                                0, /*(4 * contextBounds.width),*/
//                                                genericColorSpace, 
//                                                bitmapInfo);
//    
//    // mida del rectangle a dibuixar a dins del contexte
//    CGRect drawRect;
//    drawRect.origin.x =  (contextBounds.width - imageSize.width)/2;
//    drawRect.origin.y =  (contextBounds.height - imageSize.height)/2;
//    drawRect.size = imageSize;
//    
//    // escala que haurem d'aplicar al contexte abans de renderitzar
//    CGPoint targetScale;
//    targetScale.x = imageSize.width/selfSize.width;
//    targetScale.y = imageSize.height/selfSize.height;
//    
//    // fem el clip abans de traslladar i escalar el contexte
//    if ( radius > 0 )
//    {
//        addRoundedRectPath( bitmapContext, drawRect, radius*contentScale, 0);
//        CGContextClip(bitmapContext);
//    }
//    
//    // traslladem i escalem el contexte per renderitzar correctament el layer
//    CGContextTranslateCTM( bitmapContext, drawRect.origin.x, contextBounds.height-drawRect.origin.y) ;
//    CGContextScaleCTM( bitmapContext, targetScale.x, -targetScale.y ) ;
//    
//    [self.layer renderInContext:bitmapContext];
//    
//    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmapContext);
//    UIImage *image = [UIImage imageWithCGImage:newImageRef scale:contentScale orientation:UIImageOrientationUp];
//    
//    CGContextRelease(bitmapContext);
//    CGImageRelease(newImageRef);
//    CGColorSpaceRelease(genericColorSpace);
//    
////    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    
////    CGImageRef imageRef = image.CGImage;
////    CGSize cgSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
////    NSLog( @"CGimageSize:%@", NSStringFromCGSize(cgSize));
////    NSLog( @"imageSize:%@ imageScale:%g", NSStringFromCGSize(image.size), image.scale);
//    
//    return image;
//}
//
//
//
//
//
//
//- (CGSize)sizeWithContentMode:(UIViewContentMode)contentMode bounds:(CGSize)bounds
//{
//    CGSize selfSize = self.bounds.size;
//    
//    if ( contentMode == UIViewContentModeCenter )
//    {
//        return selfSize;
//    }
//    
//    else if ( contentMode == UIViewContentModeScaleToFill )
//    {
//        return bounds;
//    }
//    
//    else
//    {
//        CGFloat ratio = 1.0f;
//        CGFloat horizontalRatio = bounds.width / selfSize.width;
//        CGFloat verticalRatio = bounds.height / selfSize.height;
//    
//        if ( contentMode == UIViewContentModeScaleAspectFill )
//            ratio = MAX(horizontalRatio, verticalRatio);
//    
//        else if ( contentMode == UIViewContentModeScaleAspectFit )
//            ratio = MIN(horizontalRatio, verticalRatio);
//            
//        else
//            [NSException raise:NSInvalidArgumentException format:@"Unsupported content mode: %d", contentMode];
//    
//        selfSize.width *= ratio;
//        selfSize.height *= ratio;
//        return selfSize;
//    }
//}
//
//@end
//
//
//


//@implementation CALayer(screenShot)
@implementation UIView(screenShot)


- (CGSize)_sizeWithContentMode:(UIViewContentMode)contentMode bounds:(CGSize)bounds
{
    CGSize selfSize = self.bounds.size;
    
    if ( contentMode == UIViewContentModeCenter )
    {
        return selfSize;
    }
    
    else if ( contentMode == UIViewContentModeScaleToFill )
    {
        return bounds;
    }
    
    else
    {
        CGFloat ratio = 1.0f;
        CGFloat horizontalRatio = bounds.width / selfSize.width;
        CGFloat verticalRatio = bounds.height / selfSize.height;
    
        if ( contentMode == UIViewContentModeScaleAspectFill )
            ratio = MAX(horizontalRatio, verticalRatio);
    
        else if ( contentMode == UIViewContentModeScaleAspectFit )
            ratio = MIN(horizontalRatio, verticalRatio);
            
        else
            [NSException raise:NSInvalidArgumentException format:@"Unsupported content mode: %ld", (long)contentMode];
    
        selfSize.width *= ratio;
        selfSize.height *= ratio;
        return selfSize;
    }
}



- (UIImage *)imageFromViewHierarchy
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, self.window.screen.scale);

    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}
    
// http://stackoverflow.com/questions/19066717/how-to-render-view-into-image-faster

//dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
//dispatch_queue_t renderQueue = dispatch_queue_create("com.throttling.queue", NULL);
//
//- (void) capture
//{
//    if (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW) == 0) {
//        dispatch_async(renderQueue, ^{
//            // capture
//            dispatch_semaphore_signal(semaphore);
//        });
//    }
//}


- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds   // referit a punts (no pixels)
                    interpolationQuality:(CGInterpolationQuality)quality
                                  radius:(CGFloat)radius
                                 cropped:(BOOL)cropped
                         oflineRendering:(BOOL)offlineRendering
{
    // determinem la mida del view i la seva escala
    CGSize selfSize = self.bounds.size;
    CGFloat contentScale = [[UIScreen mainScreen] scale];
    
    // determinem la mida final en funcio del content mode i els bounds que volem
    CGSize imageSize = [self _sizeWithContentMode:contentMode bounds:bounds];  // ho torna referit a punts
    
    // el contexte que crearem no te nocio d'escala, per tant ajustem la mida de la imatge per tenir la maxima resolucio
    imageSize.width *= contentScale;
    imageSize.height *= contentScale;
    
    // en principi la mida del contexte es bounds (ajustat per l'escala)
    CGSize contextBounds;
    contextBounds.width = bounds.width*contentScale;
    contextBounds.height = bounds.height*contentScale;
    
    if ( cropped )
    {
        // ajustem el contexte perque no superi mai la mida maxima de l'imatge, volem que la imatge resizada no tingui artifactes al voltant
        if ( contextBounds.width > imageSize.width ) contextBounds.width = imageSize.width;
        if ( contextBounds.height > imageSize.height ) contextBounds.height = imageSize.height;
    }
    
    // creem un contexte per el renderitzat
    CGColorSpaceRef genericColorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo =  (CGBitmapInfo)kCGImageAlphaPremultipliedFirst /*| kCGBitmapByteOrderDefault*/;
    
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL,
                                                contextBounds.width,
                                                contextBounds.height,
                                                8, 
                                                0, /*(4 * contextBounds.width),*/
                                                genericColorSpace, 
                                                bitmapInfo);
    
    // mida del rectangle a dibuixar a dins del contexte
    CGRect drawRect;
    drawRect.origin.x =  (contextBounds.width - imageSize.width)/2;
    drawRect.origin.y =  (contextBounds.height - imageSize.height)/2;
    drawRect.size = imageSize;
    
    // escala que haurem d'aplicar al contexte abans de renderitzar
    CGPoint targetScale;
    targetScale.x = imageSize.width/selfSize.width;
    targetScale.y = imageSize.height/selfSize.height;
    
//    targetScale.x = drawRect.size.width/contextBounds.width;
//    targetScale.y = drawRect.size.height/contextBounds.height;
    
    // fem el clip abans de traslladar i escalar el contexte
    if ( radius > 0 )
    {
        CGRect clipRect = drawRect;
        if ( clipRect.size.width > contextBounds.width ) clipRect.size.width = contextBounds.width, clipRect.origin.x = 0;
        if ( clipRect.size.height > contextBounds.height ) clipRect.size.height = contextBounds.height, clipRect.origin.y = 0;
        addRoundedRectPath( bitmapContext, clipRect, radius*contentScale, 0);
        CGContextClip(bitmapContext);
    }
    
    // traslladem i escalem el contexte per renderitzar correctament el layer
    CGContextTranslateCTM( bitmapContext, drawRect.origin.x, contextBounds.height-drawRect.origin.y) ;
    CGContextScaleCTM( bitmapContext, targetScale.x, -targetScale.y ) ;
    
    if ( offlineRendering )
    {
        [self.layer renderInContext:bitmapContext];
    }
    else
    {
        UIGraphicsPushContext(bitmapContext);
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];   //
        UIGraphicsPopContext();
    }
    
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmapContext);
    UIImage *image = [UIImage imageWithCGImage:newImageRef scale:contentScale orientation:UIImageOrientationUp];
    
    CGContextRelease(bitmapContext);
    CGImageRelease(newImageRef);
    CGColorSpaceRelease(genericColorSpace);
    
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
//    CGImageRef imageRef = image.CGImage;
//    CGSize cgSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
//    NSLog( @"CGimageSize:%@", NSStringFromCGSize(cgSize));
//    NSLog( @"imageSize:%@ imageScale:%g", NSStringFromCGSize(image.size), image.scale);
    
    return image;
}



@end



















