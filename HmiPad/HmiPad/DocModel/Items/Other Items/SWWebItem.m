//
//  SWWebItem.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/4/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWWebItem.h"
#import "SWPropertyDescriptor.h"
//#import "Reachability.h"

@implementation SWWebItem
{
}

#pragma mark - Class stuff

static SWObjectDescription *_objectDescription = nil;

+ (SWObjectDescription *)objectDescription
{
    if ( _objectDescription == nil ) {
        _objectDescription = [[SWObjectDescription alloc] initWithObjectClass:[self class]];
    }
    return _objectDescription;
}

+ (NSString*)defaultIdentifier
{
    return @"webItem";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"WEB BROWSER", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
    
        [SWPropertyDescriptor propertyDescriptorWithName:@"url" type:SWTypeUrl
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"http://www.google.com"]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"goBack" type:SWTypeBool
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"goForward" type:SWTypeBool
            propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0]],
            
        nil];
}

+ (SWValue*)overridenDefaultValueForPropertyName:(NSString*)propertyName
{
    if ( [propertyName isEqualToString:@"backgroundColor"])
        return [SWValue valueWithString:@"White"];
    
    return nil;
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

#pragma mark - Overriden Methods

- (SWItemResizeMask)resizeMask
{
    return SWItemResizeMaskFlexibleWidth | SWItemResizeMaskFlexibleHeight;
}

- (CGSize)defaultSize
{
    return CGSizeMake(440, 270);
}

#pragma mark - Properties

- (SWExpression*)urlExpression
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

- (SWExpression*)goBackExpression
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}

- (SWExpression*)goForwardExpression
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 2];
}



#pragma mark - Main Methods


#pragma mark - Overriden Methods

+ (SWItemControllerType)controllerType
{
    return SWItemControllerTypeWeb;
}

+ (NSString*)itemName
{
    return [[self objectDescription] localizedName];
}

+ (NSString*)itemDescription
{
    return @"Web browser embedded in an item. You can display web content and modify the item state dynamicaly.";
}

+ (UIImage*)itemIcon
{
    return [UIImage imageNamed:@"wifi.png"];
}

#pragma mark protocol ValueHolder

- (SWValue*)valueWithSymbol:(NSString *)sym property:(NSString *)property
{
    if ( property == nil ) 
        return self.urlExpression;
    
    return [super valueWithSymbol:sym property:property];
}


@end
