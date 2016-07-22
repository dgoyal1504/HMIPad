//
//  SWCustomSendMailController.h
//  HmiPad
//
//  Created by Joan on 08/03/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "AppFilesModel.h"

@class FileMD;

@interface UIViewController(SWSendMailControllerPresenter)

- (void)presentMailControllerForActivationCode:(FileMD*)fileMD;
- (void)presentMailControllerForFiles:(NSArray*)fileMDs forCategory:(FileCategory)fileCategory;

@end
