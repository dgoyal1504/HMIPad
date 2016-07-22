//
//  SWValueTypes.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/4/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWValueTypes.h"
#import "Pair.h"

#pragma mark - SWType

const static Pair swValueTypePairs [] =
{
    { @"Error", SWValueTypeError },
    //{ @"NoSource", SWValueTypeNoSource },
    { @"Number", SWValueTypeNumber },
    { @"AbsoluteTime", SWValueTypeAbsoluteTime },
    { @"Point", SWValueTypePoint },
    { @"Size", SWValueTypeSize },
    { @"Rect", SWValueTypeRect },
    { @"String", SWValueTypeString },
    { @"Object", SWValueTypeObject },
    { @"Array", SWValueTypeArray },
    { @"Hash", SWValueTypeHash },
    { @"Selector", SWValueTypeClassSelector },
};
const static int swValueTypePairsCount = sizeof(swValueTypePairs)/sizeof(Pair);

NSString* NSStringFromSWValueType(SWValueType valueType)
{
    return PairStringForNumber(swValueTypePairs, swValueTypePairsCount, valueType);
}

NSString* NSLocalizedStringFromSWValueType(SWValueType valueType)
{
    return NSLocalizedString(NSStringFromSWValueType(valueType), nil);
}

SWValueType SWValueTypeFromNSString(NSString* string)
{
    return PairNumberForString(swValueTypePairs, swValueTypePairsCount, string);
}

