//
//  SWValue+Types.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/1/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

/*
#import "SWValue+Types.h"
#import "SWColor.h"

@implementation SWValue (Types)

// ------------------------------------------------------------------------------------------ // 
// -------------------------------------- INITIALIZERS -------------------------------------- // 
// ------------------------------------------------------------------------------------------ //

- (id)initWithColor:(UIColor*)value
{
    CGFloat fred, fgreen, fblue, falpha;
    [value getRed:&fred green:&fgreen blue:&fblue alpha:&falpha];
    
    UInt8 red = (int)(fred*255.0);
    UInt8 green = (int)(fgreen*255.0);
    UInt8 blue = (int)(fblue*255.0);
    UInt8 alpha = (int)(falpha*255.0);
    
    self = [self initWithInteger:Theme_RGBA(0, red, green, blue, alpha)];
    return self;
}

- (id)initWithURL:(NSURL*)value
{
    self = [self initWithString:value.absoluteString];
    return self;
}

// ------------------------------------------------------------------------------------------ // 
// ----------------------------------------- STATICS ---------------------------------------- // 
// ------------------------------------------------------------------------------------------ // 

+ (SWValue*)valueWithColor:(UIColor*)value
{
    return [[SWValue alloc] initWithColor:value];
}

+ (SWValue*)valueWithURL:(NSURL*)value
{
    return [[SWValue alloc] initWithURL:value];
}

// ------------------------------------------------------------------------------------------ // 
// ----------------------------------------- GETTERS ---------------------------------------- // 
// ------------------------------------------------------------------------------------------ // 

- (UIColor*)colorValue
{
    return UIColorWithRgb([self integerValue]);
}

- (NSURL*)urlValue
{
    return [NSURL URLWithString:[self stringValue]];
}

// ------------------------------------------------------------------------------------------ // 
// ----------------------------------------- SETTERS ---------------------------------------- // 
// ------------------------------------------------------------------------------------------ // 

- (void)setColorValue:(UIColor*)value
{
    CGFloat fred, fgreen, fblue, falpha;
    [value getRed:&fred green:&fgreen blue:&fblue alpha:&falpha];
    
    UInt8 red = (int)(fred*255.0);
    UInt8 green = (int)(fgreen*255.0);
    UInt8 blue = (int)(fblue*255.0);
    UInt8 alpha = (int)(falpha*255.0);
    
    [self setIntegerValue:Theme_RGBA(0, red, green, blue, alpha)];
}

- (void)setURLValue:(NSURL*)value
{
    [self setStringValue:value.absoluteString];
}

@end
 */
