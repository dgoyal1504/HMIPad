//
//  SWUplodadProgressCell.h
//  HmiPad
//
//  Created by Joan on 02/03/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColoredButton.h"


@class SWUploadActivationCodeCell;

@protocol SWUploadActivationCodeCellDelegate<NSObject>

- (void)activationCodeCellDidTouchEmail:(SWUploadActivationCodeCell*)cell;

@end



@interface SWUploadActivationCodeCell : UITableViewCell

@property (nonatomic) IBOutlet UILabel *labelName;
//@property (nonatomic) IBOutlet UILabel *labelProjectUUID;
@property (nonatomic) IBOutlet UILabel *labelCode;
@property (nonatomic) IBOutlet UILabel *labelDate;
@property (nonatomic) IBOutlet UILabel *labelTotal;
@property (nonatomic) IBOutlet UILabel *labelUsed;

@property (nonatomic) IBOutlet ColoredButton *buttonEmail;


@property (nonatomic,weak) id<SWUploadActivationCodeCellDelegate> delegate;
@property (nonatomic) id fileMD;

- (IBAction)emailActivationCodeAction:(id)sender;

@end
