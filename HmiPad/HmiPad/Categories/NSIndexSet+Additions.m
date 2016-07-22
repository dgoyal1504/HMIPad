//
//  NSIndexSet+Additions.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 5/16/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "NSIndexSet+Additions.h"

@implementation NSIndexSet (Additions)

- (NSIndexSet*)intersectionWithIndexSet:(NSIndexSet*)indexSet
{
    NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
    
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        if ([indexSet containsIndex:idx]) {
            [set addIndex:idx];
        }
    }];
    
    return [set copy];
}

- (NSIndexSet*)substractIndexSet:(NSIndexSet*)indexSet
{
    NSMutableIndexSet *set = [self mutableCopy];
    
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        if ([indexSet containsIndex:idx]) {
            [set removeIndex:idx];
        }
    }];
    
    return [set copy];
}

@end
