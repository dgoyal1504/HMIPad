//
//  SWLampItem.m
//  HmiPad
//
//  Created by Lluch Joan on 09/07/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWLampItem.h"
#import "SWPropertyDescriptor.h"

@implementation SWLampItem


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
    return @"lamp";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"LAMP", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:            
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"value" type:SWTypeBool
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"blink" type:SWTypeBool
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"color" type:SWTypeColor
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"BarDefault"]],
            
            nil];
}


#pragma mark - Init and Properties

- (id)initInPage:(SWPage *)page
{
    self = [super initInPage:page];
    if (self)
    {        
       // [self.backgroundColor evalWithStringConstant:(CFStringRef)@"clearColor"];
    }
    return self;
}

- (SWExpression*)value
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

- (SWExpression*)blink
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}

- (SWExpression*)color
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 2];
}

#pragma mark - Overriden Methods

+ (SWItemControllerType)controllerType
{
    return SWItemControllerTypeLamp;
}

- (SWItemResizeMask)resizeMask
{
    return SWItemResizeMaskFlexibleHeight|SWItemResizeMaskFlexibleWidth;
}

- (CGSize)defaultSize
{
    return CGSizeMake(40, 40);
}

- (CGSize)minimumSize
{
    return CGSizeMake(26, 26);
}

+ (NSString*)itemName
{
    return [[self objectDescription] localizedName];
}


+ (NSString*)itemDescription
{
    return @"Item to display a boolean value.";
}

+ (UIImage*)itemIcon
{
    return [UIImage imageNamed:@"frame.png"];
}


@end

