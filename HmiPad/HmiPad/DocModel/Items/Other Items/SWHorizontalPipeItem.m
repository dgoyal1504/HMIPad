//
//  SWHorizontalPipeItem.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/17/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWHorizontalPipeItem.h"
#import "SWPropertyDescriptor.h"

@implementation SWHorizontalPipeItem

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
    return @"pipe";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"HORIZONTAL PIPE", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
            [SWPropertyDescriptor propertyDescriptorWithName:@"color" type:SWTypeColor
                propertyType:SWPropertyTypeExpression defaultValue:[SWValue valueWithString:@"SteelBlue"]], 
            nil];
}

#pragma mark - Init and Properties

//@dynamic color;

- (id)initInPage:(SWPage *)page
{
    self = [super initInPage:page];
    if (self)
    {
    }
    return self;
}

- (SWExpression*)color
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

#pragma mark - Overriden Methods

+ (SWItemControllerType)controllerType
{
    return SWItemControllerTypeHorizontalPipe;
}

- (CGSize)defaultSize
{
    return CGSizeMake(40, 10);
}

- (CGSize)minimumSize
{
    return CGSizeMake(10, 10);
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
    return @"Pipe line in horizontal position. Color can be customized.";
}

+ (UIImage*)itemIcon
{
    return [UIImage imageNamed:@"frame.png"];
}

@end

