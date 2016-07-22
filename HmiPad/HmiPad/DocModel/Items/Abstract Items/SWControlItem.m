//
//  SWControlItem.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/18/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWControlItem.h"
#import "SWPropertyDescriptor.h"

@implementation SWControlItem

#pragma mark - Class stuff

static SWObjectDescription *_objectDescription = nil;

+ (SWObjectDescription *)objectDescription
{
    if ( _objectDescription == nil ) {
        _objectDescription = [[SWObjectDescription alloc] initWithObjectClass:[self class]];
    }
    return _objectDescription ;
}

+ (NSString*)defaultIdentifier
{
    return @"control";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"CONTROL", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
    
            [SWPropertyDescriptor propertyDescriptorWithName:@"continuousValue" type:SWTypeAny
                propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"enabled" type:SWTypeBool
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:1.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"verificationText" type:SWTypeString
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@""]],
            
            nil];
}

#pragma mark - Init and Properties


- (SWValue*)continuousValue
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

- (SWExpression*)enabled
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}

- (SWExpression*)verificationText
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 2];
}

#pragma mark SWExpressionHolder

- (SWValue*)valueWithSymbol:(NSString *)sym property:(NSString *)property
{
    if (property == nil) 
        return self.enabled;
    
    return [super valueWithSymbol:sym property:property];
}

@end
