//
//  SWObjectDescription.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 5/23/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SWObject;
@class SWValue;
@class SWObjectDescription;

@protocol SWObjectDescriptionDataSource <NSObject>

@required
+ (SWObjectDescription*)objectDescription;
+ (Class)defaultControllerClass;
+ (NSString*)localizedName;
+ (NSString*)defaultIdentifier;

+ (NSArray*)propertyDescriptions;
+ (SWValue*)overridenDefaultValueForPropertyName:(NSString*)propertyName;

// property descriptions de la instancia (adicionals als proporcionats per el SWObjectDescription de la seva clase)
- (NSArray*)propertyDescriptions;

@end


@interface SWObjectDescription : NSObject

- (id)initWithObjectClass:(Class <SWObjectDescriptionDataSource>)objectClass;

@property (nonatomic, assign) Class objectClass;
@property (nonatomic, assign) Class controllerClass;

@property (nonatomic, strong) NSString *defaultIdentifier;
@property (nonatomic, strong) NSString *localizedName;

@property (nonatomic, strong) NSArray *propertyDescriptions;  // array de SWPropertyDescriptor
@property (nonatomic, strong) NSArray *allPropertyDescriptions;  // array de SWPropertyDescriptor
@property (nonatomic, assign) NSInteger firstClassPropertyIndex;  // index a la primera propietat

@property (nonatomic, weak) SWObjectDescription *superClassInfo;  // el SWObjectDescriptor superior
@property (nonatomic, readonly) NSInteger depth;

@end
