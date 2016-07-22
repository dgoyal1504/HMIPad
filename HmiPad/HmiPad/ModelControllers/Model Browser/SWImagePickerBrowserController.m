//
//  SWImagePickerBrowserController.m
//  HmiPad
//
//  Created by Joan on 09/04/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWImagePickerBrowserController.h"

@interface SWImagePickerBrowserController ()

@end

@implementation SWImagePickerBrowserController


#pragma mark protocol SWModelBrowserViewController

@synthesize browsingStyle = _browsingStyle;
@synthesize identifiyingObject = _identifiyingObject;

- (id)initWithObject:(id)object classIdentifierObject:(id)identifyingObject
{
    NSAssert( [object isKindOfClass:[NSString class]], @"objecte erroni per controlador" );
    self = [self initWithContentsAtPath:object];
    if ( self )
    {
        _identifiyingObject = identifyingObject;
    }
    return self;
}

- (id)identifiyingObject
{
    return _identifiyingObject;
}

#pragma mark controller lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
