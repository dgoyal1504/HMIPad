//
//  SWTapRecognizerItem.m
//  HmiPad
//
//  Created by Joan on 26/05/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWTapRecognizerItem.h"
#import "SWPropertyDescriptor.h"

@implementation SWTapRecognizerItem

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
    return @"tapRecognizer";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"TAP RECOGNIZER", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
    
        [SWPropertyDescriptor propertyDescriptorWithName:@"tap" type:SWTypeBool
            propertyType:SWPropertyTypeNoEditableValue defaultValue:[SWValue valueWithDouble:0.0]],
    
        [SWPropertyDescriptor propertyDescriptorWithName:@"numberOfTaps" type:SWTypeInteger
            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:1.0]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"numberOfTouches" type:SWTypeInteger
            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:1.0]],
            
        nil
    ];
}




#pragma mark - Init and Properties

- (SWValue*)tap
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}

- (SWValue*)numberOfTaps
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}

- (SWValue*)numberOfTouches
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 2];
}



#pragma mark - Overriden Methods

+ (SWItemControllerType)controllerType
{
    return SWItemControllerTypeTapRecognizer;
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
    return @"Tap Gesture Recognizer";
}

+ (UIImage*)itemIcon
{
    return [UIImage imageNamed:@"frame.png"];
}


@end
