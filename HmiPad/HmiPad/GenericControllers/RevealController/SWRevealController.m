//
//  SWModelBrowserRevealController.m
//  HmiPad
//
//  Created by Joan on 24/12/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWRevealController.h"
#import "SWEmptyViewController.h"

@interface SWRevealController ()

@end

@implementation SWRevealController
{
    NSArray *_frontViewControllers;
}



- (id)initWithRearViewController:(UIViewController *)rearController frontViewControllers:(NSArray*)frontControllers;
{
    self = [super initWithRearViewController:rearController frontViewController:nil];
    if ( self )
    {
        NSInteger frontCount = frontControllers.count;
   
        [self setFrontViewControllerWithControllers:frontControllers animated:NO];
        
        self.frontViewPosition = (frontCount==0 ? FrontViewPositionRightMostRemoved : FrontViewPositionLeft);
        self.bounceBackOnOverdraw = NO;
        self.stableDragOnOverdraw = YES;
        
        self.delegate = (id)rearController;
    }
    return self;
}


//- (NSArray*)_normalizedFrontControllers:(NSArray*)frontControllers
//{
//    if ( frontControllers.count == 0 )
//    {
//        SWEmptyViewController *empty = [[SWEmptyViewController alloc] init];
//        frontControllers = @[empty];
//    }
//    return frontControllers;
//}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   // [self revealToggle:nil animationDuration:0.3];
}




//- (void)setFrontViewControllerWithControllersVV:(NSArray*)controllers animated:(BOOL)animated
//{
//    UINavigationController *frontNavController = [[UINavigationController alloc] init];
//    
//    UIPanGestureRecognizer *navigationBarPanGestureRecognizer = [self panGestureRecognizer];
//    [frontNavController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];
//    
//    NSArray *frontControllers = [self _normalizedFrontControllers:controllers];
//    
//    //if ( controllers.count > 0)
//    {
//        UIViewController *rootController = [frontControllers objectAtIndex:0];
//        
//        UIImage *revealImage = [UIImage imageNamed:@"1099-list-1-toolbar.png"];
////        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]
////            initWithImage:revealImage style:UIBarButtonItemStylePlain target:self action:@selector(revealToggle:)];
//        
////        UIImageView *imageView = [[UIImageView alloc] initWithImage:revealImage];
//        
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        button.frame = CGRectMake(0,0,40,40);
//        [button setImage:revealImage forState:UIControlStateNormal];
//        [button setShowsTouchWhenHighlighted:YES];
//        [button addTarget:self action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
//        
//        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:button];
////        [leftButton setTarget:self];
////        [leftButton setAction:@selector(revealToggle:)];
//    
//        [rootController.navigationItem setLeftBarButtonItem:leftButton];
//
//        [frontNavController setViewControllers:frontControllers animated:NO];
//    }
//
//    if ( controllers.count > 0 )
//    {
//        [self setFrontViewController:frontNavController animated:animated];
//    }
//    else
//    {
//        [self setFrontViewPosition:FrontViewPositionRightMostRemoved animated:YES];
//        [self setFrontViewController:frontNavController animated:NO];
//    }
//    
//    self.title = self.rearViewController.title;
//}



- (void)setFrontViewControllerWithControllers:(NSArray*)controllers animated:(BOOL)animated
{
    UINavigationController *frontNavController = nil;
    
    if ( controllers.count > 0)
    {
        frontNavController = [[UINavigationController alloc] init];
    
        UIPanGestureRecognizer *navigationBarPanGestureRecognizer = [self panGestureRecognizer];
        [frontNavController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];
    
        UIViewController *rootController = [controllers objectAtIndex:0];
        
        UIBarButtonItem *leftButton;
        UIImage *revealImage = [UIImage imageNamed:@"1099-list-1-toolbar.png"];
        //UIImage *revealImage = [UIImage imageNamed:@"727-more-selected.png"];
        if ( IS_IOS7 )
        {
            leftButton = [[UIBarButtonItem alloc] initWithImage:revealImage style:UIBarButtonItemStylePlain
                target:self action:@selector(revealToggle:)];
        }
        else
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0,0,40,40);
            [button setImage:revealImage forState:UIControlStateNormal];
            [button setShowsTouchWhenHighlighted:YES];
            [button addTarget:self action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        
            leftButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        }
        
        [rootController.navigationItem setLeftBarButtonItem:leftButton];

        [frontNavController setViewControllers:controllers animated:NO];
    }
    

    if ( frontNavController )
    {
        //[self setFrontViewController:frontNavController animated:animated];
        [self pushFrontViewController:frontNavController animated:animated];
    }
    else
    {
        [self setFrontViewPosition:FrontViewPositionRightMostRemoved animated:YES];
        [self setFrontViewController:nil animated:NO];
    }
    
    self.title = self.rearViewController.title;
}



//
//- (UIViewController*)topViewController
//{
//    UINavigationController *frontNavController = (id)[self frontViewController];
//    UIViewController *controller = [frontNavController topViewController];
//    if ( controller == nil || [controller isKindOfClass:[SWEmptyViewController class]])
//        controller = [self rearViewController];
//
//    return controller;
//}
//
//
//- (NSArray*)visibleViewControllers
//{
//    NSMutableArray *visibleControllers = [NSMutableArray array];
//    FrontViewPosition position = self.frontViewPosition;
//    
//    if ( abs(position) > FrontViewPositionLeft )
//    {
//        [visibleControllers addObject:self.rearViewController];
//    }
//    
//    if ( abs(position) <= FrontViewPositionRightMost)
//    {
//
//        UINavigationController *frontNavController = (id)[self frontViewController];
//        UIViewController *controller = [frontNavController visibleViewController];
//        if ( controller && ![controller isKindOfClass:[SWEmptyViewController class]] )
//            [visibleControllers addObject:controller];
//    }
//    
//    return visibleControllers;
//}




- (UIViewController*)topViewController
{
    UINavigationController *frontNavController = (id)[self frontViewController];
    UIViewController *controller = [frontNavController topViewController];
    if ( controller == nil )
        controller = [self rearViewController];

    return controller;
}

- (UIViewController *)rootFrontViewController
{
    UINavigationController *frontNavController = (id)[self frontViewController];
    UIViewController *controller = [[frontNavController viewControllers] firstObject];
    return controller;
}


- (NSArray*)visibleViewControllers
{
    NSMutableArray *visibleControllers = [NSMutableArray array];
    FrontViewPosition position = self.frontViewPosition;
    
    if ( abs(position) > FrontViewPositionLeft )
    {
        [visibleControllers addObject:self.rearViewController];
    }
    
    if ( abs(position) <= FrontViewPositionRightMost)
    {
        UINavigationController *frontNavController = (id)[self frontViewController];
        UIViewController *controller = [frontNavController visibleViewController];
        if ( controller )
            [visibleControllers addObject:controller];
    }
    
    return visibleControllers;
}




#pragma mark overrides


//- (void)displayFrontViewController:(UIViewController*)frontViewController animated:(BOOL)animated
//{
//    [super displayFrontViewController:frontViewController animated:animated];
//
//    UINavigationController *frontNavController = (id)frontViewController;
//    
//    UIImage *revealImage = [UIImage imageNamed:@"1099-list-1-toolbar.png"];
//    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]
//        initWithImage:revealImage style:UIBarButtonItemStylePlain target:self action:@selector(revealToggle:)];
//    
//    UIViewController *rootFrontController = [_frontViewControllers objectAtIndex:0];
//    [rootFrontController.navigationItem setLeftBarButtonItem:leftButton];
//    
//    [frontNavController setViewControllers:_frontViewControllers animated:NO];
//    _frontViewControllers = nil;
//}


#pragma mark SWModelBrowserViewController

//- (SWModelBrowsingStyle)browsingStyle
//{
//    return _modelBrowserController.browsingStyle;
//}
//
//- (void)setBrowsingStyle:(SWModelBrowsingStyle)browsingStyle
//{
//    _modelBrowserController.browsingStyle = browsingStyle;
//}
//
//- (id<SWModelBrowserDelegate>)delegate
//{
//    return _modelBrowserController.delegate;
//}
//
//- (void)setDelegate:(id<SWModelBrowserDelegate>)delegate
//{
//    _modelBrowserController.delegate = delegate;
//}
//
//- (NSIndexSet*)acceptedTypes
//{
//    return _modelBrowserController.acceptedTypes;
//}
//
//- (void)setAcceptedTypes:(NSIndexSet *)acceptedTypes
//{
//    _modelBrowserController.acceptedTypes = acceptedTypes;
//}

@end

