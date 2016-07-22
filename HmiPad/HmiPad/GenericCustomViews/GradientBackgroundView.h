//
//  GradientBackgroundView.h
//  iPhoneDomusSwitch_090409
//
//  Created by Joan on 09/04/09.
//  Copyright 2009 SweetWilliam, S.L.. All rights reserved.

#import <UIKit/UIKit.h>


//----------------------------------------------------------------------------
typedef struct
{
    CGFloat r, g, b, a ;   // color del gradient
    CGFloat i, e ;      // multiplicador inicial, final
    CGFloat lr, lg, lb, la ; // color del contorn
    BOOL left, top, right, bottom ; // indica a on volem el contorn
    CGFloat l_width ;  // gruix del contorn
    CGFloat round_size ; // radi dels  racons
    CGFloat px_size ; // mida x del punter a la bombolla
    CGFloat py_size ; // mida y del punter a la bombolla
    
} GradientBackgroundData ;


//----------------------------------------------------------------------------
@interface GradientBackgroundView : UIView
{
    CGGradientRef gradient  ;
    BOOL onTop  ;                 // indica si el ppunter es dibuixa a dalt
    CGFloat pointX  ;             // posició x del punter a la bombolla
}

+ (GradientBackgroundData *) gradientBackgroundData ;  // a implementar per les clases derivades
+ (GradientBackgroundData *) gradientBackgroundData6 ;  // a implementar per les clases derivades
@end






