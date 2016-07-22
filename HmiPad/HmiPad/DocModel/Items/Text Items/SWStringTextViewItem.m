//
//  SWTextFieldItem.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/12/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWStringTextViewItem.h"
#import "SWPropertyDescriptor.h"
#import "SWEnumTypes.h"

#pragma mark - Class stuff

@implementation SWStringTextViewItem

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
    return @"textView";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"TEXT VIEW", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
            [SWPropertyDescriptor propertyDescriptorWithName:@"value" type:SWTypeString
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@""]],
            
//            [SWPropertyDescriptor propertyDescriptorWithName:@"style" type:SWTypeEnumTextFieldStyle
//                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWTextFieldStyleBezel]],
//            
//            [SWPropertyDescriptor propertyDescriptorWithName:@"secureInput" type:SWTypeBool
//                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:0.0]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"format" type:SWTypeFormatString
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"%"]],
            nil];
}

+ (SWValue*)overridenDefaultValueForPropertyName:(NSString*)propertyName
{
    if ( [propertyName isEqualToString:@"backgroundColor"])
        return [SWValue valueWithString:@"White"];
    
    return nil;
}

#pragma mark - Init and Properties

////@dynamic inputType;
//@dynamic secureInput;
//@dynamic value;
//@dynamic format;

- (SWExpression*)value
{ 
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

//- (SWValue*)style
//{
//    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
//}

//- (SWValue*)secureInput
//{
//    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
//}

- (SWExpression*)format
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}

#pragma mark - Overriden Methods

+ (SWItemControllerType)controllerType
{
    return SWItemControllerTypeStringTextView;
}

- (SWItemResizeMask)resizeMask
{
    return SWItemResizeMaskFlexibleWidth | SWItemResizeMaskFlexibleHeight;
}

+ (NSString*)itemName
{
    return [[self objectDescription] localizedName];
}


+ (NSString*)itemDescription
{
    return @"TextField is an item to display text.";
}

+ (UIImage*)itemIcon
{
    return [UIImage imageNamed:@"frame.png"];
}

- (CGSize)minimumSize
{
    return CGSizeMake(16, 16);
    //return CGSizeMake(40, 20);
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
    if ( value == self.value && !_controlIsEditing )
    {
        SWValue *continuous = self.continuousValue;
        if ( [continuous isPromoting] )
            return;
        
        [continuous evalWithValue:value];
    }
}

@end
