//
//  SWSliderItem.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/16/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWSliderItem.h"
#import "SWPropertyDescriptor.h"
#import "SWEnumTypes.h"

@implementation SWSliderItem

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
    return @"slider";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"SLIDER", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
    
            [SWPropertyDescriptor propertyDescriptorWithName:@"orientation" type:SWTypeEnumOrientation2
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWOrientationHorizontal]],
    
            [SWPropertyDescriptor propertyDescriptorWithName:@"value" type:SWTypeDouble
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"color" type:SWTypeColor
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@""]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"minValue" type:SWTypeDouble
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"maxValue" type:SWTypeDouble
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:100.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"format" type:SWTypeFormatString
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"%0.4g"]],
            
            nil];
}


#pragma mark - Init and Properties

@dynamic value;
@dynamic color;
@dynamic maxValue;
@dynamic minValue;

- (id)initInPage:(SWPage *)page
{
    self = [super initInPage:page];
    if (self)
    {        
       // [self.backgroundColor evalWithStringConstant:(CFStringRef)@"clearColor"];
    }
    return self;
}

- (SWValue*)orientation
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

- (SWExpression*)value
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}

- (SWExpression*)color
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

- (SWExpression*)format
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 5];
}

#pragma mark - Overriden Methods

+ (SWItemControllerType)controllerType
{
    return SWItemControllerTypeSlider;
}

- (SWItemResizeMask)resizeMask
{
    return SWItemResizeMaskFlexibleWidth | SWItemResizeMaskFlexibleHeight;
}

- (CGSize)defaultSize
{
    return CGSizeMake(150, 30);
}

- (CGSize)minimumSize
{
    return CGSizeMake(30, 30);
}

+ (NSString*)itemName
{
    return [[self objectDescription] localizedName];
}

+ (NSString*)itemDescription
{
    return @"A simple slider to manipulate expressions. Color, max and min values are customizable.";
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
