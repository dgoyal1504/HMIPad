//
//  SWKnobItem.m
//  HmiPad
//
//  Created by Lluch Joan on 27/06/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWKnobItem.h"
#import "SWPropertyDescriptor.h"
#import "SWEnumTypes.h"

@implementation SWKnobItem

#pragma mark - Class stuff

static SWObjectDescription *_objectDescription = nil;

+ (SWObjectDescription *)objectDescription
{
    if ( _objectDescription == nil ) 
        _objectDescription = [[SWObjectDescription alloc] initWithObjectClass:[self class]] ;
        
    return _objectDescription ;
}

+ (NSString*)defaultIdentifier
{
    return @"knob";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"KNOB CONTROL", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
            [SWPropertyDescriptor propertyDescriptorWithName:@"style" type:SWTypeEnumKnobStyle
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWKnobStyle1]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"thumbStyle" type:SWTypeEnumKnobThumbStyle
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWKnobThumbStyleSegment]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"value" type:SWTypeDouble
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
            
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
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"label" type:SWTypeString
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@""]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"tintColor" type:SWTypeColor
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"#999999"]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"thumbColor" type:SWTypeColor
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"#000000"]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"borderColor" type:SWTypeColor
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"#999999"]],
            
            nil];
}


#pragma mark - Init

- (id)initInPage:(SWPage *)page
{
    self = [super initInPage:page];
    if (self)
    {        
        //[self.backgroundColor evalWithStringConstant:(CFStringRef)@"clearColor"];
    }
    return self;
}

#pragma mark - Properties

- (SWValue*)style
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

- (SWValue*)thumbStyle
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}

- (SWExpression*)value
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 2];
}

- (SWExpression*)minValue
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 3];
}

- (SWExpression*)maxValue
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 4];
}

- (SWExpression*)majorTickInterval
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 5];
}

- (SWExpression*)minorTicksPerInterval
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 6];
}

- (SWExpression*)format
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 7];
}

- (SWExpression*)label
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 8];
}

- (SWExpression*)tintColor
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 9];
}

- (SWExpression*)thumbColor
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 10];
}

- (SWExpression*)borderColor
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 11];
}

#pragma mark - Overriden Methods

+ (SWItemControllerType)controllerType
{
    return SWItemControllerTypeKnob;
}

- (SWItemResizeMask)resizeMask
{
    return SWItemResizeMaskFlexibleWidth | SWItemResizeMaskFlexibleHeight;
}

- (CGSize)defaultSize
{
    return CGSizeMake(160, 160);
}

- (CGSize)minimumSize
{
    return CGSizeMake(130, 130);
}

+ (NSString*)itemName
{
    return [[self objectDescription] localizedName];
}

+ (NSString*)itemDescription
{
    return @"A rotary knob control to set a value in a range";
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

- (void)value:(SWValue *)value didTriggerWithChange:(BOOL)changed
{
    if ( value == self.value )
    {
        SWValue *continuous = self.continuousValue;
        if ( [continuous isPromoting] )
            return;
        
        [continuous evalWithValue:value];
    }
}

@end
