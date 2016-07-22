//
//  SWUserInterfaceValidations.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 5/11/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SWValidatedUserInterfaceItem.h"

@protocol SWUserInterfaceValidations <NSObject>

- (BOOL)validateUserInterfaceItem:(id<SWValidatedUserInterfaceItem>)anItem;

@end

