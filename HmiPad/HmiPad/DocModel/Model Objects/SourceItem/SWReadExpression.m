//
//  SWReadExpression.m
//  HmiPad
//
//  Created by Joan on 22/08/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWReadExpression.h"

@implementation SWReadExpression

@synthesize node = _node;

- (id)initWithQuickCoder:(QuickUnarchiver *)decoder
{
    self = [super initWithQuickCoder:decoder];
    if (self) 
    {
        _node = [decoder decodeObject];  
    }
    return self;
}

- (void)encodeWithQuickCoder:(QuickArchiver *)encoder
{
    [super encodeWithQuickCoder:encoder];
    [encoder encodeObject:_node];
}


@end
