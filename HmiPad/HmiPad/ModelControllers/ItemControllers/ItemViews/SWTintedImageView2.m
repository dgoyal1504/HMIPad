//
//  SWTintedImageView.m
//  HmiPad
//
//  Created by Lluch Joan on 25/07/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SWColor.h"
#import "SWTintedImageView.h"
#import "UIImage+Resize.h"
#import "SWTintedImageLayer.h"


//@interface SWImageLayer : CALayer
//
//@property (nonatomic,strong) UIImage *image;
//@property (nonatomic,strong) UIColor *tintColor;
//@property (nonatomic,assign) UIViewContentMode contentMode;
//
//@end
//
//
//@implementation SWImageLayer
//{
//    UIImage *_theImage;
//}
//
//@synthesize image = _image;
//@synthesize tintColor = _tintColor;
//@synthesize contentMode = _contentMode;
//
//- (id)init
//{
//    self = [super init];
//    {
//        CGFloat scale = [UIScreen mainScreen].scale;
//        self.contentsScale = scale;
//        [self setNeedsDisplayOnBoundsChange:NO];
//    }
//    return self;
//}
//
//-(id<CAAction>)actionForKey:(NSString *)key 
//{
//    return nil;
//}
//
//- (void)drawInContext:(CGContextRef)context
//{
//    [super drawInContext:context];
//    if (_tintColor == nil || _theImage == nil )
//        return;
//    
//    CGRect bounds = self.bounds;
//       
//    CGContextTranslateCTM(context, 0.0, bounds.size.height);
//    CGContextScaleCTM(context, 1.0, -1.0);
//    
//    CGRect drawRect = [_theImage rectWithContentMode:_contentMode bounds:bounds.size scale:1];
//
//    CGContextDrawImage(context, drawRect, _theImage.CGImage);
//    
//    CGContextClipToMask(context, drawRect, _theImage.CGImage);
//    CGContextSetBlendMode( context, kCGBlendModeColor );
//
//    CGContextSetFillColorWithColor( context, _tintColor.CGColor );
//    CGContextFillRect(context, bounds);
//}
//
//
//
//- (void)_update
//{
//    _theImage = _image;
//    if ( _theImage == nil )
//    {
//        _theImage = [UIImage imageNamed:@"PhotoNoAvailable300.png"];
//        self.contentsGravity = kCAGravityResizeAspect;
//    }
//    
//    if ( _tintColor )
//    {
//        [self setNeedsDisplay];
//    }
//    else
//    {
//        [self setContents:(id)_theImage.CGImage];
//    }
//}
//
//
//- (void)setImage:(UIImage*)image
//{
//    _image = image;
//    [self _update];
//}
//
//
//- (void)setTintColor:(UIColor*)tintColor
//{
//    _tintColor = tintColor;
//    [self _update];
//}
//
//
//- (void)setFrame:(CGRect)frame
//{
//    [super setFrame:frame];
//    if ( _tintColor )
//        [self setNeedsDisplay];
//}
//
//
//- (void)setContentMode:(UIViewContentMode)contentMode
//{
//    NSString *contentsGravity = nil;
//    
//    switch( contentMode )
//    {
//        case UIViewContentModeScaleToFill:
//            contentsGravity = kCAGravityResize;
//            break;
//            
//        case UIViewContentModeScaleAspectFit:      // contents scaled to fit with fixed aspect. remainder is transparent
//            contentsGravity = kCAGravityResizeAspect;
//            break;
//            
//        case UIViewContentModeScaleAspectFill:     // contents scaled to fill with fixed aspect. some portion of content may be clipped.
//            contentsGravity = kCAGravityResizeAspectFill;
//            break;
//            
//        case UIViewContentModeCenter:              // contents remain same size. positioned adjusted.
//            contentsGravity = kCAGravityCenter;
//            break;
//        
//        default:
//            contentsGravity = nil;
//            NSAssert( NO, @"Content Mode not supported") ;
//            break;
//    
//    }
//    
//    _contentMode = contentMode;
//    self.contentsGravity = contentsGravity;
//    [self _update];
//}
//
//@end
//


@implementation SWTintedImageView
{
    SWImageLayer *_imageLayer;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        //_unavailableImage = [UIImage imageNamed:@"PhotoNoAvailable300.png"];
        _imageLayer = [[SWImageLayer alloc ] init];
        [self.layer addSublayer:_imageLayer];
    }
    return self;
}

//- (void)setImage:(UIImage*)image
//{
//    //UIViewContentMode contentMode = _imageLayer.contentMode;
//    
//    _imageLayer.image = image;
//    
//    //_imageLayer.contentMode = contentMode; // <----- Hem de mantenir el mateix contentMode després de canviar la imatge!
//}

- (void)setOriginalImage:(UIImage*)image
{
    [_imageLayer setOriginalImage:image];
}

- (void)setResizedImage:(UIImage*)image
{
    [_imageLayer setResizedImage:image];
}

- (void)setRgbTintColor:(UInt32)rgbColor
{
    UIColor *tintColor = nil;
 
       if (ColorA(rgbColor) >= 0.1)
        tintColor = UIColorWithRgb(rgbColor);
    
    _imageLayer.tintColor = tintColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _imageLayer.frame = self.bounds;
}

- (void)setContentMode:(UIViewContentMode)contentMode
{
    [super setContentMode:contentMode];
    _imageLayer.contentMode = contentMode;
}

@end


//@implementation SWTintedImageView
//{
//    UIColor *_tintColor;
//}
//
//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self)
//    {
//        // Initialization code
//        //[self setContentMode:UIViewContentModeRedraw];
//        
//        _unavailableImage = [UIImage imageNamed:@"PhotoNoAvailable300.png"];
//    }
//    return self;
//}
//
//- (void)drawRect:(CGRect)rect
//{
//    if (_tintColor == nil)
//        return;
//    
//    CGRect bounds = self.bounds;
//    
//    UIImage *image = [self _displayImage];
//
//    CGContextRef context = UIGraphicsGetCurrentContext();
//       
//    CGContextTranslateCTM(context, 0.0, bounds.size.height);
//    CGContextScaleCTM(context, 1.0, -1.0);
//    
//    CGRect drawRect = [image rectWithContentMode:self.contentMode bounds:bounds.size scale:1];
//
//    CGContextDrawImage(context, drawRect, image.CGImage);
//    
//    CGContextClipToMask(context, drawRect, image.CGImage);
//    CGContextSetBlendMode( context, kCGBlendModeColor );
//
//    CGContextSetFillColorWithColor( context, _tintColor.CGColor );
//    CGContextFillRect(context, bounds);
//}
//
//
//- (void)_update
//{
//    if (_tintColor)
//    {
//        if (_image || _unavailableImage)
//            [self setNeedsDisplay];
//    }
//    else
//    {
//        CALayer *layer = self.layer;
//        UIImage *image = [self _displayImage];
//        [layer setContents:(id)image.CGImage];
//    }
//}
//
//- (void)_update_V
//{
//    if (_image || _unavailableImage)
//        [self setNeedsDisplay];
//}
//
//- (UIImage*)_displayImage
//{
//    if (_image)
//        return _image;
//    
//    return _unavailableImage;
//}
//
//- (void)setImage:(UIImage*)image
//{
//    _image = image;
//    [self _update];
//}
//
//- (void)setUnavailableImage:(UIImage *)unavailableImage
//{
//    _unavailableImage = unavailableImage;
//    [self _update];
//}
//
//- (void)setRgbTintColor:(UInt32)rgbColor
//{
//    if (ColorA(rgbColor) < 0.1) // <----------------------- Valors de alfa < 0.1 ho considerem transparent
//        _tintColor = nil;
//    else
//        _tintColor = UIColorWithRgb(rgbColor);
//    
//    [self _update];
//}
//
//- (void)setFrame:(CGRect)rect
//{
//    [super setFrame:rect];
//    if ( _tintColor && (_image || _unavailableImage))
//        [self setNeedsDisplay];
//}
//
//- (void)setContentMode:(UIViewContentMode)contentMode
//{
//    [super setContentMode:contentMode];
//    if ( _tintColor && (_image || _unavailableImage))
//        [self setNeedsDisplay];
//}
//
//@end
