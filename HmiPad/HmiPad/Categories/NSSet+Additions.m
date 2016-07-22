//
//  NSSet+Additions.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 5/16/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "NSSet+Additions.h"

@implementation NSSet (Additions)

- (NSIndexSet*)indexesOfObjectsInArray:(NSArray*)array
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    NSInteger count = array.count;
    for (NSInteger index=0; index<count; ++index) {
        id object = [array objectAtIndex:index];
        
        if ([self containsObject:object]) {
            [indexSet addIndex:index];
        }
    }
    
    return [indexSet copy];
}

- (NSSet*)setByIntersectingWithSet:(NSSet*)set
{
    NSMutableSet *newSet = [NSMutableSet set];
    
    for (id object in self) {
        if ([set containsObject:object]) {
            [newSet addObject:object];
        }
    }
    
    return [newSet copy];
}

- (NSSet*)setBySubstractingSet:(NSSet*)set
{
    NSMutableSet *newSet = [self mutableCopy];
    
    for (id object in self) {
        if ([set containsObject:object]) {
            [newSet removeObject:object];
        }
    }
    
    return [newSet copy];
}

@end
