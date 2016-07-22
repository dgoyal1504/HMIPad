//
//  SWArrayPickerItem.m
//  HmiPad
//
//  Created by Joan on 05/25/13.
//  Copyright (c) 2013 SweetWilliam SL. All rights reserved.
//


#import "SWDictionaryPickerItem.h"
#import "SWPropertyDescriptor.h"
#import "SWEnumTypes.h"

@implementation SWDictionaryPickerItem

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
    return @"dictionaryPicker";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"DICTIONARY PICKER", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
    
//        [SWPropertyDescriptor propertyDescriptorWithName:@"style" type:SWTypeEnumButtonStyle
//            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWButtonStyleNormal]],
            
        
        [SWPropertyDescriptor propertyDescriptorWithName:@"key" type:SWTypeAny
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"first"]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"value" type:SWTypeAny
            propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:1.0]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"dictionary" type:SWTypeDictionary
            propertyType:SWPropertyTypeExpression defaultValue:
            [SWValue valueWithDictionary:@{@"first":@(1),@"second":@(2),@"third":@(3)}]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"format" type:SWTypeFormatString
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"%"]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"color" type:SWTypeColor
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"Default"]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"textAlignment" type:SWTypeEnumTextAlignment
            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWTextAlignmentCenter]],
        
        [SWPropertyDescriptor propertyDescriptorWithName:@"verticalAlignment" type:SWTypeEnumVerticalTextAlignment
            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWVerticalTextAlignmentCenter]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"font" type:SWTypeFont
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"Helvetica-Bold"]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"fontSize" type:SWTypeInteger
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:15.0]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"active" type:SWTypeBool
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:1]],
        
        nil];
}


#pragma mark - Init and Properties

- (id)initInPage:(SWPage *)page
{
    self = [super initInPage:page];
    if (self)
    {        
    }
    return self;
}

//- (SWExpression*)buttonStyle
//{
//    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
//}

- (SWExpression*)key
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

- (SWExpression*)value
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}

- (SWExpression*)dictionary
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 2];
}

- (SWExpression*)format
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 3];
}

- (SWExpression*)color
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 4];
}

- (SWValue*)textAlignment
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 5];
}

- (SWValue*)verticalTextAlignment
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 6];
}

- (SWExpression*)font
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 7];
}

- (SWExpression*)fontSize
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 8];
}

- (SWValue*)active
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 9];
}




#pragma mark - Overriden Methods

+ (SWItemControllerType)controllerType
{
    return SWItemControllerTypeDictionaryPicker;
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
    return @"Dictionary Picker";
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
    if ( value == self.key )
    {
        SWValue *continuous = self.continuousValue;
        if ( [continuous isPromoting] )
            return;
        
        [continuous evalWithValue:value]; // el continuous value es la key !!
    }
    
    if ( value == self.key || value == self.dictionary )
    {
        SWValue *vvalue = self.value;
        if ( [vvalue isPromoting] )
            return;
    
        SWValue *theValue = [self.dictionary valueForValueKey:self.key];
        if ( theValue == nil ) theValue = [[SWValue alloc] init];  // <- error
        
        [vvalue evalWithValue:theValue];
    }
}

@end
