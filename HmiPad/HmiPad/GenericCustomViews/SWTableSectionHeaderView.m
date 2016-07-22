//
//  SWTableSectionHeaderView.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/27/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWTableSectionHeaderView.h"

#import <QuartzCore/QuartzCore.h>
#import "SWColor.h"
#import "Drawing.h"

//#import "SWFloatingPopoverView.h"


//@interface SWTableViewLineLayer : CALayer
//@end
//
//@implementation SWTableViewLineLayer
//@end



@implementation SWTableSectionHeaderView
{
   CALayer *_lineLayer;
}

@synthesize titleLabel = _titleLabel;
@synthesize tintsColor = _tintsColor;
@dynamic title;


- (void)_doTableViewHeaderInit
{
    self.backgroundColor = [UIColor clearColor];
    
    // a partir d'aqui hauria de ser el mateix que hi ha a SWItemConfigurationHeader.xib per la mateixa propietat,
    // (s'hauria de treure aquesta dependencia)
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth /*| UIViewAutoresizingFlexibleHeight*/;
    if ( IS_IOS7 )
    {
       // _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _titleLabel.font = [UIFont systemFontOfSize:15];
    }
    else
    {
        _titleLabel.font = [UIFont boldSystemFontOfSize:15];
    }
    _titleLabel.textColor = [UIColor whiteColor];
    CGFloat grayLevel = 45.0/255.0;
    _titleLabel.shadowColor = [UIColor colorWithRed:grayLevel green:grayLevel blue:grayLevel alpha:1.0];
    _titleLabel.shadowOffset = CGSizeMake(0,-1);
    _titleLabel.backgroundColor = [UIColor clearColor];
    
    //CGRect rect = self.bounds;
    
    _lineLayer = [[CALayer alloc] init];
    //_lineLayer.frame = CGRectMake(0,rect.size.height,rect.size.width,1);
    [self.layer addSublayer:_lineLayer];
}


- (id)init
{
    return [self initWithFrame:CGRectMake(0, 0, 100, 30)];
}


- (id)initWithHeight:(CGFloat)height
{
    return [self initWithFrame:CGRectMake(0, 0, 100, height)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 1, frame.size.width-16, frame.size.height-2)];
        [self addSubview:_titleLabel];
        [self _doTableViewHeaderInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self _doTableViewHeaderInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [self _doTableViewHeaderInit];
}

- (void)setTintsColor:(UIColor *)tintColor
{
    _tintsColor = tintColor;
}


//- (void)drawRectVV:(CGRect)rect
//{
//    CGContextRef context = UIGraphicsGetCurrentContext() ;
//    
//    UIColor *gradcolor1 = nil;
//    UIColor *gradcolor2 = nil;
//    UIColor *linecolor1 = nil;
//    UIColor *linecolor2 = nil;
//    
//    if ( _tintColor == nil )
//    {
//        _tintColor = UIColorWithRgb(SystemDarkerBlueColor);
//    }
//    
//    CGFloat h,s,b,a;
//        
//    // Crec que aixo no funciona si el color no s'ha creat amb un dels metodes de color rgb
//    [_tintColor getHue:&h saturation:&s brightness:&b alpha:&a];
//        
//    NSLog(@"HUE: %f, SAT: %f, BRIGH: %f, ALPHA: %f",h,s,b,a);
//        
//    gradcolor1 = [UIColor colorWithHue:h saturation:(s*0.9f) brightness:(b*1.1f) alpha:a*0.85f];   // + clar
//    gradcolor2 = [UIColor colorWithHue:h saturation:s brightness:(b*0.9f) alpha:a*0.85f];   // + fosc
//   
//    linecolor1 = [UIColor colorWithHue:h saturation:(s*0.5f) brightness:(b*1.4f) alpha:a];  // + clar
//    linecolor2 = [UIColor colorWithHue:h saturation:s brightness:(b*0.7f) alpha:a];  // + fosc
//
//    
//    drawLinearGradientRect( context, rect, 
//                           gradcolor1.CGColor,  // + clar
//                           gradcolor2.CGColor,  // + fosc
//                           DrawGradientDirectionDown) ;
//    
//    CGContextMoveToPoint( context, rect.origin.x, rect.origin.y+0.5f ) ;
//    CGContextAddLineToPoint( context, rect.origin.x + rect.size.width, rect.origin.y+0.5f ) ;
//    CGContextSetLineWidth( context, 1 ) ;
//    CGContextSetStrokeColorWithColor( context, linecolor1.CGColor) ;
//    CGContextStrokePath( context ) ;
//    
//    CGContextMoveToPoint( context, rect.origin.x, rect.origin.y+rect.size.height-0.5f ) ;
//    CGContextAddLineToPoint( context, rect.origin.x + rect.size.width, +rect.size.height-0.5f ) ;
//    CGContextSetLineWidth( context, 1 ) ;
//    CGContextSetStrokeColorWithColor( context, linecolor2.CGColor) ;
//    CGContextStrokePath( context ) ;
//    
//    [super drawRect:rect] ;
//}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext() ;
    
    UIColor *gradcolor1 = nil;
    UIColor *gradcolor2 = nil;
    UIColor *linecolor1 = nil;
    UIColor *linecolor2 = nil;
    
    if ( _tintsColor == nil )
    {
        _tintsColor = UIColorWithRgb(SystemDarkerBlueColor);
    }
    
    CGFloat h,s,b,a;
        
    // Crec que aixo no funciona si el color no s'ha creat amb un dels metodes de color rgb
    [_tintsColor getHue:&h saturation:&s brightness:&b alpha:&a];
        
    //NSLog(@"HUE: %f, SAT: %f, BRIGH: %f, ALPHA: %f",h,s,b,a);
        
    gradcolor1 = [UIColor colorWithHue:h saturation:(s*0.9f) brightness:(b*1.1f) alpha:a*0.85f];   // + clar
    gradcolor2 = [UIColor colorWithHue:h saturation:s brightness:(b*0.9f) alpha:a*0.85f];   // + fosc
    
    linecolor1 = [UIColor colorWithHue:h saturation:(s*0.5f) brightness:(b*1.2f) alpha:a];  // + clar
    linecolor2 = [UIColor colorWithHue:h saturation:s brightness:(b*0.8f) alpha:a];  // + fosc

    
    drawLinearGradientRect( context, rect, 
                           gradcolor1.CGColor,  // + clar
                           gradcolor2.CGColor,  // + fosc
                           DrawGradientDirectionDown) ;
    
    CGContextMoveToPoint( context, rect.origin.x, rect.origin.y+0.5f ) ;
    CGContextAddLineToPoint( context, rect.origin.x + rect.size.width, rect.origin.y+0.5f ) ;
    CGContextSetLineWidth( context, 1 ) ;
    CGContextSetStrokeColorWithColor( context, linecolor2.CGColor) ;
    CGContextStrokePath( context ) ;
    
    CGContextMoveToPoint( context, rect.origin.x, rect.origin.y+1.5f ) ;
    CGContextAddLineToPoint( context, rect.origin.x + rect.size.width, rect.origin.y+1.5f ) ;
    CGContextSetLineWidth( context, 1 ) ;
    CGContextSetStrokeColorWithColor( context, linecolor1.CGColor) ;
    CGContextStrokePath( context ) ;
    
    [_lineLayer setBackgroundColor:linecolor2.CGColor];
//    [_lineLayer setNeedsDisplay];
    
//    CGContextMoveToPoint( context, rect.origin.x, rect.origin.y+rect.size.height+0.5f ) ;
//    CGContextAddLineToPoint( context, rect.origin.x + rect.size.width, +rect.size.height+0.5f ) ;
//    CGContextSetLineWidth( context, 1 ) ;
//    CGContextSetStrokeColorWithColor( context, linecolor2.CGColor) ;
//    CGContextStrokePath( context ) ;
    
    
    [super drawRect:rect] ;
}


- (void)layoutSubviews
{
    CGRect rect = self.bounds;
    _lineLayer.frame = CGRectMake(0,rect.size.height,rect.size.width,1);
}


- (NSString*)title
{
    return _titleLabel.text;
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}



@end
