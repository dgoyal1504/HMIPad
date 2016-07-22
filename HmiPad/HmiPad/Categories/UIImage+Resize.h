//
//  UIImage+Resize.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/5/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//  Codi tret de: http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/

#import <UIKit/UIKit.h>

#define INTERPOLATION_QUALITY kCGInterpolationDefault
//#define INTERPOLATION_QUALITY kCGInterpolationHigh
@interface UIImage (Utils)

+ (NSArray*)supportedFileFormats;

- (void)info;

@end

// Helper methods for adding an alpha layer to an image
@interface UIImage (Alpha)

- (BOOL)hasAlpha;

- (UIImage *)imageWithAlpha;

//- (UIImage *)transparentBorderImage:(NSUInteger)borderSize;
- (UIImage *)transparentBorderImage:(NSUInteger)borderSize contentScale:(CGFloat)contentScale;

@end

// Extends the UIImage class to support making rounded corners
@interface UIImage (RoundedCorner)

//- (UIImage *)roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize;
- (UIImage *)roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize contentScale:(CGFloat)contentScale;

@end

@interface UIImage (TintColor)

- (UIImage *)tintedImageWithColor:(UIColor*)tintColor;

@end

// Extends the UIImage class to support resizing/cropping
@interface UIImage (Resize)

- (CGSize)sizeWithContentMode:(UIViewContentMode)contentMode bounds:(CGSize)bounds contentScale:(CGFloat)contentScale;

//- (void)drawInContext:(CGContextRef)context
//        withContentMode:(UIViewContentMode)contentMode 
//        bounds:(CGSize)bounds 
//        interpolationQuality:(CGInterpolationQuality)quality
//        contentScale:(CGFloat)contentScale;

- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                            contentScale:(CGFloat)contentScale
                    interpolationQuality:(CGInterpolationQuality)quality
                                 cropped:(BOOL)croped;

@end