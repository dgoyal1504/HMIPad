//
//  ReaderOverlayController.m
//  HmiPad
//
//  Created by Joan Lluch on 02/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.



#define thickness 44
//#define height 54


#import "ReaderOverlayView.h"


@interface ReaderOverlayView()<UIToolbarDelegate>
@end


@implementation ReaderOverlayView
{
    NSInteger _fpCounter;
}


//- (id)initWithText:(NSString*)text view:(UIView*)aView delegate:(id<ReaderOverlayDelegate>)obj

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame]; // CGRectMake(0, 0, 320, 480)];
    if ( !self )
        return nil;
    
//    _delegate = obj ;
//    _view = aView;
//    if ( self==nil || _view==nil ) return nil;

    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight] ;
    CGSize size = [self bounds].size ;
    //CGSize size = [_view bounds].size ;

    self.backgroundColor = [UIColor clearColor];
 

    UIButton *infoBtn = [UIButton buttonWithType: UIButtonTypeInfoLight] ;
    [infoBtn addTarget:self action:@selector(info) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithCustomView:infoBtn] ;    
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,size.width-100,thickness)] ;
    [_label setAutoresizingMask:UIViewAutoresizingFlexibleWidth] ;
    [_label setNumberOfLines:0] ;
    [_label setBackgroundColor:[UIColor clearColor]] ; // [UIColor colorWithWhite:0 alpha:0.5f]] ;
    [_label setTextColor:[UIColor whiteColor]] ;
    [_label setTextAlignment:NSTextAlignmentCenter] ;
    [_label setFont:[UIFont boldSystemFontOfSize:18]] ;
    UIBarButtonItem *labelItem = [[UIBarButtonItem alloc] initWithCustomView:_label] ;
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemStop target:self action:@selector(dismiss)];
    
    _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,size.width-100,thickness)] ;
    [_progressLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth] ;
    [_progressLabel setNumberOfLines:0] ;
    [_progressLabel setBackgroundColor:[UIColor clearColor]] ; // [UIColor colorWithWhite:0 alpha:0.5f]] ;
    [_progressLabel setTextColor:[UIColor whiteColor]] ;
    [_progressLabel setTextAlignment:NSTextAlignmentCenter] ;
    [_progressLabel setFont:[UIFont systemFontOfSize:15]] ;
    [_progressLabel setText:@""] ;

    UIBarButtonItem *progressLabelItem = [[UIBarButtonItem alloc] initWithCustomView:_progressLabel] ;
//    UIImage *flipCamImg = [UIImage imageNamed:@"barCamera.png"] ;
//    UIBarButtonItem *flipItem = [[UIBarButtonItem alloc] initWithImage:flipCamImg style:UIBarButtonItemStylePlain target:self action:@selector(flip)] ;
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    // toolbar de dalt
    
    _toolbar0 = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,size.width,thickness)];
    _toolbar0.delegate = self;
    [_toolbar0 setBarStyle:UIBarStyleBlackTranslucent] ;
    [_toolbar0 setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin] ;
    [_toolbar0 setItems:[NSArray arrayWithObjects: cancelItem, space, labelItem, space, infoItem, nil]] ;
    
    [self addSubview:_toolbar0] ;
    
    // tool bar d'abaix
    
    _toolbar1 = [[UIToolbar alloc] initWithFrame: CGRectMake(0, size.height-thickness, size.width, thickness)];
    [_toolbar1 setBarStyle:UIBarStyleBlackTranslucent];
    [_toolbar1 setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin] ;

//
//    NSArray *items = nil ;
//    if ( [_delegate respondsToSelector:@selector(shouldShowCameraPositionControl)] )
//    {
//        if ( [_delegate shouldShowCameraPositionControl] ) items = [NSArray arrayWithObjects:space, progressLabelItem, space, flipItem, nil] ;
//    }
//    
//    if ( items == nil )

    NSArray *items = [NSArray arrayWithObjects:space, progressLabelItem, space, nil] ;
    [_toolbar1 setItems:items];

    [self addSubview: _toolbar1];
    
    // guia
    CGFloat edgex = size.width/8;
    CGFloat edgey = size.height/4;
    _guide = [[UIView alloc] initWithFrame:CGRectMake(edgex, edgey, size.width-edgex*2, size.height-edgey*2) ] ;
    [_guide setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin];
    [_guide.layer setBorderColor:[UIColor whiteColor].CGColor];
    [_guide.layer setBorderWidth:2];
    [_guide.layer setCornerRadius:20];
    [self addSubview:_guide];

    return self;
}



- (void) dealloc
{
    if ( _getFpsTimer ) CFRunLoopTimerInvalidate( _getFpsTimer ) ;
}


- (void)setSupportText:(NSString *)supportText
{
    [_label setText:supportText];
}

- (NSString*)supportText
{
    return _label.text;
}

//- (void)setTopLayoutGuideLength:(CGFloat)topLayoutGuideLength
//{
//}


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if ( newSuperview == nil )
        return;
        
    NSArray *items = nil ;
    
    UIBarButtonItem *progressLabelItem = [[UIBarButtonItem alloc] initWithCustomView:_progressLabel] ;
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    if ( [_delegate respondsToSelector:@selector(shouldShowCameraPositionControl)] )
    {
        UIImage *flipCamImg = [UIImage imageNamed:@"barCamera.png"] ;
        UIBarButtonItem *flipItem = [[UIBarButtonItem alloc] initWithImage:flipCamImg style:UIBarButtonItemStylePlain target:self action:@selector(flip)] ;
        if ( [_delegate shouldShowCameraPositionControl] ) items = [NSArray arrayWithObjects:space, progressLabelItem, space, flipItem, nil] ;
    }
    
    if ( items == nil ) items = [NSArray arrayWithObjects:space, progressLabelItem, space, nil] ;
    
    [_toolbar1 setItems:items];
}



//- (void)setDelegate:(id<ReaderOverlayDelegate>)delegate
//{
//
//
//
//
//}


- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}


- (UILabel*)helpView
{
    if ( _helpView == nil )
    {
        CGSize size = [self bounds].size ;
        //CGSize size = [_view bounds].size ;
        _helpView = [[UILabel alloc] initWithFrame:CGRectMake( 0, thickness, size.width, size.height-thickness-thickness)] ;
        [_helpView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight] ;
        [_helpView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5f]] ;
        [_helpView setTextColor:[UIColor whiteColor]] ;
        [_helpView setTextAlignment:NSTextAlignmentCenter] ;
        [_helpView setFont:[UIFont systemFontOfSize:15]] ;
        [_helpView setNumberOfLines:0] ;
        [_helpView setAlpha:0] ;
        [_helpView setText:@
        "HINTS FOR SUCCESSFUL SCANNING\n"
        "\n"
        "Ensure there is plenty of light\n"
        "\n"
        "Let camera see full barcode\n"
        "\n"
        "Shake to force camera to focus\n"
        "\n"
        "Wait for autofocus to finish\n"
        "\n"
        "Hold still while the barcode is scanned\n"
        "\n"
        ] ;
    }
    return _helpView ;
}

//-----------------------------------------------------------------------------
- (UIView*)shutter
{
    if ( _shutter == nil )
    {
        CGSize size = [self bounds].size ;
        //CGSize size = [_view bounds].size ;
        _shutter = [[UIView alloc] initWithFrame:CGRectMake( 0, thickness, size.width, size.height-thickness-thickness)] ;
        [_shutter setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight] ;
        //[shutter setBackgroundColor:[UIColor darkGrayColor]] ;
        [_shutter setBackgroundColor:[UIColor blackColor]];
    }
    return _shutter ;
}


//-----------------------------------------------------------------------------
static void UpdateTimerCallback ( CFRunLoopTimerRef timer, void *info )
{
    ReaderOverlayView *self = (__bridge ReaderOverlayView *)info ;
    //CGFloat fps = [self->_delegate getFps] ;
    //NSString *fpsString = [[NSString alloc] initWithFormat:@"Scanning at %3.1f fps...", fps] ;
    
    NSString *fpsString = @"Scanning·";
    NSInteger dots = (self->_fpCounter++)%2;
    if ( dots == 1 ) fpsString = @"Scanning.";
    //if ( dots == 2 ) fpsString = @"Scanning..";
    
    [self->_progressLabel setText:fpsString] ;
}


//-----------------------------------------------------------------------------
-(void)setFpsTimerInterval:(CFTimeInterval)interval
{
	if ( interval == 0.0 )
    {
    	if ( _getFpsTimer ) CFRunLoopTimerInvalidate( _getFpsTimer ) ;
        _getFpsTimer = nil ;
    }
	else 
    {
        CFAbsoluteTime now = CFAbsoluteTimeGetCurrent() ;
    	if ( _getFpsTimer == nil )
    	{
        	CFRunLoopTimerContext tContext = { 0, (__bridge void *)(self), NULL, NULL, NULL } ;    
 
	        _getFpsTimer = CFRunLoopTimerCreate(
    	        NULL,                     	// CFAllocatorRef allocator,
        	    now+interval,               // CFAbsoluteTime
            	interval,                   // CFTimeInterval
            	0, 0,                     	// CFOptionFlags, CFIndex
            	UpdateTimerCallback,     	// CFRunLoopTimerCallBack
            	&tContext ) ;             	// CFRunLoopTimerContext
    
	        CFRunLoopAddTimer (
    	        CFRunLoopGetCurrent(),      //  CFRunLoopRef rl
        	    _getFpsTimer,              //  CFRunLoopTimerRef timer,
            	kCFRunLoopDefaultMode ) ;   //  CFStringRef mode
        
	        if ( _getFpsTimer ) CFRelease( _getFpsTimer ) ; // es retingut per el runLoop, per tant no cal retenirlo nosaltres
    	}
        if ( _getFpsTimer ) CFRunLoopTimerSetNextFireDate ( _getFpsTimer, now ) ;
    }
}



//-----------------------------------------------------------------------------
//- (void)setMode:(ReaderOverlayMode)mode withLabelText:(NSString*)labelText showProgress:(BOOL)show
- (void)setShowProgress:(BOOL)show orText:(NSString*)text ;
{
    //showProgress = show ;
    //[label setText:labelText] ;
    //[progressLabel setText:showProgress?@"Scanning...":@""] ;
 
    if ( show )
    {
        [self setFpsTimerInterval:0.5] ;
    }
    else 
    {
        [self setFpsTimerInterval:0.0] ;
        [_progressLabel setText:text] ;
    }
    
    //[toolbar setItems:[NSArray arrayWithObjects: cancelBtn, space, progressLabelItem, space, binfoBtn, nil]];
    //[toolbar0 setItems:[NSArray arrayWithObjects: space, labelItem, space, nil]] ;
}


//-----------------------------------------------------------------------------
- (void)setShutterOn:(BOOL)on animated:(BOOL)animated
{
    // off
    if ( _shutter && !on )
    {
        void (^begin)(void) = ^
        {
            [_shutter setAlpha:0.0f] ;
        };
        
        void (^end)(BOOL) = ^(BOOL finished)
        { 
            [_shutter removeFromSuperview] ;
            _shutter = nil ;
        };
    
        if ( animated ) [UIView animateWithDuration:0.3f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:begin completion:end];
        else begin(), end(YES) ;
    }
    
    // on
    else if ( !_shutter && on )
    {
        //[_view addSubview:[self shutter]] ;
        [self addSubview:[self shutter]] ;
        [_shutter setAlpha:0.0f] ;
        
        void (^begin)(void) = ^
        {
            [_shutter setAlpha:0.7f] ;
        };
        
        if ( animated) [UIView animateWithDuration:0.3f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:begin completion:nil];
        else begin() ;
    }
}



//-----------------------------------------------------------------------------
- (void)dismiss
{
//    [delegate performSelector: @selector(readerOverlayDidDismiss) withObject: nil afterDelay: 0.1];
    [_delegate readerOverlayDidDismiss] ;
}

//-----------------------------------------------------------------------------
- (void)flip
{
    if ( [_delegate respondsToSelector:@selector(readerOverlayFlip)] )
    {
        [_delegate readerOverlayFlip];
    }
}

//-----------------------------------------------------------------------------
- (void)info
{
    if ( _helpView )
    {
        [UIView animateWithDuration:0.3f 
        animations:^(void) 
        {
            [_helpView setAlpha:0.0f] ;
        } 
        completion:^(BOOL finished) 
        {
            [_helpView removeFromSuperview] ;
            _helpView = nil ;
        }] ;
    }
    else
    {
        [self addSubview:[self helpView]] ;
        //[_view addSubview:[self helpView]] ;
        [UIView animateWithDuration:0.3f 
        animations:^(void) 
        {
            [_helpView setAlpha:1.0f] ;
        }] ;
    }
}

@end
