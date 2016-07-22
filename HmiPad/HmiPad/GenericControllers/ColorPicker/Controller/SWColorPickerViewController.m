//
//  SWColorPickerViewController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/15/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWColorPickerViewController.h"

#import "SWColor.h"
#import "Drawing.h"

@implementation SWColorPickerViewController

@synthesize privateColorPickerView = _privateColorPickerView;
@synthesize coloredView = _coloredView;
@synthesize color = _color;
@synthesize delegate = _delegate;
//@synthesize colorPickerView = _colorPickerView;
@synthesize colorPicker = _colorPicker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
//    UIColor *color = [UIColor colorWithRed:(arc4random()%100)/100.0f 
//                                     green:(arc4random()%100)/100.0f
//                                      blue:(arc4random()%100)/100.0f
//                                     alpha:1.0];
//    
//    return [self initWithColor:color];
    return [self initWithColor:nil];
}

- (id)initWithColor:(UIColor *)color
{
    self = [super initWithNibName:@"SWColorPickerViewController" bundle:nil];
    if (self)
    {
        if (color) 
            _color = color;
        else
            _color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _coloredView.backgroundColor = _color;
    _privateColorPickerView.color = _color;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _coloredView.backgroundColor = _color;
    _privateColorPickerView.color = _color;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}



//- (void)viewDidUnload
//{
//    [self setPrivateColorPickerView:nil];
//    [self setColoredView:nil];
//    [self setColorPickerView:nil];
//    
//    [super viewDidUnload];
//}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//	return YES;
//}

#pragma mark Properties

- (void)setColor:(UIColor *)color
{
    _color = color;
    
    _coloredView.backgroundColor = _color;
    _privateColorPickerView.color = _color;
}


#pragma mark Protocol ILColorPickerDelegate

- (void)colorPicked:(UIColor *)color forPicker:(ILColorPickerView *)picker pickingFinished:(BOOL)finished
{
    _coloredView.backgroundColor = color;
    _color = color;
    
    //[_colorPicker setColor:color];
    
    if (finished)
    {
        [_colorPicker setColor:color];

        if ([_delegate respondsToSelector:@selector(colorPicker:didPickColor:)])
                [_delegate colorPicker:self didPickColor:color];
    }
}

@end
