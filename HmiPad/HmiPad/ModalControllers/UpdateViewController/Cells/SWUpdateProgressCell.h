//
//  SWUplodadProgressCell.h
//  HmiPad
//
//  Created by Joan on 02/03/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWUpdateProgressCell : UITableViewCell

@property (nonatomic) IBOutlet UILabel *labelProgress;
@property (nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic) IBOutlet UILabel *labelDetailProgress;
@property (nonatomic) IBOutlet UIProgressView *detailProgressView;

@end
