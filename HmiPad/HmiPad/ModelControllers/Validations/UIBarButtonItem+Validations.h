//
//  UIBarButtonItem+Validations.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 5/11/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWUserInterfaceValidations.h"

@interface UIBarButtonItem (Validations) <SWValidatedUserInterfaceItem> 

- (void)updateWithValidator:(id<SWUserInterfaceValidations>)validator;

@end

/*
@interface UIView (Validations)

- (UIView*)findFirstResponder;

@end


@interface UIViewController (Validations)

- (id)findFirstResponder;

@end

@interface UIApplication (Validations)

- (id)targetForAction:(SEL)anAction to:(id)aTarget from:(id)sender;

@end
*/