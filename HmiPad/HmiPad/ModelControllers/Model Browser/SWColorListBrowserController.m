//
//  SWColorListBrowserController.m
//  HmiPad
//
//  Created by Joan on 09/04/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWColorListBrowserController.h"

@interface SWColorListBrowserController ()

@end

@implementation SWColorListBrowserController



#pragma mark protocol SWModelBrowserViewController

@synthesize browsingStyle = _browsingStyle;
@synthesize identifiyingObject = _identifiyingObject;

- (id)initWithObject:(id)object classIdentifierObject:(id)identifyingObject
{
    NSAssert( [object isKindOfClass:[UIColor class]], @"objecte erroni per controlador" );
    self = [self initWithStyle:UITableViewStylePlain andColor:object];
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
