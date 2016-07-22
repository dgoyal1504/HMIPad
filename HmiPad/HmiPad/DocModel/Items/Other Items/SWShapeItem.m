//
//  SWshapeItem.m
//  HmiPad
//
//  Created by Lluch Joan on 09/07/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWShapeItem.h"
#import "SWPropertyDescriptor.h"
#import "SWEnumTypes.h"

@implementation SWShapeItem


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
    return @"shape";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"SHAPE", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
            [SWPropertyDescriptor propertyDescriptorWithName:@"animate" type:SWTypeEnumBooleanChoice
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWBooleanChoiceNo]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"fillStyle" type:SWTypeEnumFillStyle
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWFillStyleFlat]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"strokeStyle" type:SWTypeEnumStrokeStyle
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWStrokeStyleLine]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"shadowStyle" type:SWTypeEnumShadowStyle
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWShadowStyleNone]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"gradientDirection" type:SWTypeEnumDirection
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWDirectionDown]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"aspectRatio" type:SWTypeEnumAspectRatio
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWImageAspectRatioScaleToFill]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"fillColor1" type:SWTypeColor
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"lightgrey"]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"fillColor2" type:SWTypeColor
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"gray"]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"fillImage" type:SWTypeImagePath
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@""]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"cornerRadius" type:SWTypeDouble
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:5.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"lineWidth" type:SWTypeDouble
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:2.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"strokeColor" type:SWTypeColor
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"black"]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"gridColumns" type:SWTypeInteger
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:1.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"gridRows" type:SWTypeInteger
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:1.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"shadowOffset" type:SWTypeDouble
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:3.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"shadowBlur" type:SWTypeDouble
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:5.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"shadowColor" type:SWTypeColor
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"black"]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"opacity" type:SWTypeDouble
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:1]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"blink" type:SWTypeBool
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
            
            nil];
}


#pragma mark - Init and Properties

- (id)initInPage:(SWPage *)page
{
    self = [super initInPage:page];
    if (self)
    {        
        //[self.backgroundColor evalWithStringConstant:(CFStringRef)@"clearColor"];
    }
    return self;
}

- (SWValue*)animated
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

- (SWValue*)fillStyle
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}

- (SWValue*)strokeStyle
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 2];
}

- (SWValue*)shadowStyle
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 3];
}

- (SWValue*)gradientDirection
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 4];
}

- (SWValue*)aspectRatioValue
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 5];
}

- (SWExpression*)fillColor1
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 6];
}

- (SWExpression*)fillColor2
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 7];
}

- (SWExpression*)fillImage
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 8];
}

- (SWExpression*)cornerRadius
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 9];
}

- (SWExpression*)lineWidth
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 10];
}

- (SWExpression*)strokeColor
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 11];
}

- (SWExpression*)gridColumns
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 12];
}


- (SWExpression*)gridRows
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 13];
}


- (SWValue*)shadowOffset
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 14];
}

- (SWValue*)shadowBlur
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 15];
}

- (SWExpression*)shadowColor
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 16];
}

- (SWExpression*)opacity
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 17];
}

- (SWExpression*)blink
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 18];
}

#pragma mark - Overriden Methods

- (CGSize)defaultSize
{
    return CGSizeMake(170, 170);
}

- (CGSize)minimumSize
{
//    return CGSizeMake(80, 80);
    return CGSizeMake(16, 16);
}

+ (SWItemControllerType)controllerType
{
    return SWItemControllerTypeShape;
}

- (SWItemResizeMask)resizeMask
{
    return SWItemResizeMaskFlexibleHeight|SWItemResizeMaskFlexibleWidth;
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

