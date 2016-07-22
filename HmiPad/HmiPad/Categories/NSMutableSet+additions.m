//
//  NSMutableSet+additions.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 5/3/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "NSMutableSet+Additions.h"

@implementation NSMutableSet (Additions)

- (void)removeObjectsFromArray:(NSArray*)array
{
    for (id object in array) {
        [self removeObject:object];
    }
}

@end
