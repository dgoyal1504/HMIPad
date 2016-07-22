//
//  SWUploadViewController.h
//  HmiPad
//
//  Created by Joan on 18/01/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ColoredButton;

@interface SWSubscribeViewController : UIViewController

@property (nonatomic) IBOutlet UILabel *labelHeader;
@property (nonatomic) IBOutlet UILabel *labelProgress;
@property (nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic) IBOutlet UILabel *labelDetailProgress;
@property (nonatomic) IBOutlet UIProgressView *detailProgressView;

@property (nonatomic) IBOutlet ColoredButton *buttonUpload;

- (IBAction)uploadButtonAction:(id)sender;

@end
