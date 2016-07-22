//
//  SWTextItem.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/12/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWTextItem.h"
#import "SWPropertyDescriptor.h"
#import "SWEnumTypes.h"

@implementation SWTextItem

#pragma mark Class stuff

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
    return @"text";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"TEXT PROPERTIES", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
            [SWPropertyDescriptor propertyDescriptorWithName:@"textAlignment" type:SWTypeEnumTextAlignment
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWTextAlignmentCenter]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"verticalAlignment" type:SWTypeEnumVerticalTextAlignment
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWVerticalTextAlignmentCenter]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"fontColor" type:SWTypeColor
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"Black"]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"font" type:SWTypeFont
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"Helvetica"]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"fontSize" type:SWTypeDouble
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:15.0]],
            nil];
}

#pragma mark Init and Properties

@dynamic textAlignment;
@dynamic textColor;
@dynamic font;
@dynamic fontSize;

- (SWValue*)textAlignment
{ 
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

- (SWValue*)verticalTextAlignment
{ 
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}

- (SWExpression*)textColor
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 2];
}

- (SWExpression*)font
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 3];
}

- (SWExpression*)fontSize
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 4];
}

#pragma mark Overriden Methods

- (CGSize)defaultSize
{
    return CGSizeMake(138, 30);
}

@end

