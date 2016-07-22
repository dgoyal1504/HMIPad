//
//  SWArrayPickerItem.m
//  HmiPad
//
//  Created by Joan on 05/25/13.
//  Copyright (c) 2013 SweetWilliam SL. All rights reserved.
//


#import "SWArrayPickerItem.h"
#import "SWPropertyDescriptor.h"
#import "SWEnumTypes.h"

#import "SWDocumentModel.h"

@implementation SWArrayPickerItem

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
    return @"arrayPicker";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"ARRAY PICKER", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
    
//        [SWPropertyDescriptor propertyDescriptorWithName:@"style" type:SWTypeEnumButtonStyle
//            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWButtonStyleNormal]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"element" type:SWTypeAny
            propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithString:@""]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"index" type:SWTypeInteger
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"array" type:SWTypeAny
            propertyType:SWPropertyTypeExpression defaultValue:
            [SWValue valueWithArray:@[@"Element0",@"Element1",@"Element2"]]],
            
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
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"linkToPages" type:SWTypeAny
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithArray:@[]]],
        
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

- (SWValue*)element
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

- (SWExpression*)index
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}

- (SWExpression*)array
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

- (SWExpression*)linkToPages
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 10];
}


#pragma mark - Overriden Methods

+ (SWItemControllerType)controllerType
{
    return SWItemControllerTypeArrayPicker;
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
    return @"Array Picker";
}

+ (UIImage*)itemIcon
{
    return [UIImage imageNamed:@"frame.png"];
}

#pragma mark SWExpressionHolder


- (NSString*)replacementKeyForKey:(NSString *)key
{
    if ( [key isEqualToString:@"index"] )
        return @"value";
    
    return nil;
}


- (SWValue*)valueWithSymbol:(NSString *)sym property:(NSString *)property
{
    if (property == nil) 
        return self.index;
    
    if ( [property isEqualToString:@"value"] )
        return self.index;
    
    return [super valueWithSymbol:sym property:property];
}


- (void)value:(SWValue *)value didTriggerWithChange:(BOOL)changed
{
    if ( value == self.index )
    {
        NSInteger index = [value valueAsInteger];
        SWValue *continuous = self.continuousValue;
        if ( ![continuous isPromoting] )
        {
            [continuous evalWithValue:value];
        }
        
        if ( !_docModel.editMode )
        {
            SWValue *pageIdentifierVal = [self.linkToPages valueAtIndex:index];
            NSString *pageIdentifier = [pageIdentifierVal valueAsString];
            if ( pageIdentifier.length > 0 )
            {
                [_docModel selectPageWithPageIdentifier:pageIdentifier];
            }
        }
    }
    
    if ( value == self.index || value == self.array )
    {
        SWValue *vElement = self.element;
        if ( [vElement isPromoting] )
            return;
        
        NSInteger index = [self.index valueAsInteger];
        SWValue *theValue = [self.array valueAtIndex:index];
        if ( theValue == nil ) theValue = [[SWValue alloc] init];  // <- error
    
        [vElement evalWithValue:theValue];
    }
}

@end
