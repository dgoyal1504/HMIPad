//
//  ILColorPicker.m
//  ILColorPickerExample
//
//  Created by Jon Gilkison on 9/2/11.
//  Copyright 2011 Interfacelab LLC. All rights reserved.
//

#import "ILColorPickerView.h"


@implementation ILColorPickerView

@synthesize delegate;
@synthesize pickerLayout;
@synthesize color;

#pragma mark - Setup

- (void)setup
{
    [super setup];
    
    self.opaque=NO;
    self.backgroundColor=[UIColor clearColor];
    
    _huePicker=[[ILHuePickerView alloc] initWithFrame:CGRectZero];
    [self addSubview:_huePicker];
    
    _alphaPicker = [[ILAlphaPickerView alloc] initWithFrame:CGRectZero];
    [self addSubview:_alphaPicker];
    
    [self setPickerLayout:ILColorPickerViewLayoutBottom];
}

#pragma mark - Property Set/Get

- (void)setPickerLayout:(ILColorPickerViewLayout)layout
{
    pickerLayout = layout;

    if (_satPicker != nil)
    {
        [_satPicker removeFromSuperview];
        _satPicker = nil;
    }
    
    CGRect bounds = self.bounds;
    
    if (layout == ILColorPickerViewLayoutBottom)
    {
        CGFloat hueOffset = 38;
        CGFloat alphaOffset = 12;
    
        _huePicker.pickerOrientation = ILHuePickerViewOrientationHorizontal;
        [_huePicker setFrame:CGRectMake(0, bounds.size.height-hueOffset, bounds.size.width-10-alphaOffset, hueOffset)];
        _huePicker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
        _alphaPicker.pickerOrientation = ILAlphaPickerViewOrientationVertical;
        _alphaPicker.delegate = self;
        _alphaPicker.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        [_alphaPicker setFrame:CGRectMake(bounds.size.width - alphaOffset, 0, alphaOffset, bounds.size.height)];
        
        _satPicker = [[ILSaturationBrightnessPickerView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width-10-alphaOffset, bounds.size.height-10-hueOffset)];
        _satPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _satPicker.delegate = self;
        _huePicker.delegate = _satPicker;
        [self addSubview:_satPicker];
    }
    else
    {
        CGFloat hueOffset = 38;
        CGFloat alphaOffset = 12;
    
        _huePicker.pickerOrientation = ILHuePickerViewOrientationVertical;
        [_huePicker setFrame:CGRectMake(bounds.size.width-hueOffset, 0, hueOffset, bounds.size.height-10-alphaOffset)];
        _huePicker.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        
        _alphaPicker.pickerOrientation = ILAlphaPickerViewOrientationHorizontal;
        _alphaPicker.delegate = self;
        _alphaPicker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        [_alphaPicker setFrame:CGRectMake(0, bounds.size.height-alphaOffset, bounds.size.width, alphaOffset)];
        
        _satPicker = [[ILSaturationBrightnessPickerView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width-10-hueOffset, bounds.size.height-10-alphaOffset)];
        _satPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _satPicker.delegate = self;
        _huePicker.delegate = _satPicker;
        [self addSubview:_satPicker];
    }
}

- (UIColor*)color
{
    return [_satPicker.color colorWithAlphaComponent:_alphaPicker.alphaValue];
}

- (void)setColor:(UIColor*)c
{
    _satPicker.color = c;
    _huePicker.color = c;
    [_alphaPicker setAlphaFromColor:c];
}

#pragma mark - ILSaturationBrightnessPickerDelegate

- (void)colorPicked:(UIColor*)newColor forPicker:(ILSaturationBrightnessPickerView*)picker pickingFinished:(BOOL)flag
{    
    [delegate colorPicked:[newColor colorWithAlphaComponent:_alphaPicker.alpha] forPicker:self pickingFinished:flag];
}

#pragma mark - ILAlphaPickerDelegate

- (void)alphaPicked:(float)alpha picker:(ILAlphaPickerView *)picker pickingFinished:(BOOL)flag
{
    [delegate colorPicked:self.color forPicker:self pickingFinished:flag];
}

@end
