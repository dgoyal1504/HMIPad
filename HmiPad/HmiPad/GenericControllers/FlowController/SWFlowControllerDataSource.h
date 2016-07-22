//
//  SWFlowControllerDataSource.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/8/12.
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
#import "SWFlowControllerTypes.h"

@class SWFlowController;



@protocol SWFlowControllerDataSource <NSObject>

@required
- (NSInteger)numberOfControllersInFlowController:(SWFlowController*)flowController;
- (UIViewController*)flowController:(SWFlowController*)flowController controllerAtIndex:(NSInteger)index;

@optional
- (NSString*)flowController:(SWFlowController*)flowController titleForViewAtIndex:(NSInteger)index;
- (NSString*)flowController:(SWFlowController*)flowController subtitleForViewAtIndex:(NSInteger)index;

// -- Inserting or Deleting Controllers -- //
@optional
- (BOOL)flowController:(SWFlowController*)flowController canEditControllerAtIndex:(NSInteger)index;
- (void)flowController:(SWFlowController*)flowController commitEditingStyle:(SWFlowControllerEditingStyle)editingStyle forControllerAtIndex:(NSInteger)index;

@end
