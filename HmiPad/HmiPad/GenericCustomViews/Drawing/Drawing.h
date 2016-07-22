/*
 *  Drawing.h
 *  ScadaMobile_100829
 *
 *  Created by Joan on 30/08/10.
 *  Copyright 2010 SweetWilliam, S.L. All rights reserved.
 *
 */
 
 
enum DrawGradientDirection
{
    DrawGradientDirectionUp,
    DrawGradientDirectionRight,
    DrawGradientDirectionDown,
    DrawGradientDirectionLeft,
    DrawGradientDirectionUpLeft,
    DrawGradientDirectionDownRight,
    
    DrawGradientDirectionFlippedUp = DrawGradientDirectionDown,
    DrawGradientDirectionFlippedDown = DrawGradientDirectionUp,
    
    DrawGradientDirectionFlippedUpLeft = DrawGradientDirectionDownRight,
    DrawGradientDirectionFlippedDownRight = DrawGradientDirectionUpLeft,
} ;
typedef enum DrawGradientDirection DrawGradientDirection;
 
 

void addRoundedRectPath( CGContextRef context, CGRect rect, CGFloat radius, CGFloat inset );
//void drawLinearGradient( CGContextRef context, CGGradientRef gradient, CGRect rect, DrawGradientDirection direction);
void drawLinearGradientRect( CGContextRef context, CGRect rect, CGColorRef begcolor, CGColorRef endcolor, DrawGradientDirection direction ) ;
void drawRadialGradientRect( CGContextRef context, CGRect rect, CGColorRef begcolor, CGColorRef endcolor, CGFloat centerOffset, DrawGradientDirection direction );
void drawSingleGradientRect( CGContextRef context, CGRect rect, CGColorRef color, DrawGradientDirection direction );
void drawRectWithStyle( CGContextRef context, CGRect rect, CGColorRef color, int style );

UIImage *glossyImageWithSizeAndColor( CGSize size, CGColorRef color, BOOL border, BOOL bottomLine, CGFloat radius, int style );
UIImage *glossyImageWithSizeAndColorScaled( CGSize size, CGColorRef color, BOOL border, BOOL bottomLine, CGFloat radius, int style, CGFloat scale );




