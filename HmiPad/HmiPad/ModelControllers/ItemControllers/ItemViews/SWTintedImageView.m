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
//#import "SWTintedImageLayer.h"
#import "SWLayer.h"
#import "Drawing.h"

#import "UIImage+Resize.h"


//@interface SWTintedImageView()
//
//@property (nonatomic, readonly) UIEdgeInsets insets;
//@property (nonatomic, readonly) UIImage *image;
//@property (nonatomic, readonly) UIColor *tintsColor;
//@property (nonatomic, readonly) UIViewContentMode contentMode;
//@property (nonatomic, readonly) BOOL original;
//
//- (CGPoint)getCenterFlipped:(BOOL)isFlipped;
//
//@end


@interface SWTintedImageView()
{
    UIImage *_internalImage;
}

@property (nonatomic, readonly) UIEdgeInsets insets;
@property (nonatomic, readonly) UIColor *tintsColor;
@property (nonatomic, readonly) BOOL original;

@end



#pragma mark SWEmptyImage

@interface SWEmptyImageLayer : SWLayer
@end

@implementation SWEmptyImageLayer

//@synthesize hidden = _hidden;

- (void)drawInContext:(CGContextRef)context
{

//    [super drawInContext:context];

//    SWTintedImageView *v = (SWTintedImageView*)_v;
//    UIImage *image = v.image;
    
    //if ( self.hidden ) return;
    
    // sense imatge dibuixem un borde amb linees discontinues

    CGRect bounds = self.bounds;
    CGSize contextBounds = bounds.size;
    CGContextTranslateCTM(context, 0.0, contextBounds.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    const CGFloat lineWidth = 4;
    //const UIColor *lColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
    const UIColor *lColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
    const UIColor *fColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
    const CGRect innerRect = CGRectInset(bounds, lineWidth, lineWidth);
    const CGFloat lRadius = lineWidth;
    const CGFloat fRadius = lRadius+lineWidth;
        
    CGFloat phase = 0;
    const CGFloat lengths[] = { lineWidth*2, lineWidth*3 };
    
    // interior
    CGContextSetFillColorWithColor( context, fColor.CGColor );
    addRoundedRectPath( context, bounds, fRadius, 0 );
    CGContextFillPath(context);
        
    CGContextSetLineWidth(context, lineWidth );
//        CGContextSetStrokeColorWithColor( context, lColor.CGColor ) ;
//        addRoundedRectPath( context, innerRect, cornerRadius, 0 );
//        CGContextStrokePath( context );
    
    // linea borde
    CGContextSetStrokeColorWithColor( context, lColor.CGColor ) ;
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineDash( context, phase, lengths, sizeof(lengths)/sizeof(CGFloat));
    addRoundedRectPath( context, innerRect, lRadius, 0 );
    CGContextStrokePath( context );
}

@end




@implementation SWTintedImageView
{
    SWEmptyImageLayer *_emptyImageLayer;
    //NSString *_theContentsGravity;
}


@synthesize insets = _insets;
//@synthesize image = _image;
@synthesize tintsColor = _tintsColor;
//@synthesize contentMode = _contentMode;
@synthesize original = _original;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        CALayer *layer = (id)[self layer];
        
        _emptyImageLayer = [[SWEmptyImageLayer alloc] init];
        [_emptyImageLayer setView:self];
        _emptyImageLayer.frame = self.bounds;
        [layer addSublayer:_emptyImageLayer];
        
        _insets = UIEdgeInsetsMake( 0, 0, 0, 0 );
    }
    return self;
}

//- (CGPoint)getCenterFlipped:(BOOL)isFlipped
//{
//    CGPoint center;
//    CGSize size = self.bounds.size;
//	center.x = _insets.left + (size.width-_insets.left-_insets.right)/2.0f;;
//	center.y = _insets.bottom + (size.height-_insets.bottom-_insets.top)/2.0f;
//    if ( isFlipped ) center.y = size.height - center.y;    // compensem per y invertida en cocoa touch
//    return center;
//}



- (void)setFrame:(CGRect)rect
{
    [super setFrame:rect];
    if ( _internalImage == nil )
    {
        [self _update];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _emptyImageLayer.frame = self.bounds;
}


- (void)_update
{    
    [self.layer setNeedsLayout];
    if ( _internalImage == nil )
    {
        if ( _emptyImageLayer.hidden) [_emptyImageLayer setHidden:NO];
        [_emptyImageLayer setNeedsDisplay];
    }
    else
    {
        if ( !_emptyImageLayer.hidden) [_emptyImageLayer setHidden:YES];
    }
    
    //_imageLayer.contentsGravity = _theContentsGravity;
    
    if ( _tintsColor )
    {
        UIImage *tintedImage = nil;
        NSArray *images = _internalImage.images;
        if ( images != nil )
        {
            NSMutableArray *tintedImages = [NSMutableArray array];
            for ( UIImage *image in images )
                [tintedImages addObject:[image tintedImageWithColor:_tintsColor]];
                
            tintedImage = [UIImage animatedImageWithImages:tintedImages duration:_internalImage.duration];
        }
        else
        {
            tintedImage = [_internalImage tintedImageWithColor:_tintsColor];
        }
    
        //UIImage *tintedImage = [_internalImage tintedImageWithColor:_tintsColor];
        [self setImage:tintedImage];
    }
    else
    {
        [self setImage:_internalImage];
    }
}


- (void)setOriginalImage:(UIImage*)image
{
    _internalImage = image;
    _original = YES;
    [self _update];
}


- (void)setResizedImage:(UIImage*)image
{
    _internalImage = image;
    _original = NO;
    [self _update];
}


- (void)setRgbTintColor:(UInt32)rgbColor
{
    UIColor *tintsColor = nil;
 
    if (ColorA(rgbColor) >= 0.1)  // si no transparent
        tintsColor = UIColorWithRgb(rgbColor);
    
    _tintsColor = tintsColor;
    [self _update];
}

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    _imageLayer.frame = self.bounds;
//}

//- (void)setContentMode:(UIViewContentMode)contentMode
//{
//    [super setContentMode:contentMode];
//    _imageLayer.contentMode = contentMode;
//}


- (void)setContentMode:(UIViewContentMode)contentMode
{    
    [super setContentMode:contentMode];
    [self _update];
}


- (void)setZoomScaleFactor:(CGFloat)zoomScaleFactor
{
    [_emptyImageLayer setContentsScale:[[UIScreen mainScreen]scale]*zoomScaleFactor];
}

- (CGFloat)zoomScaleFactor
{
    CGFloat zoomScale = _emptyImageLayer.contentsScale/[[UIScreen mainScreen]scale];
    return zoomScale;
}

- (void)setContentScaleFactor:(CGFloat)contentScaleFactor
{
    // no cridem el super!
    //NSLog( @"contentScale" );
}


//- (void)setContentScaleFactor:(CGFloat)contentScaleFactor
//{
//    // no cridem el super!
//    
//    [_emptyImageLayer setContentsScale:contentScaleFactor];
//    [self _update];
//}


//....................................


//@interface SWImageLayer : SWLayer
//
//@end
//
//
//
//@implementation SWImageLayer
//
//-(void)setNeedsDisplayOnBoundsChange:(BOOL)value
//{
//    [super setNeedsDisplayOnBoundsChange:NO];
//}
//
//@end


#pragma mark SWImageViewLayer

//@interface SWImageViewLayer : SWLayer
//@end
//
//
//@implementation SWImageViewLayer
//- (id)init
//{
//    self = [super init] ;
//    if ( self )
//    {
//    }
//    return self ;
//}
//
//
//- (void)layoutSublayers
//{
//    [super layoutSublayers] ;
//        
//    CGRect bounds = self.bounds ;
//    Class imageLayerClass = [SWImageLayer class];
//    
//    for ( CALayer *layer in self.sublayers )
//    {
//        CGRect rect = bounds ;
//        if ( [layer isKindOfClass:imageLayerClass] )
//        {
////            UIEdgeInsets insets = v.insets;
////            rect.origin.x += insets.left ;
////            rect.origin.y += insets.top ;
////            rect.size.width -= insets.left+insets.right ;
////            rect.size.height -= insets.top+insets.bottom ;
//            
//            SWTintedImageView *v = (SWTintedImageView*)_v;
//            BOOL original = v.original;
//            CGRect imageRect = CGRectZero;
//            UIImage *image = v.image;
//            if ( original || image == nil )
//            {
//                imageRect.size = rect.size;
//            }
//            else
//            {
//                imageRect.size = image.size;
//            }
//
//            CGPoint center = [v getCenterFlipped:YES];
//            layer.bounds = imageRect;
//            layer.position = center;
//        }
//        else
//        {
//            layer.frame = rect ;
//        }
//        [layer setNeedsLayout] ;
//    }
//}
//
//@end



//@implementation SWTintedImageView
//{
//    SWImageLayer *_imageLayer;
//    SWEmptyImageLayer *_emptyImageLayer;
//    NSString *_theContentsGravity;
//}
//
//+ (Class)layerClass
//{
//    return [SWImageViewLayer class] ;
//}
//
//
//@synthesize insets = _insets;
//@synthesize image = _image;
//@synthesize tintsColor = _tintsColor;
//@synthesize contentMode = _contentMode;
//@synthesize original = _original;
//
//
//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self)
//    {
//        SWImageViewLayer *layer = (id)[self layer];
//        [layer setView:self];
//    
//        _imageLayer = [[SWImageLayer alloc ] init];
//        [_imageLayer setView:self];
//        [layer addSublayer:_imageLayer];
//        
//        _emptyImageLayer = [[SWEmptyImageLayer alloc] init];
//        [_emptyImageLayer setView:self];
//        [layer addSublayer:_emptyImageLayer];
//        
//        _insets = UIEdgeInsetsMake( 0, 0, 0, 0 );
//    }
//    return self;
//}
//
//- (CGPoint)getCenterFlipped:(BOOL)isFlipped
//{
//    CGPoint center;
//    CGSize size = self.bounds.size;
//	center.x = _insets.left + (size.width-_insets.left-_insets.right)/2.0f;;
//	center.y = _insets.bottom + (size.height-_insets.bottom-_insets.top)/2.0f;
//    if ( isFlipped ) center.y = size.height - center.y;    // compensem per y invertida en cocoa touch
//    return center;
//}
//
//
//
//- (void)setFrame:(CGRect)rect
//{
//    [super setFrame:rect];
//    if ( _image == nil )
//    {
//        [self _update];
//    }
//}
//
//
//- (void)_update
//{    
//    [self.layer setNeedsLayout];
//    if ( _image == nil )
//    {
//        if ( _emptyImageLayer.hidden) [_emptyImageLayer setHidden:NO];
//        [_emptyImageLayer setNeedsDisplay];
//    }
//    else
//    {
//        if ( !_emptyImageLayer.hidden) [_emptyImageLayer setHidden:YES];
//    }
//    
//    _imageLayer.contentsGravity = _theContentsGravity;
//    
//    if ( _tintsColor )
//    {
//        UIImage *tintedImage = [_image tintedImageWithColor:_tintsColor];
//        [_imageLayer setContents:(id)tintedImage.CGImage];
//    }
//    else
//    {
//        [_imageLayer setContents:(id)_image.CGImage];
//    }
//}
//
//
//
//- (void)setOriginalImage:(UIImage*)image
//{
//    _image = image;
//    _original = YES;
//    [self _update];
//}
//
//- (void)setResizedImage:(UIImage*)image
//{
//    _image = image;
//    _original = NO;
//    [self _update];
//}
//
//
//- (void)setRgbTintColor:(UInt32)rgbColor
//{
//    UIColor *tintsColor = nil;
// 
//    if (ColorA(rgbColor) >= 0.1)  // si no transparent
//        tintsColor = UIColorWithRgb(rgbColor);
//    
//    _tintsColor = tintsColor;
//    [self _update];
//}
//
////- (void)layoutSubviews
////{
////    [super layoutSubviews];
////    _imageLayer.frame = self.bounds;
////}
//
////- (void)setContentMode:(UIViewContentMode)contentMode
////{
////    [super setContentMode:contentMode];
////    _imageLayer.contentMode = contentMode;
////}
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
//    }
//    
//    _contentMode = contentMode;
//    _theContentsGravity = contentsGravity;
//    [self _update];
//}
//
//
//- (void)setZoomScaleFactor:(CGFloat)zoomScaleFactor
//{
//    [_emptyImageLayer setContentsScale:[[UIScreen mainScreen]scale]*zoomScaleFactor];
//}
//
//- (CGFloat)zoomScaleFactor
//{
//    CGFloat zoomScale = _emptyImageLayer.contentsScale/[[UIScreen mainScreen]scale];
//    return zoomScale;
//}
//
//
////- (void)setContentScaleFactor:(CGFloat)contentScaleFactor
////{
////    // no cridem el super!
////    
////    [_emptyImageLayer setContentsScale:contentScaleFactor];
////    [self _update];
////}

@end



