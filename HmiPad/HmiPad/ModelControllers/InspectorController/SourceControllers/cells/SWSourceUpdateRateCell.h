//
//  SWSourceUpdateRateCell.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/20/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWSourceItemCell.h"

@interface SWSourceUpdateRateCell : SWSourceItemCell

@property (weak, nonatomic) IBOutlet UILabel *cpsLabel;
@property (weak, nonatomic) IBOutlet UILabel *rpsLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *cpsProgressView;
@property (weak, nonatomic) IBOutlet UIProgressView *rpsProgressView;

@end
