//
//  SWInspectorViewController.h
//  HmiPad
//
//  Created by Joan on 19/02/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SWDocumentModel;

@interface SWInspectorViewController : UITabBarController

- (id)initWithDocumentModel:(SWDocumentModel*)docModel;

- (UIColor*)preferredCellBackgroundColor;
- (void)showEventsList;

@end
