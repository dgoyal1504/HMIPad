//
//  CQMFloatingNavigationBar.m
//  FloatingPopover
//
//  Created by Joan Martín Hernàndez on 6/27/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWClearNavigationBar.h"
#import "SWFloatingPopoverView.h"


// Discussio, sobre aquesta clase:
//
// Els Navigation Bar, tallen la cadena del firstResponder i per tant no hi ha manera per les superviews
// de coneixer els touchEvents. En aquest cas ens interessen perque volem moure els floatingPopovers around.
// El que fem es buscar amunt a la cadena de superviews fins que trobem el SWFloatingPopover pare i li
// enviem un missatge directament.
// No podem utilitzar un delegat perque aquesta clase substitueix directament un UINavigationBar qualsevol
// a base de fer-li object_setClass
// Pot ser hi ha una manera millor?


@implementation SWClearNavigationBar

//- (id)init 
//{
//    self = [super init];
//	if (self) {
//        self.backgroundColor = [UIColor clearColor];
//	}
//	return self;
//}
//
//- (id)initWithCoder:(NSCoder*)aDecoder 
//{
//    self = [super initWithCoder:aDecoder];
//	if (self) {
////        self.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.2];
//        self.backgroundColor = [UIColor clearColor];
//	}
//	return self;
//}
//
//- (void)drawRect:(CGRect)rect
//{
//    NSLog( @"SWClearNavigationBar drawRect");
//    // Overriden method to avoid the super calling
//}


//- (SWFloatingPopoverView *)_floatingPopoverView
//{
//    Class fpvClass = [SWFloatingPopoverView class];
//    id view = self;
//    while ( ![view isKindOfClass:fpvClass] && view != nil ) view = [view superview];
//    return view;
//}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.superview touchesBegan:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.superview touchesMoved:touches withEvent:event];
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.superview touchesEnded:touches withEvent:event];
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.superview touchesCancelled:touches withEvent:event];
    [super touchesCancelled:touches withEvent:event];
}



@end
