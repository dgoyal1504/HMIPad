//
//  SWTintedImageLayer.h
//  HmiPad
//
//  Created by Joan on 14/09/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface SWImageLayer : CALayer

@property (nonatomic,readonly) UIImage *image;
@property (nonatomic,strong) UIColor *tintColor;
@property (nonatomic,assign) UIViewContentMode contentMode;

- (void)setResizedImage:(UIImage*)image;
- (void)setOriginalImage:(UIImage*)image;

@end
