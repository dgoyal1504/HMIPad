//
//  SWStyledSwitchItem.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/16/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWStyledSwitchItem.h"
#import "SWPropertyDescriptor.h"
#import "SWEnumTypes.h"

@implementation SWStyledSwitchItem

#pragma mark - Class stuff

static SWObjectDescription *_objectDescription = nil;

+ (SWObjectDescription *)objectDescription
{
    if ( _objectDescription == nil ) {
        _objectDescription = [[SWObjectDescription alloc] initWithObjectClass:[self class]];
    }
    return _objectDescription ;
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"STYLED SWITCH", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:            
            [SWPropertyDescriptor propertyDescriptorWithName:@"style" type:SWTypeEnumSwitchStyle
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWSwitchStyleApple]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"color" type:SWTypeColor
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"DodgerBlue"]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"active" type:SWTypeBool
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:1]],
            
            nil];
}


#pragma mark - Init and Properties

@dynamic switchStyle;
@dynamic color;

- (id)initInPage:(SWPage *)page
{
    self = [super initInPage:page];
    if (self)
    {        
        //[self.backgroundColor evalWithStringConstant:(CFStringRef)@"clearColor"];
    }
    return self;
}

- (SWValue*)switchStyle
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

- (SWExpression*)color
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}

- (SWExpression*)active
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 2];
}

#pragma mark - Overriden Methods

+ (SWItemControllerType)controllerType
{
    return SWItemControllerTypeStyledSwitch;
}

- (SWItemResizeMask)resizeMask
{
    return SWItemResizeMaskNone;
}

- (CGSize)defaultSize
{
    if ( IS_IOS7 ) return CGSizeMake(52, 30);
    // ^-- la mida real de un UISwitch es de 51x31, amb 52x30 fem coincidir l'alzada del SWStyledSwitch amb la de un SWButton
    else return CGSizeMake(79, 27);
}

- (CGSize)minimumSize
{
    if ( IS_IOS7 ) return CGSizeMake(52, 30);
    else return CGSizeMake(79, 27);
}

+ (NSString*)itemName
{
    return [[self objectDescription] localizedName];
}


+ (NSString*)itemDescription
{
    return @"Item to manipulate boolean expressions with remanent effect (Switch like).";
}

+ (UIImage*)itemIcon
{
    return [UIImage imageNamed:@"frame.png"];
}



@end
