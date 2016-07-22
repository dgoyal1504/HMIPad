//
//  SWColorPickerDelegate.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/25/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SWColorPickerDelegate <NSObject>

- (void)colorPicker:(UIViewController*)colorPicker didPickColor:(UIColor*)color;

@end

@protocol SWColorPicker <NSObject>

@property (nonatomic, strong) UIColor *color;

@property (nonatomic, weak) id <SWColorPicker> colorPicker;

@end