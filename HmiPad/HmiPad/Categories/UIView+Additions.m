//
//  UIView+Additions.m
//  HmiPad
//
//  Created by Joan on 08/08/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "UIView+Additions.h"

@implementation UIView (Additions)

- (UITouchPhase)touchFaseForEvent:(UIEvent*)event
{ 
   // UITouch *touch = [[event allTouches] anyObject] ;
    
    UITouch *touch = nil ;
    for ( touch in [event allTouches] )
    {
        UIView *vi = [touch view] ;
        if ( [vi isDescendantOfView:self] ) break ;
    }

    //UITouchPhase phase = -1 ;
    UITouchPhase phase = UITouchPhaseCancelled ;
    if ( touch )
    {
        phase = [touch phase] ;
    }
    
    return phase ;
}

@end


@implementation UIView(subvistes)

- (void)lesSubvistes
{
    [self lesSubvistesAmbNivell:0];
}

- (void)lesSubvistesAmbNivell:(int)nivell
{
    NSMutableString *espai = [NSMutableString string];
    for ( int i=0 ; i<nivell ; i++ ) [espai appendString:@"--"];
    NSLog( @"%@%03d %@ <%0lx>", espai, nivell, NSStringFromClass([self class]), (unsigned long)self );
    for ( UIView *subvista in self.subviews )
    {
        [subvista lesSubvistesAmbNivell:nivell+1];
    }
}

@end