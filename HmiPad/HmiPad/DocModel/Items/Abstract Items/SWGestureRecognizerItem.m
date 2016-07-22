//
//  SWGestureRecognizerItem.m
//  HmiPad
//
//  Created by Joan on 26/05/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWGestureRecognizerItem.h"

@implementation SWGestureRecognizerItem
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
    return @"gestureRecognizer";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"GESTURE RECOGNIZER", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray array];
}

+ (SWValue*)overridenDefaultValueForPropertyName:(NSString *)propertyName
{
//    if ( [propertyName isEqualToString:@"hidden"] )
//        return [SWValue valueWithDouble:1.0];
    
    if ( [propertyName isEqualToString:@"backgroundColor"] )
        return [SWValue valueWithString:@"#000000/BF"];
    
    return nil;
}

- (CGSize)defaultSize
{
    return CGSizeMake(100, 100);
}

- (CGSize)minimumSize
{
//    return CGSizeMake(80, 80);
    return CGSizeMake(16, 16);
}

- (SWItemResizeMask)resizeMask
{
    return SWItemResizeMaskFlexibleWidth | SWItemResizeMaskFlexibleHeight;
}

+ (SWItemControllerType)controllerType
{
    return SWItemControllerTypeGestureRecognizer;
}

+ (NSString*)itemName
{
    return [[self objectDescription] localizedName];
}

+ (NSString*)itemDescription
{
    return @"Gesture Recognizer";
}

+ (UIImage*)itemIcon
{
    return [UIImage imageNamed:@"frame.png"];
}



@end
