//
//  SWAppDelegate.m
//  Encryption Test
//
//  Created by Hermes Pique on 6/13/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWAppDelegateX.h"

@implementation SWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
