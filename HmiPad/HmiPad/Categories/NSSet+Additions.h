//
//  NSSet+Additions.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 5/16/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSSet (Additions)

- (NSIndexSet*)indexesOfObjectsInArray:(NSArray*)array;

- (NSSet*)setByIntersectingWithSet:(NSSet*)set;
- (NSSet*)setBySubstractingSet:(NSSet*)set;

@end
