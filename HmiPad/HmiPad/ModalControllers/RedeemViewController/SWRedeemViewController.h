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

extern NSString *SWRedeemViewControllerWillOpenProjectNotification;


@interface SWRedeemViewController : SWTableViewController

@property (nonatomic) IBOutlet UILabel *labelHeader;
@property (nonatomic) IBOutlet UILabel *labelTitle;

// aquestes dues son mutualment exclusives
@property (nonatomic,retain) NSString *activationCode;
@property (nonatomic,retain) NSString *projectCode;
//@property (nonatomic) UInt32 projectOwner;

@end
