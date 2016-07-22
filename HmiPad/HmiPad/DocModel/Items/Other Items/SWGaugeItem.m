//
//  SWGaugeItem.m
//  HmiPad
//
//  Created by Lluch Joan on 01/06/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWGaugeItem.h"
#import "SWPropertyDescriptor.h"
#import "SWEnumTypes.h"

@implementation SWGaugeItem

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
    return @"gauge";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"GAUGE", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
            [SWPropertyDescriptor propertyDescriptorWithName:@"style" type:SWTypeEnumGaugeStyle
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWGaugeStyle1]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"options" type:SWTypeDictionary
                propertyType:SWPropertyTypeExpression
                defaultValue:[SWValue valueWithDictionary:@
                {
                    @"angleRange": @(2*M_PI-M_PI/2),
                    @"deadAnglePosition": @(-M_PI/2),
                }]],
            
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
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"Wheat"]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"needleColor" type:SWTypeColor
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"Black"]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"borderColor" type:SWTypeColor
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"SaddleBrown"]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"ranges" type:SWTypeRange
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithSWValueRange:SWValueRangeMake(0,0)]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"rangeColors" type:SWTypeColor
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"red"]],
            
            nil];
}


#pragma mark - Init

- (id)initInPage:(SWPage *)page
{
    self = [super initInPage:page];
    if (self)
    {        
      //  [self.backgroundColor evalWithStringConstant:(CFStringRef)@"clearColor"];
    }
    return self;
}


#pragma mark - Properties

- (SWValue*)style
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

- (SWValue*)options
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

- (SWExpression*)needleColor
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 10];
}

- (SWExpression*)borderColor
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 11];
}

- (SWExpression*)ranges
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 12];
}

- (SWExpression*)rangeColors
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 13];
}


#pragma mark - Overriden Methods

+ (SWItemControllerType)controllerType
{
    return SWItemControllerTypeGauge;
}

- (SWItemResizeMask)resizeMask
{
    return SWItemResizeMaskFlexibleWidth | SWItemResizeMaskFlexibleHeight;
}

- (CGSize)defaultSize
{
    return CGSizeMake(170, 170);
}

- (CGSize)minimumSize
{
    return CGSizeMake(80, 80);
}

+ (NSString*)itemName
{
    return [[self objectDescription] localizedName];
}

+ (NSString*)itemDescription
{
    return @"A circular gauge representing a value in a range";
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
