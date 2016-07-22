//
//  SWSplitViewController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/20/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWSplitViewController.h"

@implementation SWSplitViewController
@synthesize leftLabel = _leftLabel;
@synthesize rightLabel = _rightLabel;
@synthesize leftView;
@synthesize rightView;

@synthesize leftViewController = _leftViewController;
@synthesize rightViewController = _rightViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _leftControllerLoaded = YES;
        _rightControllerLoaded = YES;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!_rightControllerLoaded)
    {
        UIView *view = _rightViewController.view;
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        view.frame = self.rightView.bounds;
        [self.rightView addSubview:view];
        _rightControllerLoaded = YES;
    }
    
    if (!_leftControllerLoaded)
    {
        UIView *view = _leftViewController.view;
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        view.frame = self.leftView.bounds;
        [self.leftView addSubview:view];
        _leftControllerLoaded = YES;
    }
}

- (void)viewDidUnload
{
    [self setLeftView:nil];
    [self setRightView:nil];
    [self setLeftLabel:nil];
    [self setRightLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    _leftControllerLoaded = NO;
    _rightControllerLoaded = NO;
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//	return YES;
//}

#pragma mark - Properties

- (void)setRightViewController:(UIViewController *)rightViewController
{    
    if (_rightViewController)
    {
        [_rightViewController.view removeFromSuperview];
        [_rightViewController willMoveToParentViewController:nil];
        [_rightViewController removeFromParentViewController];
    }
    
    if (!rightViewController)
    {
        _rightViewController = nil;
        return;
    }
    
    [self addChildViewController:rightViewController];
    
    _rightViewController = rightViewController;
    
    if (self.isViewLoaded)
    {
        UIView *view = _rightViewController.view;
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        view.frame = self.rightView.bounds;
        [self.rightView addSubview:view];
    }
    else
    {
        _rightControllerLoaded = NO;
    }
    
    [rightViewController didMoveToParentViewController:self];
}

- (void)setLeftViewController:(UIViewController *)leftViewController
{
    if (_leftViewController)
    {
        [_leftViewController.view removeFromSuperview];
        [_leftViewController willMoveToParentViewController:nil];
        [_leftViewController removeFromParentViewController];
    }
    
    if (!leftViewController)
    {
        _leftViewController = nil;
        return;
    }
    
    [self addChildViewController:leftViewController];
    
    _leftViewController = leftViewController;

    if (self.isViewLoaded)
    {
        UIView *view = _leftViewController.view;
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        view.frame = self.leftView.bounds;
        [self.leftView addSubview:view];
    }
    else
    {
        _leftControllerLoaded = NO;
    }
    
    [leftViewController didMoveToParentViewController:self];
}

@end



@implementation UIViewController (SWSplitViewController) 

- (SWSplitViewController *)parentSWSplitViewController
{
    UIViewController *parent = self ;
    Class splitClass = [SWSplitViewController class] ;
    while ( parent && ![parent isKindOfClass:splitClass] )
    {
        parent = parent.parentViewController ;
    }

    return (SWSplitViewController *)parent ;
}

@end
