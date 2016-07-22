//
//  SWLayoutControllerDataSource.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/16/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

/******************************************************************/
/******************************************************************/
/**                                                              **/
/** WARNING: THIS CLASS IS ABOUT TO BE DEPRECATED. DO NOT USE IT **/
/**                                                              **/
/******************************************************************/
/******************************************************************/

#import <Foundation/Foundation.h>
#import "SWLayoutControllerTypes.h"

@class SWLayoutController;

@protocol SWLayoutControllerDataSource <NSObject>

@required
- (NSInteger)numberOfControllersInLayoutController:(SWLayoutController*)layoutController;
- (UIViewController*)layoutController:(SWLayoutController*)layoutController controllerAtIndex:(NSInteger)index;

@optional
- (NSString*)layoutController:(SWLayoutController*)layoutController titleForViewAtIndex:(NSInteger)index;
- (NSString*)layoutController:(SWLayoutController*)layoutController subtitleForViewAtIndex:(NSInteger)index;

// -- Inserting or Deleting Controllers -- //
@optional
- (BOOL)layoutController:(SWLayoutController*)layoutController canEditControllerAtIndex:(NSInteger)index;
- (void)layoutController:(SWLayoutController*)layoutController commitEditingStyle:(SWLayoutControllerEditingStyle)editingStyle forControllerAtIndex:(NSInteger)index;

@end