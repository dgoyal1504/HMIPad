//
//  SWCustomSwitchItem.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/5/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWCustomSwitchItem.h"
#import "SWExpression.h"
#import "RpnBuilder.h"
#import "SWPropertyDescriptor.h"
#import "SWEnumTypes.h"

@implementation SWCustomSwitchItem

#pragma mark - Class stuff

static SWObjectDescription *_objectDescription = nil;

+ (SWObjectDescription *)objectDescription
{
    if ( _objectDescription == nil ) {
        _objectDescription = [[SWObjectDescription alloc] initWithObjectClass:[self class]];
    }
    return _objectDescription ;
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"CUSTOM SWITCH", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"imageOn" type:SWTypeImagePath
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@""]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"aspectRatioOn" type:SWTypeEnumAspectRatio
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWImageAspectRatioFit]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"imageOff" type:SWTypeImagePath
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@""]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"aspectRatioOff" type:SWTypeEnumAspectRatio
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWImageAspectRatioFit]],
            
            nil];
    
            
}

#pragma mark - Init and Properties

@dynamic aspectRatioForStateOn;
@dynamic aspectRatioForStateOff;
@dynamic imagePathForStateOn;
@dynamic imagePathForStateOff;

- (SWExpression*)imagePathForStateOn
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

- (SWValue*)aspectRatioForStateOn
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}

- (SWExpression*)imagePathForStateOff
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 2];
}

- (SWValue*)aspectRatioForStateOff
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 3];
}


#pragma mark - Overriden Methods

+ (SWItemControllerType)controllerType
{
    return SWItemControllerTypeCustomSwitch;
}

- (SWItemResizeMask)resizeMask
{
    return SWItemResizeMaskFlexibleHeight | SWItemResizeMaskFlexibleWidth;
}

- (CGSize)defaultSize
{
    return CGSizeMake(120, 120);
}

+ (NSString*)itemName
{
    return [[self objectDescription] localizedName];
}

+ (NSString*)itemDescription
{
    return @"Customizable switch to manipulate boolean expressions with remanent effect.";
}

+ (UIImage*)itemIcon
{
    return [UIImage imageNamed:@"frame.png"];
}


@end