//
//  SWKeyboardListener.m
//  ScadaMobile
//
//  Created by Joan on 13/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <objc/runtime.h>

#import "SWKeyboardListener.h"

NSString * const SWKeyboardWillShowNotification = @"SWKeyboardWillShowNotification";
NSString * const SWKeyboardWillHideNotification = @"SWKeyboardWillHideNotification";

NSString * const SWKeyboardDidShowNotification = @"SWKeyboardDidShowNotification";
NSString * const SWKeyboardDidHideNotification = @"SWKeyboardDidHideNotification";

NSString * const SWKeyboardWillChangeFrameNotification = @"SWKeyboardWillChangeFrameNotification";
NSString * const SWKeyboardDidChangeFrameNotification = @"SWKeyboardDidChangeFrameNotification";

@implementation SWKeyboardListener

//static SWKeyboardListener *sharedInstance;

+ (SWKeyboardListener *)sharedInstance
{
    static SWKeyboardListener *sharedInstance = nil;
    if ( sharedInstance == nil ) sharedInstance = [[self alloc] init];
    return sharedInstance;
}

+ (void)load
{
    @autoreleasepool
    {
        [self sharedInstance] ;
    }
}

- (BOOL)isVisible
{
    return isVisible;
}

- (CGRect)frame
{
    return frame ;
}

- (CGFloat)offset7
{
    if ( !isVisible )
        return 0;

    UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(o) ) return frame.size.height ;
    return frame.size.width ;
}

- (CGFloat)gap7
{
    UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    if (UIInterfaceOrientationIsPortrait(o) ) return appFrame.size.height - frame.size.height ;
    return appFrame.size.width - frame.size.width ;
}

- (CGFloat)offset
{
    if ( !isVisible )
        return 0;
    
    UIView *rootView = [self _rootView];
    CGRect convertedFrame = [rootView convertRect:frame fromView:nil];
    return convertedFrame.size.height;
}

- (CGFloat)gap
{
    UIView *rootView = [self _rootView];
    CGRect convertedFrame = [rootView convertRect:frame fromView:nil];
    return rootView.bounds.size.height - convertedFrame.size.height;
}


- (UIView*)_rootView
{
    UIWindow *rootWindow = nil;
    UIView *rootView = nil;
    NSArray *windows = [[UIApplication sharedApplication] windows] ;
    if ( [windows count] > 0 )
    {
        rootWindow = [windows objectAtIndex:0] ;
    }
    rootView = [rootWindow.rootViewController view];

    return rootView;
}


- (void)willShow:(NSNotification *)note 
{
    NSDictionary *userInfo = [note userInfo];
	NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	frame = [aValue CGRectValue];
    isVisible = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:SWKeyboardWillShowNotification object:self userInfo:userInfo] ;
}


- (void)willHide:(NSNotification *)note
{
    NSDictionary *userInfo = [note userInfo];
	NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	frame = [aValue CGRectValue];
//    frame = CGRectZero ;
    isVisible = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:SWKeyboardWillHideNotification object:self userInfo:userInfo] ;
}

- (void)didShow:(NSNotification*)note
{
    NSDictionary *userInfo = [note userInfo];
	NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	frame = [aValue CGRectValue];
    isVisible = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:SWKeyboardDidShowNotification object:self userInfo:userInfo] ;
}

- (void)didHide:(NSNotification *)note
{
    NSDictionary *userInfo = [note userInfo];
	NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	frame = [aValue CGRectValue];
//    frame = CGRectZero ;
    isVisible = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:SWKeyboardDidHideNotification object:self userInfo:userInfo] ;
}

- (void)willChangeFrame:(NSNotification *)note
{
    NSDictionary *userInfo = [note userInfo];
	NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	frame = [aValue CGRectValue];
    [[NSNotificationCenter defaultCenter] postNotificationName:SWKeyboardWillChangeFrameNotification object:self userInfo:userInfo] ;
}

- (void)didChangeFrame:(NSNotification *)note
{
    NSDictionary *userInfo = [note userInfo];
	NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	frame = [aValue CGRectValue];
    [[NSNotificationCenter defaultCenter] postNotificationName:SWKeyboardDidChangeFrameNotification object:self userInfo:userInfo] ;
}


- (id)init
{
    if ((self = [super init])) 
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(willShow:) name:UIKeyboardWillShowNotification object:nil];
        [nc addObserver:self selector:@selector(willHide:) name:UIKeyboardWillHideNotification object:nil];
        [nc addObserver:self selector:@selector(didShow:) name:UIKeyboardDidShowNotification object:nil];
        [nc addObserver:self selector:@selector(didHide:) name:UIKeyboardDidHideNotification object:nil];
        [nc addObserver:self selector:@selector(willChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [nc addObserver:self selector:@selector(didChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
    }
    return self;
}

- (void)postKeyboardNotification
{
    if ( isVisible )
    {
        [self willShow:nil];
        [self didShow:nil];
    }
    else
    {
        [self willHide:nil];
        [self didHide:nil];
    }
}

@end













