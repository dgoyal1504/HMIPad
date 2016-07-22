//
//  SWBarLevelItem.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/16/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWBarLevelItem.h"
#import "SWPropertyDescriptor.h"
#import "SWEnumTypes.h"

@implementation SWBarLevelItem

#pragma mark - Class stuff

static SWObjectDescription *_objectDescription = nil;

+ (SWObjectDescription *)objectDescription
{
    if ( _objectDescription == nil ) {
        _objectDescription = [[SWObjectDescription alloc] initWithObjectClass:[SWBarLevelItem class]];
    }
    return _objectDescription ;
}

+ (NSString*)defaultIdentifier
{
    return @"barLevel";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"BAR LEVEL", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
        [SWPropertyDescriptor propertyDescriptorWithName:@"direction" type:SWTypeEnumDirection
            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWDirectionUp]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"value" type:SWTypeDouble
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"barColor" type:SWTypeColor
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"DodgerBlue"]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"tintColor" type:SWTypeColor
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"White"]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"borderColor" type:SWTypeColor
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"Gray"]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"minValue" type:SWTypeDouble
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"maxValue" type:SWTypeDouble
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:100.0]], 
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"format" type:SWTypeFormatString
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"%0.4g"]],
            
        nil];
}



- (NSString*)replacementKeyForKey:(NSString *)key
{
    if ( [key isEqualToString:@"barColor"] )
        return @"color";     // <-- provem color si barColor no el troba

    return nil;
}


#pragma mark - Init and Properties

@dynamic value;
@dynamic barColor;
@dynamic maxValue;
@dynamic minValue;

- (SWValue*)direction
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

- (SWExpression*)value
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}

- (SWExpression*)barColor
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 2];
}

- (SWExpression*)tintColor
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 3];
}

- (SWExpression*)borderColor
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 4];
}

- (SWExpression*)minValue
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 5];
}

- (SWExpression*)maxValue
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 6];
}

- (SWExpression*)format
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 7];
}


#pragma mark - Overriden Methods

+ (SWItemControllerType)controllerType
{
    return SWItemControllerTypeBarLevel;
}

- (SWItemResizeMask)resizeMask
{
    return SWItemResizeMaskFlexibleWidth | SWItemResizeMaskFlexibleHeight;
}

- (CGSize)defaultSize
{
    return CGSizeMake(36, 250);
}

- (CGSize)minimumSize
{
    return CGSizeMake(20, 36);
}

+ (NSString*)itemName
{
    return [[self objectDescription] localizedName];
}

+ (NSString*)itemDescription
{
    return @"A vertical bar will increase or decrease following an expression. Color, max and min values are customizable.";
}

+ (UIImage*)itemIcon
{
    return [UIImage imageNamed:@"frame.png"];
}

#pragma mark SWExpressionHolder

- (SWValue*)valueWithSymbol:(NSString *)sym property:(NSString *)property
{
    if (property == nil) 
        return self.value;
    
    if ( [property isEqualToString:@"color"] )
        return self.barColor;
    
    return [super valueWithSymbol:sym property:property];
}

@end
