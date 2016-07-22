//
//  SWHPIndicatorItem.m
//  HmiPad
//
//  Created by Joan Lluch on 6/23/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWHPIndicatorItem.h"
#import "SWPropertyDescriptor.h"
#import "SWEnumTypes.h"

@implementation SWHPIndicatorItem

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
    return @"rangeIndicator";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"RANGE INDICATOR", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
        [SWPropertyDescriptor propertyDescriptorWithName:@"direction" type:SWTypeEnumDirection
            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWDirectionUp]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"value" type:SWTypeDouble
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"minValue" type:SWTypeDouble
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"maxValue" type:SWTypeDouble
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:100.0]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"format" type:SWTypeFormatString
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"%0.4g"]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"tintColor" type:SWTypeColor
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"White"]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"needleColor" type:SWTypeColor
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"DodgerBlue"]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"borderColor" type:SWTypeColor
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"Gray"]],
            
//        [SWPropertyDescriptor propertyDescriptorWithName:@"ranges" type:SWTypeRange
//            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithSWValueRange:SWValueRangeMake(0,0)]],
            
        
        [SWPropertyDescriptor propertyDescriptorWithName:@"ranges" type:SWTypeRange
            propertyType:SWPropertyTypeExpression defaultValue:
            [SWValue valueWithArray:
                @[
                    [SWValue valueWithSWValueRange:SWValueRangeMake(0,15)],
                    [SWValue valueWithSWValueRange:SWValueRangeMake(85,100)],
                ]
            ]
        ],
//            
//        [SWPropertyDescriptor propertyDescriptorWithName:@"rangeColors" type:SWTypeColor
//            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"red"]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"rangeColors" type:SWTypeColor
            propertyType:SWPropertyTypeExpression defaultValue:
            [SWValue valueWithArray:
                @[
                    @"SlateGray",
                    @"SlateGray",
                ]
            ]
        ],
            
        nil];
}



#pragma mark - Init and Properties


- (SWValue*)direction
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

- (SWExpression*)value
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}

- (SWExpression*)minValue
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 2];
}

- (SWExpression*)maxValue
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 3];
}

- (SWExpression*)format
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 4];
}

- (SWExpression*)tintColor
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 5];
}

- (SWExpression*)needleColor
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 6];
}

- (SWExpression*)borderColor
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 7];
}

- (SWExpression*)ranges
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 8];
}

- (SWExpression*)rangeColors
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 9];
}



#pragma mark - Overriden Methods

+ (SWItemControllerType)controllerType
{
    return SWItemControllerTypeHPIndicator;
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
    return @"A lineal range indicator as described in the High Performance HMI book";
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
        
    return [super valueWithSymbol:sym property:property];
}

@end
