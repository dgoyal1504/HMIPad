//
//  UIView+Coordinates.h
//  layoutController
//
//  Created by Joan Martín Hernàndez on 2/6/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    ItemDecorationTypeNone = 0,
    ItemDecorationTypeAlert,
    ItemDecorationTypeWhiteActivityIndicator,
    ItemDecorationTypeGrayActivityIndicator,
    ItemDecorationTypeWhiteCheckMark,
    ItemDecorationTypeBlueCheckMark,
    ItemDecorationTypeGray,
    ItemDecorationTypeGreen,
    ItemDecorationTypePurple,
    ItemDecorationTypeRed
} ItemDecorationType;


@interface UIView (DecoratorView)

+ (UIView*)decoratedViewWithFrame:(CGRect)frame forSourceItemDecoration:(ItemDecorationType)decorationType animated:(BOOL)animated ;

@end
