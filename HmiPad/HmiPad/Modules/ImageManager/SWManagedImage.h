//
//  SWManagedImage.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/9/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SWImageDescriptor.h"
#import "QuickCoder.h"

@class SWImageManager;

@interface SWManagedImage : SWImageDescriptor <QuickCoding>

@property (nonatomic, strong) NSString* path;

@property (nonatomic, assign) NSTimeInterval creationDate;
@property (nonatomic, assign) NSTimeInterval accessDate;

// podem asignar prioritat alta
@property (nonatomic, assign) BOOL hasPriority;

- (id)initWithDescriptor:(SWImageDescriptor*)descriptor;

@end
