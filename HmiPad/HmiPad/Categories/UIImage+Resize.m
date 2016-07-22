//
//  UIImage+Resize.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/5/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//  Codi tret de: http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/

#import "UIImage+Resize.h"

@implementation UIImage (Utils)

+ (NSArray*)supportedFileFormats
{
    static NSArray *array = nil;
    
    if (!array)
        array = [NSArray arrayWithObjects:@"png",@"jpg",@"jpeg",@"gif",@"tif",@"tiff",@"bmp",@"bmpf",@"ico",@"cur",@"xbm",nil];
    
    return array;
}

- (void)info
{
    UIImage* image = self;
    CGImageRef cgimage = image.CGImage;
    
    size_t width  = CGImageGetWidth(cgimage);
    size_t height = CGImageGetHeight(cgimage);
    
    size_t bpr = CGImageGetBytesPerRow(cgimage);
    size_t bpp = CGImageGetBitsPerPixel(cgimage);
    size_t bpc = CGImageGetBitsPerComponent(cgimage);
//    size_t bytes_per_pixel = bpp / bpc;
    
    CGBitmapInfo info = CGImageGetBitmapInfo(cgimage);
    
    NSLog(
          @"\n"
          "===== %@ =====\n"
          "CGImageGetHeight: %d\n"
          "CGImageGetWidth:  %d\n"
          "CGImageGetColorSpace: %@\n"
          "CGImageGetBitsPerPixel:     %d\n"
          "CGImageGetBitsPerComponent: %d\n"
          "CGImageGetBytesPerRow:      %d\n"
          "CGImageGetBitmapInfo: 0x%.8X\n"
          "  kCGBitmapAlphaInfoMask     = %s\n"
          "  kCGBitmapFloatComponents   = %s\n"
          "  kCGBitmapByteOrderMask     = %s\n"
          "  kCGBitmapByteOrderDefault  = %s\n"
          "  kCGBitmapByteOrder16Little = %s\n"
          "  kCGBitmapByteOrder32Little = %s\n"
          "  kCGBitmapByteOrder16Big    = %s\n"
          "  kCGBitmapByteOrder32Big    = %s\n",
          @"Image Info",
          (int)width,
          (int)height,
          CGImageGetColorSpace(cgimage),
          (int)bpp,
          (int)bpc,
          (int)bpr,
          (unsigned)info,
          (info & kCGBitmapAlphaInfoMask)     ? "YES" : "NO",
          (info & kCGBitmapFloatComponents)   ? "YES" : "NO",
          (info & kCGBitmapByteOrderMask)     ? "YES" : "NO",
          (info & kCGBitmapByteOrderDefault)  ? "YES" : "NO",
          (info & kCGBitmapByteOrder16Little) ? "YES" : "NO",
          (info & kCGBitmapByteOrder32Little) ? "YES" : "NO",
          (info & kCGBitmapByteOrder16Big)    ? "YES" : "NO",
          (info & kCGBitmapByteOrder32Big)    ? "YES" : "NO"
          );
    
//    CGDataProviderRef provider = CGImageGetDataProvider(cgimage);
//    NSData* data = (__bridge id)CGDataProviderCopyData(provider);
//
//    const uint8_t* bytes = [data bytes];
//    
//    printf("Pixel Data:\n");
//    for(size_t row = 0; row < height; row++)
//    {
//        for(size_t col = 0; col < width; col++)
//        {
//            const uint8_t* pixel =
//            &bytes[row * bpr + col * bytes_per_pixel];
//            
//            printf("(");
//            for(size_t x = 0; x < bytes_per_pixel; x++)
//            {
//                printf("%.2X", pixel[x]);
//                if( x < bytes_per_pixel - 1 )
//                    printf(",");
//            }
//            
//            printf(")");
//            if( col < width - 1 )
//                printf(", ");
//        }
//        printf("\n");
//    }
}

@end

#pragma mark - Alpha Category

@implementation UIImage (Alpha)

// Returns true if the image has an alpha layer
- (BOOL)hasAlpha {
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(self.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

// Returns a copy of the given image, adding an alpha channel if it doesn't already have one
- (UIImage *)imageWithAlpha 
{
    if ([self hasAlpha]) {
        return self;
    }
    
    CGImageRef imageRef = self.CGImage;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    // The bitsPerComponent and bitmapInfo values are hard-coded to prevent an "unsupported parameter combination" error
    CGContextRef offscreenContext = CGBitmapContextCreate(NULL,
                                                          width,
                                                          height,
                                                          8,
                                                          0,
                                                          CGImageGetColorSpace(imageRef),
                                                          kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    
    // Draw the image into the context and retrieve the new image, which will now have an alpha layer
    CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef imageRefWithAlpha = CGBitmapContextCreateImage(offscreenContext);
    //UIImage *imageWithAlpha = [UIImage imageWithCGImage:imageRefWithAlpha];
    UIImage *imageWithAlpha = [UIImage imageWithCGImage:imageRefWithAlpha scale:self.scale orientation:self.imageOrientation];
    
    // Clean up
    CGContextRelease(offscreenContext);
    CGImageRelease(imageRefWithAlpha);
    
    return imageWithAlpha;
}

// Returns a copy of the image with a transparent border of the given size added around its edges.
// If the image has no alpha layer, one will be added to it.
// ATENCIO Crec que falla per retina display
- (UIImage *)transparentBorderImage:(NSUInteger)borderSize contentScale:(CGFloat)contentScale
{
    CGImageRef imageRef = self.CGImage;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);    
    borderSize *= contentScale;
    
    // If the image does not have an alpha layer, add one
    UIImage *image = [self imageWithAlpha];
    
    CGRect newRect = CGRectMake(0, 0, width + borderSize*2, height + borderSize*2);
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(self.CGImage),
                                                0,
                                                CGImageGetColorSpace(self.CGImage),
                                                CGImageGetBitmapInfo(self.CGImage));
    
    // Draw the image in the center of the context, leaving a gap around the edges
    CGRect imageLocation = CGRectMake(borderSize, borderSize, width, height);
    CGContextDrawImage(bitmap, imageLocation, image.CGImage);
    CGImageRef borderImageRef = CGBitmapContextCreateImage(bitmap);
    
    // Create a mask to make the border transparent, and combine it with the image
    CGImageRef maskImageRef = [self _newBorderMask:borderSize size:newRect.size];
    CGImageRef transparentBorderImageRef = CGImageCreateWithMask(borderImageRef, maskImageRef);
    //UIImage *transparentBorderImage = [UIImage imageWithCGImage:transparentBorderImageRef];
    UIImage *transparentBorderImage = [UIImage imageWithCGImage:transparentBorderImageRef scale:self.scale orientation:self.imageOrientation];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(borderImageRef);
    CGImageRelease(maskImageRef);
    CGImageRelease(transparentBorderImageRef);
    
    return transparentBorderImage;
}

#pragma mark Private helper methods

// Creates a mask that makes the outer edges transparent and everything else opaque
// The size must include the entire mask (opaque part + transparent border)
// The caller is responsible for releasing the returned reference by calling CGImageRelease
// dimensions relatives al contexte
- (CGImageRef)_newBorderMask:(NSUInteger)borderSize size:(CGSize)size
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Build a context that's the same dimensions as the new size
    CGContextRef maskContext = CGBitmapContextCreate(NULL,
                                                     size.width,
                                                     size.height,
                                                     8, // 8-bit grayscale
                                                     0,
                                                     colorSpace,
                                                     kCGBitmapByteOrderDefault | kCGImageAlphaNone);
    
    // Start with a mask that's entirely transparent
    CGContextSetFillColorWithColor(maskContext, [UIColor blackColor].CGColor);
    CGContextFillRect(maskContext, CGRectMake(0, 0, size.width, size.height));
    
    // Make the inner part (within the border) opaque
    CGContextSetFillColorWithColor(maskContext, [UIColor whiteColor].CGColor);
    CGContextFillRect(maskContext, CGRectMake(borderSize, borderSize, size.width - borderSize * 2, size.height - borderSize * 2));
    
    // Get an image of the context
    CGImageRef maskImageRef = CGBitmapContextCreateImage(maskContext);
    
    // Clean up
    CGContextRelease(maskContext);
    CGColorSpaceRelease(colorSpace);
    
    return maskImageRef;
}

@end

#pragma mark - RoundedCorner Category

@implementation UIImage (RoundedCorner)

// Creates a copy of this image with rounded corners
// If borderSize is non-zero, a transparent border of the given size will also be added
// Original author: BjÃ¶rn SÃ¥llarp. Used with permission. See: http://blog.sallarp.com/iphone-uiimage-round-corners/
- (UIImage *)roundedCornerImage:(NSInteger)cornerRadius borderSize:(NSInteger)borderSize contentScale:(CGFloat)contentScale
{
    CGImageRef imageRef = self.CGImage;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    cornerRadius *= contentScale;
    borderSize *= contentScale;
    
    // If the image does not have an alpha layer, add one
    UIImage *image = [self imageWithAlpha];
    
    // Build a context that's the same dimensions as the new size
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 width,
                                                 height,
                                                 CGImageGetBitsPerComponent(image.CGImage),
                                                 0,
                                                 CGImageGetColorSpace(image.CGImage),
                                                 CGImageGetBitmapInfo(image.CGImage));
    
    // Create a clipping path with rounded corners
    CGContextBeginPath(context);
    [self addRoundedRectToPath:CGRectMake(borderSize, borderSize, width - borderSize * 2, height - borderSize * 2)
                       context:context
                     ovalWidth:cornerRadius
                    ovalHeight:cornerRadius];   
    CGContextClosePath(context);
    CGContextClip(context);
    
    // Draw the image to the context; the clipping path will make anything outside the rounded rect transparent
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image.CGImage);
    
    // Create a CGImage from the context
    CGImageRef clippedImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    // Create a UIImage from the CGImage
    //UIImage *roundedImage = [UIImage imageWithCGImage:clippedImage];
    UIImage *roundedImage = [UIImage imageWithCGImage:clippedImage scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(clippedImage);
    
    return roundedImage;
}

#pragma mark Private helper methods

// Adds a rectangular path to the given context and rounds its corners by the given extents
// Original author: BjÃ¶rn SÃ¥llarp. Used with permission. See: http://blog.sallarp.com/iphone-uiimage-round-corners/
// Dimensions relatives al contexte !
- (void)addRoundedRectToPath:(CGRect)rect context:(CGContextRef)context ovalWidth:(CGFloat)ovalWidth ovalHeight:(CGFloat)ovalHeight 
{
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    CGFloat fw = CGRectGetWidth(rect) / ovalWidth;
    CGFloat fh = CGRectGetHeight(rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

@end


#pragma mark - Tint Category

@implementation UIImage (TintColor)

- (UIImage *)tintedImageWithColor:(UIColor*)tintColor
{
    CGImageRef imageRef = self.CGImage;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    // If the image does not have an alpha layer, add one
    //UIImage *image = [self imageWithAlpha];
    UIImage *image = self;
    
    
    
    // Build a context that's the same dimensions as the new size
//    CGContextRef context = CGBitmapContextCreate(NULL,
//                                                 width,
//                                                 height,
//                                                 CGImageGetBitsPerComponent(image.CGImage),
//                                                 0,
//                                                 CGImageGetColorSpace(image.CGImage),
//                                                 CGImageGetBitmapInfo(image.CGImage) | CGImageGetAlphaInfo(image.CGImage));
    
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 width,
                                                 height,
                                                 CGImageGetBitsPerComponent(image.CGImage),
                                                 0,
                                                 rgb,
                                                 kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);

    CGColorSpaceRelease(rgb);

    CGRect drawRect =  CGRectMake(0, 0, width, height);
    CGContextDrawImage(context, drawRect, image.CGImage);
    CGContextClipToMask(context, drawRect, image.CGImage);
    CGContextSetBlendMode( context, kCGBlendModeColor );

    CGContextSetFillColorWithColor( context, tintColor.CGColor );
    CGContextFillRect(context, drawRect);

    CGImageRef tintedImageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    UIImage *tintedImage = [UIImage imageWithCGImage:tintedImageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(tintedImageRef);

    return tintedImage;
}

@end


#pragma mark - Resize Category

@implementation UIImage (Resize)

//- (BOOL)hasValidContext
//{
//    CGImageRef imageRef = self.CGImage;
//    
//    //CGSize pixelsSize = CGSizeMake(0,0);
//    CGSize pixelsSize = CGSizeMake(self.size.width * self.scale, self.size.height * self.scale);
//    
//    CGColorSpaceRef colorSpaceRef = CGImageGetColorSpace(imageRef);
//    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
//    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
//    size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
//    
//    CGContextRef bitmap = CGBitmapContextCreate(NULL,
//                                                pixelsSize.width,
//                                                pixelsSize.height,
//                                                bitsPerComponent,
//                                                bytesPerRow,
//                                                colorSpaceRef,
//                                                bitmapInfo);
//    
//    BOOL returnValue = YES;
//    
//    if (bitmap == NULL)
//        returnValue = NO;
//    
//    CGContextRelease(bitmap);
//    
//    return returnValue;
//}
//
//- (UIImage *)normalize 
//{
//    CGFloat screenScale = [[UIScreen mainScreen] scale];
//    
//    CGSize size = CGSizeMake(round(self.size.width*screenScale), round(self.size.height*screenScale));
//    CGColorSpaceRef genericColorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef thumbBitmapCtxt = CGBitmapContextCreate(NULL, 
//                                                         size.width, 
//                                                         size.height, 
//                                                         8, 
//                                                         (4 * size.width), 
//                                                         genericColorSpace, 
//                                                         kCGImageAlphaPremultipliedFirst);
//    CGColorSpaceRelease(genericColorSpace);
//    CGContextSetInterpolationQuality(thumbBitmapCtxt, INTERPOLATION_QUALITY);
//    CGRect destRect = CGRectMake(0, 0, size.width, size.height);
//    CGContextDrawImage(thumbBitmapCtxt, destRect, self.CGImage);
//    CGImageRef tmpThumbImage = CGBitmapContextCreateImage(thumbBitmapCtxt);
//    CGContextRelease(thumbBitmapCtxt);    
//    UIImage *result = [UIImage imageWithCGImage:tmpThumbImage scale:screenScale orientation:UIImageOrientationUp];
//    CGImageRelease(tmpThumbImage);
//    
//    return result;
//}

// Returns a copy of this image that is cropped to the given bounds.
// The bounds will be adjusted using CGRectIntegral.
// This method ignores the image's imageOrientation setting.
- (UIImage *)croppedImage:(CGRect)bounds contentScale:(CGFloat)contentScale
{
    UIImage *croppedImage = nil;
            
    CGRect rect = bounds;
    rect.origin.x *= contentScale;
    rect.origin.y *= contentScale;
    rect.size.width *= contentScale;
    rect.size.height *= contentScale;

    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    croppedImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    
    return croppedImage;
}

// Returns a copy of this image that is squared to the thumbnail size.
// If transparentBorder is non-zero, a transparent border of the given size will be added around the edges of the thumbnail. (Adding a transparent border of at least one pixel in size has the side-effect of antialiasing the edges of the image when rotating it using Core Animation.)
- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize
          transparentBorder:(NSUInteger)borderSize
               cornerRadius:(NSUInteger)cornerRadius
       interpolationQuality:(CGInterpolationQuality)quality 
{

    CGFloat screenScale = [[UIScreen mainScreen] scale];
    UIImage *resizedImage = [self resizedImageWithContentMode:UIViewContentModeScaleAspectFill
                                                       bounds:CGSizeMake(thumbnailSize, thumbnailSize)
                                            contentScale:screenScale
                                         interpolationQuality:quality
                                             cropped:NO];
    
    // Crop out any part of the image that's larger than the thumbnail size
    // The cropped rect must be centered on the resized image
    // Round the origin points so that the size isn't altered when CGRectIntegral is later invoked
    CGRect cropRect = CGRectMake(round((resizedImage.size.width - thumbnailSize) / 2),
                                 round((resizedImage.size.height - thumbnailSize) / 2),
                                 thumbnailSize,
                                 thumbnailSize);
    UIImage *croppedImage = [resizedImage croppedImage:cropRect contentScale:screenScale];
    
    UIImage *transparentBorderImage = borderSize ? [croppedImage transparentBorderImage:borderSize contentScale:screenScale] : croppedImage;
    
    
    return [transparentBorderImage roundedCornerImage:cornerRadius borderSize:borderSize contentScale:screenScale];
}





- (CGSize)sizeWithContentMode:(UIViewContentMode)contentMode bounds:(CGSize)bounds contentScale:(CGFloat)contentScale
{
    if ( contentScale == 0 ) contentScale = [[UIScreen mainScreen] scale];

    CGSize selfSize = self.size;
    CGFloat selfScale = self.scale;
    selfSize.width = selfSize.width*selfScale/contentScale;
    selfSize.height = selfSize.height*selfScale/contentScale;
    
// aixo es suposadament el mateix
//    CGImageRef imageRef = self.CGImage;
//    CGSize selfSize;
//    selfSize.width = CGImageGetWidth(imageRef)/contentScale;
//    selfSize.height = CGImageGetHeight(imageRef)/contentScale;
    
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



- (CGRect)rectWithContentMode_deprecated:(UIViewContentMode)contentMode bounds:(CGSize)bounds contentScale:(CGFloat)contentScale
{
    CGRect rect;
    CGSize selfSize = self.size;
    CGFloat selfScale = self.scale;
    selfSize.width = selfSize.width*selfScale/contentScale;
    selfSize.height = selfSize.height*selfScale/contentScale;
    
    if ( contentMode == UIViewContentModeCenter )
    {
        rect.size = selfSize;
    }
    
    else if ( contentMode == UIViewContentModeScaleToFill )
    {
        rect.size = bounds;
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
    
        rect.size.width = selfSize.width * ratio;
        rect.size.height = selfSize.height * ratio;
    }
    rect.origin.x =  (bounds.width - rect.size.width)/2;
    rect.origin.y =  (bounds.height - rect.size.height)/2;
    
    return rect;
}


// Resizes the image according to the given content mode, taking into account the image's orientation
- (UIImage *)resizedImageWithContentMode_V:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                            contentScale:(CGFloat)contentScale
                    interpolationQuality:(CGInterpolationQuality)quality 
{            
    
    //UIImage *image = [self resizedImageWithContentMode:contentMode intoBounds:bounds interpolationQuality:quality];
    
    //    CGFloat screenScale = [[UIScreen mainScreen] scale];
    CGSize newBounds = CGSizeMake(bounds.width*contentScale, bounds.height*contentScale);
    
    CGColorSpaceRef genericColorSpace = CGColorSpaceCreateDeviceRGB();
    
//    //CGImageAlphaInfo alfaInfo = CGImageGetAlphaInfo(self.CGImage);
    CGImageRef cgImage = self.CGImage;
//    size_t bitsPerComponent = CGImageGetBitsPerComponent(cgImage);
//    //size_t bitsPerPixel = CGImageGetBitsPerPixel(cgImage);
//    size_t bytesPerRow = CGImageGetBytesPerRow(cgImage);
//    CGColorSpaceRef colorSpace = CGImageGetColorSpace(cgImage);
//    //size_t numberOfComponents = CGColorSpaceGetNumberOfComponents(colorSpace);
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(cgImage);
//    //size_t newBytesPerRow = (bitsPerPixel*numberOfComponents/8)*newBounds.width;
//    size_t width = CGImageGetWidth(cgImage);
//    size_t newBytesPerRow = (bytesPerRow/width)*newBounds.width;
//    
//    // Build a context that's the same dimensions as the new size
//    CGContextRef bitmapContext = CGBitmapContextCreate(NULL,
//                                                newBounds.width,
//                                                newBounds.height,
//                                                bitsPerComponent, 
//                                                newBytesPerRow, 
//                                                colorSpace, 
//                                                bitmapInfo /*kCGImageAlphaPremultipliedFirst*/);
////                                                CGImageGetBitsPerComponent(imageRef),
////                                                CGImageGetBytesPerRow(imageRef),
////                                                CGImageGetColorSpace(imageRef),
////                                                CGImageGetBitmapInfo(imageRef));
//    
    
    
    if ( bitmapInfo != kCGImageAlphaNoneSkipLast && bitmapInfo != kCGImageAlphaNoneSkipFirst )
        bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little;
    
    
    // CALCULAR LA MIDA de la imatge abans que el context, si la imatge es mes petita ajustar el context a la mida de la imatge
    
    
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL,
                                                newBounds.width,
                                                newBounds.height,
                                                8, 
                                                (4 * newBounds.width), 
                                                genericColorSpace, 
                                                bitmapInfo);
//                                                CGImageGetBitsPerComponent(imageRef),
//                                                CGImageGetBytesPerRow(imageRef),
//                                                CGImageGetColorSpace(imageRef),
//                                                CGImageGetBitmapInfo(imageRef));
    
    CGColorSpaceRelease(genericColorSpace);
    
    [self drawInContext:bitmapContext withContentMode:contentMode bounds:bounds interpolationQuality:quality contentScale:contentScale];
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmapContext);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:contentScale orientation:UIImageOrientationUp];
    
    // Clean up
    CGContextRelease(bitmapContext);
    CGImageRelease(newImageRef);
    
    return newImage;
        
    if (CGSizeEqualToSize(newImage.size, CGSizeZero))
        return nil;
    
    return newImage;
}





// Resizes the image according to the given content mode
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds   // referit a punts (no pixels)
                            contentScale:(CGFloat)contentScale
                    interpolationQuality:(CGInterpolationQuality)quality
                                 cropped:(BOOL)cropped
{
    
    
    CGImageRef cgImage = self.CGImage;
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(cgImage);
    
    // provem de mantenir el bitMapInfo el mes semblant al original
    if ( (bitmapInfo&kCGBitmapAlphaInfoMask) != kCGImageAlphaNoneSkipLast &&
        (bitmapInfo&kCGBitmapAlphaInfoMask) != kCGImageAlphaNoneSkipFirst )
    {
        bitmapInfo = (CGBitmapInfo)kCGImageAlphaPremultipliedFirst /*| kCGBitmapByteOrderDefault*/ ; // kCGBitmapByteOrder32Little;
    }
    
    if ( contentScale == 0 ) contentScale = [[UIScreen mainScreen] scale];
    
    // calculem la mida de la imatge resizada a dintre de bounds d'acord al contextMode
    CGSize imageSize = [self sizeWithContentMode:contentMode bounds:bounds contentScale:contentScale];  // ho torna referit a punts

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

    // treballem amb espai RGB
    CGColorSpaceRef genericColorSpace = CGColorSpaceCreateDeviceRGB();
    
    // creem un contexte amb les propietats que hem determinat
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL,
                                                contextBounds.width,
                                                contextBounds.height,
                                                8, 
                                                0, /*(4 * contextBounds.width),*/
                                                genericColorSpace, 
                                                bitmapInfo);
//                                                CGImageGetBitsPerComponent(imageRef),
//                                                CGImageGetBytesPerRow(imageRef),
//                                                CGImageGetColorSpace(imageRef),
//                                                CGImageGetBitmapInfo(imageRef));

    // centrem la imatge a dins del contexte
    CGRect drawRect;
    drawRect.origin.x =  (contextBounds.width - imageSize.width)/2;
    drawRect.origin.y =  (contextBounds.height - imageSize.height)/2;
    drawRect.size = imageSize;
    
    // dibuixem la imatge a dins del context, la imatge sencera es dibuixara en el drawRect, i per tant quedara escalada d'acord al contentMode
    // Atencio: no tenim en compte la orientacio, per veure com mirar la implementacio de drawInContext (ara no utilitzada)
    CGContextSetInterpolationQuality(bitmapContext, quality);
    CGContextDrawImage(bitmapContext, drawRect, self.CGImage);
    
    // Obtenim la imatge resizada del contexte i en creem una UIImage adequada
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmapContext);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:contentScale orientation:UIImageOrientationUp];
    
    // Clean up
    CGContextRelease(bitmapContext);
    CGImageRelease(newImageRef);
    CGColorSpaceRelease(genericColorSpace);
    
    return newImage;
        
//    if (CGSizeEqualToSize(newImage.size, CGSizeZero))
//        return nil;
//    
//    return newImage;
}




#pragma mark Private helper methods

// ATENCIO: No esborrar. No utilitzada, mantenir aqui per futura referencia
- (void)drawInContext:(CGContextRef)context 
        withContentMode:(UIViewContentMode)contentMode 
        bounds:(CGSize)bounds 
        interpolationQuality:(CGInterpolationQuality)quality
        contentScale:(CGFloat)contentsScale
{

    CGRect newRect = [self rectWithContentMode_deprecated:contentMode bounds:bounds contentScale:contentsScale];
    
    newRect.origin.x *= contentsScale;
    newRect.origin.y *= contentsScale;
    newRect.size.width *= contentsScale;
    newRect.size.height *= contentsScale;
    
    BOOL transpose;
    switch (self.imageOrientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transpose = YES;
            break;
            
        default:
            transpose = NO;
    }
    
    CGAffineTransform transform = [self transformForOrientation:newRect.size];
    newRect = CGRectIntegral(newRect);
    
    if ( transpose )
        newRect = CGRectMake(newRect.origin.x, newRect.origin.y, newRect.size.height, newRect.size.width);

    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(context, transform);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(context, quality);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(context, newRect, self.CGImage);
}

//
//
//// Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
//// The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
//// If the new size is not integral, it will be rounded up
//- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
//                intoBounds:(CGSize)bounds
////                transform:(CGAffineTransform)transform
////           drawTransposed:(BOOL)transpose
//     interpolationQuality:(CGInterpolationQuality)quality 
//{
//
//    CGFloat screenScale = [[UIScreen mainScreen] scale];
//    CGSize newBounds = CGSizeMake(bounds.width*screenScale, bounds.height*screenScale);
//    
//    CGColorSpaceRef genericColorSpace = CGColorSpaceCreateDeviceRGB();
//    
////    //CGImageAlphaInfo alfaInfo = CGImageGetAlphaInfo(self.CGImage);
//    CGImageRef cgImage = self.CGImage;
////    size_t bitsPerComponent = CGImageGetBitsPerComponent(cgImage);
////    //size_t bitsPerPixel = CGImageGetBitsPerPixel(cgImage);
////    size_t bytesPerRow = CGImageGetBytesPerRow(cgImage);
////    CGColorSpaceRef colorSpace = CGImageGetColorSpace(cgImage);
////    //size_t numberOfComponents = CGColorSpaceGetNumberOfComponents(colorSpace);
//    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(cgImage);
////    //size_t newBytesPerRow = (bitsPerPixel*numberOfComponents/8)*newBounds.width;
////    size_t width = CGImageGetWidth(cgImage);
////    size_t newBytesPerRow = (bytesPerRow/width)*newBounds.width;
////    
////    // Build a context that's the same dimensions as the new size
////    CGContextRef bitmapContext = CGBitmapContextCreate(NULL,
////                                                newBounds.width,
////                                                newBounds.height,
////                                                bitsPerComponent, 
////                                                newBytesPerRow, 
////                                                colorSpace, 
////                                                bitmapInfo /*kCGImageAlphaPremultipliedFirst*/);
//////                                                CGImageGetBitsPerComponent(imageRef),
//////                                                CGImageGetBytesPerRow(imageRef),
//////                                                CGImageGetColorSpace(imageRef),
//////                                                CGImageGetBitmapInfo(imageRef));
////    
//    
//    
//    //if ( bitmapInfo != kCGImageAlphaNoneSkipLast && bitmapInfo != kCGImageAlphaNoneSkipFirst )
//        bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little;
//    
//    // Build a context that's the same dimensions as the new size
//    CGContextRef bitmapContext = CGBitmapContextCreate(NULL,
//                                                newBounds.width,
//                                                newBounds.height,
//                                                8, 
//                                                (4 * newBounds.width), 
//                                                genericColorSpace, 
//                                                bitmapInfo);
////                                                CGImageGetBitsPerComponent(imageRef),
////                                                CGImageGetBytesPerRow(imageRef),
////                                                CGImageGetColorSpace(imageRef),
////                                                CGImageGetBitmapInfo(imageRef));
//    
//    CGColorSpaceRelease(genericColorSpace);
//    
//    [self drawInContext:bitmapContext withContentMode:contentMode bounds:bounds interpolationQuality:quality contentScale:screenScale];
//    
//    // Get the resized image from the context and a UIImage
//    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmapContext);
//    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:screenScale orientation:UIImageOrientationUp];
//    
//    // Clean up
//    CGContextRelease(bitmapContext);
//    CGImageRelease(newImageRef);
//    
//    return newImage;
//}



// Returns an affine transform that takes into account the image orientation when drawing a scaled image
- (CGAffineTransform)transformForOrientation:(CGSize)newSize 
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    NSInteger imageOrientation = self.imageOrientation;
    
    switch (imageOrientation)
    {
        case UIImageOrientationDown:           // EXIF = 3
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:           // EXIF = 6
        case UIImageOrientationLeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
    }
    
    switch (imageOrientation)
    {
        case UIImageOrientationUpMirrored:     // EXIF = 2
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
    }
    
    return transform;
}



//- (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2 {
//    UIGraphicsBeginImageContext(image1.size);
//    
//    // Draw image1
//    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];
//    
//    // Draw image2
//    [image2 drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];
//    
//    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
//    
//    UIGraphicsEndImageContext();
//    
//    return resultingImage;
//}



@end