//
//  SWFloatingPopover.m
//  FloatingPopover
//
//  Created by Joan Martín Hernàndez on 6/27/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWFloatingPopoverController.h"

#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#import "UIView+Scale.h"
#import "UIView+Genie.h"


#import "SWFloatingContentOverlayView.h"
#import "SWFloatingFrameView.h"
#import "SWClearNavigationBar.h"
#import "SWFloatingPopoverView.h"

#import "BubbleView.h"
#import "RoundedTextView.h"

#import "SWKeyboardListener.h"

//#import "SWFloatingPopoverManager.h"

//#define kDefaultMaskColor  [UIColor colorWithWhite:0 alpha:0.5]
//#define kDefaultFrameColor [UIColor colorWithRed:0.10f green:0.12f blue:0.16f alpha:1.00f]
//#define kRootKey           @"root"
#define kAnimationDuration 0.25f  // mes o menys deu ser el mateix que un popover


@interface SWFloatingPopoverController()<SWFloatingPopoverViewDelegate>

@end

@implementation SWFloatingPopoverController 
{
    SWFloatingPopoverView *_popoverView;
    UINavigationController *_navController;
    
    UIPanGestureRecognizer *_panGesture;
    UITapGestureRecognizer *_tapGesture;
    CGPoint _startPoint;
    
    //CGFloat _floatingOffset;
    CGRect _floatingFrame;
    UIEdgeInsets _floatingTableInsets;
}

@synthesize presented = _presented;
@synthesize frameColor = _frameColor;
@synthesize contentViewController = _contentViewController;
@synthesize showsCloseButton = _showsCloseButton;
@synthesize delegate = _delegate;
@synthesize mainViewController = _mainViewController;
@synthesize key = _key;
@synthesize presentationPosition;



+ (CGFloat)framePadding
{
    return kFramePadding;
}

- (id)init 
{
	return [self initWithContentViewController:nil withKey:nil forPresentingInController:nil];
}


- (id)initWithContentViewController:(UIViewController*)viewController withKey:(id)key forPresentingInController:(UIViewController *)presentingController
{
    self = [super init];
    if (self)
    {
        //_frameColor = kDefaultFrameColor;
        _key = key;
        _contentViewController = viewController;
        [self _setMainViewControllerForController:presentingController];
        _showsCloseButton = NO;
        _showsInFullScreen = NO;
    }
    return self;
}

-(void)dealloc
{
    //NSLog( @"SWFloatingPopoverController dealloc" );
}

#pragma mark Overriden Methods

- (void)loadView
{
    //[super loadView];
    //CGRect frame = self.view.frame;
    //CGRect frame = self.view.bounds;
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    
    _popoverView = [[SWFloatingPopoverView alloc] initWithFrame:frame];
    _popoverView.delegate = self;
    
    self.view = _popoverView;
}

- (void)viewDidLoad 
{    
	[super viewDidLoad];
        
    [self updateFrameColor];
    //UIView *selfView = self.view;
    
    
    //CGSize popoverSize = _contentViewController.contentSizeForViewInPopover;
    CGSize popoverSize = _contentViewController.preferredContentSize;
    CGRect finalFrame = CGRectMake(0,
                                   0,
                                   popoverSize.width+2*kFramePadding,
                                   popoverSize.height+kFramePadding+kBorderOffset);
    
    _popoverView.backgroundColor = [UIColor clearColor];
    _popoverView.frame = finalFrame;
    
    if ( _showsInFullScreen )
    {
        _popoverView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        //_popoverView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleHeight;
    }
    else
    {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        _panGesture.delegate = self;
        //_panGesture.delaysTouchesBegan = YES;
        [_popoverView addGestureRecognizer:_panGesture];
    
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
        _tapGesture.delegate = self;
        _tapGesture.cancelsTouchesInView = NO;
        //_tapGesture.delaysTouchesBegan = NO;
        [_popoverView addGestureRecognizer:_tapGesture];
        
        _popoverView.autoresizingMask = UIViewAutoresizingNone;
    }
    
    
//    if ( _showsInFullScreen )
//    {
//        //_popoverView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//        _popoverView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleHeight;
//    }
//    else
//    {
//        _popoverView.autoresizingMask = UIViewAutoresizingNone;
//    }
    
    
    
    [_popoverView prepareFrameWithNavigationBar:YES animated:NO];
    
    _navController = [self _obtainNavigationController];
    
    [self addChildViewController:_navController];
    
    UIView *navView = _navController.view;
    UIView *contentView = _popoverView.contentView;
    navView.frame = contentView.bounds;
    navView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [contentView addSubview:navView];
    [_navController didMoveToParentViewController:self];
    
    [self _displayCloseButtonIfNeeded];
}


//- (void)viewDidUnload
//{
//    _panGesture = nil;
//        
//    [_navController willMoveToParentViewController:nil];
//    [_navController.view removeFromSuperview];
//    [_navController removeFromParentViewController];
//    
//    _navController = nil;
//    
//    _popoverView = nil;
//    
//    [super viewDidUnload];
//}

- (void)viewWillAppear:(BOOL)animated
{    
    [super viewWillAppear:animated];
    
    SWKeyboardListener *keyb = [SWKeyboardListener sharedInstance];
    
    UIWindow *window = self.view.window;
    const BOOL belowKeyboard = [_mainViewController.view isDescendantOfView:window];
    
    if (belowKeyboard && keyb.isVisible)
    {
        [self _adjustControllerToKeyboard:animated];
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(_keyboardNotification:) name:SWKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(_keyboardNotification:) name:SWKeyboardWillHideNotification object:nil];
    
    [nc addObserver:self selector:@selector(_finishKeyboardNotification:) name:SWKeyboardDidShowNotification object:nil];
    [nc addObserver:self selector:@selector(_finishKeyboardNotification:) name:SWKeyboardDidHideNotification object:nil];
}


- (void)viewWillDisappear:(BOOL)animated
{        
    [super viewWillDisappear:animated];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
//{
//	return YES;
//}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


#pragma mark Properties

- (void)setFrameColor:(UIColor*)frameColor
{
    _frameColor = frameColor;
    
    if (self.isViewLoaded)
    {
        [self updateFrameColor];
    }
}


- (void)setShowsCloseButton:(BOOL)showCloseButton
{
    _showsCloseButton = showCloseButton;
    [self _displayCloseButtonIfNeeded];

}


- (void)_displayCloseButtonIfNeeded
{
    UIBarButtonItem *closeItem = nil;
    
    if (_showsCloseButton)
    {
//        closeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"xWhiteShadow.png"]
//                    style:UIBarButtonItemStyleBordered
//                    target:self
//                    action:@selector(closeButtonAction:)];
        
        closeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                    target:self
                    action:@selector(closeButtonAction:)];
    }
     
    // determinem el rootViewController a partir del _navController (no sempre es el _contentViewController)
    UIViewController *rootViewController = nil;
    NSArray *viewControllers = _navController.viewControllers;
    if ( viewControllers.count>0 ) rootViewController = [viewControllers objectAtIndex:0];
    rootViewController.navigationItem.leftBarButtonItem = closeItem;
     
}

//- (UINavigationController*)createNavigationController 
//{
//    UIViewController *dummy = [[UIViewController alloc] init];
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:dummy];
//    
//    // Archive navigation controller for changing navigationbar class
//    [navController navigationBar];
//    NSMutableData *data = [[NSMutableData alloc] init];
//    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
//    [archiver encodeObject:navController forKey:kRootKey];
//    [archiver finishEncoding];
//    
//    // Unarchive it with changing navigationbar class
//    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
//    [unarchiver setClass:[SWClearNavitagionBar class] forClassName:NSStringFromClass([UINavigationBar class])];
//    //[unarchiver setClass:[SWNavigationController class] forClassName:NSStringFromClass([UINavigationController class])];
//    navController = [unarchiver decodeObjectForKey:kRootKey];
//    
////    const float colorMask[6] = {222, 255, 222, 255, 222, 255};
////    UIImage *img = [[UIImage alloc] init];
////    UIImage *maskedImage = [UIImage imageWithCGImage:CGImageCreateWithMaskingColors(img.CGImage, colorMask)];
////    [navController.navigationBar setBackgroundImage:maskedImage forBarMetrics:UIBarMetricsDefault]; 
//    
//	return navController;
//}


- (UINavigationController*)_obtainNavigationController
{
    UINavigationController *navController = nil;
    
    // si el contentViewController es un navigationController l'utilitzem directament 
    if ( [_contentViewController isKindOfClass:[UINavigationController class]] )
    {
        navController = (id)_contentViewController;
    }
    
    // en cas contrari en creem un amb el contentViewController
    else
    {
        navController = [[UINavigationController alloc] initWithRootViewController:_contentViewController];
      //  [_contentViewController setAutomaticallyAdjustsScrollViewInsets:NO];
    }
    
    UINavigationBar *navBar = [navController navigationBar];
    
    // creem un background trasparent per el navigationBar
    //[navBar setBackgroundColor:[UIColor clearColor]];
    [navBar setBackgroundColor:_popoverView.frameColor];
    
    UIImage *img = [[UIImage alloc] init];
    [navBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
    //[navBar setBackgroundImage:img forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];   // ios7
	return navController;
}


- (void)_setMainViewControllerForController:(UIViewController*)controller
{
    UIViewController *viewController = controller;
    
    if (!viewController) 
    {
        viewController = [[[UIApplication sharedApplication].delegate window] rootViewController];
    }
                
    if ([viewController isKindOfClass:[UINavigationController class]])
    {
        viewController = [(id)viewController visibleViewController];
    }
        
    _mainViewController = viewController;
    
    //NSLog( @"FloatingPopover mainViewController %@", _mainViewController) ;
}


#pragma mark Public Methods

- (CGPoint)presentationPosition
{
    return _popoverView.center;
}


- (CGPoint)_adjustedPoint:(CGPoint)point forRevealRect:(CGRect)revealRect
{
    CGSize rootViewSize = _mainViewController.view.bounds.size;
    CGPoint adjustedPoint = CGPointZero;
    
    if ( CGRectEqualToRect(CGRectZero,revealRect) )
    {
//        adjustedPoint.x = rootViewSize.width/2.0f;
//        adjustedPoint.y = rootViewSize.height/2.0f;
        adjustedPoint = point;
    }
    else
    {
        const CGFloat hMargin = 44;
        const CGFloat vMargin = 44;
    
        [self view];  // <-- carreguem el view si no ho esta
        CGSize popoverSize = _popoverView.bounds.size;
    
        CGFloat leftSpace = revealRect.origin.x;
        CGFloat rightSpace = rootViewSize.width-(revealRect.origin.x+revealRect.size.width);
        CGFloat topSpace = revealRect.origin.y;
        CGFloat bottomSpace = rootViewSize.height-(revealRect.origin.y+revealRect.size.height);
    
        CGFloat hSpace = fmaxf(leftSpace, rightSpace);
        CGFloat vSpace = fmaxf(topSpace, bottomSpace);

        if ( hSpace > vSpace )
        {
            adjustedPoint.y = revealRect.origin.y + roundf(revealRect.size.height/2.0f);
        
            if ( leftSpace > rightSpace )
                adjustedPoint.x = revealRect.origin.x - popoverSize.width/2.0f - hMargin;
            else
                adjustedPoint.x = revealRect.origin.x + revealRect.size.width + popoverSize.width/2.0f + hMargin;
        }
        else
        {
            adjustedPoint.x = revealRect.origin.x + roundf(revealRect.size.width/2.0f);
        
            if ( topSpace > bottomSpace )
                adjustedPoint.y = revealRect.origin.y - popoverSize.height/2.0f - vMargin;
            else
                adjustedPoint.y = revealRect.origin.y + revealRect.size.height + popoverSize.height/2.0f + vMargin;
        }
    }
    
    return adjustedPoint;
}


static BCRectEdge _startEdgeForPoint_revealRect(CGPoint point, CGRect revealRect)
{
    BCRectEdge rectEdge;
    
    CGFloat leftGap = revealRect.origin.x - point.x;
    CGFloat rightGap = point.x - (revealRect.origin.x + revealRect.size.width);
    
    CGFloat topGap = revealRect.origin.y - point.y;
    CGFloat bottomGap = point.y - (revealRect.origin.y + revealRect.size.height);

    CGFloat hGap = fmax(leftGap,rightGap);
    CGFloat vGap = fmax(topGap,bottomGap);
    
    if ( hGap > vGap )
    {
        if ( leftGap > rightGap ) rectEdge = BCRectEdgeLeft;
        else rectEdge = BCRectEdgeRight;
    }
    else
    {
        if ( topGap > bottomGap ) rectEdge = BCRectEdgeTop;
        else rectEdge = BCRectEdgeBottom;
    }
    
    return rectEdge;
}


static CGRect _adjustRect_forEdge(CGRect revealRect, BCRectEdge rectEdge)
{
    
    if ( rectEdge == BCRectEdgeLeft || rectEdge == BCRectEdgeRight )
    {
        CGFloat revealCenterY = revealRect.origin.y + revealRect.size.height/2.0f;

        if ( rectEdge == BCRectEdgeRight )
            revealRect.origin.x = revealRect.origin.x + revealRect.size.width;
        
        revealRect.size.width = 0.0f;
        revealRect.size.height = fminf( 40.0f, revealRect.size.height );
        revealRect.origin.y = revealCenterY - revealRect.size.height/2.0f;
    }
    else
    {
        CGFloat revealCenterX = revealRect.origin.x + revealRect.size.width/2.0f;
        
        if ( rectEdge == BCRectEdgeBottom )
            revealRect.origin.y = revealRect.origin.y + revealRect.size.height;
        
        revealRect.size.height = 0.0f;
        revealRect.size.width = fminf( 40.0f, revealRect.size.width );
        revealRect.origin.x = revealCenterX - revealRect.size.width/2.0f;
    }
    
    return revealRect;
}


//// ho presenta en un punt depenent del revealRect
//- (void)presentFloatingPopoverWithAnimation:(SWFloatingPopoverAnimationKind)animationKind //fromRect:(CGRect)revealRect
//{
//    CGRect revealRect = CGRectZero;
//    if ( [_delegate respondsToSelector:@selector(floatingPopoverControllerGetRevealRect:)] )
//        revealRect = [_delegate floatingPopoverControllerGetRevealRect:self];
//    
//    CGPoint point = [self _adjustedPointForRevealRect:revealRect];
//
//    [self _presentFloatingPopoverAtPoint:point withAnimation:animationKind fromRect:revealRect];
//}

// ho presenta en un punt depenent del revealRect
- (void)presentChildFloatingPopoverAtPoint:(CGPoint)point withAnimation:(SWFloatingPopoverAnimationKind)animationKind
{
    CGRect revealRect = CGRectZero;
    if ( [_delegate respondsToSelector:@selector(floatingPopoverControllerGetRevealRect:)] )
        revealRect = [_delegate floatingPopoverControllerGetRevealRect:self];
    
    point = [self _adjustedPoint:point forRevealRect:revealRect];

    [self _presentFloatingPopoverAtPoint:point withAnimation:animationKind fromRect:revealRect];
}

// ho presenta en un punt determinat
- (void)presentFloatingPopoverAtPoint:(CGPoint)point withAnimation:(SWFloatingPopoverAnimationKind)animationKind
{
    CGRect revealRect = CGRectZero;
    if ( [_delegate respondsToSelector:@selector(floatingPopoverControllerGetRevealRect:)] )
        revealRect = [_delegate floatingPopoverControllerGetRevealRect:self];
    
    [self _presentFloatingPopoverAtPoint:point withAnimation:animationKind fromRect:revealRect];
}

// ho presenta en un punt fixe inclus a fora del mainViewController
- (void)presentFloatingPopoverAtFixedPoint:(CGPoint)point withAnimation:(SWFloatingPopoverAnimationKind)animationKind
{
    CGRect revealRect = CGRectZero;
    if ([_delegate respondsToSelector:@selector(floatingPopoverControllerGetRevealRect:)])
        revealRect = [_delegate floatingPopoverControllerGetRevealRect:self];

    UIView *selfView = self.view;
    CGSize popoverSize = selfView.bounds.size;
    CGRect finalFrame = CGRectMake(point.x - (popoverSize.width / 2),
                                   point.y - (popoverSize.height / 2),
                                   popoverSize.width,
                                   popoverSize.height);
    
    _fixed = YES;
    [self _presentFloatingPopoverInRect:finalFrame withAnimation:animationKind fromRect:revealRect];
}


- (void)_presentFloatingPopoverAtPoint:(CGPoint)point withAnimation:(SWFloatingPopoverAnimationKind)animationKind fromRect:(CGRect)revealRect
{
    UIView *selfView = self.view;
    CGSize popoverSize = selfView.bounds.size;
    CGRect finalFrame = CGRectMake(point.x - /*roundf*/(popoverSize.width/2.0f),
                                   point.y - /*roundf*/(popoverSize.height/2.0f),
                                   popoverSize.width,         // ooo  Agafar
                                   popoverSize.height);       // ooo
    
    UIViewController *mainViewController = _mainViewController;
    UIView *rootView = mainViewController.view;
    CGSize viewSize = rootView.bounds.size;
    
    BOOL hasStatusBar = NO;
    CGFloat yOffset = hasStatusBar?20:0;
    
    if (finalFrame.origin.x < 0)
        finalFrame.origin.x = 0;
    
    if (finalFrame.origin.y < yOffset)
        finalFrame.origin.y = yOffset;
    
    if (finalFrame.origin.x + finalFrame.size.width > viewSize.width)
        finalFrame.origin.x = viewSize.width - finalFrame.size.width;
    
    if (finalFrame.origin.y + finalFrame.size.height > viewSize.height)
        finalFrame.origin.y = viewSize.height - finalFrame.size.height;
    
    _fixed = NO;
    [self _presentFloatingPopoverInRect:finalFrame withAnimation:animationKind fromRect:revealRect];
}


- (void)_presentFloatingPopoverInRect:(CGRect)rect withAnimation:(SWFloatingPopoverAnimationKind)animationKind fromRect:(CGRect)revealRect
{
    if (_presented)
        return;
    
    _presented = YES;
    
    UIViewController *mainViewController = _mainViewController;
    UIView *rootView = mainViewController.view;
    UIView *selfView = self.view;
    
    if ( _showsInFullScreen )
    {
        CGFloat magic = 28;
        CGFloat topOffset = magic + mainViewController.topLayoutGuide.length;
        rect = rootView.bounds;
        rect.origin.y += topOffset;
        rect.size.height -= topOffset;
        
//        CGRect rootBounds = rootView.bounds;
//        rect.origin.x = 0;
//        rect.origin.y = magic + mainViewController.topLayoutGuide.length;
//        rect.size.height = rootBounds.size.height-rect.origin.y;
    }
    
	//selfView.alpha = 0;
    [mainViewController addChildViewController:self];
    
    //NSLog( @"floatingPopoverView frame: %@", NSStringFromCGRect(finalFrame));
    selfView.frame = rect;
    [rootView addSubview:selfView];
    
    //SWFloatingPopoverController *me = self;
    
    if ([_delegate respondsToSelector:@selector(floatingPopoverControllerWillPresentPopover:)])
        [_delegate floatingPopoverControllerWillPresentPopover:self];
    
    
    if ( animationKind == SWFloatingPopoverAnimationGenie )
    {
        CGPoint finalPoint;
        finalPoint.x = rect.origin.x + rect.size.width/2.0f;
        finalPoint.y = rect.origin.y + rect.size.height/2.0f;
        
        BCRectEdge startEdge = _startEdgeForPoint_revealRect(finalPoint, revealRect);
        CGRect startRect = _adjustRect_forEdge(revealRect, startEdge);
        
        [selfView genieOutTransitionWithDuration:kAnimationDuration startRect:startRect startEdge:startEdge completion:^
        {
             [self didMoveToParentViewController:mainViewController];
        }];
    }
    
    else if ( animationKind == SWFloatingPopoverAnimationFade )
    {
    	selfView.alpha = 0;
        [UIView animateWithDuration:kAnimationDuration
        animations:^(void)
        {
            [selfView setAlpha:1.0f];
        }
        completion:^(BOOL finished)
        {
            [self didMoveToParentViewController:mainViewController];
        }];
    }
    
    else if ( animationKind == SWFloatingPopoverAnimationScale )
    {
        [selfView setScaledFrame:CGRectMake( rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2,20,20)];
        
        [UIView animateWithDuration:kAnimationDuration
        animations:^(void)
        {
            [selfView setScaledFrame:rect];
        }
        completion:^(BOOL finished)
        {
            [self didMoveToParentViewController:mainViewController];
        }];
    }
    
    else // no animation
    {
        [self didMoveToParentViewController:mainViewController];
    }
}

- (void)closeButtonAction:(id)sender
{
    if ( [_delegate respondsToSelector:@selector(floatingPopoverControllerCloseButton:)] )
        [_delegate floatingPopoverControllerCloseButton:self];
}




- (void)dismissFloatingPopoverWithAnimation:(SWFloatingPopoverAnimationKind)animationKind
{
    CGRect revealRect = CGRectZero;
    
    if ( animationKind == SWFloatingPopoverAnimationGenie )
    {
        if ( [_delegate respondsToSelector:@selector(floatingPopoverControllerGetRevealRect:)] )
            revealRect = [_delegate floatingPopoverControllerGetRevealRect:self];
    }

    [self _dismissFloatingPopoverWithAnimation:animationKind toRect:revealRect];
}


- (void)_dismissFloatingPopoverWithAnimation:(SWFloatingPopoverAnimationKind)animationKind toRect:(CGRect)revealRect
{
    if ([_delegate respondsToSelector:@selector(floatingPopoverControllerWillDismissPopover:)])
        [_delegate floatingPopoverControllerWillDismissPopover:self];

    [self willMoveToParentViewController:nil];
    
    UIView *selfView = self.view;
    
    void (^completion)(BOOL) = ^(BOOL finished)
    {
        [selfView removeFromSuperview];
            
        _presented = NO;
            
        [self removeFromParentViewController];
            
        if ([_delegate respondsToSelector:@selector(floatingPopoverControllerDidDismissPopover:)])
            [_delegate floatingPopoverControllerDidDismissPopover:self];
    };
    
    if ( animationKind == SWFloatingPopoverAnimationGenie )
    {
        CGPoint finalPoint;
        CGRect frame = selfView.frame;
        finalPoint.x = frame.origin.x + frame.size.width/2.0f;
        finalPoint.y = frame.origin.y + frame.size.height/2.0f;

        BCRectEdge destEdge = _startEdgeForPoint_revealRect(finalPoint, revealRect);
        CGRect destRect = _adjustRect_forEdge(revealRect, destEdge);
        
        [selfView genieInTransitionWithDuration:kAnimationDuration destinationRect:destRect destinationEdge:destEdge completion:^
        {
            completion(YES);
        }];
    }
    else if ( animationKind == SWFloatingPopoverAnimationFade )
    {
        [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut
        animations:^
        {
            [selfView setAlpha:0];
        }
        completion:completion];
    }
    else
    {
        completion( YES );
    }
}


- (void)searchBarWillShiftUp
{
    [_popoverView prepareFrameWithNavigationBar:NO animated:YES];
}

- (void)searchBarWillShiftDown
{
    [_popoverView prepareFrameWithNavigationBar:YES animated:YES];
}

- (void)bringToFront
{
    [_mainViewController.view bringSubviewToFront:_popoverView];
    
    if ( [_delegate respondsToSelector:@selector(floatingPopoverControllerDidMoveToFront:)] )
    {
        [_delegate floatingPopoverControllerDidMoveToFront:self];
    }
}


//#pragma mark Touch Event Methods
// El SWFloatingPopoverView no implementa aquests metodes, o sigui que la responder chain acava arribant aqui

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    NSLog( @"touches moved x");
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//   // [self bringToFront];
//}

#pragma mark SWFloatingPopoverViewDelegate

- (void)floatingPopoverViewDidChangeTintsColor:(SWFloatingPopoverView *)popoverView
{
    _frameColor = popoverView.frameColor;
    [self updateFrameColor];
}


#pragma mark Private Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ( gestureRecognizer == _panGesture )
    {
        UIView *view = touch.view;
        //NSLog( @"gesture view :%@", view);
    
        // no interferim amb el desplacament si estem interactuant en controls o textViews
        if ( [view isKindOfClass:[UIControl class]])
            return NO;
    
        if ( [view isKindOfClass:[UITextView class]])
            return NO;
    }
    
    return YES;
}


- (void)panGestureRecognized:(UIPanGestureRecognizer*)recognizer
{
    UIView *view = _popoverView;
    //UIView *superview = view.superview;
    UIView *superview = _mainViewController.view ;
    
    CGPoint point = [recognizer locationInView:superview];
    CGRect frame = view.frame;
    
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
            _startPoint = [recognizer locationInView:view];
            //[superview bringSubviewToFront:view];
            [self bringToFront];
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            CGPoint position = CGPointMake(roundf(point.x - _startPoint.x), roundf(point.y - _startPoint.y));
            view.frame = CGRectMake(position.x, position.y, frame.size.width, frame.size.height);
            break;
        }
            
        case UIGestureRecognizerStateEnded:
            _startPoint = CGPointZero;
            _floatingFrame = _popoverView.frame;  // en cas d'ajust del usuari no volem canviar la posicio en un dismiss del teclat
            
            if ( [_delegate respondsToSelector:@selector(floatingPopoverController:didMoveToPoint:)] )
            {
                CGPoint endPoint = view.center;
//                endPoint.x = endFrame.origin.x + endFrame.size.width/2.0f;
//                endPoint.y = endFrame.origin.y + frame.size.height/2.0f;
                [_delegate floatingPopoverController:self didMoveToPoint:endPoint];
            }
            break;
            
        default:
            break;
    }
}

- (void)tapGestureRecognized:(UIPanGestureRecognizer*)recognizer
{
    [self bringToFront];
}

- (void)updateFrameColor
{
    if ( _frameColor )
    {
        _popoverView.frameColor = _frameColor;
        
        UINavigationBar *navBar = _navController.navigationBar;
        //[navBar setTintColor:_frameColor];
        if ( IS_IOS7 ) [navBar setBackgroundColor:_frameColor];
        else [navBar setBackgroundColor:[UIColor clearColor]];
    }
}

- (void)_keyboardNotification:(NSNotification*)notification
{
    [self _adjustControllerToKeyboard:YES];
}

- (void)_finishKeyboardNotification:(NSNotification*)notification
{
}

- (void)_adjustControllerToKeyboard:(BOOL)animated
{
    if ( _fixed )
        return ;
    
    SWKeyboardListener *keyb = [SWKeyboardListener sharedInstance];

    void (^changeFrameAnimated)(CGRect, BOOL) = ^(CGRect frame, BOOL anim)
    {
        NSTimeInterval duration = 0;
        if ( anim ) duration = 0.25;
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState
        animations:^
        {
            _popoverView.frame = frame;
        }
        completion:nil];
    };


    if ([keyb isVisible] )
    {
        UIViewController *mainViewController = _mainViewController;
        CGSize viewSize = mainViewController.view.bounds.size;
    
        CGFloat keybOffset = [keyb offset];
        CGFloat keyboardOffset = viewSize.height - keybOffset;
        
        if ( CGRectEqualToRect(_floatingFrame, CGRectZero) )
        {
            _floatingFrame = _popoverView.frame;
        }
    
        CGRect popoverFrame = _floatingFrame;
        
        CGFloat upOrigin = 0.0;
        
        if (popoverFrame.origin.y + 300 > keyboardOffset)
            upOrigin = popoverFrame.origin.y + 300 - keyboardOffset;
        
        // origin animation frame
        popoverFrame.origin.y -= upOrigin;
        //if ( popoverFrame.origin.y < 10 ) popoverFrame.origin.y = 10;
        
        CGFloat topGuide = _mainViewController.topLayoutGuide.length;
        if ( popoverFrame.origin.y < topGuide ) popoverFrame.origin.y = topGuide;
    
        changeFrameAnimated( popoverFrame, animated );
    }
    else
    {
        changeFrameAnimated( _floatingFrame, animated );
        _floatingFrame = CGRectZero;   // <-- marquem que hem acabat amb el frame
    }
    
//    if ( _showsInFullScreen )
//        [self setNeedsStatusBarAppearanceUpdate];
}

//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleDefault;
//}


@end


@implementation UIViewController(SWFloatingPopover)

- (SWFloatingPopoverController*)floatingPopoverController
{
    UIViewController *parent = self;
    Class floatingClass = [SWFloatingPopoverController class];
    while ( nil != (parent = [parent parentViewController]) && ![parent isKindOfClass:floatingClass] ) ;
    return (id)parent;
}




@end
