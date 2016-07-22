//
//  SWScaleItem.m
//  HmiPad
//
//  Created by Lluch Joan on 23/05/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWScaleItem.h"
#import "SWPropertyDescriptor.h"
#import "SWEnumTypes.h"

@implementation SWScaleItem

#pragma mark - Class stuff

static SWObjectDescription *_objectDescription = nil;

+ (SWObjectDescription *)objectDescription
{
    if ( _objectDescription == nil ) _objectDescription = [[SWObjectDescription alloc] initWithObjectClass:[self class]] ;
    return _objectDescription ;
}

+ (NSString*)defaultIdentifier
{
    return @"scale";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"SCALE", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
            [SWPropertyDescriptor propertyDescriptorWithName:@"orientation" type:SWTypeEnumOrientation
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWOrientationLeft]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"minValue" type:SWTypeDouble
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"maxValue" type:SWTypeDouble
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:100.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"majorTickInterval" type:SWTypeDouble
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:5.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"minorTicksPerInterval" type:SWTypeDouble
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:4.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"format" type:SWTypeFormatString
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"%g"]],
            
            nil];
}


#pragma mark - Properties

- (SWValue*)orientation
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

- (SWExpression*)minValue
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}

- (SWExpression*)maxValue
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 2];
}

- (SWExpression*)majorTickInterval
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 3];
}

- (SWExpression*)minorTicksPerInterval
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 4];
}

- (SWExpression*)format
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 5];
}

#pragma mark - Overriden Methods

+ (SWItemControllerType)controllerType
{
    return SWItemControllerTypeScale;
}

- (SWItemResizeMask)resizeMask
{
    return SWItemResizeMaskFlexibleWidth | SWItemResizeMaskFlexibleHeight;
}

- (CGSize)defaultSize
{
    return CGSizeMake(40, 250);
}

- (CGSize)minimumSize
{
    return CGSizeMake(36, 36);
}

+ (NSString*)itemName
{
    return @"Scale";
}

+ (NSString*)itemDescription
{
    return @"A scale graphic representing a value range with intermediate ticks";
}

+ (UIImage*)itemIcon
{
    return [UIImage imageNamed:@"frame.png"];
}


@end
