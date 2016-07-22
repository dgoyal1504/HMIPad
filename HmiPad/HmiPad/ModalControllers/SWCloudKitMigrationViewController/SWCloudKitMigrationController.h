//
//  SWCloudKitMigrationController.h
//  HmiPad
//
//  Created by joan on 13/08/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWCircleButton;

@interface SWCloudKitMigrationController : UIViewController

@property (nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) IBOutlet UIView *scrollContentView;
@property (nonatomic) IBOutlet UILabel *labelTopMessage;

@property (nonatomic) IBOutlet UIButton *buttonLogIn;
@property (nonatomic) IBOutlet UIButton *buttonAccountToCloud;
@property (nonatomic) IBOutlet UIButton *buttonMoveToCloud;
@property (nonatomic) IBOutlet SWCircleButton *buttonClose;
@property (nonatomic) IBOutlet SWCircleButton *buttonSupport;


@property (nonatomic) IBOutlet UILabel *labelCurrentUserICLoud;
@property (nonatomic) IBOutlet UILabel *labelCurrentUserIServer;
@property (nonatomic) IBOutlet UILabel *labelCurrentUserMovedICLoud;

@property (nonatomic) IBOutlet UILabel *labelProgress1;
@property (nonatomic) IBOutlet UILabel *labelProgress2;


//@property (nonatomic) IBOutlet UIProgressView *progressView1;
//@property (nonatomic) IBOutlet UIProgressView *progressView2;
@property (nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorIcloud;
@property (nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorIServer;
@property (nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorMoveUser;
@property (nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorMigrate;

@property (nonatomic) IBOutlet UIImageView *imageViewLogIcloud;
@property (nonatomic) IBOutlet UIImageView *imageViewLogIServer;
@property (nonatomic) IBOutlet UIImageView *imageViewMoveUser;
@property (nonatomic) IBOutlet UIImageView *imageViewMigrate;

@end
