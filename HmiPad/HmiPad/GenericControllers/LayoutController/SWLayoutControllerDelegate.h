//
//  SWLayoutControllerDelegate.h
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

@class SWLayoutController;

/**
 * SWLayoutController delegate protocol.
 * In case that the UIViewController doesn't conforms to the SWLayoutViewController, the SWLayoutController will ask the delegate about their position and size. If there is no delegate or it doesn't implement those methods, the SWLayoutController will chose freedly those values.
 */
@protocol SWLayoutControllerDelegate < NSObject>

@optional

/**
 * Positon methods
 */
- (CGPoint)layoutController:(SWLayoutController*)layoutController positionForViewController:(UIViewController*)viewController;
- (void)layoutController:(SWLayoutController*)layoutController viewController:(UIViewController*)viewController movedToPosition:(CGPoint)position;

/**
 * Size methods
 */
- (CGSize)layoutController:(SWLayoutController*)layoutController sizeForViewController:(UIViewController*)viewController;
- (void)layoutController:(SWLayoutController*)layoutController viewController:(UIViewController*)viewController updatedToViewSize:(CGSize)size;

@end