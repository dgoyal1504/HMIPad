//
//  UIView+Coordinates.m
//  layoutController
//
//  Created by Joan Martín Hernàndez on 2/6/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import "UIView+DecoratorView.h"
#import "Drawing.h"
#import "SWColor.h"

@implementation UIView (DecoratorView)

//+ (UIView*)decoratedViewWithFrameVV:(CGRect)frame forSourceItemDecoration:(ItemDecorationType)decorationType animated:(BOOL)animated
//{
//    UIView *view = nil ;
//    
//    UIImage *image = nil;
//    UIImageView *imageView = nil;
//    UIActivityIndicatorView *indicatorView = nil;
//    
//    switch (decorationType)
//    {
//        case ItemDecorationTypeNone:
//            //view = nil;
//            break;
//        case ItemDecorationTypeAlert:
//            image = [UIImage imageNamed:@"caution16.png"];
//            
//            break;
//        case ItemDecorationTypeWhiteActivityIndicator:
//            indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//            
//            break;
//        case ItemDecorationTypeGrayActivityIndicator:
//            indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//            
//            break;
//        case ItemDecorationTypeWhiteCheckMark:
//            image = [UIImage imageNamed:@"checkWhite.png"];
//            
//            break;
//        case ItemDecorationTypeBlueCheckMark:
//            image = [UIImage imageNamed:@"checkBlue.png"];
//            
//            break;
//        case ItemDecorationTypeGray:
//            image = [UIImage imageNamed:@"ballGray16.png"];
//            
//            break;
//        case ItemDecorationTypeGreen:
//            image = [UIImage imageNamed:@"ballGreen16.png"];
//            
//            break;
//        case ItemDecorationTypePurple:
//            image = [UIImage imageNamed:@"ballOrange16.png"];
//            
//            break;
//        case ItemDecorationTypeRed:
//            image = [UIImage imageNamed:@"ballRed16.png"];
//            
//            break;
//            
//        default:
//            break;
//    }
//    
//    // tornarem directament un dels dos
//    if (image)
//    {
//        imageView = [[UIImageView alloc] initWithImage:image];
//        imageView.contentMode = UIViewContentModeCenter;
//        if ( decorationType == ItemDecorationTypeBlueCheckMark )
//        {
//            [imageView setHighlightedImage:[UIImage imageNamed:@"checkWhite.png"]];
//        }
//        view = imageView ;
//    }
//    
//    if (indicatorView)
//    {
//        [indicatorView startAnimating];
//        view = indicatorView ;
//    }
//    
//    // posem el frame
//    view.frame = frame ;
//    
//    // animem l'aparicio del view
//    if ( animated && view ) {
//        view.alpha = 0 ;
//        [UIView animateWithDuration:0.25 animations:^{
//            view.alpha = 1;
//        }] ;
//    }
//    return view;
//}


+ (UIView*)decoratedViewWithFrame:(CGRect)frame forSourceItemDecoration:(ItemDecorationType)decorationType animated:(BOOL)animated
{
    UIView *view = nil ;
    
    UIImage *image = nil;
    UIImageView *imageView = nil;
    UIActivityIndicatorView *indicatorView = nil;
    
    static UIImage *gray=nil, *green=nil, *tangerine=nil, *red = nil;
    
    CGFloat side = 12;
    
    switch (decorationType)
    {
        case ItemDecorationTypeNone:
            //view = nil;
            break;
            
        case ItemDecorationTypeAlert:
            image = [UIImage imageNamed:@"caution16.png"];
            break;
            
        case ItemDecorationTypeWhiteActivityIndicator:
            indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            break;
            
        case ItemDecorationTypeGrayActivityIndicator:
            indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            break;
            
        case ItemDecorationTypeWhiteCheckMark:
            image = [UIImage imageNamed:@"checkWhite.png"];
            break;
            
        case ItemDecorationTypeBlueCheckMark:
            image = [UIImage imageNamed:@"checkBlue.png"];
            break;
            
        case ItemDecorationTypeGray:
            //image = [UIImage imageNamed:@"ballGray16.png"];
            if ( gray == nil )
                gray = glossyImageWithSizeAndColor(CGSizeMake(side, side), [UIColor lightGrayColor].CGColor, NO, NO, side/2, 1);
            image = gray;
            break;
            
        case ItemDecorationTypeGreen:
            //image = [UIImage imageNamed:@"ballGreen16.png"];
            if (green == nil )
                green = glossyImageWithSizeAndColor(CGSizeMake(side, side), UIColorWithRgb(TheNiceGreenColor).CGColor, NO, NO, side/2, 1);
            image = green;
            break;
            
        case ItemDecorationTypePurple:
            //image = [UIImage imageNamed:@"ballOrange16.png"];
            if ( tangerine == nil )
                tangerine = glossyImageWithSizeAndColor(CGSizeMake(side, side), UIColorWithRgb(TangerineSelectionColor).CGColor, NO, NO, side/2, 1);
            image = tangerine;
            break;
            
        case ItemDecorationTypeRed:
            //image = [UIImage imageNamed:@"ballRed16.png"];
            if ( red == nil )
                red = glossyImageWithSizeAndColor(CGSizeMake(side, side), [UIColor redColor].CGColor, NO, NO, side/2, 1);
            image = red;
            break;
            
        default:
            break;
    }
    
    // tornarem directament un dels dos
    if (image)
    {
        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeCenter;
        if ( decorationType == ItemDecorationTypeBlueCheckMark )
        {
            [imageView setHighlightedImage:[UIImage imageNamed:@"checkWhite.png"]];
        }
        view = imageView ;
    }
    
    if (indicatorView)
    {
        [indicatorView startAnimating];
        view = indicatorView ;
    }
    
    // posem el frame
    view.frame = frame ;
    
    // animem l'aparicio del view
    if ( animated && view ) {
        view.alpha = 0 ;
        [UIView animateWithDuration:0.25 animations:^{
            view.alpha = 1;
        }] ;
    }
    return view;
}



@end
