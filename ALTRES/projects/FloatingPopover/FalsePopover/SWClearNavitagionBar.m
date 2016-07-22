//
//  CQMFloatingNavigationBar.m
//  FloatingPopover
//
//  Created by Joan Martín Hernàndez on 6/27/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWClearNavitagionBar.h"

@implementation SWClearNavitagionBar

- (id)init 
{
    self = [super init];
	if (self) {
        self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder 
{
    self = [super initWithCoder:aDecoder];
	if (self) {
        self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (void)drawRect:(CGRect)rect
{
    
}

@end
