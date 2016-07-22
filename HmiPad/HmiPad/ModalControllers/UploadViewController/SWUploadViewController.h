//
//  SWUploadViewController.h
//  HmiPad
//
//  Created by Joan on 18/01/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewController.h"

//@class ColoredButton;
@class SWDocumentModel;

@interface SWUploadViewController : SWTableViewController

@property (nonatomic) IBOutlet UILabel *labelHeader;

@property (nonatomic) SWDocumentModel *docModel;
//@property (nonatomic) IBOutlet UILabel *labelProgress;
//@property (nonatomic) IBOutlet UIProgressView *progressView;
//@property (nonatomic) IBOutlet UILabel *labelDetailProgress;
//@property (nonatomic) IBOutlet UIProgressView *detailProgressView;
//
//@property (nonatomic) IBOutlet ColoredButton *buttonUpload;
//
//- (void)uploadButtonAction:(id)sender;

@end
