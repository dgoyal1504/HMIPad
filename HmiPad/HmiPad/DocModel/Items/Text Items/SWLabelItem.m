//
//  SWLabelItem.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/16/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWLabelItem.h"
#import "SWPropertyDescriptor.h"
#import "SWEnumTypes.h"

@implementation SWLabelItem

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
    return @"label";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"LABEL", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
    
        [SWPropertyDescriptor propertyDescriptorWithName:@"value" type:SWTypeAny
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"Label"]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"format" type:SWTypeFormatString
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"%"]],

       // [SWPropertyDescriptor propertyDescriptorWithName:@"verticalAlignment" type:SWTypeEnumVerticalTextAlignment
       //     propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWVerticalTextAlignmentCenter]],
    
        nil];
}

@dynamic value;
@dynamic format;

#pragma mark - Init and Properties

- (SWExpression*)value
{ 
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

- (SWExpression*)format
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}

//- (SWValue*)verticalTextAlignment
//{
//    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 2];
//}

#pragma mark - Overriden Methods

+ (SWItemControllerType)controllerType
{
    return SWItemControllerTypeLabel;
}

- (SWItemResizeMask)resizeMask
{
    return SWItemResizeMaskFlexibleWidth | SWItemResizeMaskFlexibleHeight;
}

+ (NSString*)itemName
{
    return [[self objectDescription] localizedName];
}

+ (NSString*)itemDescription
{
    return @"Item to display text. Text font, color and size can be customized.";
}

+ (UIImage*)itemIcon
{
    return [UIImage imageNamed:@"frame.png"];
}

- (CGSize)minimumSize
{
    return CGSizeMake(16, 16);
//    return CGSizeMake(40, 20);
}

@end
