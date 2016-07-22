//
//  SWCustomSendMailController.h
//  HmiPad
//
//  Created by Joan on 08/03/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "AppModelCategories.h"
@class FileMD;

@interface UIViewController(SWSendMailControllerPresenter)
- (void)presentMailControllerForActivationCodeMD:(FileMD*)fileMD;
- (void)presentMailControllerForFiles:(NSArray*)fileMDs forCategory:(FileCategory)fileCategory;
@end


@interface UIViewController(SWExamplesController)
- (void)presentExamplesController;
@end


@interface UIViewController(ReviewAppMailController)
- (void)presentReviewAppMailController;
@end


@interface UIViewController(DownloadFromServerController)
- (void)presentDownloadFromServerControllerForFileCategory:(int)fileCategory;
@end


@interface UIViewController(SWRedeemViewController)
- (void)presentRedeemControllerForActivationCode:(NSString*)code;
//- (void)presentUpdateControllerForProjectId:(NSString*)projectId owner:(UInt32)ownerId;
- (void)presentUpdateControllerForProjectId:(NSString*)projectId;
@end


@interface UIViewController(SWUploadViewController)
- (void)presentUploadController;
@end


@interface UIViewController(SWLogToICloudAlert)
- (void)presentNoUserAlertFromView:(UIView*)view;
@end

@interface UIViewController(SWNewAccountViewController)
- (void)presentNewAccountController;
@end


@interface UIViewController(SWMigrationAssistantViewController)
- (void)presentMigrationAssistantController;
+ (void)presentMigrationAssistantController;
@end

