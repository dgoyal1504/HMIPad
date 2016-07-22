//
//  SWErrorPresenterViewController.m
//  HmiPad
//
//  Created by Joan on 12/09/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWErrorPresenterViewController.h"

@interface SWErrorPresenterViewController ()

@end

@implementation SWErrorPresenterViewController
{
    NSString *_message;
}

@synthesize textView = _textView;

#pragma mark init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark view life cicle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"xWhiteShadow.png"]
                    style:UIBarButtonItemStyleBordered
                    target:self
                    action:@selector(_dismissController:)];
    
    [[self navigationItem] setLeftBarButtonItem:closeItem];
    _textView.text = _message;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//	return YES;
//}


#pragma mark public

- (void)setTitle:(NSString*)title
{
    [[self navigationItem] setTitle:title];
}


- (void)setMessage:(NSString*)message
{
    _message = message;
    _textView.text = message;
}

#pragma mark private

- (void)_dismissController:(id)sender
{
    [self dismissModalViewControllerAnimated:YES] ;
}

@end
