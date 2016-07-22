//
//  SWFloatingPopoverView.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/29/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWFloatingPopoverView.h"

#import <QuartzCore/QuartzCore.h>
#import "SWFloatingContentOverlayView.h"
#import "SWFloatingFrameView.h"
#import "SWClearNavigationBar.h"


#define kBarHeight         44

// El view principal del FloatingPopoverController que conte tots els altres
@implementation SWFloatingPopoverView
{
    BOOL _isCallingDelegate;
}

@synthesize contentView = _contentView;
@synthesize frameView = _frameView;
@synthesize contentOverlayView = _contentOverlayView;

@synthesize frameColor = _frameColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
                
        // Init Frame View (el view de sota)
        _frameView = [[SWFloatingFrameView alloc] init];
        _frameView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _frameView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        _frameView.contentMode = UIViewContentModeRedraw;
//		[_frameView.layer setShadowColor:[kShadowColor CGColor]];
//		[_frameView.layer setShadowOffset:kShadowOffset];
//		[_frameView.layer setShadowOpacity:kShadowOpacity];
//		[_frameView.layer setShadowRadius:kShadowRadius];
        
        
//        
        // Init Content View
        _contentView = [[UIView alloc] init];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _contentView.frame = CGRectMake(kFramePadding, kBorderOffset, frame.size.width - 2*kFramePadding, frame.size.height - 1*kFramePadding - kBorderOffset);
        _contentView.clipsToBounds = YES;
        
        
        // Init Content Overlay View (el view a sobre)
    //    CGRect contentFrame = _contentView.frame;
        
        
        _contentOverlayView = [[SWFloatingContentOverlayView alloc] init];
        _contentOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //_contentOverlayView.frame = CGRectMake(contentFrame.origin.x - kShadowBlur, contentFrame.origin.y - kShadowBlur,
        //                                       contentFrame.size.width  + kShadowBlur * 2, contentFrame.size.height + kShadowBlur * 2);
        _contentOverlayView.contentMode = UIViewContentModeRedraw;
		_contentOverlayView.userInteractionEnabled = NO;
                
        [self addSubview:_frameView];
        [self addSubview:_contentView];
        [self addSubview:_contentOverlayView];
    }
    return self;
}

//- (void)setFrame:(CGRect)frame
//{
//    NSLog( @"FloatingPopoverFrame: %@", NSStringFromCGRect(frame) );
//    [super setFrame:frame];
//}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UINavigationBar *dummyBar = [[UINavigationBar alloc] init];
    CGSize barSize = [dummyBar sizeThatFits:CGSizeMake(100,100)];
    CGFloat barHeight = barSize.height;
    
    CGRect contentFrame = _contentView.frame;

    CGRect newRect = CGRectMake(contentFrame.origin.x - kShadowBlur, contentFrame.origin.y + barHeight - kShadowBlur,
                             contentFrame.size.width  + kShadowBlur * 2, contentFrame.size.height - barHeight + kShadowBlur * 2);
    
    _contentOverlayView.frame = newRect;
    
    
        
//	CGFloat radius = [self.frameView cornerRadius];
//    
//    CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
//    theAnimation.duration = 0.25;
//    theAnimation.toValue = (id)[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:radius].CGPath;
//    [self.layer addAnimation:theAnimation forKey:@"shadowPath"];
}

//- (void)setFrameColor:(UIColor *)frameColor
//{
//    _frameColor = frameColor;
//    
//    [_frameView setBaseColor:frameColor];
//    [_contentOverlayView setEdgeColor:frameColor];
//}


- (void)setTintsColor:(UIColor*)frameColor
{
    [self setFrameColor:frameColor];
}


- (void)setFrameColor:(UIColor*)frameColor
{
    if ( _isCallingDelegate )
        return;
    
    _frameColor = frameColor;
    
    [_frameView setBaseColor:frameColor];
    [_contentOverlayView setEdgeColor:frameColor];
    
    _isCallingDelegate = YES;
    [_delegate floatingPopoverViewDidChangeTintsColor:self];
    _isCallingDelegate = NO;
}

//#pragma mark Touch Events
//
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
//    UIView *superview = self.superview;
//    [superview bringSubviewToFront:self];
//}

#pragma mark Public Methods

- (void)prepareFrameWithNavigationBar:(BOOL)withNavigationBar animated:(BOOL)animated
{

    // DO NOTHING !

//
//    CGRect contentFrame = _contentView.frame;
//    //CGFloat contentFrameWidth = [SWFloatingContentOverlayView frameWidth];
//    
//    
//    CGRect newRect;
//    
//    if (withNavigationBar || YES) // <------ DEBUG "YES"
//        newRect = CGRectMake(contentFrame.origin.x - kShadowBlur, contentFrame.origin.y + kBarHeight - kShadowBlur,
//                             contentFrame.size.width  + kShadowBlur * 2, contentFrame.size.height - kBarHeight + kShadowBlur * 2);
//    else
//        newRect = CGRectMake(contentFrame.origin.x - kShadowBlur, contentFrame.origin.y - kShadowBlur,
//                             contentFrame.size.width  + kShadowBlur * 2, contentFrame.size.height + kShadowBlur * 2);
//        
//    [UIView animateWithDuration:animated?0.25:0 animations:^
//    {
//        _contentOverlayView.frame = newRect; 
//    }
//    completion:^(BOOL finished)
//    {
//        
//    }];
}

@end

// ATENCIO NO ESBORRAR - MANTENIR PER FUTURA REFERENCIA

//@implementation UIView (firstResponder)
//
//- (BOOL)containsFirstResponder
//{
//    if ([self isFirstResponder])
//        return YES;
//    
//    for (UIView *subview in self.subviews) {
//        BOOL flag = [subview containsFirstResponder];
//        if (flag)
//            return YES;
//    }
//    
//    return NO;
//}
//
//- (UIView*)firstResponder
//{
//    if ([self isFirstResponder])
//        return self;
//    
//    for (UIView *subview in self.subviews) {
//        UIView *firstResponder = [subview firstResponder];
//        if (firstResponder != nil)
//            return firstResponder;
//    }
//    
//    return nil;
//}
//
//@end