//
//  SWSourcesViewControllerHeader.h
//  HmiPad
//
//  Created by Joan Lluch on 18/05/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWDocumentModel;

@interface SWSourcesViewControllerHeader : UIView

@property (nonatomic, strong) IBOutlet UILabel *cpuLabel;

@property (nonatomic, strong) IBOutlet UILabel *alarmsLabel;
@property (nonatomic, strong) IBOutlet UIImageView *imageViewAlarm;

@property (nonatomic, strong) IBOutlet UILabel *userLabel;

@property (nonatomic, strong) IBOutlet UILabel *connectionLabel;
@property (nonatomic, strong) IBOutlet UIImageView *imageViewConnection;

@property (nonatomic, strong) IBOutlet UILabel *tagsLabel;
@property (nonatomic, strong) IBOutlet UIImageView *imageViewTag;


@end
