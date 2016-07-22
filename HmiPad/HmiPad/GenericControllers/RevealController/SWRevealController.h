//
//  SWModelBrowserRevealController.h
//  HmiPad
//
//  Created by Joan on 24/12/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWRevealViewController.h"
//#import "SWModelBrowserProtocols.h"

//@class SWDocumentModel;

@interface SWRevealController : SWRevealViewController // <SWModelBrowserViewController>

//- (id)initWithDocumentModel:(SWDocumentModel*)docModel;

- (id)initWithRearViewController:(UIViewController *)rearController frontViewControllers:(NSArray*)frontControllers;
- (void)setFrontViewControllerWithControllers:(NSArray*)frontControllers animated:(BOOL)animated;
- (UIViewController*)topViewController;    // torna el topFront o el rear si no n'hi ha cap
- (UIViewController*)rootFrontViewController;  // torna el root del front o nil si no n'hi ha cap
- (NSArray*)visibleViewControllers;

@end
