//
//  UIFont+AllFonts.m
//  HmiPad
//
//  Created by Joan Lluch on 12/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "UIFont+AllFonts.h"

@implementation UIFont (AllFonts)

+ (NSArray*)allFonts
{
    NSMutableArray *allFonts = [NSMutableArray array];
    NSArray *familyNames = [[UIFont familyNames] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *familyName in familyNames)
    {
        NSArray *names = [UIFont fontNamesForFamilyName:familyName];
        [allFonts addObjectsFromArray:names];
    }

    return allFonts;
}

@end
