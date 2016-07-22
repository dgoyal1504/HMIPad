//
//  SWBackgroundViewCell.m
//  HmiPad
//
//  Created by Joan Martin on 8/1/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWDrawRectCell.h"

#import "SWColor.h"
#import "Drawing.h"


//
//@interface SWDrawRectCellBackgroundView : UIView
//
//@property (nonatomic,assign) BOOL darkContext;
//
//@end
//
//@implementation SWDrawRectCellBackgroundView
//
//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if ( self )
//    {
//        [self setContentMode:UIViewContentModeRedraw];
//        //[self setBackgroundColor:[UIColor colorWithWhite:0.96f alpha:1.0f]];
//    }
//    return self;
//}
//
//- (void)drawRect:(CGRect)rect
//{
//    CGContextRef context = UIGraphicsGetCurrentContext() ;
//    
//    UIColor *linecolor1 = nil;
//    UIColor *linecolor2 = nil;
//    if ( _darkContext )
//    {
//        linecolor1 = [UIColor colorWithWhite:1.0f alpha:0.1f];
//        linecolor2 = [UIColor colorWithWhite:0.0f alpha:0.3f];
//        
////        CGFloat h,s,b,a;
////
////        // Crec que aixo no funciona si el color no s'ha creat amb un dels metodes de color rgb
////        [self.backgroundColor getHue:&h saturation:&s brightness:&b alpha:&a];
////        
////        NSLog(@"HUE: %f, SAT: %f, BRIGH: %f, ALPHA: %f",h,s,b,a);
////    
////        linecolor1 = [UIColor colorWithHue:h saturation:(s*0.5f) brightness:(b*1.4f) alpha:a];  // + clar
////        linecolor2 = [UIColor colorWithHue:h saturation:s brightness:(b*0.7f) alpha:a];  // + fosc
//    }
//    else
//    {
//        linecolor1 = [UIColor colorWithWhite:1.0f alpha:1.0f];
//        linecolor2 = [UIColor colorWithWhite:0.8f alpha:1.0f];
//    }
//    
//    CGContextMoveToPoint( context, rect.origin.x, rect.origin.y+0.5 ) ;
//    CGContextAddLineToPoint( context, rect.origin.x + rect.size.width, rect.origin.y+0.5 ) ;
//    CGContextSetLineWidth( context, 1 ) ;
//    CGContextSetStrokeColorWithColor( context, [linecolor1 CGColor]) ;
//    CGContextStrokePath( context ) ;
//    
//    CGContextMoveToPoint( context, rect.origin.x, rect.origin.y+rect.size.height-0.5 ) ;
//    CGContextAddLineToPoint( context, rect.origin.x + rect.size.width, +rect.size.height-0.5 ) ;
//    CGContextSetLineWidth( context, 1 ) ;
//    CGContextSetStrokeColorWithColor( context, [linecolor2 CGColor]) ;
//    CGContextStrokePath( context ) ;
//    
//    [super drawRect:rect] ;
//}
//
//
//
//@end




static UIImage* _drawRectCellImageWithDark(BOOL darkContext)
{
    CGSize size = CGSizeMake(20,20);
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGRect rect = CGRectMake(0.0f, 0.0f, scale*size.width, scale*size.height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, rect.size.width, rect.size.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    
    if (context == NULL)
        return nil;
    
    UIColor *linecolor1 = nil;
    UIColor *linecolor2 = nil;
    if ( darkContext )
    {
        linecolor2 = [UIColor colorWithWhite:1.0f alpha:0.1f];
        linecolor1 = [UIColor colorWithWhite:0.0f alpha:0.3f];
    }
    else
    {
        linecolor2 = [UIColor colorWithWhite:1.0f alpha:1.0f];
        linecolor1 = [UIColor colorWithWhite:0.8f alpha:1.0f];
    }
    
    CGContextMoveToPoint( context, rect.origin.x, rect.origin.y+0.5 ) ;
    CGContextAddLineToPoint( context, rect.origin.x + rect.size.width, rect.origin.y+0.5 ) ;
    CGContextSetLineWidth( context, 1 ) ;
    CGContextSetStrokeColorWithColor( context, [linecolor1 CGColor]) ;
    CGContextStrokePath( context ) ;
    
    CGContextMoveToPoint( context, rect.origin.x, rect.origin.y+rect.size.height-0.5 ) ;
    CGContextAddLineToPoint( context, rect.origin.x + rect.size.width, +rect.size.height-0.5 ) ;
    CGContextSetLineWidth( context, 1 ) ;
    CGContextSetStrokeColorWithColor( context, [linecolor2 CGColor]) ;
    CGContextStrokePath( context ) ;
    
    CGImageRef bitmapContext = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    UIImage *theImage = [UIImage imageWithCGImage:bitmapContext scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(bitmapContext);
    
    return theImage;
}


@interface SWDrawRectCell()
{
    UIImageView *_normalImageView;
    UIImageView *_darkImageView;
}
@end


@implementation SWDrawRectCell

//
//- (void)putDrawRectBackgroundView
//{
//    UIView *backView = [[SWDrawRectCellBackgroundView alloc] initWithFrame:self.bounds];
//    [self setBackgroundView:backView];
//}
//
//
//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//    if ( self )
//    {
//        [self putDrawRectBackgroundView];
//    }
//    return self;
//}
//
//
//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if ( self )
//    {
//        [self putDrawRectBackgroundView];
//    }
//    return self;
//}
//
//- (void)setBackgroundColor:(UIColor *)backgroundColor
//{
//    //[super setBackgroundColor:backgroundColor];
//    [super setBackgroundColor:[UIColor clearColor]];
//    [self.backgroundView setBackgroundColor:backgroundColor];
//}
//
//- (void)setDarkContext:(BOOL)darkContext
//{
//    [(SWDrawRectCellBackgroundView*)self.backgroundView setDarkContext:darkContext];
//}
//
//- (BOOL)darkContext
//{
//    return [(SWDrawRectCellBackgroundView*)self.backgroundView darkContext];
//}


- (void)_setDrawRectBackgroundView
{
    static UIImage *normalImage = nil;
    static UIImage *darkImage = nil;
    
    UIImage *image = nil;
    
    if ( _darkContext )
    {
        if ( darkImage == nil )
        {
            darkImage = _drawRectCellImageWithDark( _darkContext );
            darkImage = [darkImage resizableImageWithCapInsets:UIEdgeInsetsMake(2, 0, 2, 0)];
        }
        image = darkImage;
        
        if ( _darkImageView == nil )
        {
            _darkImageView = [[UIImageView alloc] initWithImage:image];
            [self setBackgroundView:_darkImageView];
        }
    }
    else
    {
        if ( normalImage == nil )
        {
            normalImage = _drawRectCellImageWithDark( _darkContext );
            normalImage = [normalImage resizableImageWithCapInsets:UIEdgeInsetsMake(2, 0, 2, 0)];
        }
        image = normalImage;
        
        if ( _normalImageView == nil )
        {
            _normalImageView = [[UIImageView alloc] initWithImage:image];
            [self setBackgroundView:_normalImageView];
        }
    }

//    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//    [self setBackgroundView:imageView];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self )
    {
        [self setDarkContext:NO];
    }
    return self;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if ( self )
    {
        [self setDarkContext:NO];
    }
    return self;
}


- (void)setDarkContext:(BOOL)darkContext
{
    _darkContext = darkContext;
    [self _setDrawRectBackgroundView];
}


- (NSArray*)rightButtonItemsInRevealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell
{
    return nil;
}

- (NSArray*)leftButtonItemsInRevealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell
{
    return nil;
}


@end
