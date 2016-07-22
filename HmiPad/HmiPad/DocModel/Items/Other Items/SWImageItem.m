//
//  SWImageItem.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/13/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWImageItem.h"
#import "SWPropertyDescriptor.h"
#import "SWEnumTypes.h"

@implementation SWImageItem

#pragma mark - Class stuff

static SWObjectDescription *_objectDescription = nil;

+ (SWObjectDescription *)objectDescription
{
    if ( _objectDescription == nil ) {
        _objectDescription = [[SWObjectDescription alloc] initWithObjectClass:[SWImageItem class]];
    }
    return _objectDescription ;
}

+ (NSString*)defaultIdentifier
{
    return @"imageItem";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"IMAGE", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
            [SWPropertyDescriptor propertyDescriptorWithName:@"aspectRatio" type:SWTypeEnumAspectRatio 
                propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:SWImageAspectRatioScaleToFill]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"image" type:SWTypeImagePath 
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@""]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"animationDuration" type:SWTypeDouble
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithDouble:0.5]],
            
            [SWPropertyDescriptor propertyDescriptorWithName:@"tintColor" type:SWTypeColor 
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"clearColor"]],
            
            nil];
}


#pragma mark - Instance Stuff

@dynamic imagePathExpression;
@dynamic aspectRatioValue;

#pragma mark Initializers

- (id)initInPage:(SWPage *)page
{
    self = [super initInPage:page];
    if (self) 
    {
    }
    return self;
}

#pragma mark Properties

- (SWValue*)aspectRatioValue
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

- (SWExpression*)imagePathExpression
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}

- (SWExpression*)animationDurationExpression
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 2];
}

- (SWExpression*)tintColorExpression
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 3];
}

#pragma mark Overriden Methods

+ (SWItemControllerType)controllerType
{
    return SWItemControllerTypeImage;
}

- (CGSize)defaultSize
{
    return CGSizeMake(360, 210);
}

- (CGSize)minimumSize
{
//    return CGSizeMake(80, 80);
//    return CGSizeMake(8, 8);
    return CGSizeMake(16, 16);
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
    return @"Display an image stored in the application documents folder.";
}

+ (UIImage*)itemIcon
{
    return [UIImage imageNamed:@"frame.png"];
}

#pragma mark SWExpressionHolder

- (SWValue *)valueWithSymbol:(NSString *)sym property:(NSString *)property
{
    if ( property == nil ) 
        return self.imagePathExpression;
    
    return [super valueWithSymbol:sym property:property];
}

@end
