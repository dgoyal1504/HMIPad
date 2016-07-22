//
//  SWToolbarViewController.m
//  HmiPad
//
//  Created by Joan on 06/10/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWToolbarViewController.h"


@interface SWClipView : UIView
@end

@implementation SWClipView

//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
//{
//    BOOL isInside = [super pointInside:point withEvent:event];
//    if ( !isInside  )
//    {
//        for ( UIView *sub in [self.subviews reverseObjectEnumerator] )
//        {
//            CGPoint pt = [self convertPoint:point toView:sub];
//            isInside = [sub pointInside:pt withEvent:event];
//            if ( isInside )
//                return isInside;
//        }
//    }
//    return isInside;
//}

@end

#define kDefaultDuration 0.3


@interface SWToolbarViewController ()<UIToolbarDelegate,UIGestureRecognizerDelegate>
{
    UIView *_contentView;  // self.view
    UIView *_clipView;
    UIView *_shadeView;
    UIPanGestureRecognizer *_panGestureRecognizer;
    UITapGestureRecognizer *_tapGestureRecognizer;
}
@end


@implementation SWToolbarViewController
{
    SWLeftOverlayPosition _panInitialLeftOverlayPosition;
}

@synthesize contentViewController = _contentViewController;
@synthesize overlayViewController = _overlayViewController;
@synthesize leftOverlayPosition = _leftOverlayPosition;

const int SWLeftOverlayPositionUnknown = 0xff;




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

//- (id)initWithContentViewController:(UIViewController*)viewController
//{
//    self = [super initWithNibName:nil bundle:nil];
//    if (self)
//    {
//        _contentViewController = viewController;
//        _leftOverlayPosition = SWLeftOverlayPositionUnknown;
//        _leftOverlayWidth = 320;
//        _leftOverlayExtensionWidth = 120;
//        [self _updateToolbarAnimated:NO];
//    }
//    return self;
//}

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
//        _contentViewController = viewController;
        _leftOverlayPosition = SWLeftOverlayPositionUnknown;
        _leftOverlayWidth = 320;
        _leftOverlayExtensionWidth = 120;
//        [self _updateToolbarAnimated:NO];
    }
    return self;
}


#pragma mark - view lifecycle

//- (void)loadView7
//{
//    CGRect rect = [[UIScreen mainScreen] applicationFrame];
//    UIView *view = [[UIView alloc] initWithFrame:rect];
//    //[view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
//    
////    CGRect newFrame = [self.view convertRect:CGRectMake(0, 150, 1024, 768) toView:[UIApplication sharedApplication].keyWindow];
////[UIApplication sharedApplication].keyWindow.rootViewController.view.frame = newFrame;
//    
//    self.view = view;
//    CGFloat toolbarOrigin = 20;
//    CGFloat toolbarHeight = 44;
//    
//    _contentView = [[UIView alloc] initWithFrame:
//        CGRectMake(0,toolbarOrigin+toolbarHeight,rect.size.width,rect.size.height-(toolbarOrigin+toolbarHeight))];
//    [_contentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin];
//    
//    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,toolbarOrigin,rect.size.width,toolbarHeight)];
//    [_toolbar setDelegate:self];
//    [_toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
//    
//    [view addSubview:_contentView];
//    [view addSubview:_toolbar];
//}



- (void)loadView
{
    CGRect rect = [[UIScreen mainScreen] applicationFrame];
    _contentView = [[UIView alloc] initWithFrame:rect];
    
    self.view = _contentView;
    CGFloat toolbarHeight = 44;
    
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,rect.size.width,toolbarHeight)];
    [_toolbar setDelegate:self];
    [_toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    [_contentView addSubview:_toolbar];
    
    
    SWLeftOverlayPosition initialPosition = _leftOverlayPosition;
    _leftOverlayPosition = SWLeftOverlayPositionUnknown;
    
    [self setLeftOverlayPosition:initialPosition animated:NO];
}


- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}


//- (void)viewDidLayoutSubviews7
//{
//    CGRect rect = self.view.bounds;
//    CGFloat top = self.topLayoutGuide.length;
//    CGSize toolbarSize = [_toolbar sizeThatFits:rect.size];
//
//    _toolbar.frame = CGRectMake(0, top, toolbarSize.width, toolbarSize.height);
//    _contentView.frame = CGRectMake(0, top+toolbarSize.height, rect.size.width, rect.size.height-(top+toolbarSize.height));
//}


- (void)viewDidLayoutSubviews
{
    //CGRect rect = self.view.bounds;
    CGRect rect = _contentView.bounds;
    CGFloat top = self.topLayoutGuide.length;
    CGSize toolbarSize = [_toolbar sizeThatFits:rect.size];

    _toolbar.frame = CGRectMake(0, top, toolbarSize.width, toolbarSize.height);
    [self _layoutController:_contentViewController];
    [self _layoutController:_overlayViewController];
}


//- (void)_layoutContentController
//{
//
//    CGRect toolBarFrame = _toolbar.frame;
//    CGRect contentFrame = toolBarFrame;
//    contentFrame.origin.y += toolBarFrame.size.height;
//    contentFrame.size.height = self.view.bounds.size.height - contentFrame.origin.y;
//
//    _contentViewController.view.frame = contentFrame;
//}



//- (void)viewDidLoad7
//{
//    [super viewDidLoad];
//    [self _deployViewController:_contentViewController inView:_contentView]();
//	// Do any additional setup after loading the view.
//}

- (void)viewDidLoadV
{
    [super viewDidLoad];
//    [self _deployViewController:_contentViewController]();
//    [self _deployViewController:_overlayViewController]();
    
    [self _transitionFromViewController:nil toViewController:_contentViewController]();
    [self _transitionFromViewController:nil toViewController:_overlayViewController]();
    
	// Do any additional setup after loading the view.
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _deployViewForController:_contentViewController]();
    
    
	// Do any additional setup after loading the view.
}


- (UIViewController *)childViewControllerForStatusBarStyle
{
    if ( _leftOverlayPosition == SWLeftOverlayPositionShown && _overlayViewController != nil)
        return _overlayViewController;

    return _contentViewController;
}


- (UIViewController*)childViewControllerForStatusBarHidden
{
    return [self childViewControllerForStatusBarStyle];
}


- (NSUInteger)supportedInterfaceOrientations
{
//    return UIInterfaceOrientationMaskLandscape;
//    return UIInterfaceOrientationMaskPortrait;
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return YES;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
//    NSLog( @"boundsWill: %@", NSStringFromCGRect(self.view.bounds) );
//    NSLog( @"frameToolbarWill: %@", NSStringFromCGRect(_toolbar.frame) );
//    NSLog( @"frameContentWill: %@", NSStringFromCGRect(_contentView.frame) );
}

//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{

//    NSLog( @"boundsDid: %@", NSStringFromCGRect(self.view.bounds) );
//    NSLog( @"frameToolbarDid: %@", NSStringFromCGRect(_toolbar.frame) );
//    NSLog( @"frameContentDid: %@", NSStringFromCGRect(_contentView.frame) );
}




//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//	return YES;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - methods


- (UIViewController*)contentViewController
{
    return _contentViewController;
}

- (UIViewController*)overlayViewController
{
    return _overlayViewController;
}

- (void)setClipExtensionPercent:(CGFloat)clipExtensionPercent
{
    _clipExtensionPercent = clipExtensionPercent;
    [self _layoutController:_overlayViewController];
}

//- (void)setContentViewController7:(UIViewController*)viewController animated:(BOOL)animated
//{
//    [self view];
//    [self _undeployViewController:_contentViewController]();
//    [self _deployViewController:viewController inView:_contentView]();
//    
//    _contentViewController = viewController;
//    [self _updateToolbarAnimated:animated];
//}


//- (void)setContentViewController:(UIViewController*)viewController animated:(BOOL)animated
//{
//    //[self view];
//    
//    if ( viewController == _contentViewController )
//        return;
//    
//    [self _undeployViewController:_contentViewController]();
//    _contentViewController = viewController;
//    
//    if ( [self isViewLoaded] )
//    {
//        [self _deployViewController:viewController]();
//        [self _updateToolbarAnimated:animated];
//    }
//}


//- (void)setContentViewController:(UIViewController*)viewController animated:(BOOL)animated
//{
//    UIViewController *oldController = _contentViewController;
//    _contentViewController = viewController;
//    
//    if ( !self.isViewLoaded )
//        return;
//    
//    [self _transitionFromViewController:oldController toViewController:_contentViewController]();
//    [self _updateToolbarAnimated:animated];
//}


- (void)setContentViewController:(UIViewController*)viewController animated:(BOOL)animated
{
//    UIViewController *oldController = _contentViewController;
//    _contentViewController = viewController;
//    
//    [self _transitionFromViewController:oldController toViewController:_contentViewController]();
//    [self _updateToolbarAnimated:animated];
    
    [self _performContentTransitionToViewController:viewController animated:animated];
    [self _updateToolbarAnimated:animated];
}


- (void)_performContentTransitionToViewController:(UIViewController*)newViewController animated:(BOOL)animated
{
    UIViewController *oldController = _contentViewController;
    _contentViewController = newViewController;
    
    void (^completion)() = [self _transitionFromViewController:oldController toViewController:newViewController];

    if ( animated )
    {
        UIView *toView = newViewController.view;
        UIView *fromView = newViewController.view;

        toView.alpha = 0;
        
        [UIView animateWithDuration:0.3 delay:0 options:0 animations:^
        {
            fromView.alpha = 0;
            toView.alpha = 1;
        }
        completion:^(BOOL finished)
        {
            completion();
        }];
        
        
//        [UIView transitionFromView:fromView toView:toView duration:0.3
//            options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionOverrideInheritedOptions
//            completion:^(BOOL finished) { completion();} ];

    }
    else
    {
        completion();
    }

}


//- (void)setOverlayViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//   // [self view];
//    
//    if ( viewController == _overlayViewController )
//        return;
//    
//    [self _undeployViewController:_overlayViewController]();
//    _overlayViewController = viewController;
//    if ( [self isViewLoaded] )
//    {
//        [self _deployViewController:viewController]();
//    }
//}


//- (void)setOverlayViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    UIViewController *oldController = _overlayViewController;
//    _overlayViewController = viewController;
//    
//    if ( !self.isViewLoaded )
//        return;
//    
//    [self _transitionFromViewController:oldController toViewController:_overlayViewController]();
//}


- (void)setOverlayViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UIViewController *oldController = _overlayViewController;
    _overlayViewController = viewController;
    
    [self _transitionFromViewController:oldController toViewController:_overlayViewController]();
}


//- (void)setLeftOverlayPosition:(SWLeftOverlayPosition)newOverlayPosition animated:(BOOL)animated
//{
////    _leftOverlayPosition = newOverlayPosition;
////    
////    NSTimeInterval interval = animated?0.25:0;
////    [UIView animateWithDuration:interval animations:^
////    {
////        [self _layoutController:_overlayViewController];
////    }];
////    
////    ////
//    
////    if ( newOverlayPosition == _leftOverlayPosition )
////        return;
//    
//    if ( [_delegate respondsToSelector:@selector(toolbarViewController:willMoveLeftOverlayViewControllerToPosition:animated:)] )
//        [_delegate toolbarViewController:self willMoveLeftOverlayViewControllerToPosition:newOverlayPosition animated:animated];
//    
//    void (^deploymentCompletion)(void) = nil;
//    
//    if ( newOverlayPosition == SWLeftOverlayPositionHidden )
//        deploymentCompletion = [self _undeployViewController:_overlayViewController];
//    
//    else if ( newOverlayPosition == SWLeftOverlayPositionShown )
//        deploymentCompletion = [self _deployViewController:_overlayViewController];
//    
//    _leftOverlayPosition = newOverlayPosition;
//    NSTimeInterval interval = animated?0.5:0;
//    
////    [UIView animateWithDuration:interval animations:^
////    {
////        [self _layoutController:_overlayViewController];
////    }
////    completion:^(BOOL finished)
////    {
////        if ( deploymentCompletion )
////            deploymentCompletion();
////    }];
//    
//    [UIView animateWithDuration:interval delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:0
//    animations:^
//    {
//        [self _layoutController:_overlayViewController];
//        if ( [_delegate respondsToSelector:@selector(toolbarViewController:animateToPosition:)] )
//            [_delegate toolbarViewController:self animateToPosition:newOverlayPosition];
//    }
//    completion:^(BOOL finished)
//    {
//        deploymentCompletion();
//        if ( [_delegate respondsToSelector:@selector(toolbarViewController:didMoveLeftOverlayViewControllerToPosition:animated:)] )
//            [_delegate toolbarViewController:self didMoveLeftOverlayViewControllerToPosition:newOverlayPosition animated:animated];
//    }];
//}


//- (void)setLeftOverlayPosition:(SWLeftOverlayPosition)newOverlayPosition animated:(BOOL)animated
//{
//    if ( !self.isViewLoaded )
//    {
//        _leftOverlayPosition = newOverlayPosition;
//        return;
//    }
//
//    BOOL positionIsChanging = _leftOverlayPosition != newOverlayPosition;
//    
//    BOOL appear = _leftOverlayPosition == SWLeftOverlayPositionHidden && newOverlayPosition == SWLeftOverlayPositionShown;
//    BOOL disappear = newOverlayPosition == SWLeftOverlayPositionHidden && _leftOverlayPosition == SWLeftOverlayPositionShown;
//
//    _leftOverlayPosition = newOverlayPosition;
//
//    if ( positionIsChanging )
//    {
//        if ( [_delegate respondsToSelector:@selector(toolbarViewController:willMoveLeftOverlayViewControllerToPosition:animated:)] )
//            [_delegate toolbarViewController:self willMoveLeftOverlayViewControllerToPosition:newOverlayPosition animated:animated];
//    }
//    
//    void (^appearCompletion)(void) = ^{};
//    void (^disappearCompletion)(void) = ^{};
//    
//    if ( appear )
//        appearCompletion = [self _deployViewForController:_overlayViewController];
//    
//    if ( disappear )
//        disappearCompletion = [self _undeployViewForController:_overlayViewController];
//    
//    NSTimeInterval interval = animated?0.5:0;
//    
////    [UIView animateWithDuration:interval animations:^
////    {
////        [self _layoutController:_overlayViewController];
////    }
////    completion:^(BOOL finished)
////    {
////        if ( deploymentCompletion )
////            deploymentCompletion();
////    }];
//    
//    [UIView animateWithDuration:interval delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:0
//    animations:^
//    {
//        [self _layoutController:_overlayViewController];
//        [_shadeView setAlpha:newOverlayPosition==SWLeftOverlayPositionShown?0.5:0];
//        if ( [_delegate respondsToSelector:@selector(toolbarViewController:animateToPosition:)] )
//            [_delegate toolbarViewController:self animateToPosition:newOverlayPosition];
//    }
//    completion:^(BOOL finished)
//    {
//        appearCompletion();
//        disappearCompletion();
//        if ( positionIsChanging )
//        {
//            if ( [_delegate respondsToSelector:@selector(toolbarViewController:didMoveLeftOverlayViewControllerToPosition:animated:)] )
//                [_delegate toolbarViewController:self didMoveLeftOverlayViewControllerToPosition:newOverlayPosition animated:animated];
//        }
//    }];
//}



- (void)setLeftOverlayPosition:(SWLeftOverlayPosition)newOverlayPosition animated:(BOOL)animated
{
    BOOL positionIsChanging = _leftOverlayPosition != newOverlayPosition;
    
    BOOL appear = newOverlayPosition == SWLeftOverlayPositionShown &&
        (_leftOverlayPosition == SWLeftOverlayPositionHidden || _leftOverlayPosition == SWLeftOverlayPositionUnknown);
    
    BOOL disappear = _leftOverlayPosition == SWLeftOverlayPositionShown &&
        (newOverlayPosition == SWLeftOverlayPositionHidden || newOverlayPosition == SWLeftOverlayPositionUnknown);

    if ( positionIsChanging )
    {
        if ( [_delegate respondsToSelector:@selector(toolbarViewController:willMoveLeftOverlayViewControllerToPosition:animated:)] )
            [_delegate toolbarViewController:self willMoveLeftOverlayViewControllerToPosition:newOverlayPosition animated:animated];
    }
    
    if ( appear )
        [self _prepareForDeployingViewController:_overlayViewController];
    
    _leftOverlayPosition = newOverlayPosition;
    
    void (^appearCompletion)(void) = ^{};
    void (^disappearCompletion)(void) = ^{};
    
    if ( appear )
        appearCompletion = [self _deployViewForController:_overlayViewController];
    
    if ( disappear )
        disappearCompletion = [self _undeployViewForController:_overlayViewController];
    
    NSTimeInterval interval = animated?kDefaultDuration:0;
    
//    [UIView animateWithDuration:interval delay:0.0
//    options:UIViewAnimationOptionCurveEaseOut
//    animations:^
//    {
//        [self _layoutController:_overlayViewController];
//        [_shadeView setAlpha:newOverlayPosition==SWLeftOverlayPositionShown?0.5:0];
//        if ( [_delegate respondsToSelector:@selector(toolbarViewController:animateToPosition:)] )
//            [_delegate toolbarViewController:self animateToPosition:newOverlayPosition];
//    }
//    completion:^(BOOL finished)
//    {
//        appearCompletion();
//        disappearCompletion();
//        if ( positionIsChanging )
//        {
//            if ( [_delegate respondsToSelector:@selector(toolbarViewController:didMoveLeftOverlayViewControllerToPosition:animated:)] )
//                [_delegate toolbarViewController:self didMoveLeftOverlayViewControllerToPosition:newOverlayPosition animated:animated];
//        }
//    }];
    
    [UIView animateWithDuration:interval delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:0
    animations:^
    {
        [self _layoutController:_overlayViewController];
        [self setNeedsStatusBarAppearanceUpdate];
        [_shadeView setAlpha:newOverlayPosition==SWLeftOverlayPositionShown?0.333:0];
        if ( [_delegate respondsToSelector:@selector(toolbarViewController:animateToPosition:)] )
            [_delegate toolbarViewController:self animateToPosition:newOverlayPosition];
    }
    completion:^(BOOL finished)
    {
        appearCompletion();
        disappearCompletion();
        if ( positionIsChanging )
        {
            if ( [_delegate respondsToSelector:@selector(toolbarViewController:didMoveLeftOverlayViewControllerToPosition:animated:)] )
                [_delegate toolbarViewController:self didMoveLeftOverlayViewControllerToPosition:newOverlayPosition animated:animated];
        }
    }];
}


- (void)leftOverlayPositionToggleAnimated:(BOOL)animated
{
    if ( _overlayViewController == nil )
        return;
    
    SWLeftOverlayPosition newPosition = SWLeftOverlayPositionShown;
    if ( _leftOverlayPosition == SWLeftOverlayPositionShown)
        newPosition = SWLeftOverlayPositionHidden;
    
    [self setLeftOverlayPosition:newPosition animated:YES];
}


- (void)leftOverlayPositionToggle
{
    [self leftOverlayPositionToggleAnimated:YES];
}


- (UIPanGestureRecognizer*)panGestureRecognizer
{
    if ( _panGestureRecognizer == nil )
    {
        UIPanGestureRecognizer *panRecognizer =
            [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handleRevealGesture:)];
        
        panRecognizer.delegate = self;
        [_clipView addGestureRecognizer:panRecognizer];
        _panGestureRecognizer = panRecognizer;
    }
    return _panGestureRecognizer;
}


//- (UITapGestureRecognizer*)tapGestureRecognizer
//{
//    if ( _tapGestureRecognizer == nil )
//    {
//        UITapGestureRecognizer *tapRecognizer =
//            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTapGesture:)];
//        
//        tapRecognizer.delegate = self;
//        [_shadeView addGestureRecognizer:tapRecognizer];
//        _tapGestureRecognizer = tapRecognizer ;
//    }
//    return _tapGestureRecognizer;
//}

//- (void (^)(void))_deployViewController7:(UIViewController*)viewController inView:(UIView*)view
//{
//    if (!viewController)
//        return ^(void){};
//    
//    [self addChildViewController:viewController];
//    
//    UIView *controllerView = viewController.view;
//    controllerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    controllerView.frame = view.bounds;
//    
//    [view addSubview:controllerView];
//    
//    void (^completionBlock)(void) = ^(void)
//    {
//        [viewController didMoveToParentViewController:self];
//    };
//    
//    return completionBlock;
//}


#pragma mark - deployment

// Containment Transition method. Returns a block to be invoked at the
// animation completion, or right after return in case of non-animated transition.
- (void(^)(void))_transitionFromViewController:(UIViewController*)fromController toViewController:(UIViewController*)toController
{
    if ( fromController == toController )
        return ^(void){};
    
    if ( toController ) [self addChildViewController:toController];
    void (^deployCompletion)() = [self _deployViewForController:toController];
    
    
    //NSLog( @"added self.childViewControllers: %@", self.childViewControllers );
    
    [fromController willMoveToParentViewController:nil];
    void (^undeployCompletion)() = [self _undeployViewForController:fromController];
    
    void (^completionBlock)(void) = ^(void)
    {
        undeployCompletion() ;
        [fromController removeFromParentViewController];
        
        deployCompletion() ;
        [toController didMoveToParentViewController:self];
        
//        if ( fromController )
//            NSLog( @"afer remov self.childViewControllers: %@", self.childViewControllers );
    };
    return completionBlock;
}


- (void (^)(void))_deployViewForController:(UIViewController*)viewController
{
    if (!viewController || !_contentView )
        return ^(void){};
    
//    [self addChildViewController:viewController];
//    NSLog( @"self.childViewControllers: %@", self.childViewControllers );
    
    //[self _layoutController:viewController];
    [self _addViewFromController:viewController];
    
    
    void (^completionBlock)(void) = ^(void)
    {
        //[viewController didMoveToParentViewController:self];
    };
    
    return completionBlock;
}


- (void (^)(void))_undeployViewForController:(UIViewController*)viewController
{
    if (!viewController)
        return ^(void){};
    
   // [viewController willMoveToParentViewController:nil];
    
    void (^completionBlock)(void) = ^(void)
    {
        [self _removeViewFromController:viewController];
//        [viewController removeFromParentViewController];
//        
//        NSLog( @"self.childViewControllers: %@", self.childViewControllers );
    };
    
    return completionBlock;
}


#pragma mark - Private


- (void)_updateToolbarAnimated:(BOOL)animated
{
    NSArray *toolbarItems = _contentViewController.toolbarItems;
    [_toolbar setItems:toolbarItems animated:animated];
}


- (CGRect)_clipFrameForLeftOverlayPosition:(SWLeftOverlayPosition)position
{
    //CGRect clipViewFrame = self.view.bounds;
    CGRect clipViewFrame = _contentView.bounds;
        
    clipViewFrame.size.width = _leftOverlayWidth+_leftOverlayExtensionWidth*_clipExtensionPercent;
        
    if ( _leftOverlayPosition == SWLeftOverlayPositionHidden || _leftOverlayPosition == SWLeftOverlayPositionUnknown )
        clipViewFrame.origin.x = 0-clipViewFrame.size.width;

    return clipViewFrame;
}



- (void)_layoutController:(UIViewController*)controller
{
    //CGRect bounds = self.view.bounds;
    CGRect bounds = _contentView.bounds;
    CGRect toolBarFrame = _toolbar.frame;
    UIView *controllerView = controller.view;
    
    if ( controller == _contentViewController )
    {
        CGRect contentFrame = toolBarFrame;
        contentFrame.origin.y += toolBarFrame.size.height;
        contentFrame.size.height = bounds.size.height - contentFrame.origin.y;
        controllerView.frame = contentFrame;
    }
    
    if ( controller == _overlayViewController )
    {
        CGRect clipViewFrame = [self _clipFrameForLeftOverlayPosition:_leftOverlayPosition];
        _clipView.frame = clipViewFrame;
        
        CGRect overlayFrame = clipViewFrame;
        overlayFrame.origin = CGPointZero;
        overlayFrame.size.width = _leftOverlayWidth;
        
//        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:_clipView.bounds];
//        _clipView.layer.shadowPath = shadowPath.CGPath;
        
        controllerView.frame = overlayFrame;
    }
}


- (void)_prepareForDeployingViewController:(UIViewController*)controller
{
    UIView *selfView = _contentView;
    
    if ( controller == _overlayViewController )
    {
        if ( _clipView == nil )
        {
            CGRect clipViewFrame = [self _clipFrameForLeftOverlayPosition:_leftOverlayPosition];
            _clipView = [[SWClipView alloc] initWithFrame:clipViewFrame];
            _clipView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleRightMargin;
            [_clipView setClipsToBounds:YES];
            [selfView insertSubview:_clipView aboveSubview:_toolbar];
            
            //[_clipView setBackgroundColor:[UIColor yellowColor]];
        }
        
        if ( _shadeView == nil )
        {
            CGRect shadeViewFrame = selfView.bounds;
            _shadeView = [[UIView alloc] initWithFrame:shadeViewFrame];
            _shadeView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            //[_shadeView setBackgroundColor:[UIColor whiteColor]];
            //[_shadeView setBackgroundColor:[UIColor grayColor]];
            [_shadeView setBackgroundColor:[UIColor colorWithRed:0.33 green:0.33 blue:0.33 alpha:1]];
            //[_shadeView setAlpha:_leftOverlayPosition==SWLeftOverlayPositionShown?0.5:0];
            [_shadeView setAlpha:0];
            _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTapGesture:)];
            _tapGestureRecognizer.delegate = self;
            [_shadeView addGestureRecognizer:_tapGestureRecognizer];
            
            [selfView insertSubview:_shadeView belowSubview:_clipView];
            //NSLog( @"new shadeView: %@", _shadeView);
        }
    }
}


- (void)_addViewFromController:(UIViewController*)controller
{
    //UIView *selfView = self.view;
    UIView *selfView = _contentView;    
    UIView *controllerView = controller.view;
    
    if ( controller == _contentViewController )
    {
        [selfView insertSubview:controllerView belowSubview:_toolbar];
        controllerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
    }
    
    if ( controller == _overlayViewController )
    {        
        [_clipView addSubview:controllerView];
        controllerView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleRightMargin;
    }
}


- (void)_removeViewFromController:(UIViewController*)controller
{
    UIView *controllerView = controller.view;
    [controllerView removeFromSuperview];
    
    if ( controller == _overlayViewController )
    {
        [_shadeView removeFromSuperview];
        //NSLog( @"remove shadeView: %@", _shadeView);
        _shadeView = nil;
        _tapGestureRecognizer = nil;
    }
}


#pragma mark - Gesture Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer
{
    // only allow gesture if no previous request is in process
    
    if ( recognizer == _panGestureRecognizer )
        return [self _panGestureShouldBegin];
    
    if ( recognizer == _tapGestureRecognizer )
        return YES;
    
    return NO;
}


- (BOOL)_panGestureShouldBegin
{
    // forbid gesture if the initial translation is not horizontal
    UIView *recognizerView = _panGestureRecognizer.view;
    CGPoint translation = [_panGestureRecognizer translationInView:recognizerView];
    if ( fabs(translation.y/translation.x) > 1 )
        return NO;

    // forbid gesture if the following delegate is implemented and returns NO
//    if ( [_delegate respondsToSelector:@selector(revealControllerPanGestureShouldBegin:)] )
//        if ( [_delegate revealControllerPanGestureShouldBegin:self] == NO )
//            return NO;

    return YES ;
}


#pragma mark - Gesture Based Reveal

- (void)_handleTapGesture:(UITapGestureRecognizer *)recognizer
{
    [self setLeftOverlayPosition:SWLeftOverlayPositionHidden animated:YES];
    if ( [_delegate respondsToSelector:@selector(toolbarViewControllerDidHandleTapRecognizer:)] )
        [_delegate toolbarViewControllerDidHandleTapRecognizer:self];
}


- (void)_handleRevealGesture:(UIPanGestureRecognizer *)recognizer
{
    switch ( recognizer.state )
    {
        case UIGestureRecognizerStateBegan:
            [self _handleLeftRevealGestureStateBeganWithRecognizer:recognizer];
            break;
            
        case UIGestureRecognizerStateChanged:
            [self _handleLeftRevealGestureStateChangedWithRecognizer:recognizer];
            break;
            
        case UIGestureRecognizerStateEnded:
            [self _handleLeftRevealGestureStateEndedWithRecognizer:recognizer];
            break;
            
        case UIGestureRecognizerStateCancelled:
        //case UIGestureRecognizerStateFailed:
            [self _handleLeftRevealGestureStateCancelledWithRecognizer:recognizer];
            break;
            
        default:
            break;
    }
}


- (void)_handleLeftRevealGestureStateBeganWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    // we store the initial position and initialize a target position
    _panInitialLeftOverlayPosition = _leftOverlayPosition;
}


- (void)_handleLeftRevealGestureStateChangedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGFloat translation = [recognizer translationInView:_clipView].x;

    CGRect vRect = [self _clipFrameForLeftOverlayPosition:SWLeftOverlayPositionShown];
    CGRect baseLocation = [self _clipFrameForLeftOverlayPosition:_panInitialLeftOverlayPosition];
    
    CGFloat xPosition = baseLocation.origin.x + translation;
    
    CGRect frame = baseLocation;
    frame.origin.x = xPosition;
    
    if ( xPosition < vRect.origin.x - vRect.size.width )
        frame.origin.x = vRect.origin.x - vRect.size.width;
    
    else if ( xPosition > vRect.origin.x)
        frame.origin.x = vRect.origin.x;
    
    _clipView.frame = frame;
}



- (void)_handleLeftRevealGestureStateEndedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    //UIView *frontView = _contentView.frontView;
    CGRect vRect = [self _clipFrameForLeftOverlayPosition:SWLeftOverlayPositionShown];
    
    CGFloat xPosition = _clipView.frame.origin.x;
    CGFloat velocity = [recognizer velocityInView:_clipView].x;
    //NSLog( @"Velocity:%1.4f", velocity);
    
    // initially we assume drag to left and default duration
    SWLeftOverlayPosition position = SWLeftOverlayPositionShown;
    NSTimeInterval duration = kDefaultDuration;

    // Velocity driven change:
    if (fabs(velocity) > 200.0)
    {
        // we may need to set the drag position and to adjust the animation duration
        CGFloat journey = vRect.origin.x-xPosition;
        if (velocity < 0.0f)
        {
            position = SWLeftOverlayPositionHidden;
            journey = vRect.size.width - journey;
        }
        
        duration = fabs(journey/velocity);
    }
    else
    {
        // we may need to set the drag position
        if (xPosition-vRect.origin.x < -vRect.size.width*0.5f)
        {
            position = SWLeftOverlayPositionHidden;
        }
    }

    //[self _setLeftDetailViewControllerPosition:position withDuration:duration];
    
    [self setLeftOverlayPosition:position animated:duration>0];
}


- (void)_handleLeftRevealGestureStateCancelledWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
}



@end


#pragma mark - ToolbarContainment

@implementation UIViewController(SWToolbarContainment)



- (SWToolbarViewController*)toolbarViewController
{
    UIViewController *parent = self;
    Class toolbarControllerClass = [SWToolbarViewController class];
    while ( parent && ![parent isKindOfClass:toolbarControllerClass] )
    {
        parent = [parent parentViewController];
    }
    return (id)parent;
}

- (void)setToolbarControllerItems:(NSArray *)toolbarItems animated:(BOOL)animated
{
    [self setToolbarItems:toolbarItems animated:animated];
    SWToolbarViewController *toolbarController = [self toolbarViewController];
    [toolbarController _updateToolbarAnimated:animated];
}


- (void)setToolbarControllerItems:(NSArray *)array
{
    [self setToolbarControllerItems:array animated:NO];
}

- (NSArray*)toolbarControllerItems
{
    return self.toolbarItems;
}




@end