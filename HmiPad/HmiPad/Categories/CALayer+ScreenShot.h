//
//  UIView+ScreenShot.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/26/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

//@interface UIView (ScreenShot)
//
//- (UIImage *)screenShotWithScale:(CGFloat)scale;
//
//- (UIImage *)screenShotWithTargetHeight:(CGFloat)targetHeight;
//- (UIImage *)resizedImageWithContentModeDEP:(UIViewContentMode)contentMode
//                                  bounds:(CGSize)bounds   // referit a punts (no pixels)
//                    interpolationQuality:(CGInterpolationQuality)quality
//                                  radius:(CGFloat)radius
//                                 cropped:(BOOL)cropped;
//
//@end



//@interface CALayer (ScreenShot)
//
//- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
//                                  bounds:(CGSize)bounds   // referit a punts (no pixels)
//                    interpolationQuality:(CGInterpolationQuality)quality
//                                  radius:(CGFloat)radius
//                                 cropped:(BOOL)cropped;
//@end


@interface UIView (ScreenShot)

- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds   // referit a punts (no pixels)
                    interpolationQuality:(CGInterpolationQuality)quality
                                  radius:(CGFloat)radius
                                 cropped:(BOOL)cropped
                         oflineRendering:(BOOL)offlineRendering;
@end

