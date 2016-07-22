//
//  SWMasterDetailViewController.m
//  HmiPad
//
//  Created by Joan Martin on 7/26/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

#import "SWMasterDetailViewController.h"
#import "SWColor.h"
#import "UIView+Scale.h"

#define kAnimationDuration 0.25
#define kEdgePanGestureMargin 30.0f
#define kQuickFlickVelocity 200.0f



#pragma mark - SWDirectionPanGestureRecognizer

typedef enum
{
    SWDirectionPanGestureRecognizerVertical,
    SWDirectionPanGestureRecognizerHorizontal

} SWDirectionPanGestureRecognizerDirection;

@interface SWSWDirectionPanGestureRecognizer : UIPanGestureRecognizer

@property (nonatomic, assign) SWDirectionPanGestureRecognizerDirection direction;

@end


@implementation SWSWDirectionPanGestureRecognizer
{
    BOOL _dragging;
    CGPoint _init;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
   
    UITouch *touch = [touches anyObject];
    _init = [touch locationInView:self.view];
    _dragging = NO;
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    if (self.state == UIGestureRecognizerStateFailed)
        return;
    
    if ( _dragging )
        return;
    
    const int kDirectionPanThreshold = 5;
    
    UITouch *touch = [touches anyObject];
    CGPoint nowPoint = [touch locationInView:self.view];
    
    CGFloat moveX = nowPoint.x - _init.x;
    CGFloat moveY = nowPoint.y - _init.y;
    
    if (abs(moveX) > kDirectionPanThreshold)
    {
        if (_direction == SWDirectionPanGestureRecognizerHorizontal)
            _dragging = YES;
        else
            self.state = UIGestureRecognizerStateFailed;
    }
    else if (abs(moveY) > kDirectionPanThreshold)
    {
        if (_direction == SWDirectionPanGestureRecognizerVertical)
            _dragging = YES ;
        else
            self.state = UIGestureRecognizerStateFailed;
    }
}

@end


#pragma mark - SWContentInsetCenteredScrollView

@interface SWContentInsetCenteredScrollView : UIScrollView
{
    CGFloat _leftOffset;
    CGFloat _rightOffset;
}
@property (nonatomic) CGFloat leftOffset;
@property (nonatomic) CGFloat rightOffset;
@property (nonatomic) UIView *interiorView;
- (void)updateContentSizeAnimated:(BOOL)animated;
- (void)setZoomScale:(CGFloat)scale animated:(BOOL)animated completion:(void(^)(BOOL finished))block;
//- (void)setLeftOffset:(CGFloat)leftOffset animated:(BOOL)animated;

@end


@implementation SWContentInsetCenteredScrollView



//- (void)_updateInsetsWithContentSizeV:(CGSize)contentSize animated:(BOOL)animated
//{
//    CGSize boundsSize = self.bounds.size;
//    
//    CGFloat hOffset = 0, vOffset = 0;
//    
//    if (contentSize.width < boundsSize.width-_leftOffset)
//        hOffset = ((boundsSize.width-_leftOffset)-contentSize.width) * 0.5f;
//    
//    if (contentSize.height < boundsSize.height)
//        vOffset = (boundsSize.height-contentSize.height) * 0.5f;
//    
//    void (^block)() = ^()
//    {
//        self.contentSize = contentSize;
//        self.contentInset = UIEdgeInsetsMake(vOffset, _leftOffset+hOffset, vOffset, hOffset);
//        [_interiorView setCenter:CGPointMake(contentSize.width/2, contentSize.height/2)];
//    };
//    
//    if ( animated ) [UIView animateWithDuration:kAnimationDuration animations:block];
//    else block();
//}


- (void)_updateInsetsWithContentSize:(CGSize)contentSize animated:(BOOL)animated
{
    CGSize boundsSize = self.bounds.size;
    
    CGFloat hOffset = 0, vOffset = 0 ;
    CGFloat rhOffset = _rightOffset;
    
    if (contentSize.width < boundsSize.width-_leftOffset)
    {
        if (contentSize.width < boundsSize.width-_leftOffset-_rightOffset)
        {
            hOffset = ((boundsSize.width-_leftOffset-_rightOffset)-contentSize.width) * 0.5f;
            rhOffset = _rightOffset;
        }
        else
        {
            hOffset = ((boundsSize.width-_leftOffset)-contentSize.width) * 0.5f;
        }
    }
    
    if (contentSize.height < boundsSize.height)
    {
        vOffset = (boundsSize.height-contentSize.height) * 0.5f;
    }
    
    void (^block)() = ^()
    {
        self.contentSize = contentSize;
        self.contentInset = UIEdgeInsetsMake(vOffset, _leftOffset+hOffset, vOffset, rhOffset+hOffset);
        [_interiorView setCenter:CGPointMake(contentSize.width/2, contentSize.height/2)];
    };
    
    if ( animated ) [UIView animateWithDuration:kAnimationDuration animations:block];
    else block();
}



- (void)setInteriorViewV:(UIView *)interiorView
{
    [_interiorView removeFromSuperview];
    _interiorView = interiorView;
    
//    interiorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
//        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
//        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    interiorView.autoresizingMask = UIViewAutoresizingNone;
    
    [self setContentSize:interiorView.frame.size];  // << agafem frame perque ens interessa la mida ja escalada
   // [self addSubview:interiorView];
}



- (void)setInteriorView:(UIView *)interiorView
{
    _interiorView = interiorView;
    interiorView.autoresizingMask = UIViewAutoresizingNone;
    
    [self setContentSize:interiorView.frame.size];  // << agafem frame perque ens interessa la mida ja escalada
}


- (void)updateContentSizeAnimated:(BOOL)animated
{
    CGFloat scale = self.zoomScale;
    CGSize boundsSize = _interiorView.bounds.size;  // << agafem bounds perque ens interessa la mida no escalada
    
    CGSize contentSize = CGSizeMake(boundsSize.width*scale, boundsSize.height*scale);
    [self _updateInsetsWithContentSize:contentSize animated:animated];
}


- (void)setZoomScale:(CGFloat)scale animated:(BOOL)animated completion:(void(^)(BOOL finished))block
{
    NSTimeInterval duration = 0;
    if ( animated ) duration = kAnimationDuration;

    [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState
    animations:^
    {
        [self setZoomScale:scale];
        [self updateContentSizeAnimated:NO];
    }
    completion:block];

}

//- (void)setFrame:(CGRect)frame
//{
//    [super setFrame:frame];
//}

@end


#pragma mark - SWMasterDetailViewController

@interface SWMasterDetailViewController()<UIGestureRecognizerDelegate,UIScrollViewDelegate>

@end

@implementation SWMasterDetailViewController
{
    BOOL _performingAnimation;
    
//    UISwipeGestureRecognizer *_rightSwipeGestureRecognizer;
//    UISwipeGestureRecognizer *_leftSwipeGestureRecognizer;
    UIPanGestureRecognizer *_rightPanGestureRecognizer;
    UIPanGestureRecognizer *_leftPanGestureRecognizer;
    SWRightViewPosition _panInitialRightViewPosition;
    SWLeftViewPosition _panInitialLeftViewPosition;
    //SWRightViewPosition _rightViewPosition;
    //SWLeftViewPosition _leftViewPosition;
    
    SWContentInsetCenteredScrollView *_scrollView;
    
    UIView *_masterContentView;
//    SWMasterContentView *_masterContentView;
    UIView *_rightDetailContentView;
    UIView *_leftDetailContentView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _rightDetailWidth = 320.0;
        _leftDetailWidth = 320.0;
    }
    return self;

}

- (id)initWithViewControllers:(NSArray*)array
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        if (array.count > 0)
            _masterViewController = [array objectAtIndex:0];
        
        if (array.count > 1)
            _rightDetailViewController = [array objectAtIndex:1];
        
        if (array.count > 2)
            _leftDetailViewController = [array objectAtIndex:2];
    }
    return self;
}




- (void)viewDidLoadV
{
    [super viewDidLoad];
    
    UIView *view = self.view;
    CGRect bounds = view.bounds;
    
    // Creating the masterView and adding it as a subview
    
    _masterContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
    
    _masterContentView.backgroundColor = [UIColor clearColor];
    
    _scrollView = [[SWContentInsetCenteredScrollView alloc] initWithFrame:bounds];
    _scrollView.delaysContentTouches = NO;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.delegate = self;
    
    [_scrollView setInteriorView:_masterContentView];
    [view addSubview:_scrollView];   // [0] view
    
    if ( _masterViewController )
    {
        UIViewController<SWZoomableViewController> *newController = _masterViewController;
        _masterViewController = nil;
        [self setMasterViewController:newController animated:NO];
    }
    
    // Creating the leftView and adding it as a subview
    
    _leftDetailContentView = [[UIView alloc] initWithFrame:[self _frameForLeftViewPosition:_leftViewPosition]];
    [_leftDetailContentView addGestureRecognizer:self.leftPanGestureRecognizer];
        //[_leftDetailContentView setBackgroundColor:[UIColor yellowColor]];
        
    _leftDetailContentView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight;
    [view addSubview:_leftDetailContentView];  // [1] view
    
    if ( _leftDetailViewController )
    {
        UIViewController *newController = _leftDetailViewController;
        _leftDetailViewController = nil;
        [self setLeftDetailViewController:newController];
    }
    
    // Creating the rightView and adding it as a subview
    
    _rightDetailContentView = [[UIView alloc] initWithFrame:[self _frameForRightViewPosition:_rightViewPosition]];
    [_rightDetailContentView addGestureRecognizer:self.rightPanGestureRecognizer];
    
    _rightDetailContentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleHeight;
    [view addSubview:_rightDetailContentView]; // [2] view
    
    if ( _rightDetailViewController )
    {
        UIViewController *newController = _rightDetailViewController;
        _rightDetailViewController = nil;
        [self setRightDetailViewController:newController];
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *view = self.view;
    CGRect bounds = view.bounds;
    
    // Creating the masterView and adding it as a subview
    

    
    //_masterContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
    //_masterContentView.backgroundColor = [UIColor clearColor];
    
    _scrollView = [[SWContentInsetCenteredScrollView alloc] initWithFrame:bounds];
    _scrollView.delaysContentTouches = NO;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.delegate = self;
    
    
    if ( _masterViewController )
    {
        UIViewController<SWZoomableViewController> *newController = _masterViewController;
        _masterViewController = nil;
        [self setMasterViewController:newController animated:NO];
    }

    [view addSubview:_scrollView];   // [0] view
    

    
    // Creating the leftView and adding it as a subview
    
    _leftDetailContentView = [[UIView alloc] initWithFrame:[self _frameForLeftViewPosition:_leftViewPosition]];
    [_leftDetailContentView addGestureRecognizer:self.leftPanGestureRecognizer];
        //[_leftDetailContentView setBackgroundColor:[UIColor yellowColor]];
        
    _leftDetailContentView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight;
    [view addSubview:_leftDetailContentView];  // [1] view
    
    if ( _leftDetailViewController )
    {
        UIViewController *newController = _leftDetailViewController;
        _leftDetailViewController = nil;
        [self setLeftDetailViewController:newController];
    }
    
    // Creating the rightView and adding it as a subview
    
    _rightDetailContentView = [[UIView alloc] initWithFrame:[self _frameForRightViewPosition:_rightViewPosition]];
    [_rightDetailContentView addGestureRecognizer:self.rightPanGestureRecognizer];
    
    _rightDetailContentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleHeight;
    [view addSubview:_rightDetailContentView]; // [2] view
    
    if ( _rightDetailViewController )
    {
        UIViewController *newController = _rightDetailViewController;
        _rightDetailViewController = nil;
        [self setRightDetailViewController:newController];
    }
}




// Adds an arbitrary view on top of the left and master views
- (void)setControllerOverlayView:(UIView *)controllerOverlayView
{
    [_controllerOverlayView removeFromSuperview];
    _controllerOverlayView = controllerOverlayView;
    
    [self.view insertSubview:_controllerOverlayView belowSubview:_rightDetailContentView];
}


//-(void)changeScaleforLayer:(CALayer *)aLayer scale:(CGFloat)scale
//{
//    aLayer.contentsScale = scale;
//    aLayer.rasterizationScale = scale;
//    //if ( aLayer.contents == nil )
//        [aLayer setNeedsDisplay];
//
//    [aLayer setNeedsLayout];
//    
//    for ( CALayer *layer in aLayer.sublayers )
//    {
//        [self changeScaleforLayer:layer scale:scale];
//    }
//}



- (void)viewDidUnload
{
    [super viewDidUnload];
}






#pragma mark View life cycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   // [self changeScaleforLayer:_masterContentView.layer scale:2.0];
}




- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


//- (void)viewWillLayoutSubviews
//{
////    [self _setScrollViewInsetsAnimated:NO];
////    [self _changeScaleforView:_masterContentView scale:_scrollView.contentScaleFactor];
//}
//
//- (void)viewDidLayoutSubviews
//{
//
//    [self _setScrollViewInsetsAnimated:NO];
//}


//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//	return YES;
//}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{

}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self _scrollViewSetDefaultScalingAnimated:NO completion:nil];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self _updateMasterScale];
}




#pragma mark UIScrollView delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if ( scrollView == _scrollView )
        return _masterContentView;
    
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    [_masterViewController willBeginZooming];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [_scrollView updateContentSizeAnimated:NO];
}


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [_masterViewController didEndZooming];
    [self _scrollViewSetScalingToMagnetAnimated:YES completion:^(BOOL finished)
    {
        [self _updateMasterScale];
        //[_masterViewController didEndZooming];
    }];
}


#pragma mark Scaling

//- (void)setScalingEnabled:(BOOL)scalingEnabled
//{
//    _scalingEnabled = scalingEnabled;
//    [self _scrollViewSetDefaultScalingAnimated:NO completion:nil];
//}


- (void)setScalingEnabled:(BOOL)scalingEnabled
{
    [self setScalingEnabled:scalingEnabled animated:NO];
}

- (void)setScalingEnabled:(BOOL)enable animated:(BOOL)animated
{
    _scalingEnabled = enable;
    [self _scrollViewEnableZooming:enable animated:animated];
}

//- (void)setMasterSizeV:(CGSize)size animated:(BOOL)animated
//{
//    void (^block)() = ^()
//    {
//        [_masterContentView setBounds:CGRectMake(0, 0, size.width, size.height)];
//        [self _scrollViewUpdateContentSizeAnimated:NO];
//    };
//    
//    if ( animated ) [UIView animateWithDuration:kAnimationDuration animations:block];
//    else block();
//}


- (void)setMasterSize:(CGSize)size animated:(BOOL)animated
{
    CGSize oldSize = _masterContentView.bounds.size;
//    if ( CGSizeEqualToSize( size, oldSize) )
//        return;

    BOOL doIt = ( !CGSizeEqualToSize( size, oldSize) || !_scalingEnabled ) ;
    NSTimeInterval duration = ((animated && doIt) ? kAnimationDuration : 0);

    [_masterViewController willBeginZooming];
    [UIView animateWithDuration:duration animations:^
    {
        if ( doIt )
        {
            [_masterContentView setBounds:CGRectMake(0, 0, size.width, size.height)];
            [self _scrollViewSetDefaultScalingAnimated:NO completion:nil];
        }
    }
    completion:^(BOOL finished)
    {
        [_masterViewController didEndZooming];
        [self _updateMasterScale];
    }];
}

#pragma mark Scaling (private)


- (void)_scrollViewEnableZooming:(BOOL)enabled animated:(BOOL)animated
{
    [self _scrollViewSetDefaultScalingAnimated:animated completion:^(BOOL finished)
    {
        [self _updateMasterScale];
    }];
}

- (void)_scrollViewUpdateContentSizeAnimated:(BOOL)animated
{
    [self _scrollViewSetWidthOffsets];
    [_scrollView updateContentSizeAnimated:animated];
}


//- (void)_scrollViewSetWidthOffsetsV
//{
//    CGFloat leftWidth = 0;
//    CGFloat rightWidth = 0;
//    
//    if ( _leftViewPosition == SWLeftViewPositionShown )
//        leftWidth = _leftDetailWidth;
//    
//    if ( _rightViewPosition == SWRightViewPositionShown )
//        rightWidth = _rightDetailWidth;
//
//    [_scrollView setLeftOffset:leftWidth];
//    [_scrollView setRightOffset:rightWidth];
//}


//- (CGFloat)_getDefaultScalingV
//{
//    CGFloat leftWidth = 0, margin = 0;
//    if ( _leftViewPosition == SWLeftViewPositionShown )
//    {
//        leftWidth = _leftDetailWidth;
//        margin = 20;
//    }
//    
//    CGFloat leftMargin = leftWidth+margin;
//    CGFloat rightMargin = margin;
//    CGSize size = _scrollView.bounds.size;
//    CGFloat scale = (size.width-leftMargin-rightMargin)/size.width;
//
//    return scale;
//}


//- (void)_scrollViewSetWidthOffsetsV
//{
//    CGFloat leftWidth = 0, rightWidth = 0;
//    CGFloat leftMargin = 0, rightMargin = 0;
//    
//    if ( _leftViewPosition == SWLeftViewPositionShown )
//        leftWidth = _leftDetailWidth;
//    
//    if ( _rightViewPosition == SWRightViewPositionShown )
//        rightWidth = _rightDetailWidth;
//    
//    CGSize boundsSize = _scrollView.bounds.size;
//    CGSize contentSize = _masterContentView.bounds.size;
//    
//    if (contentSize.width > boundsSize.width-leftWidth-rightWidth)
//    {
//        // no hi cap a tot
//        leftMargin = leftWidth;
//        rightMargin = 0;
//    }
//    else // hi cap a tot
//    {
//        leftMargin = leftWidth;
//        rightMargin = rightWidth;
//    }
//    
//    [_scrollView setLeftOffset:leftMargin];
//    [_scrollView setRightOffset:rightMargin];
//}


- (void)_scrollViewSetWidthOffsets
{
    CGFloat leftMargin = 0, rightMargin = 0;
    
    if ( _leftViewPosition == SWLeftViewPositionShown )
        leftMargin = _leftDetailWidth;
    
    if ( _rightViewPosition == SWRightViewPositionShown )
        rightMargin = _rightDetailWidth;
    
    CGSize boundsSize = _scrollView.bounds.size;
    CGSize contentSize = _masterContentView.bounds.size;
    
    if (contentSize.width > boundsSize.width-leftMargin-rightMargin)
    {
        // no hi cap a tot
        rightMargin = 0;
    }
    
    [_scrollView setLeftOffset:leftMargin];
    [_scrollView setRightOffset:rightMargin];
}


- (void)_scrollViewSetZoomScale:(CGFloat)scale animated:(BOOL)animated completion:(void(^)(BOOL finished))block
{
    void (^completion)(BOOL) = ^(BOOL finished)
    {
        if ( block ) block(finished);
        if ( animated) [_masterViewController didEndZooming];
    };
    
    if ( animated) [_masterViewController willBeginZooming];
    [_scrollView setZoomScale:scale animated:animated completion:completion];
}


- (CGFloat)_getDefaultScaling
{
    CGFloat kMargin = 0;
    CGFloat leftWidth = 0;
    CGFloat leftMargin = 0, rightMargin = 0;
    
    if ( _leftViewPosition == SWLeftViewPositionShown )
    {
        leftWidth = _leftDetailWidth;
        kMargin = 16;
    }
    
    CGSize boundsSize = _scrollView.bounds.size;
    CGSize contentSize = _masterContentView.bounds.size;
    
    if (contentSize.width > boundsSize.width-leftWidth)  // <- no hi cap a amb el leftWidth
    {
        leftMargin = leftWidth + kMargin;
        rightMargin = kMargin;
    }
    
    CGFloat scale = (boundsSize.width-leftMargin-rightMargin)/boundsSize.width;
    return scale;
}

- (CGFloat)_getScalingThatFitsWidth
{
    CGFloat leftWidth = 0;
    CGFloat leftMargin = 0, rightMargin = 0;
    
    if ( _leftViewPosition == SWLeftViewPositionShown )
    {
        leftWidth = _leftDetailWidth;
    }
    
    CGSize boundsSize = _scrollView.bounds.size;
    CGSize contentSize = _masterContentView.bounds.size;
    
    leftMargin = leftWidth;
    
//    CGFloat scale;
//    if (contentSize.width == 0 ) scale = -1;  // far enough
//    else scale = (boundsSize.width-leftMargin-rightMargin)/contentSize.width;

    CGFloat scale = (boundsSize.width-leftMargin-rightMargin)/contentSize.width;
    return scale;  // atencio pot ser NaN o Inf
}


- (CGFloat)_getScalingThatFitsHeight
{
    CGSize boundsSize = _scrollView.bounds.size;
    CGSize contentSize = _masterContentView.bounds.size;

    CGFloat scale = boundsSize.height/contentSize.height;
    return scale;  // atencio pot ser NaN o Inf
}


- (void)_scrollViewSetDefaultScalingAnimated:(BOOL)animated completion:(void(^)(BOOL finished))block
{
    CGFloat defaultScaling = [self _getDefaultScaling];
    _scrollView.minimumZoomScale = (_scalingEnabled ? 0.3 : defaultScaling);
    _scrollView.maximumZoomScale = (_scalingEnabled ? 2.0 : defaultScaling);
    
    [self _scrollViewSetWidthOffsets];
    [self _scrollViewSetZoomScale:defaultScaling animated:animated completion:block];
}


- (void)_scrollViewSetScalingToMagnetAnimated:(BOOL)animated completion:(void(^)(BOOL finished))block
{
    CGFloat currentScaling = _scrollView.zoomScale;
    CGFloat defaultScaling = [self _getDefaultScaling];
    CGFloat fitsWidthScaling = [self _getScalingThatFitsWidth];
    CGFloat fitsHeightScaling = [self _getScalingThatFitsHeight];
    CGFloat targetScale = 1;
    
    if ( fabsf(currentScaling-1) < 0.1 )
        targetScale = 1;
    
    else if ( fabsf(currentScaling-2) < 0.1 )
        targetScale = 2;
    
    else if ( fabsf(currentScaling-defaultScaling) < 0.1 )
        targetScale = defaultScaling;
    
    else if ( fabsf(currentScaling-fitsWidthScaling) < 0.1 )
        targetScale = fitsWidthScaling;
    
    else if ( fabsf(currentScaling-fitsHeightScaling) < 0.1 )
        targetScale = fitsHeightScaling;
    
    else
        targetScale = currentScaling;
    
    [self _scrollViewSetZoomScale:targetScale animated:animated completion:block];
}


- (void)_updateMasterScale
{
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    CGFloat scale = _scrollView.zoomScale;
    
    CGFloat contentScale = screenScale*scale;
    if ( screenScale == 1 && scale < 1 ) contentScale = screenScale;
    // ^-- Per no retina sembla que es millor conservar la escala original per zooms petits
    
    [_masterViewController setViewContentScaleFactor:contentScale];
}


- (void)_setPagingMode:(BOOL)pagingMode
{
    if ( _pagingMode == pagingMode )
        return;
    
    _pagingMode = pagingMode;
    
    [self _scrollViewSetDefaultScalingAnimated:YES completion:^(BOOL finished)
    {
        [self _updateMasterScale];
    }];
}



#pragma mark Properties

- (void)setMasterViewControllerV:(UIViewController<SWZoomableViewController> *)masterViewController animated:(BOOL)animated
{
    UIViewController *oldController = _masterViewController;
    _masterViewController = masterViewController;
    
    if ( !self.isViewLoaded )
        return;
    
    [self _prepareMainViewSubframe];
    
    void (^completion)() =
        [self _transitionFromViewController:oldController toViewController:_masterViewController inView:_masterContentView];
    
    if ( animated )
    {
        _masterContentView.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^
        {
            _masterContentView.alpha = 1.0;
        }
        completion:^(BOOL finished)
        {
            completion();
        }];
    }
    else
    {
        completion();
    }
    
    [self _scrollViewSetDefaultScalingAnimated:animated completion:^(BOOL finished)
    {
        [self _updateMasterScale];
    }];
}


- (void)setMasterViewController:(UIViewController<SWZoomableViewController> *)masterViewController animated:(BOOL)animated
{
    UIViewController *oldController = _masterViewController;
    _masterViewController = masterViewController;
    
    if ( !self.isViewLoaded )
        return;
    
    [self _prepareMainViewSubframe];
    _masterContentView = masterViewController.view;
    [_scrollView setInteriorView:_masterContentView];
    
    void (^completion)() =
        [self _transitionFromViewController:oldController toViewController:_masterViewController inView:_scrollView];
    
    
    if ( animated )
    {
        _masterContentView.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^
        {
            _masterContentView.alpha = 1.0;
        }
        completion:^(BOOL finished)
        {
            completion();
        }];
    }
    else
    {
        completion();
    }
    
    [self _scrollViewSetDefaultScalingAnimated:animated completion:^(BOOL finished)
    {
        [self _updateMasterScale];
    }];
}


- (void)setRightDetailViewController:(UIViewController *)rightDetailViewController
{
    UIViewController *oldController = _rightDetailViewController;
    _rightDetailViewController = rightDetailViewController;
    
    if ( !self.isViewLoaded )
        return;
    
    UIView *deployView = nil;
    if ( _rightViewPosition == SWRightViewPositionShown ) deployView = _rightDetailContentView;
    
    [self _prepareRightViewSubframeForPosition:_rightViewPosition];
    [self _transitionFromViewController:oldController toViewController:_rightDetailViewController inView:deployView]();
}


- (void)setLeftDetailViewController:(UIViewController *)leftDetailViewController
{
    UIViewController *oldController = _leftDetailViewController;
    _leftDetailViewController = leftDetailViewController;
    
    if ( !self.isViewLoaded )
        return;
    
    UIView *deployView = nil;
    if ( _leftViewPosition == SWLeftViewPositionShown ) deployView = _leftDetailContentView;
    
    [self _prepareLeftViewSubframeForPosition:_leftViewPosition];
    [self _transitionFromViewController:oldController toViewController:_leftDetailViewController inView:deployView]();
}


- (UIPanGestureRecognizer*)rightPanGestureRecognizer
{
    if ( _rightPanGestureRecognizer == nil )
    {
        SWSWDirectionPanGestureRecognizer *customRecognizer =
            [[SWSWDirectionPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handleRightRevealGesture:)];
        
        customRecognizer.direction = SWDirectionPanGestureRecognizerHorizontal;
        customRecognizer.delegate = self;
        _rightPanGestureRecognizer = customRecognizer;
    }
    return _rightPanGestureRecognizer;
}


- (UIPanGestureRecognizer*)leftPanGestureRecognizer
{
    if ( _leftPanGestureRecognizer == nil )
    {
        SWSWDirectionPanGestureRecognizer *customRecognizer =
            [[SWSWDirectionPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLeftRevealGesture:)];
        
        customRecognizer.direction = SWDirectionPanGestureRecognizerHorizontal;
        customRecognizer.delegate = self;
        _leftPanGestureRecognizer = customRecognizer;
//        _leftPanGestureRecognizer.cancelsTouchesInView = NO;
//        _leftPanGestureRecognizer.delaysTouchesBegan = YES;
    }
    return _leftPanGestureRecognizer;
}


#pragma mark Public Methods

//- (void)replaceMasterViewControllerByControllerV:(UIViewController<SWZoomableViewController>*)controller
//    withAnimation:(SWMasterViewControllerPresentationAnimation)animation
//{
//    [self _performTransitionToViewController:controller animation:animation completion:^(BOOL finished)
//    {
//        [self _updateMasterScale];
//    }];
//}


- (void)replaceMasterViewControllerByController:(UIViewController<SWZoomableViewController>*)controller
    withAnimation:(SWMasterViewControllerPresentationAnimation)animation
{
    [self _performTransitionToMasterViewController:controller animation:animation completion:^(BOOL finished)
    {
        [self _updateMasterScale];
    }];
}

- (void)toggleRightDetailViewControllerAnimated:(BOOL)animated
{
    // ignorem les peticions si hi ha una animacio en proces
    if ( _performingAnimation )
        return;
    
    NSTimeInterval duration = animated?kAnimationDuration:0;
    SWRightViewPosition position = SWRightViewPositionShown;
    if ( _rightViewPosition==SWRightViewPositionShown) position = SWRightViewPositionHidden;
    [self _setRightDetailViewControllerPosition:position withDuration:duration];
}


- (void)toggleLeftDetailViewControllerAnimated:(BOOL)animated
{
    // ignorem les peticions si hi ha una animacio en proces
    if ( _performingAnimation )
        return;

    NSTimeInterval duration = animated?kAnimationDuration:0;
    SWLeftViewPosition position = SWLeftViewPositionShown;
    if ( _leftViewPosition==SWLeftViewPositionShown) position = SWLeftViewPositionHidden;
    
    [self _setLeftDetailViewControllerPosition:position withDuration:duration];
}


- (void)_setRightDetailViewControllerPosition:(SWRightViewPosition)position withDuration:(NSTimeInterval)duration
{
    _performingAnimation = YES;
    
    void (^completionBlock)(void) = [self _rightViewDeploymentForNewRightViewPosition:position];
    
    //NSLog( @"initial frame :%@", NSStringFromCGRect(_rightDetailContentView.frame));
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseOut
    animations:^
    {
        _rightDetailContentView.frame = [self _frameForRightViewPosition:position];
        
        //NSLog( @"final frame :%@", NSStringFromCGRect(_rightDetailContentView.frame));
        [self _prepareRightViewSubframeForPosition:position];
    }
    completion:^(BOOL finished)
    {
        _performingAnimation = NO;
        completionBlock();
    }];
    
    [self _scrollViewUpdateContentSizeAnimated:YES];
}


- (void)_setLeftDetailViewControllerPosition:(SWLeftViewPosition)position withDuration:(NSTimeInterval)duration
{
    _performingAnimation = YES;
    
    void (^completionBlock)(void) = [self _leftViewDeploymentForNewLeftViewPosition:position];
    
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseOut
    animations:^
    {
        _leftDetailContentView.frame = [self _frameForLeftViewPosition:position];
        [self _prepareLeftViewSubframeForPosition:position];
    }
    completion:^(BOOL finished)
    {
        _performingAnimation = NO;
        completionBlock();
    }];
    
    [self _setPagingMode:(position==SWLeftViewPositionShown)];
}




#pragma mark Private Methods

- (void)_prepareRightViewSubframeForPosition:(SWRightViewPosition)position
{
    CGRect subFrame = _rightDetailContentView.bounds;
    if ( position == SWRightViewPositionHidden )
        subFrame.origin.x = kEdgePanGestureMargin;
    
    UIView *view = _rightDetailViewController.view;
    [view setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    view.frame = subFrame;
}

- (void)_prepareLeftViewSubframeForPosition:(SWLeftViewPosition)position
{
    CGRect subFrame = _leftDetailContentView.bounds;
    if ( position == SWLeftViewPositionHidden )
        subFrame.origin.x = -kEdgePanGestureMargin;
    
    UIView *view = _leftDetailViewController.view;
    [view setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    view.frame = subFrame;
}

- (void)_prepareMainViewSubframeV
{
    CGRect subFrame = _masterContentView.bounds;
    UIView *view = _masterViewController.view;
//    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
//        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
//        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.frame = subFrame;
}

- (void)_prepareMainViewSubframe
{
//    CGRect subFrame = _scrollView.bounds;
//    UIView *view = _masterViewController.view;
//    
//    //view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    view.frame = subFrame;
}

- (CGRect)_frameForRightViewPosition:(SWRightViewPosition)position
{
    CGRect frame = self.view.bounds;
    CGRect rect = CGRectMake(0, 0, _rightDetailWidth, frame.size.height);
    rect.origin.x = position==SWRightViewPositionShown ? frame.size.width - _rightDetailWidth : frame.size.width-kEdgePanGestureMargin;
    return rect;
}

- (CGRect)_frameForLeftViewPosition:(SWLeftViewPosition)position
{
    CGRect frame = self.view.bounds;
    CGRect rect = CGRectMake(0, 0, _leftDetailWidth, frame.size.height);
    rect.origin.x = position==SWLeftViewPositionShown ? 0 : -_leftDetailWidth+kEdgePanGestureMargin;
    return rect;
}


// NO UTILITZAT, PERO DEIXAR PER FUTURA REFERENCIA
- (void)_setScaledFrameWithOriginalFrame:(CGRect)frame forView:(UIView*)view
{
    //CALayer *layer = view.layer;
    if ( _pagingMode )
    {
        CGRect rect;
        
//        // 3/4 del original i centrat en el frame original
//        rect.size.width = frame.size.width*3/4;
//        rect.size.height = frame.size.height*3/4;
//        rect.origin.x = frame.origin.x + (frame.size.width-rect.size.width)/2;
//        rect.origin.y = 40+frame.origin.y + (frame.size.height-rect.size.height)/2;
//        
        
        
        const CGFloat leftMargin = _leftDetailWidth+20;
        const CGFloat rightMargin = 20;
        
        rect.size.width = frame.size.width-leftMargin-rightMargin;
        CGFloat scale = rect.size.width/frame.size.width;
        rect.size.height = roundf(frame.size.height*scale);
        
        rect.origin.y = frame.origin.y + (frame.size.height-rect.size.height)/2;
        rect.origin.x = frame.origin.x + leftMargin;
        
//        
//        CGPathRef oldShadowPath = layer.shadowPath;
//        if (oldShadowPath) CFRetain(oldShadowPath);

    //
    
//        CALayer *layer = view.layer;
//        UIBezierPath *path = [UIBezierPath bezierPathWithRect:view.bounds];
//        layer.shadowPath = path.CGPath;
//        layer.shadowOffset = CGSizeMake(0, 1);
//        layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5].CGColor;
//        layer.shadowRadius = 5 ;
//        layer.shadowOpacity = 1;
    //
    
//        if (oldShadowPath)
//        {
//            CABasicAnimation *transition = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
//            transition.fromValue = (__bridge id)oldShadowPath;
//            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//            transition.duration = 2.5;
//    
//            [layer addAnimation: transition forKey:nil];
//            
//            CFRelease(oldShadowPath);
//        }
        [view setScaledFrame:rect];
        
        _addShadowToView( _masterViewController.view );
    }
    else
    {
        [view setScaledFrame:frame];
    }
}



- (CGRect)_frameForMasterViewWithAnimation:(SWMasterViewControllerPresentationAnimation)animation exiting:(BOOL)exiting
{
    CGRect bounds = _masterContentView.bounds;
    CGRect frame = bounds;
    
    if ( animation == SWMasterViewControllerPresentationAnimationFade ||
        animation == SWMasterViewControllerPresentationAnimationNone )
            return frame;
    
    CGFloat offset = 40;
    
    CGFloat widthOffset = bounds.size.width + offset;
    CGFloat heightOffset = bounds.size.height + offset;
    
    if (exiting)
    {
        widthOffset *= -1;
        heightOffset *= -1;
    }
    
    if (animation == SWMasterViewControllerPresentationAnimationLeft)
    {
        frame.origin = CGPointMake(widthOffset, 0);
    }
    else if (animation == SWMasterViewControllerPresentationAnimationRight)
    {
        frame.origin = CGPointMake(-widthOffset, 0);
    }
    else if (animation == SWMasterViewControllerPresentationAnimationUp)
    {
        frame.origin = CGPointMake(0, heightOffset);
    }
    else if (animation == SWMasterViewControllerPresentationAnimationDown)
    {
        frame.origin = CGPointMake(0, -heightOffset);
    }

    return frame;
}


- (CGRect)_initialFrameForMasterViewWithAnimation:(SWMasterViewControllerPresentationAnimation)animation exiting:(BOOL)exiting
{
    if ( exiting ) return _masterContentView.bounds;
    return [self _frameForMasterViewWithAnimation:animation exiting:exiting];
}


- (CGRect)_finalFrameForMasterViewWithAnimation:(SWMasterViewControllerPresentationAnimation)animation exiting:(BOOL)exiting
{
    if ( !exiting ) return _masterContentView.bounds;
    return [self _frameForMasterViewWithAnimation:animation exiting:exiting];
}


- (CGFloat)_initialAlphaForMasterViewWithAnimation:(SWMasterViewControllerPresentationAnimation)animation exiting:(BOOL)exiting
{
    if ( exiting ) return 1.0f;
    if ( animation == SWMasterViewControllerPresentationAnimationFade ) return 0.0f;
    return 0.5f;
}


- (CGFloat)_finalAlphaForMasterViewWithAnimation:(SWMasterViewControllerPresentationAnimation)animation exiting:(BOOL)exiting
{
    if ( !exiting ) return 1.0f;
    if ( animation == SWMasterViewControllerPresentationAnimationFade ) return 0.0f;
    return 0.5f;
}


static void _addShadowToView(UIView *view)
{
//    CALayer *layer = view.layer;
//    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
//    layer.shadowPath = shadowPath.CGPath;
//    layer.shadowOffset = CGSizeMake(0, 1);
//    layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5].CGColor;
//    layer.shadowRadius = 5 ;
//    layer.shadowOpacity = 1;
}

static void _removeShadowFromView(UIView *view)
{
    CALayer *layer = view.layer;
    layer.shadowPath = nil;
}



- (void)_performTransitionToViewControllerV:(UIViewController<SWZoomableViewController>*)inController
    animation:(SWMasterViewControllerPresentationAnimation)animation completion:(void (^)(BOOL finished))completion
{
    UIViewController *outController = _masterViewController;
    _masterViewController = inController;
    
    [self _prepareMainViewSubframe];
    
    void (^transitionCompletion)(void) =
        [self _transitionFromViewController:outController toViewController:inController inView:_masterContentView];
    
    UIView *inControllerView = inController.view;
    UIView *outControllerView = outController.view;
    
    void (^completionBlock)(BOOL) = ^(BOOL finished)
    {
        //_masterContentView.layer.shadowOpacity = 1;
        transitionCompletion();
        if (completion) completion(YES);
    };
    
    NSTimeInterval duration = kAnimationDuration*2.0;
    
    // no animation
    if (animation == SWMasterViewControllerPresentationAnimationNone)
    {
        CGRect inFinalFrame = [self _finalFrameForMasterViewWithAnimation:animation exiting:NO];
        inControllerView.frame = inFinalFrame;
        completionBlock(YES);
    }
    
    // animateWithDuration based animations
    else if ( animation == SWMasterViewControllerPresentationAnimationLeft ||
        animation == SWMasterViewControllerPresentationAnimationRight ||
        animation == SWMasterViewControllerPresentationAnimationUp ||
        animation == SWMasterViewControllerPresentationAnimationDown)
    {
    
        CGRect inInitialFrame = [self _initialFrameForMasterViewWithAnimation:animation exiting:NO];
        CGRect inFinalFrame = [self _finalFrameForMasterViewWithAnimation:animation exiting:NO];
        
        CGRect outInitialFrame = [self _initialFrameForMasterViewWithAnimation:animation exiting:YES];
        CGRect outFinalFrame = [self _finalFrameForMasterViewWithAnimation:animation exiting:YES];
        
        inControllerView.frame = inInitialFrame;
        outControllerView.frame = outInitialFrame;
        
        inControllerView.alpha = 0.0f;
        outControllerView.alpha = 1.0f;
        
        void (^animationsBlock)(void) = ^
        {
            inControllerView.frame = inFinalFrame;
            outControllerView.frame = outFinalFrame;
            
            inControllerView.alpha = 1.0f;
            outControllerView.alpha = 0.0f;
            
            _addShadowToView(inControllerView);
        };
        
        [UIView animateWithDuration:duration animations:animationsBlock completion:completionBlock];
    }

    // transitionFromView based animations
    else
    {
        UIViewAnimationOptions animationOptions = UIViewAnimationOptionTransitionNone;
        
        switch ( animation )
        {
            case SWMasterViewControllerPresentationAnimationFade:
                animationOptions = UIViewAnimationOptionTransitionCrossDissolve;
                break;
                
            default: break;
        }

        if ( animation == SWMasterViewControllerPresentationAnimationFade )
            animationOptions = UIViewAnimationOptionTransitionCrossDissolve;
        
        else if ( animation == SWMasterViewControllerPresentationAnimationCurlUp )
            animationOptions = UIViewAnimationOptionTransitionCurlUp;
        
        else if ( animation == SWMasterViewControllerPresentationAnimationCurlDown )
            animationOptions = UIViewAnimationOptionTransitionCurlDown;
        
        else if ( animation == SWMasterViewControllerPresentationAnimationFlipFromLeft )
            animationOptions = UIViewAnimationOptionTransitionFlipFromLeft;
        
        else if ( animation == SWMasterViewControllerPresentationAnimationFlipFromRight )
            animationOptions = UIViewAnimationOptionTransitionFlipFromRight;
    
        animationOptions |= UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionAllowAnimatedContent;
    
        [UIView transitionFromView:outControllerView toView:inControllerView duration:duration
            options:animationOptions completion:completionBlock];
    }
}

- (void)_performTransitionToMasterViewController:(UIViewController<SWZoomableViewController>*)inController
    animation:(SWMasterViewControllerPresentationAnimation)animation completion:(void (^)(BOOL finished))completion
{
    UIViewController *outController = _masterViewController;
    _masterViewController = inController;
    
    [self _prepareMainViewSubframe];
    _masterContentView = inController.view;
    [_scrollView setInteriorView:_masterContentView];
    
    void (^transitionCompletion)(void) =
        [self _transitionFromViewController:outController toViewController:inController inView:_scrollView];
    
    UIView *inControllerView = inController.view;
    UIView *outControllerView = outController.view;
    
    void (^completionBlock)(BOOL) = ^(BOOL finished)
    {
        //_masterContentView.layer.shadowOpacity = 1;
        transitionCompletion();
        if (completion) completion(YES);
    };
    
    NSTimeInterval duration = kAnimationDuration*2.0;
    
    // no animation
    if (animation == SWMasterViewControllerPresentationAnimationNone)
    {
        CGRect inFinalFrame = [self _finalFrameForMasterViewWithAnimation:animation exiting:NO];
        inControllerView.frame = inFinalFrame;
        completionBlock(YES);
    }
    
    // animateWithDuration based animations
    else if ( animation == SWMasterViewControllerPresentationAnimationLeft ||
        animation == SWMasterViewControllerPresentationAnimationRight ||
        animation == SWMasterViewControllerPresentationAnimationUp ||
        animation == SWMasterViewControllerPresentationAnimationDown)
    {
    
        CGRect inInitialFrame = [self _initialFrameForMasterViewWithAnimation:animation exiting:NO];
        CGRect inFinalFrame = [self _finalFrameForMasterViewWithAnimation:animation exiting:NO];
        
        CGRect outInitialFrame = [self _initialFrameForMasterViewWithAnimation:animation exiting:YES];
        CGRect outFinalFrame = [self _finalFrameForMasterViewWithAnimation:animation exiting:YES];
        
        inControllerView.frame = inInitialFrame;
        outControllerView.frame = outInitialFrame;
        
        inControllerView.alpha = 0.0f;
        outControllerView.alpha = 1.0f;
        
        void (^animationsBlock)(void) = ^
        {
            inControllerView.frame = inFinalFrame;
            outControllerView.frame = outFinalFrame;
            
            inControllerView.alpha = 1.0f;
            outControllerView.alpha = 0.0f;
            
            _addShadowToView(inControllerView);
        };
        
        [UIView animateWithDuration:duration animations:animationsBlock completion:completionBlock];
    }

    // transitionFromView based animations
    else
    {
        UIViewAnimationOptions animationOptions = UIViewAnimationOptionTransitionNone;
        
        switch ( animation )
        {
            case SWMasterViewControllerPresentationAnimationFade:
                animationOptions = UIViewAnimationOptionTransitionCrossDissolve;
                break;
                
            default: break;
        }

        if ( animation == SWMasterViewControllerPresentationAnimationFade )
            animationOptions = UIViewAnimationOptionTransitionCrossDissolve;
        
        else if ( animation == SWMasterViewControllerPresentationAnimationCurlUp )
            animationOptions = UIViewAnimationOptionTransitionCurlUp;
        
        else if ( animation == SWMasterViewControllerPresentationAnimationCurlDown )
            animationOptions = UIViewAnimationOptionTransitionCurlDown;
        
        else if ( animation == SWMasterViewControllerPresentationAnimationFlipFromLeft )
            animationOptions = UIViewAnimationOptionTransitionFlipFromLeft;
        
        else if ( animation == SWMasterViewControllerPresentationAnimationFlipFromRight )
            animationOptions = UIViewAnimationOptionTransitionFlipFromRight;
    
        animationOptions |= UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionAllowAnimatedContent;
    
        [UIView transitionFromView:outControllerView toView:inControllerView duration:duration
            options:animationOptions completion:completionBlock];
    }
}



















//- (void)_gestureRecognized:(UISwipeGestureRecognizer*)recognizer
//{
//    if (recognizer.state == UIGestureRecognizerStateEnded)
//    {
//        if (recognizer == _rightSwipeGestureRecognizer)
//        {
//            if (_rightDetailViewControllerVisible && _leftDetailViewControllerVisible)
//            {
//                // Impossible
//            }
//            else if (!_rightDetailViewControllerVisible && !_leftDetailViewControllerVisible)
//            {
//                if (recognizer == _leftSwipeGestureRecognizer)
//                {
//                    if (_getDetailViewController)
//                        [self presentLeftDetailViewController:_getDetailViewController(SWDetailViewControllerPresentationStyleLeft) animated:YES];
//                }
//                else if (recognizer == _rightSwipeGestureRecognizer)
//                {
//                    if (_getDetailViewController)
//                        [self presentRightDetailViewController:_getDetailViewController(SWDetailViewControllerPresentationStyleRight) animated:YES];
//                }
//            }
//            else if (_rightDetailViewControllerVisible && !_leftDetailViewControllerVisible)
//            {
//                if (recognizer == _leftSwipeGestureRecognizer)
//                {
//                    // Nothing to do
//                }
//                else if (recognizer == _rightSwipeGestureRecognizer)
//                {
//                    [self dismissRightDetailViewControllerAnimated:YES];
//                }
//            }
//            else if (!_rightDetailViewControllerVisible && _leftDetailViewControllerVisible)
//            {
//                if (recognizer == _leftSwipeGestureRecognizer)
//                {
//                    [self dismissLeftDetailViewControllerAnimated:YES];
//                }
//                else if (recognizer == _rightSwipeGestureRecognizer)
//                {
//                    // Nothing to do
//                }
//            }
//        }
//        
//        if (_rightDetailViewControllerVisible)
//        {
//            [self dismissRightDetailViewControllerAnimated:YES];
//        }
//        else
//        {
//            [self presentRightDetailViewControllerAnimated:YES];
//        }
//    }
//}


#pragma mark Position based view controller deployment

// Deploy/Undeploy of the right view controller following the containment principles. Returns a block
// that must be invoked on animation completion in order to finish deployment
- (void (^)(void))_rightViewDeploymentForNewRightViewPosition:(SWRightViewPosition)newPosition
{
    BOOL appear = _rightViewPosition == SWRightViewPositionHidden && newPosition == SWRightViewPositionShown;
    BOOL disappear = newPosition == SWRightViewPositionHidden && _rightViewPosition == SWRightViewPositionShown;
    
    _rightViewPosition = newPosition;
    if ( appear ) [self _prepareRightViewSubframeForPosition:SWRightViewPositionHidden];
    
    return [self _deploymentForController:_rightDetailViewController inView:_rightDetailContentView appear:appear disappear:disappear];
}


// Deploy/Undeploy of the left view controller following the containment principles. Returns a block
// that must be invoked on animation completion in order to finish deployment
- (void (^)(void))_leftViewDeploymentForNewLeftViewPosition:(SWLeftViewPosition)newPosition
{
    BOOL appear = _leftViewPosition == SWLeftViewPositionHidden && newPosition == SWLeftViewPositionShown;
    BOOL disappear = newPosition == SWLeftViewPositionHidden && _leftViewPosition == SWLeftViewPositionShown;
    
    _leftViewPosition = newPosition;
    if ( appear ) [self _prepareLeftViewSubframeForPosition:SWLeftViewPositionHidden];
    
    return [self _deploymentForController:_leftDetailViewController inView:_leftDetailContentView appear:appear disappear:disappear];
}


- (void (^)(void))_deploymentForController:(UIViewController*)controller inView:(UIView*)view appear:(BOOL)appear disappear:(BOOL)disappear
{
    if ( appear ) return [self _deployViewController:controller inView:view];
    if ( disappear ) return [self _undeployViewController:controller];
    return ^{};
}




#pragma mark Containment view controller deployment and transition

// Containment Deploy method. Returns a block to be invoked at the
// animation completion, or right after return in case of non-animated deployment.
- (void (^)(void))_deployViewController:(UIViewController*)viewController inView:(UIView*)view
{
    if ( !viewController || !view )
        return ^(void){};
    
    UIView *controllerView = viewController.view;
//    //controllerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    controllerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
//    
//    CGRect frame = view.bounds;
////    frame.origin.x += 20;
////    frame.size.width -= 20;
//    controllerView.frame = frame;
    
    [view addSubview:controllerView];
    
    void (^completionBlock)(void) = ^(void)
    {
        // nothing to do on completion at this stage
    };
    
    return completionBlock;
}

// Containment Undeploy method. Returns a block to be invoked at the
// animation completion, or right after return in case of non-animated deployment.
- (void (^)(void))_undeployViewController:(UIViewController*)viewController
{
    if (!viewController)
        return ^(void){};

    // nothing to do before completion at this stage
    
    void (^completionBlock)(void) = ^(void)
    {
        [viewController.view removeFromSuperview];
    };
    
    return completionBlock;
}

// Containment Transition method. Returns a block to be invoked at the
// animation completion, or right after return in case of non-animated transition.
- (void(^)(void))_transitionFromViewController:(UIViewController*)fromController toViewController:(UIViewController*)toController inView:(UIView*)view
{
    if ( fromController == toController )
        return ^(void){};
    
    if ( toController ) [self addChildViewController:toController];
    void (^deployCompletion)() = [self _deployViewController:toController inView:view];
    
    [fromController willMoveToParentViewController:nil];
    void (^undeployCompletion)() = [self _undeployViewController:fromController];
    
    void (^completionBlock)(void) = ^(void)
    {
        undeployCompletion() ;
        [fromController removeFromParentViewController];
        
        deployCompletion() ;
        [toController didMoveToParentViewController:self];
    };
    return completionBlock;
}


#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ( _performingAnimation )
        return NO;
    
    return YES;
}

#pragma mark - Gesture Based Reveal

- (void)_handleRightRevealGesture:(UIPanGestureRecognizer *)recognizer
{
    switch ( recognizer.state )
    {
        case UIGestureRecognizerStateBegan:
            [self _handleRightRevealGestureStateBeganWithRecognizer:recognizer];
            break;
            
        case UIGestureRecognizerStateChanged:
            [self _handleRightRevealGestureStateChangedWithRecognizer:recognizer];
            break;
            
        case UIGestureRecognizerStateEnded:
            [self _handleRightRevealGestureStateEndedWithRecognizer:recognizer];
            break;
            
        case UIGestureRecognizerStateCancelled:
        //case UIGestureRecognizerStateFailed:
            [self _handleRightRevealGestureStateCancelledWithRecognizer:recognizer];
            break;
            
        default:
            break;
    }
}


- (void)_handleLeftRevealGesture:(UIPanGestureRecognizer *)recognizer
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



- (void)_handleRightRevealGestureStateBeganWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    // we store the initial position and initialize a target position
    _panInitialRightViewPosition = _rightViewPosition;
}


- (void)_handleRightRevealGestureStateChangedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGFloat translation = [recognizer translationInView:_rightDetailContentView].x;

    CGRect vRect = [self _frameForRightViewPosition:SWRightViewPositionShown];
    CGRect baseLocation = [self _frameForRightViewPosition:_panInitialRightViewPosition];
    
    CGFloat xPosition = baseLocation.origin.x + translation;
    
    CGRect frame = baseLocation;
    frame.origin.x = xPosition;
    
    if ( xPosition < vRect.origin.x )
        frame.origin.x = vRect.origin.x;
    
    else if ( xPosition > vRect.origin.x+_rightDetailWidth)
        frame.origin.x = vRect.origin.x+_rightDetailWidth;
    
    else
    {
        //[self _prepareRightViewSubframeForPosition:SWRightViewPositionShown];
        void (^completion)() = [self _rightViewDeploymentForNewRightViewPosition:SWRightViewPositionShown];
        [UIView animateWithDuration:0.2 animations:^
        {
            [self _prepareRightViewSubframeForPosition:SWRightViewPositionShown];
        }];
        completion();
    }
    
    _rightDetailContentView.frame = frame;
}



- (void)_handleRightRevealGestureStateEndedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    //UIView *frontView = _contentView.frontView;
    CGRect vRect = [self _frameForRightViewPosition:SWRightViewPositionShown];
    
    //CGFloat baseLocation = _panInitialGestureRect.origin.x;
    CGFloat xPosition = _rightDetailContentView.frame.origin.x;
    CGFloat velocity = [recognizer velocityInView:_rightDetailContentView].x;
    //NSLog( @"Velocity:%1.4f", velocity);
    
    // initially we assume drag to left and default duration
    SWRightViewPosition position = SWRightViewPositionShown;
    NSTimeInterval duration = kAnimationDuration;

    // Velocity driven change:
    if (fabsf(velocity) > kQuickFlickVelocity)
    {
        // we may need to set the drag position and to adjust the animation duration
        CGFloat journey = xPosition-vRect.origin.x;
        if (velocity > 0.0f)
        {
            position = SWRightViewPositionHidden;
            journey = _rightDetailWidth - journey;
        }
        
        duration = fabsf(journey/velocity);
    }
    
    // Position driven change:
    else
    {
        // we may need to set the drag position        
        //if (xPosition-baseLocation > _rightDetailWidth*0.5f)
        if (xPosition-vRect.origin.x > _rightDetailWidth*0.5f)
        {
            position = SWRightViewPositionHidden;
        }
    }
    
    [self _setRightDetailViewControllerPosition:position withDuration:duration];
}


- (void)_handleRightRevealGestureStateCancelledWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
}






- (void)_handleLeftRevealGestureStateBeganWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    // we store the initial position and initialize a target position
    _panInitialLeftViewPosition = _leftViewPosition;
}


- (void)_handleLeftRevealGestureStateChangedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGFloat translation = [recognizer translationInView:_leftDetailContentView].x;

    CGRect vRect = [self _frameForLeftViewPosition:SWLeftViewPositionShown];
    CGRect baseLocation = [self _frameForLeftViewPosition:_panInitialLeftViewPosition];
    
    CGFloat xPosition = baseLocation.origin.x + translation;
    
    CGRect frame = baseLocation;
    frame.origin.x = xPosition;
    
    if ( xPosition < vRect.origin.x-_leftDetailWidth )
        frame.origin.x = vRect.origin.x-_leftDetailWidth;
    
    else if ( xPosition > vRect.origin.x)
        frame.origin.x = vRect.origin.x;
    
    else
    {
        //[self _prepareRightViewSubframeForPosition:SWRightViewPositionShown];
        void (^completion)() = [self _leftViewDeploymentForNewLeftViewPosition:SWLeftViewPositionShown];
        [UIView animateWithDuration:0.2 animations:^
        {
            [self _prepareLeftViewSubframeForPosition:SWLeftViewPositionShown];
        }];
        completion();
    }
    
    _leftDetailContentView.frame = frame;
}



- (void)_handleLeftRevealGestureStateEndedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    //UIView *frontView = _contentView.frontView;
    CGRect vRect = [self _frameForLeftViewPosition:SWLeftViewPositionShown];
    
    //CGFloat baseLocation = _panInitialGestureRect.origin.x;
    CGFloat xPosition = _leftDetailContentView.frame.origin.x;
    CGFloat velocity = [recognizer velocityInView:_leftDetailContentView].x;
    //NSLog( @"Velocity:%1.4f", velocity);
    
    // initially we assume drag to left and default duration
    SWLeftViewPosition position = SWLeftViewPositionShown;
    NSTimeInterval duration = kAnimationDuration;

    // Velocity driven change:
    if (fabsf(velocity) > kQuickFlickVelocity)
    {
        // we may need to set the drag position and to adjust the animation duration
        CGFloat journey = vRect.origin.x-xPosition;
        if (velocity < 0.0f)
        {
            position = SWLeftViewPositionHidden;
            journey = _leftDetailWidth - journey;
        }
        
        duration = fabsf(journey/velocity);
    }
    else
    {
        // we may need to set the drag position        
        //if (xPosition-baseLocation > _rightDetailWidth*0.5f)
        if (xPosition-vRect.origin.x < -_leftDetailWidth*0.5f)
        {
            position = SWLeftViewPositionHidden;
        }
    }

    [self _setLeftDetailViewControllerPosition:position withDuration:duration];
}


- (void)_handleLeftRevealGestureStateCancelledWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
}















@end




#pragma mark - UIViewController(SWMasterDetailViewController) Category

@implementation UIViewController(SWMasterDetailViewController)

- (SWMasterDetailViewController*)masterDetailViewController
{
    UIViewController *parent = self;
    Class masterDetailClass = [SWMasterDetailViewController class];
    
    while ( nil != (parent = [parent parentViewController]) && ![parent isKindOfClass:masterDetailClass] )
    {
    }
    
    return (id)parent;
}

@end













