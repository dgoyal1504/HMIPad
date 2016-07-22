//
//  SWPropertyDescriptor.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/1/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWModelTypes.h"

@protocol SWObjectDescriptionDataSource;
@class SWValue;

typedef enum {
    SWPropertyTypeValue,
    SWPropertyTypeNoEditableValue,
    SWPropertyTypeExpression
} SWPropertyType;

@interface SWPropertyDescriptor : NSObject

- (id)initWithName:(NSString *)name type:(SWType)type propertyType:(SWPropertyType)propertyType defaultValue:(SWValue*)value;

+ (SWPropertyDescriptor*)propertyDescriptorWithName:(NSString*)name type:(SWType)type propertyType:(SWPropertyType)propertyType defaultValue:(SWValue*)value;

//@property (nonatomic, assign, readonly) BOOL editable;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, assign, readonly) SWType type;
@property (nonatomic, readonly) NSString *typeAsString;
@property (nonatomic, assign, readonly) SWPropertyType propertyType;
@property (nonatomic, readonly) SWValue *defaultValue;

- (SWValue*)defaultValueForObject:(id<SWObjectDescriptionDataSource>)object;

@end