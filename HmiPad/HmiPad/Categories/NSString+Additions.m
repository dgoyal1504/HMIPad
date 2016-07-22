//
//  NSString+Additions.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 5/14/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

+ (NSString*)stringWithBitsOfInteger:(NSInteger)value
{
    NSInteger theNumber = value;
    NSMutableString *str = [NSMutableString string];
    NSInteger numberCopy = theNumber;
    for(NSInteger i=0; i<8; i++) {
        [str insertString:((numberCopy & 1) ? @"1" : @"0") atIndex:0];
        numberCopy >>= 1;
    }
    
    return [str copy];
}

@end
