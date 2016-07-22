//
//  TKAlertCenter.m
//  Created by Devin Ross on 9/29/10.
//  Thoroughly modified and extended by Joan Lluch on 5/08/12
//
/*
 
 tapku.com || http://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "SWAlertCenter.h"
#import "SWKeyboardListener.h"
//#import "UIView+TKCategory.h"




@interface SWAlertView : UIView
{
    UIWindow *_window ;
	CGRect _messageRect;
    CGRect _thingyRect;
    NSString *_title;
	UIImage *_image;
    UIView *_view;
	NSString *_text;
    NSMutableArray *_alerts;
    BOOL _active;
    BOOL _permanent;
    BOOL _pendingHide;

}

//- (void)show ;
//- (void)hide ;
//- (id) init;
//- (void) setMessageText:(NSString*)str;
//- (void) setImage:(UIImage*)image;
//
//- (void)postAlertWithMessage:(NSString*)message image:(UIImage*)image ;

@end


@implementation SWAlertView


- (id)init
{
	if ( (self = [super initWithFrame:CGRectMake(0, 0, 100, 100)]) )
    {
        [self setBackgroundColor:[UIColor clearColor]];
        //_messageRect = CGRectInset(self.bounds, 10, 10);
        _alerts = [[NSMutableArray alloc] init];
        NSArray *windows = [[UIApplication sharedApplication] windows] ;
        if ( [windows count] > 0 ) _window = [windows objectAtIndex:0] ;
        else self = nil ;   // ARC
    }
	return self;	
}

- (void)drawRoundRectangleInRect:(CGRect)rect withRadius:(CGFloat)radius
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect rrect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height );

	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
	CGContextMoveToPoint(context, minx, midy);
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	CGContextClosePath(context);
	CGContextDrawPath(context, kCGPathFill);
}


- (void)drawRect:(CGRect)rect
{
    [[UIColor colorWithWhite:0 alpha:0.8] set];
    [self drawRoundRectangleInRect:rect withRadius:10];
    
    if ( _image ) 
        [_image drawInRect:_thingyRect];
    
//    [[UIColor whiteColor] set];
    
//    if ( _title )
//        [_title drawInRect:_thingyRect withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
//    
//    if ( _text )
//        [_text drawInRect:_messageRect withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    
    
    UIFont *font = [UIFont boldSystemFontOfSize:14];
    
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle alloc] init];
        textStyle.lineBreakMode = NSLineBreakByWordWrapping;
        textStyle.alignment = NSTextAlignmentCenter;
    
    UIColor *textColor = [UIColor whiteColor];
        
    NSDictionary *attrs = @{
        NSFontAttributeName:font,
        NSParagraphStyleAttributeName:textStyle,
        NSForegroundColorAttributeName:textColor
    };
    
    if ( _title )
        [_title drawInRect:_thingyRect withAttributes:attrs];
    
    if ( _text )
        [_text drawInRect:_messageRect withAttributes:attrs];
}


- (void)layout
{
    UIFont *font = [UIFont boldSystemFontOfSize:14];
//    if ( _text )
//        s = [_text sizeWithFont:font constrainedToSize:CGSizeMake(160,200) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGSize s = CGSizeZero ;
    if ( _text )
    {
        s = [_text boundingRectWithSize:CGSizeMake(160,200) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    
        s.height = ceil(s.height);
        s.width = ceil(s.width);
    }
    CGFloat thingyAdjustment = 0;
    CGSize s1 = CGSizeZero ;
    if (_title)
    {
        //s1 = [_title sizeWithFont:font];
        s1 = [_title sizeWithAttributes:@{NSFontAttributeName:font}], thingyAdjustment = 7;
        s1.height = ceil(s1.height);
        s1.width = ceil(s1.width);
    }
    else if (_image) s1 = _image.size, thingyAdjustment = 7;
    else if (_view) s1 = _view.bounds.size, thingyAdjustment = 7;

    CGRect theBounds = CGRectZero;
    theBounds.size.width = 2*round((40+MAX(s.width,s1.width))/2);
    theBounds.size.height = 2*round((15+s1.height+thingyAdjustment+s.height+15)/2);
    self.bounds = theBounds ;
    
    _thingyRect.origin.x = round((theBounds.size.width-s1.width)/2);
    _thingyRect.origin.y = 15;
    _thingyRect.size = s1;
	
    _messageRect.origin.x = round((theBounds.size.width-s.width)/2);
    _messageRect.origin.y = 15+s1.height+thingyAdjustment;
    _messageRect.size = s;
	//_messageRect.size.height += 5;
    
    for ( UIView *subView in self.subviews ) [subView removeFromSuperview];
    if ( _view )
    {
        [_view setFrame:_thingyRect];
        [self addSubview:_view];
    }
	
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

//- (void)setMessageText:(NSString*)str
//{
//	_text = str;
//	[self layout];
//}
//
//- (void)setImage:(UIImage*)img
//{
//	_image = img;
//	[self layout];
//}
//
//- (void)setTitle:(NSString*)str
//{
//	_title = str;
//	[self layout];
//}
//
//- (void)setView:(UIView*)view
//{
//	_view = view;
//	[self layout];
//}


static CGRect subtractRect(CGRect wf,CGRect kf)
{    
	if( ! CGPointEqualToPoint(CGPointZero,kf.origin) )
    {
		if( kf.origin.x > 0 ) kf.size.width = kf.origin.x;
		if( kf.origin.y > 0 ) kf.size.height = kf.origin.y;
		kf.origin = CGPointZero;
	}
    else
    {
		kf.origin.x = fabsf(kf.size.width - wf.size.width);
		kf.origin.y = fabsf(kf.size.height - wf.size.height);
    
		if ( kf.origin.x > 0 )
        {
			CGFloat temp = kf.origin.x;
			kf.origin.x = kf.size.width;
			kf.size.width = temp;
		}
        
        if ( kf.origin.y > 0 )
        {
			CGFloat temp = kf.origin.y;
			kf.origin.y = kf.size.height;
			kf.size.height = temp;
		}
	}
    return kf ;
}


- (void)adjustOrientationTo7:(UIInterfaceOrientation)o alpha:(CGFloat)alpha factor:(CGFloat)factor
{
    SWKeyboardListener *keyb = [SWKeyboardListener sharedInstance] ;
    CGRect kf = CGRectZero;
    if ( [keyb isVisible] ) kf = [keyb frame];
    CGRect wf = [_window bounds];  // atencio _window no pot ser nil
    
    wf = subtractRect(wf,kf); ;

    //CGFloat edge = 100 ;
    CGPoint center = CGPointMake(roundf(wf.origin.x+wf.size.width/2),roundf(wf.origin.y+wf.size.height/2)) ;
    CGFloat degrees ;
    
    if(o == UIInterfaceOrientationLandscapeLeft ) degrees = -90/*,center.x=wf.size.width-wf.origin.x-edge*/;
	else if(o == UIInterfaceOrientationLandscapeRight ) degrees = 90/*, center.x=wf.origin.x+edge*/;
	else if(o == UIInterfaceOrientationPortraitUpsideDown) degrees = 180/*, center.y=wf.origin.y+edge*/ ;
    else degrees = 0/*, center.y = wf.size.height-wf.origin.y-edge*/ ;
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    self.transform = CGAffineTransformScale(transform, factor, factor);
    
    self.center = center ;
    self.alpha = alpha ;
}


- (void)adjust8ToAlpha:(CGFloat)alpha factor:(CGFloat)factor
{
    SWKeyboardListener *keyb = [SWKeyboardListener sharedInstance] ;
    CGFloat kh = [keyb offset];
    CGRect wf = [_window bounds];  // atencio _window no pot ser nil
    
    CGPoint center = CGPointMake(roundf(wf.size.width/2),roundf((wf.size.height-kh)/2)) ;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    self.transform = CGAffineTransformScale(transform, factor, factor);
    
    self.center = center ;
    self.alpha = alpha ;
}


- (void)adjustOrientationTo:(UIInterfaceOrientation)o alpha:(CGFloat)alpha factor:(CGFloat)factor
{
    if ( IS_IOS8 )
        [self adjust8ToAlpha:alpha factor:factor];
    else
        [self adjustOrientationTo7:o alpha:alpha factor:factor];
}


- (void)show
{
    if ( [_alerts count] == 0 ) 
    {
		_active = NO;
		return;
	}

	_active = YES;
    [_window addSubview:self] ;
    
    NSArray *ar = [_alerts objectAtIndex:0];
    
    _text = [ar objectAtIndex:0];
    
    id thingy = nil;
	if ( [ar count] > 1 ) thingy = [ar objectAtIndex:1];
    
    if ( [thingy isKindOfClass:[NSString class]] ) _title = thingy;
    else if ( [thingy isKindOfClass:[UIImage class]] ) _image = thingy;
    else if ( [thingy isKindOfClass:[UIView class]] ) _view = thingy;
    [self layout];
    
    [_alerts removeObjectAtIndex:0];
    
    UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
    
    BOOL permanent = _permanent;
    
    [self adjustOrientationTo:o alpha:0.0f factor:(permanent?1.0f:1.5f)] ;
    
    [UIView animateWithDuration:0.15 
    animations:^
    {
        [self adjustOrientationTo:o alpha:1.0f factor:1.0f] ;
    }
    completion:^(BOOL finished) 
    {
        if ( permanent )
        {
            BOOL pending = _pendingHide;
            _pendingHide = YES;
            if ( pending ) [self hide];
        }
        else
        {
            double delay = fmin( fmax( ((double)[_text length]*60.0/200.0/4.5),1 ), 4 );   // al menys 1 segon, com a molt 4 segons
            [self performSelector:@selector(hide) withObject:nil afterDelay:delay] ;
        }
    }] ;
}

- (void)hide
{
    UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
    BOOL permanent = _permanent;
    _view = nil;
    _image = nil;
    _title = nil;
    _text = nil;
    _pendingHide = NO;
    _permanent = NO;

    [UIView animateWithDuration:0.15
    animations:^
    {
        [self adjustOrientationTo:o alpha:0 factor:(permanent?1.0f:0.5f)] ;
    } 
    completion:^(BOOL finished) 
    {
        for ( UIView *subView in self.subviews ) [subView removeFromSuperview];
        [self removeFromSuperview] ;
        [self show] ;
    }] ;
}


- (void)postAlertWithMessage:(NSString*)message thingy:(id)thingy
{

    // el missatge no pot ser nil, el thingy si.
    if ( message == nil ) return;
    [_alerts addObject:[NSArray arrayWithObjects:message,thingy,nil]];
	if ( !_active ) [self show];
}


- (void)cancelPendingAlerts
{
    [_alerts removeAllObjects];
    if ( _permanent ) 
    {
        BOOL pending = _pendingHide;
        _pendingHide = YES;
        if ( pending ) [self hide];
    }
}


- (void)groupPendingAlerts
{
    NSMutableString *msgGroup = nil;
    id thingy = nil;
    for ( NSArray *obj in _alerts )
    {
        NSString *msg = [obj objectAtIndex:0];
        if ( msgGroup == nil ) 
        {
            msgGroup = [NSMutableString stringWithString:msg];
            if ( [obj count]>1 ) thingy = [obj objectAtIndex:1];
        }
        else [msgGroup appendFormat:@"\n%@", msg];
    }
    
    if ( msgGroup )
        _alerts = [NSMutableArray arrayWithObject:[NSArray arrayWithObjects:msgGroup,thingy,nil]];
}


- (void)setPermanent:(BOOL)value
{
    _permanent = value;
}

//-------------------------------------------------------------------------------
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if ( newSuperview == nil )
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
        [nc removeObserver:self] ;
    }
    else if ( newSuperview != [self superview] )
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
        [nc addObserver:self selector:@selector(keyboardWillAppear:) name:SWKeyboardWillShowNotification object:nil];
        [nc addObserver:self selector:@selector(keyboardWillDisappear:) name:SWKeyboardWillHideNotification object:nil];
        [nc addObserver:self selector:@selector(orientationWillChange:) 
                    name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    }
} 


- (void)keyboardWillAppear:(NSNotification *)notification 
{
    UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
    [UIView animateWithDuration:0.3 animations:
    ^{
         [self adjustOrientationTo:o alpha:1 factor:1] ;
    }] ;
}


- (void)keyboardWillDisappear:(NSNotification *) notification 
{
    UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
    [UIView animateWithDuration:0.3 animations:
    ^{
        [self adjustOrientationTo:o alpha:1 factor:1] ;
    }] ;
    
}

- (void)orientationWillChange:(NSNotification *) notification 
{
	NSDictionary *userInfo = [notification userInfo];
	NSNumber *v = [userInfo objectForKey:UIApplicationStatusBarOrientationUserInfoKey];
	UIInterfaceOrientation o = [v intValue];
    CGFloat duration = 0.3 ;
	
	[UIView animateWithDuration:duration animations:
    ^{
        [self adjustOrientationTo:o alpha:1 factor:1] ;
    }] ;
}


@end




@interface SWAlertCenter() 
{
	SWAlertView *alertView;
}
@end


@implementation SWAlertCenter

+ (SWAlertCenter*) defaultCenter
{
    static SWAlertCenter *defaultCenter = nil;
	if ( defaultCenter == nil ) defaultCenter = [[self alloc] init];
	return defaultCenter;
}

- (id)init
{
	if( (self=[super init]) )
    {
        alertView = [[SWAlertView alloc] init];
    }
	return self;
}

- (void)postAlertWithMessage:(NSString*)message title:(NSString*)title
{
    [alertView postAlertWithMessage:message thingy:title] ;
}

- (void)postAlertWithMessage:(NSString*)message image:(UIImage*)image
{
    [alertView postAlertWithMessage:message thingy:image] ;
}

- (void)postAlertWithMessage:(NSString*)message view:(UIView*)view
{
    [alertView postAlertWithMessage:message thingy:view] ;
}

- (void)postAlertWithMessage:(NSString *)message
{
	[alertView postAlertWithMessage:message thingy:nil] ;
}

- (void)cancelPendingAlerts
{
    [alertView cancelPendingAlerts];
}

- (void)setPermanent:(BOOL)value
{
    [alertView setPermanent:value];
}

- (void)groupPendingAlerts
{
    [alertView groupPendingAlerts];
}


@end


