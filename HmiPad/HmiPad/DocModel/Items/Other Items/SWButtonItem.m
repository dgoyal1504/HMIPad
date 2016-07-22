//
//  SWButtonItem.m
//  HmiPad
//
//  Created by Joan on 03/07/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import "SWButtonItem.h"
#import "SWPropertyDescriptor.h"
#import "SWEnumTypes.h"

#import "SWDocumentModel.h"

@implementation SWButtonItem

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
    return @"button";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"BUTTON", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
    
        [SWPropertyDescriptor propertyDescriptorWithName:@"style" type:SWTypeEnumButtonStyle
            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWButtonStyleNormal]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"value" type:SWTypeBool
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"color" type:SWTypeColor
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"Default"]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"title" type:SWTypeString
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"Button"]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"textAlignment" type:SWTypeEnumTextAlignment
            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWTextAlignmentCenter]],
        
        [SWPropertyDescriptor propertyDescriptorWithName:@"verticalAlignment" type:SWTypeEnumVerticalTextAlignment
            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWVerticalTextAlignmentCenter]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"font" type:SWTypeFont
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"Helvetica-Bold"]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"fontSize" type:SWTypeInteger
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:15.0]],

        [SWPropertyDescriptor propertyDescriptorWithName:@"image" type:SWTypeImagePath
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@""]],

        [SWPropertyDescriptor propertyDescriptorWithName:@"aspectRatio" type:SWTypeEnumAspectRatio
            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWImageAspectRatioFit]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"animationDuration" type:SWTypeDouble
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.5]],

        [SWPropertyDescriptor propertyDescriptorWithName:@"active" type:SWTypeBool
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:1]],

        [SWPropertyDescriptor propertyDescriptorWithName:@"linkToPage" type:SWTypeString
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@""]],

        nil];
}



//@dynamic state;
//@dynamic color;
//@dynamic title;
//@dynamic font;
//@dynamic fontSize;

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

- (SWExpression*)buttonStyle
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

- (SWExpression*)title
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 3];
}

- (SWValue*)textAlignment
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 4];
}

- (SWValue*)verticalTextAlignment
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 5];
}

- (SWExpression*)font
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 6];
}

- (SWExpression*)fontSize
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 7];
}

- (SWExpression*)imagePath
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 8];
}

- (SWValue*)aspectRatio
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 9];
}

- (SWExpression*)animationDuration
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 10];
}

- (SWValue*)active
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 11];
}

- (SWExpression*)linkToPage
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 12];
}




#pragma mark - Overriden Methods

+ (SWItemControllerType)controllerType
{
    return SWItemControllerTypeButton;
}

- (SWItemResizeMask)resizeMask
{
    return SWItemResizeMaskFlexibleHeight|SWItemResizeMaskFlexibleWidth;
}

- (CGSize)defaultSize
{
    return CGSizeMake(120, 30);
}

+ (NSString*)itemName
{
    return [[self objectDescription] localizedName];
}

+ (NSString*)itemDescription
{
    return @"Item to manipulate boolean expressions with instant on/off response (Button like).";
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
        if ( ![continuous isPromoting] )
        {
            [continuous evalWithValue:value];
        }
        
        if ( !_docModel.editMode )
        {
            BOOL bValue = [value valueAsBool];
            if ( bValue )
            {
                NSString *pageIdentifier = [self.linkToPage valueAsString];
                if ( pageIdentifier.length > 0 )
                {
                    [_docModel selectPageWithPageIdentifier:pageIdentifier];
                }
            }
        }
    }
}

@end
