//
//  SWFloatingPopover.m
//  FloatingPopover
//
//  Created by Joan Martín Hernàndez on 6/27/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWFloatingPopoverController.h"

#import <QuartzCore/QuartzCore.h>
#import "SWFloatingContentOverlayView.h"
#import "SWFloatingFrameView.h"
#import "SWClearNavitagionBar.h"
#import "SWPathUtilities.h"

#define kDefaultMaskColor  [UIColor colorWithWhite:0 alpha:0.5]
#define kDefaultFrameColor [UIColor colorWithRed:0.10f green:0.12f blue:0.16f alpha:1.00f]
#define kDefaultPortraitFrameSize  CGSizeMake(320 - 66, 460 - 66)
#define kDefaultLandscapeFrameSize CGSizeMake(480 - 66, 300 - 66)
#define kFramePadding      5.0f
#define kRootKey           @"root"
#define kShadowColor       [UIColor blackColor]
#define kShadowOffset      CGSizeMake(0, 2.0f)
#define kShadowOpacity     0.70f
#define kShadowRadius      10.0f
#define kAnimationDuration 0.3f

@interface SWFloatingPopoverController()

@property (nonatomic, readonly, strong) SWFloatingFrameView *frameView;
@property (nonatomic, readonly, strong) UIView *contentView;
@property (nonatomic, readonly, strong) SWFloatingContentOverlayView *contentOverlayView;
@property (nonatomic, readonly, strong) UINavigationController *navigationController;
@property (nonatomic, strong) UIImageView *shadowView;

@end

@implementation SWFloatingPopoverController 
{
    UIPanGestureRecognizer *_panGesture;
    CGPoint _startPoint;
}

@synthesize presented = _presented;
@synthesize frameColor = _frameColor;
@synthesize contentViewController = _contentViewController;

@synthesize delegate = _delegate;

@synthesize shadowView = _shadowView;
@synthesize frameView = _frameView;
@synthesize contentView = _contentView;
@synthesize contentOverlayView = _contentOverlayView;
@synthesize navigationController = _navController;

- (id)init 
{
	return [self initWithContentViewController:nil];
}

- (id)initWithContentViewController:(UIViewController*)viewController;
{
    self = [super init];
    if (self) {        
        _frameColor = kDefaultFrameColor;
        
        if (viewController) {
            _contentViewController = viewController;
            [self.navigationController setViewControllers:[NSArray arrayWithObject:_contentViewController]];
        }
    }
    return self;
}

#pragma mark UIViewController

- (void)viewDidLoad 
{    
	[super viewDidLoad];
        
    [self updateFrameColor];
        
    self.view.autoresizingMask = UIViewAutoresizingNone;
    
    self.view.frame = CGRectMake(0, 0, _contentViewController.contentSizeForViewInPopover.width,  _contentViewController.contentSizeForViewInPopover.height);
        
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognized:)];
    [self.view addGestureRecognizer:_panGesture];
        
	[self.view setBackgroundColor:[UIColor clearColor]];
    
	[self.view addSubview:[self frameView]];
	[self.frameView addSubview:[self contentView]];
	[self.contentView addSubview:[self.navigationController view]];
	[self.frameView addSubview:[self contentOverlayView]];
}

- (void)viewDidUnload
{
    _panGesture = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
{
	return YES;
}

#pragma mark Properties

- (void)setContentViewController:(UIViewController *)contentViewController
{
    _contentViewController = contentViewController;
    [self.navigationController setViewControllers:[NSArray arrayWithObject:_contentViewController] animated:_presented];
}

- (void)setFrameColor:(UIColor*)frameColor 
{
    _frameColor = frameColor;
    
    if (self.isViewLoaded) {
        [self updateFrameColor];
    }
}

- (SWFloatingFrameView*)frameView 
{
	if (_frameView == nil) {
		_frameView = [[SWFloatingFrameView alloc] init];
		[_frameView.layer setShadowColor:[kShadowColor CGColor]];
		[_frameView.layer setShadowOffset:kShadowOffset];
		[_frameView.layer setShadowOpacity:kShadowOpacity];
		[_frameView.layer setShadowRadius:kShadowRadius];
	}
    return _frameView;
}

- (UIView*)contentView 
{
	if (_contentView == nil) {
		_contentView = [[UIView alloc] init];
		[_contentView setClipsToBounds:YES];
	}
	return _contentView;
}

- (SWFloatingContentOverlayView*)contentOverlayView 
{
	if (_contentOverlayView == nil) {
		_contentOverlayView = [[SWFloatingContentOverlayView alloc] init];
		[_contentOverlayView setUserInteractionEnabled:NO];
	}
	return _contentOverlayView;
}

- (UINavigationController*)navigationController 
{
	if (_navController == nil) {
		UIViewController *dummy = [[UIViewController alloc] init];
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:dummy];
		
		// Archive navigation controller for changing navigationbar class
		[navController navigationBar];
		NSMutableData *data = [[NSMutableData alloc] init];
		NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
		[archiver encodeObject:navController forKey:kRootKey];
		[archiver finishEncoding];
		
		// Unarchive it with changing navigationbar class
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		[unarchiver setClass:[SWClearNavitagionBar class]
				forClassName:NSStringFromClass([UINavigationBar class])];
		_navController = [unarchiver decodeObjectForKey:kRootKey];
	}
	return _navController;
}

#pragma mark Public Methods

- (void)presentFloatingPopoverAtPoint:(CGPoint)point inView:(UIView *)view animated:(BOOL)animated
{    
    @synchronized(self) {
		if (_presented) {
			return;
		}
		_presented = YES;
	}
    
    CGSize viewSize = view.frame.size;
    
    // (JMH) No entenc pq he de posar el següent codi. Resulta que en funció de l'orientació la "size" de la view em ve girada. (Sempre en portrait).
    switch (self.interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            viewSize = CGSizeMake(viewSize.height, viewSize.width);
            break;
        default:
            break;
    }
    
    CGSize popoverSize = _contentViewController.contentSizeForViewInPopover;
    
    CGRect finalFrame = CGRectMake(point.x - roundf(popoverSize.width/2.0),
                                   point.y - roundf(popoverSize.height/2.0),
                                   popoverSize.width,
                                   popoverSize.height);
          
    if (finalFrame.origin.x < 0)
        finalFrame.origin.x = 0;
    
    if (finalFrame.origin.y < 0)
        finalFrame.origin.y = 0;
    
    if (finalFrame.origin.x + finalFrame.size.width > viewSize.width)
        finalFrame.origin.x = viewSize.width - finalFrame.size.width;
    
    if (finalFrame.origin.y + finalFrame.size.height > viewSize.height)
        finalFrame.origin.y = viewSize.height - finalFrame.size.height;
    
    self.view.frame = finalFrame;
    
	[self.view setAlpha:0];
    
	[view addSubview:[self view]];
	
	[self layoutFrameView];
	
	__block SWFloatingPopoverController *me = self;
	[UIView animateWithDuration:(animated ? kAnimationDuration : 0)
					 animations:
	 ^(void) {
		 [me.view setAlpha:1.0f];
	 }];
}

- (void)dismissFloatingPopoverAnimated:(BOOL)animated
{
    void (^animations)(void) = ^() {
		[self.view setAlpha:0];
    };
    
    void (^completion)(BOOL) = ^(BOOL finished) {
        if (finished) {
            [self.view removeFromSuperview];
            _presented = NO;
                        
            if ([_delegate respondsToSelector:@selector(floatingPopoverControllerDidDismissPopover:)])
                [_delegate floatingPopoverControllerDidDismissPopover:self];
        }
    };
    
    CGFloat duration = (animated ? kAnimationDuration : 0);
    
	[UIView animateWithDuration:duration animations:animations completion:completion];
}

#pragma mark Private Methods

- (void)layoutFrameView 
{    
	// Frame
	CGSize frameSize = _contentViewController.contentSizeForViewInPopover;

	UIView *frameView = [self frameView];
	[frameView setFrame:CGRectMake(frameView.frame.origin.x,
                                   frameView.frame.origin.y,
								   frameSize.width,
								   frameSize.height)];
	[frameView setNeedsDisplay];
    
	// Content
	UIView *contentView = [self contentView];
	CGRect contentFrame = CGRectMake(kFramePadding, 0,
									 frameSize.width - kFramePadding * 2,
									 frameSize.height - kFramePadding);
	CGSize contentSize = contentFrame.size;
	[contentView setFrame:contentFrame];
	
	// Navigation
	UIView *navView = [self.navigationController view];
	CGFloat navBarHeight = [self.navigationController.navigationBar sizeThatFits:[contentView bounds].size].height;
	[navView setFrame:CGRectMake(0, 0,
								 contentSize.width, contentSize.height)];
	[self.navigationController.navigationBar setFrame:CGRectMake(0, 0,
																 contentSize.width, navBarHeight)];
	
	// Content overlay
	UIView *contentOverlay = [self contentOverlayView];
	CGFloat contentFrameWidth = [SWFloatingContentOverlayView frameWidth];
	[contentOverlay setFrame:CGRectMake(contentFrame.origin.x - contentFrameWidth,
										contentFrame.origin.y + navBarHeight - contentFrameWidth,
										contentSize.width  + contentFrameWidth * 2,
										contentSize.height - navBarHeight + contentFrameWidth * 2)];
	[contentOverlay setNeedsDisplay];
	[contentOverlay.superview bringSubviewToFront:contentOverlay];
	
	// Shadow
	CGFloat radius = [self.frameView cornerRadius];
	CGPathRef shadowPath = CQMPathCreateRoundingRect(CGRectMake(0, 0,
																frameSize.width, frameSize.height),
													 radius, radius, radius, radius);
	[frameView.layer setShadowPath:shadowPath];
	CGPathRelease(shadowPath);
}

- (void)gestureRecognized:(UIPanGestureRecognizer*)recognizer
{
    CGPoint point = [recognizer locationInView:self.view.superview];
    CGRect frame = self.view.frame;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            _startPoint = [recognizer locationInView:self.view];
            break;
        case UIGestureRecognizerStateChanged:
            self.view.frame = CGRectMake(point.x - _startPoint.x, 
                                         point.y - _startPoint.y, 
                                         frame.size.width, frame.size.height);
            break;
        case UIGestureRecognizerStateEnded:
            _startPoint = CGPointZero;
            break;
        default:
            break;
    }
}

- (void)updateFrameColor
{
    [self.frameView setBaseColor:_frameColor];
    [self.contentOverlayView setEdgeColor:_frameColor];
    [self.navigationController.navigationBar setTintColor:_frameColor];
}

@end

