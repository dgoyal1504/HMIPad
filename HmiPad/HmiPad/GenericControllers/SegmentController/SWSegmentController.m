//
//  SWSegmentController.m
//  SegmentConroller
//
//  Created by Joan Martín Hernàndez on 7/23/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWSegmentController.h"
#import "SWFloatingPopoverController.h"

@implementation SWSegmentController
{
    NSUInteger _selectedIndex;
    
    UIViewController *_presentedViewController;
    
    UISegmentedControl *_segmentedControl;
    
    UIView *_contentView;
}

@synthesize tabbedViewControllers = _tabbedViewControllers;
@synthesize showsCloseButtonWhenFloating = _showsCloseButtonWhenFloating;


- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    return [self initWithTabbedViewControllers:[NSArray arrayWithObject:rootViewController]];
}

//- (id)initWithTabbedViewControllers:(NSArray*)viewControllers
//{
//    UIViewController *initialViewController = nil;
//    
//    if (viewControllers.count == 0) 
//    {
//        initialViewController = [[UIViewController alloc] init];
//        initialViewController.view.backgroundColor = [UIColor whiteColor];
//    }
//    else 
//    {
//        initialViewController = [viewControllers objectAtIndex:0];
//    }
//    
//    self = [super initWithRootViewController:initialViewController];
//    if (self) 
//    {
//        _tabbedViewControllers = viewControllers;
//        _presentedViewController = initialViewController;
//        
//        _selectedIndex = NSNotFound;
//        if (viewControllers.count > 0)
//            _selectedIndex = 0;
//        
//        [self _updateSegmentControlAnimated:NO];
//        [self _addSegmentedControlToController:initialViewController];
//    }
//    return self;
//}


- (id)initWithTabbedViewControllers:(NSArray*)viewControllers
{
    self = [super init];
    {
        [self setTabbedViewControllers:viewControllers animated:NO];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//	return YES;
//}

#pragma mark Properties

- (void)setTabbedViewControllers:(NSArray *)viewControllers
{
    [self setViewControllers:viewControllers animated:NO];
}

- (UIViewController*)selectedViewController
{
    if (_selectedIndex != NSNotFound) 
    {
        return [_tabbedViewControllers objectAtIndex:_selectedIndex];
    }
    
    return nil;
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    NSInteger index = [_tabbedViewControllers indexOfObjectIdenticalTo:selectedViewController];
    
    if (index == NSNotFound)
        [NSException raise:NSInternalInconsistencyException format:@"Trying to present an unknown controller. Try with setTabbedViewControllers: method."];
    
    [self setSelectedIndex:index];
}

- (NSUInteger)selectedIndex
{
    return _selectedIndex;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [self _presentViewControllerAtIndex:selectedIndex];
}

#pragma mark Public Methods

//- (void)setTabbedViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
//{    
//    _tabbedViewControllers = viewControllers;
//    
//    if (viewControllers.count > 0)
//    {
//        [self _presentViewControllerAtIndex:0];
//    }
//    else
//    {
//        UIViewController *vc = [[UIViewController alloc] init];
//        vc.view.backgroundColor = [UIColor whiteColor];
//        [self setViewControllers:[NSArray arrayWithObject:vc]];
//        _presentedViewController = nil;
//        _selectedIndex = NSNotFound;
//    }
//    
//    [self _updateSegmentControlAnimated:animated];
//    [self _addSegmentedControlToController:self.topViewController];
//}


- (void)setTabbedViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    UIViewController *initialViewController = nil;
    if (viewControllers.count == 0) 
    {
        initialViewController = [[UIViewController alloc] init];
        initialViewController.view.backgroundColor = [UIColor whiteColor];
    }
    else 
    {
        initialViewController = [viewControllers objectAtIndex:0];
    }
    
    _tabbedViewControllers = viewControllers;
    [self _updateSegmentControlAnimated:animated];
    
    [self _presentController:initialViewController];
    
    _selectedIndex = viewControllers.count>0 ? 0 : NSNotFound;
}




#pragma mark Private Methods

- (void)_presentController:(UIViewController*)controller
{
    [_segmentedControl removeFromSuperview];
    controller.navigationItem.titleView = _segmentedControl;
    
//    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:_segmentedControl];
//    controller.toolbarItems = @[buttonItem];
//    [self setToolbarHidden:NO];

    [self setViewControllers:[NSArray arrayWithObject:controller]];
    _presentedViewController = controller;
    
    SWFloatingPopoverController *floatingController = [controller floatingPopoverController];
    [floatingController setShowsCloseButton:_showsCloseButtonWhenFloating];

}


- (void)_updateSegmentControlAnimated:(BOOL)animated
{
    NSMutableArray *items = [NSMutableArray array];
    
    for (UIViewController *vc in _tabbedViewControllers)
    {
        UITabBarItem *tabItem = vc.tabBarItem;
        
        UIImage *tabImage = tabItem.image;
        NSString *tabTitle = tabItem.title;
        NSString *vcTitle = vc.title;
        
        if (tabImage)
        {
            [items addObject:tabImage];
        }
        else if (tabTitle)
        {
            [items addObject:tabTitle];
        }
        else if (vcTitle)
        {
            [items addObject:vcTitle];
        }
        else 
        {
            [items addObject:[NSString stringWithFormat:@"VC %lu",(unsigned long)[_tabbedViewControllers indexOfObjectIdenticalTo:vc]]];
        }
    }
    
    if (_tabbedViewControllers.count == 0)
        [items addObject:NSLocalizedString(@"Empty",nil)];
    
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
    //_segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [_segmentedControl addTarget:self action:@selector(didChangeValueForSegmentedControl:) forControlEvents:UIControlEventValueChanged];
    
    if (_selectedIndex != NSNotFound)
        _segmentedControl.selectedSegmentIndex = _selectedIndex;
    else
        _segmentedControl.selectedSegmentIndex = 0;
    
    CGRect segmentedFrame = _segmentedControl.frame;
    if ( segmentedFrame.size.width < 160 )
    {
        segmentedFrame.size.width = 160;
        _segmentedControl.frame = segmentedFrame;
    }
    
}



- (void)didChangeValueForSegmentedControl:(UISegmentedControl*)segmentedControl
{
    NSInteger index = segmentedControl.selectedSegmentIndex;
    [self _presentViewControllerAtIndex:index];
}


- (void)_presentViewControllerAtIndex:(NSInteger)index
{
    NSInteger count = _tabbedViewControllers.count;
    if ( count > 0 && index < count)
    {
        UIViewController *presentedController = [_tabbedViewControllers objectAtIndex:index];
    
        [self _presentController:presentedController];
    
        _selectedIndex = index;
        _segmentedControl.selectedSegmentIndex = index;
    }
}

@end
