//
//  ColoredButton.h
//  ScadaMobile_100412
//
//  Created by Joan on 13/04/2010.
//  Copyright 2010 SweetWilliam, S.L.. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import "VerticallyAlignedLabel.h"

@class CAGradientLayer ;

@interface ColoredButton : UIButton
{
    UInt32 rgbTintColor ;
    BOOL glossy ;
    BOOL bottomLine;
    
    CGFloat _oldFrameHeight;
    //BOOL _isLayingSubviews;
    //CGFloat _oldFrameWidth;
}

@property (nonatomic, assign) BOOL circular;
//@property (nonatomic) UIFont *font;

//- (void)setRgbTintColor:(UInt32)rgbColor ;
- (void)setRgbTintColor:(UInt32)rgbColor overWhite:(BOOL)overWhite;
- (void)setVerticalTextAlignment:(VerticalAlignment)textAlignment;
- (void)setTextAlignment:(NSTextAlignment)textAlignment;
- (void)setOverTitle:(NSString*)text;
- (void)setOverFont:(UIFont*)font;
- (void)setUnactived:(BOOL)unactived;

//- (void)setBackgroundToGlossyRectOfColor:(UIColor*)color withBorder:(BOOL)border radius:(CGFloat)radius forState:(UIControlState)state ;
//- (void)setBackgroundToRectOfColor:(UIColor*)color withBorder:(BOOL)border radius:(CGFloat)radius forState:(UIControlState)state ;

@end


/*
//---------------------------------------------------------------------
// Categoria de UIColor per determinar un color de contrast respecte un fons
@interface UIColor(ColoredButtonExtensions)

+(CGFloat)brightnessForColor:(UIColor*)color ;
+(UIColor*)contrastColorForBrightness:(CGFloat)brightness ;
+(UIColor*)shadowColorForForBrightness:(CGFloat)brightness ;

@end

*/