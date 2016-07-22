//
//  NSIndexSet+Additions.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 5/16/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexSet (Additions)

- (NSIndexSet*)intersectionWithIndexSet:(NSIndexSet*)indexSet;
- (NSIndexSet*)substractIndexSet:(NSIndexSet*)indexSet;

@end
