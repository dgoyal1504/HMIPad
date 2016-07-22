//
//  UIColor+GetHSB.h
//  ILColorPickerExample
//
//  Created by Jon Gilkison on 9/2/11.
//  Copyright 2011 Interfacelab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
} HSBType;

@interface UIColor(GetHSB)

-(HSBType)HSB;

@end
