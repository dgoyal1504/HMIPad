//
//  NSArray+Additions.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 5/23/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "NSArray+Additions.h"

@implementation NSArray (Additions)

- (NSArray*)reversedArray
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    for ( id object in self)
    {
        [array insertObject:object atIndex:0];
    }
    
    return [array copy];
}

@end