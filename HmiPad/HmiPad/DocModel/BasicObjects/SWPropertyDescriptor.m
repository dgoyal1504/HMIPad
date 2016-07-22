//
//  SWPropertyDescriptor.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/1/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWPropertyDescriptor.h"
#import "SWObjectDescription.h"

@implementation SWPropertyDescriptor

@synthesize name = _name;
@synthesize type = _type;
@synthesize propertyType = _propertyType;
@synthesize defaultValue = _defaultValue;

- (id)initWithName:(NSString *)name type:(SWType)type propertyType:(SWPropertyType)propertyType defaultValue:(SWValue*)value
{
    self = [super init];
    if (self) {
        _name = name;
        _type = type;
        _defaultValue = value;
        _propertyType = propertyType;
    }
    return self;
}

- (SWValue*)defaultValueForObject:(id<SWObjectDescriptionDataSource>)object
{
    SWValue *defaultValue = [[object class] overridenDefaultValueForPropertyName:_name];
    if ( defaultValue != nil )
        return defaultValue;

    return _defaultValue;
}


- (NSString*)typeAsString
{
    return NSLocalizedStringFromSWType(_type);
}

+ (SWPropertyDescriptor*)propertyDescriptorWithName:(NSString*)name type:(SWType)type propertyType:(SWPropertyType)propertyType defaultValue:(SWValue*)value
{
    return [[SWPropertyDescriptor alloc] initWithName:name type:type propertyType:propertyType defaultValue:value];
}

@end
