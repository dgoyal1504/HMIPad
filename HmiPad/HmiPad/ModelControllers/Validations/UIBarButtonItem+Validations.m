//
//  UIBarButtonItem+Validations.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 5/11/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "UIBarButtonItem+Validations.h"
//#import "UIResponder+FindFirstResponder.h"

@implementation UIBarButtonItem (Validations)

- (void)updateWithValidator:(id<SWUserInterfaceValidations>)validator
{
    //validator = [[UIApplication sharedApplication] targetForAction:@selector(validateUserInterfaceItem:) to:self.target from:self];
    
    if ([validator respondsToSelector:@selector(validateUserInterfaceItem:)]) {
    //if (validator) {
        [self setEnabled:[validator validateUserInterfaceItem:self]];
    } else {
        [self setEnabled:NO];
    }
}

@end

/*
@implementation UIView (Validations)

- (UIView *)findFirstResponder
{
    if (self.isFirstResponder) {        
        return self;     
    }
    
    for (UIView *subView in self.subviews) {
        UIView *firstResponder = [subView findFirstResponder];
        
        if (firstResponder != nil) {
            return firstResponder;
        }
    }
    
    return nil;
}
@end

@implementation UIViewController (Validations)

- (id)findFirstResponder
{
    if (self.isFirstResponder) {        
        return self;     
    }
    
    id firstResponder = [self.view findFirstResponder];    
    if (firstResponder != nil) {
        return firstResponder;
    }
    
    for (UIViewController *childViewController in self.childViewControllers) {
        firstResponder = [childViewController findFirstResponder];
        
        if (firstResponder != nil) {
            return firstResponder;
        }
    }

    return nil;
}

@end

@implementation UIApplication (Validations)

- (id)targetForAction:(SEL)anAction to:(id)aTarget from:(id)sender
{
    if (anAction == nil) {
        return nil;
    }
    
    if ([aTarget respondsToSelector:@selector(anAction)]) {
        return aTarget;
    } else {
        UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];
        //UIResponder *responder = [mainWindow.rootViewController currentFirstResponder];
        //UIResponder *responder = [mainWindow performSelector:@selector(firstResponder)];
        UIResponder *responder = [mainWindow.rootViewController findFirstResponder];
        
        while (responder != nil) {
            
//            if ([responder isKindOfClass:NSClassFromString(@"SWPageController")]) {
//                return responder;
//            }
//            
//            if ([responder isKindOfClass:NSClassFromString(@"SWDocumentController")]) {
//                return responder;
//            }            
            
            if ([responder respondsToSelector:@selector(anAction)]) {
                return responder;
            } else {
                NSLog(@"%@ not responds to selector %@",responder.class.description, NSStringFromSelector(anAction));
            }
            
            responder = responder.nextResponder;
        }
    }
    
    return nil;
}

@end
 */
