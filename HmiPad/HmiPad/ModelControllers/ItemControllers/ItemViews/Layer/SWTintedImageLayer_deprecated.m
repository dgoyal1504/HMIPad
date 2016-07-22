//
//  SWTintedImageLayer.m
//  HmiPad
//
//  Created by Joan on 14/09/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWTintedImageLayer.h"

#import "UIImage+Resize.h"
#import "Drawing.h"


@implementation SWImageLayer
{
    BOOL _original;
    NSString *_theContentsGravity;
    
}

@synthesize image = _image;
@synthesize tintColor = _tintColor;
@synthesize contentMode = _contentMode;

- (id)init
{
    self = [super init];
    {
        CGFloat scale = [UIScreen mainScreen].scale;
        self.contentsScale = scale;
        [self setNeedsDisplayOnBoundsChange:NO];
    }
    return self;
}

//-(id<CAAction>)actionForKey:(NSString *)key 
//{
////    return [super actionForKey:key];
//    return nil;
//}



-(id<CAAction>)actionForKey:(NSString *)key 
{
    CALayer *superlayer = [self superlayer] ;
//    if ( [superlayer isKindOfClass:[SWLayer class]] )
    {
        //if ( [key isEqualToString:@"position"] ) return nil ;
        //if ( [key isEqualToString:@"bounds"] ) return nil ;
        //if ( [key isEqualToString:@"onLayout"] ) return nil ;
        //if ( [key isEqualToString:@"contents"] ) return nil ;
        
        CABasicAnimation *theAnimation = nil ;
        CAAnimation *animation = [superlayer animationForKey:key] ;
        if ( animation )
        {
            theAnimation = [CABasicAnimation animationWithKeyPath:key] ;
            theAnimation.fromValue = [[self presentationLayer] valueForKey:key] ;
            theAnimation.timingFunction = animation.timingFunction ;
            theAnimation.duration = animation.duration ;
        }
        return theAnimation;
    }
    //return [super actionForKey:key] ;
}





















//- (void)drawInContextVV:(CGContextRef)context
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
//    CGRect drawRect = [_theImage rectWithContentMode:_contentMode bounds:bounds.size contentScale:self.contentsScale];
//    // ^ el layer ja te la escala adequada per tant aqui no hi ha necesitat de compensar
//
//    CGContextDrawImage(context, drawRect, _theImage.CGImage);
//    
//    CGContextClipToMask(context, drawRect, _theImage.CGImage);
//    CGContextSetBlendMode( context, kCGBlendModeColor );
//
//    CGContextSetFillColorWithColor( context, _tintColor.CGColor );
//    CGContextFillRect(context, bounds);
//}


- (void)drawInContext:(CGContextRef)context
{
    [super drawInContext:context];
//    if (_tintColor == nil || _theImage == nil )
//        return;

    if ( _image && _tintColor == nil )
        return;

    
    CGRect bounds = self.bounds;
    CGSize contextBounds = bounds.size;
    CGContextTranslateCTM(context, 0.0, contextBounds.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    if ( _image == nil )
    {
        const CGFloat lineWidth = 6;
        //const UIColor *lColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
        const UIColor *lColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
        const UIColor *fColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
        const CGRect innerRect = CGRectInset(bounds, lineWidth, lineWidth);
        const CGFloat lRadius = lineWidth;
        const CGFloat fRadius = lRadius+lineWidth;
        //SWStrokeStyle strokeStyle = v.strokeStyle;
        //if ( strokeStyle == SWStrokeStyleDash )
        
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
    else
    {

    
    //CGRect drawRect = [_theImage rectWithContentMode:_contentMode bounds:bounds.size contentScale:self.contentsScale];
    
        CGSize imageSize = [_image sizeWithContentMode:_contentMode bounds:contextBounds contentScale:self.contentsScale];
    
        CGRect drawRect;
        drawRect.origin.x =  (contextBounds.width - imageSize.width)/2;
        drawRect.origin.y =  (contextBounds.height - imageSize.height)/2;
        drawRect.size = imageSize;
    

        CGContextDrawImage(context, drawRect, _image.CGImage);
    
        CGContextClipToMask(context, drawRect, _image.CGImage);
        
        CGContextSetBlendMode( context, kCGBlendModeColor );

        CGContextSetFillColorWithColor( context, _tintColor.CGColor );
        CGContextFillRect(context, bounds);
    }
}



//- (void)_updateV
//{
//    _theImage = _image;
//    if ( _theImage == nil )
//    {
//        _theImage = [UIImage imageNamed:@"PhotoNoAvailable300.png"];
//        //self.contentsGravity = kCAGravityResizeAspect;
//    }
//    
//    if ( _tintColor )
//    {
//        [self setNeedsDisplay];
//    }
//    else
//    {
//        self.contentsGravity = _original?_theContentsGravity:kCAGravityCenter;
//        [self setContents:(id)_theImage.CGImage];
//    }
//}


- (void)_update
{
    
    if ( _tintColor || _image == nil )
    {
        [self setNeedsDisplay];
    }
    else
    {
        self.contentsGravity = _original?_theContentsGravity:kCAGravityCenter;
        [self setContents:(id)_image.CGImage];
    }
}


- (void)setOriginalImage:(UIImage*)image
{
    _image = image;
    _original = YES;
    [self _update];
}

- (void)setResizedImage:(UIImage*)image
{
    _image = image;
    _original = NO;
    [self _update];
}


- (void)setTintColor:(UIColor*)tintColor
{
    _tintColor = tintColor;
    [self _update];
}


- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if ( _tintColor )
       [self setNeedsDisplay];
}



- (void)setContentMode:(UIViewContentMode)contentMode
{
    NSString *contentsGravity = nil;
    
    switch( contentMode )
    {
        case UIViewContentModeScaleToFill:
            contentsGravity = kCAGravityResize;
            break;
            
        case UIViewContentModeScaleAspectFit:      // contents scaled to fit with fixed aspect. remainder is transparent
            contentsGravity = kCAGravityResizeAspect;
            break;
            
        case UIViewContentModeScaleAspectFill:     // contents scaled to fill with fixed aspect. some portion of content may be clipped.
            contentsGravity = kCAGravityResizeAspectFill;
            break;
            
        case UIViewContentModeCenter:              // contents remain same size. positioned adjusted.
            contentsGravity = kCAGravityCenter;
            break;
        
        default:
            contentsGravity = nil;
            NSAssert( NO, @"Content Mode not supported") ;
            break;
    
    }
    
    _contentMode = contentMode;
    _theContentsGravity = contentsGravity;
    [self _update];
}


@end

