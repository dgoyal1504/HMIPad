//
//  UIResponder+FindFirstResponder.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 5/11/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIResponder (FindFirstResponder)

- (id)currentFirstResponder;
- (void)setCurrentFirstResponder:(id)aResponder;
- (void)findFirstResponder:(id)sender;

@end
