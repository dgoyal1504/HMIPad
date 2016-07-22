//
//  SWValueTypes.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 31/05/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

/*
#import "SWValueTypes.h"

#pragma mark - SWStorageType

static NSString * const StringStorageTypeUndefined = @"SWStorageTypeUndefined";
static NSString * const StringStorageTypeInteger = @"SWStorageTypeInteger";
static NSString * const StringStorageTypeBool = @"SWStorageTypeBool";
static NSString * const StringStorageTypeFloat = @"SWStorageTypeFloat";
static NSString * const StringStorageTypeDouble = @"SWStorageTypeDouble";
static NSString * const StringStorageTypePoint = @"SWStorageTypePoint";
static NSString * const StringStorageTypeSize = @"SWStorageTypeSize";
static NSString * const StringStorageTypeRect = @"SWStorageTypeRect";
static NSString * const StringStorageTypeString = @"SWStorageTypeString";
static NSString * const StringStorageTypePointer = @"SWStorageTypePointer";

NSString *NSStringFromSWStorageType(SWStorageType type) {
    NSString *string = nil;
    
    switch (type) {
        case SWStorageTypeUndefined:
            string = StringStorageTypeUndefined;
            break;
        case SWStorageTypeInteger:
            string = StringStorageTypeInteger;
            break;
        case SWStorageTypeBool:
            string = StringStorageTypeBool;
            break;
        case SWStorageTypeFloat:
            string = StringStorageTypeFloat;
            break;
        case SWStorageTypeDouble:
            string = StringStorageTypeDouble;
            break;
        case SWStorageTypePoint:
            string = StringStorageTypePoint;
            break;
        case SWStorageTypeSize:
            string = StringStorageTypeSize;
            break;
        case SWStorageTypeRect:
            string = StringStorageTypeRect;
            break;
        case SWStorageTypeObject:
            string = StringStorageTypePointer;
            break;
        case SWStorageTypeString:
            string = StringStorageTypeString;
            break;
        default:
            break;
    }
    
    return string;
}

SWStorageType SWStorageTypeFromString(NSString *string) {
    SWStorageType type = SWStorageTypeUndefined;
    
    if ([string isEqualToString:StringStorageTypeInteger]) {
        type = SWStorageTypeInteger;
    } else if ([string isEqualToString:StringStorageTypeBool]) {
        type = SWStorageTypeBool;
    } else if ([string isEqualToString:StringStorageTypeFloat]) {
        type = SWStorageTypeFloat;
    } else if ([string isEqualToString:StringStorageTypeDouble]) {
        type = SWStorageTypeDouble;
    } else if ([string isEqualToString:StringStorageTypePoint]) {
        type = SWStorageTypePoint;
    } else if ([string isEqualToString:StringStorageTypeSize]) {
        type = SWStorageTypeSize;
    } else if ([string isEqualToString:StringStorageTypeRect]) {
        type = SWStorageTypeRect;
    } else if ([string isEqualToString:StringStorageTypePointer]) {
        type = SWStorageTypeObject;
    } else if ([string isEqualToString:StringStorageTypeString]) {
        type = SWStorageTypeString;
    }
    
    return type;
}

*/