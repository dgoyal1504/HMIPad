//
//  UIResponder+FindFirstResponder.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 5/11/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//
#import <objc/runtime.h>
#import "UIResponder+FindFirstResponder.h"

static char const * const aKey = "first";

@implementation UIResponder (FindFirstResponder)

- (id)currentFirstResponder 
{
    [[UIApplication sharedApplication] sendAction:@selector(findFirstResponder:) to:nil from:self forEvent:nil];
    id obj = objc_getAssociatedObject (self, aKey);
    objc_setAssociatedObject (self, aKey, nil, OBJC_ASSOCIATION_ASSIGN);
    return obj;
}

- (void)setCurrentFirstResponder:(id)aResponder 
{
    objc_setAssociatedObject (self, aKey, aResponder, OBJC_ASSOCIATION_ASSIGN);
}

- (void)findFirstResponder:(id)sender 
{
//    NSLog(@"FIRST RESPONDER: %@",self.description);
    [sender setCurrentFirstResponder:self];
}

@end