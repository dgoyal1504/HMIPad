//
//  SW.m
//  HmiPad
//
//  Created by Joan Lluch on 25/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import "SWProjectUser.h"
#import "SWPropertyDescriptor.h"
#import "SWDocumentModel.h"

@implementation SWProjectUser
{
//    BOOL _isChangingP;
}

#pragma mark ObjectDescription

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
    return @"user";
}

+ (NSString*)localizedName
{
    return NSLocalizedString(@"USER", nil);
}

+ (NSArray*)propertyDescriptions
{
    return [NSArray arrayWithObjects:
       
        [SWPropertyDescriptor propertyDescriptorWithName:@"userName" type:SWTypeString
            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithString:@"user"]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"password" type:SWTypeString
            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithString:@"pass"]],
            
        [SWPropertyDescriptor propertyDescriptorWithName:@"accessLevel" type:SWTypeInteger
            propertyType:SWPropertyTypeValue defaultValue:[SWValue valueWithDouble:9]],
            
        nil];
}


#pragma mark - Properties

- (SWValue*)userName
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 0];
}


- (SWValue*)userP
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 1];
}


- (SWValue*)userL
{
    return [_properties objectAtIndex:_objectDescription.firstClassPropertyIndex + 2];
}


#pragma mark - Value Holder

//- (void)value:(SWValue *)value didTriggerWithChange:(BOOL)changed
//{
//    if ( value == self.userP && !_isChangingP )
//    {
//        NSString *pass = value.valueAsString;
//        NSString *cryptPass = [pass stringByAppendingString:@"--"];
//    
//        _isChangingP = YES;
//        [value evalWithString:cryptPass];
//        _isChangingP = NO;
//    }
//}

- (void)value:(SWValue *)value didTriggerWithChange:(BOOL)changed
{
    NSLog( @"triger");
    if ( value == self.userName || value == self.userL )
    {
        if ( _docModel.selectedProjectUser == self )
        {
            [_docModel selectProjectUser:self];
        }
    }
}


@end
