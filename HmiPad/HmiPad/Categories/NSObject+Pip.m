//
//  NSObject+Pip.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 5/16/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "NSObject+Pip.h"

@implementation NSObject (Pip)

- (void)pip
{
    NSLog(@" --- PIP --- : %@",self.description);
}

- (void)startPipWithTime:(NSTimeInterval)timeInterval
{
    [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(pip) userInfo:nil repeats:YES];
}

@end
