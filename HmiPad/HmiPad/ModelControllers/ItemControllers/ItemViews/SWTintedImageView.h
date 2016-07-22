//
//  SWTintedImageView.h
//  HmiPad
//
//  Created by Lluch Joan on 25/07/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWZoomableViewController.h"

//@interface SWTintedImageView : UIView<SWZoomableViewController>
//
////- (void)setImage:(UIImage *)image;
//- (void)setRgbTintColor:(UInt32)rgbTintColor;
//- (void)setContentMode:(UIViewContentMode)contentMode;
//
//- (void)setOriginalImage:(UIImage*)image;
//- (void)setResizedImage:(UIImage*)image;
////- (void)setEditingFrame:(CGRect)rect;
//
//@end


@interface SWTintedImageView : UIImageView<SWZoomableViewController>

//- (void)setImage:(UIImage *)image;
- (void)setRgbTintColor:(UInt32)rgbTintColor;
- (void)setContentMode:(UIViewContentMode)contentMode;

- (void)setOriginalImage:(UIImage*)image;
- (void)setResizedImage:(UIImage*)image;

@end