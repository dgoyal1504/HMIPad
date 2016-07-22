//
//  SWUplodadProgressCell.h
//  HmiPad
//
//  Created by Joan on 02/03/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ColoredButton;

@interface SWUpdateProjectCell : UITableViewCell

@property (nonatomic) IBOutlet UILabel *labelName;
@property (nonatomic) IBOutlet UILabel *labelUUID;
@property (nonatomic) IBOutlet UILabel *labelOwner;
@property (nonatomic) IBOutlet UILabel *labelDate;
@property (nonatomic) IBOutlet UILabel *labelSize;

@property (nonatomic) IBOutlet ColoredButton *buttonUpdate;
@property (nonatomic) IBOutlet UILabel *labelStatus;

@end
