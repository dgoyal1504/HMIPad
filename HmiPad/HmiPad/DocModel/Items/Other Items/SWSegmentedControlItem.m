//
//  SWSegmentedControlItem.h
//  HmiPad
//
//  Created by Joan on 05/25/13.
//  Copyright (c) 2013 SweetWilliam SL. All rights reserved.
//


#import "SWSegmentedControlItem.h"
#import "SWPropertyDescriptor.h"
#import "SWEnumTypes.h"

#import "SWDocumentModel.h"

@implementation SWSegmentedControlItem

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
    return @"segmentedControl";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"SEGMENTED CONTROL", nil);
}


+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
    
        [SWPropertyDescriptor propertyDescriptorWithName:@"value" type:SWTypeInteger
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.0]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"array" type:SWTypeAny
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithArray:@[@"One",@"Two",@"Three"]]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"format" type:SWTypeFormatString
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"%"]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"color" type:SWTypeColor
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"Default"]],
            
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

- (SWExpression*)value
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

- (SWExpression*)array
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}

- (SWExpression*)format
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 2];
}

- (SWExpression*)color
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 3];
}

- (SWValue*)active
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 4];
}

- (SWExpression*)linkToPages
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 5];
}


#pragma mark - Overriden Methods

+ (SWItemControllerType)controllerType
{
   // return SWItemControllerTypeArrayPicker;
    return SWItemControllerTypeSegmentedControl;
}

- (SWItemResizeMask)resizeMask
{
    return SWItemResizeMaskFlexibleWidth;
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
    return @"Segmented Control";
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
            NSInteger iValue = [value valueAsInteger];
            SWValue *pageIdentifierVal = [self.linkToPages valueAtIndex:iValue];
            NSString *pageIdentifier = [pageIdentifierVal valueAsString];
            if ( pageIdentifier.length > 0 )
            {
                [_docModel selectPageWithPageIdentifier:pageIdentifier];
            }
        }
    }
}

@end
